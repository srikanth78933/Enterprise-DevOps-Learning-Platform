#!/usr/bin/env bash
# Runs the React frontend locally against a backend on localhost:8080.
set -euo pipefail

cd "$(dirname "$0")/../frontend"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created frontend/.env from .env.example"
fi

npm install
npm start
