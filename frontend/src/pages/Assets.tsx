import React, { useEffect, useState } from 'react';
import api from '../services/api';
import Layout from '../components/Layout';

export default function Assets() {
  const [assets, setAssets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ assetTag: '', deviceType: '', manufacturer: '', model: '', serialNumber: '', status: 'ACTIVE' });
  const [saving, setSaving] = useState(false);
  const [search, setSearch] = useState('');

  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAdmin = ['ADMIN', 'TEAM_LEAD'].includes(user.role);

  useEffect(() => {
    api.get('/assets').then(res => setAssets(res.data)).finally(() => setLoading(false));
  }, []);

  const set = (field: string, value: string) => setForm(f => ({ ...f, [field]: value }));

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const res = await api.post('/assets', form);
      setAssets(prev => [res.data, ...prev]);
      setShowForm(false);
      setForm({ assetTag: '', deviceType: '', manufacturer: '', model: '', serialNumber: '', status: 'ACTIVE' });
    } finally { setSaving(false); }
  };

  const filtered = assets.filter(a =>
    (a.assetTag ?? '').toLowerCase().includes(search.toLowerCase()) ||
    (a.deviceType ?? '').toLowerCase().includes(search.toLowerCase()) ||
    (a.model ?? '').toLowerCase().includes(search.toLowerCase())
  );

  const statusColor: Record<string, string> = {
    ACTIVE: 'bg-green-100 text-green-700',
    INACTIVE: 'bg-gray-100 text-gray-600',
    REPAIR: 'bg-yellow-100 text-yellow-700',
    RETIRED: 'bg-red-100 text-red-600',
  };

  return (
    <Layout>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">IT Assets</h2>
        {isAdmin && (
          <button onClick={() => setShowForm(!showForm)}
            className="bg-blue-600 text-white text-sm px-4 py-2 rounded hover:bg-blue-700">
            {showForm ? 'Cancel' : '+ Add Asset'}
          </button>
        )}
      </div>

      {showForm && (
        <form onSubmit={handleCreate} className="bg-white rounded shadow p-6 mb-6">
          <h3 className="font-bold text-base mb-4">New Asset</h3>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {[
              { field: 'assetTag', label: 'Asset Tag *', placeholder: 'AST-001', required: true },
              { field: 'deviceType', label: 'Device Type', placeholder: 'Laptop' },
              { field: 'manufacturer', label: 'Manufacturer', placeholder: 'Dell' },
              { field: 'model', label: 'Model', placeholder: 'XPS 15' },
              { field: 'serialNumber', label: 'Serial Number', placeholder: 'SN123456' },
            ].map(({ field, label, placeholder, required }) => (
              <div key={field}>
                <label className="block text-xs font-semibold text-gray-600 mb-1">{label}</label>
                <input type="text" required={required} placeholder={placeholder}
                  value={(form as any)[field]} onChange={e => set(field, e.target.value)}
                  className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
              </div>
            ))}
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Status</label>
              <select value={form.status} onChange={e => set('status', e.target.value)}
                className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
                <option value="REPAIR">In Repair</option>
                <option value="RETIRED">Retired</option>
              </select>
            </div>
          </div>
          <button type="submit" disabled={saving}
            className="mt-4 bg-blue-600 text-white text-sm px-4 py-2 rounded hover:bg-blue-700 disabled:bg-blue-300">
            {saving ? 'Saving...' : 'Save Asset'}
          </button>
        </form>
      )}

      <div className="mb-4">
        <input type="text" placeholder="Search by tag, type, or model..."
          className="border rounded px-3 py-2 w-full text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
          value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      <div className="bg-white rounded shadow overflow-hidden">
        {loading ? <p className="p-4 text-gray-500">Loading...</p>
          : filtered.length === 0 ? <p className="p-4 text-gray-500">No assets found. {isAdmin && 'Add one above.'}</p>
          : (
            <table className="min-w-full text-sm">
              <thead><tr className="bg-gray-50 text-left text-xs text-gray-500 uppercase">
                <th className="px-4 py-3">Asset Tag</th>
                <th className="px-4 py-3">Type</th>
                <th className="px-4 py-3">Manufacturer</th>
                <th className="px-4 py-3">Model</th>
                <th className="px-4 py-3">Serial #</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Assigned To</th>
              </tr></thead>
              <tbody>
                {filtered.map(a => (
                  <tr key={a.id} className="border-t hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-xs font-semibold text-blue-700">{a.assetTag}</td>
                    <td className="px-4 py-3">{a.deviceType ?? '—'}</td>
                    <td className="px-4 py-3 text-gray-600">{a.manufacturer ?? '—'}</td>
                    <td className="px-4 py-3 text-gray-600">{a.model ?? '—'}</td>
                    <td className="px-4 py-3 text-gray-400 text-xs font-mono">{a.serialNumber ?? '—'}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded text-xs ${statusColor[a.status] ?? 'bg-gray-100'}`}>{a.status}</span>
                    </td>
                    <td className="px-4 py-3 text-gray-500 text-xs">{a.assignedUser?.firstName ?? 'Unassigned'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
      </div>
    </Layout>
  );
}
