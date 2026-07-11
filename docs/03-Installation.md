# Installation — Project 3: CI/CD with Helm & Independent Pipelines

Assumes you already have a running EKS cluster with the NGINX Ingress
Controller and Metrics Server installed (Project 2). If not, do that
first — nothing in `terraform/` changed.

## 1. Install Helm locally (if you haven't already)

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh && ./get_helm.sh
helm version
```

## 2. Create the secrets (same as Project 2, if not already done)

```bash
kubectl create namespace enterprise-devops --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic backend-secret -n enterprise-devops \
  --from-literal=DB_USERNAME=devops_user \
  --from-literal=DB_PASSWORD='<strong-password>' \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic mysql-secret -n enterprise-devops \
  --from-literal=MYSQL_USER=devops_user \
  --from-literal=MYSQL_PASSWORD='<same-password-as-above>' \
  --from-literal=MYSQL_ROOT_PASSWORD='<strong-root-password>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## 3. Lint and render the chart before installing

```bash
helm lint helm/enterprise-app
helm template enterprise-app helm/enterprise-app -n enterprise-devops | less
```

## 4. Install

```bash
./scripts/helm-install.sh
```

Or manually: `helm upgrade --install enterprise-app helm/enterprise-app -n
enterprise-devops --create-namespace --wait --timeout 5m`

## 5. Verify

```bash
kubectl get pods,svc,hpa,ingress -n enterprise-devops
./scripts/verify-backend.sh
./scripts/verify-frontend.sh
```

## 6. Set up the two Jenkins pipeline jobs

Follow [`jenkins/README.md`](../jenkins/README.md) steps 1-11 (steps 7 and
11 are new in this project — two jobs, not one).

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
