# Installation — Project 2: CD to AWS EKS

## 1. Provision the infrastructure

```bash
./scripts/terraform-init-apply.sh
```

Review the plan carefully before confirming — this creates real AWS
resources. Takes 10-15 minutes (EKS control plane provisioning is slow).

## 2. Point kubectl at the new cluster

```bash
./scripts/configure-kubeconfig.sh
kubectl get nodes
```

You should see 2 nodes in `Ready` state.

## 3. Enable the Metrics Server (required for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## 4. Install the NGINX Ingress Controller (required for Ingress)

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

## 5. Create the real secrets (never commit these)

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
curl -H "Host: enterprise-devops.example.com" http://<lb-hostname>/
```

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
