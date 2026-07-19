#!/usr/bin/env bash
# Local equivalent of the Jenkinsfile "Deploy to EKS" stage. Useful for
# testing a deployment change before wiring it into Jenkins, or for a
# manual redeploy of the current backend image.
#
# Usage:
#   ./scripts/deploy-to-eks.sh [image-tag]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
BACKEND_IMAGE="${BACKEND_IMAGE:-devopstraining064/enterprise-devops-backend}"
TAG="${1:-latest}"

echo "==> Applying baseline manifests (namespace, config, services, HPA, ingress)"
kubectl apply -k "${ROOT_DIR}/kubernetes"

echo "==> Setting image tag to ${TAG}"
kubectl set image deployment/backend backend="${BACKEND_IMAGE}:${TAG}" -n "${NAMESPACE}"

echo "==> Waiting for rollout"
kubectl rollout status deployment/backend -n "${NAMESPACE}" --timeout=180s

echo "Deploy complete. Run scripts/verify-deployment.sh to smoke-test it."
