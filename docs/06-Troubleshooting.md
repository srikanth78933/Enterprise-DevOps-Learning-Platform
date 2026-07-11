# Troubleshooting — Project 6: Monitoring (Prometheus & Grafana)

## A scrape target shows `DOWN` on http://localhost:9090/targets

Click the target for the actual error. Common causes:

- **`kubernetes-pods` / backend**: the pod doesn't have the
  `prometheus.io/scrape` annotation — confirm `kubectl get pod <backend-pod>
  -n enterprise-devops -o jsonpath='{.metadata.annotations}'` shows it. If
  missing, `enterprise-app`'s release is running an older chart version
  before this project added it — trigger a sync.
- **`kubernetes-nodes-cadvisor`**: usually an RBAC issue — confirm
  `monitoring/monitoring-stack/charts/prometheus/templates/rbac.yaml`'s
  ClusterRole actually synced (`kubectl get clusterrole prometheus`) and
  that `nodes/proxy` + the `/metrics/cadvisor` nonResourceURL are both
  present.
- **`node-exporter` / `kube-state-metrics`**: confirm the Service name
  matches exactly what Prometheus's static target references (`kubectl
  get svc -n monitoring`) — both are hardcoded, not values-driven, per the
  comment in `configmap.yaml`.

## Alert never fires even though the condition looks true

Check the raw expression yourself at http://localhost:9090/graph — paste
the alert's `expr` in directly. If it returns no data, the underlying
metric name might not exist yet (a metric only appears in Prometheus
after at least one successful scrape that produced it) or a label
selector (like `namespace="enterprise-devops"`) doesn't match what's
actually being scraped.

## Grafana dashboards show "No data" on every panel

Confirm the Prometheus datasource is actually reachable: Grafana →
Connections → Data sources → Prometheus → Test. If that fails, check
`grafana.prometheus.host` in
`monitoring/monitoring-stack/values.yaml` matches the actual Prometheus
Service name (`prometheus`, fixed — see that chart's `_helpers.tpl`).

## Grafana pod `CrashLoopBackOff` with a permissions error on `/var/lib/grafana`

The `fsGroup: 472` securityContext in
`charts/grafana/templates/deployment.yaml` should prevent this on a fresh
PVC — if you're reusing a PVC from before this was added, either delete
it (losing dashboard customizations, not metric data) or manually `chown`
via a one-off debug pod.

## Alertmanager shows alerts but Slack never gets a message

Confirm `alertmanager.slack.enabled: true` was actually set (it's `false`
by default — see `docs/08-Assignments.md`), and that the
`alertmanager-slack` Secret's `slack-webhook-url` key contains a real,
currently-valid Slack incoming webhook URL (regenerate it if the workspace
integration was ever reset).

## `generate-load.sh` doesn't move the needle on CPU/memory panels

The backend's default resource limits may simply be generous enough that
this workload doesn't saturate them — see step 3 of
`docs/04-Step-by-Step.md` for temporarily lowering the limit for a
reliable demo.

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
