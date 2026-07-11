import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { getDepartmentById, createDepartment, updateDepartment } from '../api/departmentApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';

const emptyForm = { name: '', code: '', location: '' };

function DepartmentForm() {
  const { id } = useParams();
  const isEdit = Boolean(id);
  const navigate = useNavigate();

  const [form, setForm] = useState(emptyForm);
  const [loading, setLoading] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!isEdit) return;
    getDepartmentById(id)
      .then((dept) => setForm({ name: dept.name, code: dept.code, location: dept.location || '' }))
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

    const request = isEdit ? updateDepartment(id, form) : createDepartment(form);
    request
      .then(() => navigate('/departments'))
      .catch((err) => setError(err.message))
      .finally(() => setSaving(false));
  };

  if (loading) return <Loader label="Loading department..." />;

  return (
    <div>
      <div className="page-header">
        <h1>{isEdit ? 'Edit Department' : 'Add Department'}</h1>
      </div>
      <ErrorBanner message={error} />

      <form className="card form-card" onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="name">Name</label>
          <input id="name" name="name" value={form.name} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label htmlFor="code">Code</label>
          <input id="code" name="code" value={form.code} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label htmlFor="location">Location</label>
          <input id="location" name="location" value={form.location} onChange={handleChange} />
        </div>

        <div className="form-actions">
          <button type="submit" className="btn btn-primary" disabled={saving}>
            {saving ? 'Saving...' : 'Save'}
          </button>
          <button type="button" className="btn btn-secondary" onClick={() => navigate('/departments')}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}

export default DepartmentForm;
