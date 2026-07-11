#!/usr/bin/env bash
# Local equivalent of backend/Jenkinsfile's "Helm Upgrade" + "Verify" stages.
# Usage: ./scripts/helm-upgrade-backend.sh <image-tag>
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"
TAG="${1:?Usage: helm-upgrade-backend.sh <image-tag>}"

helm upgrade --install "${RELEASE}" "${ROOT_DIR}/helm/enterprise-app" \
  -n "${NAMESPACE}" --create-namespace \
  --reuse-values \
  --set backend.image.tag="${TAG}" \
  --wait --timeout 5m

kubectl rollout status deployment/backend -n "${NAMESPACE}" --timeout=180s
"${ROOT_DIR}/scripts/verify-backend.sh"
