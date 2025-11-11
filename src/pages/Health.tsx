import { useEffect } from 'react';

export default function Health() {
  const healthData = {
    ok: true,
    status: "healthy",
    version: "1.0.0",
    buildTime: new Date().toISOString(),
    commitHash: import.meta.env.VITE_COMMIT_HASH || "unknown",
    environment: import.meta.env.MODE,
  };

  useEffect(() => {
    document.body.innerHTML = `<pre>${JSON.stringify(healthData, null, 2)}</pre>`;
    document.head.innerHTML = '<meta charset="UTF-8"><style>body { font-family: monospace; padding: 20px; }</style>';
  }, []);

  return (
    <pre style={{ fontFamily: 'monospace', padding: '20px' }}>
      {JSON.stringify(healthData, null, 2)}
    </pre>
  );
}
