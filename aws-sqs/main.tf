data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "this" {
  name                        = var.name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  kms_master_key_id                    = var.kms_master_key_id
  kms_data_key_reuse_period_seconds    = var.kms_data_key_reuse_period_seconds
  sqs_managed_sse_enabled              = var.sqs_managed_sse_enabled

  policy = var.enable_minimal_policy ? data.aws_iam_policy_document.sqs_minimal[0].json : var.policy


  redrive_policy = var.redrive_policy == null ? null : jsonencode({
    deadLetterTargetArn = var.redrive_policy.dead_letter_target_arn
    maxReceiveCount     = var.redrive_policy.max_receive_count
  })

  tags = var.tags

  lifecycle {
    ignore_changes = [
      kms_master_key_id,
      kms_data_key_reuse_period_seconds,
      sqs_managed_sse_enabled,
      redrive_policy,
      policy,
    ]
  }
}

data "aws_iam_policy_document" "sqs_minimal" {
  count = var.enable_minimal_policy ? 1 : 0

  ############################################
  # 1. 允许当前 AWS 账号的 IAM 主体执行所有 SQS 操作
  ############################################
  statement {
    sid = "AllowAccountFullAccess"

    actions = [
      "sqs:*"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    resources = [
      aws_sqs_queue.this.arn
    ]
  }

  ############################################
  # 2. 允许 AWS 服务发布消息（如 EventBridge）
  ############################################
  statement {
    sid = "AllowAWSServicePublish"

    actions = [
      "sqs:SendMessage"
    ]

    principals {
      type        = "Service"
      identifiers = var.allowed_publish_services
    }

    resources = [
      aws_sqs_queue.this.arn
    ]
  }

  ############################################
  # 3. 允许指定 ARN 发布消息（Lambda / SNS / IAM Role）
  ############################################
  statement {
    sid = "AllowSpecificArnPublish"

    actions = [
      "sqs:SendMessage"
    ]

    principals {
      type        = "AWS"
      identifiers = var.allowed_publish_arns
    }

    resources = [
      aws_sqs_queue.this.arn
    ]
  }
}
