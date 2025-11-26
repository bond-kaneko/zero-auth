defmodule ZeroAuthWeb.OAuthController do
  use ZeroAuthWeb, :controller

  alias ZeroAuth.OIDC
  alias ZeroAuth.OIDC.Authorization
  alias ZeroAuth.OIDC.Client
  alias ZeroAuth.OIDC.JWT
  alias ZeroAuth.OIDC.Token
  alias ZeroAuth.Repo
  alias ZeroAuth.Users.User

  def authorize(conn, params) do
    with {:ok, client} <- get_client(params),
         {:ok, redirect_uri} <- validate_redirect_uri(client, params),
         {:ok, scopes} <- validate_scopes(client, params) do
      if get_session(conn, :user_id) do
        # User is already authenticated, proceed with authorization
        handle_authorization(conn, client, redirect_uri, scopes, params)
      else
        # User needs to login first
        redirect_to_login(conn, params)
      end
    else
      {:error, reason} ->
        error_response(conn, :invalid_request, reason)
    end
  end

  def token(conn, params) do
    case params["grant_type"] do
      "authorization_code" ->
        handle_authorization_code_grant(conn, params)

      "refresh_token" ->
        handle_refresh_token_grant(conn, params)

      _ ->
        error_response(conn, :unsupported_grant_type, "Unsupported grant type")
    end
  end

  def userinfo(conn, _params) do
    case get_auth_header(conn) do
      nil ->
        error_response(conn, :invalid_request, "Missing Authorization header")

      header ->
        token = extract_bearer_token(header)

        case Token.verify_access_token(token) do
          {:ok, access_token} ->
            user = Repo.preload(access_token, :user).user

            json(conn, %{
              "sub" => user.sub,
              "email" => user.email,
              "name" => user.name
            })

          {:error, _reason} ->
            error_response(conn, :invalid_token, "Invalid or expired token")
        end
    end
  end

  def openid_configuration(conn, _params) do
    base_url = get_base_url(conn)

    json(conn, %{
      "issuer" => base_url,
      "authorization_endpoint" => "#{base_url}/oauth/authorize",
      "token_endpoint" => "#{base_url}/oauth/token",
      "userinfo_endpoint" => "#{base_url}/oauth/userinfo",
      "jwks_uri" => "#{base_url}/.well-known/jwks.json",
      "response_types_supported" => ["code"],
      "grant_types_supported" => ["authorization_code", "refresh_token"],
      "subject_types_supported" => ["public"],
      "id_token_signing_alg_values_supported" => ["HS256"],
      "scopes_supported" => ["openid", "profile", "email"],
      "token_endpoint_auth_methods_supported" => ["client_secret_post", "client_secret_basic"]
    })
  end

  defp handle_authorization(conn, client, redirect_uri, scopes, params) do
    user_id = get_session(conn, :user_id)
    user = Repo.get!(User, user_id)

    code_challenge = params["code_challenge"]
    code_challenge_method = params["code_challenge_method"]

    case Authorization.create_authorization_code(
           client,
           user,
           redirect_uri,
           scopes,
           code_challenge,
           code_challenge_method
         ) do
      {:ok, auth_code} ->
        state = params["state"]
        redirect_url = build_redirect_url(redirect_uri, auth_code.code, state)
        redirect(conn, external: redirect_url)

      {:error, _changeset} ->
        error_response(conn, :server_error, "Failed to create authorization code")
    end
  end

  defp handle_authorization_code_grant(conn, params) do
    with {:ok, client} <- authenticate_client(conn, params),
         code when is_binary(code) <- params["code"],
         redirect_uri when is_binary(redirect_uri) <- params["redirect_uri"],
         code_verifier <- params["code_verifier"],
         {:ok, auth_code} <-
           Authorization.verify_authorization_code(code, client.id, redirect_uri, code_verifier) do
      # Mark code as used
      OIDC.mark_authorization_code_as_used(code)

      # Create access token
      user = Repo.preload(auth_code, :user).user

      case Token.create_access_token(client, user, auth_code.scopes) do
        {:ok, access_token} ->
          # Generate ID token if openid scope is present
          id_token =
            if "openid" in auth_code.scopes do
              JWT.generate_id_token(user, client.client_id, params["nonce"])
            else
              nil
            end

          response = %{
            "access_token" => access_token.token,
            "token_type" => "Bearer",
            "expires_in" => 3600,
            "refresh_token" => access_token.refresh_token
          }

          response = if id_token, do: Map.put(response, "id_token", id_token), else: response

          json(conn, response)

        {:error, _changeset} ->
          error_response(conn, :server_error, "Failed to create access token")
      end
    else
      {:error, reason} ->
        error_response(conn, reason, "Invalid authorization code")

      nil ->
        error_response(conn, :invalid_request, "Missing required parameters")
    end
  end

  defp handle_refresh_token_grant(conn, params) do
    with {:ok, client} <- authenticate_client(conn, params),
         refresh_token when is_binary(refresh_token) <- params["refresh_token"],
         {:ok, access_token} <- Token.verify_refresh_token(refresh_token) do
      if access_token.client_id == client.id do
        user = Repo.preload(access_token, :user).user

        case Token.create_access_token(client, user, access_token.scopes) do
          {:ok, new_access_token} ->
            json(conn, %{
              "access_token" => new_access_token.token,
              "token_type" => "Bearer",
              "expires_in" => 3600,
              "refresh_token" => new_access_token.refresh_token
            })

          {:error, _changeset} ->
            error_response(conn, :server_error, "Failed to create access token")
        end
      else
        error_response(conn, :invalid_client, "Invalid client")
      end
    else
      {:error, reason} ->
        error_response(conn, reason, "Invalid refresh token")

      nil ->
        error_response(conn, :invalid_request, "Missing refresh_token")
    end
  end

  defp get_client(params) do
    case params["client_id"] do
      nil ->
        {:error, :invalid_client}

      client_id ->
        case OIDC.get_client_by_client_id(client_id) do
          nil -> {:error, :invalid_client}
          client -> {:ok, client}
        end
    end
  end

  defp validate_redirect_uri(client, params) do
    redirect_uri = params["redirect_uri"]

    if redirect_uri in client.redirect_uris do
      {:ok, redirect_uri}
    else
      {:error, :invalid_redirect_uri}
    end
  end

  defp validate_scopes(client, params) do
    requested_scopes = String.split(params["scope"] || "", " ")
    valid_scopes = Enum.filter(requested_scopes, &(&1 in client.scopes))

    if Enum.empty?(valid_scopes) and not Enum.empty?(requested_scopes) do
      {:error, :invalid_scope}
    else
      {:ok, valid_scopes}
    end
  end

  defp authenticate_client(conn, params) do
    case get_client_auth(conn, params) do
      {client_id, client_secret} ->
        verify_client_credentials(client_id, client_secret)

      _ ->
        {:error, :invalid_client}
    end
  end

  defp verify_client_credentials(client_id, client_secret) do
    case OIDC.get_client_by_client_id(client_id) do
      nil ->
        {:error, :invalid_client}

      client ->
        if Client.verify_secret(client, client_secret) do
          {:ok, client}
        else
          {:error, :invalid_client}
        end
    end
  end

  defp get_client_auth(conn, params) do
    # Try Basic Auth first
    case get_auth_header(conn) do
      "Basic " <> encoded ->
        case Base.decode64(encoded) do
          {:ok, decoded} ->
            [client_id, client_secret] = String.split(decoded, ":", parts: 2)
            {client_id, client_secret}

          _ ->
            nil
        end

      _ ->
        # Try POST parameters
        case {params["client_id"], params["client_secret"]} do
          {client_id, client_secret} when is_binary(client_id) and is_binary(client_secret) ->
            {client_id, client_secret}

          _ ->
            nil
        end
    end
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [header] -> header
      _ -> nil
    end
  end

  defp extract_bearer_token("Bearer " <> token), do: String.trim(token)
  defp extract_bearer_token(token), do: token

  defp redirect_to_login(conn, params) do
    query_string = URI.encode_query(params)
    redirect(conn, to: "/login?#{query_string}")
  end

  defp build_redirect_url(redirect_uri, code, state) do
    params = [{"code", code}]
    params = if state, do: [{"state", state} | params], else: params
    "#{redirect_uri}?#{URI.encode_query(params)}"
  end

  defp get_base_url(conn) do
    scheme = if conn.scheme == :https, do: "https", else: "http"
    host = conn.host
    port = conn.port

    if port in [80, 443] do
      "#{scheme}://#{host}"
    else
      "#{scheme}://#{host}:#{port}"
    end
  end

  defp error_response(conn, error, description) do
    conn
    |> put_status(400)
    |> json(%{
      "error" => to_string(error),
      "error_description" => description
    })
  end
end
