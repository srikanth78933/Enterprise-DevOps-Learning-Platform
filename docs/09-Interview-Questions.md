# Interview Questions — Project 3: CI/CD with Helm & Independent Pipelines

## Helm fundamentals

1. What's the difference between a chart's `values.yaml` and a `-f
   custom-values.yaml` overlay, in terms of precedence? Where does `--set`
   fit in that order?
2. Explain what `--reuse-values` actually does, mechanically. Why is
   `--reuse-values` alone not equivalent to `helm upgrade` with no flags?
3. Why does the umbrella chart's `values.yaml` set values under top-level
   keys named exactly `frontend`, `backend`, `mysql`? What happens if you
   rename the `backend/` directory under `charts/` to `api/` but forget to
   rename the corresponding key in the parent's `values.yaml`?
4. What is `helm template` for, and how does it differ from `helm install
   --dry-run`?

## This chart specifically

5. Why does `backend/templates/deployment.yaml` use `envFrom: secretRef`
   pointing at `.Values.existingSecret` instead of the chart creating and
   templating a `Secret` object itself?
6. Why does `mysql`'s `_helpers.tpl` return a hardcoded name instead of
   the conventional `{{ .Release.Name }}-<chart>` pattern? What capability
   does the chart lose by doing this?
7. Walk through exactly what Kubernetes objects change (and which don't)
   when `backend/Jenkinsfile` runs `helm upgrade --set
   backend.image.tag=42 --reuse-values`.

## Pipeline architecture

8. What's the actual argument for splitting one Jenkinsfile into
   `backend/Jenkinsfile` and `frontend/Jenkinsfile`? What did the single
   combined pipeline (Projects 1-2) cost you that this fixes?
9. Both pipelines deploy to the same Helm release. What could go wrong if
   they ran concurrently, and what (if anything) protects against it?
10. If you had ten microservices instead of two, would you keep scaling
    this "one Jenkinsfile per service, one shared umbrella chart" pattern?
    What would start to hurt first?

## Looking ahead

11. This project still has Jenkins calling `helm upgrade` directly. What
    problems does that create for auditability and "what's actually
    running in production right now" that Project 4's GitOps approach is
    about to solve?

## Next

Continue to [10-Deployment-Log.md](./10-Deployment-Log.md) for what
actually happened getting both services deployed for real the first time.
