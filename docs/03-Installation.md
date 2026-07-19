# Installation — Project 2: CD to AWS EKS

## 1. Point kubectl at the existing cluster

```bash
export EKS_CLUSTER_NAME=eks-cluster   # or your cluster's actual name
export AWS_REGION=eu-west-3           # or your cluster's actual region
./scripts/configure-kubeconfig.sh
kubectl get nodes
```

You should see your worker nodes in `Ready` state.

## 2. Install the EBS CSI driver (required for the MySQL PVC)

`mysql-deployment.yaml`'s PVC needs a real volume provisioner. EKS doesn't
install one by default, and the in-tree `kubernetes.io/aws-ebs` provisioner
(what the `gp2` StorageClass names) is migrated to the CSI driver under the
hood on modern EKS — so without it, the PVC sits in `Pending` forever with
"waiting for external provisioner ebs.csi.aws.com" and nothing using it
(MySQL, then the backend) can ever start.

This needs an IAM role the driver assumes via IRSA, which needs the
cluster's OIDC provider registered in IAM first — skip provider creation if
you already have one:

```bash
CLUSTER_NAME=eks-cluster   # or your cluster's actual name
REGION=eu-west-3           # or your cluster's actual region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ISSUER=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" \
  --query "cluster.identity.oidc.issuer" --output text)
ISSUER_HOST_PATH=${ISSUER#https://}

# Skip this if `aws iam list-open-id-connect-providers` already shows one
# for this cluster.
THUMBPRINT=$(echo | openssl s_client -servername "${ISSUER_HOST_PATH%%/*}" \
  -showcerts -connect "${ISSUER_HOST_PATH%%/*}:443" 2>/dev/null \
  | openssl x509 -fingerprint -noout -sha1 | sed 's/sha1 Fingerprint=//I; s/://g')
aws iam create-open-id-connect-provider \
  --url "$ISSUER" --client-id-list sts.amazonaws.com \
  --thumbprint-list "$THUMBPRINT"

cat > /tmp/ebs-csi-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${ISSUER_HOST_PATH}"},
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {"StringEquals": {
      "${ISSUER_HOST_PATH}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
      "${ISSUER_HOST_PATH}:aud": "sts.amazonaws.com"
    }}
  }]
}
EOF

aws iam create-role --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file:///tmp/ebs-csi-trust-policy.json
aws iam attach-role-policy --role-name AmazonEKS_EBS_CSI_DriverRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

aws eks create-addon --cluster-name "$CLUSTER_NAME" --region "$REGION" \
  --addon-name aws-ebs-csi-driver \
  --service-account-role-arn "arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole"
```

Wait for it to become active before continuing:

```bash
aws eks describe-addon --cluster-name "$CLUSTER_NAME" --region "$REGION" \
  --addon-name aws-ebs-csi-driver --query "addon.status"
```

## 3. Enable the Metrics Server (required for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## 4. Install the NGINX Ingress Controller (required for Ingress)

Needs `helm` on whatever machine you run this from (`helm version` to
check; see [helm.sh/docs/intro/install](https://helm.sh/docs/intro/install/)
if it's missing — this is a one-time cluster setup step, not something
the Jenkins pipeline itself runs):

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

This provisions an AWS Network Load Balancer — wait for an external
address:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller -w
```

The Service gets a hostname almost immediately, but its DNS record can
take a minute or two to actually resolve — `curl: Could not resolve
host` right after this step is expected, not a failure; retry shortly.

## 5. Create the real secrets (never commit these)

If you're deploying through the Jenkins pipeline, the "Deploy to EKS" stage
now does this for you on every run (see `jenkins/README.md` step 8b for the
two credentials it needs) - the steps below are only for a manual/local
deploy via `scripts/deploy-to-eks.sh`.

```bash
kubectl create namespace enterprise-devops --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic backend-secret -n enterprise-devops \
  --from-literal=DB_USERNAME=devops_user \
  --from-literal=DB_PASSWORD='<choose-a-strong-password>' \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic mysql-secret -n enterprise-devops \
  --from-literal=MYSQL_USER=devops_user \
  --from-literal=MYSQL_PASSWORD='<same-password-as-above>' \
  --from-literal=MYSQL_ROOT_PASSWORD='<choose-a-strong-root-password>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## 6. Deploy the application

Either manually:

```bash
./scripts/deploy-to-eks.sh latest
```

...or extend your Project 1 Jenkins setup per [`jenkins/README.md`](../jenkins/README.md)
(steps 8-10 are new) and trigger the pipeline job pointed at this branch.

## 7. Verify

```bash
./scripts/verify-deployment.sh
```

Or manually, once you have the Ingress load balancer's hostname
(`kubectl get ingress -n enterprise-devops`):

```bash
curl -H "Host: enterprise-devops.example.com" http://<lb-hostname>/api/health
```

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
