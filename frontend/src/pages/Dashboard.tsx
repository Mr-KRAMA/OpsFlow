import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../services/api';
import Layout from '../components/Layout';

export default function Dashboard() {
  const [stats, setStats] = useState<any>(null);
  const [tickets, setTickets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.allSettled([api.get('/tickets'), api.get('/dashboard/admin')])
      .then(([tRes, dRes]) => {
        if (tRes.status === 'fulfilled') setTickets(tRes.value.data);
        if (dRes.status === 'fulfilled') setStats(dRes.value.data);
      })
      .finally(() => setLoading(false));
  }, []);

  const total = stats?.totalTickets ?? tickets.length;
  const open = stats?.openTickets ?? tickets.filter(t => !['RESOLVED','CLOSED'].includes(t.status)).length;
  const resolved = stats?.resolvedTickets ?? tickets.filter(t => t.status === 'RESOLVED').length;
  const breached = stats?.slaBreachedTickets ?? 0;

  const statusColor: Record<string, string> = {
    NEW: 'bg-blue-100 text-blue-800', ASSIGNED: 'bg-purple-100 text-purple-800',
    IN_PROGRESS: 'bg-yellow-100 text-yellow-800', PENDING: 'bg-orange-100 text-orange-800',
    RESOLVED: 'bg-green-100 text-green-800', CLOSED: 'bg-gray-100 text-gray-800',
  };
  const priorityColor: Record<string, string> = {
    CRITICAL: 'text-red-600 font-bold', HIGH: 'text-red-500 font-bold',
    MEDIUM: 'text-yellow-600', LOW: 'text-green-600',
  };

  return (
    <Layout>
      <h2 className="text-2xl font-bold mb-6">Dashboard</h2>
      {loading ? <p className="text-gray-500">Loading...</p> : (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            {[
              { label: 'Total Tickets', value: total, color: 'border-blue-500' },
              { label: 'Open', value: open, color: 'border-yellow-500' },
              { label: 'Resolved', value: resolved, color: 'border-green-500' },
              { label: 'SLA Breached', value: breached, color: 'border-red-500' },
            ].map(s => (
              <div key={s.label} className={`bg-white p-4 rounded shadow border-l-4 ${s.color}`}>
                <p className="text-gray-500 text-sm">{s.label}</p>
                <p className="text-3xl font-bold mt-1">{s.value}</p>
              </div>
            ))}
          </div>

          <div className="bg-white rounded shadow">
            <div className="px-4 py-3 border-b flex justify-between items-center">
              <h3 className="font-bold text-lg">Recent Tickets</h3>
              <Link to="/tickets" className="text-sm text-blue-600 hover:underline">View all →</Link>
            </div>
            {tickets.length === 0 ? (
              <p className="p-4 text-gray-500 text-sm">No tickets yet. <Link to="/tickets/new" className="text-blue-600 hover:underline">Create one</Link></p>
            ) : (
              <table className="min-w-full text-sm">
                <thead><tr className="bg-gray-50 text-left text-xs text-gray-500 uppercase">
                  <th className="px-4 py-3">Ticket #</th><th className="px-4 py-3">Title</th>
                  <th className="px-4 py-3">Status</th><th className="px-4 py-3">Priority</th>
                  <th className="px-4 py-3">Created</th>
                </tr></thead>
                <tbody>
                  {tickets.slice(0, 8).map(t => (
                    <tr key={t.id} className="border-t hover:bg-gray-50">
                      <td className="px-4 py-3"><Link to={`/tickets/${t.id}`} className="text-blue-600 hover:underline font-mono text-xs">{t.ticketNumber}</Link></td>
                      <td className="px-4 py-3">{t.title}</td>
                      <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded text-xs ${statusColor[t.status] ?? 'bg-gray-100'}`}>{t.status}</span></td>
                      <td className="px-4 py-3"><span className={`text-xs ${priorityColor[t.priority] ?? ''}`}>{t.priority ?? '—'}</span></td>
                      <td className="px-4 py-3 text-gray-400 text-xs">{new Date(t.createdAt).toLocaleDateString()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}
    </Layout>
  );
}
