# Pipeline & Deploy Flow — Project 2: CD to AWS EKS

Full diagrams: [`/architecture/pipeline-diagram.md`](../architecture/pipeline-diagram.md).

## New stages vs. Project 1

| Stage | Command | Fails the build if... |
|---|---|---|
| Frontend Build | `npm ci && npm test && npm run build` | Jest tests fail or the build errors |
| Docker Build (parallel) | `docker build` x2 | Either Dockerfile fails |
| Push Docker Images | `docker push` x4 (2 tags x 2 images) | Docker Hub auth/network failure |
| Deploy to EKS | `aws eks update-kubeconfig` → `kubectl apply -k` → `kubectl set image` x2 | AWS auth failure, cluster unreachable, invalid manifest |
| Verify | `kubectl rollout status` x2, then `scripts/verify-deployment.sh` | Rollout doesn't complete in 180s, or the smoke test curl fails |

## Why `kubectl apply -k` then `kubectl set image` (not one step)

`kubectl apply -k kubernetes/` is declarative and idempotent — it
reconciles the *shape* of the cluster (namespace exists, configmap is
current, services/HPA/ingress exist) but the `images:` block in
`kustomization.yaml` only pins a fallback tag (`latest`). `kubectl set
image` then does one focused, auditable thing: point the two Deployments
at this specific build's images. Splitting these means a manifest change
(e.g. adjusting HPA thresholds) and an image bump are always independently
diagnosable in `kubectl rollout history`.

## Rolling update mechanics

Neither Deployment manifest sets a custom `strategy` for backend/frontend,
so both use Kubernetes' default `RollingUpdate` (`maxUnavailable: 25%,
maxSurge: 25%`). Combined with the `readinessProbe` on both, this is what
makes the zero-downtime behavior in `docs/04-Step-by-Step.md` step 5 work:
Kubernetes won't route traffic to a new pod, or terminate an old one, until
the readiness probe says so.

## Credential flow (new: AWS)

```mermaid
sequenceDiagram
    participant JF as Jenkinsfile
    participant JC as Jenkins Credential Store
    participant AWS as AWS STS
    participant EKS as EKS API Server

    JF->>JC: credentials('aws-access-key-id' / 'aws-secret-access-key')
    JC-->>JF: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (masked in logs)
    JF->>AWS: aws eks update-kubeconfig (uses env credentials implicitly)
    AWS-->>JF: kubeconfig for the cluster
    JF->>EKS: kubectl apply -k / kubectl set image (authenticated via the kubeconfig)
```

## Next

Continue to [06-Troubleshooting.md](./06-Troubleshooting.md).
