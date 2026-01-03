import type { Role } from './role'

export interface Membership {
  id: string
  user_id: string
  role_id: string
  role?: Role
  created_at: string
  updated_at: string
}
