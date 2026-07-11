variable "project_name" {
  description = "Used as a prefix for all VPC resource names/tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "AZs to spread subnets across - EKS requires at least 2"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ), used by the Ingress load balancer"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ), used by EKS worker nodes"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name - subnets are tagged with kubernetes.io/cluster/<name> so the AWS Load Balancer Controller and cluster-autoscaler can discover them"
  type        = string
}
