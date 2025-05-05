output "mediawiki_url" {
  description = "URL to access MediaWiki"
  value       = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wiki_db.address
}

output "guardduty_detector_id" {
  description = "ID of GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "sftp_endpoint" {
  description = "SFTP endpoint for AWS Transfer Family"
  value       = aws_transfer_server.transfer_family.endpoint
}

output "sftp_username" {
  description = "Username for SFTP access"
  value       = aws_transfer_user.mediawiki_user.user_name
}
