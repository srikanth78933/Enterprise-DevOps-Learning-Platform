import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { getEmployeeById, createEmployee, updateEmployee } from '../api/employeeApi';
import { getAllDepartments } from '../api/departmentApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';

const emptyForm = {
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  designation: '',
  dateOfJoining: '',
  salary: '',
  departmentId: '',
};

function EmployeeForm() {
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
    if (isEdit) requests.push(getEmployeeById(id));

    Promise.all(requests)
      .then(([departmentList, employee]) => {
        setDepartments(departmentList);
        if (employee) {
          setForm({
            firstName: employee.firstName,
            lastName: employee.lastName,
            email: employee.email,
            phone: employee.phone || '',
            designation: employee.designation || '',
            dateOfJoining: employee.dateOfJoining || '',
            salary: employee.salary ?? '',
            departmentId: employee.departmentId,
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
      salary: form.salary === '' ? null : Number(form.salary),
      dateOfJoining: form.dateOfJoining || null,
    };

    const request = isEdit ? updateEmployee(id, payload) : createEmployee(payload);
    request
      .then(() => navigate('/employees'))
      .catch((err) => setError(err.message))
      .finally(() => setSaving(false));
  };

  if (loading) return <Loader label="Loading employee..." />;

  return (
    <div>
      <div className="page-header">
        <h1>{isEdit ? 'Edit Employee' : 'Add Employee'}</h1>
      </div>
      <ErrorBanner message={error} />

      <form className="card form-card" onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="firstName">First Name</label>
          <input id="firstName" name="firstName" value={form.firstName} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label htmlFor="lastName">Last Name</label>
          <input id="lastName" name="lastName" value={form.lastName} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label htmlFor="email">Email</label>
          <input id="email" name="email" type="email" value={form.email} onChange={handleChange} required />
        </div>

        <div className="form-group">
          <label htmlFor="phone">Phone</label>
          <input id="phone" name="phone" value={form.phone} onChange={handleChange} />
        </div>

        <div className="form-group">
          <label htmlFor="designation">Designation</label>
          <input id="designation" name="designation" value={form.designation} onChange={handleChange} />
        </div>

        <div className="form-group">
          <label htmlFor="dateOfJoining">Date of Joining</label>
          <input id="dateOfJoining" name="dateOfJoining" type="date" value={form.dateOfJoining} onChange={handleChange} />
        </div>

        <div className="form-group">
          <label htmlFor="salary">Salary</label>
          <input id="salary" name="salary" type="number" min="0" step="0.01" value={form.salary} onChange={handleChange} />
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
          <button type="button" className="btn btn-secondary" onClick={() => navigate('/employees')}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}

export default EmployeeForm;
