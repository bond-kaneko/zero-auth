import { DateTime } from '~/components/DateTime'

import type { JSX } from 'react'
import type { User } from '~/types/user'

interface UserTableRowProps {
  user: User
}

export function UserTableRow({ user }: UserTableRowProps): JSX.Element {
  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.email}</td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.name}</td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
        <DateTime value={user.created_at} />
      </td>
    </tr>
  )
}
