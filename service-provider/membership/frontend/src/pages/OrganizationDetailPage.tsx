import { useState, useEffect, useCallback } from 'react'
import { useParams } from 'react-router-dom'

import { organizationsApi } from '~/api/organizations'
import { Alert } from '~/components/Alert'
import { Card } from '~/components/Card'
import { CreateRoleForm } from '~/components/CreateRoleForm'
import { LoadingSpinner } from '~/components/LoadingSpinner'
import { OrganizationInfo } from '~/components/OrganizationInfo'
import { PageHeader } from '~/components/PageHeader'
import { RoleList } from '~/components/RoleList'

import type { JSX } from 'react'
import type { Organization } from '~/types/organization'

export default function OrganizationDetailPage(): JSX.Element {
  const { id } = useParams<{ id: string }>()
  const [organization, setOrganization] = useState<Organization | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showRoleForm, setShowRoleForm] = useState(false)

  const loadOrganization = useCallback(async (): Promise<void> => {
    if (!id) return

    try {
      setLoading(true)
      setError(null)
      const data = await organizationsApi.get(id)
      setOrganization(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load organization')
      console.error('Failed to load organization:', err)
    } finally {
      setLoading(false)
    }
  }, [id])

  useEffect(() => {
    void loadOrganization()
  }, [loadOrganization])

  const handleCreateSuccess = (): void => {
    setShowRoleForm(false)
    void loadOrganization()
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <LoadingSpinner />
        </div>
      </div>
    )
  }

  if (error || !organization) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <Alert variant="error">{error ?? 'Organization not found'}</Alert>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader
          title={organization.name}
          backTo="/organizations"
          backText="← Back to Organizations"
        />

        <div className="space-y-6">
          <OrganizationInfo organization={organization} />

          {showRoleForm && (
            <Card className="p-6">
              <div className="mb-6">
                <h2 className="text-xl font-semibold text-gray-900">Create New Role</h2>
              </div>
              <CreateRoleForm
                organizationId={organization.id}
                onSuccess={handleCreateSuccess}
                onCancel={() => {
                  setShowRoleForm(false)
                }}
              />
            </Card>
          )}

          <RoleList
            roles={organization.roles ?? []}
            showForm={showRoleForm}
            onAddClick={() => {
              setShowRoleForm(true)
            }}
          />
        </div>
      </div>
    </div>
  )
}
