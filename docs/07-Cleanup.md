# Cleanup — Project 5: Centralized Logging (ELK)

## 1. Delete the logging Application (removes everything it deployed)

```bash
kubectl delete -f gitops/applications/logging-stack.yaml
```

The finalizer means this also removes Elasticsearch's StatefulSet, PVC,
Logstash, Filebeat's DaemonSet + RBAC, and Kibana + its Ingress.

## 2. Confirm the Elasticsearch PVC is actually gone

`prune: true` should remove it along with everything else, but PVCs from
StatefulSets sometimes need an explicit check:

```bash
kubectl get pvc -n logging
# if anything remains:
kubectl delete pvc -n logging --all
```

## 3. Remove the TLS secret and namespace

```bash
kubectl delete secret kibana-tls -n logging
kubectl delete namespace logging
```

## 4. Revert any temporary demo changes

If you followed `docs/04-Step-by-Step.md` step 3 (lowering
`slowRequestThresholdMs` via a direct `helm upgrade`), make sure that's
reverted via a proper Git-tracked change, not left as drift — Argo CD's
`selfHeal` on `enterprise-app` (Project 4) will otherwise fight with it
next sync.

## What you're NOT tearing down here

`enterprise-app`, the EKS cluster, and Argo CD itself are untouched by
this cleanup — see Project 4's `docs/07-Cleanup.md` if you're tearing
down everything.

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
