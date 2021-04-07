### ecr
module "ecr" {
  source       = "Young-ook/eks/aws//modules/ecr"
  name         = "hello-nodejs"
  scan_on_push = false
}

### codebuild
locals {
  stages             = ["amd64", "arm64", "manifest"]
  image_al2_aarch64  = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
  image_al2_amd64    = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  buildspec_image    = "examples/arm64/modules/codebuild/buildspec-docker.yaml"
  buildspec_manifest = "examples/arm64/modules/codebuild/buildspec-manifest.yaml"
}

module "cb" {
  for_each = toset(local.stages)
  source   = "Young-ook/spinnaker/aws//modules/codebuild"
  version  = "~> 2.0"
  name     = join("-", ["hello-nodejs", each.key])
  tags     = var.tags
  environment_config = {
    type            = each.key == "arm64" ? "ARM_CONTAINER" : "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = each.key == "arm64" ? local.image_al2_aarch64 : local.image_al2_amd64
    privileged_mode = true
    environment_variables = {
      REPOSITORY_URI = module.ecr.url
      TAG            = each.key == "manifest" ? "" : each.key
    }
  }
  source_config = {
    type      = "GITHUB"
    location  = "https://github.com/Young-ook/terraform-aws-eks.git"
    buildspec = each.key == "manifest" ? local.buildspec_manifest : local.buildspec_image
  }
  policy_arns = [
    module.ecr.policy_arns["read"],
    module.ecr.policy_arns["write"],
  ]
}
