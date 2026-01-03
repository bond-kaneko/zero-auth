import { useState, useEffect } from 'react'

import { organizationsApi } from '~/api/organizations'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { CreateOrganizationForm } from '~/components/CreateOrganizationForm'
import { LoadingSpinner } from '~/components/LoadingSpinner'
import { OrganizationTableHeader } from '~/components/OrganizationTableHeader'
import { OrganizationTableRow } from '~/components/OrganizationTableRow'
import { PageHeader } from '~/components/PageHeader'

import type { JSX } from 'react'
import type { Organization } from '~/types/organization'

export default function OrganizationsPage(): JSX.Element {
  const [organizations, setOrganizations] = useState<Organization[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showForm, setShowForm] = useState(false)

  useEffect(() => {
    void loadOrganizations()
  }, [])

  const loadOrganizations = async (): Promise<void> => {
    try {
      setLoading(true)
      setError(null)
      const data = await organizationsApi.list()
      setOrganizations(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load organizations')
      console.error('Failed to load organizations:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleCreateSuccess = (): void => {
    setShowForm(false)
    void loadOrganizations()
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader title="Organization Management" backTo="/" backText="← Back to Home" />

        {showForm && (
          <Card className="p-6 mb-6">
            <div className="mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Create New Organization</h2>
            </div>
            <CreateOrganizationForm
              onSuccess={handleCreateSuccess}
              onCancel={() => {
                setShowForm(false)
              }}
            />
          </Card>
        )}

        <Card className="p-6">
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Organizations</h2>
            {!showForm && (
              <Button
                variant="primary"
                onClick={() => {
                  setShowForm(true)
                }}
              >
                Add Organization
              </Button>
            )}
          </div>

          {loading && <LoadingSpinner />}

          {error && <Alert variant="error">{error}</Alert>}

          {!loading && !error && organizations.length === 0 && (
            <div className="text-gray-600">
              <p>No organizations yet.</p>
            </div>
          )}

          {!loading && !error && organizations.length > 0 && (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <OrganizationTableHeader />
                <tbody className="bg-white divide-y divide-gray-200">
                  {organizations.map((organization) => (
                    <OrganizationTableRow key={organization.id} organization={organization} />
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
