# Provides for state storage and state locking using AWS infrastructure.
# Disabled for this demo so as to be more plug and play
# terraform {
#   backend "s3" {
#     bucket         = "<insert bucket>"
#     key            = "terraform.tfstate"
#     region         = "<insert region"
#     profile        = "<insert profile"
#     dynamodb_table = "terraform-lock"
#     role_arn       = "<insert role>"
#   }
# }

provider "aws" {
  region = var.aws_region
}
