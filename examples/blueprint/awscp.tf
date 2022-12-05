### container image build pipeline
module "ci" {
  source  = "Young-ook/spinnaker/aws//modules/codebuild"
  version = "2.3.1"
  name    = "yelbv2"
  tags    = var.tags
  project = {
    source = {
      type      = "GITHUB"
      location  = "https://github.com/Young-ook/terraform-aws-eks.git"
      buildspec = "examples/blueprint/yelbv2/buildspec.yml"
      version   = "main"
    }
    environment = {
      image           = "aws/codebuild/standard:4.0"
      privileged_mode = true
      environment_variables = {
        ARTIFACT_BUCKET = module.artifact.bucket.id
        REPOSITORY_URI  = module.ecr.url
        APP_NAME        = "examples/blueprint/yelbv2"
      }
    }
  }
  policy_arns = [
    module.ecr.policy_arns["read"],
    module.ecr.policy_arns["write"],
    module.artifact.policy_arns["write"],
  ]
  log = {
    cloudwatch_logs = {
      group_name = module.logs["codebuild"].log_group.name
    }
  }
}

module "artifact" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  version       = "0.2.0"
  name          = "yelbv2"
  tags          = var.tags
  force_destroy = true
}

module "ecr" {
  source       = "Young-ook/eks/aws//modules/ecr"
  name         = "yelbv2"
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
