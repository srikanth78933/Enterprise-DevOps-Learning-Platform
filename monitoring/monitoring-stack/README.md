# monitoring-stack — Helm Umbrella Chart

Observability for the platform: Prometheus, Alertmanager, Grafana,
node-exporter, and kube-state-metrics. Deployed by Argo CD as its own
release (`monitoring-stack`) in the `monitoring` namespace — same pattern
as `logging/elk-stack`, independent of `enterprise-app`.

No Prometheus Operator, no CRDs (`ServiceMonitor`, `PrometheusRule`).
Scrape targets are discovered via plain Kubernetes annotation-based
service discovery (`prometheus.io/scrape` on pod templates — see
`helm/enterprise-app/charts/backend/templates/deployment.yaml`), and alert
rules are a mounted ConfigMap file. This is the original, still fully
supported Prometheus configuration style that predates the Operator —
chosen here so every scrape target and alert rule is a plain YAML file you
can read top to bottom, not a CRD abstraction layer on top of one.

## Structure

```
monitoring-stack/
├── Chart.yaml
├── values.yaml                Umbrella defaults
├── templates/namespace.yaml   Creates the `monitoring` namespace
└── charts/
    ├── prometheus/              Deployment+PVC, scrape config, alert rules, RBAC
    ├── alertmanager/            Deployment+PVC, routing config (no-op by default)
    ├── grafana/                 Deployment+PVC, Ingress+TLS, 3 provisioned dashboards
    ├── node-exporter/           DaemonSet - host CPU/memory/disk/network metrics
    └── kube-state-metrics/      Deployment+RBAC - Kubernetes object state as metrics
```

## Metrics flow

```
node-exporter (DaemonSet)        \
kube-state-metrics (Deployment)   >-- scraped by --> Prometheus --> Alertmanager (alerts)
backend pods (actuator/prometheus)/                       |
                                                            v
                                                         Grafana (dashboards, queries Prometheus)
```

Full diagram: [`/architecture/metrics-flow.md`](../../architecture/metrics-flow.md).

## Secrets — create before first install

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic grafana-admin -n monitoring \
  --from-literal=GF_SECURITY_ADMIN_USER=admin \
  --from-literal=GF_SECURITY_ADMIN_PASSWORD='<strong-password>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

TLS for Grafana's Ingress: same self-signed approach as Kibana (Project 5)
— `./scripts/generate-self-signed-tls.sh grafana.enterprise-devops.example.com grafana-tls monitoring`.

## Install (via Argo CD, not directly)

See `gitops/applications/monitoring-stack.yaml`. For local chart
development only:

```bash
helm lint monitoring/monitoring-stack
helm template monitoring-stack monitoring/monitoring-stack -n monitoring
```

## Alerts configured out of the box

See `charts/prometheus/templates/configmap-rules.yaml`:
`HighCPUUsage`, `HighMemoryUsage`, `PodCrashLooping`,
`KubernetesImagePullBackOff`, `NodeDiskFull`, `NodeDown` — all scoped to
the `enterprise-devops` namespace except the node-level ones. They route
to Alertmanager's `default` (no-op, UI-visible-only) receiver unless you
enable Slack — see `docs/08-Assignments.md`.
