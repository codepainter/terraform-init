# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "Terraform"   = "true"
      "Project"     = var.project_code
      "Environment" = var.environment
    }
  }
}