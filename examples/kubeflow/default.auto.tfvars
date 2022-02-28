aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-kubeflow"
tags = {
  env = "dev"
}
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 9
    desired_size  = 7
    instance_type = "t3.small"
  }
]
node_groups      = []
fargate_profiles = []
