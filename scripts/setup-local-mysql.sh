#!/usr/bin/env bash
# Starts a standalone MySQL container for local backend development
# without needing the full docker-compose stack.
set -euo pipefail

CONTAINER_NAME="devops-mysql-standalone"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Container ${CONTAINER_NAME} already exists. Starting it..."
  docker start "${CONTAINER_NAME}"
else
  echo "Creating and starting ${CONTAINER_NAME}..."
  docker run -d \
    --name "${CONTAINER_NAME}" \
    -e MYSQL_DATABASE=enterprise_devops \
    -e MYSQL_USER=devops_user \
    -e MYSQL_PASSWORD=devops_pass \
    -e MYSQL_ROOT_PASSWORD=root_pass \
    -p 3306:3306 \
    mysql:8.0
fi

echo "Waiting for MySQL to become healthy..."
until docker exec "${CONTAINER_NAME}" mysqladmin ping -h localhost -uroot -proot_pass --silent; do
  sleep 2
done

echo "MySQL is ready on localhost:3306 (db: enterprise_devops, user: devops_user)"
