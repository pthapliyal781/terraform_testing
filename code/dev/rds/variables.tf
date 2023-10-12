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
