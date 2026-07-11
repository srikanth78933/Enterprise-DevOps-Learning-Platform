# Architecture — Project 2: CD to AWS EKS

Full detail lives in [`/architecture`](../architecture/README.md) — this
page is the short version.

## Infrastructure layer

There's no Terraform in this branch — the VPC, IAM roles, and EKS cluster
(control plane + managed node group) already exist, provisioned and
managed outside this repo. This project only needs `kubectl`/`aws` CLI
access to that cluster (see `docs/01-Prerequisites.md`); it doesn't
provision or own the infrastructure underneath it.

## Application layer (unchanged code, new deployment target)

Backend only — `frontend/` source was removed from this branch entirely;
see `architecture/README.md` for why.

```
kubernetes/namespace.yaml           → enterprise-devops namespace
kubernetes/configmap.yaml           → non-secret backend + MySQL config
kubernetes/secret.example.yaml      → template only, real secrets created imperatively
kubernetes/mysql-deployment.yaml    → single-replica MySQL + PVC
kubernetes/backend-deployment.yaml  → 2 replicas, Actuator readiness/liveness probes
kubernetes/backend-hpa.yaml         → scales 2-6 replicas on CPU/memory
kubernetes/backend-vpa.yaml         → recommendation-only, optional
kubernetes/ingress.yaml             → routes all paths to backend
```

## Pipeline layer

The Jenkinsfile from Project 1 gains two stages: **Deploy to EKS** and
**Verify** (Docker Build/Push Docker Image already existed in Project 1).
Full diagram:
[`architecture/pipeline-diagram.md`](../architecture/pipeline-diagram.md).

## Next

Continue to [03-Installation.md](./03-Installation.md).
