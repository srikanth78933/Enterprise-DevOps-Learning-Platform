# CI/CD Pipeline Diagram — Project 2

Extends Project 1's pipeline (Checkout through Push Docker Image are
unchanged) with a real deployment to EKS.

Rendered view (source is the Mermaid below, in case you want to edit it):

![Project 2 Pipeline — Detailed Sequential View](./project-2-pipeline-detailed.png)

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

## Stage-by-stage detail

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub Repo
    participant J as Jenkins
    participant SQ as SonarQube
    participant NX as Nexus
    participant DH as Docker Hub
    participant AWS as AWS STS/EKS
    participant K8s as EKS API Server

    Dev->>GH: git push
    GH-->>J: webhook / poll triggers build
    J->>J: Checkout
    J->>J: Maven Build (compile + versions:set stamps 1.0.0-<build#>)
    J->>J: Unit Test (mvn test - JUnit + JaCoCo)
    J->>SQ: mvn sonar:sonar (submit analysis)
    SQ-->>J: webhook callback with Quality Gate result
    alt Quality Gate failed
        J-->>Dev: Build marked FAILURE, pipeline aborted
    else Quality Gate passed
        par Parallel Stage
            J->>J: Publish JaCoCo coverage report
        and
            J->>J: mvn dependency:tree audit
        end
        J->>J: mvn package -DskipTests (jar archived)
        J->>NX: mvn deploy (immutable versioned artifact)
        NX-->>J: artifact stored (maven-releases)
        J->>J: docker build -f backend-ci.Dockerfile
        J->>DH: docker push (versioned tag + latest)
        DH-->>J: push acknowledged
        J->>AWS: aws eks update-kubeconfig --name eks-cluster --region eu-west-3
        AWS-->>J: kubeconfig with cluster endpoint + CA cert
        J->>K8s: kubectl apply -k kubernetes/ (baseline: namespace, configmap, PVC, services, HPA, ingress)
        K8s-->>J: resources created/unchanged
        J->>K8s: kubectl set image deployment/backend backend=<image>:<build-tag>
        K8s->>DH: pull new image (rolling update, one pod at a time)
        K8s-->>J: rollout status: successfully rolled out
        J->>J: scripts/verify-deployment.sh (curl /api/health through Ingress)
        J-->>Dev: Build marked SUCCESS
    end
```

Why `kubectl apply -k` runs *before* `kubectl set image`: the baseline
apply is what actually creates the namespace/configmap/services/HPA/PVC
if they don't already exist (first deploy) or reconciles drift (later
deploys); `set image` only ever touches the container image field on an
existing Deployment, so it must run second.
