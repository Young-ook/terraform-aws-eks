# allowed values for 'ami_type'
#  - AL2_x86_64
#  - AL2_x86_64_GPU
#  - AL2_ARM_64
#  - CUSTOM
#  - BOTTLEROCKET_ARM_64
#  - BOTTLEROCKET_x86_64

fargate_profiles = []
managed_node_groups = [
  {
    name          = "bros"
    instance_type = "t3.small"
    ami_type      = "BOTTLEROCKET_x86_64"
  },
  {
    name          = "bros-arm64"
    instance_type = "m6g.medium"
    ami_type      = "BOTTLEROCKET_ARM_64"
  },
  {
    name          = "al2-gpu"
    instance_type = "g4dn.xlarge"
    ami_type      = "AL2_x86_64_GPU"
  },
]
node_groups = []
