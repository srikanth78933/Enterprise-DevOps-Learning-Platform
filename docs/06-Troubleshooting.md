# Troubleshooting — Project 4: GitOps with Argo CD

## Argo CD Application stuck `OutOfSync` forever, never reconciles

Check `kubectl describe application enterprise-app -n argocd` for the
actual error. Common causes: `repoURL` in
`gitops/applications/enterprise-app.yaml` doesn't match what's allow-listed
in `gitops/projects/enterprise-devops-project.yaml`'s `sourceRepos`, or the
`targetRevision` branch doesn't exist / was force-pushed out from under it.

## `Error: secrets "backend-secret" not found` in the Application's sync error

Same root cause as Project 3 — Argo CD renders the chart the same way
`helm install` does, and it references `existingSecret` by name. Create
the secrets first; Argo CD doesn't create them for you (intentionally —
see `helm/enterprise-app/README.md`).

## `scripts/update-image-tag.sh` fails with "failed to push after 3 attempts"

Something else is committing to the branch concurrently faster than the
rebase-retry loop can keep up (rare with two files that never overlap,
but possible if a human is also pushing to the branch during a demo).
Re-run the pipeline, or push manually after investigating
`git log --oneline -5`.

## Jenkins pipeline re-triggers itself in a loop after every deploy

The webhook/polling trigger isn't actually scoped to `backend/**` /
`frontend/**` — see `jenkins/README.md` step 8's loop-avoidance note. Fix
the trigger's path filter; don't rely on the `[skip ci]` commit message
marker alone unless your specific Jenkins trigger plugin actually honors it
(many don't, by default).

## `argocd login` fails with a certificate error

The `--insecure` flag in both Jenkinsfiles' "Wait for Argo CD Sync" stage
is what allows this against the self-signed cert from
`gitops/argocd/values.yaml`'s `server.insecure: true` setting. If you
changed that to a real TLS setup, remove `--insecure` and ensure the
agent trusts the real certificate instead.

## Docker Scout stage shows `UNSTABLE` — is that a real problem?

Check the stage log for what it actually found. `UNSTABLE` here means
"Docker Scout found a critical CVE, but this doesn't block delivery" — it's
informational by design (see `architecture/README.md`). Treat repeated
`UNSTABLE` builds as a signal to investigate, not as noise to ignore
indefinitely.

## Self-heal demo doesn't revert the scaled replicas

Confirm `syncPolicy.automated.selfHeal: true` is actually set in
`gitops/applications/enterprise-app.yaml` and that the Application applied
successfully (`kubectl get application enterprise-app -n argocd -o
yaml | grep -A3 syncPolicy`). Also check Argo CD's reconciliation
interval hasn't been tuned up in your install — the default 3-minute
polling means `scripts/simulate-self-heal.sh`'s 5-minute wait should
always be enough, but a heavily loaded Argo CD controller can lag further.

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
