# Step-by-Step Walkthrough — Project 1: Enterprise CI Pipeline

## 1. Trigger a clean build

Make a trivial change (e.g. a comment) in `backend/src/main/java/.../HealthController.java`,
commit, and push. If you configured a webhook, Jenkins builds automatically;
otherwise click **Build Now**.

## 2. Watch the Unit Test stage

Open the build's **Test Result** page once the "Unit Test" stage completes.
You should see all 26 tests (`DepartmentControllerTest`,
`DepartmentServiceTest`, `EmployeeServiceTest`, `ProjectServiceTest`) passing.

## 3. Break a test on purpose

Edit `backend/src/test/java/.../DepartmentServiceTest.java` and change an
`assertThat(...)` to an obviously wrong expectation. Push it.

- The pipeline should fail at **Unit Test**
- **SonarQube Analysis**, **Quality Gate**, and every later stage should be
  skipped — Jenkins declarative pipelines stop at the first failed stage by
  default
- Revert the change and push again to confirm it goes green

## 4. Break the Quality Gate on purpose

Temporarily lower test coverage (comment out a chunk of
`EmployeeServiceTest`) without deleting the code it tests. Push it.

- Unit Test still passes (fewer assertions, but no failures)
- **SonarQube Analysis** succeeds (analysis always "succeeds" — it's just a
  report)
- **Quality Gate** fails because coverage on new code dropped below the
  default threshold (80% on Sonar's default "Sonar way" gate)
- Confirm the pipeline aborts and no Docker image gets pushed for this
  build — revert and push again

## 5. Inspect the Parallel Stage

Open the Stage View for a successful build — "Publish Coverage Report" and
"Dependency Tree Audit" should show as running concurrently, both nested
under "Parallel Stage".

## 6. Confirm the pushed image runs

```bash
docker pull <your-namespace>/enterprise-devops-backend:latest
docker run --rm -p 8080:8080 \
  -e DB_URL=jdbc:mysql://host.docker.internal:3306/enterprise_devops \
  -e DB_USERNAME=devops_user -e DB_PASSWORD=devops_pass \
  <your-namespace>/enterprise-devops-backend:latest

curl http://localhost:8080/actuator/health
```

## Next

Continue to [05-Flow.md](./05-Flow.md) for what's happening inside each stage.
