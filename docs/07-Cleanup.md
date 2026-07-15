# Cleanup — Project 4: GitOps with Argo CD

## 1. Delete the Argo CD Application (also deletes what it deployed)

```bash
kubectl delete -f gitops/applications/enterprise-app.yaml
```

The `resources-finalizer.argocd.argoproj.io` finalizer on the Application
(see that file) means this also removes the Deployments/Services/HPA/
Ingress it created — confirm the Ingress load balancer is actually gone
(AWS Console → EC2 → Load Balancers) before proceeding to infra teardown.

## 2. Remove the AppProject

```bash
kubectl delete -f gitops/projects/enterprise-devops-project.yaml
```

## 3. Uninstall Argo CD itself

```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## 4. Remove the Ingress Controller

```bash
helm uninstall ingress-nginx -n ingress-nginx
```

## 5. Remove secrets and PVC (only if you want the data gone)

```bash
kubectl delete secret backend-secret mysql-secret -n enterprise-devops
kubectl delete pvc mysql-pvc -n enterprise-devops
```

## 6. Revoke tokens created for this project

- The Argo CD `jenkins-ci` account token
  (`argocd account delete-token jenkins-ci <token-id>`)
- The GitHub PAT created for Jenkins' git write-back, if solely used for
  this learning exercise

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
