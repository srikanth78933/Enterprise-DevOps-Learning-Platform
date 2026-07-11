# elk-stack — Helm Umbrella Chart

Centralized logging for the platform: Elasticsearch, Logstash, Filebeat,
and Kibana. Deployed by Argo CD as its own release (`elk-stack`), separate
from `enterprise-app` — logging infrastructure has its own lifecycle,
independent of application deploys. See
[`/gitops/README.md`](../../gitops/README.md) and
[`/architecture/README.md`](../../architecture/README.md) for why.

## Structure

```
elk-stack/
├── Chart.yaml
├── values.yaml              Umbrella defaults
├── templates/namespace.yaml Creates the `logging` namespace
└── charts/
    ├── elasticsearch/         StatefulSet (volumeClaimTemplates), 2 Services
    ├── logstash/              Deployment, ConfigMap (beats input -> JSON filter -> ES output)
    ├── filebeat/               DaemonSet, RBAC, ConfigMap (Kubernetes autodiscover)
    └── kibana/                Deployment, Ingress with TLS
```

## Log flow

```
Spring Boot app (JSON to stdout, prod profile)
  -> container log file on the node (/var/log/containers/...)
  -> Filebeat DaemonSet (tails it, attaches Kubernetes metadata)
  -> Logstash (parses the JSON message, tags error/slow_request/request_log)
  -> Elasticsearch (indexed as enterprise-devops-logs-YYYY.MM.dd)
  -> Kibana (dashboards, Discover, saved searches)
```

Full diagram: [`/architecture/log-flow.md`](../../architecture/log-flow.md).

## Install (via Argo CD, not directly)

Registered the same way as `enterprise-app` — see
`gitops/applications/logging-stack.yaml`. For local chart development
only:

```bash
helm lint logging/elk-stack
helm template elk-stack logging/elk-stack -n logging
```

## TLS for Kibana

`kibana-tls` is never templated by this chart — create it out-of-band:

```bash
./scripts/generate-self-signed-tls.sh kibana.enterprise-devops.example.com kibana-tls logging
```

See that script's header for why self-signed (not cert-manager) is used
in this tutorial, and what changes for a real deployment.

## Resource footprint

This is a single-node "cluster" of everything — appropriate for a
learning environment, not a production log store. Elasticsearch alone
requests 1.5-2Gi memory; budget for roughly 3-4Gi total across all four
components before deploying onto the same node group as `enterprise-app`.
See `docs/01-Prerequisites.md` for whether your EKS node group has room.
