# Cleanup — Project 6: Monitoring (Prometheus & Grafana)

## 1. Delete the monitoring Application (removes everything it deployed)

```bash
kubectl delete -f gitops/applications/monitoring-stack.yaml
```

Removes Prometheus (+ PVC), Alertmanager (+ PVC), Grafana (+ PVC +
Ingress), node-exporter's DaemonSet, and kube-state-metrics + its RBAC.

## 2. Confirm PVCs are actually gone

```bash
kubectl get pvc -n monitoring
# if anything remains:
kubectl delete pvc -n monitoring --all
```

## 3. Remove secrets and the namespace

```bash
kubectl delete secret grafana-admin grafana-tls -n monitoring
kubectl delete namespace monitoring
```

## 4. Revert any temporary demo changes

If you followed `docs/04-Step-by-Step.md` (lowering `backend.resources
.limits.cpu`, or setting a bad `backend.image.tag` to trigger
`ImagePullBackOff`), confirm both are reverted via a proper Git-tracked
change — not left as drift against `enterprise-app`'s `selfHeal: true`
release.

## What you're NOT tearing down here

`enterprise-app`, `elk-stack`, the EKS cluster, and Argo CD itself are
untouched by this cleanup.

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
