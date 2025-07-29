# VPC 전체 라우트
data "aws_subnet" "selected" {
  for_each = var.subnet_ids # 중복 ID 자동 제거
  id       = each.value
}

locals {
  unique_subnet_by_az = {
    for key, subnet in data.aws_subnet.selected :
    subnet.availability_zone => subnet.id
  }
  first_subnet_id = element(values(local.unique_subnet_by_az), 0)
}

# ACM Certificate for Client  
# openssl genrsa -out client.key 2048
# openssl req -new -key client.key -out client.csr  
# openssl req -new -key client.key -out client.csr -subj "/CN=client.dev-leafresh.app"
# openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365

# ACM Certificate for Server
# Generate server key and cert:
# openssl genrsa -out server.key 2048
# openssl req -new -key server.key -out server.csr -subj "/CN=vpn.dev-leafresh.app"
# openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365


resource "aws_acm_certificate" "server" {
  private_key       = file("${path.module}/certs/server.key")
  certificate_body  = file("${path.module}/certs/server.crt")
  certificate_chain = file("${path.module}/certs/ca.crt")
}

resource "aws_acm_certificate" "client" {
  private_key       = file("${path.module}/certs/client.key") 
  certificate_body  = file("${path.module}/certs/client.crt")
  certificate_chain = file("${path.module}/certs/ca.crt")
}

# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.project_name}-client-vpn"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block     = var.client_cidr_block

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client.arn
  }

  connection_log_options {
    enabled = false
  }

  transport_protocol = "udp"
  vpn_port          = 443
  split_tunnel      = false
}

# 서브넷과 연결
resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = var.subnet_ids
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

# 모든 그룹에 인가 규칙 허용
resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
  description            = "Allow all VPC access"
}

resource "null_resource" "ensure_vpn_route" {
  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 create-client-vpn-route \
        --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.this.id} \
        --destination-cidr-block ${var.vpc_cidr_block} \
        --target-vpc-subnet-id ${local.first_subnet_id} \
        || echo "Route exists or other error—skipping"
    EOT

    on_failure = continue
  }
}

