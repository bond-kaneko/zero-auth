export interface Client {
  id: string;
  name: string;
  redirect_uri: string;
  client_id: string;
  created_at: string;
  updated_at: string;
}

export interface CreateClientRequest {
  name: string;
  redirect_uri: string;
}

export interface UpdateClientRequest {
  name?: string;
  redirect_uri?: string;
}
