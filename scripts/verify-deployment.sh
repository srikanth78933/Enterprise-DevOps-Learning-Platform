#!/usr/bin/env bash
# Smoke-tests a deployment: confirms pods are Ready, then hits the backend
# health endpoint through the Ingress load balancer.
# Used by the Jenkinsfile "Verify" stage and safe to run manually.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
INGRESS_HOST="${INGRESS_HOST:-enterprise-devops.example.com}"

echo "==> Checking pod readiness in namespace ${NAMESPACE}"
kubectl get pods -n "${NAMESPACE}" -o wide

NOT_READY=$(kubectl get pods -n "${NAMESPACE}" --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
if [ "${NOT_READY}" -gt 0 ]; then
  echo "ERROR: ${NOT_READY} pod(s) not in Running phase." >&2
  exit 1
fi

echo "==> Resolving the Ingress load balancer address (can take a few minutes on first deploy)"
LB_ADDRESS=""
for i in $(seq 1 30); do
  LB_ADDRESS=$(kubectl get ingress enterprise-devops-ingress -n "${NAMESPACE}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [ -n "${LB_ADDRESS}" ]; then
    break
  fi
  echo "  ...not ready yet (${i}/30), waiting 10s"
  sleep 10
done

if [ -z "${LB_ADDRESS}" ]; then
  echo "ERROR: Ingress load balancer address never became available." >&2
  echo "Check: kubectl describe ingress enterprise-devops-ingress -n ${NAMESPACE}" >&2
  exit 1
fi

echo "==> Load balancer: ${LB_ADDRESS}"
echo "==> Verifying backend health via the Ingress (Host header, no DNS needed)"
curl -sf -H "Host: ${INGRESS_HOST}" "http://${LB_ADDRESS}/api/health" | grep -q '"status":"UP"' \
  && echo "Backend OK" \
  || { echo "ERROR: backend health check failed" >&2; exit 1; }

echo "Verification passed."
