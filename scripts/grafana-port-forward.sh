#!/usr/bin/env bash
# Quick local access to Grafana without going through the Ingress/TLS setup.
set -euo pipefail

NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
LOCAL_PORT="${1:-3000}"

echo "==> Forwarding localhost:${LOCAL_PORT} -> grafana:3000 in namespace ${NAMESPACE}"
echo "    Open http://localhost:${LOCAL_PORT} and log in with the grafana-admin secret's credentials"
kubectl port-forward svc/grafana -n "${NAMESPACE}" "${LOCAL_PORT}:3000"
