
data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.eks_vpc.id
}

# data "aws_security_group" "default" {
#   vpc_id = data.aws_vpc.eks_vpc.id
#   name   = "default"
# }

#####
# DB
#####
output "this_db_instance_endpoint" {
  value = module.db.this_db_instance_endpoint
}

resource "aws_security_group" "rds" {
  count  = var.create_rds ? 1 : 0
  name   = var.env_name
  vpc_id = data.aws_vpc.eks_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = var.env_name

  engine            = "postgres"
  engine_version    = "9.6.18"
  instance_class    = "db.t3.small"
  allocated_storage = 40
  storage_encrypted = false
  # 
  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = var.env_name

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = var.postgres_username

  password = var.postgres_password
  port     = "5432"

  vpc_security_group_ids = aws_security_group.rds[*].id

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "iterrate"
    Environment = "production"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = false
}

