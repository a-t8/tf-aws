

module "network" {
  source           = "./network"
  vpc_cidr         = local.vpc_cidr
  public_sn_count  = 2
  private_sn_count = 2
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, local.newbits, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, local.newbits, i)]
  max_subnets      = 20
  access_ip        = var.access_ip
  security_groups = local.security_groups

}

module "backend" {
  source = "./backend_storage"
}