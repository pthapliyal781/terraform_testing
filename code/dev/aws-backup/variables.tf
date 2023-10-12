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

variable "schedule" {
  type        = string
  description = "A CRON expression specifying when AWS Backup initiates a backup job"
}
variable "start_window" {
  type        = number
  description = "The amount of time in minutes before beginning a backup. Minimum value is 60 minutes"
}

variable "completion_window" {
  type        = number
  description = "The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window`"
}

variable "cold_storage_after" {
  type        = number
  description = "Specifies the number of days after creation that a recovery point is moved to cold storage"
}


variable "delete_after" {
  description = "Number of days after which a recovery point is deleted"
  type        = number
  default     = 30
}
