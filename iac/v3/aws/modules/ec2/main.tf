# ────────────────────────────────────────────────────────────────────────────────
# Security Groups
# ────────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "k8s" {
  name_prefix        = "${var.project_name}-sg-k8s-"
  description = "Kubernetes components SG"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Kubernetes API Server
  ingress {
    description = "K8s API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # etcd
  ingress {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # kubelet API
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # kube-scheduler
  ingress {
    description = "Kube Scheduler"
    from_port   = 10251
    to_port     = 10251
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # kube-controller-manager
  ingress {
    description = "Kube Controller Manager"
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # NodePort 서비스 (필요 시 외부에 공개할 수 있도록 열어둠)
  ingress {
    description = "K8s NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Grafana UI
  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # ArgoCD UI
  ingress {
    description = "ArgoCD UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # Redis
  ingress {
    description = "ArgoCD UI"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-k8s"
  }
}

resource "aws_security_group" "gpu" {
  name_prefix        = "${var.project_name}-sg-gpu-"
  description = "Instance using GPU"
  vpc_id      = var.vpc_id
  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Fast API
  ingress {
    description = "fastapi"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Grafana UI
  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  # ArgoCD UI
  ingress {
    description = "ArgoCD UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-gpu"
  }
}

# ────────────────────────────────────────────────────────────────────────────────
# Key Pairs
# ────────────────────────────────────────────────────────────────────────────────
resource "tls_private_key" "ec2" {
  for_each = { for node in var.ec2_nodes : node.name => node }

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  for_each   = tls_private_key.ec2
  key_name   = "${var.project_name}-keypair-${each.key}"
  public_key = each.value.public_key_openssh
}

resource "local_file" "private_key" {
  for_each = tls_private_key.ec2

  content  = each.value.private_key_pem
  filename = "${path.module}/keys/${each.key}.pem"
  file_permission = "0400"
}



# ────────────────────────────────────────────────────────────────────────────────
# EC2 Instances
# ────────────────────────────────────────────────────────────────────────────────
resource "aws_instance" "nodes" {
  for_each                    = { for node in var.ec2_nodes : node.name => node }
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  key_name                    = aws_key_pair.ec2[each.key].key_name
  associate_public_ip_address = each.value.role == "gpu"

  vpc_security_group_ids = [
    each.value.role == "gpu"
    ? aws_security_group.gpu.id
    : aws_security_group.k8s.id
  ]

  tags = {
    Name = "${var.project_name}-ec2-${each.key}"
  }
}

resource "aws_launch_template" "template" {
  for_each      = { for node in var.ec2_nodes : node.name => node }
  name_prefix   = "${var.project_name}-${each.key}-lt"
  image_id      = each.value.ami
  instance_type = each.value.instance_type

  # key_name = aws_key_pair.this.key_name # lookup(each.value, "key_name", null)
  user_data = base64encode(
    templatefile(
      "${path.module}/templates/base.sh.tpl",
      {
        node_name    = each.key
        project_name = var.project_name
        region       = var.region
      }
    )
  )

  network_interfaces {
    device_index = 0
    subnet_id    = each.value.subnet_id
    security_groups = [each.value.role == "gpu"
      ? aws_security_group.gpu.id
    : aws_security_group.k8s.id]
    associate_public_ip_address = each.value.role == "gpu"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ec2-lt-${each.key}"
    }
  }
}