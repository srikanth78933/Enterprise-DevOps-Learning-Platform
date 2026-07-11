# Architecture (main branch)

The base application is a deliberately simple 3-tier system: **React → Spring
Boot → MySQL**. No authentication, no message queues, no caching layer — the
goal is to keep the application easy to reason about so that later project
branches can layer DevOps tooling around it without fighting business-logic
complexity.

Full diagrams (component, class/module, request sequence) live in
[`/diagrams/application-architecture.md`](../diagrams/application-architecture.md).

## Backend layering

```
controller/   → REST endpoints, request/response mapping, validation trigger
service/      → business rules, orchestration, transaction boundaries
service/impl/ → concrete implementations of the service interfaces
repository/   → Spring Data JPA interfaces (no custom SQL needed yet)
model/entity/ → JPA entities (Employee, Department, Project, ProjectStatus)
dto/          → request/response contracts, decoupled from entities
exception/    → ResourceNotFoundException + GlobalExceptionHandler (RFC-7807-style ApiError)
config/       → CorsConfig (frontend origin allow-list)
```

Controllers never touch entities directly — everything crosses the
controller boundary as a DTO. This keeps the API contract stable even if the
persistence model changes later (relevant once Terraform-managed RDS
replaces the local MySQL container in Project 2).

## Frontend layering

```
api/          → one file per resource (employeeApi.js, departmentApi.js, ...),
                all HTTP calls go through the shared apiClient.js axios instance
components/   → reusable UI (Navbar, Footer, Loader, ErrorBanner, ConfirmDialog)
pages/        → one screen per route (List + Form pair per module)
styles/       → single App.css, no CSS framework dependency
```

## Why no authentication yet

Adding auth now would obscure the DevOps lessons this repository exists to
teach. Security concerns (secrets management, RBAC, network policy) are
introduced progressively starting in Project 4 (GitOps + Trivy/OWASP
scanning) rather than baked into the app itself.

## Next

Continue to [03-Installation.md](./03-Installation.md).
