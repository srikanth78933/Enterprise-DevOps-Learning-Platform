import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getAllProjects, deleteProject } from '../api/projectApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';
import ConfirmDialog from '../components/ConfirmDialog';

function ProjectList() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [pendingDelete, setPendingDelete] = useState(null);

  const loadProjects = () => {
    setLoading(true);
    getAllProjects()
      .then(setProjects)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadProjects();
  }, []);

  const handleDeleteConfirmed = () => {
    deleteProject(pendingDelete.id)
      .then(() => {
        setPendingDelete(null);
        loadProjects();
      })
      .catch((err) => setError(err.message));
  };

  if (loading) return <Loader label="Loading projects..." />;

  return (
    <div>
      <div className="page-header">
        <h1>Projects</h1>
        <Link to="/projects/new" className="btn btn-primary">Add Project</Link>
      </div>
      <ErrorBanner message={error} />

      {projects.length === 0 ? (
        <div className="empty-state">No projects yet. Create the first one.</div>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Status</th>
              <th>Department</th>
              <th>Start Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {projects.map((proj) => (
              <tr key={proj.id}>
                <td>{proj.name}</td>
                <td>{proj.status}</td>
                <td>{proj.departmentName}</td>
                <td>{proj.startDate}</td>
                <td className="actions-cell">
                  <Link to={`/projects/${proj.id}/edit`} className="btn btn-secondary">Edit</Link>
                  <button className="btn btn-danger" onClick={() => setPendingDelete(proj)}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <ConfirmDialog
        open={!!pendingDelete}
        title="Delete project"
        message={pendingDelete ? `Delete "${pendingDelete.name}"? This cannot be undone.` : ''}
        onConfirm={handleDeleteConfirmed}
        onCancel={() => setPendingDelete(null)}
      />
    </div>
  );
}

export default ProjectList;
