import { useEffect, useState } from 'react';
import api from '../services/api';
import Layout from '../components/Layout';

export default function Users() {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/users').then(res => setUsers(res.data)).finally(() => setLoading(false));
  }, []);

  const roleColor: Record<string, string> = {
    ADMIN: 'bg-red-100 text-red-700',
    TEAM_LEAD: 'bg-purple-100 text-purple-700',
    SUPPORT_AGENT: 'bg-blue-100 text-blue-700',
    EMPLOYEE: 'bg-gray-100 text-gray-700',
  };

  return (
    <Layout>
      <h2 className="text-2xl font-bold mb-6">Users</h2>
      <div className="bg-white rounded shadow overflow-hidden">
        {loading ? <p className="p-4 text-gray-500">Loading...</p> : (
          <table className="min-w-full text-sm">
            <thead><tr className="bg-gray-50 text-left text-xs text-gray-500 uppercase">
              <th className="px-4 py-3">Name</th><th className="px-4 py-3">Email</th>
              <th className="px-4 py-3">Role</th><th className="px-4 py-3">Team</th>
              <th className="px-4 py-3">Status</th>
            </tr></thead>
            <tbody>
              {users.map(u => (
                <tr key={u.id} className="border-t hover:bg-gray-50">
                  <td className="px-4 py-3 font-medium">{u.firstName} {u.lastName}</td>
                  <td className="px-4 py-3 text-gray-500">{u.email}</td>
                  <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded text-xs ${roleColor[u.role] ?? 'bg-gray-100'}`}>{u.role}</span></td>
                  <td className="px-4 py-3 text-gray-500 text-xs">{u.teamName ?? '—'}</td>
                  <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded text-xs ${u.active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>{u.active ? 'Active' : 'Inactive'}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </Layout>
  );
}
