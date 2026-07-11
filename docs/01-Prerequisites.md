# Prerequisites — Project 6: Monitoring (Prometheus & Grafana)

Builds on Project 5's prerequisites (Argo CD, a running EKS cluster with
the `elk-stack` release already familiar — see
`docs/01-Prerequisites.md` on `project-05-logging-elk`). No new CLI
tools required.

## Resource capacity check

Combined resource *requests* on top of `enterprise-app` and `elk-stack`:

| Component | CPU request | Memory request |
|---|---|---|
| Prometheus | 250m | 512Mi |
| Alertmanager | 100m | 128Mi |
| Grafana | 100m | 256Mi |
| node-exporter (per node) | 50m | 64Mi |
| kube-state-metrics | 100m | 128Mi |

If you're running `elk-stack` and `monitoring-stack` on the same small
node group simultaneously, check capacity the same way Project 5 told you
to:

```bash
kubectl describe nodes | grep -A5 "Allocated resources"
```

## New concepts this project assumes no prior exposure to

- **Metrics vs. logs**: a log is a discrete event ("this request
  happened, here's what it was"); a metric is a numeric time series
  ("this value, sampled every 30 seconds, forever"). You query logs for a
  specific event; you query metrics to see trends, rates, and thresholds.
  Neither replaces the other — Project 5 and this project are genuinely
  complementary, not two ways of doing the same thing.
- **PromQL**: Prometheus's query language. `rate()`, `sum by (...)`, and
  `histogram_quantile()` show up throughout this project's alert rules
  and dashboards — if you've never seen PromQL, read a few of the alert
  expressions in `monitoring/monitoring-stack/charts/prometheus/templates/configmap-rules.yaml`
  before diving into `docs/04-Step-by-Step.md`.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
