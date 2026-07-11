# Architecture — Project 6: Monitoring (Prometheus & Grafana)

Full detail lives in [`/architecture`](../architecture/README.md) and
[`/architecture/metrics-flow.md`](../architecture/metrics-flow.md) — this
page is the short version.

## Three independent Argo CD Applications now

```
gitops/applications/enterprise-app.yaml    → helm/enterprise-app          → namespace: enterprise-devops
gitops/applications/logging-stack.yaml     → logging/elk-stack            → namespace: logging
gitops/applications/monitoring-stack.yaml  → monitoring/monitoring-stack  → namespace: monitoring
```

None depend on each other at the Kubernetes/Argo CD level.
`monitoring-stack` observes `enterprise-devops` (via scrape config scoped
to that namespace) purely as an application-layer concern, the same way
`logging-stack`'s Filebeat does.

## Monitoring chart layers

```
monitoring/monitoring-stack/charts/node-exporter/       → DaemonSet: host CPU/memory/disk/network
monitoring/monitoring-stack/charts/kube-state-metrics/  → Deployment+RBAC: K8s object state (pod status, restarts, replica counts)
monitoring/monitoring-stack/charts/prometheus/          → Deployment+PVC: scrapes both of the above + backend, evaluates alert rules
monitoring/monitoring-stack/charts/alertmanager/        → Deployment+PVC: routes/dedupes fired alerts
monitoring/monitoring-stack/charts/grafana/             → Deployment+PVC+Ingress: 3 dashboards, queries Prometheus
```

## Next

Continue to [03-Installation.md](./03-Installation.md).
