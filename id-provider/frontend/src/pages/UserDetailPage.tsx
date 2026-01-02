import { useState, useEffect, useCallback } from 'react'
import { useParams, useNavigate } from 'react-router-dom'

import { usersApi } from '~/api/users'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { DateTime } from '~/components/DateTime'
import { LoadingSpinner } from '~/components/LoadingSpinner'
import { PageHeader } from '~/components/PageHeader'
import { ReadOnlyField } from '~/components/ReadOnlyField'
import { TextField } from '~/components/TextField'

import type { JSX } from 'react'
import type { User } from '~/types/user'

export default function UserDetailPage(): JSX.Element {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    given_name: '',
    family_name: '',
    picture: '',
    email_verified: false,
  })

  const loadUser = useCallback(async (): Promise<void> => {
    if (!id) return

    try {
      setLoading(true)
      setError(null)
      const data = await usersApi.get(id)
      setUser(data)
      setFormData({
        name: data.name ?? '',
        given_name: data.given_name ?? '',
        family_name: data.family_name ?? '',
        picture: data.picture ?? '',
        email_verified: data.email_verified,
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load user')
      console.error('Failed to load user:', err)
    } finally {
      setLoading(false)
    }
  }, [id])

  useEffect(() => {
    void loadUser()
  }, [loadUser])

  const handleDelete = async (): Promise<void> => {
    if (
      !id ||
      !confirm('Are you sure you want to delete this user? This action cannot be undone.')
    ) {
      return
    }

    try {
      await usersApi.delete(id)
      void navigate('/users')
    } catch (err) {
      alert(err instanceof Error ? err.message : 'Failed to delete user')
      console.error('Failed to delete user:', err)
    }
  }

  const handleSave = async (): Promise<void> => {
    if (!id) return

    try {
      setSaving(true)
      const updatedUser = await usersApi.update(id, formData)
      setUser(updatedUser)
      setFormData({
        name: updatedUser.name ?? '',
        given_name: updatedUser.given_name ?? '',
        family_name: updatedUser.family_name ?? '',
        picture: updatedUser.picture ?? '',
        email_verified: updatedUser.email_verified,
      })
      alert('User updated successfully')
    } catch (err) {
      alert(err instanceof Error ? err.message : 'Failed to update user')
      console.error('Failed to update user:', err)
    } finally {
      setSaving(false)
    }
  }

  const updateTextField = (
    field: 'name' | 'given_name' | 'family_name' | 'picture',
    value: string
  ): void => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <LoadingSpinner />
      </div>
    )
  }

  if (error || !user) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <PageHeader title="User Details" backTo="/users" backText="← Back to Users" />
          <Alert variant="error">{error ?? 'User not found'}</Alert>
        </div>
      </div>
    )
  }

  const displayName =
    (user.name ?? `${user.given_name ?? ''} ${user.family_name ?? ''}`.trim()) || user.email

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader title="User Details" backTo="/users" backText="← Back to Users" />

        <Card>
          <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <h2 className="text-xl font-semibold text-gray-900">{displayName}</h2>
          </div>

          <div className="px-6 py-6 space-y-6">
            {/* Email */}
            <ReadOnlyField label="Email" value={user.email} />

            {/* Sub */}
            <ReadOnlyField label="Subject (sub)" value={user.sub} />

            {/* Name */}
            <TextField
              id="user-name"
              label="Name"
              value={formData.name}
              onChange={(value) => {
                updateTextField('name', value)
              }}
            />

            {/* Given Name */}
            <TextField
              id="user-given-name"
              label="Given Name"
              value={formData.given_name}
              onChange={(value) => {
                updateTextField('given_name', value)
              }}
            />

            {/* Family Name */}
            <TextField
              id="user-family-name"
              label="Family Name"
              value={formData.family_name}
              onChange={(value) => {
                updateTextField('family_name', value)
              }}
            />

            {/* Picture */}
            <TextField
              id="user-picture"
              label="Picture URL"
              value={formData.picture}
              onChange={(value) => {
                updateTextField('picture', value)
              }}
            />

            {/* Email Verified */}
            <div>
              <label htmlFor="email-verified" className="flex items-center">
                <input
                  id="email-verified"
                  type="checkbox"
                  checked={formData.email_verified}
                  onChange={(e) => {
                    setFormData((prev) => ({ ...prev, email_verified: e.target.checked }))
                  }}
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
                <span className="ml-2 text-sm font-medium text-gray-700">Email Verified</span>
              </label>
            </div>

            {/* Metadata */}
            <div className="grid grid-cols-2 gap-4 pt-4 border-gray-200">
              <div>
                <div className="block text-sm font-medium text-gray-700 mb-1">Created At</div>
                <p className="text-sm text-gray-900">
                  <DateTime value={user.created_at} />
                </p>
              </div>
              <div>
                <div className="block text-sm font-medium text-gray-700 mb-1">Updated At</div>
                <p className="text-sm text-gray-900">
                  <DateTime value={user.updated_at} />
                </p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-between">
            <Button
              variant="primary"
              onClick={() => {
                void handleSave()
              }}
              disabled={saving}
            >
              {saving ? 'Saving...' : 'Save Changes'}
            </Button>
            <Button
              variant="danger"
              onClick={() => {
                void handleDelete()
              }}
            >
              Delete User
            </Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
