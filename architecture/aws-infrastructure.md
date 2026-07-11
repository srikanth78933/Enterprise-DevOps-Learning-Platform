# AWS Infrastructure — Project 2

What `terraform/` provisions, and how the deployed application sits inside it.

```mermaid
flowchart TB
    subgraph AWS["AWS Account - us-east-1"]
        subgraph VPC["VPC 10.20.0.0/16"]
            subgraph PublicSubnets["Public Subnets (2 AZs)"]
                IGW[Internet Gateway]
                NAT[NAT Gateway]
                NLB[NGINX Ingress<br/>Network Load Balancer]
            end

            subgraph PrivateSubnets["Private Subnets (2 AZs)"]
                subgraph EKS["EKS Cluster"]
                    NodeGroup[Managed Node Group<br/>2-4x t3.medium]
                    subgraph NS["Namespace: enterprise-devops"]
                        FE[frontend Deployment<br/>2 replicas]
                        BE[backend Deployment<br/>2-6 replicas via HPA]
                        MySQL[mysql Deployment<br/>1 replica + PVC]
                    end
                end
            end
        end

        IAM1[IAM: EKS Cluster Role]
        IAM2[IAM: Node Group Role]
        OIDC[OIDC Provider<br/>for future IRSA use]
    end

    Internet((Internet)) --> IGW --> NLB --> FE
    NLB --> BE
    NodeGroup -.-> NAT -.-> IGW
    BE --> MySQL
    IAM1 -.-> EKS
    IAM2 -.-> NodeGroup
    OIDC -.-> EKS
```

## Why one NAT Gateway instead of one per AZ

A production deployment typically runs one NAT Gateway per AZ so an AZ
failure doesn't take down outbound internet access for the other AZ's
nodes. This project uses a single shared NAT Gateway to keep the
per-hour cost of running the learning environment down — see
`terraform/modules/vpc/main.tf` for exactly where you'd change this
(duplicate the `aws_nat_gateway` resource per AZ and adjust the private
route tables to match).

## Why worker nodes are private-subnet-only

Standard EKS best practice: nodes have no direct route from the internet;
all inbound traffic arrives through the Ingress-provisioned Load Balancer
in the public subnets. Reduces the attack surface to exactly one
internet-facing entry point.

Full pipeline diagram (including the new Deploy/Verify stages):
[`pipeline-diagram.md`](./pipeline-diagram.md).
