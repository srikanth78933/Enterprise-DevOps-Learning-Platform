# Installation — Project 1: Enterprise CI Pipeline

## 1. Run Jenkins locally

```bash
docker volume create jenkins_home
docker run -d --name jenkins \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8080:8080 -p 50000:50000 \
  jenkins/jenkins:lts

# Install the docker CLI inside the container so the pipeline's `docker build` works
docker exec -u root jenkins sh -c "apt-get update && apt-get install -y docker.io"

# First-run admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Visit http://localhost:8080, unlock with the password above, install
suggested plugins, then follow [`jenkins/README.md`](../jenkins/README.md)
for the CI-specific setup (plugins, tools, SonarQube server, Docker Hub
credentials).

## 2. Run SonarQube locally

```bash
./scripts/run-sonar-local.sh
```

Run it once to start the container, log in to http://localhost:9000
(default `admin`/`admin`, you'll be forced to change it), generate a token
under **My Account → Security**, then re-run with `SONAR_TOKEN=<token>`.

## 3. Create the Jenkins pipeline job

- New Item → name it `enterprise-ci-pipeline` → Pipeline
- Pipeline section → Definition: "Pipeline script from SCM"
- SCM: Git → your repo URL → Branch: `*/project-01-ci-pipeline`
- Script Path: `Jenkinsfile`
- Save, then **Build Now**

## 4. Watch it run

Open the build → Console Output, or the classic Stage View, and watch the
pipeline move through Checkout → Maven Build → Unit Test → SonarQube →
Quality Gate → Parallel Stage → Package Jar → Docker Build → Push Docker
Image.

## Verifying the install

- SonarQube dashboard shows a project named `enterprise-devops-backend`
  with a green quality gate
- Docker Hub shows a new image at `<your-namespace>/enterprise-devops-backend`
  tagged with both the Jenkins build number and `latest`
- The Jenkins build's "Test Result" trend shows 26 passing tests

## Next

Continue to [04-Step-by-Step.md](./04-Step-by-Step.md).
