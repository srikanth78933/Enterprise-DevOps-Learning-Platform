# enterprise-app — Helm Umbrella Chart

Bundles `frontend`, `backend`, and `mysql` into one release. Since
project-04, this chart is deployed by **Argo CD**, not by Jenkins or a
human running `helm install` directly — see
[`/gitops/README.md`](../../gitops/README.md) for the full flow. Everything
below still works for local testing/chart development; it's just no
longer what actually deploys to the shared cluster.

## Structure

```
enterprise-app/
├── Chart.yaml
├── values.yaml               Umbrella defaults - overrides subchart values by key
├── values-images/
│   ├── backend.yaml           Jenkins-managed image tag, Argo CD-watched (see gitops/README.md)
│   └── frontend.yaml          Jenkins-managed image tag, Argo CD-watched
├── values-prod.yaml.example  Example production overlay (see comments inside)
├── templates/
│   ├── _helpers.tpl
│   ├── ingress.yaml           Routes /api -> backend, / -> frontend
│   └── NOTES.txt              Printed after install/upgrade
└── charts/
    ├── frontend/               Deployment, Service, optional HPA
    ├── backend/                Deployment, Service, ConfigMap, HPA
    └── mysql/                  Deployment, PVC, Service
```

No `helm dependency update` step is needed — `frontend/`, `backend/`, and
`mysql/` are plain chart directories under `charts/`, which Helm loads
automatically as subcharts. `Chart.yaml`'s `dependencies:` block declares
them anyway because `helm lint` otherwise flags undeclared subchart
dependencies as an error.

## Secrets — create these before the first sync

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

The chart references these by name (`existingSecret` in each subchart's
`values.yaml`) — it never creates or templates Secret objects itself, so
real credentials never pass through `helm template`, Argo CD's rendered
manifest diff, or `helm get values`.

## How a deploy actually happens now

Neither Jenkinsfile runs `helm install`/`helm upgrade` anymore. Instead:
1. `scripts/update-image-tag.sh <service> <tag>` edits
   `values-images/<service>.yaml` and pushes the commit
2. Argo CD (watching this repo — see
   `gitops/applications/enterprise-app.yaml`) detects the change and runs
   the equivalent of `helm template` + `kubectl apply` itself

## Manual/local use (chart development, not the live cluster)

```bash
# Install standalone, e.g. into a throwaway namespace for chart development:
helm install enterprise-app helm/enterprise-app -n enterprise-devops --create-namespace

# Bump one service's tag by hand (fights Argo CD's selfHeal if run against
# a cluster Argo CD manages - see scripts/helm-upgrade-backend.sh's header):
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values --set backend.image.tag=<build-number>

helm uninstall enterprise-app -n enterprise-devops
```

This does **not** delete the PVC (`mysql-pvc` survives by Kubernetes
default) — remove it explicitly if you want the data gone:
`kubectl delete pvc mysql-pvc -n enterprise-devops`.

## Lint and render locally

```bash
helm lint helm/enterprise-app
helm template enterprise-app helm/enterprise-app -n enterprise-devops \
  -f helm/enterprise-app/values-images/backend.yaml \
  -f helm/enterprise-app/values-images/frontend.yaml
```

The `-f` flags reproduce exactly what Argo CD's `valueFiles` list renders
(see `gitops/applications/enterprise-app.yaml`) — useful for previewing
what a GitOps commit will actually change before pushing it.
