#!/usr/bin/env bash
# Carried over from project-03 for local chart testing (e.g. against a
# throwaway namespace/cluster) ONLY. Since project-04, frontend/Jenkinsfile
# no longer runs this - it uses scripts/update-image-tag.sh + a Git commit
# instead. Running this directly against a cluster where Argo CD manages
# the `enterprise-app` Application will fight with it: `selfHeal: true`
# (see gitops/applications/enterprise-app.yaml) reverts this change back
# to whatever's in Git within minutes. Use scripts/update-image-tag.sh if
# you want a change to actually stick.
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
