# IAM roles and policies

resource "aws_iam_role" "ecs_execution_role" {
  name                  = "${var.project_name}-ecs_execution_role"
  description           = "ECS Execution Role for pulling container images"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ecs_execution_role"
    Environment = var.environment
  }
}
# IAM role and policy for AWS Transfer Family to access EFS
resource "aws_iam_role" "transfer_family" {
  name = "${var.project_name}-transfer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-transfer-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "transfer_family_efs_access" {
  name = "${var.project_name}-transfer-efs-access"
  role = aws_iam_role.transfer_family.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = [
          aws_efs_file_system.mediawiki_settings.arn,
          aws_efs_access_point.mediawiki_settings.arn,
          "${aws_efs_file_system.mediawiki_settings.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:CreateAccessPoint",
          "elasticfilesystem:PutFileSystemPolicy"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name                  = "${var.project_name}-ecs-task-role"
  description           = "ECS Task Role"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ecs_task_role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "ecs_efs_access" {
  name        = "${var.project_name}-efs-access-policy"
  description = "Policy for ECS tasks to access EFS and create directories"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = aws_efs_file_system.mediawiki_settings.arn
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = aws_efs_access_point.mediawiki_settings.arn
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_s3_access" {
  name        = "${var.project_name}-s3-access-policy"
  description = "Policy for ECS tasks to access S3 bucket for wiki uploads"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.wikiuploads.arn,
          "${aws_s3_bucket.wikiuploads.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.wikiuploads.arn}/config/LocalSettings.php"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_s3_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_s3_access.arn
}

# IAM role for Transfer Family logging
resource "aws_iam_role" "transfer_logging" {
  name = "${var.project_name}-transfer-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-transfer-logging-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "transfer_logging" {
  name = "${var.project_name}-transfer-logging-policy"
  role = aws_iam_role.transfer_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
