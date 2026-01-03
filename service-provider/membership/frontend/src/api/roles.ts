import { apiClient } from './client'

import type { Role } from '~/types/role'

export const rolesApi = {
  // POST /api/organizations/:organization_id/roles
  create: (organizationId: string, data: { name: string; permissions: string[] }) =>
    apiClient.post<Role>(`/organizations/${organizationId}/roles`, { role: data }),
}
