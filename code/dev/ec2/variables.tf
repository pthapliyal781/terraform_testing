# Custom variables
variable "default_region" {
  description = "Default region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Default tags to be added to all resources"
  type        = map(string)
  default     = {}
}

variable "ami" {
  description = "AMI to be used on EC2 instance"
  type        = string
  default     = "ami-0fc970315c2d38f01"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}
