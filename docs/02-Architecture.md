# Architecture — Project 5: Centralized Logging (ELK)

Full detail lives in [`/architecture`](../architecture/README.md) and
[`/architecture/log-flow.md`](../architecture/log-flow.md) — this page is
the short version.

## Two independent Argo CD Applications now

```
gitops/applications/enterprise-app.yaml   → helm/enterprise-app     → namespace: enterprise-devops
gitops/applications/logging-stack.yaml    → logging/elk-stack       → namespace: logging
```

Neither knows the other exists. `logging-stack` watches container logs
across `enterprise-devops` (via Filebeat's namespace filter in
`logging/elk-stack/values.yaml`), but that's an application-layer
concern (which logs Filebeat ships), not a Kubernetes/Argo CD dependency
between the two Applications.

## Backend logging layers (new)

```
logback-spring.xml          → JSON (prod) vs plain text (dev) console output
filter/RequestLoggingFilter → wraps every HTTP request: method/uri/status/durationMs, WARN if slow
exception/GlobalExceptionHandler → WARN for expected client errors, ERROR+stacktrace for real failures
```

## ELK chart layers

```
logging/elk-stack/charts/elasticsearch/  → StatefulSet + PVC (log store)
logging/elk-stack/charts/logstash/       → Deployment (parse + tag + index)
logging/elk-stack/charts/filebeat/       → DaemonSet + RBAC (log shipper)
logging/elk-stack/charts/kibana/         → Deployment + Ingress/TLS (UI)
```

## Next

Continue to [03-Installation.md](./03-Installation.md).
