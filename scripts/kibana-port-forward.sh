#!/usr/bin/env bash
# Quick local access to Kibana without going through the Ingress/TLS setup -
# useful for a first look before DNS/certs are wired up.
set -euo pipefail

NAMESPACE="${LOGGING_NAMESPACE:-logging}"
LOCAL_PORT="${1:-5601}"

echo "==> Forwarding localhost:${LOCAL_PORT} -> kibana:5601 in namespace ${NAMESPACE}"
echo "    Open http://localhost:${LOCAL_PORT}"
kubectl port-forward svc/kibana -n "${NAMESPACE}" "${LOCAL_PORT}:5601"
