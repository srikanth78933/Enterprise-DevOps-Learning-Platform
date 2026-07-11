#!/usr/bin/env bash
# Points local kubectl at the existing EKS cluster.
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-west-3}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-eks-cluster}"

aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

echo "kubeconfig updated. Verifying connectivity:"
kubectl get nodes
