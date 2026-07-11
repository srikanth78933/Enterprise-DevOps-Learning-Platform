# Student Assignments — Project 1: Enterprise CI Pipeline

## Beginner

1. Add a `Checkstyle` or `Spotless` stage between **Maven Build** and
   **Unit Test** that fails the pipeline on formatting violations. Document
   which plugin you chose and why in a short note in your PR.
2. Change `IMAGE_TAG` to also include the short Git commit SHA (e.g.
   `42-a1b2c3d`) instead of just the build number, so an image tag alone
   tells you exactly what commit it came from.

## Intermediate

3. Add a `Trivy` image scan stage after **Docker Build** that fails the
   pipeline on any `CRITICAL` vulnerability, before the push stage runs.
   (This is a preview of Project 4 — don't worry about making it perfect.)
4. Make the pipeline post a Slack or email notification on failure only
   (not on every success) using the `post { failure { ... } }` block.
5. Parameterize the Jenkinsfile so `IMAGE_NAME` and `SONARQUBE_ENV` can be
   overridden at build time instead of hardcoded, without breaking the
   default values used by CI.

## Advanced

6. Convert the repeated `dir('backend') { sh '...' }` pattern into a
   Jenkins Shared Library function, and rewrite the Jenkinsfile to call it.
   Explain in your PR why shared libraries matter once you have more than
   one pipeline in an organization.
7. Add a manual approval gate (`input` step) before **Push Docker Image**
   that only appears on the `project-01-ci-pipeline` branch itself (not on
   feature branches building via multibranch pipeline) — research
   `when { branch '...' }` conditions to do this cleanly.

## Submission

Open a PR against `project-01-ci-pipeline`. Include a screenshot of a
passing pipeline run and, for assignment 3 or 6, the relevant stage output.
