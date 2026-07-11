# Prerequisites — Project 4: GitOps with Argo CD

Builds on Project 3's prerequisites (Helm, a running EKS cluster with
Ingress Controller + Metrics Server — see `docs/01-Prerequisites.md` on
`project-03-cicd-helm-microservices`). Additionally:

| Tool | Minimum Version | Check |
|---|---|---|
| Argo CD CLI | 2.11+ | `argocd version --client` |
| Trivy | 0.50+ | `trivy --version` |
| Docker Scout CLI (optional) | latest | `docker scout version` |

## What you need already in place

- A running EKS cluster with the NGINX Ingress Controller and Metrics
  Server (Project 2)
- The `enterprise-app` Helm chart working via manual `helm install`
  (Project 3) — confirm this before adding Argo CD on top, so you're not
  debugging two new things at once
- A GitHub Personal Access Token (fine-grained, `Contents: read/write`
  scoped to this repo only) for Jenkins to commit GitOps value changes —
  see `jenkins/README.md` step 8

## New concept this project assumes no prior exposure to

**GitOps**: the practice of using Git as the single source of truth for
desired infrastructure/application state, with an automated controller
(Argo CD here) continuously reconciling the live system to match. If
you're used to imperative deploys (`kubectl apply`, `helm upgrade` run by
a human or a CI job), the mental model flip is: you no longer *tell* the
cluster what to do — you *declare* what should be true, and something else
makes it true, continuously, forever, including reverting anything that
drifts.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
