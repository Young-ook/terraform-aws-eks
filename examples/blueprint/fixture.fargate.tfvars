use_default_vpc = false
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
]
managed_node_groups = [
  {
    name          = "system"
    desired_size  = 1
    instance_type = "m6i.xlarge"
  },
]
node_groups = []
