# Interview Questions — Project 2: CD to AWS EKS

## Terraform

1. Why are `vpc`, `iam`, and `eks` separate modules instead of one flat
   `main.tf`? What's the reusability/blast-radius argument?
2. What's stored in Terraform state, and why does `backend.tf` push for S3
   + DynamoDB remote state instead of the local `terraform.tfstate` file
   used by default?
3. Explain what `create_before_destroy` on the node group's `lifecycle`
   block protects against.

## AWS / EKS

4. Why do worker nodes live in private subnets while the Ingress load
   balancer lives in public subnets? What's the actual attack-surface
   argument, not just "best practice says so"?
5. What is the OIDC provider created in `terraform/modules/eks/main.tf`
   for, given this project doesn't use IRSA yet?
6. Why does `aws eks update-kubeconfig` alone not guarantee `kubectl`
   access — what's the separate authorization layer, and where does it
   live?

## Kubernetes

7. Why does `mysql-deployment.yaml` use `strategy: Recreate` instead of the
   default `RollingUpdate`?
8. Walk through exactly what happens, step by step, when
   `kubectl set image deployment/backend backend=...` runs against a
   Deployment with 2 replicas and a readiness probe.
9. What's the difference between what the HPA (`backend-hpa.yaml`) and the
   VPA (`backend-vpa.yaml`) each control, and why is running both
   simultaneously against the same Deployment risky without care (hint:
   see the comment in `backend-vpa.yaml`)?
10. Why does `ingress.yaml` route by path (`/api` vs `/`) rather than by
    separate hostnames for frontend and backend?

## CI/CD

11. Why does the Jenkinsfile call `kubectl apply -k` before `kubectl set
    image` rather than doing everything in one `kubectl apply`?
12. If the `Verify` stage's `kubectl rollout status` times out, has the
    deployment actually failed? What state is the cluster in at that
    point, and what would you check first?
