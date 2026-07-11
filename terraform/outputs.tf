output "cluster_name" {
  description = "Pass to `aws eks update-kubeconfig --name <this>`"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
