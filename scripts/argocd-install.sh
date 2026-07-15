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

echo "==> Waiting for the argocd-server LoadBalancer address (can take a few minutes)..."
LB_ADDRESS=""
for i in $(seq 1 30); do
  LB_ADDRESS=$(kubectl get svc argocd-server -n argocd \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  [ -n "${LB_ADDRESS}" ] && break
  echo "  ...not ready yet (${i}/30), waiting 10s"
  sleep 10
done

if [ -n "${LB_ADDRESS}" ]; then
  echo
  echo "==> Access the UI at: https://${LB_ADDRESS}  (login: admin / password above)"
  echo "    Use this same address for ARGOCD_SERVER in both Jenkinsfiles - see the"
  echo "    TODO comment at the top of backend/Jenkinsfile and frontend/Jenkinsfile."
else
  echo
  echo "==> LoadBalancer address not available yet - check later with:"
  echo "    kubectl get svc argocd-server -n argocd"
fi

echo
echo "(Alternative, local-only access: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo " then open https://localhost:8080 - fine for a human, but Jenkins needs the LoadBalancer"
echo " address above since it has no kubectl access to port-forward with.)"
