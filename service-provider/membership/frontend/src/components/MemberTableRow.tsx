import type { JSX } from 'react'
import type { Membership } from '~/types/membership'
import type { Role } from '~/types/role'
import type { User } from '~/types/user'

interface MemberTableRowProps {
  memberships: Membership[]
  user: User | undefined
}

export function MemberTableRow({ memberships, user }: MemberTableRowProps): JSX.Element {
  const roles = memberships.reduce<Role[]>((acc, m) => {
    if (m.role) {
      acc.push(m.role)
    }
    return acc
  }, [])

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
        {user?.name ?? 'Unknown'}
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user?.email ?? 'N/A'}</td>
      <td className="px-6 py-4 text-sm text-gray-500">
        <div className="flex flex-wrap gap-1">
          {roles.map((role) => (
            <span
              key={role.id}
              className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-green-100 text-green-800"
            >
              {role.name}
            </span>
          ))}
        </div>
      </td>
    </tr>
  )
}
