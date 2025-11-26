defmodule ExampleClient.OIDC.Client do
  @moduledoc """
  OIDC client for authenticating with zero-auth provider
  """

  @default_provider_url_browser "http://localhost:4000"
  @default_provider_url_server "http://app:4000"
  @default_redirect_uri "http://localhost:4001/auth/callback"

  # Browser-facing URL (used in authorize_url for redirects)
  defp provider_url_browser do
    Application.get_env(:example_client, :provider_url_browser, @default_provider_url_browser)
  end

  # Server-side URL (used in exchange_code and get_userinfo for server-to-server calls)
  defp provider_url_server do
    Application.get_env(:example_client, :provider_url, @default_provider_url_server)
  end

  defp client_id do
    Application.get_env(:example_client, :client_id)
  end

  defp client_secret do
    Application.get_env(:example_client, :client_secret)
  end

  defp redirect_uri do
    Application.get_env(:example_client, :redirect_uri, @default_redirect_uri)
  end

  def authorize_url(state \\ nil) do
    params = [
      client_id: client_id(),
      redirect_uri: redirect_uri(),
      response_type: "code",
      scope: "openid profile email",
      state: state
    ]
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Enum.map(fn {key, value} -> {to_string(key), value} end)

    "#{provider_url_browser()}/oauth/authorize?#{URI.encode_query(params)}"
  end

  def exchange_code(code, redirect_uri \\ nil) do
    redirect_uri = redirect_uri || redirect_uri()
    token_endpoint = "#{provider_url_server()}/oauth/token"

    body = %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect_uri,
      client_id: client_id(),
      client_secret: client_secret()
    }

    case Req.post(token_endpoint, json: body) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_userinfo(access_token) do
    userinfo_endpoint = "#{provider_url_server()}/oauth/userinfo"

    headers = [
      {"authorization", "Bearer #{access_token}"}
    ]

    case Req.get(userinfo_endpoint, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def refresh_token(refresh_token) do
    token_endpoint = "#{provider_url_server()}/oauth/token"

    body = %{
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      client_id: client_id(),
      client_secret: client_secret()
    }

    case Req.post(token_endpoint, json: body) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

