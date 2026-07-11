# Terraform — AWS EKS Infrastructure

Provisions the VPC, IAM roles, and EKS cluster + managed node group that
Project 2 deploys the application onto. See
[`/docs/02-Architecture.md`](../docs/02-Architecture.md) for the full
picture and [`/docs/03-Installation.md`](../docs/03-Installation.md) for
step-by-step usage.

## Layout

```
terraform/
├── main.tf                    Root module: wires vpc + iam + eks together
├── variables.tf                Root input variables (with sane defaults)
├── outputs.tf                  cluster_name, cluster_endpoint, VPC/subnet ids
├── providers.tf                AWS + TLS provider requirements
├── backend.tf                  Remote state placeholder (S3 + DynamoDB)
├── terraform.tfvars.example    Copy to terraform.tfvars and adjust
└── modules/
    ├── vpc/                    VPC, public/private subnets, IGW, single NAT gateway
    ├── iam/                    EKS cluster role + node group role
    └── eks/                    EKS control plane, managed node group, OIDC provider
```

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Or use [`/scripts/terraform-init-apply.sh`](../scripts/terraform-init-apply.sh)
which wraps the same three commands with basic guardrails.

## Cost note

This provisions real, billable AWS resources: one EKS control plane
(~$0.10/hr), 2× `t3.medium` worker nodes, and one NAT Gateway. Run
`terraform destroy` (or [`/scripts/terraform-destroy.sh`](../scripts/terraform-destroy.sh))
as soon as you're done experimenting — see
[`/docs/07-Cleanup.md`](../docs/07-Cleanup.md).
