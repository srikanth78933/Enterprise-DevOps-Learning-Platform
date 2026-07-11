#!/usr/bin/env bash
# Initializes and applies the Terraform configuration under terraform/.
# Requires AWS credentials already configured (env vars, ~/.aws/credentials,
# or an assumed role) and terraform >= 1.7 on PATH.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

if [ ! -f "${TF_DIR}/terraform.tfvars" ]; then
  echo "terraform.tfvars not found - copying from terraform.tfvars.example"
  cp "${TF_DIR}/terraform.tfvars.example" "${TF_DIR}/terraform.tfvars"
  echo "Review ${TF_DIR}/terraform.tfvars before continuing, then re-run this script."
  exit 1
fi

cd "${TF_DIR}"
terraform init
terraform plan -out=tfplan
echo
read -p "Apply this plan? Provisions real, billable AWS resources. [y/N] " confirm
if [ "${confirm}" = "y" ] || [ "${confirm}" = "Y" ]; then
  terraform apply tfplan
else
  echo "Aborted. Plan saved at ${TF_DIR}/tfplan for review."
fi
