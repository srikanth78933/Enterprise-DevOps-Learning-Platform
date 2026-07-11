# Prerequisites — Project 5: Centralized Logging (ELK)

Builds on Project 4's prerequisites (Argo CD, a running EKS cluster —
see `docs/01-Prerequisites.md` on `project-04-gitops-argocd`). No new CLI
tools required this project.

## Resource capacity check

The ELK stack's combined resource *requests* (not limits):

| Component | CPU request | Memory request |
|---|---|---|
| Elasticsearch | 500m | 1.5Gi |
| Logstash | 250m | 768Mi |
| Filebeat (per node) | 100m | 128Mi |
| Kibana | 250m | 512Mi |

On top of what `enterprise-app` already requests. Confirm your node group
has room:

```bash
kubectl describe nodes | grep -A5 "Allocated resources"
```

If you're on the `t3.medium` x 2 default from `terraform/terraform.tfvars.example`,
you may need to bump `node_desired_size`/instance type before deploying
this project — see `docs/06-Troubleshooting.md` if pods stay `Pending`.

## New concepts this project assumes no prior exposure to

- **StatefulSet**: like a Deployment, but gives each pod a stable network
  identity and its own PersistentVolumeClaim (via `volumeClaimTemplates`)
  that survives pod rescheduling. Elasticsearch uses one here for the
  first time in this repo — MySQL (Projects 2-4) deliberately used a
  plain Deployment instead; see `logging/elk-stack/charts/elasticsearch/templates/statefulset.yaml`'s
  comments for exactly why StatefulSet semantics matter here and didn't
  for MySQL.
- **DaemonSet**: runs exactly one pod per node, automatically, on every
  node including ones added later. Filebeat needs this — it has to
  observe every node's container logs, not just some of them.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
