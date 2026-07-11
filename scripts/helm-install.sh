#!/usr/bin/env bash
# Carried over from project-03. Since project-04, prefer
# scripts/argocd-install.sh + scripts/argocd-bootstrap.sh instead - Argo CD
# performs the equivalent first install once the Application is registered,
# and then keeps managing it (this script's install is a one-time action;
# Argo CD's is continuous). Still useful for confirming the chart installs
# cleanly in isolation (e.g. a throwaway namespace) before wiring up
# Argo CD, or for chart development outside the GitOps flow entirely.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"

echo "==> Creating namespace ${NAMESPACE} (if it doesn't already exist)"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

if ! kubectl get secret backend-secret -n "${NAMESPACE}" >/dev/null 2>&1; then
  echo "ERROR: secret 'backend-secret' not found in namespace ${NAMESPACE}." >&2
  echo "Create it first - see helm/enterprise-app/README.md." >&2
  exit 1
fi
if ! kubectl get secret mysql-secret -n "${NAMESPACE}" >/dev/null 2>&1; then
  echo "ERROR: secret 'mysql-secret' not found in namespace ${NAMESPACE}." >&2
  echo "Create it first - see helm/enterprise-app/README.md." >&2
  exit 1
fi

echo "==> Installing/upgrading Helm release ${RELEASE}"
helm upgrade --install "${RELEASE}" "${ROOT_DIR}/helm/enterprise-app" \
  -n "${NAMESPACE}" --create-namespace \
  --wait --timeout 5m

echo "==> Done. Status:"
kubectl get pods,svc,hpa,ingress -n "${NAMESPACE}"
