# Architecture — Project 6: Monitoring (Prometheus & Grafana)

This project adds a third, independent Argo CD-managed Helm release —
`monitoring-stack` — alongside `enterprise-app` (Projects 2-4) and
`elk-stack` (Project 5). Where Project 5 gave you logs (discrete events,
searched/read one at a time), this project gives you metrics (numeric
time series, aggregated and alerted on) — a genuinely different
observability signal, not a duplicate of the same data in a different UI.

See [`metrics-flow.md`](./metrics-flow.md) for the full pipeline and
alert-routing diagrams.

## What's new vs. project-05-logging-elk

| Added | Purpose |
|---|---|
| `monitoring/monitoring-stack/` (prometheus, alertmanager, grafana, node-exporter, kube-state-metrics subcharts) | The metrics pipeline itself |
| `gitops/applications/monitoring-stack.yaml` | Independent Argo CD Application, third one alongside `enterprise-app` and `logging-stack` |
| `prometheus.io/scrape` annotations on `helm/enterprise-app/charts/backend/templates/deployment.yaml` | Lets Prometheus auto-discover the backend without any change to `monitoring-stack` itself |

No backend code changes this project — the JVM/HTTP metrics Grafana's
Application dashboard queries (`http_server_requests_seconds_*`,
`jvm_memory_used_bytes`, `hikaricp_connections_active`, etc.) are already
exposed by `spring-boot-starter-actuator` +
`micrometer-registry-prometheus`, both present since `main`. Project 6
is purely additive infrastructure, same as Project 5's `elk-stack` was.

## Why no Prometheus Operator / CRDs

`ServiceMonitor` and `PrometheusRule` custom resources are the
mainstream production pattern, and worth knowing exist (see
`docs/08-Assignments.md` for migrating to them as an exercise) — but they
add a layer of indirection (a CRD that gets reconciled into a config file
you never directly see) that works against this repo's teaching goal of
"read the actual scrape config and alert rule, not an abstraction over
one." `monitoring/monitoring-stack/charts/prometheus/templates/configmap.yaml`
and `configmap-rules.yaml` are the complete, literal Prometheus
configuration — nothing generates them.

## Why three separate Argo CD Applications, still

Same reasoning established in Project 5 for `logging-stack`: different
lifecycle, different namespace, different `selfHeal` risk profile
(Prometheus/Alertmanager/Grafana all hold persistent volumes). See that
project's `architecture/README.md` history for the original argument —
it applies identically here.

## Next branch

Later projects (`project-07-security`, `project-08-service-mesh-istio`,
`project-09-observability`, `project-10-production`) extend this same
pattern — each a self-contained branch adding one more production
capability on top of what Projects 1-6 established.
