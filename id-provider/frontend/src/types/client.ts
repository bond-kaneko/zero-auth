export interface Client {
  id: string
  name: string
  redirect_uris: string[]
  client_id: string
  client_secret: string
  created_at: string
  updated_at: string
  grant_types?: string[]
  response_types?: string[]
  scopes?: string[]
  active?: boolean
}

export interface CreateClientRequest {
  name: string
  redirect_uris: string[]
  grant_types: string[]
  response_types: string[]
  scopes?: string[]
}

export interface UpdateClientRequest {
  name?: string
  redirect_uris?: string[]
  grant_types?: string[]
  response_types?: string[]
  scopes?: string[]
}
