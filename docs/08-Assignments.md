# Student Assignments — Project 3: CI/CD with Helm & Independent Pipelines

## Beginner

1. Add a `NOTES.txt` section (or extend the existing one) that prints the
   currently-deployed `backend.image.tag` and `frontend.image.tag` after
   every `helm upgrade` — useful at a glance without a separate `helm get
   values` call.
2. Parameterize `mysql.persistence.size` so a student can override it at
   install time without editing `values.yaml`, and document the override
   in `helm/enterprise-app/README.md`.

## Intermediate

3. Add a `helm test` hook (a `Job` template annotated
   `helm.sh/hook: test`) that curls the backend's `/actuator/health`
   endpoint from inside the cluster and fails if it's not `UP`. Wire
   `helm test enterprise-app -n enterprise-devops` into both Jenkinsfiles
   right after the `Verify` stage.
4. The frontend chart's HPA is disabled by default
   (`autoscaling.enabled: false`). Enable it, tune sensible thresholds for
   a static-asset-serving NGINX pod (hint: it'll almost never be CPU-bound
   the way the backend is — think about what *should* trigger scaling for
   a service like this, if anything).
5. Add a pre-install/pre-upgrade Helm hook that verifies `backend-secret`
   and `mysql-secret` both exist before proceeding, turning today's late
   "INSTALLATION FAILED" error into an earlier, clearer one.

## Advanced

6. Extract `frontend`, `backend`, and `mysql` into genuinely independent,
   versioned charts (each with its own `Chart.yaml` version bumped
   separately, published to a chart repository like ChartMuseum or OCI),
   and have the umbrella chart's `dependencies:` pin specific versions
   instead of using `file://` paths. Explain the tradeoff this introduces
   for local development.
7. Design (and implement, if you're ambitious) a scheme for ephemeral
   per-PR preview environments using this chart — you'll need to solve the
   fixed-resource-name problem described in
   `architecture/helm-chart-structure.md` first.

## Submission

Open a PR against `project-03-cicd-helm-microservices`. Include
`helm list -n enterprise-devops` and `helm get values enterprise-app -n
enterprise-devops` output.
