import axios from 'axios';

// In production the value is baked in at Docker build time (see docker/frontend.Dockerfile)
// or injected via env-config.js served alongside the app in Kubernetes (Project 2+).
const BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8080/api';

const apiClient = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const message = error.response?.data?.message || error.message || 'Unexpected error';
    return Promise.reject(new Error(message));
  }
);

export default apiClient;
