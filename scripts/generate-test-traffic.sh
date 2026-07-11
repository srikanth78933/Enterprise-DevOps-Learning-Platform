#!/usr/bin/env bash
# Generates a mix of normal, not-found, and validation-error requests
# against the deployed backend so there's actually something interesting
# to look at in Kibana (application logs, error logs, request logs) -
# see docs/04-Step-by-Step.md for the full exercise, including how to
# also generate a slow-request log entry.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"
INGRESS_HOST="${INGRESS_HOST:-enterprise-devops.example.com}"

LB_ADDRESS=$(kubectl get ingress "${RELEASE}-ingress" -n "${NAMESPACE}" \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)

if [ -z "${LB_ADDRESS}" ]; then
  echo "ERROR: Ingress load balancer address not found. Is the app deployed?" >&2
  exit 1
fi

BASE_URL="http://${LB_ADDRESS}"
HDR=(-H "Host: ${INGRESS_HOST}")

echo "==> Generating normal traffic (request_log entries)"
for i in $(seq 1 10); do
  curl -s "${HDR[@]}" "${BASE_URL}/api/health" > /dev/null
  curl -s "${HDR[@]}" "${BASE_URL}/api/employees" > /dev/null
  curl -s "${HDR[@]}" "${BASE_URL}/api/departments" > /dev/null
done

echo "==> Generating 404s (error-ish, but WARN not ERROR - see GlobalExceptionHandler)"
for i in $(seq 1 5); do
  curl -s "${HDR[@]}" "${BASE_URL}/api/employees/999999" > /dev/null
done

echo "==> Generating a validation failure (400, WARN)"
curl -s "${HDR[@]}" -X POST "${BASE_URL}/api/departments" \
  -H "Content-Type: application/json" -d '{"name":"","code":""}' > /dev/null

echo "Done. Give Filebeat/Logstash a few seconds, then check Kibana's Discover"
echo "tab filtered to index enterprise-devops-logs-* ."
