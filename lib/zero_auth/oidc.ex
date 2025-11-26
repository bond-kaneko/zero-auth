defmodule ZeroAuth.OIDC do
  @moduledoc """
  Context module for OIDC-related operations
  """

  alias ZeroAuth.Repo
  alias ZeroAuth.OIDC.Client
  alias ZeroAuth.OIDC.AuthorizationCode
  alias ZeroAuth.OIDC.AccessToken

  def get_client_by_client_id(client_id) do
    Repo.get_by(Client, client_id: client_id)
  end

  def create_client(attrs) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  def create_authorization_code(attrs) do
    %AuthorizationCode{}
    |> AuthorizationCode.changeset(attrs)
    |> Repo.insert()
  end

  def get_authorization_code_by_code(code) do
    Repo.get_by(AuthorizationCode, code: code)
    |> Repo.preload([:client, :user])
  end

  def mark_authorization_code_as_used(code) do
    case get_authorization_code_by_code(code) do
      nil -> {:error, :not_found}
      auth_code ->
        auth_code
        |> AuthorizationCode.changeset(%{used: true})
        |> Repo.update()
    end
  end

  def create_access_token(attrs) do
    %AccessToken{}
    |> AccessToken.changeset(attrs)
    |> Repo.insert()
  end

  def get_access_token_by_token(token) do
    Repo.get_by(AccessToken, token: token)
    |> Repo.preload([:client, :user])
  end

  def get_access_token_by_refresh_token(refresh_token) do
    Repo.get_by(AccessToken, refresh_token: refresh_token)
    |> Repo.preload([:client, :user])
  end

  def list_clients do
    Repo.all(Client)
  end

  def get_client(id) do
    Repo.get(Client, id)
  end

  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  def rotate_client_secret(%Client{} = client) do
    new_secret = Client.generate_client_secret()

    client
    |> Client.changeset(%{client_secret: new_secret})
    |> Repo.update()
    |> case do
      {:ok, updated_client} -> {:ok, updated_client, new_secret}
      error -> error
    end
  end
end

