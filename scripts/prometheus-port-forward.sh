#!/usr/bin/env bash
# Quick local access to the Prometheus UI (Status > Targets is the first
# place to check when a scrape target isn't showing data) and Alertmanager.
set -euo pipefail

NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
SERVICE="${1:-prometheus}"   # prometheus | alertmanager
LOCAL_PORT="${2:-9090}"

case "${SERVICE}" in
  prometheus)   TARGET_PORT=9090 ;;
  alertmanager) TARGET_PORT=9093 ;;
  *) echo "Usage: $0 [prometheus|alertmanager] [local-port]" >&2; exit 1 ;;
esac

echo "==> Forwarding localhost:${LOCAL_PORT} -> ${SERVICE}:${TARGET_PORT} in namespace ${NAMESPACE}"
echo "    Open http://localhost:${LOCAL_PORT}"
kubectl port-forward "svc/${SERVICE}" -n "${NAMESPACE}" "${LOCAL_PORT}:${TARGET_PORT}"
