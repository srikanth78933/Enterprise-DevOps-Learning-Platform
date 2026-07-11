# Enterprise DevOps Learning Platform

A single, evolving application used to teach DevOps from first principles to
production-grade practice. One codebase, one set of features — Employee,
Department, Project, Health, About — carried across seven branches, each
adding one real layer of enterprise DevOps tooling on top of the last.

> Students don't rebuild the app in every project. They rebuild the
> **pipeline, infrastructure, and operations** around the same app, so the
> evolution of the platform — not the business logic — is what's being
> learned.

## How this repository is organized

```
Enterprise-DevOps-Learning-Platform/
├── backend/         Spring Boot 3 (Java 21) REST API
├── frontend/        React SPA
├── helm/            Helm charts (from project-03 onward)
├── kubernetes/       Raw K8s manifests (from project-02 onward)
├── terraform/       AWS infrastructure as code (from project-02 onward)
├── monitoring/       Prometheus / Grafana / Alertmanager (project-06)
├── logging/         ELK / Filebeat stack (project-05)
├── docs/            Numbered guides: prerequisites → interview questions
├── diagrams/        Mermaid architecture diagrams
├── scripts/          Local dev + operational shell scripts
├── docker/          Dockerfiles + local docker-compose stack
├── jenkins/         Jenkinsfiles (from project-01 onward)
└── LICENSE
```

## Branch strategy

Each branch is a complete, working snapshot — check one out and you get a
fully functional stage of the platform, not a partial diff.

| Branch | What it adds |
|---|---|
| `main` | The base application: Spring Boot + React + MySQL, CRUD only, no pipeline |
| `project-01-ci-pipeline` | Jenkins CI: build, unit test, SonarQube quality gate, Docker image, push to Docker Hub |
| `project-02-cd-eks` | Terraform-provisioned AWS EKS cluster, Kubernetes Deployments/Services/Ingress/HPA, CD stage added to the pipeline |
| `project-03-cicd-helm-microservices` | Frontend and backend get independent CI pipelines; deployment moves to a Helm umbrella chart |
| `project-04-gitops-argocd` | `kubectl apply` is replaced by Argo CD; Trivy/OWASP/Docker Scout scanning added to CI |
| `project-05-logging-elk` | Centralized logging: Filebeat → Logstash → Elasticsearch → Kibana, deployed with StatefulSets and persistent storage |
| `project-06-monitoring-prometheus-grafana` | Full observability: Prometheus, Alertmanager, Grafana dashboards, alert rules |

```bash
git clone <this-repo-url> Enterprise-DevOps-Learning-Platform
cd Enterprise-DevOps-Learning-Platform

git checkout main                                # start here
git checkout project-01-ci-pipeline               # then here
git checkout project-02-cd-eks                    # ...and so on
```

Later projects (`project-07-security`,
`project-08-service-mesh-istio`, `project-09-observability`,
`project-10-production`) extend the same pattern and will be added as
follow-on branches.

## The application

Deliberately simple so the DevOps lessons aren't competing with business
logic for your attention.

```
React (frontend) → Spring Boot (backend) → MySQL
```

Modules: **Employee**, **Department**, **Project** (all full CRUD),
**Health**, **About**. No authentication in `main` — see
[`docs/02-Architecture.md`](docs/02-Architecture.md) for why, and how later
projects introduce security concerns without touching this decision
prematurely.

Full architecture diagrams:
[`diagrams/application-architecture.md`](diagrams/application-architecture.md).

## Quick start (main branch)

```bash
docker compose -f docker/docker-compose.yml up --build
```

Then open http://localhost:3000. Full instructions, including running the
backend/frontend natively for development, are in
[`docs/03-Installation.md`](docs/03-Installation.md).

## Documentation structure

Every branch ships the same numbered doc set under `docs/`, scoped to what
that branch adds:

1. `01-Prerequisites.md`
2. `02-Architecture.md`
3. `03-Installation.md`
4. `04-Step-by-Step.md`
5. `05-Flow.md`
6. `06-Troubleshooting.md`
7. `07-Cleanup.md`
8. `08-Assignments.md`
9. `09-Interview-Questions.md`

## Technology stack (across all branches)

**Application:** Java 21, Spring Boot, Maven, JUnit, Mockito, React, MySQL
**CI/CD:** Jenkins, SonarQube, Trivy, OWASP Dependency Check, Docker, Docker Hub
**Infrastructure:** Terraform, AWS (EKS, VPC, IAM), Kubernetes, Helm, NGINX Ingress
**GitOps:** Argo CD
**Observability:** Prometheus, Alertmanager, Grafana
**Logging:** Elasticsearch, Logstash, Filebeat, Kibana

## License

[MIT](./LICENSE)
