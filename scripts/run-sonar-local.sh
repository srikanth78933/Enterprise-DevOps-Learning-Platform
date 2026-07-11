#!/usr/bin/env bash
# Runs a SonarQube analysis against a local SonarQube instance, without Jenkins.
# Starts a throwaway SonarQube container if one isn't already running.
#
# Usage:
#   SONAR_TOKEN=squ_xxx ./scripts/run-sonar-local.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER_NAME="devops-sonarqube-local"
SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "==> Starting local SonarQube (first boot can take ~60s to become ready)"
  docker run -d --name "${CONTAINER_NAME}" -p 9000:9000 sonarqube:lts-community
  echo "Visit ${SONAR_HOST_URL} , log in with admin/admin, generate a token,"
  echo "then re-run this script with SONAR_TOKEN=<token>."
  exit 0
fi

if [ -z "${SONAR_TOKEN:-}" ]; then
  echo "SONAR_TOKEN is not set. Generate one at ${SONAR_HOST_URL}/account/security" >&2
  exit 1
fi

echo "==> Running analysis"
(cd "${ROOT_DIR}/backend" && mvn -B -ntp clean verify sonar:sonar \
  -Dsonar.host.url="${SONAR_HOST_URL}" \
  -Dsonar.token="${SONAR_TOKEN}")

echo "==> Analysis submitted. View results at ${SONAR_HOST_URL}/dashboard?id=enterprise-devops-backend"
