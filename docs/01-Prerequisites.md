# Prerequisites — Project 3: CI/CD with Helm & Independent Pipelines

Builds on Project 2's prerequisites (AWS CLI, kubectl, Terraform, an EKS
cluster — see `docs/01-Prerequisites.md` on `project-02-cd-eks`).
Additionally:

| Tool | Minimum Version | Check |
|---|---|---|
| Helm | 3.14+ | `helm version` |

## What you need already in place

- A running EKS cluster (from Project 2's `terraform apply`, or freshly
  provisioned — this project doesn't change `terraform/` at all)
- The NGINX Ingress Controller and Metrics Server installed (Project 2,
  steps 3-4 of `docs/03-Installation.md`)
- Docker Hub, Jenkins, SonarQube from Projects 1-2

## New this project

Two Jenkins pipeline jobs instead of one — see
[`jenkins/README.md`](../jenkins/README.md) step 7.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
