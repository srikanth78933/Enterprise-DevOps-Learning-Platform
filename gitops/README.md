# GitOps — Project 4

Replaces Jenkins calling `helm upgrade` directly (Project 3) with Argo CD
continuously reconciling the cluster against what's declared in Git.

## Folder layout

```
gitops/
├── argocd/
│   └── values.yaml                     Helm values for installing Argo CD itself
├── projects/
│   └── enterprise-devops-project.yaml  AppProject - scopes allowed repos/destinations
└── applications/
    └── enterprise-app.yaml             Application - the desired-state declaration
```

## The new flow

```
Git push (app code) → Jenkins → Build/Test/Scan → Push Image
    → Update Helm values file → Git commit + push
    → Argo CD detects the Git change → Sync → Deploy
```

Jenkins's responsibility now ends at "commit the new image tag to Git."
It never touches the cluster directly — no `kubectl`, no `helm upgrade`.
Argo CD is the only thing with write access to the cluster's application
resources, which is the actual point of GitOps: one auditable path from
"desired state in Git" to "what's actually running," instead of two
(Jenkins pushing *and* someone occasionally running `kubectl apply` by
hand).

## Why the image tag lives in `helm/enterprise-app/values-images/*.yaml`, not here

Argo CD resolves a Helm chart's `valueFiles` relative to `source.path`
(the chart directory), and by default won't follow `../` traversal outside
it for security reasons. Keeping `values-images/backend.yaml` and
`values-images/frontend.yaml` *inside* the chart directory sidesteps that
restriction entirely, at the (small, deliberate) cost of those two files
looking slightly out of place next to `gitops/`. See
`architecture/README.md` for the full reasoning.

## Bootstrap order

1. Install Argo CD itself: `scripts/argocd-install.sh`
2. Apply the AppProject and Application: `scripts/argocd-bootstrap.sh`
3. From then on, Jenkins commits are the only thing that changes what's
   deployed — see `docs/03-Installation.md` for the full walkthrough.

## Self-healing, demonstrated

```bash
kubectl scale deployment/backend -n enterprise-devops --replicas=5
# watch Argo CD revert it back to whatever helm/enterprise-app declares within ~3 minutes (or instantly if you click "Refresh" in the UI)
kubectl get deployment/backend -n enterprise-devops -w
```

This is `syncPolicy.automated.selfHeal: true` in
`gitops/applications/enterprise-app.yaml` in action — see
`docs/04-Step-by-Step.md` for the full exercise.
