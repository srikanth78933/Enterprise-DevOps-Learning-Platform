# Installation — Project 5: Centralized Logging (ELK)

Assumes `enterprise-app` is already deployed via Argo CD (Project 4).

## 1. Generate the TLS secret for Kibana

```bash
./scripts/generate-self-signed-tls.sh kibana.enterprise-devops.example.com kibana-tls logging
```

## 2. Point the Application at your fork

Edit `repoURL` in `gitops/applications/logging-stack.yaml` (and confirm
it's still correct in `gitops/projects/enterprise-devops-project.yaml`'s
`sourceRepos`, from Project 4).

## 3. Register the Application

```bash
kubectl apply -f gitops/applications/logging-stack.yaml
kubectl get application logging-stack -n argocd -w
```

Wait for `SYNC STATUS: Synced`. `HEALTH STATUS` may sit at `Progressing`
for a minute or two while Elasticsearch initializes — that's expected.

## 4. Confirm everything's running

```bash
kubectl get pods,pvc -n logging
kubectl get daemonset filebeat -n logging   # DESIRED should equal your node count
```

## 5. Open Kibana

```bash
./scripts/kibana-port-forward.sh
```

Open http://localhost:5601. First time in Kibana: **Stack Management →
Data Views** → create a data view matching `enterprise-devops-logs-*`,
timestamp field `@timestamp`.

(Or via the real Ingress once DNS/cert trust is sorted:
`https://kibana.enterprise-devops.example.com` — your browser will warn
about the self-signed cert, that's expected per
`scripts/generate-self-signed-tls.sh`'s header.)

## 6. Generate sample logs

```bash
./scripts/generate-test-traffic.sh
```

Then in Kibana's **Discover** tab, select the `enterprise-devops-logs-*`
data view and look for entries tagged `request_log`, `error_log`.

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
