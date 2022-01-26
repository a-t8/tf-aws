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
}

module "loadbalancer" {
  source         = "../loadbalancer"
  public_sg      = module.network.public_sg
  public_subnets = module.network.public_subnets
  vpc_id         = module.network.vpc_id
  port           = 80
  protocol       = "HTTP"
}
