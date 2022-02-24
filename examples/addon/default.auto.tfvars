aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
use_default_vpc = true
name            = "eks-addon"
tags = {
  env = "dev"
}
enable_ssm         = true
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "default"
    desired_size  = 1
    min_size      = 1
    max_size      = 1
    instance_type = "m5.large"
  }
]
