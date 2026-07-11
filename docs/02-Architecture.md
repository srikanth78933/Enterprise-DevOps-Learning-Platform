# Architecture — Project 2: CD to AWS EKS

Full detail lives in [`/architecture`](../architecture/README.md) — this
page is the short version.

## Infrastructure layers

```
terraform/modules/vpc/   → VPC, public/private subnets, IGW, NAT Gateway
terraform/modules/iam/   → EKS cluster role, node group role
terraform/modules/eks/   → EKS control plane, managed node group, OIDC provider
terraform/main.tf        → wires the three modules together
```

See [`architecture/aws-infrastructure.md`](../architecture/aws-infrastructure.md)
for the full topology diagram.

## Application layer (unchanged code, new deployment target)

```
kubernetes/namespace.yaml           → enterprise-devops namespace
kubernetes/configmap.yaml           → non-secret backend + MySQL config
kubernetes/secret.example.yaml      → template only, real secrets created imperatively
kubernetes/mysql-deployment.yaml    → single-replica MySQL + PVC
kubernetes/backend-deployment.yaml  → 2 replicas, Actuator readiness/liveness probes
kubernetes/backend-hpa.yaml         → scales 2-6 replicas on CPU/memory
kubernetes/backend-vpa.yaml         → recommendation-only, optional
kubernetes/frontend-deployment.yaml → 2 replicas, NGINX-served static build
kubernetes/ingress.yaml             → routes /api to backend, / to frontend
```

## Pipeline layer

The Jenkinsfile from Project 1 gains five stages: **Frontend Build**,
**Docker Build** (now parallel, backend + frontend), **Push Docker Images**
(x2), **Deploy to EKS**, **Verify**. Full diagram:
[`architecture/pipeline-diagram.md`](../architecture/pipeline-diagram.md).

## Next

Continue to [03-Installation.md](./03-Installation.md).
