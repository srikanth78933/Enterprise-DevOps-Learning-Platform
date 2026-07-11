import React, { useEffect, useState } from 'react';
import { getHealth } from '../api/healthApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';

function Health() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    getHealth()
      .then(setHealth)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Loader label="Checking backend health..." />;

  return (
    <div>
      <div className="page-header">
        <h1>Health</h1>
      </div>
      <ErrorBanner message={error} />
      {health && (
        <div className="card">
          <p>
            Status:{' '}
            <span className={health.status === 'UP' ? 'badge badge-up' : 'badge badge-down'}>
              {health.status}
            </span>
          </p>
          <p>Service: {health.service}</p>
          <p>Checked at: {health.timestamp}</p>
        </div>
      )}
    </div>
  );
}

export default Health;
