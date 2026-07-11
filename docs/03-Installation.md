# Installation (main branch)

You have two options: run everything with Docker Compose (fastest), or run
each piece natively (better for active development with hot reload).

## Option A — Docker Compose (recommended for a first look)

```bash
git clone <your-fork-url> Enterprise-DevOps-Learning-Platform
cd Enterprise-DevOps-Learning-Platform
docker compose -f docker/docker-compose.yml up --build
```

This starts MySQL, the backend (port 8080), and the frontend (port 3000,
served via NGINX). Visit http://localhost:3000.

## Option B — Native (recommended for development)

1. Start MySQL only:
   ```bash
   ./scripts/setup-local-mysql.sh
   ```
2. Start the backend in a separate terminal:
   ```bash
   ./scripts/run-backend.sh
   ```
3. Start the frontend in another terminal:
   ```bash
   ./scripts/run-frontend.sh
   ```
4. Visit http://localhost:3000. The React dev server proxies API calls to
   http://localhost:8080/api (configured via `frontend/.env`).

## Seeding sample data (optional)

```bash
mysql -h 127.0.0.1 -u devops_user -pdevops_pass enterprise_devops < backend/src/main/resources/data-dev.sql
```

## Verifying the install

```bash
curl http://localhost:8080/api/health
curl http://localhost:8080/api/about
curl http://localhost:8080/api/departments
```

All three should return JSON. See [05-Flow.md](./05-Flow.md) for the full
request lifecycle and [06-Troubleshooting.md](./06-Troubleshooting.md) if
something doesn't come up.

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
