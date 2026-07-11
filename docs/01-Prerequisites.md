# Prerequisites — Project 2: CD to AWS EKS

Builds on Project 1's prerequisites (Jenkins, SonarQube, Docker Hub — see
`docs/01-Prerequisites.md` on the `project-01-ci-pipeline` branch).
Additionally:

| Tool | Minimum Version | Check |
|---|---|---|
| AWS CLI | v2 | `aws --version` |
| kubectl | 1.28+ | `kubectl version --client` |
| An existing AWS EKS cluster (provisioned outside this repo) | — | — |

## Accounts and access you need before starting

1. **An already-running EKS cluster** — this project deploys onto it, it
   doesn't provision one. You need its cluster name and region.
2. **AWS credentials configured locally**, for an IAM identity with
   `eks:DescribeCluster` permission and a mapping in the cluster's
   `aws-auth` ConfigMap (or equivalent EKS access entry) granting `kubectl`
   access: `aws configure` (access key + secret + default region), or an
   assumed role via `aws sso login` / `aws sts assume-role`.
3. Everything from Project 1: Docker Hub account, Jenkins, SonarQube.

## Cost awareness

The cluster itself is billed regardless of this pipeline (EKS control
plane $0.10/hr, plus whatever worker nodes are running). Deploying this
project's workloads and, if you install one, an Ingress Controller's Load
Balancer adds further hourly cost on top. Not free-tier eligible — check
with whoever manages the cluster if you're cost-sensitive.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
