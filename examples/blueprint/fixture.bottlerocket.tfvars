# allowed values for 'ami_type'
#  - AL2_x86_64
#  - AL2_x86_64_GPU
#  - AL2_ARM_64
#  - CUSTOM
#  - BOTTLEROCKET_ARM_64
#  - BOTTLEROCKET_x86_64

fargate_profiles    = []
managed_node_groups = []
node_groups = [
  {
    name          = "bottlerocket"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.small"
    ami_type      = "BOTTLEROCKET_x86_64"
  },
]
