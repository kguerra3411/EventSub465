variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mediawiki"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mediawiki"
}

variable "mediawiki_image" {
  description = "Docker Hub image for MediaWiki"
  type        = string
  default     = "thejolman/mediawiki-custom:latest"
}

variable "transfer_user_name" {
  description = "Username for AWS Transfer Family user"
  type        = string
}

variable "transfer_ssh_public_key" {
  description = "SSH public key for AWS Transfer Family user"
  type        = string
}

variable "transfer_allowed_cidrs" {
  description = "Allowed CIDR blocks for SFTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "config_file" {
  description = "Name of MediaWiki configuration file"
  type = string
  default = "LocalSettings.php"
}

variable "logo_file" {
  description = "Name of 135x135 MediaWiki logo file"
  type = string
  default = "wiki.png"
}
