# CI/CD Pipeline Diagram — Project 2

Extends Project 1's pipeline (Checkout through Package Jar are unchanged)
with a real deployment to EKS.

```mermaid
flowchart TD
    A[Git push] --> B[Checkout]
    B --> C[Maven Build]
    C --> D[Unit Test]
    D --> E[SonarQube Analysis]
    E --> F{Quality Gate}
    F -- fail --> X[Pipeline aborted]
    F -- pass --> G[Parallel Stage]

    subgraph G[Parallel Stage]
        direction LR
        G1[Publish Coverage Report]
        G2[Dependency Tree Audit]
    end

    G --> H[Package Jar]
    H --> I[Docker Build]
    I --> J[Push Docker Image]
    J --> L[Deploy to EKS]
    L --> M[Verify]
    M --> N[Pipeline success]

    subgraph L[Deploy to EKS]
        direction TB
        L1[aws eks update-kubeconfig]
        L2[kubectl apply -k kubernetes/]
        L3[kubectl set image backend]
        L1 --> L2 --> L3
    end

    subgraph M[Verify]
        direction TB
        M1[kubectl rollout status backend]
        M2[scripts/verify-deployment.sh<br/>curl through the Ingress]
        M1 --> M2
    end
```

## Deploy stage detail

```mermaid
sequenceDiagram
    participant J as Jenkins
    participant AWS as AWS STS/EKS
    participant K8s as EKS API Server
    participant DH as Docker Hub

    J->>AWS: aws eks update-kubeconfig
    AWS-->>J: kubeconfig with cluster endpoint + CA cert
    J->>K8s: kubectl apply -k kubernetes/ (baseline: namespace, configmap, PVC, services, HPA, ingress)
    K8s-->>J: resources created/unchanged
    J->>K8s: kubectl set image deployment/backend backend=<image>:<build-tag>
    K8s->>DH: pull new image (rolling update, one pod at a time)
    K8s-->>J: rollout status: successfully rolled out
    J->>J: scripts/verify-deployment.sh (curl /api/health through Ingress)
```

Why `kubectl apply -k` runs *before* `kubectl set image`: the baseline
apply is what actually creates the namespace/configmap/services/HPA/PVC
if they don't already exist (first deploy) or reconciles drift (later
deploys); `set image` only ever touches the container image field on an
existing Deployment, so it must run second.
