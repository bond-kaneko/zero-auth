import { apiClient } from './client'

import type { Organization } from '~/types/organization'

export const organizationsApi = {
  // GET /api/organizations
  list: () => apiClient.get<Organization[]>('/organizations'),

  // GET /api/organizations/:id
  get: (id: string) => apiClient.get<Organization>(`/organizations/${id}`),

  // POST /api/organizations
  create: (data: Omit<Organization, 'id' | 'created_at' | 'updated_at'>) =>
    apiClient.post<Organization>('/organizations', { organization: data }),

  // PATCH /api/organizations/:id
  update: (id: string, data: Partial<Omit<Organization, 'id' | 'created_at' | 'updated_at'>>) =>
    apiClient.patch<Organization>(`/organizations/${id}`, { organization: data }),

  // DELETE /api/organizations/:id
  delete: (id: string) => apiClient.delete<null>(`/organizations/${id}`),
}
