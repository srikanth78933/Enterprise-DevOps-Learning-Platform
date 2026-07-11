import apiClient from './apiClient';

const RESOURCE = '/employees';

export const getAllEmployees = () => apiClient.get(RESOURCE).then((res) => res.data);

export const getEmployeeById = (id) => apiClient.get(`${RESOURCE}/${id}`).then((res) => res.data);

export const createEmployee = (employee) => apiClient.post(RESOURCE, employee).then((res) => res.data);

export const updateEmployee = (id, employee) =>
  apiClient.put(`${RESOURCE}/${id}`, employee).then((res) => res.data);

export const deleteEmployee = (id) => apiClient.delete(`${RESOURCE}/${id}`);
