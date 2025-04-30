resource "aws_efs_file_system" "mediawiki_settings" {
  creation_token = "${var.project_name}-settings-efs"
  encrypted      = true

  tags = {
    Name        = "${var.project_name}-settings-efs"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "mediawiki_settings" {
  count           = length(aws_subnet.public)
  file_system_id  = aws_efs_file_system.mediawiki_settings.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "mediawiki_settings" {
  file_system_id = aws_efs_file_system.mediawiki_settings.id

  posix_user {
    gid = 33 # www-data group ID in the container
    uid = 33 # www-data user ID in the container
  }

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }

  tags = {
    Name        = "${var.project_name}-efs-access-point"
    Environment = var.environment
  }
}
