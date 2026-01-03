import { useState, useMemo, useEffect, type JSX } from 'react'

import { membershipsApi } from '~/api/memberships'
import { usersApi } from '~/api/users'

import { Card } from './Card'
import { LoadingSpinner } from './LoadingSpinner'
import { MemberTableHeader } from './MemberTableHeader'
import { MemberTableRow } from './MemberTableRow'

import type { Membership } from '~/types/membership'
import type { User } from '~/types/user'

interface MemberListProps {
  organizationId: string
  onAddMember: () => void
}

export function MemberList({ organizationId, onAddMember }: MemberListProps): JSX.Element {
  const [searchQuery, setSearchQuery] = useState('')
  const [memberships, setMemberships] = useState<Membership[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(false)

  // Fetch memberships with search keyword
  useEffect(() => {
    const fetchMemberships = async (): Promise<void> => {
      try {
        setLoading(true)
        const data = await membershipsApi.list(organizationId, searchQuery.trim() || undefined)
        setMemberships(data)
      } catch (err) {
        console.error('Failed to fetch memberships:', err)
        setMemberships([])
      } finally {
        setLoading(false)
      }
    }

    const timer = setTimeout(() => {
      void fetchMemberships()
    }, 300) // Debounce search

    return () => {
      clearTimeout(timer)
    }
  }, [organizationId, searchQuery])

  // Fetch users for the membership user IDs
  useEffect(() => {
    const fetchUsers = async (): Promise<void> => {
      try {
        const userIds = [...new Set(memberships.map((m) => m.user_id))]
        if (userIds.length === 0) {
          setUsers([])
          return
        }

        const allUsers = await usersApi.list()
        const relevantUsers = allUsers.filter((u) => userIds.includes(u.id_provider_user_id))
        setUsers(relevantUsers)
      } catch (err) {
        console.error('Failed to fetch users:', err)
        setUsers([])
      }
    }

    void fetchUsers()
  }, [memberships])

  // Create user lookup map for efficient access
  const userMap = useMemo(() => {
    const map = new Map<string, User>()
    users.forEach((user) => {
      map.set(user.id_provider_user_id, user)
    })
    return map
  }, [users])

  // Get unique users from memberships
  const uniqueUserIds = useMemo(() => {
    const userIds = new Set<string>()
    memberships.forEach((m) => {
      userIds.add(m.user_id)
    })
    return Array.from(userIds)
  }, [memberships])

  // Group memberships by user
  const membershipsByUser = useMemo(() => {
    const map = new Map<string, Membership[]>()
    memberships.forEach((membership) => {
      const existing = map.get(membership.user_id) ?? []
      map.set(membership.user_id, [...existing, membership])
    })
    return map
  }, [memberships])

  return (
    <Card>
      <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900">Members</h3>
          <p className="text-sm text-gray-500 mt-1">{uniqueUserIds.length} members</p>
        </div>
        <button
          onClick={() => {
            onAddMember()
          }}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
        >
          Add Member
        </button>
      </div>

      <div className="px-6 py-4 border-b border-gray-200">
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => {
            setSearchQuery(e.target.value)
          }}
          placeholder="Search by name, email, or role..."
          className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      {loading ? (
        <div className="px-6 py-12">
          <LoadingSpinner />
        </div>
      ) : uniqueUserIds.length > 0 ? (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <MemberTableHeader />
            <tbody className="bg-white divide-y divide-gray-200">
              {uniqueUserIds.map((userId) => {
                const user = userMap.get(userId)
                const userMemberships = membershipsByUser.get(userId) ?? []

                if (userMemberships.length === 0) return null

                return <MemberTableRow key={userId} memberships={userMemberships} user={user} />
              })}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="px-6 py-12 text-center text-gray-500">
          {searchQuery ? 'No members found matching your search.' : 'No members yet.'}
        </div>
      )}
    </Card>
  )
}
