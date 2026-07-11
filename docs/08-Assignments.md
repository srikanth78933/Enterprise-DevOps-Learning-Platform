# Student Assignments — Project 4: GitOps with Argo CD

## Beginner

1. Swap Docker Scout for Grype in one Jenkinsfile (`grype
   <image>:<tag> --fail-on critical`, install via
   `curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin`).
   Compare its findings against Trivy's on the same image — do they agree?
2. Add a suppression to `backend/owasp-suppressions.xml` for a real
   finding (pick any CVE the scan reports), with a proper `<notes>`
   justification, and explain in your PR why it's genuinely a false
   positive or accepted risk — not just "to make the build pass."

## Intermediate

3. Configure a real Git webhook from GitHub/GitLab to Argo CD (instead of
   relying on the default 3-minute poll) so syncs happen within seconds of
   a Jenkins commit. Document the webhook URL and secret setup.
4. Add a second Argo CD `Application` for a `staging` namespace, pointed
   at a different `targetRevision` (e.g. a `staging` branch), and figure
   out how to promote a build from staging to production via Git (hint:
   this is usually a PR that copies a `values-images/*.yaml` change from
   one branch/path to another — design the promotion flow explicitly).
5. Write a Jenkins stage that fails the build if `argocd app wait` reports
   `Degraded` health specifically (not just any non-`Healthy` status),
   and explain the difference between `Progressing`, `Degraded`, and
   `Missing` health states.

## Advanced

6. Implement the "app of apps" pattern: an umbrella Argo CD Application
   whose source is the `gitops/applications/` directory itself, so adding
   a new `Application` YAML file to Git is all it takes to onboard a new
   service — no more manual `kubectl apply -f gitops/applications/...`.
7. Set up branch protection + required PR review on `values-images/*.yaml`
   changes specifically (via a CODEOWNERS entry), so Jenkins' automated
   commits still require human approval before Argo CD syncs them — model
   what a real "progressive delivery with a human gate" setup looks like
   without losing the audit trail GitOps provides.

## Submission

Open a PR against `project-04-gitops-argocd`. Include
`kubectl get application enterprise-app -n argocd -o yaml` showing
`Synced`/`Healthy` status, and the Trivy/OWASP scan output from a pipeline
run.
