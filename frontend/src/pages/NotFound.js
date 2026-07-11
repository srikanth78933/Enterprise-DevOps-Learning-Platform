import React from 'react';
import { Link } from 'react-router-dom';

function NotFound() {
  return (
    <div className="empty-state">
      <h2>404 - Page not found</h2>
      <Link to="/" className="btn btn-primary">Back to Dashboard</Link>
    </div>
  );
}

export default NotFound;
