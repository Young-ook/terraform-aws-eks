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
      name      = "yelbv2"
      image     = "aws/codebuild/standard:5.0"
      buildspec = "examples/blueprint/apps/yelbv2/buildspec.yml"
      app_path  = "examples/blueprint/apps/yelbv2"
      repo      = "yelbv2"
    },
  ]
}

module "ci" {
  for_each = { for proj in local.projects : proj.name => proj }
  source   = "Young-ook/spinnaker/aws//modules/codebuild"
  version  = "2.3.6"
  name     = each.key
  tags     = var.tags
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
        APP_PATH       = lookup(each.value, "app_path")
        ARCH           = lookup(each.value, "arch", "amd64")
        REPOSITORY_URI = module.ecr[lookup(each.value, "repo")].url
      }
    }
  }
  policy_arns = [
    module.ecr[lookup(each.value, "repo")].policy_arns["read"],
    module.ecr[lookup(each.value, "repo")].policy_arns["write"],
  ]
  log = {
    cloudwatch_logs = {
      group_name = module.logs["codebuild"].log_group.name
    }
  }
}

module "ecr" {
  for_each     = { for proj in local.projects : proj.repo => proj... }
  source       = "Young-ook/eks/aws//modules/ecr"
  version      = "1.7.11"
  name         = each.key
  scan_on_push = false
}

module "logs" {
  source  = "Young-ook/lambda/aws//modules/logs"
  version = "0.2.1"
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
  content = templatefile("${path.module}/apps/hellojs/hellojs.yaml.tpl", {
    ecr_uri = module.ecr["hellojs"].url
  })
  filename        = "${path.cwd}/hellojs.yaml"
  file_permission = "0400"
}
