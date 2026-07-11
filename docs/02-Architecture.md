# Architecture — Project 3: CI/CD with Helm & Independent Pipelines

Full detail lives in [`/architecture`](../architecture/README.md) — this
page is the short version.

## Helm chart layers

```
helm/enterprise-app/               → umbrella chart, owns the Ingress
helm/enterprise-app/charts/mysql/  → single-replica MySQL + PVC
helm/enterprise-app/charts/backend/  → Deployment, Service, ConfigMap, HPA
helm/enterprise-app/charts/frontend/ → Deployment, Service, optional HPA
```

See [`architecture/helm-chart-structure.md`](../architecture/helm-chart-structure.md)
for the values-precedence diagram and why subchart resource names are
fixed rather than release-prefixed.

## Pipeline layers (now two, not one)

```
backend/Jenkinsfile   → Maven/JUnit/SonarQube/Docker/Helm --set backend.image.tag
frontend/Jenkinsfile  → npm/Docker/Helm --set frontend.image.tag
```

See [`architecture/pipeline-diagram.md`](../architecture/pipeline-diagram.md)
for the full flow and the `--reuse-values` mechanism that keeps the two
pipelines from clobbering each other's last deployed image tag.

## What didn't change

- The AWS infrastructure — same VPC, same EKS cluster, still provisioned
  and managed outside this repo (no `terraform/` here, same as Project 2)
- The application code (`backend/src`, `frontend/src`) — identical to
  Project 2
- The Docker images themselves (`docker/backend-ci.Dockerfile`,
  `docker/frontend-ci.Dockerfile`)

## Next

Continue to [03-Installation.md](./03-Installation.md).
