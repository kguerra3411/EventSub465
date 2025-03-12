resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_s3_bucket" "wikiuploads" {
    bucket = "${var.project_name}-bucket"

}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.wikiuploads.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
    bucket = aws_s3_bucket.wikiuploads.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_db_instance" "wiki_db" {
  allocated_storage = 10
  engine = "mysql"
  instance_class = "db.t3.micro"
  identifier = "wiki"
  db_name = "${db_name}"
  username = "${db_username}"
  password = "${db_password}"
  port = "3306" #can be whatever
  #once we have security groups and subnets set up in the vpc we'd add them here i think
  #vpc_security_group_ids = [aws_security_group.rds_sg.id]
  #db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name

  skip_final_snapshot = true
}