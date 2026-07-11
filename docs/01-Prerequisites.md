# Prerequisites — Project 1: Enterprise CI Pipeline

This project assumes you've already completed the [`main`](../../tree/main)
branch prerequisites (JDK 21, Maven, Node, Docker). Additionally:

| Tool | Minimum Version | Check |
|---|---|---|
| Jenkins | 2.440+ (LTS) | Web UI → Manage Jenkins → System Information |
| SonarQube | 10.x Community Edition | Web UI footer |
| Docker Hub account | — | https://hub.docker.com |
| Git | 2.40+ | `git --version` |

## Accounts and access you need before starting

1. **Docker Hub account** with an access token (not your password) —
   Account Settings → Security → New Access Token.
2. **SonarQube instance** — either the local one spun up by
   `scripts/run-sonar-local.sh`, or a shared team instance with a
   personal access token you can generate.
3. **A Jenkins controller** you have admin access to (local Docker
   container is fine for learning — see [`jenkins/README.md`](../jenkins/README.md)).

## Ports used locally

| Service | Port |
|---|---|
| Jenkins | 8080 |
| SonarQube | 9000 |

If you're also running the `main` branch's docker-compose stack, note it
also uses 8080 for the backend API — don't run both at once on the same
host without remapping one of them.

## Next

Continue to [02-Architecture.md](./02-Architecture.md) (or the fuller
version in [`/architecture`](../architecture/README.md)).
