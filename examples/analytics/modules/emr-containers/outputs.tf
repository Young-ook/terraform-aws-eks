output "cluster" {
  description = "The attributes of generated EMR virtual cluster"
  value       = aws_emrcontainers_virtual_cluster.emr
}
