### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.5"
  name    = var.name == null || var.name == "" ? "emr-containers" : var.name
  petname = var.name == null || var.name == "" ? true : false
}

locals {
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = module.frigga.name },
  )
}
