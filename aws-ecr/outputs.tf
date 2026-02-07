output "repository_policy" {
  value = try(aws_ecr_repository_policy.this[0].policy, null)
}
