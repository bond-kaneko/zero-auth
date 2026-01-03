import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

import { usersApi } from '~/api/users'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { PageHeader } from '~/components/PageHeader'
import { TextField } from '~/components/TextField'

import type { JSX } from 'react'

export default function CreateUserPage(): JSX.Element {
  const navigate = useNavigate()
  const [creating, setCreating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    name: '',
  })

  const handleCreate = async (): Promise<void> => {
    // バリデーション
    if (!formData.email.trim()) {
      setError('Email is required')
      return
    }
    if (!formData.password.trim()) {
      setError('Password is required')
      return
    }

    try {
      setCreating(true)
      setError(null)

      const requestData = {
        email: formData.email,
        password: formData.password,
        name: formData.name.trim() || undefined,
      }

      const user = await usersApi.create(requestData)

      // 作成成功 → 詳細画面へリダイレクト
      void navigate(`/users/${user.id}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create user')
      console.error('Failed to create user:', err)
    } finally {
      setCreating(false)
    }
  }

  const updateField = (field: 'email' | 'password' | 'name', value: string): void => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader title="Create New User" backTo="/users" backText="← Back to Users" />

        {error && <Alert variant="error">{error}</Alert>}

        <Card>
          <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <h2 className="text-xl font-semibold text-gray-900">User Information</h2>
          </div>

          <div className="px-6 py-6 space-y-6">
            {/* Email */}
            <TextField
              id="user-email"
              label="Email"
              type="email"
              value={formData.email}
              onChange={(value) => {
                updateField('email', value)
              }}
              placeholder="user@example.com"
            />

            {/* Password */}
            <TextField
              id="user-password"
              label="Password"
              type="password"
              value={formData.password}
              onChange={(value) => {
                updateField('password', value)
              }}
              placeholder="Enter password"
            />

            {/* Name (Optional) */}
            <TextField
              id="user-name"
              label="Name (Optional)"
              value={formData.name}
              onChange={(value) => {
                updateField('name', value)
              }}
              placeholder="John Doe"
            />
          </div>

          {/* Actions */}
          <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-between">
            <Button
              variant="primary"
              onClick={() => {
                void handleCreate()
              }}
              disabled={creating}
            >
              {creating ? 'Creating...' : 'Create User'}
            </Button>
            <Button
              variant="secondary"
              onClick={() => {
                void navigate('/users')
              }}
              disabled={creating}
            >
              Cancel
            </Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
