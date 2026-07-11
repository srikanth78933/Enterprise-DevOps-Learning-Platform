import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getAllDepartments, deleteDepartment } from '../api/departmentApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';
import ConfirmDialog from '../components/ConfirmDialog';

function DepartmentList() {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [pendingDelete, setPendingDelete] = useState(null);

  const loadDepartments = () => {
    setLoading(true);
    getAllDepartments()
      .then(setDepartments)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadDepartments();
  }, []);

  const handleDeleteConfirmed = () => {
    deleteDepartment(pendingDelete.id)
      .then(() => {
        setPendingDelete(null);
        loadDepartments();
      })
      .catch((err) => setError(err.message));
  };

  if (loading) return <Loader label="Loading departments..." />;

  return (
    <div>
      <div className="page-header">
        <h1>Departments</h1>
        <Link to="/departments/new" className="btn btn-primary">Add Department</Link>
      </div>
      <ErrorBanner message={error} />

      {departments.length === 0 ? (
        <div className="empty-state">No departments yet. Create the first one.</div>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Code</th>
              <th>Location</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {departments.map((dept) => (
              <tr key={dept.id}>
                <td>{dept.name}</td>
                <td>{dept.code}</td>
                <td>{dept.location}</td>
                <td className="actions-cell">
                  <Link to={`/departments/${dept.id}/edit`} className="btn btn-secondary">Edit</Link>
                  <button className="btn btn-danger" onClick={() => setPendingDelete(dept)}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <ConfirmDialog
        open={!!pendingDelete}
        title="Delete department"
        message={pendingDelete ? `Delete "${pendingDelete.name}"? This cannot be undone.` : ''}
        onConfirm={handleDeleteConfirmed}
        onCancel={() => setPendingDelete(null)}
      />
    </div>
  );
}

export default DepartmentList;
