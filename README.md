# Project 2 — CD to AWS EKS

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch continues from `project-01-ci-pipeline` and deploys the application
onto a real, Terraform-provisioned AWS EKS cluster. **No application code
changed** — everything here is new infrastructure and deployment automation.

```
Git → Jenkins → Build → Test → Sonar → Docker → Push Image → Deploy to EKS → Verify
```

## What you'll learn

AWS (VPC, IAM, EKS), Terraform modules, `kubectl`, Namespaces, ConfigMaps,
Secrets, Deployments, Services, Ingress, HorizontalPodAutoscaler, and
VerticalPodAutoscaler.

## What's new in this branch

```
├── terraform/                       VPC + IAM + EKS, as reusable modules
│   ├── modules/{vpc,iam,eks}/
│   └── (root: main.tf, variables.tf, outputs.tf, backend.tf, ...)
├── kubernetes/                      Namespace, Config, Secrets template, Deployments, HPA, VPA, Ingress
├── docker/frontend-ci.Dockerfile    Packages the Jenkins-built frontend bundle
├── Jenkinsfile                      Extended: Frontend Build, dual Docker Build/Push, Deploy to EKS, Verify
├── architecture/
│   ├── aws-infrastructure.md        VPC/EKS topology diagram
│   └── pipeline-diagram.md          Updated end-to-end pipeline diagram
├── scripts/
│   ├── terraform-init-apply.sh      Provision the cluster without Jenkins
│   ├── configure-kubeconfig.sh      Point local kubectl at the cluster
│   ├── deploy-to-eks.sh             Local equivalent of the Deploy stage
│   ├── verify-deployment.sh         Local equivalent of the Verify stage
│   └── terraform-destroy.sh         Safe teardown (checks for orphaned load balancers first)
└── docs/                            01-Prerequisites through 09-Interview-Questions, scoped to this project
```

## Quick start

1. `terraform/README.md` → provision the cluster
2. `jenkins/README.md` → extend your Project 1 Jenkins setup with AWS
   credentials and `kubectl`/`aws` CLI on the agent
3. Point the Jenkins pipeline job at this branch and run it

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md).

## Cost warning

This provisions real, billable AWS resources (EKS control plane, EC2 worker
nodes, NAT Gateway, and — once you install an Ingress controller — a Load
Balancer). Run `./scripts/terraform-destroy.sh` as soon as you're done —
see [`docs/07-Cleanup.md`](docs/07-Cleanup.md) for the safe teardown order.

## Next branch

`project-03-cicd-helm-microservices` replaces these raw manifests with a
Helm umbrella chart and splits this Jenkinsfile into independent
frontend/backend pipelines.

```bash
git checkout project-03-cicd-helm-microservices
```
