output "mediawiki_url" {
  description = "URL to access MediaWiki"
  value = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value = aws_db_instance.wiki_db.address
}
