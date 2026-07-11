# Cleanup — Project 2: CD to AWS EKS

Order matters — Kubernetes-created load balancers must go before the
cluster that hosts their controller does.

## 1. Remove the Ingress and Ingress Controller first

```bash
kubectl delete -f kubernetes/ingress.yaml
helm uninstall ingress-nginx -n ingress-nginx
```

Confirm the AWS Network Load Balancer it created is actually gone (AWS
Console → EC2 → Load Balancers) before proceeding — it bills hourly even
if nothing is using it.

## 2. Remove the application

```bash
kubectl delete -k kubernetes/
kubectl delete secret backend-secret mysql-secret -n enterprise-devops
```

## 3. Destroy the AWS infrastructure

```bash
./scripts/terraform-destroy.sh
```

This checks for lingering Ingress resources and warns you before
proceeding — confirm you actually completed steps 1-2 first.

## 4. Confirm nothing billable is left

AWS Console, check for orphans in each of:

- EC2 → Load Balancers (should be empty)
- EC2 → Elastic IPs (should be empty — the NAT Gateway's EIP releases with
  the NAT Gateway, but confirm)
- EKS → Clusters (should be empty)
- VPC → Your VPCs (the `enterprise-devops-dev-vpc` should be gone)

## 5. Local cleanup

```bash
rm -rf backend/target frontend/build frontend/node_modules
rm -f terraform/tfplan terraform/terraform.tfstate*
```

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
