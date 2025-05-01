resource "aws_cloudwatch_log_group" "guardduty_logs" {
  name              = "/aws/guardduty/findings"
  retention_in_days = 14
}


resource "aws_cloudwatch_event_target" "send_to_logs" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "CloudWatchLogStream"
  arn       = aws_cloudwatch_log_group.guardduty_logs.arn
}

resource "aws_cloudwatch_log_resource_policy" "guardduty_policy" {
  policy_name = "AllowGuardDutyToPutLogs"
  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action   = "logs:PutLogEvents",
      Resource = "${aws_cloudwatch_log_group.guardduty_logs.arn}:*"
    }]
  })
}


resource "aws_cloudwatch_log_metric_filter" "guardduty_high_severity" {
  name           = "guardduty-high-severity-filter"
  log_group_name = aws_cloudwatch_log_group.guardduty_logs.name

  pattern = "{ $.detail.severity >= 7.0 }"

  metric_transformation {
    name      = "HighSeverityGuardDutyFindings"
    namespace = "GuardDuty"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "guardduty_high_severity_alarm" {
  alarm_name          = "HighSeverityGuardDutyFindingAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.guardduty_high_severity.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.guardduty_high_severity.metric_transformation[0].namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when a high severity GuardDuty finding is detected"
  treat_missing_data  = "notBreaching"

  #i think we can set up an SNS notif from here too
}