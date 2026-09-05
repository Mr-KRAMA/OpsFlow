import React, { useEffect, useState } from 'react';
import api from '../services/api';
import Layout from '../components/Layout';

export default function KnowledgeBase() {
  const [articles, setArticles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState<any>(null);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ title: '', category: '', problem: '', solution: '', tags: '' });
  const [saving, setSaving] = useState(false);

  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAgent = ['SUPPORT_AGENT', 'TEAM_LEAD', 'ADMIN'].includes(user.role);

  useEffect(() => {
    api.get('/knowledge/articles').then(res => setArticles(res.data)).finally(() => setLoading(false));
  }, []);

  const filtered = articles.filter(a =>
    a.title.toLowerCase().includes(search.toLowerCase()) ||
    (a.tags ?? '').toLowerCase().includes(search.toLowerCase()) ||
    (a.category ?? '').toLowerCase().includes(search.toLowerCase())
  );

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const res = await api.post('/knowledge/articles', { ...form, status: 'PUBLISHED' });
      setArticles(prev => [res.data, ...prev]);
      setShowForm(false);
      setForm({ title: '', category: '', problem: '', solution: '', tags: '' });
    } finally { setSaving(false); }
  };

  const statusColor: Record<string, string> = {
    PUBLISHED: 'bg-green-100 text-green-700',
    DRAFT: 'bg-yellow-100 text-yellow-700',
    ARCHIVED: 'bg-gray-100 text-gray-500',
  };

  return (
    <Layout>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">Knowledge Base</h2>
        {isAgent && (
          <button onClick={() => setShowForm(!showForm)}
            className="bg-blue-600 text-white text-sm px-4 py-2 rounded hover:bg-blue-700">
            {showForm ? 'Cancel' : '+ New Article'}
          </button>
        )}
      </div>

      {/* Create form */}
      {showForm && (
        <form onSubmit={handleCreate} className="bg-white rounded shadow p-6 mb-6 space-y-3">
          <h3 className="font-bold text-base mb-2">New Article</h3>
          <input required placeholder="Title" value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
            className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
          <div className="grid grid-cols-2 gap-3">
            <input placeholder="Category (e.g. Network)" value={form.category} onChange={e => setForm(f => ({ ...f, category: e.target.value }))}
              className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
            <input placeholder="Tags (comma separated)" value={form.tags} onChange={e => setForm(f => ({ ...f, tags: e.target.value }))}
              className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
          </div>
          <textarea required rows={3} placeholder="Problem description..." value={form.problem} onChange={e => setForm(f => ({ ...f, problem: e.target.value }))}
            className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
          <textarea required rows={3} placeholder="Solution..." value={form.solution} onChange={e => setForm(f => ({ ...f, solution: e.target.value }))}
            className="border rounded w-full px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
          <button type="submit" disabled={saving}
            className="bg-blue-600 text-white text-sm px-4 py-2 rounded hover:bg-blue-700 disabled:bg-blue-300">
            {saving ? 'Saving...' : 'Publish Article'}
          </button>
        </form>
      )}

      <div className="flex gap-4">
        {/* Article list */}
        <div className="w-1/3">
          <input type="text" placeholder="Search articles..."
            className="border rounded px-3 py-2 w-full text-sm mb-3 focus:outline-none focus:ring-2 focus:ring-blue-400"
            value={search} onChange={e => setSearch(e.target.value)} />
          <div className="space-y-2">
            {loading ? <p className="text-gray-500 text-sm">Loading...</p>
              : filtered.length === 0 ? <p className="text-gray-400 text-sm">No articles found.</p>
              : filtered.map(a => (
                <div key={a.id} onClick={() => setSelected(a)}
                  className={`bg-white rounded shadow p-3 cursor-pointer hover:border-blue-400 border-2 transition-colors ${selected?.id === a.id ? 'border-blue-500' : 'border-transparent'}`}>
                  <div className="flex justify-between items-start mb-1">
                    <p className="font-medium text-sm">{a.title}</p>
                    <span className={`text-xs px-1.5 py-0.5 rounded ${statusColor[a.status] ?? 'bg-gray-100'}`}>{a.status}</span>
                  </div>
                  {a.category && <p className="text-xs text-gray-400">{a.category}</p>}
                  {a.tags && <p className="text-xs text-blue-400 mt-1">{a.tags.split(',').map((t: string) => `#${t.trim()}`).join(' ')}</p>}
                </div>
              ))}
          </div>
        </div>

        {/* Article detail */}
        <div className="flex-1">
          {!selected ? (
            <div className="bg-white rounded shadow p-8 text-center text-gray-400">
              <p className="text-4xl mb-3">📖</p>
              <p>Select an article to read</p>
            </div>
          ) : (
            <div className="bg-white rounded shadow p-6">
              <div className="flex justify-between items-start mb-4">
                <h3 className="text-xl font-bold">{selected.title}</h3>
                <span className={`text-xs px-2 py-1 rounded ${statusColor[selected.status] ?? 'bg-gray-100'}`}>{selected.status}</span>
              </div>
              {selected.category && <p className="text-xs text-gray-400 mb-4">Category: {selected.category}</p>}

              <div className="mb-4">
                <h4 className="font-semibold text-sm text-red-600 mb-2">🔴 Problem</h4>
                <p className="text-sm text-gray-700 bg-red-50 p-3 rounded">{selected.problem}</p>
              </div>
              <div className="mb-4">
                <h4 className="font-semibold text-sm text-green-600 mb-2">✅ Solution</h4>
                <p className="text-sm text-gray-700 bg-green-50 p-3 rounded">{selected.solution}</p>
              </div>
              {selected.tags && (
                <div className="flex gap-2 flex-wrap mt-3">
                  {selected.tags.split(',').map((t: string) => (
                    <span key={t} className="bg-blue-100 text-blue-700 text-xs px-2 py-0.5 rounded">#{t.trim()}</span>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}
