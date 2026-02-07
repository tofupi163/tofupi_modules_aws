output "topic_arn" {
  value = aws_sns_topic.this.arn
}

output "topic_name" {
  value = aws_sns_topic.this.name
}

output "subscription_arns" {
  value = [
    for s in aws_sns_topic_subscription.this :
    s.arn
  ]
}

output "tracing_config" {
  value = var.tracing_config
}
