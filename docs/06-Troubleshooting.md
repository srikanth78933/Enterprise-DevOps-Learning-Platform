# Troubleshooting — Project 5: Centralized Logging (ELK)

## Elasticsearch pod stuck `CrashLoopBackOff` with a `max virtual memory areas` error

`vm.max_map_count` isn't set high enough on the node. Confirm the
`sysctl` init container actually ran (`kubectl describe pod
elasticsearch-0 -n logging`) — if your cluster's admission policy blocks
privileged init containers, set `elasticsearch.sysctlInitContainer.enabled:
false` in `logging/elk-stack/values.yaml` and set
`vm.max_map_count=262144` at the node level instead (via a custom launch
template's user-data, or a separate privileged DaemonSet your platform
team already runs for this purpose).

## Elasticsearch pod `Pending` forever

Almost always the PVC. `kubectl describe pvc data-elasticsearch-0 -n
logging` — check the `gp2` StorageClass exists
(`kubectl get storageclass`) and that your node group has capacity in the
same AZ as wherever the PV gets provisioned.

## `kubectl get daemonset filebeat -n logging` shows fewer `READY` than `DESIRED`

```bash
kubectl describe daemonset filebeat -n logging
kubectl logs -l app.kubernetes.io/name=filebeat -n logging --previous
```

Common cause: the ClusterRole/ClusterRoleBinding
(`logging/elk-stack/charts/filebeat/templates/rbac.yaml`) didn't sync —
check Argo CD didn't reject them (see
`gitops/projects/enterprise-devops-project.yaml`'s
`clusterResourceWhitelist` — Project 5 added `ClusterRole`/
`ClusterRoleBinding` there specifically for this).

## No documents showing up in Kibana at all

Work backward through the pipeline:

```bash
./scripts/tail-logs.sh                                    # 1. is the app actually emitting JSON?
kubectl logs -l app.kubernetes.io/name=filebeat -n logging | grep -i error   # 2. is Filebeat erroring?
kubectl logs -l app.kubernetes.io/name=logstash -n logging | tail -50        # 3. is Logstash erroring?
curl http://localhost:9200/_cat/indices?v                 # 4. (via port-forward) does the index exist at all?
```

## Logs show up but `app.level`/`app.message` fields are missing (just raw `message`)

Logstash's `json` filter is gated on
`[kubernetes][labels][app_kubernetes_io/name] == "backend"` — confirm the
backend Deployment actually carries that label (it does, via
`helm/enterprise-app/charts/backend/templates/_helpers.tpl`'s
`backend.selectorLabels`) and that Filebeat's `add_kubernetes_metadata`
processor is attaching it (check one raw document in Kibana — expand
`kubernetes.labels` and confirm the key is present, possibly dedotted to
`app_kubernetes_io/name`).

## `Wait for Argo CD Sync` isn't relevant here — why?

Neither Jenkinsfile changed in this project. `logging-stack` is deployed
by directly applying `gitops/applications/logging-stack.yaml` (see
`docs/03-Installation.md`), not through a Jenkins pipeline — there's no
image to build for infrastructure-as-Helm-chart the way there is for the
application tier.

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
