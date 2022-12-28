## managed container image registry service

# security/policy
resource "aws_iam_policy" "read" {
  name        = format("%s-ecr-read", local.name)
  description = format("Allow to read images from the ECR")
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:ListImages",
      ]
      Effect   = "Allow"
      Resource = [aws_ecr_repository.repo.arn]
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "write" {
  name        = format("%s-ecr-write", local.name)
  description = format("Allow to push and write images to the ECR")
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action = [
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:CompleteLayerUpload",
      ]
      Effect   = "Allow"
      Resource = [aws_ecr_repository.repo.arn]
    }]
    Version = "2012-10-17"
  })
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository_policy" "repo" {
  repository = aws_ecr_repository.repo.name
  policy = jsonencode({
    Statement = [{
      Sid = "AllowCrossAccountAccess"
      Action = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages",
      ]
      Effect = "Allow"
      Principal = {
        AWS = flatten([
          data.aws_caller_identity.current.account_id,
          var.trusted_accounts,
        ])
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_ecr_lifecycle_policy" "repo" {
  count      = var.lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.repo.name
  policy     = var.lifecycle_policy == null ? jsonencode(local.default_lifecycle_policy) : var.lifecycle_policy
}

resource "aws_ecr_repository" "repo" {
  name = local.repo
  tags = merge(var.tags, local.default-tags)

  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
