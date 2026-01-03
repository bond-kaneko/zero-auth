import { useState, useEffect, useCallback } from 'react'
import { useParams } from 'react-router-dom'

import { membershipsApi } from '~/api/memberships'
import { organizationsApi } from '~/api/organizations'
import { usersApi } from '~/api/users'
import { AddMemberForm } from '~/components/AddMemberForm'
import { Alert } from '~/components/Alert'
import { Card } from '~/components/Card'
import { CreateRoleForm } from '~/components/CreateRoleForm'
import { LoadingSpinner } from '~/components/LoadingSpinner'
import { MemberList } from '~/components/MemberList'
import { OrganizationInfo } from '~/components/OrganizationInfo'
import { PageHeader } from '~/components/PageHeader'
import { RoleList } from '~/components/RoleList'

import type { JSX } from 'react'
import type { Membership } from '~/types/membership'
import type { Organization } from '~/types/organization'
import type { User } from '~/types/user'

export default function OrganizationDetailPage(): JSX.Element {
  const { id } = useParams<{ id: string }>()
  const [organization, setOrganization] = useState<Organization | null>(null)
  const [memberships, setMemberships] = useState<Membership[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showRoleForm, setShowRoleForm] = useState(false)
  const [showMemberForm, setShowMemberForm] = useState(false)

  const loadOrganization = useCallback(async (): Promise<void> => {
    if (!id) return

    try {
      setLoading(true)
      setError(null)

      // Load organization, memberships, and users in parallel
      const [orgData, membershipsData, usersData] = await Promise.all([
        organizationsApi.get(id),
        membershipsApi.list(id),
        usersApi.list(),
      ])

      setOrganization(orgData)
      setMemberships(membershipsData)
      setUsers(usersData)
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

  const handleRoleCreateSuccess = (): void => {
    setShowRoleForm(false)
    void loadOrganization()
  }

  const handleMemberAddSuccess = (): void => {
    setShowMemberForm(false)
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
                onSuccess={handleRoleCreateSuccess}
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

          {showMemberForm && (
            <AddMemberForm
              roles={organization.roles ?? []}
              onSuccess={handleMemberAddSuccess}
              onCancel={() => {
                setShowMemberForm(false)
              }}
            />
          )}

          <MemberList
            memberships={memberships}
            users={users}
            onAddMember={() => {
              setShowMemberForm(true)
            }}
          />
        </div>
      </div>
    </div>
  )
}
