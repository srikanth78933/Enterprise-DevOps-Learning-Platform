# Project 3 — CI/CD with Helm & Independent Microservice Pipelines

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch continues from `project-02-cd-eks`, replaces the raw
Kubernetes manifests with a Helm umbrella chart, and splits the single
Jenkinsfile into two fully independent pipelines. **No application code
changed.**

```
Frontend Pipeline: Checkout -> Install & Test -> Build -> Docker Build -> Push -> Helm Upgrade -> Verify
Backend  Pipeline: Checkout -> Maven Build -> Test -> Sonar -> Quality Gate -> Package -> Docker Build -> Push -> Helm Upgrade -> Verify
```

## What you'll learn

Helm (charts, values precedence, templates), ConfigMaps/Secrets via Helm's
`existingSecret` pattern, Ingress through a chart, HPA via chart values,
and how to structure CI/CD so two services deploy independently without
stepping on each other.

## What's new in this branch

```
├── helm/enterprise-app/             Umbrella chart: frontend + backend + mysql subcharts
│   ├── Chart.yaml, values.yaml, values-prod.yaml.example
│   ├── templates/ingress.yaml       Routes /api -> backend, / -> frontend
│   └── charts/{frontend,backend,mysql}/
├── backend/Jenkinsfile              Independent backend pipeline (was: root Jenkinsfile)
├── frontend/Jenkinsfile             Independent frontend pipeline (new)
├── architecture/
│   ├── helm-chart-structure.md      Chart layout + values precedence diagram
│   └── pipeline-diagram.md          Both pipelines + why splitting them matters
├── scripts/
│   ├── helm-install.sh              First-time install
│   ├── helm-upgrade-backend.sh      Local equivalent of backend/Jenkinsfile's deploy step
│   ├── helm-upgrade-frontend.sh     Local equivalent of frontend/Jenkinsfile's deploy step
│   ├── verify-backend.sh / verify-frontend.sh
│   └── helm-uninstall.sh
└── docs/                            01-Prerequisites through 09-Interview-Questions, scoped to this project

(removed: kubernetes/ raw manifests, root Jenkinsfile - both superseded above)
```

## Quick start

1. Already have the EKS cluster from Project 2? Skip to step 2. Otherwise:
   `terraform/README.md` first.
2. `helm/enterprise-app/README.md` → create secrets, install the chart once
3. `jenkins/README.md` → set up two pipeline jobs (steps 7 and 11 are new
   vs. Project 2)
4. Push a backend-only or frontend-only change and watch only the relevant
   pipeline run

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md).

## Next branch

`project-04-gitops-argocd` replaces Jenkins calling `helm upgrade`
directly with Argo CD watching a Git repository, and adds Trivy, OWASP
Dependency Check, and Docker Scout scanning to both pipelines.

```bash
git checkout project-04-gitops-argocd
```
