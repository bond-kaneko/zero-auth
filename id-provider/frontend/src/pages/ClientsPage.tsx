import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { clientsApi } from '~/api/clients';
import type { Client } from '~/types/client';
import { ClientTableHeader } from '~/components/ClientTableHeader';
import { ClientTableRow } from '~/components/ClientTableRow';

export default function ClientsPage() {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadClients();
  }, []);

  const loadClients = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await clientsApi.list();
      setClients(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load clients');
      console.error('Failed to load clients:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <Link
            to="/"
            className="text-blue-600 hover:text-blue-800 mb-4 inline-block"
          >
            ← Back to Home
          </Link>
          <h1 className="text-3xl font-bold text-gray-900">
            Client Management
          </h1>
        </div>

        <div className="bg-white shadow-lg rounded-lg p-6">
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Clients</h2>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
              Add Client
            </button>
          </div>

          {loading && (
            <div className="text-center py-8">
              <p className="text-gray-600">Loading...</p>
            </div>
          )}

          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-4">
              <p className="text-red-800">{error}</p>
            </div>
          )}

          {!loading && !error && clients.length === 0 && (
            <div className="text-gray-600">
              <p>No clients yet. Click "Add Client" to create one.</p>
            </div>
          )}

          {!loading && !error && clients.length > 0 && (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <ClientTableHeader />
                <tbody className="bg-white divide-y divide-gray-200">
                  {clients.map((client) => (
                    <ClientTableRow key={client.id} client={client} />
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
