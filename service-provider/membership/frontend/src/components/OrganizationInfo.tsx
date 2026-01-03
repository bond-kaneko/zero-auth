import { Card } from '~/components/Card'

import type { JSX } from 'react'
import type { Organization } from '~/types/organization'

interface OrganizationInfoProps {
  organization: Organization
}

export function OrganizationInfo({ organization }: OrganizationInfoProps): JSX.Element {
  return (
    <Card className="p-6">
      <div className="mb-4">
        <h2 className="text-xl font-semibold text-gray-900">Organization Details</h2>
      </div>
      <dl className="grid grid-cols-1 gap-4">
        <div>
          <dt className="text-sm font-medium text-gray-500">Name</dt>
          <dd className="mt-1 text-sm text-gray-900">{organization.name}</dd>
        </div>
        <div>
          <dt className="text-sm font-medium text-gray-500">Slug</dt>
          <dd className="mt-1 text-sm text-gray-900 font-mono">{organization.slug}</dd>
        </div>
      </dl>
    </Card>
  )
}
