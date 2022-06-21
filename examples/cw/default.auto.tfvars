aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
use_default_vpc = true
name            = "eks-cw"
tags = {
  env     = "dev"
  metrics = "false"
  logs    = "false"
}
kubernetes_version = "1.22"
managed_node_groups = [
  {
    name          = "mng"
    desired_size  = 1
    min_size      = 1
    max_size      = 3
    instance_type = "t3.large"
  },
  {
    name          = "mng-eachtag"
    desired_size  = 1
    min_size      = 1
    max_size      = 3
    instance_type = "t3.large"
    tags = {
      test = "each-node-tag"
    }
  }
]
node_groups = [
  {
    name          = "ng"
    desired_size  = 1
    min_size      = 1
    max_size      = 3
    instance_type = "t3.large"
  },
  {
    name          = "ng-eachtag"
    desired_size  = 1
    min_size      = 1
    max_size      = 3
    instance_type = "t3.large"
    tags = {
      test = "each-node-tag"
    }
  }
]
enable_cw = {
  enable_metrics = false
  enable_logs    = true
}
