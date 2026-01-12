variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "jimmillerdrums.com"
}

variable "bucket_name" {
  description = "S3 bucket name for static website hosting"
  type        = string
  default     = "jimmillerdrums-com"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
