resource "aws_transfer_server" "transfer_family" {
  endpoint_type          = "PUBLIC"
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.transfer_logging.arn
  protocols              = ["SFTP"]
  domain                 = "EFS"

  tags = {
    Name        = "${var.project_name}-transfer-server"
    Environment = var.environment
  }
}

resource "aws_transfer_user" "mediawiki_user" {
  server_id = aws_transfer_server.transfer_family.id
  user_name = var.transfer_user_name
  role      = aws_iam_role.transfer_family.arn

  home_directory_type = "LOGICAL"

  home_directory_mappings {
    entry  = "/"
    target = "/${aws_efs_access_point.mediawiki_settings.id}"
  }

  tags = {
    Name        = var.transfer_user_name
    Environment = var.environment
  }
}

resource "aws_transfer_ssh_key" "transfer_ssh_key" {
  server_id = aws_transfer_server.transfer_family.id
  user_name = aws_transfer_user.mediawiki_user.user_name
  body      = var.transfer_ssh_public_key
}
