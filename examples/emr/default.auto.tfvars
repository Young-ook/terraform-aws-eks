name = "eks-emr"
tags = {
  env = "prod"
}
aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr               = "10.1.0.0/16"
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "spark"
    desired_size  = 3
    min_size      = 3
    max_size      = 9
    instance_type = "m5.large"
  }
]
