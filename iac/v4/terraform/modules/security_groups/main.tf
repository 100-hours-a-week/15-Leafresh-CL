# modules/security_groups/main.tf

locals {
  ssh_sg_name         = "${var.vpc_name}-sg-ssh"
  ai_sg_name          = "${var.vpc_name}-sg-ai"
  db_sg_name          = "${var.vpc_name}-sg-db"
  ops_sg_name         = "${var.vpc_name}-sg-ops"
  eks_cluster_sg_name = "${var.vpc_name}-sg-eks-cluster"
  eks_worker_sg_name  = "${var.vpc_name}-sg-eks-worker"
  monitoring_sg_name  = "${var.vpc_name}-sg-monitoring"
}

resource "aws_security_group" "ssh" {
  name_prefix = local.ssh_sg_name
  vpc_id      = var.vpc_id
  description = "Allow SSH access from specified CIDR blocks"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "Allow SSH from trusted networks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = local.ssh_sg_name
  }
}

# 2. EKS Control Plane / Worker Node 통신을 위한 보안 그룹 (No change from last fix)

resource "aws_security_group" "eks_cluster" {
  name_prefix = local.eks_cluster_sg_name
  vpc_id      = var.vpc_id
  description = "EKS Cluster communication"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from EKS cluster"
  }

  tags = {
    Name = local.eks_cluster_sg_name
  }
}

resource "aws_security_group" "eks_worker" {
  name_prefix = local.eks_worker_sg_name
  vpc_id      = var.vpc_id
  description = "EKS Worker Node communication"

  # Self-referencing rule is fine here:
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true # Allow communication within the same security group
    description = "Allow all internal communication within worker nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from worker nodes"
  }

  tags = {
    Name = local.eks_worker_sg_name
  }
}

# --- aws_security_group_rule resources (No change from last fix) ---

resource "aws_security_group_rule" "eks_cluster_ingress_worker_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_worker.id
  description              = "Allow EKS worker nodes to communicate with control plane (HTTPS)"
}

resource "aws_security_group_rule" "eks_cluster_ingress_worker_10250" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_worker.id
  description              = "Allow Kubelet from EKS worker nodes"
}

resource "aws_security_group_rule" "eks_worker_node_ingress_cluster_10250" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_cluster.id
  description              = "Allow Kubelet from EKS control plane"
}

resource "aws_security_group_rule" "eks_worker_node_ingress_cluster_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_cluster.id
  description              = "Allow control plane outbound to worker nodes"
}

# --- Database Access Security Group ---
resource "aws_security_group" "db" {
  name_prefix = local.db_sg_name
  vpc_id      = var.vpc_id
  description = "Allow database access from application/EKS tiers"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from DB"
  }

  tags = {
    Name = local.db_sg_name
  }
}

# Database Access Ingress Rules (Corrected app_server and ops_tools references)
resource "aws_security_group_rule" "db_ingress_eks_worker" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.eks_worker.id
  description              = "Allow DB access from EKS worker nodes"
}

resource "aws_security_group_rule" "db_ingress_app_server" {
  # Use condition on 'count' if 'enable_app_server_sg' is false,
  # the resource will not be created, preventing reference errors.
  count                    = var.enable_app_server_sg ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ai.id
  description              = "Allow DB access from App Server"
}

resource "aws_security_group_rule" "db_ingress_ops_tools" {
  # Use condition on 'count' if 'enable_ops_tools_sg' is false,
  # the resource will not be created, preventing reference errors.
  count                    = var.enable_ops_tools_sg ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ops.id
  description              = "Allow DB access from Ops Tools"
}

# 4. 애플리케이션 서버 보안 그룹 (No change from last fix)
resource "aws_security_group" "ai" {
  name_prefix = local.ai_sg_name
  vpc_id      = var.vpc_id
  description = "Application Server Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow HTTP from VPC"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow HTTPS from VPC"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh.id]
    description     = "Allow SSH from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = local.ai_sg_name
  }
}


# 5. 운영 도구 (Ops Tools) 보안 그룹 (No change from last fix)
resource "aws_security_group" "ops" {
  name_prefix = local.ops_sg_name
  vpc_id      = var.vpc_id
  description = "Security Group for Operations Tools"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh.id]
    description     = "Allow SSH from bastion"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow Jenkins access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = local.ops_sg_name
  }
}


# 6. 모니터링 보안 그룹 (Self-referential block corrected)
resource "aws_security_group" "monitoring" {
  name_prefix = local.monitoring_sg_name
  vpc_id      = var.vpc_id
  description = "Security Group for Monitoring Services"

  ingress {
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.ops.id]
    description     = "Allow Prometheus Node Exporter from Ops"
  }

  # New ingress block for self-referencing
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    self        = true # This is how you allow traffic from the SG to itself
    description = "Allow Prometheus Node Exporter from Monitoring (self)"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh.id]
    description     = "Allow SSH from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = local.monitoring_sg_name
  }
}
