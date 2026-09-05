$frontendSrc = "src"
New-Item -ItemType Directory -Force -Path "$frontendSrc\components"
New-Item -ItemType Directory -Force -Path "$frontendSrc\pages"
New-Item -ItemType Directory -Force -Path "$frontendSrc\services"
New-Item -ItemType Directory -Force -Path "$frontendSrc\types"

$appTsx = @"
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import TicketDetails from './pages/TicketDetails';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/login" />} />
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/tickets/:id" element={<TicketDetails />} />
      </Routes>
    </Router>
  );
}

export default App;
"@
Set-Content -Path "$frontendSrc\App.tsx" -Value $appTsx

$loginTsx = @"
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Dummy login logic
    localStorage.setItem('token', 'dummy-token');
    navigate('/dashboard');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-96">
        <h2 className="text-2xl font-bold mb-6 text-center">OpsFlow Login</h2>
        <form onSubmit={handleLogin}>
          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-bold mb-2">Email</label>
            <input 
              type="email" 
              className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="mb-6">
            <label className="block text-gray-700 text-sm font-bold mb-2">Password</label>
            <input 
              type="password" 
              className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded w-full">
            Sign In
          </button>
        </form>
      </div>
    </div>
  );
}
"@
Set-Content -Path "$frontendSrc\pages\Login.tsx" -Value $loginTsx

$dashboardTsx = @"
import React from 'react';

export default function Dashboard() {
  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-4">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded shadow border-l-4 border-blue-500">
          <h2 className="text-gray-500 text-sm">Total Tickets</h2>
          <p className="text-2xl font-bold">124</p>
        </div>
        <div className="bg-white p-4 rounded shadow border-l-4 border-yellow-500">
          <h2 className="text-gray-500 text-sm">Open</h2>
          <p className="text-2xl font-bold">45</p>
        </div>
        <div className="bg-white p-4 rounded shadow border-l-4 border-green-500">
          <h2 className="text-gray-500 text-sm">Resolved</h2>
          <p className="text-2xl font-bold">79</p>
        </div>
        <div className="bg-white p-4 rounded shadow border-l-4 border-red-500">
          <h2 className="text-gray-500 text-sm">SLA Breached</h2>
          <p className="text-2xl font-bold">3</p>
        </div>
      </div>
      <div className="bg-white p-4 rounded shadow">
        <h2 className="text-xl font-bold mb-4">Recent Tickets</h2>
        <table className="min-w-full">
          <thead>
            <tr className="bg-gray-100 text-left">
              <th className="p-2">ID</th>
              <th className="p-2">Title</th>
              <th className="p-2">Status</th>
              <th className="p-2">Priority</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b">
              <td className="p-2 text-blue-500">INC-2026-A1B2</td>
              <td className="p-2">Cannot connect to VPN</td>
              <td className="p-2"><span className="bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-xs">OPEN</span></td>
              <td className="p-2"><span className="text-red-500 font-bold">HIGH</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}
"@
Set-Content -Path "$frontendSrc\pages\Dashboard.tsx" -Value $dashboardTsx

$ticketDetailsTsx = @"
import React from 'react';

export default function TicketDetails() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Ticket: INC-2026-A1B2</h1>
      <div className="bg-white p-4 rounded shadow mb-4">
        <h2 className="text-lg font-bold mb-2">Cannot connect to VPN</h2>
        <p className="text-gray-700">User is unable to connect to the corporate VPN using Cisco AnyConnect.</p>
      </div>
      <div className="bg-white p-4 rounded shadow">
        <h3 className="font-bold mb-2">Comments</h3>
        <div className="border-b py-2">
          <p className="text-sm text-gray-500">John Doe (Support Agent)</p>
          <p>Please restart your computer and try again.</p>
        </div>
      </div>
    </div>
  );
}
"@
Set-Content -Path "$frontendSrc\pages\TicketDetails.tsx" -Value $ticketDetailsTsx
