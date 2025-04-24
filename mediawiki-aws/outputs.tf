output "mediawiki_url" {
  description = "URL to access MediaWiki"
  value       = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wiki_db.address
}

output "secure_mediawiki_base_url" {
  description = "API-Gateway URL including stage"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "secure_mediawiki_wiki_url" {
  description = "API-Gateway URL including /wiki prefix"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/wiki"
}

output "cognito_user_pool_id" {
  description = "The Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "The Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

