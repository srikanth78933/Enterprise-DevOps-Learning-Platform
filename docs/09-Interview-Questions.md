# Interview Questions — Project 1: Enterprise CI Pipeline

## Jenkins

1. What's the difference between declarative and scripted Jenkins
   pipelines? Why does this repo use declarative?
2. Explain what `disableConcurrentBuilds()` protects against in this
   Jenkinsfile, and describe a failure mode it prevents.
3. Why does the `Unit Test` stage have its own `post { always { junit ... } }`
   block instead of one global `post` block at the pipeline level?
4. What's the security reason for injecting Docker Hub credentials via
   `credentials('dockerhub-credentials')` instead of hardcoding them, and
   how does Jenkins prevent them from leaking into console logs?

## SonarQube

5. Why is `waitForQualityGate` a separate stage from `SonarQube Analysis`
   rather than one combined stage?
6. What happens if the SonarQube webhook is never configured? Why doesn't
   the pipeline just fail fast in that case?
7. What's the difference between "overall code" and "new code" quality
   gate conditions, and which one usually matters more for CI on a mature
   codebase?

## Docker

8. Why does this pipeline use a different Dockerfile
   (`backend-ci.Dockerfile`) than the one used for local development
   (`backend.Dockerfile`)?
9. Why is `docker login` done via `--password-stdin` instead of `-p`?
10. What's the purpose of tagging the same image with both the build number
    and `latest`? What's the risk of only ever pushing `latest`?

## General CI/CD

11. Why does `Package Jar` use `-DskipTests` when tests already ran in a
    prior stage? What's the difference between `-DskipTests` and
    `-Dmaven.test.skip=true`?
12. If you had to add a second microservice to this pipeline, would you
    extend this single Jenkinsfile or create a second one? What factors
    would drive that decision? (Hint: see how Project 3 answers this.)
