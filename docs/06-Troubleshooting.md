# Troubleshooting — Project 1: Enterprise CI Pipeline

## `waitForQualityGate` times out after 10 minutes

The SonarQube → Jenkins webhook isn't configured (or is pointed at the
wrong URL). Check SonarQube Administration → Webhooks — the URL must be
`http://<jenkins-url>/sonarqube-webhook/` (trailing slash matters) and
reachable from the SonarQube server's network, not just your browser's.

## `mvn sonar:sonar` fails with `Not authorized. Please check the properties sonar.login...`

Your SonarQube server credential in Jenkins (Manage Jenkins → System →
SonarQube servers) is missing, expired, or wrong. Regenerate a token in
SonarQube (My Account → Security) and update the Jenkins credential.

## `docker: command not found` on the Docker Build stage

The Jenkins agent doesn't have the Docker CLI installed, or (if Jenkins
itself runs in a container) the host's `docker.sock` isn't mounted. See
step 5 of [`jenkins/README.md`](../jenkins/README.md).

## `docker push` fails with `unauthorized: authentication required`

- Confirm the `dockerhub-credentials` credential ID matches exactly what's
  in the Jenkinsfile
- Confirm you used a Docker Hub **access token**, not your account password
  (Docker Hub deprecated password-based CI logins)
- Confirm `IMAGE_NAME` in the Jenkinsfile actually starts with your Docker
  Hub namespace — pushing to a namespace you don't own always 401s

## `mvn deploy` fails with `401 Unauthorized` against Nexus

The `nexus-credentials` Jenkins credential is missing/wrong, or the
credential IDs in `jenkins/nexus-settings.xml`'s `<servers>` block
(`nexus-releases`, `nexus-snapshots`) don't match `backend/pom.xml`'s
`<distributionManagement>` repository ids exactly — Maven silently uses
no authentication at all if the ids don't line up, rather than erroring
about the mismatch itself.

## `mvn deploy` fails with `400 Bad Request` / `repository does not allow updating assets`

You deployed a non-SNAPSHOT version twice. Nexus's `maven-releases` repo
is immutable by design — the same `groupId:artifactId:version` can only
be uploaded once. This is exactly why `backend/pom.xml`'s version is
`1.0.0-SNAPSHOT`, which resolves to `maven-snapshots` (redeployable) —
if you changed the version back to a fixed release number, either bump it
on every build or accept that only the first deploy of that version
succeeds.

## Quality Gate fails but you can't tell why

Open the SonarQube project dashboard (linked from the Jenkins build's
SonarQube widget, if the plugin is installed) — the specific failed
condition (e.g. "Coverage on New Code < 80%") is listed there, not in the
Jenkins console output.

## Build stuck at "Unit Test" forever

Check for a hung Spring context in a test — most likely a `@SpringBootTest`
someone added that's trying to reach a real database. This project's tests
are deliberately Mockito-only / `@WebMvcTest` slices specifically to avoid
this class of problem; keep new tests in that style.

## Next

Continue to [07-Cleanup.md](./07-Cleanup.md).
