# build container image

# This seperate provider is no longer required in this example,
# because this example tested on ap-northeast-2 (seoul) and it supports arm64 architectre
# with ECR, ECR, EKS, CodeBuild now. if you want to run this example on other regions,
# please check below before you begin.
# (https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html)

provider "aws" {
  alias  = "codebuild"
  region = "ap-northeast-1"
}

### pipeline/cb
locals {
  stages             = ["amd64", "arm64", "manifest"]
  image_al2_aarch64  = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
  image_al2_amd64    = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  buildspec_image    = "examples/arm64/buildspec-docker.yaml"
  buildspec_manifest = "examples/arm64/buildspec-manifest.yaml"
}

module "cb" {
  for_each = toset(local.stages)
  source   = "Young-ook/spinnaker/aws//modules/codebuild"
  version  = "2.2.6"
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
    version   = "main"
  }
  policy_arns = [
    module.ecr.policy_arns["read"],
    module.ecr.policy_arns["write"],
  ]
}

resource "local_file" "manifest" {
  content = templatefile("${path.module}/templates/hello-nodejs.tpl", {
    ecr_uri = module.ecr.url
  })
  filename        = "${path.cwd}/hello-nodejs.yaml"
  file_permission = "0400"
}
