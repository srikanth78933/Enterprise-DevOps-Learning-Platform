# Troubleshooting (main branch)

## Backend fails to start: `Communications link failure`

MySQL isn't reachable yet. Confirm the container is running and healthy:

```bash
docker ps --filter name=devops-mysql
docker logs devops-mysql
```

If using `docker compose`, the `backend` service already waits on
`mysql`'s healthcheck — if it's still failing, the healthcheck itself is
failing; check `docker compose logs mysql`.

## `Table 'enterprise_devops.employees' doesn't exist`

`spring.jpa.hibernate.ddl-auto` is `update` in the `dev` profile, which
creates tables automatically on first boot. If you switched to the `prod`
profile (`ddl-auto: validate`) against an empty database, tables were never
created. Either run once with `dev`, or apply a schema migration manually.

## Frontend shows "Network Error" on every page

- Confirm the backend is actually up: `curl http://localhost:8080/api/health`
- Confirm `frontend/.env` has `REACT_APP_API_BASE_URL=http://localhost:8080/api`
  (copy from `.env.example` if missing) and restart `npm start` — React only
  reads `.env` at process startup

## CORS error in the browser console

`CorsConfig` only allows the origin in `app.cors.allowed-origins`
(default `http://localhost:3000`). If you're serving the frontend from a
different port or host, set `CORS_ALLOWED_ORIGINS` accordingly when starting
the backend.

## `mvn test` fails with Lombok-related compile errors

Ensure your IDE has annotation processing enabled for Lombok, and that
you're on JDK 21 exactly (`java -version`) — Lombok 1.18.x used by this
Spring Boot parent version is validated against JDK 21.

## Port already in use (3000 / 8080 / 3306)

```bash
# find and stop whatever is bound to the port, e.g. on 8080:
lsof -i :8080        # macOS/Linux
netstat -ano | findstr :8080   # Windows
```

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
