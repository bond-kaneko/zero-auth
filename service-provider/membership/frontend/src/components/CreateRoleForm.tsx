import { useState } from 'react'

import { rolesApi } from '~/api/roles'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'

import type { JSX } from 'react'

interface CreateRoleFormProps {
  organizationId: string
  onSuccess: () => void
  onCancel: () => void
}

export function CreateRoleForm({
  organizationId,
  onSuccess,
  onCancel,
}: CreateRoleFormProps): JSX.Element {
  const [name, setName] = useState('')
  const [permissionsText, setPermissionsText] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    e.preventDefault()
    setError(null)

    if (!name.trim()) {
      setError('Name is required')
      return
    }

    const permissions = permissionsText
      .split(',')
      .map((p) => p.trim())
      .filter((p) => p.length > 0)

    if (permissions.length === 0) {
      setError('At least one permission is required')
      return
    }

    try {
      setLoading(true)
      await rolesApi.create(organizationId, { name: name.trim(), permissions })
      onSuccess()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create role')
      console.error('Failed to create role:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form
      onSubmit={(e) => {
        void handleSubmit(e)
      }}
      className="space-y-4"
    >
      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
          Role Name
        </label>
        <input
          id="name"
          type="text"
          value={name}
          onChange={(e) => {
            setName(e.target.value)
          }}
          disabled={loading}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
          placeholder="Admin, Member, Viewer, etc."
        />
      </div>

      <div>
        <label htmlFor="permissions" className="block text-sm font-medium text-gray-700 mb-1">
          Permissions
        </label>
        <input
          id="permissions"
          type="text"
          value={permissionsText}
          onChange={(e) => {
            setPermissionsText(e.target.value)
          }}
          disabled={loading}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
          placeholder="read, write, delete"
        />
        <p className="mt-1 text-xs text-gray-500">Comma-separated list of permissions</p>
      </div>

      {error && <Alert variant="error">{error}</Alert>}

      <div className="flex gap-3 justify-end">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={loading}>
          Cancel
        </Button>
        <Button type="submit" variant="primary" disabled={loading}>
          {loading ? 'Creating...' : 'Create Role'}
        </Button>
      </div>
    </form>
  )
}
