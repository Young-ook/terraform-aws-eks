fargate_profiles = []
managed_node_groups = [
  {
    name          = "x86"
    desired_size  = 1
    instance_type = "m5.large"
  },
  {
    name          = "arm64"
    desired_size  = 1
    instance_type = "m6g.large"
    ami_type      = "AL2_ARM_64"
  }
]
node_groups = []
