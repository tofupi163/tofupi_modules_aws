# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  dynamic "image_scanning_configuration" {
    for_each = length(var.image_scanning_configuration) > 0 ? [var.image_scanning_configuration] : []
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  dynamic "encryption_configuration" {
    for_each = length(var.encryption_configuration) > 0 ? [var.encryption_configuration] : []
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key  
    }
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy == null ? 0 : 1
  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy.policy_file != "" ? file(var.lifecycle_policy.policy_file) : var.lifecycle_policy.policy
}

resource "aws_ecr_repository_policy" "this" {
  count      = var.repository_policy == null ? 0 : 1
  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy.policy_file != "" ? file(var.repository_policy.policy_file) : var.repository_policy.policy
}
