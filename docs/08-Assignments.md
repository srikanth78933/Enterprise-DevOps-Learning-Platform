# Student Assignments — Project 2: CD to AWS EKS

## Beginner

1. Add a `readinessProbe`/`livenessProbe` tuning pass: the current
   `initialDelaySeconds` values are guesses. Measure actual backend startup
   time (`kubectl logs` timestamps) and set values that are neither too
   eager (probe fails before the app is up) nor too lax (slow failure
   detection).

## Intermediate

2. Write a `PodDisruptionBudget` for the `backend` Deployment that
   guarantees at least 1 pod stays available during voluntary disruptions
   (like a node drain), and test it by draining a node while watching pod
   status.
3. The `mysql-secret`/`backend-secret` creation commands in
   `docs/03-Installation.md` are manual. Write a script that generates
   random strong passwords and creates both secrets consistently (so they
   never drift out of sync) in one step.

## Advanced

4. Replace the static IAM user credentials (`AWS_ACCESS_KEY_ID`/
   `AWS_SECRET_ACCESS_KEY`) with an OIDC-federated Jenkins identity that
   assumes a role via STS, eliminating long-lived credentials from Jenkins
   entirely. Document the IAM trust policy you used.

## Submission

Open a PR against `project-02-cd-eks`. Include `kubectl get pods,hpa,ingress
-n enterprise-devops` output showing a healthy deployment.
