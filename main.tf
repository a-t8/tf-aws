# ----root/main.tf---

module "network" {
  source           = "./network"
  vpc_cidr         = var.vpc_network_cidr
  public_sn_count  = 2
  private_sn_count = 2
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_network_cidr, var.newbits, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_network_cidr, var.newbits, i)]
  max_subnets      = 20
  
}
