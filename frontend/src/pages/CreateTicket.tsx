import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

import Layout from '../components/Layout';

export default function CreateTicket() {
  const [categories, setCategories] = useState<any[]>([]);
  const [form, setForm] = useState({
    title: '',
    description: '',
    categoryId: '',
    subcategory: '',
    impact: 'LOW',
    urgency: 'LOW',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    api.get('/tickets/categories').catch(() =>
      api.get('/tickets').then(() => setCategories([]))
    );
    // Try fetching categories — fallback gracefully if endpoint differs
    api.get('/tickets/categories')
      .then(res => setCategories(res.data))
      .catch(() => setCategories([]));
  }, []);

  const set = (field: string, value: string) => setForm(f => ({ ...f, [field]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title || !form.description || !form.impact || !form.urgency) {
      setError('Please fill in all required fields.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const payload: any = {
        title: form.title,
        description: form.description,
        impact: form.impact,
        urgency: form.urgency,
        subcategory: form.subcategory || undefined,
        categoryId: form.categoryId ? Number(form.categoryId) : (categories[0]?.id ?? 1),
      };
      const res = await api.post('/tickets', payload);
      navigate(`/tickets/${res.data.id}`);
    } catch (err: any) {
      setError(err.response?.data?.message ?? 'Failed to create ticket.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Layout>
      <div className="max-w-2xl mx-auto">
        <h2 className="text-2xl font-bold mb-6">Create New Ticket</h2>

        {error && <div className="bg-red-100 text-red-700 px-3 py-2 rounded mb-4 text-sm">{error}</div>}

        <form onSubmit={handleSubmit} className="bg-white rounded shadow p-6 space-y-4">
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Title *</label>
            <input
              type="text"
              required
              className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
              value={form.title}
              onChange={e => set('title', e.target.value)}
              placeholder="Brief description of the issue"
            />
          </div>

          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Description *</label>
            <textarea
              required
              rows={4}
              className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
              value={form.description}
              onChange={e => set('description', e.target.value)}
              placeholder="Detailed description of the issue..."
            />
          </div>

          {categories.length > 0 && (
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-1">Category *</label>
              <select
                className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                value={form.categoryId}
                onChange={e => set('categoryId', e.target.value)}
              >
                <option value="">Select category...</option>
                {categories.map((c: any) => (
                  <option key={c.id} value={c.id}>{c.name}</option>
                ))}
              </select>
            </div>
          )}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-1">Impact *</label>
              <select
                className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                value={form.impact}
                onChange={e => set('impact', e.target.value)}
              >
                <option value="LOW">Low</option>
                <option value="MEDIUM">Medium</option>
                <option value="HIGH">High</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-1">Urgency *</label>
              <select
                className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                value={form.urgency}
                onChange={e => set('urgency', e.target.value)}
              >
                <option value="LOW">Low</option>
                <option value="MEDIUM">Medium</option>
                <option value="HIGH">High</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Subcategory</label>
            <input
              type="text"
              className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
              value={form.subcategory}
              onChange={e => set('subcategory', e.target.value)}
              placeholder="Optional"
            />
          </div>

          <div className="flex gap-3 pt-2">
            <button
              type="submit"
              disabled={loading}
              className="bg-blue-600 hover:bg-blue-700 disabled:bg-blue-300 text-white font-bold py-2 px-6 rounded text-sm"
            >
              {loading ? 'Submitting...' : 'Submit Ticket'}
            </button>
            <button
              type="button"
              onClick={() => navigate('/tickets')}
              className="bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold py-2 px-6 rounded text-sm"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </Layout>
  );
}
