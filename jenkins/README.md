# Jenkins Setup — Project 4: GitOps with Argo CD

One-time setup before `backend/Jenkinsfile` and `frontend/Jenkinsfile` will
run successfully. This carries over Project 3's steps 1-6 (plugins, tools,
SonarQube, Docker Hub credentials, Docker on the agent, image names)
unchanged, but **replaces** its steps 8-10 (AWS credentials, `kubectl`/
`helm`/`aws` CLI, cluster constants) — Jenkins no longer touches the
cluster at all in this project. Read `gitops/README.md` first if you
haven't already; it explains why.

## 1. Install plugins

Install everything listed in [`plugins.txt`](./plugins.txt) — Manage
Jenkins → Plugins → Available plugins, or via `jenkins-plugin-cli
--plugin-file jenkins/plugins.txt` if you're baking a custom controller image.

## 2. Configure tools

Manage Jenkins → Tools:

| Tool type | Name (must match `backend/Jenkinsfile`) | Version |
|---|---|---|
| JDK | `jdk21` | Temurin 21 |
| Maven | `maven3` | 3.9.x |

## 3. Configure the SonarQube server

Manage Jenkins → System → SonarQube servers → Add:

- Name: `sonarqube-server` (must match `SONARQUBE_ENV` in `backend/Jenkinsfile`)
- Server URL: your SonarQube instance URL
- Server authentication token: create a credential of type "Secret text"
  from a SonarQube-generated token, select it here

Then, in SonarQube itself: Administration → Webhooks → add a webhook
pointing at `http://<jenkins-url>/sonarqube-webhook/`.

## 4. Add Docker Hub credentials

Manage Jenkins → Credentials → add a "Username with password" credential:

- ID: `dockerhub-credentials` (must match both Jenkinsfiles)
- Username / Password: your Docker Hub username and an access token

## 5. Docker on the agent

```bash
docker run -d --name jenkins \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  -p 8080:8080 -p 50000:50000 \
  jenkins/jenkins:lts
```

(Also install the `docker` CLI binary inside that same Jenkins container.)

## 6. Update the image names

Edit `BACKEND_IMAGE` in `backend/Jenkinsfile` and `FRONTEND_IMAGE` in
`frontend/Jenkinsfile` to your own Docker Hub namespace.

## 7. Install security scanning tools on the agent

```bash
# Trivy (both Jenkinsfiles use this, blocking on fixable CRITICAL CVEs)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
  sh -s -- -b /usr/local/bin

# Docker Scout (optional stage - install the CLI plugin)
curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh -s --
```

OWASP Dependency Check (`backend/Jenkinsfile`) needs no separate install —
it's a Maven plugin already declared in `backend/pom.xml`, invoked via
`mvn dependency-check:check`. Its first run downloads the NVD CVE database
(can take 10+ minutes and needs outbound internet); consider caching
`~/.m2/repository/org/owasp/dependency-check-data` on the agent between
builds so this isn't repeated every run.

## 8. Add Git write-back credentials

Both Jenkinsfiles' "Update GitOps Values" stage commits and pushes to this
repository (see `scripts/update-image-tag.sh`). Manage Jenkins →
Credentials → add credentials Jenkins' git operations can authenticate
with — a "Username with password" credential using a GitHub Personal
Access Token (fine-grained, scoped to just this repo's Contents:
read/write) as the password, configured as the default credential for
this repo's Git SCM source (or wired via `withCredentials` + a credential
helper if you prefer not to rely on the SCM-level credential).

**Loop-avoidance**: configure the Jenkins webhook trigger (or SCM polling
filter) to fire only on changes under `backend/**` or `frontend/**` —
`scripts/update-image-tag.sh` only ever touches
`helm/enterprise-app/values-images/*.yaml`, which is outside both paths,
so Jenkins' own commits never re-trigger either pipeline. Confirm this is
actually configured; a misconfigured "any branch, any path" trigger here
creates a real infinite build loop.

## 9. Install the Argo CD CLI on the agent

```bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

## 10. Add an Argo CD auth token credential

Once Argo CD is installed and bootstrapped (see `gitops/README.md` and
`scripts/argocd-install.sh`), generate a token for CI use rather than
using the admin password:

```bash
argocd account generate-token --account jenkins-ci
```

(Create a dedicated `jenkins-ci` Argo CD account with read-only access
first — Manage Jenkins should never hold your Argo CD admin credentials.
See the Argo CD RBAC docs for `argocd-rbac-cm`.)

Manage Jenkins → Credentials → add a "Secret text" credential:

- ID: `argocd-auth-token` — value: the generated token

## 11. Create two pipeline jobs

- New Item → `enterprise-backend-pipeline` → Pipeline → "Pipeline script
  from SCM" → Git → this repo URL, branch `project-04-gitops-argocd`,
  script path `backend/Jenkinsfile`
- New Item → `enterprise-frontend-pipeline` → same repo/branch, script
  path `frontend/Jenkinsfile`

## 12. Bootstrap Argo CD and the first deploy

Before either pipeline's first run:

```bash
./scripts/argocd-install.sh      # installs Argo CD into the cluster
./scripts/argocd-bootstrap.sh    # registers the AppProject + Application
```

Create `backend-secret`/`mysql-secret` per
[`helm/enterprise-app/README.md`](../helm/enterprise-app/README.md) —
Argo CD's first sync will fail without them, same as a manual `helm
install` would.

## Maven settings.xml

See [`settings.xml.example`](./settings.xml.example) — unchanged from
Project 1.
