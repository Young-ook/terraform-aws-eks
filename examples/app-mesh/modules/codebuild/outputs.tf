resource "local_file" "manifest" {
  content = templatefile("${path.module}/templates/yelb.tpl", {
    ecr_uri = module.ecr.url
  })
  filename        = "${path.cwd}/yelb.yaml"
  file_permission = "0400"
}