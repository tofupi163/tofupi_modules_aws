// prevent destroy default true
variable "prevent_destroy" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = null
}

variable "asset_id" {
  type = string
  description = "当前资源所属资产ID"
}
variable "asset_name" {
  type        = string
  description = "Asset Name"
}

variable "asset_group" {
  type = string
  description = "当前资源所属资产分组"
}

variable "_tofupi" {
  description = "Tofupi 内部变量"
  type = map(object({}))
  default = {
    aws_eip = {
      nameKey = "tags.Name",
      # from tags
      projectID = "AssetID",
      exclude = [
        "arn",
        "association_id",
        "allocation_id",
        "domain",
        "id",
        "instance_owner_id",
        "network_interface_owner_id",
        "private_ip",
        "public_ip",
        "public_ipv4_pool",
        "private_dns",
        "public_dns",
        "network_border_group",
        "region",
      ]
    }
  }
}

variable "domain" {
  type        = string
  default     = "vpc"
  description = "Indicates if this EIP is for use in VPC or EC2-Classic"

  validation {
    condition     = contains(["vpc", "standard"], var.domain)
    error_message = "domain 必须是 \"vpc\" 或 \"standard\"."
  }
}

variable "instance" {
  type        = string
  default     = null
  description = "EC2 instance ID to associate with the EIP"
}

variable "network_interface" {
  type        = string
  default     = null
  description = "Network interface ID to associate with the EIP"
}

variable "associate_with_private_ip" {
  type        = string
  default     = null
  description = "Private IP to associate with the EIP"
}

variable "public_ipv4_pool" {
  type        = string
  default     = "amzone"
  description = "EC2 IPv4 address pool"
}
