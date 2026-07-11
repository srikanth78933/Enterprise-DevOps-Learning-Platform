#!/usr/bin/env bash
# Runs the Spring Boot backend locally with the dev profile.
set -euo pipefail

cd "$(dirname "$0")/../backend"
export SPRING_PROFILES_ACTIVE=dev

mvn spring-boot:run
