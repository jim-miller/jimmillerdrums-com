terraform {
  backend "s3" {
    bucket         = "jimmillerdrums-terraform-state"
    key            = "website/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "jimmillerdrums-terraform-locks"
    encrypt        = true
  }
}
