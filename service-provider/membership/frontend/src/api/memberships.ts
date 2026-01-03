import { apiClient } from './client'

import type { Membership } from '~/types/membership'

export const membershipsApi = {
  // GET /api/organizations/:organization_id/memberships
  list: (organizationId: string) =>
    apiClient.get<Membership[]>(`/organizations/${organizationId}/memberships`),

  // POST /api/roles/:role_id/memberships
  create: (roleId: string, data: { user_id: string }) =>
    apiClient.post<Membership>(`/roles/${roleId}/memberships`, { membership: data }),
}
