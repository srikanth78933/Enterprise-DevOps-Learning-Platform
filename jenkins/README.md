# Jenkins Setup — Project 2: CD to AWS EKS

One-time setup for the Jenkins controller before the root `Jenkinsfile` will
run successfully. This extends Project 1's setup (steps 1-7 below) with AWS
credentials and `kubectl`/`aws` CLI access (steps 8-10) needed for the new
Deploy and Verify stages.

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

Edit `BACKEND_IMAGE` at the top of the root `Jenkinsfile` to your own
Docker Hub namespace before running the pipeline against a real registry.

## 7. Create the pipeline job

New Item → Pipeline → "Pipeline script from SCM" → Git → this repo URL,
branch `project-02-cd-eks`, script path `Jenkinsfile`.

## 8. Add AWS credentials

Provision an IAM user (or better, a role your Jenkins host can assume) with
permissions to call `eks:DescribeCluster` and to manage the EKS cluster's
Kubernetes RBAC (the IAM identity running `aws eks update-kubeconfig` must
also be mapped to a Kubernetes RBAC role — by default, whichever identity
created the cluster already has `system:masters`; grant others access via
the `aws-auth` ConfigMap if needed).

Manage Jenkins → Credentials → add two "Secret text" credentials:

- ID: `AWS_ACCESS_KEY_ID` — value: the IAM user's access key ID
- ID: `AWS_SECRET_ACCESS_KEY` — value: the IAM user's secret access key

(A minimal setup for learning. Production setups should use short-lived
STS credentials via an OIDC-federated Jenkins identity instead of a static
IAM user key — a Project 10 concern.)

## 9. Install `kubectl` and the `aws` CLI on the agent

```bash
# inside the Jenkins container/agent
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -m 0755 kubectl /usr/local/bin/kubectl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && ./aws/install
```

## 10. Update cluster/region constants

`EKS_CLUSTER_NAME` and `AWS_REGION` at the top of the Jenkinsfile must
match your existing cluster's actual name and region exactly — check the
AWS Console or `aws eks list-clusters --region <region>` if you're unsure.

## Maven settings.xml

See [`settings.xml.example`](./settings.xml.example) — it documents the
`pluginGroups` entry needed for the bare `mvn sonar:sonar` goal to resolve.
Do not commit a real `settings.xml` with credentials; use Jenkins' Config
File Provider plugin instead.
