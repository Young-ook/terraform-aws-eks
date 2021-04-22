resource "local_file" "manifest" {
  content = templatefile("${path.module}/templates/hello-nodejs.tpl", {
    ecr_uri = module.ecr.url
  })
  filename        = "${path.cwd}/hello-nodejs.yaml"
  file_permission = "0400"
}
