variable "aws_region" {
  description = "The AWS Region of Deployment"
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "Value of the AWS CLI Profile"
  type        = string
  default     = "iamadmin-general"
}

variable "vpc_network_cidr" {
  description = "Value of the network_cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "newbits" {
  description = "Value of the newbits for halving the network"
  type        = string
  default     = "8"
}

variable "env_code" {
  description = "Value of the enviroment like dev or prod"
  type        = string
  default     = "dev"
}
