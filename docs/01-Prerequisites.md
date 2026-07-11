# Prerequisites — Project 2: CD to AWS EKS

Builds on Project 1's prerequisites (Jenkins, SonarQube, Docker Hub — see
`docs/01-Prerequisites.md` on the `project-01-ci-pipeline` branch).
Additionally:

| Tool | Minimum Version | Check |
|---|---|---|
| AWS CLI | v2 | `aws --version` |
| kubectl | 1.28+ | `kubectl version --client` |
| Terraform | 1.7+ | `terraform -version` |
| An AWS account with billing enabled | — | — |

## Accounts and access you need before starting

1. **AWS account** with permissions to create VPCs, IAM roles, and EKS
   clusters (an `AdministratorAccess` policy is simplest for learning; a
   real org would scope this down significantly).
2. **AWS credentials configured locally**: `aws configure` (access key +
   secret + default region), or an assumed role via `aws sso login` /
   `aws sts assume-role`.
3. Everything from Project 1: Docker Hub account, Jenkins, SonarQube.

## Cost awareness

Running through this project's `terraform apply` → `terraform destroy`
cycle a few times while learning costs a few dollars (EKS control plane
$0.10/hr, 2× t3.medium nodes, one NAT Gateway, briefly a Load Balancer).
Not free-tier eligible. Set a AWS Budget alert before starting if you're
cost-sensitive.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
