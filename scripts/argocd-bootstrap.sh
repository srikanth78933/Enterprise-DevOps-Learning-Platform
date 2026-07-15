#!/usr/bin/env bash
# Applies the AppProject and Application manifests that tell Argo CD what
# to deploy and from where. Run once after argocd-install.sh (and again
# any time you change gitops/projects/ or gitops/applications/ by hand -
# though after this first apply, Argo CD itself notices Git changes to
# its own Application/AppProject manifests too, if you apply this "app of
# apps" style - not done in this project for simplicity, see docs/08-Assignments.md).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

kubectl apply -f "${ROOT_DIR}/gitops/projects/enterprise-devops-project.yaml"
kubectl apply -f "${ROOT_DIR}/gitops/applications/enterprise-app.yaml"

echo "==> Application registered. Status:"
kubectl get application enterprise-app -n argocd

echo
echo "Argo CD will now sync automatically (syncPolicy.automated). Watch progress:"
echo "    kubectl get application enterprise-app -n argocd -w"
