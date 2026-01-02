import { apiClient } from './client'

import type { User, CreateUserRequest, UpdateUserRequest } from '~/types/user'

export const usersApi = {
  list: () => apiClient.get<User[]>('/management/users'),
  get: (id: string) => apiClient.get<User>(`/management/users/${id}`),
  create: (data: CreateUserRequest) => apiClient.post<User>('/management/users', { user: data }),
  update: (id: string, data: UpdateUserRequest) =>
    apiClient.patch<User>(`/management/users/${id}`, { user: data }),
  delete: (id: string) => apiClient.delete<null>(`/management/users/${id}`),
}
