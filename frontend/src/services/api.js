import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_URL,
});

// Add token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (username, password) => api.post('/auth/login', { username, password }),
  register: (username, password) => api.post('/auth/register', { username, password }),
};

export const postsAPI = {
  getAll: () => api.get('/posts'),
  getOne: (id) => api.get(`/posts/${id}`),
  create: (title, content) => api.post('/posts', { title, content }),
  update: (id, title, content) => api.put(`/posts/${id}`, { title, content }),
  delete: (id) => api.delete(`/posts/${id}`),
};

export default api;
