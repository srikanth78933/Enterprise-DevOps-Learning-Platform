# Project 6 — Monitoring (Prometheus & Grafana)

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch continues from `project-05-logging-elk` and adds
metrics-based observability: Prometheus, Alertmanager, Grafana,
node-exporter, and kube-state-metrics, deployed as a third independent
Argo CD-managed Helm release. **No backend code changes** — the JVM/HTTP
metrics this project visualizes have been exposed since `main` via
`spring-boot-starter-actuator` + `micrometer-registry-prometheus`.

```
node-exporter, kube-state-metrics, backend (actuator/prometheus)
  -> Prometheus (scrape + evaluate alert rules)
  -> Alertmanager (route/dedupe alerts)
  -> Grafana (dashboards, queries Prometheus)
```

## What you'll learn

Application metrics vs. cluster/node/pod metrics, CPU/memory/restart-count/
latency/availability as concrete PromQL queries, and how to design alerts
(and alert routing) around them — no Prometheus Operator/CRDs, every
scrape target and alert rule is a plain YAML file.

## What's new in this branch

```
├── monitoring/monitoring-stack/         Umbrella chart
│   └── charts/
│       ├── prometheus/                    Scrape config, 6 alert rules, RBAC, PVC
│       ├── alertmanager/                  Routing (no-op by default, optional Slack)
│       ├── grafana/                       3 dashboards, Ingress+TLS
│       ├── node-exporter/                 DaemonSet, host metrics
│       └── kube-state-metrics/            K8s object state as metrics
├── gitops/applications/monitoring-stack.yaml   Third independent Argo CD Application
├── architecture/metrics-flow.md          Full pipeline + alert-routing diagrams
└── scripts/
    ├── grafana-port-forward.sh / prometheus-port-forward.sh
    ├── generate-load.sh                  Trigger HPA + CPU/memory alert conditions
    └── check-alerts.sh                   Query Prometheus's API for firing alerts
```

One small addition to `helm/enterprise-app/`: `prometheus.io/scrape`
annotations on the backend's pod template, so Prometheus auto-discovers
it — no `monitoring-stack` change needed to add or remove scrape targets
from the application side.

## Alerts configured out of the box

`HighCPUUsage`, `HighMemoryUsage` (>80% of container limits),
`PodCrashLooping`, `KubernetesImagePullBackOff`, `NodeDiskFull` (<10%
free), `NodeDown`. All visible in the Alertmanager UI immediately; Slack
routing is opt-in (see `docs/08-Assignments.md`).

## Quick start

1. `kubectl create secret generic grafana-admin ...` (see
   `monitoring/monitoring-stack/README.md`)
2. `./scripts/generate-self-signed-tls.sh grafana.enterprise-devops.example.com grafana-tls monitoring`
3. `kubectl apply -f gitops/applications/monitoring-stack.yaml`
4. `./scripts/grafana-port-forward.sh` then open http://localhost:3000
5. `./scripts/generate-load.sh` to make the dashboards (and maybe the
   alerts) move

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md).

## Next branches

Later projects (`project-07-security`, `project-08-service-mesh-istio`,
`project-09-observability`, `project-10-production`) will extend this
same pattern with one more production capability each.
