#!/usr/bin/env bash
# Removes the enterprise-app Helm release. Does NOT delete the mysql PVC
# (Kubernetes default) or the secrets - see docs/07-Cleanup.md for full
# teardown, and why that order matters.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"

helm uninstall "${RELEASE}" -n "${NAMESPACE}"

echo "Release uninstalled. Still present (delete explicitly if you want them gone too):"
kubectl get pvc,secret -n "${NAMESPACE}"
