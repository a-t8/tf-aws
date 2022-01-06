# ----root/main.tf---

module "network" {
  source       = "./network"
  vpc_cidr     = "10.0.0.0/16"
  public_sn_count = 2
  private_sn_count = 2
  public_cidrs = [for i in range (2, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
  private_cidrs = [for i in range (1, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
  max_subnets = 20
}