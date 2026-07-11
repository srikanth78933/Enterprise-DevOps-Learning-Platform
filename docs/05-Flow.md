# GitOps Flow — Project 4

Full diagrams: [`/architecture/pipeline-diagram.md`](../architecture/pipeline-diagram.md).

## What each new/changed stage does

| Stage | Command | Fails the build if... |
|---|---|---|
| OWASP Dependency Check (backend only) | `mvn dependency-check:check` | Any dependency has CVSS >= 8 and isn't suppressed |
| npm audit (frontend only) | `npm audit --omit=dev --audit-level=high` | Any runtime dependency has a high/critical advisory |
| Trivy Scan (both) | `trivy image --severity CRITICAL --exit-code 1 --ignore-unfixed` | Any *fixable* CRITICAL CVE in the built image |
| Docker Scout (both, optional) | `docker scout cves --only-severity critical --exit-code` | Never fails the build — `catchError` caps it at `UNSTABLE` |
| Update GitOps Values | `scripts/update-image-tag.sh <service> <tag>` | Push fails after 3 rebase-and-retry attempts |
| Wait for Argo CD Sync | `argocd app wait --health --sync` | Argo CD doesn't report Synced+Healthy within 300s |

## Why Trivy blocks but Docker Scout doesn't

Running two full vulnerability scanners as equally-blocking gates means
every finding either tool disagrees about (different CVE databases,
different severity scoring) becomes a pipeline outage someone has to
adjudicate. Trivy is the one blocking gate; Docker Scout runs as a second
opinion that surfaces in the build's `UNSTABLE` status without stopping
delivery — a deliberate choice, not an oversight. See
`docs/08-Assignments.md` for swapping in Grype as a third option to
compare against.

## The commit that actually deploys

```bash
git show --stat HEAD  # after a pipeline run, on gitops-relevant commits
```

Every deploy has exactly one corresponding Git commit:
`chore(gitops): bump backend image tag to 47 [skip ci]`, touching exactly
one file. This is the audit trail GitOps is actually for — "what's
running in production" is always answerable by `git log
helm/enterprise-app/values-images/`.

## Argo CD's reconciliation loop (independent of Jenkins)

Argo CD polls the Git repository (default every 3 minutes) and reacts to
webhooks if configured, comparing the rendered Helm output against live
cluster state on every pass — completely independent of whether Jenkins
is running, healthy, or even installed. If Jenkins is down for a day, any
commit anyone pushes to `values-images/*.yaml` by hand still gets deployed
by Argo CD. That decoupling is the point.

## Next

Continue to [06-Troubleshooting.md](./06-Troubleshooting.md).
