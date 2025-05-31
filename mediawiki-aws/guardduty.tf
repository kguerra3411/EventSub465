resource "aws_guardduty_detector" "main" {
  enable = var.enable_guardduty
}
