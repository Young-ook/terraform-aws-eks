use_default_vpc = false
fargate_profiles = [
  {
    name      = "hello-fargate"
    namespace = "hello-fargate"
  },
]
managed_node_groups = []
node_groups         = []
