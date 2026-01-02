import { Link } from 'react-router-dom'

import { DateTime } from './DateTime'

import type { JSX } from 'react'
import type { User } from '~/types/user'

interface UserTableRowProps {
  user: User
}

export function UserTableRow({ user }: UserTableRowProps): JSX.Element {
  const displayName =
    (user.name ?? `${user.given_name ?? ''} ${user.family_name ?? ''}`.trim()) || user.email

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
        <Link
          to={`/users/${user.id}`}
          className="text-blue-600 hover:text-blue-800 hover:underline"
        >
          {user.email}
        </Link>
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{displayName}</td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
        {user.email_verified ? (
          <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
            Verified
          </span>
        ) : (
          <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
            Unverified
          </span>
        )}
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
        <DateTime value={user.created_at} />
      </td>
    </tr>
  )
}
