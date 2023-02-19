### Amazon EMR virtual cluster

resource "aws_emrcontainers_virtual_cluster" "emr" {
  name = module.frigga.name
  tags = var.tags

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
