# Project 1 — Enterprise CI Pipeline

Part of the [Enterprise DevOps Learning Platform](https://github.com/srikanth78933/Enterprise-DevOps-Learning-Platform).
This branch takes the base application from `main` and puts a
production-style Jenkins CI pipeline in front of it, wired to real Jenkins/
SonarQube/Nexus/Docker Hub infrastructure (see `jenkins/README.md` for the
exact endpoints). **No application code changed** — every file under
`backend/` and `frontend/` is identical to `main`; everything here is new
automation.

```
Git → Jenkins → Checkout → Maven Build → Unit Test → SonarQube → Quality Gate
    → Parallel Stage → Package Jar → Publish to Nexus → Docker Build → Push Docker Image
```

## What you'll learn

Git, Maven, Jenkins declarative pipelines, Docker, SonarQube quality gates,
JUnit reporting, publishing artifacts to a Nexus repository, and
publishing images to Docker Hub.

## What's new in this branch

```
├── Jenkinsfile                     Root pipeline definition
├── jenkins/
│   ├── README.md                   Jenkins controller setup (plugins, credentials, SonarQube, Nexus)
│   ├── plugins.txt                 Required plugin list
│   ├── nexus-settings.xml          Real settings.xml for the Nexus deploy stage (no secrets - see its header)
│   └── settings.xml.example        Generic Maven settings template for other environments
├── docker/
│   └── backend-ci.Dockerfile       Packages the Jenkins-built jar (see architecture/README.md for why)
├── architecture/
│   ├── README.md                   What changed vs. main, and why
│   └── pipeline-diagram.md         Mermaid flow + sequence diagrams
├── scripts/
│   ├── docker-build-push.sh        Run the package/build/push stages locally, no Jenkins needed
│   └── run-sonar-local.sh          Spin up a local SonarQube and analyze against it
└── docs/                           01-Prerequisites through 09-Interview-Questions, scoped to this project
```

`backend/pom.xml` also gained a `<distributionManagement>` block pointing
at Nexus, and the version changed to `1.0.0-SNAPSHOT` (see that file's
comment — Nexus's release repo rejects redeploying an existing version,
and this pipeline deploys on every build).

## Quick start

1. Read [`jenkins/README.md`](jenkins/README.md) and complete the one-time
   Jenkins controller setup (plugins, tool names, SonarQube server,
   Docker Hub credentials, Nexus credentials).
2. Point a new Jenkins Pipeline job at this branch, script path `Jenkinsfile`.
3. Trigger a build and watch it move through each stage in the classic
   stage view or Blue Ocean.

Full walkthrough: [`docs/03-Installation.md`](docs/03-Installation.md) and
[`docs/04-Step-by-Step.md`](docs/04-Step-by-Step.md).

## Next branch

`project-02-cd-eks` takes the image this pipeline pushes to Docker Hub and
deploys it to a Terraform-provisioned AWS EKS cluster.

```bash
git checkout project-02-cd-eks
```
