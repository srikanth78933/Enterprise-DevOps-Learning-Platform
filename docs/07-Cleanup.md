# Cleanup — Project 2: CD to AWS EKS

The cluster itself is managed outside this repo, so cleanup here only
covers what this project created *on* it — the application and any
Kubernetes-provisioned AWS resources (Load Balancers).

## 1. Remove the Ingress and Ingress Controller first

```bash
kubectl delete -f kubernetes/ingress.yaml
helm uninstall ingress-nginx -n ingress-nginx
```

Confirm the AWS Network Load Balancer it created is actually gone (AWS
Console → EC2 → Load Balancers) before proceeding — it bills hourly even
if nothing is using it.

## 2. Remove the application

```bash
kubectl delete -k kubernetes/
kubectl delete secret backend-secret mysql-secret -n enterprise-devops
```

## 3. Confirm nothing billable is left behind

AWS Console, check for orphans in:

- EC2 → Load Balancers (should have nothing tied to `enterprise-devops`)
- EC2 → Elastic IPs (should have nothing tied to a Load Balancer you just deleted)

(The EKS cluster and its node group are expected to still be there — this
project doesn't own or manage them.)

## 4. Local cleanup

```bash
rm -rf backend/target frontend/build frontend/node_modules
```

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
