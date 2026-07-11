# Installation — Project 3: CI/CD with Helm & Independent Pipelines

Assumes you already have a running EKS cluster with the EBS CSI driver,
NGINX Ingress Controller, and Metrics Server installed — steps 1-4 of
`project-02-cd-eks`'s `docs/03-Installation.md`. If not, do that first;
this project doesn't provision or change any of that infrastructure.

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
kubectl get pods -n enterprise-devops -o wide
kubectl get deployment,svc,hpa,ingress,pvc -n enterprise-devops
helm list -n enterprise-devops
```

Expect: `backend` 2/2 `Running`, `frontend` 2/2 `Running`, `mysql` 1/1
`Running`, `mysql-pvc` `Bound`, the `enterprise-app` release showing
`STATUS: deployed` (not `failed` or `pending-upgrade`), and
`enterprise-app-ingress` with a real `ADDRESS` (the NLB hostname — can
take a couple minutes to appear on first install).

Then confirm both services actually answer through that Ingress:

```bash
./scripts/verify-backend.sh
./scripts/verify-frontend.sh
```

## 6. Set up the two Jenkins pipeline jobs

Follow [`jenkins/README.md`](../jenkins/README.md) steps 1-11 (steps 7 and
11 are new in this project — two jobs, not one).

## 7. Verify after each pipeline runs

Same checklist as step 5, run again after triggering
`enterprise-backend-pipeline` and `enterprise-frontend-pipeline` — this is
what actually confirms the split-pipeline model works: each pod's
`RESTARTS`/`AGE` should reflect only the service that pipeline touched,
`helm list` should show the release revision incremented by exactly one
per run, and `helm get values enterprise-app -n enterprise-devops` should
show both `backend.image.tag` and `frontend.image.tag` holding their own
independent values (see `docs/04-Step-by-Step.md` steps 2-3 for the
deliberate cross-check that neither pipeline clobbered the other's tag).

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
