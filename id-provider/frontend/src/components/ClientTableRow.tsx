import { Link } from 'react-router-dom'

import type { Client } from '~/types/client'

interface ClientTableRowProps {
  client: Client
}

export function ClientTableRow({ client }: ClientTableRowProps): JSX.Element {
  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
        <Link
          to={`/clients/${client.id}`}
          className="text-blue-600 hover:text-blue-800 hover:underline"
        >
          {client.name}
        </Link>
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
        {client.client_id}
      </td>
      <td className="px-6 py-4 text-sm text-gray-500">{client.redirect_uris.join(', ')}</td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
        {new Date(client.created_at).toLocaleDateString()}
      </td>
    </tr>
  )
}
