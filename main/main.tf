module "network" {
  source = "../network"

  vpc_cidr         = local.vpc_cidr
  public_sn_count  = 2
  private_sn_count = 2
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, local.newbits, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, local.newbits, i)]
  max_subnets      = 20
  access_ip        = local.access_ip
  security_groups  = local.security_groups
  env_code         = "env_a"
  db_subnet_group  = "true"
}

module "compute" {
  source              = "../compute"
  public_sg           = module.network.public_sg
  public_subnets      = module.network.public_subnets
  private_subnets     = module.network.private_subnets
  private_sg          = module.network.private_sg
  instance_type       = "t3.micro"
  instance_count      = 1
  vol_size            = "10"
  user_data_path      = "${path.root}/userdata.tpl"
  key_name            = "atulkey"
  lb_target_group_arn = module.loadbalancer.lb_target_group_arn
  lb_id               = module.loadbalancer.lb_id
}

module "loadbalancer" {
  source         = "../loadbalancer"
  public_sg      = module.network.public_sg
  public_subnets = module.network.public_subnets
  vpc_id         = module.network.vpc_id
  port           = 80
  protocol       = "HTTP"
}

module "database" {
  source                           = "../database"
  db_engine_version                = "5.7.22"
  db_instance_class                = "db.t2.micro"
  dbname                           = "devdb"
  db_identifier                    = "atul-dev-db"
  skip_final_snapshot              = false
  backup_window                    = "00:00-02:00"
  backup_retention_period          = 7
  db_subnet_group_name             = module.network.db_subnet_group_name[0]
  vpc_security_group_ids           = module.network.db_security_group
  multi_az                         = true
  final_snapshot_identifier_suffix = "dev-final-snapshot"
}
