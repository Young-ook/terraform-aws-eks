### output variables

output "associations" {
  description = "The attributes of pod identity associations"
  #sensitive   = true
  value = { for a in aws_eks_pod_identity_association.pid : a.association_id => a }
}
