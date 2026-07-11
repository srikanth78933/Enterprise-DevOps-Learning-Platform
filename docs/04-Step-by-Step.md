# Step-by-Step Walkthrough — Project 2: CD to AWS EKS

## 1. Confirm the baseline deploy works

After following `docs/03-Installation.md` end to end, confirm all pods are
healthy:

```bash
kubectl get pods -n enterprise-devops
```

Expect: 1 `mysql-*` pod, 2 `backend-*` pods, all `Running` and `1/1 Ready`.

## 2. Exercise the API through the Ingress

Using the load balancer hostname from step 3 of Installation, hit the API
with `curl -H "Host: ..."` (real DNS isn't configured for the placeholder
`enterprise-devops.example.com` host used in `ingress.yaml`) and walk
through the same CRUD flow as `main`'s `docs/04-Step-by-Step.md` — create
a department, an employee, a project:

```bash
curl -H "Host: enterprise-devops.example.com" http://<lb-hostname>/api/departments
```

## 3. Watch the HPA under load

```bash
kubectl get hpa -n enterprise-devops -w
```

In another terminal, generate load against the backend:

```bash
kubectl run load-generator --image=busybox --restart=Never -n enterprise-devops -- \
  /bin/sh -c "while true; do wget -q -O- http://backend:8080/api/employees; done"
```

Watch `CURRENT` CPU climb past the 70% target and `REPLICAS` scale up
toward 6. Clean up afterward: `kubectl delete pod load-generator -n enterprise-devops`.

## 4. Trigger a real deploy through Jenkins

Push a trivial backend change (as in Project 1's walkthrough) and let the
full pipeline run. Watch the **Deploy to EKS** and **Verify** stages in the
Jenkins console — you should see the rolling update happen with zero
downtime (old pods stay serving traffic until new ones pass their
readiness probe).

## 5. Confirm zero-downtime deploys

While a deploy is in progress (`kubectl rollout status deployment/backend
-n enterprise-devops`), hit the health endpoint in a tight loop from
another terminal:

```bash
while true; do curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Host: enterprise-devops.example.com" http://<lb-hostname>/api/health; sleep 0.5; done
```

You should see a continuous stream of `200`s with no gaps, even as pods
roll.

## Next

Continue to [05-Flow.md](./05-Flow.md).
