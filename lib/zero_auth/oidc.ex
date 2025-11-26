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
end

