# Project 2 — CD to AWS EKS

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch continues from `project-01-ci-pipeline` and deploys the application
onto an existing AWS EKS cluster, provisioned and managed outside this repo.
**No application code changed** — everything here is new deployment
automation on top of that cluster.

```
Git → Jenkins → Build → Test → Sonar → Docker → Push Image → Deploy to EKS → Verify
```

## What you'll learn

AWS EKS, `kubectl`, Namespaces, ConfigMaps, Secrets, Deployments, Services,
Ingress, HorizontalPodAutoscaler, and VerticalPodAutoscaler.

## What's new in this branch

```
├── kubernetes/                      Namespace, Config, Secrets template, Backend Deployment, HPA, VPA, Ingress
├── Jenkinsfile                      Extended: Docker Build/Push, Deploy to EKS, Verify
├── architecture/
│   └── pipeline-diagram.md          Updated end-to-end pipeline diagram
├── scripts/
│   ├── configure-kubeconfig.sh      Point local kubectl at the existing cluster
│   ├── deploy-to-eks.sh             Local equivalent of the Deploy stage
│   └── verify-deployment.sh         Local equivalent of the Verify stage
└── docs/                            01-Prerequisites through 10-Deployment-Log, scoped to this project
```

Note: `frontend/` isn't deployed by this branch — see
[`architecture/README.md`](architecture/README.md#why-theres-no-frontend-deployment-here)
for why.

## Quick start

1. Confirm you have `kubectl`/`aws` CLI access to the existing EKS cluster
   (see `docs/01-Prerequisites.md`)
2. `jenkins/README.md` → extend your Project 1 Jenkins setup with AWS
   credentials and `kubectl`/`aws` CLI on the agent
3. Point the Jenkins pipeline job at this branch and run it

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md).

## Cost warning

This deploys onto real, billable AWS resources (EKS control plane, EC2
worker nodes, and — once you install an Ingress controller — a Load
Balancer). The cluster itself is managed outside this repo, but clean up
the Kubernetes-level resources you create (Ingress, LoadBalancer Services)
when done — see [`docs/07-Cleanup.md`](docs/07-Cleanup.md).

## Next branch

`project-03-cicd-helm-microservices` replaces these raw manifests with a
Helm umbrella chart and splits this Jenkinsfile into independent
frontend/backend pipelines.

```bash
git checkout project-03-cicd-helm-microservices
```
