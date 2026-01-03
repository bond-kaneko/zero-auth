import { apiClient } from './client'

import type { User } from '~/types/user'

export const usersApi = {
  // GET /api/users
  list: () => apiClient.get<User[]>('/users'),

  // POST /api/users/sync
  sync: () => apiClient.post<{ synced_count: number }>('/users/sync', {}),
}
