export interface User {
  id: string
  sub: string
  email: string
  name?: string
  given_name?: string
  family_name?: string
  picture?: string
  email_verified: boolean
  created_at: string
  updated_at: string
}

export interface CreateUserRequest {
  email: string
  password: string
  name?: string
  given_name?: string
  family_name?: string
  picture?: string
}

export interface UpdateUserRequest {
  name?: string
  given_name?: string
  family_name?: string
  picture?: string
  email_verified?: boolean
}
