# Step-by-Step Walkthrough — Project 3: CI/CD with Helm & Independent Pipelines

## 1. Confirm the baseline install works

After `docs/03-Installation.md`, confirm:

```bash
helm list -n enterprise-devops
helm get values enterprise-app -n enterprise-devops
```

`helm get values` should show only what you explicitly `--set` or `-f`
overrode — never a real password (secrets are referenced by name, not
templated).

## 2. Trigger only the backend pipeline

Make a trivial backend change, push it, run `enterprise-backend-pipeline`
in Jenkins. Watch the **Helm Upgrade** stage — it runs `--set
backend.image.tag=<build>` only. Confirm the frontend Deployment's image
tag is untouched:

```bash
kubectl get deployment frontend -n enterprise-devops -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## 3. Trigger only the frontend pipeline

Same idea, opposite direction — make a trivial frontend change, run
`enterprise-frontend-pipeline`, and confirm the backend's image tag didn't
move.

## 4. Break `--reuse-values` on purpose, then fix it

Temporarily edit `scripts/helm-upgrade-backend.sh` to remove
`--reuse-values` and run it. Then check:

```bash
kubectl get deployment frontend -n enterprise-devops -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Without `--reuse-values`, the frontend image tag resets to whatever
`helm/enterprise-app/values.yaml` says by default (`latest`) — a real
regression this flag exists specifically to prevent. Revert the script
change afterward.

## 5. Try a values overlay

```bash
helm upgrade enterprise-app helm/enterprise-app -n enterprise-devops \
  --reuse-values -f helm/enterprise-app/values-prod.yaml.example --dry-run --debug
```

`--dry-run --debug` renders and validates without actually applying —
inspect the output and see exactly which values changed versus the
current release.

## 6. Roll back

```bash
helm history enterprise-app -n enterprise-devops
helm rollback enterprise-app <revision-number> -n enterprise-devops
```

## Next

Continue to [05-Flow.md](./05-Flow.md).
