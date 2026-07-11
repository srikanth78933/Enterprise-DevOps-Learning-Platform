# Jenkins Setup — Project 1: Enterprise CI Pipeline

One-time setup for the Jenkins controller before the root `Jenkinsfile` will
run successfully. This version is wired to this deployment's actual
infrastructure:

| Service | URL |
|---|---|
| Jenkins | http://15.237.252.11:8080 |
| SonarQube | http://35.180.226.19:9000 |
| Nexus | http://13.36.239.212:8081 |
| Docker Hub | docker.io/devopstraining064 |

None of the credentials for these are in this repo — every value below
gets entered directly into Jenkins' own credential store through its UI,
never into a file.

## 1. Install plugins

Install everything listed in [`plugins.txt`](./plugins.txt) — Manage
Jenkins → Plugins → Available plugins.

## 2. Configure tools

Manage Jenkins → Tools — confirm these already exist with these **exact**
names (the Jenkinsfile references them by name):

| Tool type | Name (must match Jenkinsfile) |
|---|---|
| JDK | `java21` |
| Maven | `maven3.9.16` |

## 3. Configure the SonarQube server

Manage Jenkins → Credentials → add a **Secret text** credential:
- ID: `sonarqube-token` (or any ID — only used in step 3b below, not referenced elsewhere)
- Secret: the `jenkins-token` value from SonarQube (Administration → Security → Users → Tokens)

Manage Jenkins → System → SonarQube servers → Add:
- Name: `sonarqube-server` (must match `SONARQUBE_ENV` in the Jenkinsfile — exact match)
- Server URL: `http://35.180.226.19:9000`
- Server authentication token: select the `sonarqube-token` credential from step 3a

Then, in SonarQube itself: Administration → Webhooks → Create:
- Name: `jenkins`
- URL: `http://15.237.252.11:8080/sonarqube-webhook/`

Without this webhook, the `waitForQualityGate` step in the pipeline times
out after 10 minutes instead of returning as soon as analysis completes.

## 4. Add Docker Hub credentials

Manage Jenkins → Credentials → add a **Username with password** credential:
- ID: `dockerhub-credentials` (must match the Jenkinsfile)
- Username: `devopstraining064`
- Password: a Docker Hub **access token**, not your account password —
  Docker Hub → Account Settings → Security → New Access Token

## 5. Add Nexus credentials

Manage Jenkins → Credentials → add a **Username with password** credential:
- ID: `nexus-credentials` (must match the Jenkinsfile)
- Username / Password: your Nexus login

Confirm Nexus has the two repositories the pipeline deploys to (Nexus
ships with these by default under Repository → Repositories):
- `maven-releases`
- `maven-snapshots` ← this is the one actually used, since
  `backend/pom.xml`'s version is `1.0.0-SNAPSHOT` (see that file's comment
  for why — Nexus's release repo rejects redeploying the same version, and
  this pipeline deploys on every build)

## 6. Docker on the agent

Since Jenkins runs directly on its own EC2 (not in a container here),
confirm the `docker` CLI is installed and the `jenkins` system user can
run it without `sudo`:

```bash
# on the Jenkins EC2
docker --version
sudo usermod -aG docker jenkins   # if the jenkins user isn't already in the docker group
sudo systemctl restart jenkins
```

## 7. Create the pipeline job

New Item → `enterprise-devops-ci` → Pipeline → "Pipeline script from SCM"
→ Git → this repo's URL, branch `project-01-ci-pipeline`, script path
`Jenkinsfile`.

## Maven settings.xml

[`nexus-settings.xml`](./nexus-settings.xml) is the **real** file the
"Publish to Nexus" stage uses (`mvn deploy -s jenkins/nexus-settings.xml`)
— safe to commit because it only references the `NEXUS_CREDENTIALS_USR`/
`_PSW` environment variables Jenkins injects from the credential in step
5, never a literal secret.
[`settings.xml.example`](./settings.xml.example) is a separate, generic
template kept for reference/reuse in other environments.
