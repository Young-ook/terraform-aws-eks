aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.0.0.0/16"
name       = "eks-ecr"
tags = {
  env      = "dev"
  platform = "ec2"
}
enable_igw         = true
enable_ngw         = true
single_ngw         = true
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
