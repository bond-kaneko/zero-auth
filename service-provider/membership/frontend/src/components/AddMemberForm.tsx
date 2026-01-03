import { useState, useEffect, useRef, type JSX } from 'react'

import { membershipsApi } from '~/api/memberships'
import { usersApi } from '~/api/users'

import { Alert } from './Alert'
import { Button } from './Button'
import { Card } from './Card'

import type { Role } from '~/types/role'
import type { User } from '~/types/user'

interface AddMemberFormProps {
  roles: Role[]
  onSuccess: () => void
  onCancel: () => void
}

export function AddMemberForm({ roles, onSuccess, onCancel }: AddMemberFormProps): JSX.Element {
  const [keyword, setKeyword] = useState('')
  const [searchResults, setSearchResults] = useState<User[]>([])
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [selectedRoleId, setSelectedRoleId] = useState('')
  const [loading, setLoading] = useState(false)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [showDropdown, setShowDropdown] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  // Search users when keyword changes (with debounce)
  useEffect(() => {
    if (!keyword.trim()) {
      setSearchResults([])
      setShowDropdown(false)
      return
    }

    const timer = setTimeout(() => {
      const searchUsers = async (): Promise<void> => {
        try {
          setSearching(true)
          const results = await usersApi.search(keyword)
          setSearchResults(results)
          setShowDropdown(true)
        } catch (err) {
          console.error('Failed to search users:', err)
          setSearchResults([])
        } finally {
          setSearching(false)
        }
      }

      void searchUsers()
    }, 300)

    return () => {
      clearTimeout(timer)
    }
  }, [keyword])

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent): void => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setShowDropdown(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [])

  const handleUserSelect = (user: User): void => {
    setSelectedUser(user)
    setKeyword(user.email)
    setShowDropdown(false)
  }

  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    e.preventDefault()
    setError(null)

    if (!selectedUser) {
      setError('Please select a user')
      return
    }

    if (!selectedRoleId) {
      setError('Please select a role')
      return
    }

    try {
      setLoading(true)
      await membershipsApi.create(selectedRoleId, { user_id: selectedUser.id_provider_user_id })
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

        <div className="relative" ref={dropdownRef}>
          <label htmlFor="user" className="block text-sm font-medium text-gray-700 mb-1">
            User (search by name or email)
          </label>
          <input
            id="user"
            type="text"
            value={keyword}
            onChange={(e) => {
              setKeyword(e.target.value)
              setSelectedUser(null)
            }}
            placeholder="Type to search..."
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={loading}
            autoComplete="off"
          />
          {searching && (
            <div className="absolute right-3 top-10 text-sm text-gray-500">Searching...</div>
          )}
          {showDropdown && searchResults.length > 0 && (
            <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto">
              {searchResults.map((user) => (
                <button
                  key={user.id_provider_user_id}
                  type="button"
                  onClick={() => {
                    handleUserSelect(user)
                  }}
                  className="w-full px-4 py-2 text-left hover:bg-gray-100 focus:outline-none focus:bg-gray-100"
                >
                  <div className="font-medium text-gray-900">{user.name}</div>
                  <div className="text-sm text-gray-500">{user.email}</div>
                </button>
              ))}
            </div>
          )}
          {showDropdown && searchResults.length === 0 && !searching && keyword.trim() && (
            <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg px-4 py-2 text-sm text-gray-500">
              No users found
            </div>
          )}
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
