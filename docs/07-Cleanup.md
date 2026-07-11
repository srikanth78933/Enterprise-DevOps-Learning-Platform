# Cleanup — Project 3: CI/CD with Helm & Independent Pipelines

Order matters — same reasoning as Project 2, now via Helm. The cluster
itself is managed outside this repo, so cleanup here only covers what
this project created on it (same as Project 2).

## 1. Uninstall the Helm release (removes the app's Ingress too)

```bash
./scripts/helm-uninstall.sh
```

Confirm the Ingress load balancer is actually gone (AWS Console → EC2 →
Load Balancers) before proceeding.

## 2. Remove the Ingress Controller

```bash
helm uninstall ingress-nginx -n ingress-nginx
```

## 3. Remove the secrets and PVC (only if you want the data gone)

```bash
kubectl delete secret backend-secret mysql-secret -n enterprise-devops
kubectl delete pvc mysql-pvc -n enterprise-devops
```

## 4. Local cleanup

```bash
rm -rf backend/target frontend/build frontend/node_modules
```

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
