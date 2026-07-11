#!/usr/bin/env bash
# Demonstrates Argo CD self-healing: manually drifts the cluster away from
# what Git declares, then watches Argo CD revert it. See
# docs/04-Step-by-Step.md for the full walkthrough this automates.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"

ORIGINAL=$(kubectl get deployment backend -n "${NAMESPACE}" -o jsonpath='{.spec.replicas}')
echo "==> Current backend replicas (per Git/Helm): ${ORIGINAL}"

echo "==> Manually drifting: scaling backend to 5 replicas via kubectl (bypassing Git)"
kubectl scale deployment/backend -n "${NAMESPACE}" --replicas=5

echo "==> Watching Argo CD revert the drift (syncPolicy.automated.selfHeal: true)"
echo "    This can take up to 3 minutes on Argo CD's default reconciliation interval,"
echo "    or click 'Refresh' in the Argo CD UI to force it immediately."

for i in $(seq 1 30); do
  CURRENT=$(kubectl get deployment backend -n "${NAMESPACE}" -o jsonpath='{.spec.replicas}')
  echo "  [$i/30] current replicas: ${CURRENT}"
  if [ "${CURRENT}" = "${ORIGINAL}" ]; then
    echo "Self-healed back to ${ORIGINAL} replicas."
    exit 0
  fi
  sleep 10
done

echo "Did not observe self-heal within 5 minutes - check 'kubectl get application enterprise-app -n argocd' for sync status." >&2
exit 1
