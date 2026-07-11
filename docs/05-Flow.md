# Metrics & Alert Flow — Project 6

Full diagram: [`/architecture/metrics-flow.md`](../architecture/metrics-flow.md).

## Scrape cycle (every 30s, per `global.scrape_interval`)

1. Prometheus's `kubernetes-pods` job re-runs pod discovery against the
   Kubernetes API (`role: pod`), filters to pods with
   `prometheus.io/scrape: "true"`, and scrapes each at the annotated path/port
2. The `kubernetes-nodes-cadvisor` job re-runs node discovery (`role:
   node`), and for each node, proxies through the API server to that
   node's kubelet `/metrics/cadvisor` endpoint
3. `node-exporter` and `kube-state-metrics` jobs hit their fixed Service
   targets directly
4. All scraped samples are written to Prometheus's local TSDB (the PVC)

## Alert evaluation cycle (every 30s, per `global.evaluation_interval`)

1. Every rule in `rules.yml` is evaluated against current TSDB data
2. If a rule's expression is true, the alert enters `Pending` state
3. If it's still true after the rule's `for:` duration, it transitions to
   `Firing` and gets pushed to Alertmanager
4. If the expression stops being true at any point before `for:` elapses,
   it resets to inactive — this is why `HighCPUUsage`'s `for: 5m` matters:
   a brief spike doesn't page anyone, only sustained load does

## Why `for:` durations differ per alert

| Alert | `for:` | Why |
|---|---|---|
| `HighCPUUsage`/`HighMemoryUsage` | 5m | Brief spikes are normal; only sustained pressure matters |
| `PodCrashLooping` | 5m | The `increase(...)[15m]) > 3` window already requires repeated failures; `for: 5m` avoids alerting on the very first restart |
| `KubernetesImagePullBackOff` | 2m | This is never transient/expected — alert fast |
| `NodeDiskFull` | 5m | Avoids flapping on momentary disk pressure from a burst write |
| `NodeDown` | 5m | Avoids alerting on a brief network blip between Prometheus and the node |

## Grafana's role — it doesn't store anything

Every panel in all three dashboards is a live PromQL query against
Prometheus, run each time the dashboard is viewed or auto-refreshes.
Grafana itself only persists dashboard *definitions* (in its own PVC) and
user/session state — deleting and reinstalling Grafana loses none of your
actual metric history, since that lives in Prometheus's PVC instead.

## Next

Continue to [06-Troubleshooting.md](./06-Troubleshooting.md).
