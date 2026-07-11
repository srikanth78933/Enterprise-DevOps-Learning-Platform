resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access  = true
    endpoint_public_access   = true
    # Restrict this to your office/VPN CIDR in a real deployment - open to
    # the internet here only because this is a learning environment.
    public_access_cidrs      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.cluster_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "application"
  }

  tags = {
    Name        = "${var.cluster_name}-node-group"
    Project     = var.project_name
    Environment = var.environment
  }

  # IAM role policy attachments must exist before nodes try to join the cluster
  lifecycle {
    create_before_destroy = true
  }
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# OIDC provider enables IAM Roles for Service Accounts (IRSA) - not consumed
# in this project yet, but required by the AWS Load Balancer Controller and
# cluster-autoscaler that get installed via Helm starting in Project 3.
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "${var.cluster_name}-oidc"
    Project     = var.project_name
    Environment = var.environment
  }
}
