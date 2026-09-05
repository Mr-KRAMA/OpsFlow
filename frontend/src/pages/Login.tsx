import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../services/api';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.post('/auth/login', { email, password });
      localStorage.setItem('token', res.data.token);
      localStorage.setItem('user', JSON.stringify(res.data));
      navigate('/dashboard');
    } catch {
      setError('Invalid email or password.');
    } finally {
      setLoading(false);
    }
  };

  const demoLogin = (demoEmail: string, demoPassword: string) => {
    setEmail(demoEmail);
    setPassword(demoPassword);
  };

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-blue-900 to-blue-700">
      {/* Left branding panel */}
      <div className="hidden md:flex flex-col justify-center px-12 w-1/2 text-white">
        <h1 className="text-5xl font-bold mb-4">OpsFlow</h1>
        <p className="text-blue-200 text-lg mb-8">Enterprise IT Service Management</p>
        <ul className="space-y-3 text-blue-100 text-sm">
          {['Ticket lifecycle management', 'Automated SLA tracking', 'Role-based access control', 'Immutable audit logging', 'Knowledge base & asset tracking'].map(f => (
            <li key={f} className="flex items-center gap-2">
              <span className="text-green-400">✓</span> {f}
            </li>
          ))}
        </ul>
      </div>

      {/* Right login panel */}
      <div className="flex flex-col justify-center items-center w-full md:w-1/2 px-6">
        <div className="bg-white rounded-xl shadow-2xl p-8 w-full max-w-md">
          <h2 className="text-2xl font-bold text-gray-800 mb-1">Welcome back</h2>
          <p className="text-gray-500 text-sm mb-6">Sign in to your OpsFlow account</p>

          {error && <div className="bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded mb-4 text-sm">{error}</div>}

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Email</label>
              <input type="email" required value={email} onChange={e => setEmail(e.target.value)}
                className="border rounded w-full py-2.5 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                placeholder="you@company.com" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1">Password</label>
              <input type="password" required value={password} onChange={e => setPassword(e.target.value)}
                className="border rounded w-full py-2.5 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                placeholder="••••••••" />
            </div>
            <button type="submit" disabled={loading}
              className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-300 text-white font-bold py-2.5 rounded text-sm">
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>

          <div className="mt-4 border-t pt-4">
            <p className="text-xs text-gray-400 mb-2 font-semibold">DEMO ACCOUNTS</p>
            <div className="grid grid-cols-2 gap-2">
              {[
                { label: 'Admin', email: 'admin@opsflow.com', pass: 'admin123' },
                { label: 'Agent', email: 'agent@opsflow.com', pass: 'agent123' },
                { label: 'Team Lead', email: 'lead@opsflow.com', pass: 'lead123' },
                { label: 'Employee', email: 'employee@opsflow.com', pass: 'emp123' },
              ].map(d => (
                <button key={d.label} onClick={() => demoLogin(d.email, d.pass)}
                  className="text-xs border rounded px-2 py-1.5 text-gray-600 hover:bg-gray-50 text-left">
                  <span className="font-semibold">{d.label}</span><br />
                  <span className="text-gray-400">{d.email}</span>
                </button>
              ))}
            </div>
          </div>

          <p className="text-center text-sm text-gray-500 mt-4">
            New user?{' '}
            <Link to="/register" className="text-blue-600 hover:underline font-medium">Create account</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
