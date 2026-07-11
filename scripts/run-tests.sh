#!/usr/bin/env bash
# Runs backend (JUnit/Mockito) and frontend (Jest) test suites.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Running backend tests"
(cd "${ROOT_DIR}/backend" && mvn -B test)

echo "==> Running frontend tests"
(cd "${ROOT_DIR}/frontend" && npm install && npm test)

echo "All tests passed."
