defmodule ZeroAuth.OIDC.Authorization do
  @moduledoc """
  Module for generating and verifying authorization codes
  """

  alias ZeroAuth.OIDC

  @code_length 32
  @expires_in_seconds 600

  def generate_code do
    :crypto.strong_rand_bytes(@code_length)
    |> Base.url_encode64(padding: false)
  end

  def create_authorization_code(
        client,
        user,
        redirect_uri,
        scopes,
        code_challenge \\ nil,
        code_challenge_method \\ nil
      ) do
    code = generate_code()
    expires_at = DateTime.add(DateTime.utc_now(), @expires_in_seconds, :second)

    attrs = %{
      code: code,
      client_id: client.id,
      user_id: user.id,
      redirect_uri: redirect_uri,
      scopes: scopes,
      code_challenge: code_challenge,
      code_challenge_method: code_challenge_method,
      expires_at: expires_at
    }

    OIDC.create_authorization_code(attrs)
  end

  def verify_authorization_code(code, client_id, redirect_uri, code_verifier \\ nil) do
    case OIDC.get_authorization_code_by_code(code) do
      nil ->
        {:error, :invalid_code}

      auth_code ->
        cond do
          auth_code.used ->
            {:error, :code_already_used}

          auth_code.client_id != client_id ->
            {:error, :invalid_client}

          auth_code.redirect_uri != redirect_uri ->
            {:error, :invalid_redirect_uri}

          DateTime.compare(auth_code.expires_at, DateTime.utc_now()) == :lt ->
            {:error, :expired_code}

          auth_code.code_challenge != nil and not verify_code_challenge(auth_code, code_verifier) ->
            {:error, :invalid_code_verifier}

          true ->
            {:ok, auth_code}
        end
    end
  end

  defp verify_code_challenge(auth_code, code_verifier) when is_binary(code_verifier) do
    case auth_code.code_challenge_method do
      "S256" ->
        challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)
        challenge == auth_code.code_challenge

      "plain" ->
        code_verifier == auth_code.code_challenge

      _ ->
        false
    end
  end

  defp verify_code_challenge(_auth_code, _code_verifier), do: false
end
