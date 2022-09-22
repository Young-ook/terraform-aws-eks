### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.6"
  name    = lookup(var.helm, "name", local.default_helm_config["name"])
  petname = true
}
