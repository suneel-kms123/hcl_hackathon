resource "aws_cloudwatch_log_group" "hcl_log_group" {
  name              = "/ecs/hcl-app"
  retention_in_days = 30

  tags = {
    Name = "cb-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "hcl_log_stream" {
  name           = "hcl-log-stream"
  log_group_name = aws_cloudwatch_log_group.hcl_log_group.name
}