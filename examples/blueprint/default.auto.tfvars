tags                = { example = "eks_blueprint" }
fargate_profiles    = []
managed_node_groups = []
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 9
    desired_size  = 4
    instance_type = "m6i.xlarge"
    volume_type   = "gp3"
  },
]
