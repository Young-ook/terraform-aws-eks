terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "main" {
  source = "../../"
}
