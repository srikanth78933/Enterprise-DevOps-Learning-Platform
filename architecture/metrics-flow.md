# Metrics Flow — Project 6

```mermaid
flowchart LR
    subgraph Targets["Scrape Targets"]
        NE["node-exporter<br/>(DaemonSet, host metrics)"]
        KSM["kube-state-metrics<br/>(K8s object state)"]
        BE["backend pods<br/>/actuator/prometheus"]
        CAD["kubelet cAdvisor<br/>(container CPU/memory)"]
    end

    Prom["Prometheus<br/>annotation-based + node-role discovery<br/>evaluates alert rules every 30s"]
    AM["Alertmanager<br/>routes/dedupes/groups alerts"]
    Graf["Grafana<br/>3 provisioned dashboards"]

    NE -->|"scraped"| Prom
    KSM -->|"scraped"| Prom
    BE -->|"scraped via prometheus.io/scrape annotation"| Prom
    CAD -->|"scraped via API server proxy"| Prom

    Prom -->|"alert rules fire"| AM
    Prom -->|"PromQL queries"| Graf
```

## How Prometheus finds each target (no Operator, no CRDs)

| Target | Discovery mechanism | Config location |
|---|---|---|
| Backend pods | `role: pod` + `prometheus.io/scrape` annotation | `helm/enterprise-app/charts/backend/templates/deployment.yaml` (annotation) + `monitoring/monitoring-stack/charts/prometheus/templates/configmap.yaml` (job) |
| kube-state-metrics | Static target (fixed Service name/port) | same configmap, `kube-state-metrics` job |
| node-exporter | Static target (fixed Service name/port) | same configmap, `node-exporter` job |
| Container CPU/memory (cAdvisor) | `role: node` + API server proxy path | same configmap, `kubernetes-nodes-cadvisor` job |

## Alert evaluation and routing

```mermaid
sequenceDiagram
    participant P as Prometheus
    participant R as rules.yml (ConfigMap)
    participant A as Alertmanager
    participant U as Alertmanager UI / Slack (optional)

    loop every 30s
        P->>R: evaluate each alert expression
        alt condition true for `for:` duration
            P->>A: fire alert (with labels/annotations)
            A->>A: group by alertname+namespace, apply inhibit_rules
            A->>U: route to receiver (default = UI only, unless Slack enabled)
        else condition false
            P->>P: no action
        end
    end
```

## Dashboards

Three, covering the six categories the project's learning goals name
(Cluster, Namespace, Application, Node, JVM, Spring Boot) by grouping the
closely-related ones together:

| Dashboard | Covers |
|---|---|
| Cluster & Node Dashboard | Cluster-wide node count/pod count, per-node CPU/memory/disk/network |
| Namespace & Pod Dashboard | Pods per namespace, deployment availability, restarts, per-pod CPU/memory |
| Application (Spring Boot / JVM) Dashboard | HTTP request rate/latency/availability, JVM heap/threads/GC, DB connection pool |

See `monitoring/monitoring-stack/charts/grafana/templates/configmap-dashboard-*.yaml`
for the actual panel definitions and PromQL queries.

## Independence from the other two Argo CD Applications

Like `logging-stack` (Project 5), `monitoring-stack` is its own Argo CD
Application, in its own `monitoring` namespace, with no `selfHeal` given
its own persistent volumes (Prometheus's TSDB, Alertmanager's silence
state, Grafana's dashboards/sessions). It observes `enterprise-app` and
(via the backend's `prometheus.io/scrape` annotation) the application
tier specifically, but neither Application has any Kubernetes-level
dependency on the other — each can be installed, upgraded, or removed
independently.
