import { useState, useEffect } from 'react'

import { clientsApi } from '~/api/clients'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { ClientTableHeader } from '~/components/ClientTableHeader'
import { ClientTableRow } from '~/components/ClientTableRow'
import { LoadingSpinner } from '~/components/LoadingSpinner'
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

        <Card className="p-6">
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Clients</h2>
            <Button variant="primary">Add Client</Button>
          </div>

          {loading && <LoadingSpinner />}

          {error && <Alert variant="error">{error}</Alert>}

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
        </Card>
      </div>
    </div>
  )
}
