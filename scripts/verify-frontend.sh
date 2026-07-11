#!/usr/bin/env bash
# Smoke-tests the frontend through the Ingress. Used by frontend/Jenkinsfile's
# "Verify" stage and scripts/helm-upgrade-frontend.sh; safe to run manually.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"
INGRESS_HOST="${INGRESS_HOST:-enterprise-devops.example.com}"

LB_ADDRESS=""
for i in $(seq 1 30); do
  LB_ADDRESS=$(kubectl get ingress "${RELEASE}-ingress" -n "${NAMESPACE}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  [ -n "${LB_ADDRESS}" ] && break
  echo "  ...ingress address not ready yet (${i}/30), waiting 10s"
  sleep 10
done

if [ -z "${LB_ADDRESS}" ]; then
  echo "ERROR: Ingress load balancer address never became available." >&2
  exit 1
fi

echo "==> Verifying frontend via ${LB_ADDRESS}"
curl -sf -H "Host: ${INGRESS_HOST}" "http://${LB_ADDRESS}/" | grep -qi '<div id="root">' \
  && echo "Frontend OK" \
  || { echo "ERROR: frontend check failed" >&2; exit 1; }
