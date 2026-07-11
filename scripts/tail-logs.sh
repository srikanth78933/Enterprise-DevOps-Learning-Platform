#!/usr/bin/env bash
# Tails raw backend container logs directly via kubectl, bypassing the
# whole ELK pipeline - useful for confirming the app itself is emitting
# the JSON you expect before debugging whether Filebeat/Logstash/
# Elasticsearch are the problem.
set -euo pipefail

NAMESPACE="${K8S_NAMESPACE:-enterprise-devops}"

echo "==> Tailing backend logs (Ctrl+C to stop). Expect one JSON object per line"
echo "    once SPRING_PROFILES_ACTIVE is anything other than 'dev' - see"
echo "    backend/src/main/resources/logback-spring.xml."
kubectl logs -f -l app.kubernetes.io/name=backend -n "${NAMESPACE}" --max-log-requests=10
