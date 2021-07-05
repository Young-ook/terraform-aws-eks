### ecr
module "ecr" {
  source       = "Young-ook/eks/aws//modules/ecr"
  name         = "yelb"
  scan_on_push = false
}

### codebuild
locals {
  stages          = ["yelb"]
  image_al2_amd64 = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  buildspec       = "examples/app-mesh/modules/codebuild/buildspec.yaml"
}

module "cb" {
  for_each = toset(local.stages)
  source   = "Young-ook/spinnaker/aws//modules/codebuild"
  version  = "~> 2.0"
  name     = each.key
  tags     = var.tags
  environment_config = {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = local.image_al2_amd64
    privileged_mode = true
    environment_variables = {
      REPOSITORY_URI = module.ecr.url
      TAG            = "v2"
    }
  }
  source_config = {
    type      = "GITHUB"
    location  = "https://github.com/Young-ook/terraform-aws-eks.git"
    buildspec = local.buildspec
    version   = "main"
  }
  policy_arns = [
    module.ecr.policy_arns["read"],
    module.ecr.policy_arns["write"],
  ]
}
