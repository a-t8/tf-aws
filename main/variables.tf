variable "aws_region" {
  description = "The AWS Region of Deployment"
  type        = string
  default     = "us-west-2"
}

variable "env_code" {
  description = "Value of the enviroment like dev or prod"
  type        = string
  default     = "dev"
}

variable "access_ip" {
  type = string
}
