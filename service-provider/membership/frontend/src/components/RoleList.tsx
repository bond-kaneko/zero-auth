import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { RoleTableHeader } from '~/components/RoleTableHeader'
import { RoleTableRow } from '~/components/RoleTableRow'

import type { JSX } from 'react'
import type { Role } from '~/types/role'

interface RoleListProps {
  roles: Role[]
  showForm: boolean
  onAddClick: () => void
}

export function RoleList({ roles, showForm, onAddClick }: RoleListProps): JSX.Element {
  return (
    <Card className="p-6">
      <div className="mb-6 flex justify-between items-center">
        <h2 className="text-xl font-semibold text-gray-900">Roles</h2>
        {!showForm && (
          <Button
            variant="primary"
            onClick={() => {
              onAddClick()
            }}
          >
            Add Role
          </Button>
        )}
      </div>

      {roles.length === 0 && (
        <div className="text-gray-600">
          <p>No roles yet.</p>
        </div>
      )}

      {roles.length > 0 && (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <RoleTableHeader />
            <tbody className="bg-white divide-y divide-gray-200">
              {roles.map((role) => (
                <RoleTableRow key={role.id} role={role} />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Card>
  )
}
