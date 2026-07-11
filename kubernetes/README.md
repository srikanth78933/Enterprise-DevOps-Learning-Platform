# Kubernetes Manifests — Project 2

Raw manifests (no Helm yet — that's introduced in Project 3). Applied via
`kubectl apply -k kubernetes/` (kustomize, built into `kubectl`) so the
Jenkins pipeline can set image tags without hand-editing YAML.

## Apply order

`kubectl apply -k .` applies everything in the right order on its own
(Kubernetes retries until dependencies like the namespace exist), but for
manual step-by-step learning:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
# create secrets first - see secret.example.yaml, do NOT apply that file directly
kubectl apply -f mysql-deployment.yaml
kubectl rollout status deployment/mysql -n enterprise-devops
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-hpa.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f ingress.yaml
```

`backend-vpa.yaml` is applied separately and optionally — see the
comments in that file before using it.

## Files

| File | Kind | Notes |
|---|---|---|
| `namespace.yaml` | Namespace | Everything else lives in `enterprise-devops` |
| `configmap.yaml` | ConfigMap ×2 | Non-secret backend + MySQL config |
| `secret.example.yaml` | Secret ×2 (template) | Real secrets created via `kubectl create secret`, never committed |
| `mysql-deployment.yaml` | PVC, Deployment, Service | Single-replica MySQL with persistent storage |
| `backend-deployment.yaml` | Deployment, Service | 2 replicas, readiness/liveness on Actuator probe groups |
| `backend-hpa.yaml` | HorizontalPodAutoscaler | CPU + memory based, requires Metrics Server |
| `backend-vpa.yaml` | VerticalPodAutoscaler | Recommendation-only, requires separate VPA controller |
| `frontend-deployment.yaml` | Deployment, Service | 2 replicas, NGINX-served static build |
| `ingress.yaml` | Ingress | Routes `/api` → backend, `/` → frontend |
| `kustomization.yaml` | Kustomization | Ties it together, exposes the `images:` transformer used by CI |
