### output variables

output "addons" {
  description = "Attributes of eks addon"
  value       = aws_eks_addon.addon
}
