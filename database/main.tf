data "aws_secretsmanager_secret_version" "dev-secret" {
  secret_id = "my-db-secret"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.dev-secret.secret_string
  )
}

resource "aws_db_instance" "dev_db" {

  allocated_storage         = 10
  apply_immediately         = true
  engine                    = "mysql"
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_class
  name                      = var.dbname
  username                  = local.db_creds.username
  password                  = local.db_creds.password
  db_subnet_group_name      = var.db_subnet_group_name
  vpc_security_group_ids    = var.vpc_security_group_ids
  identifier                = var.db_identifier
  skip_final_snapshot       = var.skip_final_snapshot
  backup_window             = var.backup_window
  backup_retention_period   = var.backup_retention_period
  multi_az                  = var.multi_az
  final_snapshot_identifier = var.final_snapshot_identifier_suffix

  tags = {
    name = var.dbname
  }

}
