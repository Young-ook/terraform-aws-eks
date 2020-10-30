## virtual private cloud

## default vpc
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  subnet_ids = var.subnets == null ? data.aws_subnet_ids.default.ids : var.subnets
}
