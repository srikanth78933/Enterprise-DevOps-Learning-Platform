import apiClient from './apiClient';

export const getHealth = () => apiClient.get('/health').then((res) => res.data);

export const getAbout = () => apiClient.get('/about').then((res) => res.data);
