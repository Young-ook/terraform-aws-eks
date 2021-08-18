aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-ecr"
tags = {
  env      = "dev"
  platform = "ec2"
}
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "hello"
    desired_size  = 1
    instance_type = "t3.medium"
  }
]
node_groups      = []
fargate_profiles = []
