# Remote state - keeps Terraform state out of git and lets Jenkins and
# individual students share the same state safely (with locking).
#
# Backend configuration cannot use variables, so this is deliberately left
# as a placeholder. Bootstrap the S3 bucket + DynamoDB lock table once
# (see scripts/terraform-init-apply.sh), fill in the values below or pass
# them via `terraform init -backend-config=...`, then uncomment.
#
# terraform {
#   backend "s3" {
#     bucket         = "your-org-terraform-state"
#     key            = "enterprise-devops-platform/eks/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "your-org-terraform-locks"
#     encrypt        = true
#   }
# }
#
# Until you configure this, Terraform uses local state (terraform.tfstate
# in this directory) - fine for a single learner working solo, but never
# use local state for anything shared or long-lived.
