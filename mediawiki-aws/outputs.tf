output "mediawiki_url" {
  description = "URL to access MediaWiki"
  value = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value = aws_db_instance.wiki_db.address
}

output "secure_mediawiki_url" {
  description = "API Gateway-protected URL for MediaWiki"
  value       = "https://${aws_api_gateway_deployment.wiki_deploy.invoke_url}/prod/wiki"
}
