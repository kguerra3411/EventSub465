# S3 bucket for wiki uploads

resource "aws_s3_bucket" "wikiuploads" {
  bucket        = "${var.project_name}-bucket-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.environment
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.wikiuploads.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.wikiuploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a CORS configuration to allow MediaWiki to access the bucket
resource "aws_s3_bucket_cors_configuration" "wiki_cors" {
  bucket = aws_s3_bucket.wikiuploads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Create bucket policy to allow MediaWiki to access files
resource "aws_s3_bucket_policy" "allow_access_from_mediawiki" {
  bucket = aws_s3_bucket.wikiuploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_role.arn
        }
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource  = [
          aws_s3_bucket.wikiuploads.arn,
          "${aws_s3_bucket.wikiuploads.arn}/*"
        ]
      }
    ]
  })
}