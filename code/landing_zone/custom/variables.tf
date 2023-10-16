# Custom variables
variable "default_region" {
  description = "Default region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "super_cidr" {
  description = "CIDR value that contain all the CIDR's of the VPC's"
  type        = string
  default     = "10.0.0.0/8"
}