defmodule ZeroAuth.OIDC.JWT do
  @moduledoc """
  Module for generating and verifying JWTs
  """

  alias Joken.Config
  alias Joken.Signer

  @issuer "zero-auth"
  @algorithm "HS256"

  def generate_signer(secret) do
    Signer.create(@algorithm, secret)
  end

  def generate_id_token(user, client_id, nonce \\ nil) do
    now = DateTime.utc_now() |> DateTime.to_unix()
    exp = now + 3600

    claims = %{
      "iss" => @issuer,
      "sub" => user.sub,
      "aud" => client_id,
      "exp" => exp,
      "iat" => now,
      "auth_time" => now,
      "email" => user.email,
      "name" => user.name
    }

    claims = if nonce, do: Map.put(claims, "nonce", nonce), else: claims

    secret = get_secret()
    signer = generate_signer(secret)

    Joken.generate_and_sign!(%{}, claims, signer)
  end

  def verify_id_token(token, client_id) do
    secret = get_secret()
    signer = generate_signer(secret)

    with {:ok, claims} <- Joken.verify_and_validate(token, Config.default_claims(), signer) do
      if claims["aud"] == client_id and claims["iss"] == @issuer do
        {:ok, claims}
      else
        {:error, :invalid_claims}
      end
    end
  end

  defp get_secret do
    Application.get_env(:zero_auth, :jwt_secret, "default-secret-change-in-production")
  end
end
