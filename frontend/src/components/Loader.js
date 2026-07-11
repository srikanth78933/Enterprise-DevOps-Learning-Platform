import React from 'react';

function Loader({ label = 'Loading...' }) {
  return <div className="loader">{label}</div>;
}

export default Loader;
