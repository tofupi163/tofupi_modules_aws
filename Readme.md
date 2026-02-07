## tofupi_modules_aws
terraform module for aws, 该模块为tofupi项目 的配套terraform模块，克隆后复制到 tofupi项目的terraform/modules 目录下即可使用，模块列表如下：

### 模块列表
#### aws-dynamodb
* 功能说明
✔ 支持 PAY_PER_REQUEST / PROVISIONED 计费模式与严格变量校验
✔ 动态 attributes / GSI / LSI / TTL / Stream 等完整表能力
✔ 支持 Point-In-Time Recovery、自定义恢复天数
✔ 支持 KMS Server-Side Encryption 与显式 KMS Key 绑定
✔ 可选启用 Streams 并指定 `stream_view_type`
✔ 所有配置均通过 map/list 传入，方便模块化复用

* 模块样例
```hcl
module "dynamodb_orders" {
  source = "../modules/aws/aws-dynamodb"

  name         = "orders"
  billing_mode = "PROVISIONED"
  hash_key     = "order_id"
  range_key    = "created_at"

  attributes = [
    { name = "order_id", type = "S" },
    { name = "created_at", type = "S" },
    { name = "customer_id", type = "S" }
  ]

  global_secondary_index = [{
    name            = "customer_id_index"
    hash_key        = "customer_id"
    range_key       = "created_at"
    projection_type = "ALL"
    read_capacity   = 10
    write_capacity  = 5
  }]

  ttl = {
    attribute_name = "expire_at"
    enabled        = true
  }

  point_in_time_recovery = {
    enabled                  = true
    recovery_period_in_days  = 7
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption = {
    enabled     = true
    kms_key_arn = aws_kms_key.ddb.arn
  }

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-ebs
* 功能说明
✔ 自动根据卷类型控制 IOPS / 吞吐量字段，避免不合法配置
✔ 支持多附加（multi-attach）、快照恢复、KMS 加密
✔ `volume_attachments` 支持一次性挂载到多台实例
✔ 可定义 `prevent_destroy`，保护关键数据卷
✔ 所有标签透传，便于计费/审计

* 模块样例
```hcl
module "ebs_logs" {
  source = "../modules/aws/aws-ebs"

  name              = "logs-data"
  availability_zone = "ap-southeast-1a"
  size              = 200
  type              = "gp3"
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs.arn
  throughput        = 250

  volume_attachments = [
    {
      device_name = "/dev/sdf"
      instance_id = aws_instance.app_a.id
      force_detach = false
    },
    {
      device_name = "/dev/sdf"
      instance_id = aws_instance.app_b.id
      force_detach = true
    }
  ]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-ec2_instance
* 功能说明
✔ 覆盖所有常用 EC2 属性（CPU / Metadata / Launch Template / Enclave 等）
✔ Root Block 与多块 EBS Block Device 通过 list/map 动态注入
✔ 支持 Spot / RI / Capacity Reservation 组合配置
✔ 自动合并标签并遵循 `Name` 逻辑命名
✔ 可插拔 IAM Instance Profile、S.G.、UserData（Base64）

* 模块样例
```hcl
module "ec2_bastion" {
  source = "../modules/aws/aws-ec2_instance"

  name           = "bastion"
  ami            = data.aws_ami.al2.id
  instance_type  = "t3.medium"
  subnet_id      = aws_subnet.public_a.id
  key_name       = "jump-key"
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  root_block_device = {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  ebs_block_devices = [
    {
      device_name = "/dev/xvdb"
      volume_size = 40
      volume_type = "gp3"
      delete_on_termination = true
    }
  ]

  metadata_options = {
    http_tokens = "required"
  }

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-ecr
* 功能说明
✔ 自动创建 ECR 仓库，支持不可变 / 可变镜像标签
✔ 支持 push 时病毒扫描与 KMS 加密
✔ Lifecycle Policy / Repository Policy 支持文件或内联 JSON
✔ 通过 `prevent_destroy` 保护仓库，避免误删
✔ Tags 统一透传，方便 CMDB 对齐

* 模块样例
```hcl
module "ecr_comments" {
  source = "../modules/aws/aws-ecr"

  name                 = "comments-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration = {
    scan_on_push = true
  }

  encryption_configuration = {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  lifecycle_policy = {
    policy = jsonencode({
      rules = [{
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection    = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = { type = "expire" }
      }]
    })
  }

  repository_policy = {
    policy = data.aws_iam_policy_document.ecr.json
  }

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-eip
* 功能说明
✔ 同步管理 EIP 分配、实例/ENI 关联、私网 IP 绑定
✔ 支持 BYOIP `public_ipv4_pool` 指定
✔ 可通过 `prevent_destroy` 保障长久 IP 不被销毁
✔ 自动携带资产信息（AssetID/Name/Group）入标签

* 模块样例
```hcl
module "nat_eip" {
  source = "../modules/aws/aws-eip"

  asset_id    = "asset-001"
  asset_name  = "core-network"
  asset_group = "prod"

  domain     = "vpc"
  instance   = null
  network_interface = aws_network_interface.nat.id
  associate_with_private_ip = "10.0.1.5"

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-elasticache
* 功能说明
✔ 支持单节点 Cluster 与 Redis Replication Group 双模式
✔ 自动创建 Subnet Group / Parameter Group 并注入标签
✔ 支持多 AZ / 自动故障转移 / Data Tiering / Transit Encryption
✔ 可配置 Snapshot、Maintenance Window、User Group IDs
✔ 所有网络、加密、引擎参数均模块化传入

* 模块样例
```hcl
module "redis_cache" {
  source = "../modules/aws/aws-elasticache"

  asset_id    = "asset-002"
  asset_name  = "content"
  asset_group = "prod"

  name         = "redis-cache"
  cluster_id   = "redis-cache"
  mode         = "replication_group"
  engine       = "redis"
  engine_version = "7.0"
  node_type    = "cache.t3.medium"
  replicas     = 2
  az_mode      = "cross-az"
  security_group_ids = [aws_security_group.cache.id]

  subnet_group_name = {
    subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  }

  parameter_group_name = {
    name       = "redis7-custom"
    family     = "redis7"
    parameters = {
      "maxmemory-policy" = { value = "allkeys-lru" }
    }
  }

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-igw
* 功能说明
✔ 一键创建 Internet Gateway 并自动带上资产标签
✔ 与指定 VPC 绑定，支持自定义名称
✔ 适合在 VPC 基础设施模块中复用

* 模块样例
```hcl
module "vpc_igw" {
  source = "../modules/aws/aws-igw"

  asset_id    = "asset-003"
  asset_name  = "edge"
  asset_group = "prod"

  name   = "core-igw"
  vpc_id = aws_vpc.main.id

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-nacl
* 功能说明
✔ 使用 list 结构定义 ingress / egress 规则，顺序与优先级可控
✔ 支持一次性关联多个子网
✔ 规则字段与 AWS 控制台一致，减少心智负担
✔ 自动合并标签并同步 `Name`

* 模块样例
```hcl
module "private_nacl" {
  source = "../modules/aws/aws-nacl"

  name   = "private"
  vpc_id = aws_vpc.main.id

  nacl_ingress = [
    {
      rule_no    = 100
      protocol   = "tcp"
      action     = "allow"
      cidr_block = "10.0.0.0/16"
      from_port  = 0
      to_port    = 65535
    }
  ]

  nacl_egress = [
    {
      rule_no    = 100
      protocol   = "tcp"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 65535
    }
  ]

  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-route_table
* 功能说明
✔ 支持批量定义 Route（NAT/IGW/TGW/Peering 等目标）
✔ 支持 `propagating_vgws`、主路由表绑定以及多子网/网关关联
✔ 使用 for_each 动态生成 association 资源，便于迭代环境扩展

* 模块样例
```hcl
module "private_rt" {
  source = "../modules/aws/aws-route_table"

  name   = "private"
  vpc_id = aws_vpc.main.id

  routes = [
    {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main.id
    }
  ]

  table_association = [
    { subnet_id = aws_subnet.private_a.id },
    { subnet_id = aws_subnet.private_b.id }
  ]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-s3
* 功能说明
✔ Bucket 名称可自动由 Asset 信息拼接或手动指定
✔ 默认开启 `prevent_destroy`，保护生产数据
✔ 支持 Versioning、CORS、Lifecycle、Access Point、Bucket Policy、SSE
✔ Policy / 值文件支持 `data/` 目录引用，便于分环境管理

* 模块样例
```hcl
module "artifact_bucket" {
  source = "../modules/aws/aws-s3"

  asset_id    = "asset-004"
  asset_name  = "artifact"
  asset_group = "prod"
  short_name  = "artifacts"

  name = null # 使用自动命名

  bucket_policy = {
    policy = data.aws_iam_policy_document.artifacts.json
  }

  cors_rule = [{
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["https://app.example.com"]
    allowed_headers = ["*"]
  }]

  lifecycle_rule = [{
    id     = "cleanup"
    status = "Enabled"
    prefix = "tmp/"
    transitions = [{
      days          = 30
      storage_class = "GLACIER"
    }]
  }]

  server_side_encryption_configuration = [{
    rule = [{
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = [{
        kms_master_key_id = aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }]
    }]
  }]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-secretsmanager
* 功能说明
✔ 自动创建 SecretsManager Secret + Version，支持 JSON payload
✔ 可选自动生成随机密码与 KMS Key / Alias
✔ `secret_data` merge 机制，便于拓展字段
✔ 忽略 rotation/kms drift，Terraform Apply 更平滑

* 模块样例
```hcl
module "db_secret" {
  source = "../modules/aws/aws-secretsmanager"

  asset_id    = "asset-005"
  asset_name  = "db"
  asset_group = "prod"

  name        = "prod/rds/credentials"
  description = "Aurora credentials"

  create_random_password = true
  random_password_length = 24

  create_kms_key = true

  secret_data = {
    username = "app_user"
  }

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-sg
* 功能说明
✔ 通过 `ingress`/`egress` block 快速声明常规规则
✔ `sg_rules` 资源支持引用 SG/Prefix 等更复杂场景
✔ 自动补齐 Name 标签，与 VPC 资源配套
✔ 便于与模块化 VPC / EKS / ECS 代码复用

* 模块样例
```hcl
module "alb_sg" {
  source = "../modules/aws/aws-sg"

  asset_id    = "asset-006"
  asset_name  = "alb"
  asset_group = "prod"

  name  = "alb"
  vpc_id = aws_vpc.main.id

  ingress = [{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }]

  egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  sg_rules = [{
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "internal http"
  }]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-sns
* 功能说明
✔ 完整独立 SNS Topic 模块并提供严格变量校验
✔ 自动生成最小权限 Topic Policy，支持服务/ARN 精细控制
✔ 支持 email / lambda / sqs / http(s) / sms 等订阅协议
✔ 支持 filter policy、raw message delivery、外部 KMS Key
✔ 支持 AWS 服务发布消息与 X-Ray 分布式追踪
✔ 完整 lifecycle，模块可多环境复用

* 模块样例
```hcl
module "sns_alerts" {
  source = "../modules/aws/aws-sns"

  asset_id    = "asset-007"
  asset_name  = "alerts"
  asset_group = "prod"
  short_name  = "alerts"

  name       = "alerts-topic"
  kms_key_id = module.kms_sns.key_arn

  enable_minimal_policy = true

  allowed_publish_services = [
    "events.amazonaws.com",
    "cloudwatch.amazonaws.com"
  ]

  allowed_subscriber_arns = [
    aws_lambda_function.alert_handler.arn,
    aws_sqs_queue.alert_queue.arn
  ]

  subscriptions = [{
    protocol = "lambda"
    endpoint = aws_lambda_function.alert_handler.arn
  }]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-sqs
* 功能说明
✔ 自动生成最小权限 Policy，覆盖账号主体与服务主体
✔ 支持 FIFO / 标准队列、DLQ、加密、等待时间、Visibility 等全部参数
✔ KMS 加密支持数据密钥重用周期与 SSE-SQS 切换
✔ 支持自定义 Policy、Lambda/SNS/IAM 发布者
✔ 内置 `prevent_destroy`，保护生产队列

* 模块样例
```hcl
module "dlq" {
  source = "../modules/aws/aws-sqs"

  asset_id    = "asset-007"
  asset_name  = "alerts"
  asset_group = "prod"
  short_name  = "alerts-dlq"

  name                       = "alerts-dlq"
  message_retention_seconds  = 1209600
  sqs_managed_sse_enabled    = true
}

module "main_queue" {
  source = "../modules/aws/aws-sqs"

  asset_id    = "asset-007"
  asset_name  = "alerts"
  asset_group = "prod"
  short_name  = "alerts-main"

  name = "alerts"

  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 10

  kms_master_key_id                 = module.kms_sqs.key_arn
  kms_data_key_reuse_period_seconds = 300
  sqs_managed_sse_enabled           = false

  redrive_policy = {
    dead_letter_target_arn = module.dlq.queue_arn
    max_receive_count      = 5
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Principal = "*"
      Action   = "sqs:SendMessage"
      Resource = "*"
    }]
  })
}

output "main_queue_url" {
  value = module.main_queue.queue_url
}

output "main_queue_arn" {
  value = module.main_queue.queue_arn
}
```

#### aws-ssm
* 功能说明
✔ 自动基于 Asset 信息拼装 Parameter Store 层级路径
✔ 默认 prevent_destroy，防止核心配置误删
✔ 支持从 `data/` 下文件读取值，或直接传入 value
✔ 支持 SecureString / Advanced Tier / DataType / KMS Key

* 模块样例
```hcl
module "ssm_db_password" {
  source = "../modules/aws/aws-ssm"

  asset_id    = "asset-008"
  asset_name  = "db"
  asset_group = "prod"
  short_name  = "credentials"

  type  = "SecureString"
  tier  = "Intelligent-Tiering"
  key_id = aws_kms_key.parameters.arn

  value = jsonencode({
    username = "app"
    password = random_password.db.result
  })
}
```

#### aws-subnet
* 功能说明
✔ 支持 IPv4/IPv6、LNI、DNS64、COIP、Auto-IP 等高级开关
✔ 自动带上 Name 标签并与 Asset 元信息关联
✔ 通过布尔变量控制 public/private 行为

* 模块样例
```hcl
module "private_a" {
  source = "../modules/aws/aws-subnet"

  asset_id    = "asset-009"
  asset_name  = "app"
  asset_group = "prod"

  name       = "app-private-a"
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"

  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = true

  tags = {
    Tier = "private"
  }
}
```

#### aws-vpc
* 功能说明
✔ 统一创建 VPC 并可选启用 IPv6、NAS metering、安全 DNS 等能力
✔ 可一并创建 DHCP Options 并完成关联
✔ 自动注入资产标签，便于 CMDB 关联

* 模块样例
```hcl
module "main_vpc" {
  source = "../modules/aws/aws-vpc"

  asset_id    = "asset-010"
  asset_name  = "core"
  asset_group = "prod"

  name                = "core-vpc"
  cidr_block          = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = true

  dhcp_options = {
    domain_name         = "corp.local"
    domain_name_servers = ["AmazonProvidedDNS"]
  }
}
```

#### aws-vpc_endpoint
* 功能说明
✔ 同时支持 Interface / Gateway Endpoint，并自动识别服务类型
✔ 提供最小权限 Policy 模板，可针对 IAM / Service Principal 精细授权
✔ Interface 模式可自动创建最小权限专用 Security Group
✔ 支持自定义 Subnet 配置、DNS 选项、私网 DNS、IP 地址类型

* 模块样例
```hcl
module "ssm_endpoint" {
  source = "../modules/aws/aws-vpc_endpoint"

  asset_id    = "asset-010"
  asset_name  = "core"
  asset_group = "prod"

  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.ssm"

  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  enable_minimal_policy = true
  private_dns_enabled   = true

  allowed_service_principals = ["ec2.amazonaws.com"]

  tags = {
    Project = "demo"
    Env     = "prod"
  }
}
```

#### aws-vpc_peering
* 功能说明
✔ 管理跨账号/跨 Region VPC Peering，并支持自动接受
✔ `requester/accepter` 块可开启对端 DNS 解析
✔ 可一次性下发双方 Route，避免额外手工配置
✔ 自带资产标签，便于审计

* 模块样例
```hcl
module "vpc_peering_prod_to_shared" {
  source = "../modules/aws/aws-vpc_peering"

  asset_id    = "asset-011"
  asset_name  = "core"
  asset_group = "prod"

  name         = "prod-shared"
  vpc_id       = aws_vpc.prod.id
  peer_vpc_id  = aws_vpc.shared.id
  peer_owner_id = data.aws_caller_identity.shared.account_id
  peer_region  = "ap-southeast-1"
  auto_accept  = true

  requester = {
    allow_remote_vpc_dns_resolution = true
  }

  accepter = {
    allow_remote_vpc_dns_resolution = true
  }

  requester_route_table_ids = [aws_route_table.private_a.id]
  accepter_route_table_ids  = [aws_route_table.shared_private.id]
  requester_cidr_block      = aws_vpc.prod.cidr_block
  peer_cidr_block           = aws_vpc.shared.cidr_block
}
```
