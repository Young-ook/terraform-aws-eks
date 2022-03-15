output "name" {
  description = "The name of generated IAM role"
  value       = aws_iam_role.irsa.name
}

output "arn" {
  description = "The ARN of generated IAM role"
  value       = aws_iam_role.irsa.arn
}

output "kubecli" {
  description = "The kubernetes configuration file for creating IAM role with service account"
  value = join(" ", [
    format("kubectl -n %s create sa %s", var.namespace, var.serviceaccount),
    "&&",
    format("kubectl -n %s annotate sa %s %s",
      var.namespace,
      var.serviceaccount,
      join("=", ["eks.amazonaws.com/role-arn", aws_iam_role.irsa.arn])
    ),
  ])
}
