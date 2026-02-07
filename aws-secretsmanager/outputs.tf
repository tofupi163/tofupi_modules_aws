output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}

output "secret_id" {
  value = aws_secretsmanager_secret.this.id
}

output "kms_key_id" {
  value = local.final_kms_key_id
}

output "password" {
  value     = var.create_random_password ? random_password.this[0].result : null
  sensitive = true
}
