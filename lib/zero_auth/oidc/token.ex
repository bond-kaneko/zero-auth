defmodule ZeroAuth.OIDC.Token do
  @moduledoc """
  Module for generating and verifying access tokens and refresh tokens
  """

  alias ZeroAuth.OIDC

  @token_length 32
  @access_token_expires_in_seconds 3600
  @refresh_token_expires_in_seconds 86_400 * 30

  def generate_token do
    :crypto.strong_rand_bytes(@token_length)
    |> Base.url_encode64(padding: false)
  end

  def create_access_token(client, user, scopes) do
    token = generate_token()
    refresh_token = generate_token()
    expires_at = DateTime.add(DateTime.utc_now(), @access_token_expires_in_seconds, :second)

    refresh_token_expires_at =
      DateTime.add(DateTime.utc_now(), @refresh_token_expires_in_seconds, :second)

    attrs = %{
      token: token,
      refresh_token: refresh_token,
      client_id: client.id,
      user_id: user.id,
      scopes: scopes,
      expires_at: expires_at,
      refresh_token_expires_at: refresh_token_expires_at
    }

    OIDC.create_access_token(attrs)
  end

  def verify_access_token(token) do
    case OIDC.get_access_token_by_token(token) do
      nil ->
        {:error, :invalid_token}

      access_token ->
        if DateTime.compare(access_token.expires_at, DateTime.utc_now()) == :lt do
          {:error, :expired_token}
        else
          {:ok, access_token}
        end
    end
  end

  def verify_refresh_token(refresh_token) do
    case OIDC.get_access_token_by_refresh_token(refresh_token) do
      nil ->
        {:error, :invalid_refresh_token}

      access_token ->
        if DateTime.compare(access_token.refresh_token_expires_at, DateTime.utc_now()) == :lt do
          {:error, :expired_refresh_token}
        else
          {:ok, access_token}
        end
    end
  end
end
