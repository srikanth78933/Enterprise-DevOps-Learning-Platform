import React, { useEffect, useState } from 'react';
import { getAbout } from '../api/healthApi';
import Loader from '../components/Loader';
import ErrorBanner from '../components/ErrorBanner';

function About() {
  const [about, setAbout] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    getAbout()
      .then(setAbout)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Loader label="Loading..." />;

  return (
    <div>
      <div className="page-header">
        <h1>About</h1>
      </div>
      <ErrorBanner message={error} />
      {about && (
        <div className="card">
          <h2>{about.name}</h2>
          <p>{about.description}</p>
          <p>Version: {about.version}</p>
          <p>Modules: {about.modules?.join(', ')}</p>
        </div>
      )}
    </div>
  );
}

export default About;
