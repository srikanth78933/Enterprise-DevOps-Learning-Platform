# Troubleshooting — Project 2: CD to AWS EKS

## `terraform apply` fails with `UnauthorizedOperation` or `AccessDenied`

Your AWS credentials don't have permission to create VPCs/IAM roles/EKS
clusters. Confirm `aws sts get-caller-identity` returns the identity you
expect, and that it has sufficient IAM permissions (see
`docs/01-Prerequisites.md`).

## `aws eks update-kubeconfig` succeeds, but `kubectl get nodes` returns `Unauthorized`

The IAM identity you're using isn't mapped to Kubernetes RBAC. By default,
only the IAM identity that *created* the cluster (i.e., whoever ran
`terraform apply`) gets implicit `system:masters` access. If Jenkins uses a
different IAM user than the one you ran Terraform with locally, you must
add it to the `aws-auth` ConfigMap:

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

## Ingress load balancer never gets an address

`kubectl get ingress -n enterprise-devops` shows no `ADDRESS`. Confirm the
NGINX Ingress Controller is actually installed and its Service is `type:
LoadBalancer` (`kubectl get svc -n ingress-nginx`) — the Ingress resource
itself does nothing without a controller watching it.

## `terraform destroy` hangs or fails deleting the VPC

Almost always an orphaned ELB/NLB created by a Kubernetes `Service` or
`Ingress` that Terraform doesn't know about, holding a network interface in
one of the subnets. Delete the Ingress and any `LoadBalancer`-type Services
first (see `scripts/terraform-destroy.sh`, which checks for this
automatically), then retry `terraform destroy`.

## `kubectl set image` succeeds but pods never update

Check `kubectl rollout status deployment/backend -n enterprise-devops` —
if it's stuck, the new pod likely never passes its readiness probe. Check
`kubectl logs deployment/backend -n enterprise-devops` for a startup
crash (frequently: `DB_URL`/credentials mismatch between the `backend-secret`
and what `mysql-secret` actually contains).

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
