import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

import { usersApi } from '~/api/users'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { LoadingSpinner } from '~/components/LoadingSpinner'
import { PageHeader } from '~/components/PageHeader'
import { UserTableHeader } from '~/components/UserTableHeader'
import { UserTableRow } from '~/components/UserTableRow'

import type { JSX } from 'react'
import type { User } from '~/types/user'

export default function UsersPage(): JSX.Element {
  const navigate = useNavigate()
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    void loadUsers()
  }, [])

  const loadUsers = async (): Promise<void> => {
    try {
      setLoading(true)
      setError(null)
      const data = await usersApi.list()
      setUsers(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load users')
      console.error('Failed to load users:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader title="User Management" backTo="/" backText="← Back to Home" />

        <Card className="p-6">
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Users</h2>
            <Button
              variant="primary"
              onClick={() => {
                void navigate('/users/new')
              }}
            >
              Add User
            </Button>
          </div>

          {loading && <LoadingSpinner />}

          {error && <Alert variant="error">{error}</Alert>}

          {!loading && !error && users.length === 0 && (
            <div className="text-gray-600">
              <p>No users yet. Click "Add User" to create one.</p>
            </div>
          )}

          {!loading && !error && users.length > 0 && (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <UserTableHeader />
                <tbody className="bg-white divide-y divide-gray-200">
                  {users.map((user) => (
                    <UserTableRow key={user.id} user={user} />
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
