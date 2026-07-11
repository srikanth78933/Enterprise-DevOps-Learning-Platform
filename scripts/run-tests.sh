#!/usr/bin/env bash
# Runs the backend (JUnit/Mockito) test suite.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Running backend tests"
(cd "${ROOT_DIR}/backend" && mvn -B test)

echo "All tests passed."
