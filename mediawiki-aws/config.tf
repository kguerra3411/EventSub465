# AWS Config Setup

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "aws_config_bucket" {
  bucket = "my-aws-config-bucket-${random_id.bucket_id.hex}"

  force_destroy = true
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "aws_config_bucket_policy" {
  bucket = aws_s3_bucket.aws_config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.aws_config_bucket.arn,
          "${aws_s3_bucket.aws_config_bucket.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "aws_config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "aws_config_policy" {
  name = "aws-config-inline-policy"
  role = aws_iam_role.aws_config_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ],
        Resource = [
          aws_s3_bucket.aws_config_bucket.arn,
          "${aws_s3_bucket.aws_config_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "config:Put*",
          "config:Get*",
          "config:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "aws_config_recorder" {
  name     = "default"
  role_arn = aws_iam_role.aws_config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "aws_config_delivery_channel" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.aws_config_bucket.bucket

  depends_on = [
    aws_s3_bucket_policy.aws_config_bucket_policy,
    aws_config_configuration_recorder.aws_config_recorder
  ]
}

resource "aws_config_configuration_recorder_status" "aws_config_recorder_status" {
  name       = aws_config_configuration_recorder.aws_config_recorder.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.aws_config_delivery_channel
  ]
}

resource "aws_config_config_rule" "s3_bucket_not_public" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

resource "aws_config_config_rule" "instances_in_vpc" {
  name = "instances-in-vpc"

  source {
    owner             = "AWS"
    source_identifier = "INSTANCES_IN_VPC"
  }
}

resource "aws_config_config_rule" "root_access_key_check" {
  name = "iam-root-access-key-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
}
