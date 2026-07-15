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

## Stage-by-stage detail

`backend/Jenkinsfile`, start to finish:

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as Git Repository
    participant J as Jenkins (backend/Jenkinsfile)
    participant SQ as SonarQube
    participant DH as Docker Hub
    participant Helm as Helm / EKS

    Dev->>GH: git push (backend change)
    GH-->>J: webhook / poll triggers build
    J->>J: Checkout
    J->>J: Maven Build (compile + versions:set stamps 1.0.0-<build#>)
    J->>J: Unit Test (mvn test - JUnit + Mockito)
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
        J->>J: docker build -f backend-ci.Dockerfile
        J->>DH: docker push (versioned tag + latest)
        DH-->>J: push acknowledged
        J->>J: helm package helm/enterprise-app --version 1.0.0-<build>
        J->>DH: helm push (OCI chart artifact)
        DH-->>J: chart push acknowledged
        J->>Helm: helm upgrade --reuse-values --set backend.image.tag=<tag>
        Helm-->>J: backend Deployment rolled out (frontend untouched)
        J->>J: kubectl rollout status deployment/backend
        J->>J: scripts/verify-backend.sh (curl /api/health through Ingress)
        J-->>Dev: Build marked SUCCESS
    end
```

`frontend/Jenkinsfile`, start to finish:

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as Git Repository
    participant J as Jenkins (frontend/Jenkinsfile)
    participant DH as Docker Hub
    participant Helm as Helm / EKS

    Dev->>GH: git push (frontend change)
    GH-->>J: webhook / poll triggers build
    J->>J: Checkout
    J->>J: Install & Test (npm ci, npm test)
    J->>J: Build (npm run build, REACT_APP_API_BASE_URL=/api baked in)
    J->>J: docker build -f frontend-ci.Dockerfile
    J->>DH: docker push (versioned tag + latest)
    DH-->>J: push acknowledged
    J->>J: helm package helm/enterprise-app --version 1.0.0-<build>
    J->>DH: helm push (OCI chart artifact)
    DH-->>J: chart push acknowledged
    J->>Helm: helm upgrade --reuse-values --set frontend.image.tag=<tag>
    Helm-->>J: frontend Deployment rolled out (backend untouched)
    J->>J: kubectl rollout status deployment/frontend
    J->>J: scripts/verify-frontend.sh (curl / through Ingress)
    J-->>Dev: Build marked SUCCESS
```

Notice what's missing from the frontend sequence compared to the
backend one: no SonarQube, no Quality Gate. `frontend/Jenkinsfile` never
declared that gate in the first place (per `jenkins/README.md` step 3) —
only the backend pipeline enforces a quality bar before shipping.

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
