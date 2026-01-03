import type { JSX } from 'react'
import type { Role } from '~/types/role'

interface RoleTableRowProps {
  role: Role
}

export function RoleTableRow({ role }: RoleTableRowProps): JSX.Element {
  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{role.name}</td>
      <td className="px-6 py-4 text-sm text-gray-500">
        <div className="flex flex-wrap gap-1">
          {role.permissions.map((permission) => (
            <span
              key={permission}
              className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-blue-100 text-blue-800"
            >
              {permission}
            </span>
          ))}
        </div>
      </td>
    </tr>
  )
}
