# Architecture — Project 5: Centralized Logging (ELK)

This project adds a second, independent Argo CD-managed Helm release —
`elk-stack` — alongside the `enterprise-app` release Projects 2-4
established. It also instruments the backend to actually produce
structured, categorized logs; without that, there'd be nothing meaningful
for Elasticsearch to index or Kibana to visualize.

See [`log-flow.md`](./log-flow.md) for the full pipeline diagram.

## What's new vs. project-04-gitops-argocd

| Added | Purpose |
|---|---|
| `backend/src/main/resources/logback-spring.xml` | JSON logs in prod/k8s, human-readable in dev |
| `backend/.../filter/RequestLoggingFilter.java` | Request + slow-request logging, requestId MDC |
| `GlobalExceptionHandler` logging (WARN vs ERROR) | Error/exception logs, deliberately not all at one level |
| `logging/elk-stack/` (Elasticsearch, Logstash, Filebeat, Kibana subcharts) | The log pipeline itself |
| `gitops/applications/logging-stack.yaml` | Independent Argo CD Application for the logging stack |

## Why `elk-stack` is a separate Argo CD Application, not folded into `enterprise-app`

- **Different lifecycle.** Logging infrastructure gets upgraded, scaled,
  or torn down on its own schedule, unrelated to application deploys.
- **Different blast radius for `selfHeal`.** `enterprise-app`'s
  Application has `selfHeal: true` — safe, because its Deployments are
  stateless and reverting drift just means a rolling restart.
  `logging-stack`'s Application deliberately omits `selfHeal` — a
  StatefulSet holding actual log data is riskier to auto-revert without a
  human looking first (see the comment in that file).
- **Different namespace.** `logging` vs `enterprise-devops` — logging
  infrastructure watching the application namespace, not living inside it,
  mirrors how you'd operate this for real (one shared logging stack could
  eventually observe multiple application namespaces).

## Why the backend needed actual code changes (not just infra)

Every prior project touched only infrastructure/pipeline code —
`backend/src` and `frontend/src` were byte-for-byte identical from `main`
through Project 4. Project 5 is the first exception: centralized logging
is meaningless without something worth centralizing. The three additions
(`logback-spring.xml`, `RequestLoggingFilter`, `GlobalExceptionHandler`
logging) are the minimum needed to produce the five log categories the
project's learning goals name explicitly (Application, Error, Request,
Exception, Slow Request logs) — see `log-flow.md`'s table for exactly
which code produces which category.

## Next branch

`project-06-monitoring-prometheus-grafana` adds metrics (as opposed to
logs) — Prometheus, Alertmanager, Grafana — observing the same
application through a different lens, deployed the same GitOps way this
project and the last one established.
