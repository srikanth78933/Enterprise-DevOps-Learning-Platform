#!/usr/bin/env bash
# Generates sustained concurrent load against the backend - enough to
# move the Grafana dashboards and, with default resource limits, likely
# enough to trip HighCPUUsage after a few minutes. If it doesn't (limits
# are somewhat generous by default), see docs/04-Step-by-Step.md for how
# to temporarily lower backend.resources.limits.cpu for a reliable demo,
# the same pattern Project 5 used for the slow-request threshold.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"
RELEASE="${HELM_RELEASE:-enterprise-app}"
INGRESS_HOST="${INGRESS_HOST:-enterprise-devops.example.com}"
DURATION_SECONDS="${1:-300}"
CONCURRENCY="${2:-20}"

LB_ADDRESS=$(kubectl get ingress "${RELEASE}-ingress" -n "${NAMESPACE}" \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)

if [ -z "${LB_ADDRESS}" ]; then
  echo "ERROR: Ingress load balancer address not found. Is the app deployed?" >&2
  exit 1
fi

echo "==> Generating load: ${CONCURRENCY} concurrent workers for ${DURATION_SECONDS}s"
echo "    Watch it live: ./scripts/grafana-port-forward.sh, then open the Application dashboard"
echo "    or: ./scripts/prometheus-port-forward.sh, then open the HighCPUUsage/HighMemoryUsage alert state"

END=$((SECONDS + DURATION_SECONDS))
pids=()
for i in $(seq 1 "${CONCURRENCY}"); do
  (
    while [ $SECONDS -lt $END ]; do
      curl -s -H "Host: ${INGRESS_HOST}" "http://${LB_ADDRESS}/api/employees" > /dev/null
      curl -s -H "Host: ${INGRESS_HOST}" "http://${LB_ADDRESS}/api/departments" > /dev/null
      curl -s -H "Host: ${INGRESS_HOST}" "http://${LB_ADDRESS}/api/projects" > /dev/null
    done
  ) &
  pids+=($!)
done

wait "${pids[@]}"
echo "Load generation complete."
