# default variables

locals {
  default_lifecycle_policy = {
    rules = [{
      rulePriority = 1
      description  = "Only keep 2 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 2
      }
      action = {
        type = "expire"
      }
    }]
  }
}
