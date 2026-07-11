# Interview Questions — Project 6: Monitoring (Prometheus & Grafana)

## Prometheus fundamentals

1. What's the difference between Prometheus's pull model (scraping
   targets) and a push-based metrics system? What operational problem
   does pull solve that becomes relevant specifically in a Kubernetes
   environment with pods constantly being created/destroyed?
2. Explain what `rate()` does to a counter metric and why you almost never
   query a raw counter (like `container_cpu_usage_seconds_total`)
   directly without it.
3. Walk through the `for:` clause on an alert rule — what problem does it
   solve, and what would `HighCPUUsage` look like in practice (how often
   would it fire) if `for:` were removed entirely?

## This project's scrape configuration

4. Explain each `relabel_configs` step in the `kubernetes-pods` job
   (`monitoring/monitoring-stack/charts/prometheus/templates/configmap.yaml`)
   — what does each one actually do to the discovered target before
   Prometheus scrapes it?
5. Why does the `kubernetes-nodes-cadvisor` job need `bearer_token_file`
   and a ClusterRole with `nonResourceURLs`, while the `node-exporter` and
   `kube-state-metrics` jobs need neither?
6. What's the practical difference between annotation-based service
   discovery (this project) and a `ServiceMonitor` CRD (Prometheus
   Operator)? What does the Operator actually automate that you're doing
   by hand here?

## Alerting

7. Why does `PodCrashLooping` use `increase(...)[15m]) > 3` (a count over
   a window) rather than a simple threshold on the restart count itself?
8. Explain what the `inhibit_rules` in Alertmanager's config do, using the
   specific example in this project (`PodCrashLooping` suppressing
   `HighCPUUsage`/`HighMemoryUsage` for the same pod). What's the failure
   mode if inhibition weren't configured?
9. Why is the default Alertmanager receiver a no-op (`default`, UI-only)
   rather than, say, always emailing someone? What's the actual cost of
   over-alerting that this default avoids?

## Grafana & metrics design

10. Every panel in this project's dashboards queries Prometheus live at
    render/refresh time. What are the tradeoffs of that versus a system
    where Grafana caches or pre-aggregates data?
11. Why does the Application dashboard use `histogram_quantile()` for p95
    latency instead of just averaging `http_server_requests_seconds_sum /
    http_server_requests_seconds_count`? What does averaging hide that
    percentiles reveal?
12. This project exposes JVM metrics (heap, threads, GC pause time)
    alongside HTTP metrics on the same dashboard. Why might a JVM-specific
    metric (like GC pause time) be a leading indicator for an HTTP-level
    symptom (like latency) that hasn't shown up yet?
