terraform {
  backend "s3" {
    bucket         = "terraform-stage-4-status-bucket"
    key            = "terraform-stage-4/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform_lock"
  }
}