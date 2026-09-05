import { useEffect, useState } from 'react';
import api from '../services/api';
import Layout from '../components/Layout';

export default function AuditLogs() {
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/audit').then(res => setLogs(res.data)).finally(() => setLoading(false));
  }, []);

  return (
    <Layout>
      <h2 className="text-2xl font-bold mb-6">Audit Logs</h2>
      <div className="bg-white rounded shadow overflow-hidden">
        {loading ? <p className="p-4 text-gray-500">Loading...</p> : logs.length === 0 ? (
          <p className="p-4 text-gray-500">No audit logs yet.</p>
        ) : (
          <table className="min-w-full text-sm">
            <thead><tr className="bg-gray-50 text-left text-xs text-gray-500 uppercase">
              <th className="px-4 py-3">Action</th><th className="px-4 py-3">Entity</th>
              <th className="px-4 py-3">User</th><th className="px-4 py-3">Timestamp</th>
            </tr></thead>
            <tbody>
              {logs.map(l => (
                <tr key={l.id} className="border-t hover:bg-gray-50">
                  <td className="px-4 py-3"><span className="bg-blue-100 text-blue-700 px-2 py-0.5 rounded text-xs font-mono">{l.action}</span></td>
                  <td className="px-4 py-3 text-gray-500 text-xs">{l.entityType} #{l.entityId}</td>
                  <td className="px-4 py-3 text-gray-600">{l.userEmail}</td>
                  <td className="px-4 py-3 text-gray-400 text-xs">{new Date(l.timestamp).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </Layout>
  );
}
