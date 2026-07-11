# Student Assignments (main branch)

Complete these before moving to `project-01-ci-pipeline` — they force you to
actually read the code you'll soon be shipping through a pipeline.

## Beginner

1. Add a new field `employeeCode` (unique, required) to the Employee module:
   entity, DTO (+ validation), Flyway-free schema update via `ddl-auto`,
   frontend form field, and list column. Add a Mockito test asserting
   duplicate `employeeCode` is rejected.
2. Add a `GET /api/departments/{id}/employees` endpoint that returns all
   employees in a department. Add a frontend link from the department list
   to a filtered employee view.

## Intermediate

3. Add pagination to `GET /api/employees` (`page`, `size` query params using
   Spring Data's `Pageable`). Update `EmployeeList.js` to show
   Previous/Next controls.
4. Add a `PATCH /api/projects/{id}/status` endpoint that only updates the
   `status` field (not a full replace like `PUT`). Write both a service unit
   test and a `@WebMvcTest` controller test for it.
5. Replace the `window.confirm`-style delete flow (already using
   `ConfirmDialog`) with an undo toast instead of a blocking confirmation —
   discuss the UX tradeoff in a short paragraph in your PR description.

## Advanced

6. Introduce a `ProjectMember` join entity (many-to-many between `Employee`
   and `Project` with a `role` column) without breaking any existing
   endpoint or test.
7. Add optimistic locking (`@Version`) to `Employee` and write a test that
   proves a stale update is rejected with a `409 Conflict` (you'll need a new
   `GlobalExceptionHandler` case for `ObjectOptimisticLockingFailureException`).

## Submission

Open a PR against your fork's `main` branch. Your PR description should
state which assignment(s) you completed and how you tested them — this
mirrors what you'll be graded on once code review gates are added to the
pipeline in later projects.
