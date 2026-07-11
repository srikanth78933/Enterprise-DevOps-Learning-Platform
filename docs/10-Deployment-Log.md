# Deployment Log — Getting Both Microservices Live via Helm

A record of the one-time, mostly-manual actions taken against the real
Jenkins host and AWS account to get `project-03-cicd-helm-microservices`
running end to end for the first time. Same purpose as
`project-02-cd-eks`'s `docs/10-Deployment-Log.md` — this isn't a generic
walkthrough, it's what actually happened getting *this* deployment
working, kept here because most of it (Jenkins/cluster state) isn't
visible anywhere else in git.

## 1. This branch was forked before Project 2's fixes landed

Same Terraform placeholders, credential IDs, region/cluster constants,
Docker Hub namespace, `ddl-auto`, and missing executable bits that
Project 2 had already fixed — all mirrored here and fixed the same way.
See the earlier log entries in this same doc series (commit history on
this branch) for the full list; not repeating it here.

## 2. Project 2's raw `kubectl`-managed resources were still live

Before Helm ever touched this cluster, `backend`, `mysql`, their
Services, the ConfigMap, the HPA, and the old `enterprise-devops-ingress`
were all still running from Project 2's `kubectl apply -k` — none of them
owned by Helm. Installing the chart as-is would have collided on every
one of those names (the umbrella chart deliberately uses the same,
non-release-prefixed names — see `architecture/helm-chart-structure.md`).

Resolved by:
- **Adopting** `mysql-pvc` into Helm's ownership via annotation/label
  patch (`meta.helm.sh/release-name`, `meta.helm.sh/release-namespace`,
  `app.kubernetes.io/managed-by: Helm`) — preserves the actual data and
  the already-provisioned EBS volume, no new volume, no downtime for the
  claim itself.
- **Deleting** the raw Deployments/Services/ConfigMap/HPA/Ingress — safe
  to recreate, brief downtime while Helm's versions came up. Deployment
  selectors aren't the same format Helm's chart generates, so adoption
  (vs. delete+recreate) wasn't an option for those without hitting
  Kubernetes' immutable-selector restriction.

## 3. Node.js didn't exist on the Jenkins agent at all

`frontend/Jenkinsfile` needs `npm ci`/`npm test`/`npm run build`, and
unlike `jdk`/`maven` it isn't declared as a Jenkins `tools` entry (per
`jenkins/README.md` step 2, it's expected directly on the agent's PATH).
Installed Node.js 20 LTS via NodeSource; confirmed the `jenkins` system
user can see it before relying on it in a real build.

## 4. First Helm install: backend/mysql fine, frontend expected to fail

Ran `helm upgrade --install ... --wait --timeout 5m` by hand to establish
the baseline release. `backend` and `mysql` came up `Running` immediately
(the backend image already existed from Projects 1-2). `frontend` sat in
`ImagePullBackOff` — expected, since no frontend pipeline had ever run to
push a real image yet. `helm status` reported the release as `failed`
purely because `--wait` couldn't confirm frontend too; the manifests it
did apply were correct and live.

## 5. `helm upgrade --wait` made the backend pipeline fail on its own success

Once `enterprise-backend-pipeline` existed and ran for real, its Helm
Upgrade stage hung the full 5 minutes and failed — `--wait` blocks on
*every* Deployment in the release, not just the one being upgraded, so it
kept waiting on the still-broken frontend pod. Fixed by removing
`--wait --timeout 5m` from both Jenkinsfiles' `helm upgrade` calls (and
the matching `scripts/helm-upgrade-backend.sh` / `helm-upgrade-frontend.sh`)
— the `Verify` stage's `kubectl rollout status deployment/<service>`
right after already does the correctly-scoped check. `scripts/helm-install.sh`
keeps `--wait` deliberately, since a first-time full install *should*
wait for everything.

## 6. Added Helm chart storage as an OCI artifact

Per a design discussion: both Jenkinsfiles now package and push
`helm/enterprise-app` to `oci://registry-1.docker.io/devopstraining064`
(versioned `1.0.0-<build>`) as a "Package & Push Helm Chart" stage before
`Helm Upgrade`, purely for a versioned/auditable record — reusing the
existing Docker Hub registry and credential rather than standing up a
separate chart repository (e.g. Nexus's `helm` format). Doesn't change
what `helm upgrade` actually deploys from (still the checked-out
directory, not a pulled package).

## 7. Final validation — both microservices live

After both pipelines ran successfully:

```
NAME                        READY   STATUS    RESTARTS   AGE
backend-7d4674ff65-chjp4    1/1     Running   0          5m31s
backend-7d4674ff65-dd5h7    1/1     Running   0          4m45s
frontend-597d99bbc8-dswzg   1/1     Running   0          98s
frontend-597d99bbc8-qvmb4   1/1     Running   0          112s
mysql-5759bcbf4c-kpvmc      1/1     Running   0          35m
```

- `backend` 2/2, `frontend` 2/2, `mysql` 1/1 — all `Running`
- `mysql-pvc` still `Bound` to the same volume adopted in step 2 — no
  data loss across the whole Project 2 → Project 3 transition
- `enterprise-app-ingress` serving both `/api` (backend) and `/`
  (frontend) through the same NLB Project 2 originally provisioned
- Helm release `enterprise-app` at `STATUS: deployed`, incrementing one
  revision per pipeline run (`helm list -n enterprise-devops`)

This confirms the actual point of Project 3: `enterprise-backend-pipeline`
and `enterprise-frontend-pipeline` each shipped independently, without
either one's run touching the other's currently-deployed image tag.

## 8. Frontend loaded, but every page showed "Network Error"

Pods, Service, and Ingress were all healthy — the actual React bundle
had `http://localhost:8080/api` baked in as its API base URL.
`frontend/src/api/apiClient.js` falls back to that value when
`REACT_APP_API_BASE_URL` isn't set, and React inlines env vars at
`npm run build` time, not runtime (the "env-config.js injected in
Kubernetes" idea mentioned in that file's comment was never actually
built). `frontend/Jenkinsfile`'s Build stage never set it, so every
visitor's browser tried to reach `localhost:8080` on their own machine.

Fixed by setting `REACT_APP_API_BASE_URL=/api` (a relative path, not an
absolute hostname) in the Build stage — since the Ingress serves both
services on the same host, a relative base URL resolves correctly
regardless of hostname and needs no CORS configuration at all (same
origin). Required a full pipeline re-run to take effect - an
already-built, already-pushed image can't be patched in place, only
rebuilt.

Also needed at the time, unrelated to the app itself: the Ingress
hostname (`enterprise-devops.example.com`) wasn't real public DNS, so
browser access required a local hosts-file entry pointing it at the
Ingress Load Balancer's IP. Superseded by step 9 below - that workaround
is no longer necessary.

## 9. Removed the Ingress host restriction entirely

The hosts-file requirement above was actually a symptom of a design
choice worth reconsidering, not just a one-off inconvenience: the
Ingress rule required `Host: enterprise-devops.example.com` specifically
(a fake hostname with no real DNS), so *any* real access - a teammate's
browser, a monitoring check, anything - needed the same local hack.

Changed `helm/enterprise-app/templates/ingress.yaml` so `host:` is only
included when `global.ingressHost` is actually set (now empty by
default in `values.yaml`) - an omitted `host:` matches any Host header,
so the raw Load Balancer address works directly in any browser with zero
setup. `global.ingressHost` stays available for a real deployment with
an owned domain (`values-prod.yaml.example` already demonstrated this
use case). Also dropped `CORS_ALLOWED_ORIGINS`' dependency on that same
hostname (now `"*"`, since the frontend's relative-path API calls are
same-origin and don't need CORS at all - see step 8).

## Net result

Same shape as Project 2's log: most of the real work here was cluster
and Jenkins-host state that never shows up in a diff — adopting a live
PVC instead of destroying it, installing a missing language runtime, and
a Helm flag that looked correct but was scoped too broadly for an
independent-pipelines design. The actual application/chart code changes
were small; the environment around them needed more.
