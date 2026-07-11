#!/usr/bin/env bash
# Local equivalent of the Jenkinsfile "Package Jar" -> "Docker Build" ->
# "Push Docker Image" stages. Useful for testing the Docker image before
# wiring up Jenkins, or for manual releases.
#
# Usage:
#   IMAGE_NAME=yourdockerhubuser/enterprise-devops-backend ./scripts/docker-build-push.sh [tag]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-yourdockerhubuser/enterprise-devops-backend}"
TAG="${1:-local}"

echo "==> Packaging jar"
(cd "${ROOT_DIR}/backend" && mvn -B -ntp package -DskipTests)

echo "==> Building image ${IMAGE_NAME}:${TAG}"
docker build -f "${ROOT_DIR}/docker/backend-ci.Dockerfile" -t "${IMAGE_NAME}:${TAG}" "${ROOT_DIR}"

echo "==> Logging in to Docker Hub (expects DOCKERHUB_USERNAME / DOCKERHUB_TOKEN env vars)"
if [ -n "${DOCKERHUB_USERNAME:-}" ] && [ -n "${DOCKERHUB_TOKEN:-}" ]; then
  echo "${DOCKERHUB_TOKEN}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
  echo "==> Pushing ${IMAGE_NAME}:${TAG}"
  docker push "${IMAGE_NAME}:${TAG}"
  docker logout
else
  echo "DOCKERHUB_USERNAME / DOCKERHUB_TOKEN not set — built image locally only, skipping push."
fi
