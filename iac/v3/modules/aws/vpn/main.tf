# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.project_name}-client-vpn"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_root_certificate_arn
  }
  connection_log_options { enabled = false }
  transport_protocol = "udp"
  vpn_port           = 443
  split_tunnel       = false
}

# 서브넷과 연결
resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = var.subnet_ids
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

# VPC 전체 라우트
resource "aws_ec2_client_vpn_route" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = var.vpc_cidr_block
  target_vpc_subnet_id = var.subnet_ids["subnet-0"]
}

# 모든 그룹에 인가 규칙 허용
resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
  description            = "Allow all VPC access"
}
