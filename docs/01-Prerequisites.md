# Prerequisites — Project 3: CI/CD with Helm & Independent Pipelines

Builds on Project 2's prerequisites (AWS CLI, kubectl, an existing EKS
cluster — see `docs/01-Prerequisites.md` on `project-02-cd-eks`).
Additionally:

| Tool | Minimum Version | Check |
|---|---|---|
| Helm | 3.14+ | `helm version` |

## What you need already in place

- The same existing EKS cluster from Project 2 (this project doesn't
  provision infrastructure any more than Project 2 does — no `terraform/`
  here)
- The EBS CSI driver, NGINX Ingress Controller, and Metrics Server
  installed (Project 2, steps 2-4 of `docs/03-Installation.md`)
- Docker Hub, Jenkins, SonarQube from Projects 1-2

## New this project

Two Jenkins pipeline jobs instead of one — see
[`jenkins/README.md`](../jenkins/README.md) step 7.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
