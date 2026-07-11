# enterprise-app — Helm Umbrella Chart

Bundles `frontend`, `backend`, and `mysql` into one release. Replaces
Project 2's raw `kubernetes/` manifests.

## Structure

```
enterprise-app/
├── Chart.yaml
├── values.yaml              Umbrella defaults - overrides subchart values by key
├── values-prod.yaml.example Example production overlay (see comments inside)
├── templates/
│   ├── _helpers.tpl
│   ├── ingress.yaml          Routes /api -> backend, / -> frontend
│   └── NOTES.txt             Printed after install/upgrade
└── charts/
    ├── frontend/              Deployment, Service, optional HPA
    ├── backend/               Deployment, Service, ConfigMap, HPA
    └── mysql/                 Deployment, PVC, Service
```

No `helm dependency update` step is needed — `frontend/`, `backend/`, and
`mysql/` are plain chart directories under `charts/`, which Helm loads
automatically as subcharts. That mechanism (`dependencies:` +
`helm dependency update`) is only for subcharts pulled from a chart
repository or packaged as `.tgz`.

## Secrets — create these before the first install

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
real credentials never pass through `helm template`/`helm install` output
or `helm get values`.

## Install

```bash
helm install enterprise-app helm/enterprise-app -n enterprise-devops --create-namespace
```

## Upgrade a single service (what the split Jenkinsfiles actually do)

```bash
# after backend/Jenkinsfile builds and pushes a new backend image:
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values --set backend.image.tag=<pom-version>-<build-number>

# after frontend/Jenkinsfile builds and pushes a new frontend image:
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values --set frontend.image.tag=<package-version>-<build-number>
```

`--reuse-values` is what makes this safe for independent pipelines: the
backend pipeline's upgrade doesn't need to know (or accidentally reset)
whatever image tag the frontend pipeline last set, and vice versa.

## Uninstall

```bash
helm uninstall enterprise-app -n enterprise-devops
```

This does **not** delete the PVC (`mysql-pvc` survives by Kubernetes
default so data isn't lost on an accidental uninstall) — remove it
explicitly if you actually want to delete the data:
`kubectl delete pvc mysql-pvc -n enterprise-devops`.

## Lint and render locally

```bash
helm lint helm/enterprise-app
helm template enterprise-app helm/enterprise-app -n enterprise-devops
```
