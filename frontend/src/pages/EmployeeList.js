import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getAllEmployees, deleteEmployee } from '../api/employeeApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';
import ConfirmDialog from '../components/ConfirmDialog';

function EmployeeList() {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [pendingDelete, setPendingDelete] = useState(null);

  const loadEmployees = () => {
    setLoading(true);
    getAllEmployees()
      .then(setEmployees)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadEmployees();
  }, []);

  const handleDeleteConfirmed = () => {
    deleteEmployee(pendingDelete.id)
      .then(() => {
        setPendingDelete(null);
        loadEmployees();
      })
      .catch((err) => setError(err.message));
  };

  if (loading) return <Loader label="Loading employees..." />;

  return (
    <div>
      <div className="page-header">
        <h1>Employees</h1>
        <Link to="/employees/new" className="btn btn-primary">Add Employee</Link>
      </div>
      <ErrorBanner message={error} />

      {employees.length === 0 ? (
        <div className="empty-state">No employees yet. Create the first one.</div>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Designation</th>
              <th>Department</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {employees.map((emp) => (
              <tr key={emp.id}>
                <td>{emp.firstName} {emp.lastName}</td>
                <td>{emp.email}</td>
                <td>{emp.designation}</td>
                <td>{emp.departmentName}</td>
                <td className="actions-cell">
                  <Link to={`/employees/${emp.id}/edit`} className="btn btn-secondary">Edit</Link>
                  <button className="btn btn-danger" onClick={() => setPendingDelete(emp)}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <ConfirmDialog
        open={!!pendingDelete}
        title="Delete employee"
        message={pendingDelete ? `Delete "${pendingDelete.firstName} ${pendingDelete.lastName}"? This cannot be undone.` : ''}
        onConfirm={handleDeleteConfirmed}
        onCancel={() => setPendingDelete(null)}
      />
    </div>
  );
}

export default EmployeeList;
