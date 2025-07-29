output "endpoint_id" {
  description = "생성된 Client VPN Endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "endpoint_dns_name" {
  description = "Client VPN 접속용 DNS 이름"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "server_certificate_arn" {
  value = aws_acm_certificate.server.arn
}
output "server_domain_validation_options" {
  value = aws_acm_certificate.server.domain_validation_options
}
output "client_certificate_arn" {
  value = aws_acm_certificate.client.arn
}
output "client_domain_validation_options" {
  value = aws_acm_certificate.client.domain_validation_options
}