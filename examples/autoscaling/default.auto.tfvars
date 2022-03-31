aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
use_default_vpc = true
name            = "eks-autoscaling"
tags = {
  env = "dev"
}
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "default"
    desired_size  = 2
    max_size      = 6
    instance_type = "t3.small"
  }
]
node_groups      = []
fargate_profiles = []
