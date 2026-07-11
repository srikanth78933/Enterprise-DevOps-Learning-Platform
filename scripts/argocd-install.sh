#!/usr/bin/env bash
# Installs Argo CD itself into the cluster via its official Helm chart.
# Run once per cluster (not per app deploy).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f "${ROOT_DIR}/gitops/argocd/values.yaml" \
  --wait --timeout 5m

echo
echo "==> Argo CD installed. Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
echo
echo
echo "==> Access the UI with:"
echo "    kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "    open https://localhost:8080  (login: admin / password above)"
