import React, { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import api from '../services/api';
import Layout from '../components/Layout';

const STATUS_TRANSITIONS: Record<string, string[]> = {
  NEW: ['TRIAGED', 'ASSIGNED', 'CLOSED'],
  TRIAGED: ['ASSIGNED', 'CLOSED'],
  ASSIGNED: ['IN_PROGRESS', 'CLOSED'],
  IN_PROGRESS: ['PENDING', 'RESOLVED', 'ASSIGNED'],
  PENDING: ['IN_PROGRESS', 'RESOLVED'],
  RESOLVED: ['CLOSED', 'REOPENED'],
  CLOSED: [],
  REOPENED: ['ASSIGNED', 'IN_PROGRESS'],
};

const statusColor: Record<string, string> = {
  NEW: 'bg-blue-100 text-blue-800', ASSIGNED: 'bg-purple-100 text-purple-800',
  IN_PROGRESS: 'bg-yellow-100 text-yellow-800', PENDING: 'bg-orange-100 text-orange-800',
  RESOLVED: 'bg-green-100 text-green-800', CLOSED: 'bg-gray-100 text-gray-800',
  TRIAGED: 'bg-indigo-100 text-indigo-800', REOPENED: 'bg-red-100 text-red-800',
};
const priorityColor: Record<string, string> = {
  CRITICAL: 'text-red-600 font-bold', HIGH: 'text-red-500 font-bold',
  MEDIUM: 'text-yellow-600 font-semibold', LOW: 'text-green-600',
};

export default function TicketDetails() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [ticket, setTicket] = useState<any>(null);
  const [comments, setComments] = useState<any[]>([]);
  const [agents, setAgents] = useState<any[]>([]);
  const [newComment, setNewComment] = useState('');
  const [isInternal, setIsInternal] = useState(false);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [updatingStatus, setUpdatingStatus] = useState(false);

  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAgent = ['SUPPORT_AGENT', 'TEAM_LEAD', 'ADMIN'].includes(user.role);

  useEffect(() => {
    Promise.all([
      api.get(`/tickets/${id}`),
      api.get(`/tickets/${id}/comments`),
      ...(isAgent ? [api.get('/users')] : []),
    ]).then(([tRes, cRes, uRes]) => {
      setTicket(tRes.data);
      setComments(cRes.data);
      if (uRes) setAgents(uRes.data.filter((u: any) => ['SUPPORT_AGENT','TEAM_LEAD'].includes(u.role)));
    }).catch(() => navigate('/tickets'))
      .finally(() => setLoading(false));
  }, [id]);

  const updateStatus = async (status: string) => {
    setUpdatingStatus(true);
    try {
      const res = await api.patch(`/tickets/${id}/status`, { status });
      setTicket(res.data);
    } finally { setUpdatingStatus(false); }
  };

  const assignAgent = async (agentId: string) => {
    const res = await api.patch(`/tickets/${id}/assign`, { agentId: Number(agentId) });
    setTicket(res.data);
  };

  const submitComment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.post(`/tickets/${id}/comments`, { content: newComment, isInternal });
      setComments(prev => [...prev, res.data]);
      setNewComment('');
    } finally { setSubmitting(false); }
  };

  if (loading) return <Layout><p className="text-gray-500">Loading...</p></Layout>;
  if (!ticket) return null;

  const nextStatuses = STATUS_TRANSITIONS[ticket.status] ?? [];

  return (
    <Layout>
      <Link to="/tickets" className="text-sm text-blue-600 hover:underline mb-4 inline-block">← Back to Tickets</Link>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Left: Ticket info + comments */}
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-white rounded shadow p-6">
            <div className="flex justify-between items-start mb-2">
              <span className="font-mono text-xs text-gray-400">{ticket.ticketNumber}</span>
              <span className={`px-2 py-1 rounded text-xs font-medium ${statusColor[ticket.status] ?? 'bg-gray-100'}`}>{ticket.status}</span>
            </div>
            <h2 className="text-xl font-bold mb-2">{ticket.title}</h2>
            <p className="text-gray-600 text-sm mb-4">{ticket.description}</p>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm border-t pt-4">
              {[
                ['Priority', <span className={priorityColor[ticket.priority] ?? ''}>{ticket.priority ?? '—'}</span>],
                ['Impact', ticket.impact ?? '—'],
                ['Urgency', ticket.urgency ?? '—'],
                ['Category', ticket.categoryName ?? '—'],
                ['Created By', ticket.creatorName ?? '—'],
                ['Assigned To', ticket.assignedAgentName ?? 'Unassigned'],
                ['Team', ticket.assignedTeamName ?? '—'],
                ['Created', new Date(ticket.createdAt).toLocaleDateString()],
              ].map(([label, value]) => (
                <div key={label as string}>
                  <p className="text-gray-400 text-xs">{label}</p>
                  <p className="font-medium text-sm">{value}</p>
                </div>
              ))}
            </div>

            {ticket.resolutionSlaDeadline && (
              <div className="mt-4 text-xs text-orange-700 bg-orange-50 border border-orange-200 px-3 py-2 rounded">
                ⏱ SLA Resolution Deadline: {new Date(ticket.resolutionSlaDeadline).toLocaleString()}
              </div>
            )}
          </div>

          {/* Comments */}
          <div className="bg-white rounded shadow p-6">
            <h3 className="font-bold text-base mb-4">Comments ({comments.length})</h3>
            <div className="space-y-3 mb-4">
              {comments.length === 0 && <p className="text-gray-400 text-sm">No comments yet.</p>}
              {comments.map(c => (
                <div key={c.id} className={`p-3 rounded border-l-4 ${c.isInternal ? 'border-yellow-400 bg-yellow-50' : 'border-blue-200 bg-gray-50'}`}>
                  <div className="flex justify-between text-xs text-gray-400 mb-1">
                    <span className="font-semibold text-gray-700">{c.authorName}</span>
                    <span>{new Date(c.createdAt).toLocaleString()}</span>
                  </div>
                  {c.isInternal && <span className="text-xs bg-yellow-200 text-yellow-800 px-1.5 py-0.5 rounded mr-2">Internal</span>}
                  <p className="text-sm text-gray-800 mt-1">{c.content}</p>
                </div>
              ))}
            </div>
            <form onSubmit={submitComment}>
              <textarea rows={3} className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 mb-2"
                placeholder="Add a comment..." value={newComment} onChange={e => setNewComment(e.target.value)} />
              <div className="flex items-center justify-between">
                {isAgent && (
                  <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                    <input type="checkbox" checked={isInternal} onChange={e => setIsInternal(e.target.checked)} />
                    Internal note
                  </label>
                )}
                <button type="submit" disabled={submitting || !newComment.trim()}
                  className="bg-blue-600 hover:bg-blue-700 disabled:bg-blue-300 text-white text-sm font-bold py-2 px-4 rounded ml-auto">
                  {submitting ? 'Posting...' : 'Post Comment'}
                </button>
              </div>
            </form>
          </div>
        </div>

        {/* Right: Agent actions */}
        {isAgent && (
          <div className="space-y-4">
            {/* Update Status */}
            <div className="bg-white rounded shadow p-4">
              <h4 className="font-bold text-sm mb-3">Update Status</h4>
              {nextStatuses.length === 0 ? (
                <p className="text-xs text-gray-400">No transitions available</p>
              ) : (
                <div className="space-y-2">
                  {nextStatuses.map(s => (
                    <button key={s} onClick={() => updateStatus(s)} disabled={updatingStatus}
                      className={`w-full text-left px-3 py-2 rounded text-sm border hover:bg-gray-50 disabled:opacity-50 ${statusColor[s] ?? 'bg-gray-100'}`}>
                      → {s.replace('_', ' ')}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Assign Agent */}
            <div className="bg-white rounded shadow p-4">
              <h4 className="font-bold text-sm mb-3">Assign Agent</h4>
              <select onChange={e => e.target.value && assignAgent(e.target.value)}
                className="border rounded w-full py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                defaultValue="">
                <option value="">Select agent...</option>
                {agents.map(a => (
                  <option key={a.id} value={a.id}>{a.firstName} {a.lastName} ({a.role})</option>
                ))}
              </select>
            </div>

            {/* Ticket meta */}
            <div className="bg-white rounded shadow p-4 text-xs text-gray-500 space-y-1">
              <p>Created: {new Date(ticket.createdAt).toLocaleString()}</p>
              <p>Updated: {new Date(ticket.updatedAt).toLocaleString()}</p>
              {ticket.resolvedAt && <p>Resolved: {new Date(ticket.resolvedAt).toLocaleString()}</p>}
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}
