# Project 4 — GitOps with Argo CD

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch continues from `project-03-cicd-helm-microservices` and
replaces Jenkins calling `helm upgrade` directly with Argo CD watching
this Git repository. Also adds security scanning (OWASP Dependency Check,
Trivy, optional Docker Scout) to both pipelines. **No application code
changed.**

```
Git -> Jenkins -> Build -> Test -> Scan -> Push Image
    -> Update Helm values -> Git Commit -> Argo CD Sync -> Deploy
```

## What you'll learn

GitOps principles (desired state, drift, self-healing, rollback via Git
history), Argo CD (Application, AppProject, sync policies), and dependency/
image vulnerability scanning as a CI gate.

## What's new in this branch

```
├── gitops/
│   ├── argocd/values.yaml            Helm values for installing Argo CD itself
│   ├── projects/enterprise-devops-project.yaml   Argo CD AppProject
│   └── applications/enterprise-app.yaml          Argo CD Application (the desired state)
├── helm/enterprise-app/values-images/
│   ├── backend.yaml                  Jenkins-managed, Argo CD-watched
│   └── frontend.yaml                 Jenkins-managed, Argo CD-watched
├── backend/Jenkinsfile               + OWASP Dependency Check, Trivy, Docker Scout, GitOps commit
├── frontend/Jenkinsfile              + npm audit, Trivy, Docker Scout, GitOps commit
├── backend/owasp-suppressions.xml    Documented false-positive suppressions only
├── architecture/pipeline-diagram.md  Full GitOps flow + self-healing loop diagrams
└── docs/                             01-Prerequisites through 09-Interview-Questions, scoped to this project

(removed from both Jenkinsfiles: AWS credentials, kubectl/helm deploy stages -
 Jenkins no longer has cluster access at all)
```

## Quick start

1. Already have the EKS cluster + Helm chart working from Project 3? Good
   — infrastructure and the chart's shape are unchanged.
2. `./scripts/argocd-install.sh` then `./scripts/argocd-bootstrap.sh`
3. Create secrets per [`helm/enterprise-app/README.md`](helm/enterprise-app/README.md)
   (same as Project 3)
4. `jenkins/README.md` → update both pipeline jobs (steps 7-12 are new vs.
   Project 3)
5. Push a change, watch Jenkins stop at "commit to Git," then watch Argo
   CD pick it up

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md).
Try the self-healing demo:
[`docs/04-Step-by-Step.md`](docs/04-Step-by-Step.md).

## Next branch

`project-05-logging-elk` adds centralized logging — a new Helm subchart
and Argo CD Application, deployed the same GitOps way this project
established.

```bash
git checkout project-05-logging-elk
```
