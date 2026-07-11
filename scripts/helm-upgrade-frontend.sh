#!/usr/bin/env bash
# Local equivalent of frontend/Jenkinsfile's "Helm Upgrade" + "Verify" stages.
# Usage: ./scripts/helm-upgrade-frontend.sh <image-tag>
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"
TAG="${1:?Usage: helm-upgrade-frontend.sh <image-tag>}"

helm upgrade --install "${RELEASE}" "${ROOT_DIR}/helm/enterprise-app" \
  -n "${NAMESPACE}" --create-namespace \
  --reuse-values \
  --set frontend.image.tag="${TAG}" \
  --wait --timeout 5m

kubectl rollout status deployment/frontend -n "${NAMESPACE}" --timeout=180s
"${ROOT_DIR}/scripts/verify-frontend.sh"
