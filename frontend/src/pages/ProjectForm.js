import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { getProjectById, createProject, updateProject } from '../api/projectApi';
import { getAllDepartments } from '../api/departmentApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';

const STATUS_OPTIONS = ['PLANNED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED'];

const emptyForm = {
  name: '',
  description: '',
  status: 'PLANNED',
  startDate: '',
  endDate: '',
  departmentId: '',
};

function ProjectForm() {
  const { id } = useParams();
  const isEdit = Boolean(id);
  const navigate = useNavigate();

  const [form, setForm] = useState(emptyForm);
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const requests = [getAllDepartments()];
    if (isEdit) requests.push(getProjectById(id));

    Promise.all(requests)
      .then(([departmentList, project]) => {
        setDepartments(departmentList);
        if (project) {
          setForm({
            name: project.name,
            description: project.description || '',
            status: project.status,
            startDate: project.startDate || '',
            endDate: project.endDate || '',
            departmentId: project.departmentId,
          });
        } else if (departmentList.length > 0) {
          setForm((prev) => ({ ...prev, departmentId: departmentList[0].id }));
        }
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [id, isEdit]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setSaving(true);
    setError('');

    const payload = {
      ...form,
      departmentId: Number(form.departmentId),
      startDate: form.startDate || null,
      endDate: form.endDate || null,
    };

    const request = isEdit ? updateProject(id, payload) : createProject(payload);
    request
      .then(() => navigate('/projects'))
      .catch((err) => setError(err.message))
      .finally(() => setSaving(false));
  };

  if (loading) return <Loader label="Loading project..." />;

  return (
    <div>
      <div className="page-header">
        <h1>{isEdit ? 'Edit Project' : 'Add Project'}</h1>
      </div>
      <ErrorBanner message={error} />

      <form className="card form-card" onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="name">Name</label>
          <input id="name" name="name" value={form.name} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label htmlFor="description">Description</label>
          <textarea id="description" name="description" rows="3" value={form.description} onChange={handleChange} />
        </div>

        <div className="form-group">
          <label htmlFor="status">Status</label>
          <select id="status" name="status" value={form.status} onChange={handleChange} required>
            {STATUS_OPTIONS.map((status) => (
              <option key={status} value={status}>{status}</option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label htmlFor="startDate">Start Date</label>
          <input id="startDate" name="startDate" type="date" value={form.startDate} onChange={handleChange} />
        </div>

        <div className="form-group">
          <label htmlFor="endDate">End Date</label>
          <input id="endDate" name="endDate" type="date" value={form.endDate} onChange={handleChange} />
        </div>

        <div className="form-group">
          <label htmlFor="departmentId">Department</label>
          <select id="departmentId" name="departmentId" value={form.departmentId} onChange={handleChange} required>
            <option value="" disabled>Select a department</option>
            {departments.map((dept) => (
              <option key={dept.id} value={dept.id}>{dept.name}</option>
            ))}
          </select>
        </div>

        <div className="form-actions">
          <button type="submit" className="btn btn-primary" disabled={saving}>
            {saving ? 'Saving...' : 'Save'}
          </button>
          <button type="button" className="btn btn-secondary" onClick={() => navigate('/projects')}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}

export default ProjectForm;
