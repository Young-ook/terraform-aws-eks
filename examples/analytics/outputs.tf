output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value       = module.eks.kubeconfig
}

output "run_emr_job" {
  description = "Bash script to run a basic pyspark job on your virtual EMR cluster"
  value = join(" ", [
    "bash -e",
    format("%s/apps/pi/basic-pyspark-job.sh", path.module),
    format("-c %s", module.emr.cluster["id"]),
    format("-r %s", aws_iam_role.emr-job-execution.arn),
  ])
}
