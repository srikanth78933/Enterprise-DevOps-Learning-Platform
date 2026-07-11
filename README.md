# Project 5 — Centralized Logging (ELK)

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch continues from `project-04-gitops-argocd` and adds centralized
logging: Elasticsearch, Logstash, Filebeat, and Kibana, deployed as an
independent Argo CD-managed Helm release. **This is the first project
branch with real backend code changes** — logging instrumentation, not
business logic.

```
Application (stdout, JSON) -> Filebeat -> Logstash -> Elasticsearch -> Kibana
```

## What you'll learn

The ELK stack's roles (shipper, pipeline, store, UI), StatefulSets +
`volumeClaimTemplates`, DaemonSets, Kubernetes RBAC for a log shipper,
StorageClasses, resource limits at logging-infrastructure scale, Ingress
with TLS, and how to design application logging (structured JSON,
request/slow-request/exception categorization) so a log pipeline is
actually useful.

## What's new in this branch

```
├── backend/src/main/resources/logback-spring.xml   JSON logs (prod) vs plain (dev)
├── backend/.../filter/RequestLoggingFilter.java     Request + slow-request logging
├── backend/.../exception/GlobalExceptionHandler.java  Now actually logs (WARN vs ERROR)
├── logging/elk-stack/                Umbrella chart: elasticsearch, logstash, filebeat, kibana
├── gitops/applications/logging-stack.yaml   Independent Argo CD Application
├── architecture/log-flow.md          Full pipeline diagram + log-category reference
├── scripts/
│   ├── generate-self-signed-tls.sh   TLS for Kibana's Ingress
│   ├── kibana-port-forward.sh        Quick local access
│   ├── tail-logs.sh                  Raw kubectl logs, bypassing ELK (for comparison)
│   └── generate-test-traffic.sh      Produces sample logs across all 5 categories
└── docs/                             01-Prerequisites through 09-Interview-Questions, scoped to this project
```

No changes to `helm/enterprise-app/`, either Jenkinsfile, or `terraform/`
— this project is additive.

## Quick start

1. `./scripts/generate-self-signed-tls.sh kibana.enterprise-devops.example.com kibana-tls logging`
2. Update `repoURL` in `gitops/applications/logging-stack.yaml` to your fork
3. `kubectl apply -f gitops/applications/logging-stack.yaml`
4. `./scripts/kibana-port-forward.sh` then open http://localhost:5601
5. `./scripts/generate-test-traffic.sh` to produce sample logs, then explore
   Discover in Kibana

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md).

## Next branch

`project-06-monitoring-prometheus-grafana` adds metrics-based observability
(Prometheus, Alertmanager, Grafana) alongside the logging this project
established.

```bash
git checkout project-06-monitoring-prometheus-grafana
```
