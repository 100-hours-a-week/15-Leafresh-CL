output "endpoint_id" {
  description = "생성된 Client VPN Endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "endpoint_dns_name" {
  description = "Client VPN 접속용 DNS 이름"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}
