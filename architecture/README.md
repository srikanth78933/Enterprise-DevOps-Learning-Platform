# Architecture — Project 2: CD to AWS EKS

This project takes Project 1's CI pipeline and extends it into full CI/CD:
the backend now runs on a real AWS EKS cluster (provisioned and managed
outside this repo — see the note below), built, pushed, and deployed by
Jenkins.

See [`pipeline-diagram.md`](./pipeline-diagram.md) for the full extended
pipeline.

## Why there's no Terraform here

This branch originally provisioned its own EKS cluster via Terraform. It
now deploys onto an already-running cluster managed outside this repo, so
the Terraform code was removed rather than left to drift out of sync with
infrastructure it no longer actually controls — running `terraform apply`
against stale modules would create a second, different cluster instead of
managing the real one. `docs/01-Prerequisites.md` covers what access you
need to the existing cluster instead.

## Why there's no frontend here

Deploying both services to EKS at once — two Docker images, two
Deployments, path-based Ingress routing between them — added complexity
that wasn't the point of *this* project (learning the CD mechanics: build,
push, `kubectl apply -k`, `kubectl set image`, rolling updates, HPA). The
`frontend/` source itself, `docker/frontend.Dockerfile`, and the
`frontend` service in `docker-compose.yml` were all removed from this
branch — local dev here is backend+mysql only.
`project-03-cicd-helm-microservices` is where frontend and backend both
get proper, independent CI/CD treatment via Helm.

## What's new vs. project-01-ci-pipeline

| Added | Purpose |
|---|---|
| `kubernetes/` | Namespace, ConfigMaps, Secrets template, MySQL/backend Deployments, HPA, VPA, Ingress, Kustomization |
| `Jenkinsfile` stages: Docker Build, Push Docker Image, Deploy to EKS, Verify | Full CD |
| `scripts/configure-kubeconfig.sh`, `deploy-to-eks.sh`, `verify-deployment.sh` | Local equivalents of what Jenkins now automates |

## Key design decisions

- **`kubectl apply -k` before `kubectl set image`.** The kustomization
  provides the stable baseline (namespace, config, services, HPA, ingress);
  `set image` is a fast, targeted way to bump the container image per
  deploy without re-templating the whole manifest set. See the sequence
  diagram in `pipeline-diagram.md`.
- **MySQL as a single-replica Deployment + PVC, not a StatefulSet.** A
  StatefulSet's ordered/stable-identity guarantees matter for multi-node
  stateful clusters (which is what Project 5's Elasticsearch actually
  needs). A single MySQL replica gets nothing from that machinery — a
  Deployment with `strategy.type: Recreate` (never two pods writing to the
  same volume at once) is simpler and equally correct here.
- **Secrets are never committed to git.** `kubernetes/secret.example.yaml`
  is a template; real secrets are created imperatively via `kubectl create
  secret ... --dry-run=client -o yaml | kubectl apply -f -`, and in
  Jenkins, sourced from Jenkins Credentials.
- **AWS credentials reach Jenkins via two `Secret text` credentials**
  (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`), not a heavier AWS
  Credentials plugin — fewer moving parts for a learning environment, at
  the cost of not supporting STS AssumeRole chains (a Project 10 concern).

## Next branch

`project-03-cicd-helm-microservices` replaces these raw manifests with a
Helm umbrella chart and adds the frontend back in, as an independent
pipeline alongside the backend's.
