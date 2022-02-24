aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-autoscaling-tc4"
tags = {
  env         = "dev"
  test        = "tc4"
  ssm_managed = "enabled"
}
kubernetes_version = "1.21"
enable_ssm         = true
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.small"
  }
]
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.small"
  }
]
fargate_profiles = []
