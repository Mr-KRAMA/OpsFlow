import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Tickets from './pages/Tickets';
import CreateTicket from './pages/CreateTicket';
import TicketDetails from './pages/TicketDetails';
import KnowledgeBase from './pages/KnowledgeBase';
import Assets from './pages/Assets';
import Users from './pages/Users';
import AuditLogs from './pages/AuditLogs';

function PrivateRoute({ children }: { children: React.ReactNode }) {
  return localStorage.getItem('token') ? <>{children}</> : <Navigate to="/login" />;
}

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/login" />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/dashboard" element={<PrivateRoute><Dashboard /></PrivateRoute>} />
        <Route path="/tickets" element={<PrivateRoute><Tickets /></PrivateRoute>} />
        <Route path="/tickets/new" element={<PrivateRoute><CreateTicket /></PrivateRoute>} />
        <Route path="/tickets/:id" element={<PrivateRoute><TicketDetails /></PrivateRoute>} />
        <Route path="/knowledge" element={<PrivateRoute><KnowledgeBase /></PrivateRoute>} />
        <Route path="/assets" element={<PrivateRoute><Assets /></PrivateRoute>} />
        <Route path="/admin/users" element={<PrivateRoute><Users /></PrivateRoute>} />
        <Route path="/admin/audit" element={<PrivateRoute><AuditLogs /></PrivateRoute>} />
      </Routes>
    </Router>
  );
}
