fargate_profiles = []
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
node_groups = []
