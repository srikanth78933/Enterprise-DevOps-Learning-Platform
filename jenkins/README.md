# Jenkins Setup — Project 1: Enterprise CI Pipeline

One-time setup for the Jenkins controller before the root `Jenkinsfile` will
run successfully.

## 1. Install plugins

Install everything listed in [`plugins.txt`](./plugins.txt) — Manage
Jenkins → Plugins → Available plugins, or via `jenkins-plugin-cli
--plugin-file jenkins/plugins.txt` if you're baking a custom controller image.

## 2. Configure tools

Manage Jenkins → Tools:

| Tool type | Name (must match Jenkinsfile) | Version |
|---|---|---|
| JDK | `jdk21` | Temurin 21 |
| Maven | `maven3` | 3.9.x |

## 3. Configure the SonarQube server

Manage Jenkins → System → SonarQube servers → Add:

- Name: `sonarqube-server` (must match `SONARQUBE_ENV` in the Jenkinsfile)
- Server URL: your SonarQube instance URL
- Server authentication token: create a credential of type "Secret text"
  from a SonarQube-generated token, select it here

Then, in SonarQube itself: Administration → Webhooks → add a webhook
pointing at `http://<jenkins-url>/sonarqube-webhook/`. Without this, the
`waitForQualityGate` step in the pipeline will time out after 10 minutes
instead of returning immediately.

## 4. Add Docker Hub credentials

Manage Jenkins → Credentials → add a "Username with password" credential:

- ID: `dockerhub-credentials` (must match the Jenkinsfile)
- Username / Password: your Docker Hub username and an access token
  (Docker Hub → Account Settings → Security → New Access Token — do not use
  your account password)

## 5. Docker on the agent

The agent running this pipeline needs a working `docker` CLI. If Jenkins
itself runs in a container, mount the host's Docker socket:

```bash
docker run -d --name jenkins \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  -p 8080:8080 -p 50000:50000 \
  jenkins/jenkins:lts
```

(Also install the `docker` CLI binary inside that same Jenkins container —
the Jenkins image does not ship it by default.)

## 6. Update the image name

Edit `IMAGE_NAME` at the top of the root `Jenkinsfile` to your own Docker
Hub namespace (`yourdockerhubuser/enterprise-devops-backend`) before running
the pipeline against a real registry.

## 7. Create the pipeline job

New Item → Pipeline → "Pipeline script from SCM" → Git → this repo URL,
branch `project-01-ci-pipeline`, script path `Jenkinsfile`.

## Maven settings.xml

See [`settings.xml.example`](./settings.xml.example) — it documents the
`pluginGroups` entry needed for the bare `mvn sonar:sonar` goal to resolve.
Do not commit a real `settings.xml` with credentials; use Jenkins' Config
File Provider plugin instead.
