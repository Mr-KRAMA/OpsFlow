import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../services/api';

export default function Register() {
  const [form, setForm] = useState({ firstName: '', lastName: '', email: '', password: '', role: 'EMPLOYEE' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const set = (field: string, value: string) => setForm(f => ({ ...f, [field]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.post('/auth/register', form);
      localStorage.setItem('token', res.data.token);
      localStorage.setItem('user', JSON.stringify(res.data));
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.response?.data?.message ?? 'Registration failed. Email may already be in use.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-900 to-blue-700">
      <div className="bg-white p-8 rounded-xl shadow-xl w-full max-w-md">
        <div className="text-center mb-6">
          <h1 className="text-3xl font-bold text-blue-700">OpsFlow</h1>
          <p className="text-gray-500 text-sm mt-1">Create your account</p>
        </div>

        {error && <div className="bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded mb-4 text-sm">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">First Name</label>
              <input required type="text" value={form.firstName} onChange={e => set('firstName', e.target.value)}
                className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" placeholder="John" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Last Name</label>
              <input required type="text" value={form.lastName} onChange={e => set('lastName', e.target.value)}
                className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" placeholder="Doe" />
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1">Email</label>
            <input required type="email" value={form.email} onChange={e => set('email', e.target.value)}
              className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" placeholder="you@company.com" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1">Password</label>
            <input required type="password" value={form.password} onChange={e => set('password', e.target.value)}
              className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" placeholder="••••••••" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1">Role</label>
            <select value={form.role} onChange={e => set('role', e.target.value)}
              className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400">
              <option value="EMPLOYEE">Employee</option>
              <option value="SUPPORT_AGENT">Support Agent</option>
              <option value="TEAM_LEAD">Team Lead</option>
              <option value="ADMIN">Admin</option>
            </select>
          </div>
          <button type="submit" disabled={loading}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-300 text-white font-bold py-2.5 rounded text-sm mt-2">
            {loading ? 'Creating account...' : 'Create Account'}
          </button>
        </form>

        <p className="text-center text-sm text-gray-500 mt-4">
          Already have an account?{' '}
          <Link to="/login" className="text-blue-600 hover:underline font-medium">Sign in</Link>
        </p>
      </div>
    </div>
  );
}
