output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value       = module.eks.kubeconfig
}

output "apps" {
  description = "Bash script to run a basic pyspark job on your virtual EMR cluster"
  value = {
    pyspark_pi = join(" ", [
      "bash -e",
      format("%s/apps/pi/basic-pyspark-job.sh", path.module),
      format("-c %s", module.emr.cluster["id"]),
      format("-r %s", module.emr.role["job"].arn),
    ])
  }
}
