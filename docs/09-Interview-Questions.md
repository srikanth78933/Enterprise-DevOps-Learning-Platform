# Interview Questions — Project 2: CD to AWS EKS

## AWS / EKS

1. Why do worker nodes live in private subnets while the Ingress load
   balancer lives in public subnets? What's the actual attack-surface
   argument, not just "best practice says so"?
2. What is an EKS cluster's OIDC provider used for, given this project
   doesn't use IRSA yet?
3. Why does `aws eks update-kubeconfig` alone not guarantee `kubectl`
   access — what's the separate authorization layer, and where does it
   live?

## Kubernetes

4. Why does `mysql-deployment.yaml` use `strategy: Recreate` instead of the
   default `RollingUpdate`?
5. Walk through exactly what happens, step by step, when
   `kubectl set image deployment/backend backend=...` runs against a
   Deployment with 2 replicas and a readiness probe.
6. What's the difference between what the HPA (`backend-hpa.yaml`) and the
   VPA (`backend-vpa.yaml`) each control, and why is running both
   simultaneously against the same Deployment risky without care (hint:
   see the comment in `backend-vpa.yaml`)?

## CI/CD

7. Why does the Jenkinsfile call `kubectl apply -k` before `kubectl set
   image` rather than doing everything in one `kubectl apply`?
8. If the `Verify` stage's `kubectl rollout status` times out, has the
   deployment actually failed? What state is the cluster in at that
   point, and what would you check first?
