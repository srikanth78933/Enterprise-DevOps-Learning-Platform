import apiClient from './apiClient';

const RESOURCE = '/departments';

export const getAllDepartments = () => apiClient.get(RESOURCE).then((res) => res.data);

export const getDepartmentById = (id) => apiClient.get(`${RESOURCE}/${id}`).then((res) => res.data);

export const createDepartment = (department) => apiClient.post(RESOURCE, department).then((res) => res.data);

export const updateDepartment = (id, department) =>
  apiClient.put(`${RESOURCE}/${id}`, department).then((res) => res.data);

export const deleteDepartment = (id) => apiClient.delete(`${RESOURCE}/${id}`);
