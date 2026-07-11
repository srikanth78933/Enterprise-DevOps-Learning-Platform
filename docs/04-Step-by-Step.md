# Step-by-Step Walkthrough (main branch)

This walks through exercising every module once, end to end, so you know the
baseline application works before moving to `project-01-ci-pipeline`.

## 1. Create a Department

- Navigate to **Departments → Add Department**
- Fill in Name = `Engineering`, Code = `ENG`, Location = `Bengaluru`
- Save — you're redirected to the department list and see the new row

## 2. Create an Employee

- Navigate to **Employees → Add Employee**
- Fill in the required fields; pick `Engineering` from the Department dropdown
- Save — the employee list shows the new row with the resolved department name

## 3. Create a Project

- Navigate to **Projects → Add Project**
- Set Status = `IN_PROGRESS`, pick the same department
- Save

## 4. Confirm the Dashboard aggregates correctly

- Navigate to **Dashboard**
- Employee/Department/Project counts should reflect what you just created,
  and "Active Projects" should count the one you set to `IN_PROGRESS`

## 5. Edit and delete

- Edit the employee's designation, save, confirm it persists
- Delete the project via the confirm dialog, confirm it disappears from the list

## 6. Check Health and About

- **Health** should show `status: UP`
- **About** should list all five modules

## 7. Run the backend test suite

```bash
cd backend
mvn test
```

Expect all `EmployeeServiceTest`, `DepartmentServiceTest`, `ProjectServiceTest`,
and `DepartmentControllerTest` cases to pass.

## 8. Run the frontend test suite

```bash
cd frontend
npm test
```

## Next

Continue to [05-Flow.md](./05-Flow.md) to understand what happens under the
hood during step 2.
