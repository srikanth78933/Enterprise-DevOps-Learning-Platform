#!/usr/bin/env bash
# Tears down everything terraform/ provisioned. Run this as soon as you're
# done experimenting - see docs/07-Cleanup.md for the full teardown order
# (Kubernetes-created load balancers should be removed BEFORE this, or
# terraform destroy can leave an orphaned ELB/NLB that keeps billing).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

cd "${TF_DIR}"

echo "==> Checking for Kubernetes-managed load balancers that Terraform doesn't know about"
if kubectl get ingress -A --no-headers 2>/dev/null | grep -q .; then
  echo "WARNING: Ingress resources still exist. Their load balancers were created by the"
  echo "NGINX Ingress Controller, not Terraform - deleting the EKS cluster without first"
  echo "deleting the Ingress (and the ingress-nginx controller's Service) can leave an"
  echo "orphaned, still-billing ELB/NLB behind. Recommended:"
  echo "    helm uninstall enterprise-app -n enterprise-devops   (removes the app's Ingress)"
  echo "    helm uninstall ingress-nginx -n ingress-nginx        (removes the controller itself)"
  read -p "Continue with terraform destroy anyway? [y/N] " confirm
  if [ "${confirm}" != "y" ] && [ "${confirm}" != "Y" ]; then
    echo "Aborted."
    exit 1
  fi
fi

terraform destroy
