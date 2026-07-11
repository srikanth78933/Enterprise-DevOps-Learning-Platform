import apiClient from './apiClient';

const RESOURCE = '/projects';

export const getAllProjects = () => apiClient.get(RESOURCE).then((res) => res.data);

export const getProjectById = (id) => apiClient.get(`${RESOURCE}/${id}`).then((res) => res.data);

export const createProject = (project) => apiClient.post(RESOURCE, project).then((res) => res.data);

export const updateProject = (id, project) =>
  apiClient.put(`${RESOURCE}/${id}`, project).then((res) => res.data);

export const deleteProject = (id) => apiClient.delete(`${RESOURCE}/${id}`);
