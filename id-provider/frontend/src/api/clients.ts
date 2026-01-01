import { apiClient } from './client';
import type { Client, CreateClientRequest, UpdateClientRequest } from '~/types/client';

export const clientsApi = {
  // GET /api/management/clients
  list: () => apiClient.get<Client[]>('/management/clients'),

  // GET /api/management/clients/:id
  get: (id: string) => apiClient.get<Client>(`/management/clients/${id}`),

  // POST /api/management/clients
  create: (data: CreateClientRequest) =>
    apiClient.post<Client>('/management/clients', { client: data }),

  // PATCH /api/management/clients/:id
  update: (id: string, data: UpdateClientRequest) =>
    apiClient.patch<Client>(`/management/clients/${id}`, { client: data }),

  // DELETE /api/management/clients/:id
  delete: (id: string) => apiClient.delete<void>(`/management/clients/${id}`),

  // POST /api/management/clients/:id/revoke_secret
  revokeSecret: (id: string) =>
    apiClient.post<Client>(`/management/clients/${id}/revoke_secret`),
};
