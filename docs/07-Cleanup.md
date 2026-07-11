# Cleanup (main branch)

## Docker Compose stack

```bash
docker compose -f docker/docker-compose.yml down
# also remove the MySQL data volume:
docker compose -f docker/docker-compose.yml down -v
```

## Standalone MySQL container (from setup-local-mysql.sh)

```bash
docker stop devops-mysql-standalone
docker rm devops-mysql-standalone
```

## Build artifacts

```bash
# backend
rm -rf backend/target

# frontend
rm -rf frontend/node_modules frontend/build
```

## Docker images built locally

```bash
docker image prune -f
docker rmi $(docker images 'enterprise-devops-learning-platform*' -q) 2>/dev/null || true
```

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
