module "network" {
  source           = "./network"
  vpc_cidr         = local.vpc_cidr
  public_sn_count  = 2
  private_sn_count = 2
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, local.newbits, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, local.newbits, i)]
  max_subnets      = 20
  access_ip        = var.access_ip
  security_groups  = local.security_groups
}

module "loadbalancer" {
  source                 = "./loadbalancer"
  public_sg              = module.network.public_sg
  public_subnets         = module.network.public_subnets
  tg_port                = 80
  tg_protocol            = "HTTP"
  vpc_id                 = module.network.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 80
  listener_protocol      = "HTTP"
  key_name               = "key1"
  public_key_path        = "/Users/shobhittiwari/Keys/key1.pub"
  user_data_path         = "${path.root}/userdata.tpl"
  tg_arn                 = module.loadbalancer.tg_arn
  instance_count         = 1
  instance_type          = "t3.micro"
  vol_size               = 10
}
