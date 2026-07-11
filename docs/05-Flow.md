# Request Flow (main branch)

See the sequence diagram in
[`/diagrams/application-architecture.md`](../diagrams/application-architecture.md)
for the visual version of this flow (Employee creation example).

## Read path — `GET /api/employees`

1. `EmployeeController.getAllEmployees()` receives the request
2. Delegates to `EmployeeService.getAllEmployees()`
3. `EmployeeServiceImpl` calls `EmployeeRepository.findAll()` (Spring Data JPA
   generates the SQL)
4. Each `Employee` entity is mapped to an `EmployeeDTO` (including resolving
   `departmentName` from the lazy-loaded `Department` association, inside the
   `@Transactional(readOnly = true)` boundary so the lazy load succeeds)
5. Controller returns `200 OK` with the DTO list as JSON

## Write path — `POST /api/employees`

1. `@Valid @RequestBody EmployeeDTO` triggers Bean Validation
   (`@NotBlank`, `@Email`, `@PositiveOrZero`, etc.)
2. If validation fails, `MethodArgumentNotValidException` is thrown before
   the controller method body runs, and `GlobalExceptionHandler` converts it
   into a `400` with a `fieldErrors` map the frontend renders under each field
3. If validation passes, `EmployeeServiceImpl.createEmployee()`:
   - Checks `existsByEmail()` to enforce uniqueness (a DB-level unique
     constraint also exists as the last line of defense)
   - Loads the referenced `Department` or throws `ResourceNotFoundException`
   - Saves the new `Employee`, returns the mapped DTO
4. Controller returns `201 Created`

## Error contract

Every error response (404, 400, 500) follows the same `ApiError` shape:

```json
{
  "timestamp": "2026-07-11T10:15:30Z",
  "status": 404,
  "error": "Not Found",
  "message": "Employee not found with id: 42",
  "path": "/api/employees/42",
  "fieldErrors": null
}
```

The frontend's `apiClient.js` response interceptor unwraps `message` so
every page can display errors with a single `<ErrorBanner message={...} />`.

## Next

Continue to [06-Troubleshooting.md](./06-Troubleshooting.md).
