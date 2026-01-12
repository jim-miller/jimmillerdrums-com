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
      # Website S3 bucket content management
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
      # S3 bucket configuration management
      {
        Effect = "Allow"
        Action = [
          "s3:GetAccelerateConfiguration",
          "s3:GetBucket*",
          "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetPublicAccessBlock",
          "s3:GetVersioning",
          "s3:PutBucket*"
        ]
        Resource = aws_s3_bucket.website.arn
      },
      # CloudFront management
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution",
          "cloudfront:GetInvalidation",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:TagResource",
          "cloudfront:UpdateDistribution"
        ]
        Resource = "*"
      },
      # ACM certificate access
      {
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate"
        ]
        Resource = "*"
      },
      # Route53 access
      {
        Effect = "Allow"
        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      },
      # IAM read access for self-management
      {
        Effect = "Allow"
        Action = [
          "iam:GetPolicy",
          "iam:GetUser",
          "iam:GetUserPolicy",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies"
        ]
        Resource = [
          "arn:aws:iam::*:user/github-actions-*",
          "arn:aws:iam::*:policy/GitHubActionsDeploymentPolicy-*"
        ]
      },
      # State bucket access
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
      # DynamoDB state locking
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DeleteItem",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = data.aws_dynamodb_table.terraform_locks.arn
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
