provider "aws" {
  region = var.default_region
}

module "backup" {
  source           = "../../../terraform_module/terraform-aws-backup"
  name             = var.name
  backup_resources = []

  rules = [
    {
      name              = "${var.name}-daily"
      schedule          = var.schedule
      start_window      = var.start_window
      completion_window = var.completion_window
      lifecycle = {
        cold_storage_after = var.cold_storage_after
        delete_after       = var.delete_after
      }
    }
  ]
}
