#!/usr/bin/env bash
# Queries Prometheus's API directly for currently firing/pending alerts -
# faster than opening the UI when you just want a yes/no answer, and
# scriptable (e.g. for a CI smoke test that the alert rules loaded at all).
set -euo pipefail

NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
LOCAL_PORT=19090

echo "==> Port-forwarding Prometheus (background)"
kubectl port-forward svc/prometheus -n "${NAMESPACE}" "${LOCAL_PORT}:9090" > /dev/null 2>&1 &
PF_PID=$!
trap 'kill ${PF_PID} 2>/dev/null || true' EXIT
sleep 3

echo "==> Alert rules loaded:"
curl -s "http://localhost:${LOCAL_PORT}/api/v1/rules" | \
  grep -o '"name":"[A-Za-z]*"' | sort -u

echo
echo "==> Currently active (pending or firing) alerts:"
ACTIVE=$(curl -s "http://localhost:${LOCAL_PORT}/api/v1/alerts")
echo "${ACTIVE}" | grep -q '"alerts":\[\]' && echo "(none)" || echo "${ACTIVE}"
