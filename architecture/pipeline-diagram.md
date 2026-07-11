# CI/CD Pipeline Diagrams — Project 3

Two fully independent pipelines now — `backend/Jenkinsfile` and
`frontend/Jenkinsfile` — replacing the single root `Jenkinsfile` from
Projects 1-2. Each can build, test, and deploy without waiting on, or
being blocked by, the other.

```mermaid
flowchart TD
    subgraph BE["backend/Jenkinsfile"]
        direction TB
        B1[Checkout] --> B2[Maven Build] --> B3[Unit Test] --> B4[SonarQube]
        B4 --> B5{Quality Gate}
        B5 -- pass --> B6[Parallel Stage] --> B7[Package Jar]
        B7 --> B8[Docker Build] --> B9[Push Image]
        B9 --> B9c["Package & Push Helm Chart<br/>OCI push to Docker Hub"]
        B9c --> B10["Helm Upgrade<br/>--set backend.image.tag"]
        B10 --> B11[Verify backend]
    end

    subgraph FE["frontend/Jenkinsfile"]
        direction TB
        F1[Checkout] --> F2["Install & Test<br/>npm ci / test"] --> F3["Build<br/>npm run build"]
        F3 --> F4[Docker Build] --> F5[Push Image]
        F5 --> F5c["Package & Push Helm Chart<br/>OCI push to Docker Hub"]
        F5c --> F6["Helm Upgrade<br/>--set frontend.image.tag"]
        F6 --> F7[Verify frontend]
    end

    B10 -.->|"same Helm release,\ndifferent --set key"| F6
```

## Why splitting pipelines matters (the actual lesson)

In Project 2's single Jenkinsfile, a frontend-only CSS tweak still had to
wait for the *entire* backend build/test/SonarQube/quality-gate chain
before anything deployed — and a red backend Quality Gate blocked an
unrelated frontend fix from shipping. Splitting into two pipelines, each
touching only its own Helm values key via `--reuse-values`, means:

- A frontend change deploys in the time it takes to `npm test` + build a
  static bundle — no Java toolchain, no SonarQube wait.
- A failing backend Quality Gate never blocks a frontend release, and
  vice versa.
- Each pipeline's blast radius is exactly one Helm value
  (`backend.image.tag` or `frontend.image.tag`) — `--reuse-values` is what
  guarantees pipeline A never clobbers pipeline B's last successful value.

## Helm release lifecycle across both pipelines

```mermaid
sequenceDiagram
    participant BEJ as backend/Jenkinsfile
    participant FEJ as frontend/Jenkinsfile
    participant Helm as Helm / EKS

    Note over BEJ,FEJ: Both target the same release: "enterprise-app"

    BEJ->>Helm: helm upgrade --install enterprise-app ... --reuse-values --set backend.image.tag=41
    Helm-->>BEJ: backend.image.tag=41, frontend.image.tag=<unchanged>
    Note right of Helm: Only the backend Deployment rolls

    FEJ->>Helm: helm upgrade --install enterprise-app ... --reuse-values --set frontend.image.tag=17
    Helm-->>FEJ: frontend.image.tag=17, backend.image.tag=41 (preserved)
    Note right of Helm: Only the frontend Deployment rolls
```

## Why the chart is also pushed to Docker Hub

`Package & Push Helm Chart` packages `helm/enterprise-app` and pushes it
as an OCI artifact to `oci://registry-1.docker.io/devopstraining064`,
versioned the same way as the image tag (`1.0.0-<build>`). This is purely
for a versioned, auditable record of what was deployed — reuses the same
Docker Hub registry and `dockerhub-credentials` already used for images,
rather than standing up a separate chart repository (e.g. Nexus's `helm`
format) just for this. The actual `Helm Upgrade` stage right after still
deploys from the freshly-checked-out `helm/enterprise-app/` directory, not
a pulled package, so this stage doesn't change deploy behavior.

Full Helm chart structure: [`helm-chart-structure.md`](./helm-chart-structure.md).
