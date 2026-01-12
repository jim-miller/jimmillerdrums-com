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
      # S3 Website Bucket - Content Management
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
      # S3 Website Bucket - Configuration Management
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucket*",
          "s3:PutBucket*",
          "s3:GetAccelerateConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetVersioning",
          "s3:PutBucketVersioning",
          "s3:GetPublicAccessBlock",
          "s3:PutPublicAccessBlock",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetReplicationConfiguration",
          "s3:PutReplicationConfiguration",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:GetLifecycleConfiguration"
        ]
        Resource = aws_s3_bucket.website.arn
      },
      # S3 State Bucket - Backend Operations
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging"
        ]
        Resource = [
          data.aws_s3_bucket.terraform_state.arn,
          "${data.aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      # DynamoDB State Locking - Backend Operations
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:ListTagsOfResource",
          "dynamodb:TagResource",
          "dynamodb:UntagResource"
        ]
        Resource = data.aws_dynamodb_table.terraform_locks.arn
      },
      # CloudFront Management
      {
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:UpdateOriginAccessControl",
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
          "cloudfront:TagResource",
          "cloudfront:UntagResource",
          "cloudfront:ListTagsForResource"
        ]
        Resource = "*"
      },
      # ACM Certificate Management
      {
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:RequestCertificate",
          "acm:AddTagsToCertificate",
          "acm:ListTagsForCertificate"
        ]
        Resource = "*"
      },
      # Route53 DNS Management
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      },
      # IAM Self-Management
      {
        Effect = "Allow"
        Action = [
          "iam:GetUser",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetUserPolicy",
          "iam:ListAttachedUserPolicies",
          "iam:ListAccessKeys",
          "iam:ListPolicyVersions",
          "iam:GetAccessKeyLastUsed",
          "iam:CreateAccessKey",
          "iam:UpdateAccessKey",
          "iam:DeleteAccessKey",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]
        Resource = [
          "arn:aws:iam::*:user/github-actions-*",
          "arn:aws:iam::*:policy/GitHubActionsDeploymentPolicy-*"
        ]
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
