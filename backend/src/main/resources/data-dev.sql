-- Seed data for local development only.
-- Not loaded automatically; run manually against the dev database if you want sample rows to start with:
--   mysql -u devops_user -p enterprise_devops < data-dev.sql

INSERT INTO departments (name, code, location) VALUES
    ('Engineering', 'ENG', 'Bengaluru'),
    ('Human Resources', 'HR', 'Mumbai'),
    ('Finance', 'FIN', 'Hyderabad')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO employees (first_name, last_name, email, phone, designation, date_of_joining, salary, department_id) VALUES
    ('Asha', 'Rao', 'asha.rao@example.com', '9876543210', 'Backend Engineer', '2023-06-01', 950000.00, 1),
    ('Rahul', 'Mehta', 'rahul.mehta@example.com', '9876500000', 'DevOps Engineer', '2022-11-15', 1100000.00, 1),
    ('Priya', 'Nair', 'priya.nair@example.com', '9876511111', 'HR Manager', '2021-03-10', 850000.00, 2)
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name);

INSERT INTO projects (name, description, status, start_date, end_date, department_id) VALUES
    ('Platform Migration', 'Migrate monolith to microservices', 'IN_PROGRESS', '2026-01-01', NULL, 1),
    ('Payroll Automation', 'Automate monthly payroll processing', 'PLANNED', '2026-08-01', NULL, 3)
ON DUPLICATE KEY UPDATE name = VALUES(name);
