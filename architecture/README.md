# Architecture — Project 4: GitOps with Argo CD

This project doesn't change the AWS infrastructure (`terraform/`, still
Project 2's cluster) or the Helm chart's *shape* (`helm/enterprise-app/`,
still Project 3's frontend/backend/mysql subcharts). What changes is who's
allowed to deploy: Jenkins loses cluster credentials entirely, and Argo CD
becomes the only path from "declared in Git" to "running in the cluster."

See [`pipeline-diagram.md`](./pipeline-diagram.md) for the full flow and
sequence diagrams.

## What's new vs. project-03-cicd-helm-microservices

| Added | Removed | Purpose |
|---|---|---|
| `gitops/projects/enterprise-devops-project.yaml` | — | Argo CD AppProject: scopes allowed repos/destinations |
| `gitops/applications/enterprise-app.yaml` | — | Argo CD Application: the desired-state declaration |
| `gitops/argocd/values.yaml` | — | Helm values for installing Argo CD itself |
| `helm/enterprise-app/values-images/{backend,frontend}.yaml` | — | Git-tracked, Jenkins-managed image tags Argo CD watches |
| OWASP Dependency Check (backend), `npm audit` (frontend), Trivy image scan (both), Docker Scout (both, optional) | — | Security scanning gates before an image ships |
| `scripts/update-image-tag.sh` | — | What replaced `helm upgrade`/`kubectl set image` in both Jenkinsfiles |
| — | AWS credentials from both Jenkinsfiles | Jenkins no longer needs cluster access at all |
| — | "Helm Upgrade" / "Deploy to EKS" stages | Replaced by "Update GitOps Values" + "Wait for Argo CD Sync" |

## Key design decisions

- **`values-images/*.yaml` live inside the Helm chart directory, not
  under `gitops/`.** Argo CD resolves Helm `valueFiles` relative to
  `source.path` and restricts `../` traversal outside it by default. Two
  tiny always-the-same-shape files inside the chart avoids that
  restriction entirely — see `gitops/README.md` for the full reasoning.
- **Jenkins loses `kubectl`/AWS credentials on purpose.** This is the
  actual point of GitOps, not an incidental cleanup: exactly one thing
  (Argo CD) can mutate cluster state for this application, which is what
  makes "what's running in production" always traceable to a specific Git
  commit.
- **`argocd app wait` is a read-only status check, not a deploy step.**
  Both Jenkinsfiles still confirm the deploy actually succeeded before
  reporting the build green — they just do it by *asking* Argo CD, not by
  *doing* the deploy themselves.
- **Docker Scout is non-blocking (`catchError` → `UNSTABLE`, never
  `FAILURE`).** Matches the spec's "(Optional)" framing — Trivy is the
  blocking image scanner; Docker Scout is a second opinion, not a second
  gate. Grype is documented as a swappable alternative in
  `docs/08-Assignments.md` rather than added as a third redundant scanner.
- **`targetRevision` in `gitops/applications/enterprise-app.yaml` points
  at this exact branch.** A real GitOps setup tracks a stable branch or a
  dedicated environment branch, not a per-lesson feature branch — this is
  a tutorial-scoped simplification, called out explicitly in that file's
  comments.

## Next branch

`project-05-logging-elk` adds centralized logging (Filebeat → Logstash →
Elasticsearch → Kibana) for both services, deployed the same GitOps way
this project established — a new subchart, same Argo CD Application
pattern.
