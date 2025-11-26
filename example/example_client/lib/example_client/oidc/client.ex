defmodule ExampleClient.OIDC.Client do
  @moduledoc """
  OIDC client for authenticating with zero-auth provider
  """

  @provider_url Application.compile_env(:example_client, :provider_url, "http://localhost:4000")
  @client_id Application.compile_env(:example_client, :client_id)
  @client_secret Application.compile_env(:example_client, :client_secret)
  @redirect_uri Application.compile_env(:example_client, :redirect_uri, "http://localhost:4001/auth/callback")

  def authorize_url(state \\ nil) do
    params = [
      client_id: @client_id,
      redirect_uri: @redirect_uri,
      response_type: "code",
      scope: "openid profile email",
      state: state
    ]
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Enum.map(fn {key, value} -> {to_string(key), value} end)

    "#{@provider_url}/oauth/authorize?#{URI.encode_query(params)}"
  end

  def exchange_code(code, redirect_uri \\ @redirect_uri) do
    token_endpoint = "#{@provider_url}/oauth/token"

    body = %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect_uri,
      client_id: @client_id,
      client_secret: @client_secret
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
    userinfo_endpoint = "#{@provider_url}/oauth/userinfo"

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
    token_endpoint = "#{@provider_url}/oauth/token"

    body = %{
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      client_id: @client_id,
      client_secret: @client_secret
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

