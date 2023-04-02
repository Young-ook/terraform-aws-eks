### Amazon EMR virtual cluster

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

resource "null_resource" "enable-emr-access" {
  provisioner "local-exec" {
    command = "eksctl create iamidentitymapping --cluster $CLUSTER_NAME --service-name $SERVICE_NAME --namespace $NAMESPACE"
    environment = {
      CLUSTER_NAME = lookup(var.container_providers, "id")
      SERVICE_NAME = lookup(var.container_providers, "service_name", local.default_emr_container_provider["service_name"])
      NAMESPACE    = lookup(var.container_providers, "namespace", local.default_emr_container_provider["namespace"])
    }
  }
}

resource "aws_emrcontainers_virtual_cluster" "emr" {
  depends_on = [null_resource.enable-emr-access]
  name       = module.frigga.name
  tags       = merge(var.tags, local.default-tags)

  container_provider {
    id   = lookup(var.container_providers, "id")
    type = lookup(var.container_providers, "type", local.default_emr_container_provider["type"])

    info {
      eks_info {
        namespace = lookup(var.container_providers, "namespace", local.default_emr_container_provider["namespace"])
      }
    }
  }
}
