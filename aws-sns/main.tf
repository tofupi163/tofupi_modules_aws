resource "aws_sns_topic" "this" {
  name              = var.name
  display_name = var.display_name
  kms_master_key_id = var.kms_master_key_id != "" ? var.kms_master_key_id : null

  policy = var.enable_minimal_policy ? data.aws_iam_policy_document.sns_minimal[0].json : var.policy

  firehose_success_feedback_sample_rate = var.firehose_success_feedback_sample_rate
  http_success_feedback_sample_rate = var.http_success_feedback_sample_rate
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_sample_rate
  lambda_success_feedback_sample_rate = var.lambda_success_feedback_sample_rate
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  signature_version = var.signature_version
  fifo_topic = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication

  delivery_policy = var.delivery_policy
  tracing_config = var.tracing_config
  tags = var.tags

  lifecycle {
    ignore_changes = [
      policy,
      delivery_policy,
      kms_master_key_id,
      tracing_config,
    ]
  }
}

resource "aws_sns_topic_subscription" "this" {
  for_each = {
    for idx, sub in var.subscriptions :
    idx => sub
  }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  raw_message_delivery = lookup(each.value, "raw_message_delivery", null)
  filter_policy        = lookup(each.value, "filter_policy", null)
}

data "aws_iam_policy_document" "sns_minimal" {
  count = var.enable_minimal_policy ? 1 : 0

  # 允许 AWS 服务发布消息
  statement {
    sid = "AllowAWSServicePublish"

    actions = [
      "SNS:Publish"
    ]

    principals {
      type        = "Service"
      identifiers = var.allowed_publish_services
    }

    resources = [
      aws_sns_topic.this.arn
    ]
  }

  # 允许订阅者（Lambda / SQS / IAM Role）订阅 Topic
  statement {
    sid = "AllowSubscriberAccess"

    actions = [
      "SNS:Subscribe",
      "SNS:Receive"
    ]

    principals {
      type        = "AWS"
      identifiers = var.allowed_subscriber_arns
    }

    resources = [
      aws_sns_topic.this.arn
    ]
  }
}
