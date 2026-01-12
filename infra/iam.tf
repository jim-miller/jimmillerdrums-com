# IAM user for GitHub Actions deployment
resource "aws_iam_user" "github_actions" {
  name = "github-actions-${var.domain_name}"
  path = "/"
}

# IAM policy for deployment permissions
resource "aws_iam_policy" "github_actions_deployment" {
  name        = "GitHubActionsDeploymentPolicy"
  description = "Policy for GitHub Actions to deploy website and manage infra"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Manage the Website Bucket content (Syncing files)
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.website.arn,
          "${aws_s3_bucket.website.arn}/*"
        ]
      },
      # 2. Manage the Infrastructure settings (tofu apply)
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucket*",
          "s3:PutBucket*",
          "cloudfront:GetDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:TagResource"
        ]
        Resource = "*" # Actions like 'ListDistributions' require "*"
      },
      # 3. Access the State Bucket (Hardcoded because it's external to this config)
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::jimmillerdrums-terraform-state",
          "arn:aws:s3:::jimmillerdrums-terraform-state/*"
        ]
      },
      # 4. Invalidation permissions
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "github_actions" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_deployment.arn
}

# Access key for GitHub Actions
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}
