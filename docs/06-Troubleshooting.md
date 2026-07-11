# Troubleshooting — Project 2: CD to AWS EKS

## `aws eks update-kubeconfig` succeeds, but `kubectl get nodes` returns `Unauthorized`

The IAM identity you're using isn't mapped to Kubernetes RBAC. By default,
only the IAM identity that *created* the cluster gets implicit
`system:masters` access. If Jenkins uses a different IAM user than
whoever created the cluster, you must add it to the `aws-auth` ConfigMap:

```bash
kubectl edit configmap aws-auth -n kube-system
# add a new mapUsers or mapRoles entry for the Jenkins IAM identity
```

## Pods stuck in `Pending`

```bash
kubectl describe pod <pod-name> -n enterprise-devops
```

Usually one of: no node has enough allocatable CPU/memory for the
`resources.requests` (check `kubectl top nodes` / `kubectl describe node`),
or the `mysql-pvc` PersistentVolumeClaim never bound (check `kubectl get
pvc -n enterprise-devops` — the default `gp2` StorageClass must exist,
which EKS provides automatically unless it was explicitly removed).

## HPA shows `<unknown>` for CURRENT / TARGETS forever

Metrics Server isn't installed. Re-run step 3 of
`docs/03-Installation.md`, then `kubectl top pods -n enterprise-devops` —
if that also fails, Metrics Server itself isn't healthy
(`kubectl get pods -n kube-system | grep metrics-server`).

## `mysql-pvc` stuck `Pending` forever, mysql pod never schedules

`kubectl describe pvc mysql-pvc -n enterprise-devops` shows "waiting for
external provisioner ebs.csi.aws.com". The EBS CSI driver addon isn't
installed on the cluster — run step 2 of `docs/03-Installation.md`. This
blocks everything downstream: mysql never starts, so the backend never
passes its readiness probe either, even once secrets exist.

## Ingress load balancer never gets an address

`kubectl get ingress -n enterprise-devops` shows no `ADDRESS`. Confirm the
NGINX Ingress Controller is actually installed and its Service is `type:
LoadBalancer` (`kubectl get svc -n ingress-nginx`) — the Ingress resource
itself does nothing without a controller watching it.

## Orphaned Load Balancer left behind after cleanup

A Kubernetes `Service` or `Ingress` of `type: LoadBalancer` provisions its
own AWS ELB/NLB, which nothing outside Kubernetes tracks. If you delete
the Ingress/Service but the Load Balancer still shows up in the AWS
Console, it usually means the delete didn't fully propagate — check
`kubectl get svc -A | grep LoadBalancer` for leftovers, and delete the
Load Balancer directly in the AWS Console as a last resort. This is worth
checking regularly since it bills hourly even if nothing is using it.

## `kubectl set image` succeeds but pods never update

Check `kubectl rollout status deployment/backend -n enterprise-devops` —
if it's stuck, the new pod likely never passes its readiness probe. Check
`kubectl logs deployment/backend -n enterprise-devops` for a startup
crash (frequently: `DB_URL`/credentials mismatch between the `backend-secret`
and what `mysql-secret` actually contains).

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
