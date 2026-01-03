import { apiClient } from './client'

import type { User } from '~/types/user'

export const usersApi = {
  // GET /api/users
  list: () => apiClient.get<User[]>('/users'),

  // GET /api/users?keyword=xxx
  search: (keyword: string) =>
    apiClient.get<User[]>(`/users?keyword=${encodeURIComponent(keyword)}`),

  // POST /api/users/sync
  sync: () => apiClient.post<{ synced_count: number }>('/users/sync', {}),
}
