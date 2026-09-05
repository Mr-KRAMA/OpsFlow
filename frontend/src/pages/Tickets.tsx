import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';
import Layout from '../components/Layout';

export default function Tickets() {
  const [tickets, setTickets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    api.get('/tickets').then(res => setTickets(res.data)).finally(() => setLoading(false));
  }, []);

  const filtered = tickets.filter(t => {
    const matchSearch = t.title.toLowerCase().includes(search.toLowerCase()) || t.ticketNumber.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter ? t.status === statusFilter : true;
    return matchSearch && matchStatus;
  });

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
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">All Tickets</h2>
        <button onClick={() => navigate('/tickets/new')} className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm">
          + Create Ticket
        </button>
      </div>

      <div className="flex gap-3 mb-4">
        <input
          type="text" placeholder="Search by title or ticket #..."
          className="border rounded px-3 py-2 flex-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
          value={search} onChange={e => setSearch(e.target.value)}
        />
        <select
          className="border rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
          value={statusFilter} onChange={e => setStatusFilter(e.target.value)}
        >
          <option value="">All Statuses</option>
          {['NEW','ASSIGNED','IN_PROGRESS','PENDING','RESOLVED','CLOSED'].map(s => (
            <option key={s} value={s}>{s}</option>
          ))}
        </select>
      </div>

      <div className="bg-white rounded shadow overflow-hidden">
        {loading ? <p className="p-4 text-gray-500">Loading...</p>
          : filtered.length === 0 ? <p className="p-4 text-gray-500">No tickets found.</p>
          : (
            <table className="min-w-full text-sm">
              <thead><tr className="bg-gray-50 text-left text-xs text-gray-500 uppercase">
                <th className="px-4 py-3">Ticket #</th><th className="px-4 py-3">Title</th>
                <th className="px-4 py-3">Status</th><th className="px-4 py-3">Priority</th>
                <th className="px-4 py-3">Assigned To</th><th className="px-4 py-3">Created</th>
              </tr></thead>
              <tbody>
                {filtered.map(t => (
                  <tr key={t.id} className="border-t hover:bg-gray-50">
                    <td className="px-4 py-3"><Link to={`/tickets/${t.id}`} className="text-blue-600 hover:underline font-mono text-xs">{t.ticketNumber}</Link></td>
                    <td className="px-4 py-3 font-medium">{t.title}</td>
                    <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded text-xs ${statusColor[t.status] ?? 'bg-gray-100'}`}>{t.status}</span></td>
                    <td className="px-4 py-3"><span className={`text-xs ${priorityColor[t.priority] ?? ''}`}>{t.priority ?? '—'}</span></td>
                    <td className="px-4 py-3 text-gray-500 text-xs">{t.assignedAgentName ?? 'Unassigned'}</td>
                    <td className="px-4 py-3 text-gray-400 text-xs">{new Date(t.createdAt).toLocaleDateString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
      </div>
    </Layout>
  );
}
