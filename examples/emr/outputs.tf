output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value       = module.eks.kubeconfig
}

# Need to update aws-auth configmap with,
#
#    - rolearn: arn:aws:iam::{AWS_ACCOUNT_ID}:role/AWSServiceRoleForAmazonEMRContainers
#      username: emr-containers
#
# and also, create role and role mapping on the target namespace
# for more details, https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-cluster-access.html
#
# `eksctl` provides a command that creates the required RBAC resources for EMR,
# and updates the aws-auth ConfigMap to bind the role with the SLR for EMR.
#

output "enable_emr_access" {
  description = "Bash script to enable emr to the eks cluster"
  value = join(" ", [
    format("eksctl create iamidentitymapping --cluster %s --service-name emr-containers --namespace default", module.eks.cluster.name),
  ])
}

output "create_emr_containers" {
  description = "Bash script to create emr containers virtual cluster"
  value = join(" ", [
    "bash -e",
    format("%s/create-emr-virtual-cluster.sh", path.module),
  ])
}

output "delete_emr_containers" {
  description = "Bash script to delete emr containers virtual cluster"
  value = join(" ", [
    "bash -e",
    format("%s/delete-emr-virtual-cluster.sh", path.module),
  ])
}
