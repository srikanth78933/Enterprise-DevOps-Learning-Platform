# GitOps Pipeline Diagrams — Project 4

Same two independent pipelines as Project 3, but each now ends at a Git
commit instead of a direct cluster deploy. Argo CD, not Jenkins, is what
actually talks to the Kubernetes API for application resources.

```mermaid
flowchart TD
    subgraph BE["backend/Jenkinsfile"]
        direction TB
        B1[Checkout] --> B2[Maven Build] --> B3[Unit Test] --> B4[SonarQube]
        B4 --> B5{Quality Gate}
        B5 -- pass --> B6[Parallel Stage] --> B7[Package Jar]
        B7 --> B8["OWASP Dependency Check<br/>fails on CVSS >= 8"]
        B8 --> B9[Docker Build]
        B9 --> B10["Trivy Scan<br/>fails on fixable CRITICAL"]
        B10 --> B11["Docker Scout (optional)<br/>never fails the build"]
        B11 --> B12[Push Image]
        B12 --> B13["Update GitOps Values<br/>edit values-images/backend.yaml, commit, push"]
        B13 --> B14["Wait for Argo CD Sync<br/>argocd app wait --health --sync"]
    end

    B13 -.->|"Git commit"| GitRepo[(Git Repository)]
    GitRepo -.->|"detects change"| ArgoCD[Argo CD]
    ArgoCD -.->|"helm template + kubectl apply"| Cluster[(EKS Cluster)]
    B14 -.->|"read-only status check"| ArgoCD
```

## The actual deploy path (not Jenkins)

```mermaid
sequenceDiagram
    participant J as Jenkins
    participant Git as Git Repository
    participant A as Argo CD
    participant K as EKS API Server

    J->>Git: git commit values-images/backend.yaml (tag=42) + push
    Note over Git,A: Argo CD polls (default: every 3 min) or reacts to a webhook
    Git-->>A: detects new commit on watched branch/path
    A->>A: helm template (renders manifests from the new values)
    A->>K: kubectl apply (diff between rendered manifests and live state)
    K-->>A: rollout progresses
    A-->>A: status: Synced, Healthy
    J->>A: argocd app wait --health --sync (polls the same status)
    A-->>J: Synced + Healthy
```

Compare this to Project 3's sequence diagram (same file, previous branch)
where Jenkins itself called `helm upgrade` — here Jenkins never has
`kubectl`/cluster credentials at all. `argocd app wait` is a read-only
status check against the Argo CD API, not a deploy action.

## Self-healing / desired-state reconciliation

```mermaid
flowchart LR
    Git[(Git: desired state)] -->|continuous reconciliation loop| ArgoCD[Argo CD Controller]
    ArgoCD -->|compares| Live[Live cluster state]
    Live -->|drift detected| ArgoCD
    ArgoCD -->|selfHeal: true - reverts drift| Live
    Manual["kubectl scale / kubectl edit\n(bypasses Git)"] -.->|causes drift| Live
```

See `scripts/simulate-self-heal.sh` and `docs/04-Step-by-Step.md` for a
hands-on exercise proving this loop actually works, not just describing it.
