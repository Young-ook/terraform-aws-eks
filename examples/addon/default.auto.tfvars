name = "eks-addon"
tags = {
  env = "dev"
}
aws_region         = "ap-northeast-2"
enable_ssm         = true
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "default"
    desired_size  = 1
    min_size      = 1
    max_size      = 1
    instance_type = "m5.large"
  }
]
