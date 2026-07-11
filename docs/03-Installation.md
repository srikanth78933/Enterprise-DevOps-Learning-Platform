# Installation — Project 4: GitOps with Argo CD

Assumes Project 3's cluster (EKS + Ingress Controller + Metrics Server) is
already up. If you still have Project 3's manual `helm install` release
running, that's fine — Argo CD will adopt it.

## 1. Install Argo CD

```bash
./scripts/argocd-install.sh
```

Note the admin password it prints. Port-forward and log in to confirm it
came up:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# in another terminal / browser:
open https://localhost:8080
```

## 2. Point the Application at your fork

Edit `repoURL` in both:
- `gitops/projects/enterprise-devops-project.yaml`
- `gitops/applications/enterprise-app.yaml`

to your actual fork's URL (they default to this tutorial's origin repo).

## 3. Bootstrap the AppProject and Application

```bash
./scripts/argocd-bootstrap.sh
```

## 4. Create the secrets (same as Project 3, if not already done)

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

## 5. Watch the first sync happen

```bash
kubectl get application enterprise-app -n argocd -w
```

Wait for `SYNC STATUS: Synced` and `HEALTH STATUS: Healthy`. Then:

```bash
kubectl get pods,svc,hpa,ingress -n enterprise-devops
```

## 6. Set up Jenkins for GitOps

Follow [`jenkins/README.md`](../jenkins/README.md) steps 7-12 (new vs.
Project 3): scanning tools, Git write-back credentials, Argo CD CLI + auth
token, and the two pipeline jobs pointed at this branch.

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
