import { useState, useMemo, type JSX } from 'react'

import { Card } from './Card'
import { MemberTableHeader } from './MemberTableHeader'
import { MemberTableRow } from './MemberTableRow'

import type { Membership } from '~/types/membership'
import type { User } from '~/types/user'

interface MemberListProps {
  memberships: Membership[]
  users: User[]
  onAddMember: () => void
}

export function MemberList({ memberships, users, onAddMember }: MemberListProps): JSX.Element {
  const [searchQuery, setSearchQuery] = useState('')

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

  // Filter users by search query
  const filteredUserIds = useMemo(() => {
    if (!searchQuery.trim()) {
      return uniqueUserIds
    }

    const query = searchQuery.toLowerCase()
    return uniqueUserIds.filter((userId) => {
      const user = userMap.get(userId)
      if (!user) return false

      return user.name.toLowerCase().includes(query) || user.email.toLowerCase().includes(query)
    })
  }, [uniqueUserIds, userMap, searchQuery])

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
          <p className="text-sm text-gray-500 mt-1">{filteredUserIds.length} members</p>
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
          placeholder="Search by name or email..."
          className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      {filteredUserIds.length > 0 ? (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <MemberTableHeader />
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredUserIds.map((userId) => {
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
