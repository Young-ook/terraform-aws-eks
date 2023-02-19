output "name" {
  description = "A name of generated EMR containers cluster"
  value       = aws_emrcontainers_virtual_cluster.emr.name
}
