output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "kubecli" {
  description = "The kubectl command to attach annotations of IAM role for service account"
  value       = module.irsa.kubecli
}

resource "local_file" "kubejob" {
  content         = <<-EOT
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: aws-cli
  spec:
    template:
      metadata:
        labels:
          app: aws-cli
      spec:
        serviceAccountName: s3-readonly
        containers:
        - name: aws-cli
          image: amazon/aws-cli:latest
          args: ["s3", "ls"]
        restartPolicy: Never
  EOT
  filename        = "${path.cwd}/irsa.yaml"
  file_permission = "0600"
}
