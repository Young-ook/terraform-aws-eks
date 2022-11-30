### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.6"
  name    = var.name
  petname = true
}

locals {
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = module.frigga.name },
  )
}
