import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

jest.mock('./api/employeeApi', () => ({ getAllEmployees: () => Promise.resolve([]) }));
jest.mock('./api/departmentApi', () => ({ getAllDepartments: () => Promise.resolve([]) }));
jest.mock('./api/projectApi', () => ({ getAllProjects: () => Promise.resolve([]) }));

test('renders the navbar brand', () => {
  render(<App />);
  expect(screen.getByText(/Enterprise DevOps Platform/i)).toBeInTheDocument();
});

test('renders dashboard navigation links', () => {
  render(<App />);
  expect(screen.getByText('Employees')).toBeInTheDocument();
  expect(screen.getByText('Departments')).toBeInTheDocument();
  expect(screen.getByText('Health')).toBeInTheDocument();
});
