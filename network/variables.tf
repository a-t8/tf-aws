variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(any)
}

variable "private_cidrs" {
  type = list(any)
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}
variable "max_subnets" {
  type = number
}

variable "env_code" {
  description = "Value of the enviroment like dev or prod"
  type        = string
  default     = "dev"
}

variable "access_ip" {
  type = string
}

variable "security_groups" {}

