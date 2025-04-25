output "mediawiki_url" {
  description = "URL to access MediaWiki"
  value       = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wiki_db.address
}

output "cognito_user_pool_id" {
  description = "The Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "The Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_user_pool_domain" {
  value = aws_cognito_user_pool_domain.main.domain
}
