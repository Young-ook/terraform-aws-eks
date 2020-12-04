output "name" {
  description = "A name of generated ECR repository"
  value       = aws_ecr_repository.repo.id
}

output "arn" {
  description = "An ARN of generated ECR repository"
  value       = aws_ecr_repository.repo.arn
}

output "url" {
  description = "A URL of generated ECR repository"
  value       = aws_ecr_repository.repo.repository_url
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this ECR repository. If you want to make an IAM role or instance-profile has permissions to manage this repository, please attach the `poliy_arn` of this output on your side."
  value       = zipmap(["read", "write"], [aws_iam_policy.read.arn, aws_iam_policy.write.arn])
}
