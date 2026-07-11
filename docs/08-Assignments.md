# Student Assignments — Project 2: CD to AWS EKS

## Beginner

1. Change `node_desired_size`/`node_min_size`/`node_max_size` in
   `terraform.tfvars` to run a single-node cluster (cheaper for solo
   learning) and re-apply. Explain in a short note what breaks (hint:
   `backend-hpa.yaml`'s `minReplicas: 2` plus pod anti-affinity you don't
   have yet).
2. Add a `readinessProbe`/`livenessProbe` tuning pass: the current
   `initialDelaySeconds` values are guesses. Measure actual backend startup
   time (`kubectl logs` timestamps) and set values that are neither too
   eager (probe fails before the app is up) nor too lax (slow failure
   detection).

## Intermediate

3. Add a second NAT Gateway (one per AZ) to `terraform/modules/vpc/` and
   update the private route tables accordingly, so an AZ outage doesn't
   take down outbound connectivity for the other AZ's nodes. Document the
   cost difference in your PR.
4. Write a `PodDisruptionBudget` for the `backend` Deployment that
   guarantees at least 1 pod stays available during voluntary disruptions
   (like a node drain), and test it by draining a node while watching pod
   status.
5. The `mysql-secret`/`backend-secret` creation commands in
   `docs/03-Installation.md` are manual. Write a script that generates
   random strong passwords and creates both secrets consistently (so they
   never drift out of sync) in one step.

## Advanced

6. Replace the static IAM user credentials (`aws-access-key-id`/
   `aws-secret-access-key`) with an OIDC-federated Jenkins identity that
   assumes a role via STS, eliminating long-lived credentials from Jenkins
   entirely. Document the IAM trust policy you used.
7. Add a `terraform plan` stage to the Jenkinsfile that runs on every PR
   (posting the plan as a PR comment) without ever running `apply`
   automatically — infrastructure changes should be human-approved. Decide
   and justify where the approval gate goes.

## Submission

Open a PR against `project-02-cd-eks`. Include `kubectl get pods,hpa,ingress
-n enterprise-devops` output showing a healthy deployment.
