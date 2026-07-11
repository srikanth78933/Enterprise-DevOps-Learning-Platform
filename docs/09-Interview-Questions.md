# Interview Questions (main branch — application fundamentals)

These cover the application layer only. DevOps/infra interview questions are
added per project branch (CI, EKS, Helm, GitOps, ELK, Prometheus).

## Spring Boot / Java

1. Why do the controllers in this codebase accept and return DTOs instead of
   JPA entities directly?
2. What does `@Transactional(readOnly = true)` buy you on the read methods,
   and why does removing it break `getAllEmployees()` (hint: lazy-loaded
   `Department`)?
3. Explain the difference between `spring.jpa.hibernate.ddl-auto: update`
   (dev) and `validate` (prod) — why is `update` unsafe in production?
4. How does `GlobalExceptionHandler` avoid duplicating error-handling logic
   across every controller?
5. Why is `open-in-view` set to `false` in `application.yml`, and what bug
   class does it prevent?

## Testing

6. Why do `EmployeeServiceTest` and friends use pure Mockito (`@Mock`,
   `@InjectMocks`) instead of loading the full Spring context?
7. What's the difference between the `@WebMvcTest` slice used in
   `DepartmentControllerTest` and a full `@SpringBootTest`? When would you
   need the latter?
8. `createDepartment_whenCodeExists_throwsException` asserts
   `verify(departmentRepository, never()).save(any())`. Why does this
   verification matter beyond just asserting the thrown exception?

## React

9. Why does `apiClient.js` centralize error handling in an axios response
   interceptor instead of each page catching raw axios errors?
10. Walk through what happens in `EmployeeForm.js` when editing an existing
    employee vs. creating a new one — how does one component serve both
    cases?
11. Why is department data fetched via `Promise.all` alongside the employee
    fetch in edit mode, rather than sequentially?

## System design (applied to this app)

12. This app has no authentication. If you had to add JWT-based auth with
    minimal disruption, which layers would you touch, and how would you keep
    the `GlobalExceptionHandler` pattern consistent for `401`/`403`
    responses?
13. The `Employee` → `Department` relationship is `@ManyToOne` with
    `FetchType.LAZY`. What would break if you switched it to `EAGER`, and
    under what circumstances would `EAGER` actually be the right call?
