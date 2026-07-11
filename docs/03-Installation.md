# Installation — Project 6: Monitoring (Prometheus & Grafana)

Assumes `enterprise-app` is already deployed via Argo CD (Project 4). Does
not require `elk-stack` (Project 5) to be installed, though nothing here
conflicts with it either.

## 1. Create the Grafana admin secret

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic grafana-admin -n monitoring \
  --from-literal=GF_SECURITY_ADMIN_USER=admin \
  --from-literal=GF_SECURITY_ADMIN_PASSWORD='<strong-password>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## 2. Generate the TLS secret for Grafana's Ingress

```bash
./scripts/generate-self-signed-tls.sh grafana.enterprise-devops.example.com grafana-tls monitoring
```

## 3. Point the Application at your fork

Edit `repoURL` in `gitops/applications/monitoring-stack.yaml` (and
confirm it's in `gitops/projects/enterprise-devops-project.yaml`'s
`sourceRepos`).

## 4. Register the Application

```bash
kubectl apply -f gitops/applications/monitoring-stack.yaml
kubectl get application monitoring-stack -n argocd -w
```

## 5. Confirm scrape targets are healthy

```bash
./scripts/prometheus-port-forward.sh prometheus
```

Open http://localhost:9090/targets — every target (`prometheus`,
`kubernetes-pods`, `kubernetes-nodes-cadvisor`, `node-exporter`,
`kube-state-metrics`) should show `State: UP`. If `kubernetes-pods` shows
nothing for the backend specifically, confirm the backend Deployment
actually carries the `prometheus.io/scrape` annotations (it should,
automatically, since this project added them to
`helm/enterprise-app/charts/backend/templates/deployment.yaml` — but
confirm your `enterprise-app` release has actually synced that change).

## 6. Open Grafana

```bash
./scripts/grafana-port-forward.sh
```

Open http://localhost:3000, log in with the `grafana-admin` secret's
credentials. Dashboards → Enterprise DevOps folder — all three should
already be there (provisioned automatically, no manual import).

## 7. Check Alertmanager

```bash
./scripts/prometheus-port-forward.sh alertmanager 9093
```

Open http://localhost:9093 — should show no active alerts on a healthy
cluster. See `docs/04-Step-by-Step.md` to trigger one on purpose.

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
