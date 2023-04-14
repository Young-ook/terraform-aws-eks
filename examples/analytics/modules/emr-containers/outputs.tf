output "cluster" {
  description = "The attributes of generated EMR virtual cluster"
  value       = aws_emrcontainers_virtual_cluster.emr
}

output "role" {
  description = "The IAM roles for EMR job"
  value = {
    job = aws_iam_role.emrjob
  }
}
