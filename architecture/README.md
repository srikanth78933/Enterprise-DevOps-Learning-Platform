# Architecture — Project 2: CD to AWS EKS

This project takes Project 1's CI pipeline and extends it into full CI/CD:
the same application now runs on a real (Terraform-provisioned) AWS EKS
cluster, with both the backend and frontend built, pushed, and deployed by
Jenkins.

See:
- [`aws-infrastructure.md`](./aws-infrastructure.md) — what Terraform builds
- [`pipeline-diagram.md`](./pipeline-diagram.md) — the full extended pipeline

## What's new vs. project-01-ci-pipeline

| Added | Purpose |
|---|---|
| `terraform/` | VPC, IAM, EKS cluster + managed node group |
| `kubernetes/` | Namespace, ConfigMaps, Secrets template, MySQL/backend/frontend Deployments, HPA, VPA, Ingress, Kustomization |
| `docker/frontend-ci.Dockerfile` | Packages the Jenkins-built frontend bundle (same reasoning as `backend-ci.Dockerfile`) |
| `Jenkinsfile` stages: Frontend Build, Docker Build (parallel), Push Docker Images (x2), Deploy to EKS, Verify | Full CD |
| `scripts/terraform-init-apply.sh`, `configure-kubeconfig.sh`, `deploy-to-eks.sh`, `verify-deployment.sh`, `terraform-destroy.sh` | Local equivalents of what Jenkins now automates |

## Key design decisions

- **`kubectl apply -k` before `kubectl set image`.** The kustomization
  provides the stable baseline (namespace, config, services, HPA, ingress);
  `set image` is a fast, targeted way to bump exactly two container images
  per deploy without re-templating the whole manifest set. See the sequence
  diagram in `pipeline-diagram.md`.
- **MySQL as a single-replica Deployment + PVC, not a StatefulSet.** A
  StatefulSet's ordered/stable-identity guarantees matter for multi-node
  stateful clusters (which is what Project 5's Elasticsearch actually
  needs). A single MySQL replica gets nothing from that machinery — a
  Deployment with `strategy.type: Recreate` (never two pods writing to the
  same volume at once) is simpler and equally correct here.
- **Secrets are never templated through Terraform or committed to git.**
  `kubernetes/secret.example.yaml` is a template; real secrets are created
  imperatively via `kubectl create secret ... --dry-run=client -o yaml |
  kubectl apply -f -`, and in Jenkins, sourced from Jenkins Credentials.
- **AWS credentials reach Jenkins via two `Secret text` credentials**
  (`aws-access-key-id`, `aws-secret-access-key`), not a heavier AWS
  Credentials plugin — fewer moving parts for a learning environment, at
  the cost of not supporting STS AssumeRole chains (a Project 10 concern).

## Next branch

`project-03-cicd-helm-microservices` replaces these raw manifests with a
Helm umbrella chart and splits this single Jenkinsfile into independent
frontend/backend pipelines.
