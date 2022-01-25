aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
name       = "eks-mng-mix-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "on-demand"
    capacity_type = "ON_DEMAND" # allowed values: ON_DEMAND, SPOT
    instance_type = "t3.medium"
    desired_size  = 1
  },
  {
    name          = "spot"
    capacity_type = "SPOT"
    instance_type = "t3.medium"
    desired_size  = 1
  }
]
node_groups      = []
fargate_profiles = []
