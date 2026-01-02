import { Link } from 'react-router-dom'

import { DateTime } from '~/components/DateTime'

import type { JSX } from 'react'
import type { Organization } from '~/types/organization'

interface OrganizationTableRowProps {
  organization: Organization
}

export function OrganizationTableRow({ organization }: OrganizationTableRowProps): JSX.Element {
  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
        <Link
          to={`/organizations/${organization.id}`}
          className="text-blue-600 hover:text-blue-800 hover:underline"
        >
          {organization.name}
        </Link>
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
        {organization.slug}
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
        <DateTime value={organization.created_at} />
      </td>
    </tr>
  )
}
