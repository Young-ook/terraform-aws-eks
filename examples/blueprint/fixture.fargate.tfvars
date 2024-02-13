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
    desired_size  = 2
    instance_type = "t3.2xlarge"
  },
]
node_groups = []
