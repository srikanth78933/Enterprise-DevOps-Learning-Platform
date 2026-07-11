# Application Architecture (main branch)

This is the baseline architecture of the application before any DevOps tooling
is layered on top in the project branches.

```mermaid
flowchart LR
    subgraph Client
        Browser[Browser]
    end

    subgraph Frontend["Frontend - React"]
        UI[React SPA<br/>Employee / Department / Project / Health / About]
    end

    subgraph Backend["Backend - Spring Boot"]
        API[REST API<br/>Controllers -> Services -> Repositories]
    end

    subgraph Data["Database"]
        DB[(MySQL 8)]
    end

    Browser --> UI
    UI -- "HTTP/JSON /api/*" --> API
    API -- "JPA/Hibernate" --> DB
```

## Module map

```mermaid
classDiagram
    class Department {
        Long id
        String name
        String code
        String location
    }
    class Employee {
        Long id
        String firstName
        String lastName
        String email
        String designation
        LocalDate dateOfJoining
        BigDecimal salary
    }
    class Project {
        Long id
        String name
        String description
        ProjectStatus status
        LocalDate startDate
        LocalDate endDate
    }
    Department "1" --> "many" Employee : department_id
    Department "1" --> "many" Project : department_id
```

## Request flow (Employee CRUD example)

```mermaid
sequenceDiagram
    participant U as User
    participant R as React (EmployeeForm)
    participant C as EmployeeController
    participant S as EmployeeServiceImpl
    participant D as DepartmentRepository
    participant E as EmployeeRepository
    participant DB as MySQL

    U->>R: Submit employee form
    R->>C: POST /api/employees
    C->>S: createEmployee(dto)
    S->>D: findById(departmentId)
    D->>DB: SELECT department
    DB-->>D: department row
    S->>E: existsByEmail(email)
    E->>DB: SELECT count
    DB-->>E: 0
    S->>E: save(employee)
    E->>DB: INSERT employee
    DB-->>E: generated id
    S-->>C: EmployeeDTO
    C-->>R: 201 Created
    R-->>U: Redirect to employee list
```

This diagram evolves in every subsequent project branch — see each
branch's `docs/02-Architecture.md` for the updated picture (CI pipeline,
EKS deployment, Helm release, GitOps flow, logging pipeline, monitoring
stack).
