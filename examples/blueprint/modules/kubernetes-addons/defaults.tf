### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aws = {
    id        = module.aws.caller.account_id
    region    = module.aws.region.name
    partition = module.aws.partition.partition
  }
}
