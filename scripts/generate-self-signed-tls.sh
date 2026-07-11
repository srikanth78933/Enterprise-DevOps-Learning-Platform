#!/usr/bin/env bash
# Generates a self-signed TLS cert/key and stores it as a Kubernetes
# Secret - used for Kibana's Ingress in this tutorial.
#
# This is a learning-environment shortcut, not a production practice: a
# self-signed cert means every browser/client has to explicitly trust it
# (or click through a warning), and it never rotates automatically. A real
# deployment uses cert-manager with a real issuer (Let's Encrypt, or your
# org's internal CA) so certs are issued and renewed without a human
# running this script. See docs/06-Troubleshooting.md for the cert-manager
# migration path.
#
# Usage: ./scripts/generate-self-signed-tls.sh <hostname> <secret-name> <namespace>
set -euo pipefail

HOST="${1:?Usage: generate-self-signed-tls.sh <hostname> <secret-name> <namespace>}"
SECRET_NAME="${2:?Usage: generate-self-signed-tls.sh <hostname> <secret-name> <namespace>}"
NAMESPACE="${3:?Usage: generate-self-signed-tls.sh <hostname> <secret-name> <namespace>}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "${TMP_DIR}/tls.key" \
  -out "${TMP_DIR}/tls.crt" \
  -subj "/CN=${HOST}/O=enterprise-devops-learning-platform" \
  -addext "subjectAltName=DNS:${HOST}"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret tls "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --cert="${TMP_DIR}/tls.crt" \
  --key="${TMP_DIR}/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Created TLS secret '${SECRET_NAME}' in namespace '${NAMESPACE}' for host '${HOST}'."
echo "Your browser will warn about this cert being untrusted - that's expected for a self-signed cert."
