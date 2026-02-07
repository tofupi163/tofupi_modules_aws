# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment
resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.size
  type              = var.type
  encrypted         = var.encrypted
  kms_key_id        = var.kms_key_id

  iops = (
    contains(["io1", "io2"], var.type)
    ? var.iops
    : null
  )

  throughput = (
    var.type == "gp3"
    ? var.throughput
    : null
  )

  snapshot_id = var.snapshot_id
  
  multi_attach_enabled = var.multi_attach_enabled
  volume_initialization_rate = var.volume_initialization_rate

  tags = var.tags
}

resource "aws_volume_attachment" "this" {
  for_each = var.volume_attachments != null ? { for idx, val in var.volume_attachments : idx => val } : {}
  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.this.id
  instance_id = each.value.instance_id
  force_detach = each.value.force_detach
}

