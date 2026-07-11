# Cleanup — Project 1: Enterprise CI Pipeline

## Stop and remove local Jenkins

```bash
docker stop jenkins && docker rm jenkins
docker volume rm jenkins_home   # only if you want to lose all job history/config
```

## Stop and remove local SonarQube

```bash
docker stop devops-sonarqube-local && docker rm devops-sonarqube-local
```

## Remove pushed Docker Hub images

Docker Hub → your repository → Tags → delete the tags created while
testing this project (build-number tags accumulate quickly).

## Remove local build artifacts

```bash
rm -rf backend/target
```

## Revoke tokens you created for this exercise

- SonarQube token (My Account → Security → Revoke)
- Docker Hub access token (Account Settings → Security → Revoke), if you
  created one solely for this learning exercise

## Next

Continue to [08-Assignments.md](./08-Assignments.md).
