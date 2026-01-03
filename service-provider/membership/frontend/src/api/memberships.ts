import { apiClient } from './client'

import type { Membership } from '~/types/membership'

export const membershipsApi = {
  // GET /api/organizations/:organization_id/memberships
  list: (organizationId: string, keyword?: string) => {
    const url = keyword
      ? `/organizations/${organizationId}/memberships?keyword=${encodeURIComponent(keyword)}`
      : `/organizations/${organizationId}/memberships`
    return apiClient.get<Membership[]>(url)
  },

  // POST /api/roles/:role_id/memberships
  create: (roleId: string, data: { user_id: string }) =>
    apiClient.post<Membership>(`/roles/${roleId}/memberships`, { membership: data }),
}
