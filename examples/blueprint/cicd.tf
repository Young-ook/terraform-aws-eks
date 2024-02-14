### container image build pipeline
locals {
  projects = [
    {
      name      = "hellojs-amd64"
      arch      = "amd64"
      image     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
      type      = "LINUX_CONTAINER"
      buildspec = "examples/blueprint/apps/hellojs/buildspec.yaml"
      app_path  = "examples/blueprint/apps/hellojs"
      repo      = "hellojs"
    },
    {
      name         = "hellojs-arm64"
      arch         = "arm64"
      image        = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
      compute_type = "BUILD_GENERAL1_LARGE"
      type         = "ARM_CONTAINER"
      buildspec    = "examples/blueprint/apps/hellojs/buildspec.yaml"
      app_path     = "examples/blueprint/apps/hellojs"
      repo         = "hellojs"
    },
    {
      name      = "yelb"
      image     = "aws/codebuild/standard:5.0"
      buildspec = "examples/blueprint/apps/yelb/buildspec.yml"
      app_path  = "examples/blueprint/apps/yelb"
      repo      = "yelb"
    },
  ]
}

module "ci" {
  depends_on = [module.s3]
  for_each   = { for proj in local.projects : proj.name => proj }
  source     = "Young-ook/spinnaker/aws//modules/codebuild"
  version    = "3.0.0"
  name       = each.key
  tags       = var.tags
  project = {
    source = {
      type      = "GITHUB"
      location  = "https://github.com/Young-ook/terraform-aws-eks.git"
      buildspec = lookup(each.value, "buildspec")
      version   = "main"
    }
    environment = {
      compute_type    = lookup(each.value, "compute_type", "BUILD_GENERAL1_SMALL")
      type            = lookup(each.value, "type", "LINUX_CONTAINER")
      image           = lookup(each.value, "image", "aws/codebuild/standard:4.0")
      privileged_mode = true
      environment_variables = {
        APP_PATH        = lookup(each.value, "app_path")
        ARCH            = lookup(each.value, "arch", "amd64")
        ARTIFACT_BUCKET = module.s3.bucket.id
        REPOSITORY_URI  = module.ecr[lookup(each.value, "repo")].url
      }
    }
  }
  policy_arns = [
    module.ecr[lookup(each.value, "repo")].policy_arns["read"],
    module.ecr[lookup(each.value, "repo")].policy_arns["write"],
    module.s3.policy_arns["write"],
  ]
  log = {
    cloudwatch_logs = {
      group_name = module.logs["codebuild"].log_group.name
    }
  }
}

### artifact/repository
module "ecr" {
  for_each     = { for proj in local.projects : proj.repo => proj... }
  source       = "Young-ook/eks/aws//modules/ecr"
  version      = "2.0.3"
  name         = each.key
  scan_on_push = false
}

### artifact/storage
module "s3" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  version       = "0.4.7"
  tags          = var.tags
  force_destroy = true
}

module "logs" {
  source  = "Young-ook/eventbridge/aws//modules/logs"
  version = "0.0.14"
  for_each = { for log in [
    {
      type = "codebuild"
      log_group = {
        namespace      = "/aws/codebuild"
        retension_days = 3
      }
    },
  ] : log.type => log }
  name      = "yelbv2"
  log_group = each.value.log_group
}

resource "local_file" "manifest" {
  for_each = {
    hellojs = {
      filepath = "${path.module}/apps/hellojs/hellojs.yaml.tpl"
    }
    yelb = {
      filepath = "${path.module}/apps/yelb/yelb.yaml.tpl"
    }
  }
  content = templatefile(lookup(each.value, "filepath"), {
    ecr_uri = module.ecr[each.key].url
  })
  filename        = "${path.module}/apps/${each.key}/${each.key}.yaml"
  file_permission = "0400"
}

resource "local_file" "localbuild" {
  content = templatefile("${path.module}/apps/hellojs/localbuild.sh.tpl", {
    region  = var.aws_region
    ecr_uri = module.ecr["hellojs"].url
  })
  filename        = "${path.module}/apps/hellojs/localbuild.sh"
  file_permission = "0400"
}

### role allows a spinnaker to manage an aws resources
module "spinnaker-managed-aws" {
  for_each         = (local.toggles.spinnaker_enabled ? toset(["enabled"]) : [])
  source           = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version          = "3.0.0"
  trusted_role_arn = [module.kubernetes-addons.spinnaker.irsa.arn]
}
