#!/usr/bin/env bash
# Points local kubectl at the Terraform-provisioned EKS cluster.
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-enterprise-devops-dev-eks}"

aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

echo "kubeconfig updated. Verifying connectivity:"
kubectl get nodes
