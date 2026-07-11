# Prerequisites (main branch — base application)

Before running the application locally, install:

| Tool | Minimum Version | Check |
|---|---|---|
| Java (JDK) | 21 | `java -version` |
| Maven | 3.9 | `mvn -version` |
| Node.js | 20 LTS | `node -version` |
| npm | 10 | `npm -version` |
| Docker | 24 | `docker -version` |
| Docker Compose plugin | v2 | `docker compose version` |
| Git | 2.40+ | `git --version` |
| MySQL client (optional, for manual queries) | 8.0 | `mysql --version` |

## Recommended editor setup

- IntelliJ IDEA or VS Code with the "Extension Pack for Java" and "Spring Boot Extension Pack"
- VS Code "ES7+ React/Redux/React-Native snippets" for the frontend

## Ports used locally

| Service | Port |
|---|---|
| React dev server | 3000 |
| Spring Boot API | 8080 |
| MySQL | 3306 |

Make sure nothing else on your machine is already bound to these ports.

## Next

Continue to [02-Architecture.md](./02-Architecture.md).
