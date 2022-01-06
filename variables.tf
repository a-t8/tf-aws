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