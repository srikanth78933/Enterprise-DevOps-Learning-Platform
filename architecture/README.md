# Architecture — Project 3: CI/CD with Helm & Independent Microservice Pipelines

This project doesn't change the AWS infrastructure at all — the EKS
cluster from `terraform/` (see [`aws-infrastructure.md`](./aws-infrastructure.md),
unchanged since Project 2) is exactly the same. What changes is *how* the
application gets deployed onto it, and how CI/CD is organized around two
independently deployable services instead of one monolithic pipeline.

See:
- [`helm-chart-structure.md`](./helm-chart-structure.md) — the umbrella chart and values precedence
- [`pipeline-diagram.md`](./pipeline-diagram.md) — the two independent pipelines

## What's new vs. project-02-cd-eks

| Added | Removed | Purpose |
|---|---|---|
| `helm/enterprise-app/` (umbrella chart: frontend/backend/mysql subcharts) | `kubernetes/` (raw manifests) | Templated, reusable, environment-overridable deployment |
| `backend/Jenkinsfile` | root `Jenkinsfile` | Backend builds/deploys independently |
| `frontend/Jenkinsfile` | — | Frontend builds/deploys independently |
| `docker/frontend-ci.Dockerfile` (from Project 2, unchanged) | — | Still used, now invoked by `frontend/Jenkinsfile` directly |

## Key design decisions

- **One Helm release, two pipelines, `--reuse-values` as the safety net.**
  See `pipeline-diagram.md` for why this specifically prevents one
  pipeline's deploy from clobbering the other's.
- **No `dependencies:` via a chart repository.** `Chart.yaml` declares
  `file://` dependencies pointing at the subchart directories Helm already
  auto-loads from `charts/` — declared explicitly because `helm lint`
  otherwise flags undeclared subchart dependencies as an error, not
  because `helm dependency update` is actually required here.
- **Secrets still never touch Helm.** `existingSecret` values reference
  Kubernetes Secrets created imperatively (same `kubectl create secret`
  pattern as Project 2) — `helm template`/`helm get values` output never
  contains a real credential.
- **Fixed (non-release-prefixed) subchart resource names.** Trades
  multi-release-per-namespace flexibility for keeping `backend`'s
  hardcoded `DB_URL` host stable. See `helm-chart-structure.md` for the
  full reasoning.

## Next branch

`project-04-gitops-argocd` replaces `kubectl`/`helm upgrade` calls from
Jenkins with Argo CD watching a Git repository — Jenkins's job becomes
"build, push, and update a values file in Git," not "deploy directly."
Also introduces Trivy, OWASP Dependency Check, and Docker Scout scanning.
