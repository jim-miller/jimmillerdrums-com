output "s3_bucket_name" {
  value = aws_s3_bucket.website.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website.id
}

output "website_url" {
  value = "https://${var.domain_name}"
}

# GitHub Actions credentials (sensitive)
output "github_actions_access_key_id" {
  value     = aws_iam_access_key.github_actions.id
  sensitive = true
}

output "github_actions_secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}
