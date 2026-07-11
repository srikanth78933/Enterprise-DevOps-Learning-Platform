# Student Assignments — Project 6: Monitoring (Prometheus & Grafana)

## Beginner

1. Enable Slack alerting: create a Slack incoming webhook, store it in the
   `alertmanager-slack` secret, set `alertmanager.slack.enabled: true`,
   and trigger a real alert (Step 3 or 5 of `docs/04-Step-by-Step.md`) to
   confirm a message actually arrives.
2. Add a fourth dashboard panel type to the Application dashboard: a
   `table` panel listing the top 5 slowest endpoints by p99 (not p95)
   latency over the last hour.

## Intermediate

3. Add a `RequestErrorRate` alert: fires when the ratio of 5xx responses
   to total requests exceeds 5% over 5 minutes, using
   `http_server_requests_seconds_count`. This is the "Availability" metric
   category the project's learning goals name, not yet covered by the six
   alerts already included.
4. The `NodeDown` alert only fires if node-exporter itself becomes
   unreachable. Add a genuinely different alert,
   `KubernetesNodeNotReady`, based on `kube_node_status_condition{condition="Ready",
   status="true"} == 0` from kube-state-metrics, and explain in your PR
   the actual difference between these two failure modes (a node can be
   `NotReady` in the Kubernetes API while its node-exporter is still
   perfectly reachable, or vice versa).
5. Add a Grafana alert-annotations overlay: configure Grafana to draw a
   vertical marker on the Application dashboard's timeseries panels
   whenever `HighCPUUsage` fires, so a latency spike and its cause are
   visible on the same graph without cross-referencing Alertmanager
   separately.

## Advanced

6. Migrate this project's plain-YAML Prometheus setup to the Prometheus
   Operator (`ServiceMonitor` + `PrometheusRule` CRDs). Install the
   operator, convert `configmap.yaml`'s scrape jobs into `ServiceMonitor`
   resources and `configmap-rules.yaml`'s alert groups into a
   `PrometheusRule`, and document exactly what got simpler and what got
   more opaque in the process — this project deliberately chose the
   plain-YAML approach; form your own opinion on the tradeoff with direct
   experience of both.
7. Add long-term metrics storage: Prometheus's local TSDB (this project)
   only retains `retention: 15d`. Research and implement (or at least
   design and document) a remote-write setup to a long-term store (Thanos,
   Cortex, or a managed option), and explain what query-time tradeoffs
   that introduces versus querying local Prometheus directly.

## Submission

Open a PR against `project-06-monitoring-prometheus-grafana`. Include a
screenshot of a firing alert in the Alertmanager UI and one dashboard
panel showing real (not idle) traffic data.
