import React, { useEffect, useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import api from '../services/api';

interface Props { children: React.ReactNode; }

export default function Layout({ children }: Props) {
  const navigate = useNavigate();
  const location = useLocation();
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAgent = ['SUPPORT_AGENT', 'TEAM_LEAD', 'ADMIN'].includes(user.role);
  const [unread, setUnread] = useState(0);
  const [notifications, setNotifications] = useState<any[]>([]);
  const [showNotif, setShowNotif] = useState(false);

  useEffect(() => {
    api.get('/notifications').then(res => {
      setNotifications(res.data);
      setUnread(res.data.filter((n: any) => !n.read).length);
    }).catch(() => {});
  }, [location.pathname]);

  const markRead = async (id: number) => {
    await api.patch(`/notifications/${id}/read`).catch(() => {});
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
    setUnread(prev => Math.max(0, prev - 1));
  };

  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  const navLink = (to: string, label: string) => {
    const active = location.pathname.startsWith(to);
    return (
      <Link to={to} className={`flex items-center px-3 py-2 rounded text-sm font-medium transition-colors ${active ? 'bg-blue-700 text-white' : 'text-blue-100 hover:bg-blue-700'}`}>
        {label}
      </Link>
    );
  };

  return (
    <div className="min-h-screen flex bg-gray-50">
      {/* Sidebar */}
      <aside className="w-56 bg-blue-800 flex flex-col fixed h-full z-10">
        <div className="px-4 py-5 border-b border-blue-700">
          <h1 className="text-white text-xl font-bold">OpsFlow</h1>
          <p className="text-blue-300 text-xs mt-1">{user.firstName ? `Hi, ${user.firstName}` : user.email}</p>
          <span className="text-xs bg-blue-600 text-white px-2 py-0.5 rounded mt-1 inline-block">{user.role}</span>
        </div>
        <nav className="flex-1 px-3 py-4 space-y-1">
          {navLink('/dashboard', '📊 Dashboard')}
          {navLink('/tickets', '🎫 Tickets')}
          {navLink('/knowledge', '📖 Knowledge Base')}
          {navLink('/assets', '🖥️ Assets')}
          {isAgent && navLink('/admin/users', '👥 Users')}
          {isAgent && navLink('/admin/audit', '📋 Audit Logs')}
        </nav>
        <div className="px-3 py-4 border-t border-blue-700">
          <button onClick={logout} className="w-full text-left text-blue-200 hover:text-white text-sm px-3 py-2 rounded hover:bg-blue-700">
            🚪 Logout
          </button>
        </div>
      </aside>

      {/* Main content */}
      <div className="ml-56 flex-1 flex flex-col">
        {/* Top bar */}
        <header className="bg-white shadow-sm px-6 py-3 flex justify-between items-center sticky top-0 z-10">
          <div />
          <div className="flex items-center gap-4">
            <Link to="/tickets/new" className="bg-blue-600 text-white text-sm px-3 py-1.5 rounded hover:bg-blue-700">
              + New Ticket
            </Link>
            {/* Notifications bell */}
            <div className="relative">
              <button onClick={() => setShowNotif(!showNotif)} className="relative text-gray-500 hover:text-gray-700 p-1">
                <span className="text-xl">🔔</span>
                {unread > 0 && (
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">
                    {unread}
                  </span>
                )}
              </button>
              {showNotif && (
                <div className="absolute right-0 mt-2 w-80 bg-white rounded shadow-lg border z-50 max-h-80 overflow-y-auto">
                  <div className="px-4 py-2 border-b font-semibold text-sm text-gray-700">Notifications</div>
                  {notifications.length === 0 ? (
                    <p className="px-4 py-3 text-sm text-gray-500">No notifications</p>
                  ) : notifications.map(n => (
                    <div
                      key={n.id}
                      onClick={() => { markRead(n.id); setShowNotif(false); if (n.relatedTicketId) navigate(`/tickets/${n.relatedTicketId}`); }}
                      className={`px-4 py-3 text-sm border-b cursor-pointer hover:bg-gray-50 ${!n.read ? 'bg-blue-50 font-medium' : 'text-gray-600'}`}
                    >
                      {n.message}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </header>

        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  );
}
