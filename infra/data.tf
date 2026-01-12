# Data sources for external bootstrap resources
data "aws_s3_bucket" "terraform_state" {
  bucket = "jimmillerdrums-terraform-state"
}

data "aws_dynamodb_table" "terraform_locks" {
  name = "jimmillerdrums-terraform-locks"
}
