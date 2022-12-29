### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.5"
  name    = var.name == null || var.name == "" ? "ecr" : var.name
  petname = var.name == null || var.name == "" ? true : false
}

locals {
  name = join("-", compact([var.namespace, module.frigga.name]))
  repo = join("/", compact([var.namespace, module.frigga.name]))
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.repo },
  )
}
