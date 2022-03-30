aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name            = "eks-autoscaling-tc5"
use_default_vpc = false
tags = {
  env         = "dev"
  test        = "tc5"
  ssm_managed = "enabled"
  fargate     = "enabled"
}
kubernetes_version = "1.21"
enable_ssm         = true
managed_node_groups = [
]
node_groups = []
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
]
