# Troubleshooting — Project 3: CI/CD with Helm & Independent Pipelines

## `helm lint` fails with "chart metadata is missing these dependencies"

`Chart.yaml` in `helm/enterprise-app/` must explicitly declare `frontend`,
`backend`, and `mysql` under `dependencies:` (even though they're local,
unpacked chart directories under `charts/` that Helm loads automatically
regardless). This is a lint-time check, not a runtime requirement — but
keep the declaration anyway, it's genuinely useful documentation of what
the umbrella chart is made of.

## `helm upgrade` resets the other service's image tag

You (or a script) forgot `--reuse-values`. See `docs/05-Flow.md` — this is
the single most common mistake when hand-running Helm commands during this
project. Fix: `helm rollback enterprise-app <previous-revision>` to
recover, then re-run with `--reuse-values`.

## `Error: INSTALLATION FAILED: ... backend-secret" not found`

The chart references `backend-secret`/`mysql-secret` by name
(`existingSecret` in each subchart's values) but doesn't create them.
Create them first — see `helm/enterprise-app/README.md`.

## A single-service pipeline's `helm upgrade` times out even though that service is fine

`helm upgrade --wait` blocks until **every** Deployment in the release is
Ready, not just the one you `--set`. If the other service currently has a
broken pod (e.g. `ImagePullBackOff` because its own pipeline has never
successfully pushed an image yet), a backend-only or frontend-only
upgrade will hang for the full `--timeout` waiting on a pod it never
touched, then fail the whole build - even though the service it actually
upgraded came up fine underneath. This is why `backend/Jenkinsfile` and
`frontend/Jenkinsfile` don't pass `--wait` to `helm upgrade` at all; the
`Verify` stage's `kubectl rollout status deployment/<service>` right
after already does the correctly-scoped check for just that one service.
(`scripts/helm-install.sh` is the one place `--wait` is still correct -
a first-time install of the whole release should wait for everything.)

If you hit this with a hand-run `helm upgrade`, check
`kubectl get pods -n enterprise-devops` for the *other* service before
assuming the one you just upgraded is broken.

## Two Jenkins jobs both try to deploy at once and one fails

`helm upgrade` on the same release from two concurrent invocations can
race (Helm holds a per-release lock, so the second one usually just fails
cleanly with "another operation is in progress" rather than corrupting
anything). If your webhook triggers are firing both pipelines simultaneously
for unrelated changes, that's usually a sign the webhook path filters
(`backend/**` vs `frontend/**`) aren't actually scoped correctly — see
`jenkins/README.md` step 7.

## Ingress works for `/` but not `/api`, or vice versa

Confirm both entries actually rendered:
`helm template enterprise-app helm/enterprise-app | grep -A5 "kind: Ingress"`.
A common mistake when hand-editing `helm/enterprise-app/templates/ingress.yaml`
is putting the more specific path (`/api`) *after* the catch-all (`/`) —
NGINX Ingress evaluates paths in the order Kubernetes returns them, and
`pathType: Prefix` on `/` will happily also match `/api/employees` if it's
evaluated first.

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
