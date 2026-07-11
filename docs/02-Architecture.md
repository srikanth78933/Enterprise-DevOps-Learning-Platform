# Architecture — Project 4: GitOps with Argo CD

Full detail lives in [`/architecture`](../architecture/README.md) — this
page is the short version.

## New layer: `gitops/`

```
gitops/argocd/values.yaml                       → how Argo CD itself is installed
gitops/projects/enterprise-devops-project.yaml   → what Argo CD is allowed to touch
gitops/applications/enterprise-app.yaml          → the desired-state declaration
```

See [`architecture/pipeline-diagram.md`](../architecture/pipeline-diagram.md)
for the full flow and the self-healing reconciliation loop diagram.

## What each pipeline stage does now vs. Project 3

```
Project 3: ... -> Docker Build -> Push Image -> Helm Upgrade (Jenkins deploys) -> Verify (Jenkins checks kubectl rollout)
Project 4: ... -> Docker Build -> Trivy Scan -> Push Image -> Update GitOps Values (commit+push) -> Wait for Argo CD Sync (Jenkins asks Argo CD's status)
```

The "Verify"-shaped stage still exists (`Wait for Argo CD Sync`), but its
nature changed completely: it's a read-only status poll against the Argo
CD API, not a `kubectl rollout status` against the cluster Jenkins itself
just modified.

## New security scanning layer

```
backend/Jenkinsfile:  OWASP Dependency Check (Maven deps) -> Trivy (image) -> Docker Scout (image, optional)
frontend/Jenkinsfile: npm audit (npm deps)                -> Trivy (image) -> Docker Scout (image, optional)
```

## Next

Continue to [03-Installation.md](./03-Installation.md).
