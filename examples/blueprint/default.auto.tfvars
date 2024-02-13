tags             = { example = "eks_blueprint" }
fargate_profiles = []
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 3
    instance_type = "m5.xlarge"
  },
]
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.xlarge"
    volume_type   = "gp3"
  },
]
