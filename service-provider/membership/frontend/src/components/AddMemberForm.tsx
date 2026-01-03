import { useState, type JSX } from 'react'

import { membershipsApi } from '~/api/memberships'

import { Alert } from './Alert'
import { Button } from './Button'
import { Card } from './Card'

import type { Role } from '~/types/role'
import type { User } from '~/types/user'

interface AddMemberFormProps {
  roles: Role[]
  users: User[]
  onSuccess: () => void
  onCancel: () => void
}

export function AddMemberForm({
  roles,
  users,
  onSuccess,
  onCancel,
}: AddMemberFormProps): JSX.Element {
  const [selectedUserId, setSelectedUserId] = useState('')
  const [selectedRoleId, setSelectedRoleId] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    e.preventDefault()
    setError(null)

    if (!selectedUserId) {
      setError('Please select a user')
      return
    }

    if (!selectedRoleId) {
      setError('Please select a role')
      return
    }

    try {
      setLoading(true)
      await membershipsApi.create(selectedRoleId, { user_id: selectedUserId })
      onSuccess()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add member')
      console.error('Failed to add member:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card>
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">Add Member</h3>
      </div>

      <form
        onSubmit={(e) => {
          void handleSubmit(e)
        }}
        className="p-6 space-y-4"
      >
        {error && <Alert variant="error">{error}</Alert>}

        <div>
          <label htmlFor="user" className="block text-sm font-medium text-gray-700 mb-1">
            User
          </label>
          <select
            id="user"
            value={selectedUserId}
            onChange={(e) => {
              setSelectedUserId(e.target.value)
            }}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={loading}
          >
            <option value="">Select a user...</option>
            {users.map((user) => (
              <option key={user.id_provider_user_id} value={user.id_provider_user_id}>
                {user.name} ({user.email})
              </option>
            ))}
          </select>
        </div>

        <div>
          <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-1">
            Role
          </label>
          <select
            id="role"
            value={selectedRoleId}
            onChange={(e) => {
              setSelectedRoleId(e.target.value)
            }}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={loading}
          >
            <option value="">Select a role...</option>
            {roles.map((role) => (
              <option key={role.id} value={role.id}>
                {role.name}
              </option>
            ))}
          </select>
        </div>

        <div className="flex gap-3 pt-4">
          <Button type="submit" variant="primary" disabled={loading}>
            {loading ? 'Adding...' : 'Add Member'}
          </Button>
          <Button
            type="button"
            variant="secondary"
            onClick={() => {
              onCancel()
            }}
            disabled={loading}
          >
            Cancel
          </Button>
        </div>
      </form>
    </Card>
  )
}
