# Step-by-Step Walkthrough — Project 6: Monitoring (Prometheus & Grafana)

## 1. Explore each dashboard once with no load

Open Grafana, visit all three dashboards with the cluster idle. Get a
feel for baseline numbers (idle CPU%, request rate near zero, JVM heap at
rest) before you generate load — you need a "normal" to compare "abnormal"
against.

## 2. Generate load and watch the Application dashboard react live

```bash
./scripts/generate-load.sh 300 20
```

While it runs, watch the Application dashboard's HTTP Request Rate and
p95 Latency panels update in near-real-time (Grafana's default refresh
matches Prometheus's 30s scrape interval).

## 3. Try to trip HighCPUUsage on purpose

The default backend CPU limit (500m) may or may not saturate under
`generate-load.sh`'s traffic — simple CRUD endpoints aren't very CPU-heavy.
For a reliable demo, temporarily lower the limit (same pattern Project 5
used for the slow-request threshold):

```bash
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values --set backend.resources.limits.cpu=50m

./scripts/generate-load.sh 300 20
```

Watch it fire in Prometheus (http://localhost:9090/alerts) — `Pending`
for the first 5 minutes (the `for: 5m` clause), then `Firing`. Check
Alertmanager too — it should show the same alert, grouped.

**Revert this change via Git afterward**, not another direct `helm
upgrade` — see Project 4's GitOps flow for why leaving it as
uncommitted drift matters once `enterprise-app`'s `selfHeal: true` is
active.

## 4. Trigger PodCrashLooping on purpose

```bash
kubectl exec -n enterprise-devops deploy/backend -- sh -c "kill 1"
```

Do this 4 times in a row within 15 minutes (or just wait for it to
restart and crash repeatedly if step 3's CPU limit is still in effect —
OOMKilled counts as a restart too). Watch `PodCrashLooping` fire.

## 5. Trigger KubernetesImagePullBackOff on purpose

```bash
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values --set backend.image.tag=this-tag-does-not-exist
```

Watch the alert fire within 2 minutes, then revert (again, via Git, not
another direct `helm upgrade`).

## 6. Check the Alertmanager UI's grouping and inhibition

If you triggered both `PodCrashLooping` and `HighCPUUsage`/`HighMemoryUsage`
for the same pod around the same time, confirm the resource alerts got
inhibited (see the `inhibit_rules` in
`monitoring/monitoring-stack/charts/alertmanager/templates/configmap.yaml`)
— Alertmanager's UI shows inhibited alerts distinctly from actively
firing ones.

## Next

Continue to [05-Flow.md](./05-Flow.md).
