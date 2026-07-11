import React, { useEffect, useState } from 'react';
import { getAllEmployees } from '../api/employeeApi';
import { getAllDepartments } from '../api/departmentApi';
import { getAllProjects } from '../api/projectApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';

function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([getAllEmployees(), getAllDepartments(), getAllProjects()])
      .then(([employees, departments, projects]) => {
        setStats({
          employees: employees.length,
          departments: departments.length,
          projects: projects.length,
          activeProjects: projects.filter((p) => p.status === 'IN_PROGRESS').length,
        });
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Loader label="Loading dashboard..." />;

  return (
    <div>
      <div className="page-header">
        <h1>Dashboard</h1>
      </div>
      <ErrorBanner message={error} />
      {stats && (
        <div className="card-grid">
          <div className="card stat-card">
            <h3>Employees</h3>
            <div className="stat-value">{stats.employees}</div>
          </div>
          <div className="card stat-card">
            <h3>Departments</h3>
            <div className="stat-value">{stats.departments}</div>
          </div>
          <div className="card stat-card">
            <h3>Projects</h3>
            <div className="stat-value">{stats.projects}</div>
          </div>
          <div className="card stat-card">
            <h3>Active Projects</h3>
            <div className="stat-value">{stats.activeProjects}</div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Dashboard;
