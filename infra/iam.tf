# IAM user for GitHub Actions deployment
resource "aws_iam_user" "github_actions" {
  name = "github-actions-${var.domain_name}-${var.environment}"
  path = "/"

  tags = {
    Environment = var.environment
    Project     = var.domain_name
  }
}

# IAM policy for deployment permissions
resource "aws_iam_policy" "github_actions_deployment" {
  name        = "GitHubActionsDeploymentPolicy-${var.environment}"
  description = "Policy for GitHub Actions to deploy website and manage infra"

  tags = {
    Environment = var.environment
    Project     = var.domain_name
  }

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
      # 3. Access the State Bucket (External resource from bootstrap)
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          data.aws_s3_bucket.terraform_state.arn,
          "${data.aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      # 4. DynamoDB State Locking (External resource from bootstrap)
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = data.aws_dynamodb_table.terraform_locks.arn
      },
      # 5. Invalidation permissions
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
