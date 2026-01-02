import { useState, useEffect } from 'react'

import { clientsApi } from '~/api/clients'
import { Button } from '~/components/Button'
import { ClientTableHeader } from '~/components/ClientTableHeader'
import { ClientTableRow } from '~/components/ClientTableRow'
import { PageHeader } from '~/components/PageHeader'

import type { JSX } from 'react'
import type { Client } from '~/types/client'

export default function ClientsPage(): JSX.Element {
  const [clients, setClients] = useState<Client[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    void loadClients()
  }, [])

  const loadClients = async (): Promise<void> => {
    try {
      setLoading(true)
      setError(null)
      const data = await clientsApi.list()
      setClients(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load clients')
      console.error('Failed to load clients:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader title="Client Management" backTo="/" backText="← Back to Home" />

        <div className="bg-white shadow-lg rounded-lg p-6">
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Clients</h2>
            <Button variant="primary">Add Client</Button>
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
  )
}
