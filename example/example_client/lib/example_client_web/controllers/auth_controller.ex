defmodule ExampleClientWeb.AuthController do
  use ExampleClientWeb, :controller

  alias ExampleClient.OIDC.Client
  alias ExampleClientWeb.Plugs.Auth

  def authorize(conn, _params) do
    state = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    authorize_url = Client.authorize_url(state)

    conn
    |> put_session(:oauth_state, state)
    |> redirect(external: authorize_url)
  end

  def callback(conn, params) do
    code = params["code"]
    state = params["state"]
    stored_state = get_session(conn, :oauth_state)

    cond do
      code == nil ->
        conn
        |> put_flash(:error, "Authorization code not provided")
        |> redirect(to: "/")

      state != stored_state ->
        conn
        |> put_flash(:error, "Invalid state parameter")
        |> redirect(to: "/")

      true ->
        handle_token_exchange(conn, code)
    end
  end

  def logout(conn, _params) do
    conn
    |> Auth.clear_session()
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: "/")
  end

  defp handle_token_exchange(conn, code) do
    case Client.exchange_code(code) do
      {:ok, token_response} ->
        access_token = token_response["access_token"]

        conn
        |> delete_session(:oauth_state)
        |> Auth.store_tokens(token_response)
        |> fetch_userinfo(access_token)

      {:error, reason} ->
        conn
        |> put_flash(:error, "Failed to exchange code: #{inspect(reason)}")
        |> redirect(to: "/")
    end
  end

  defp fetch_userinfo(conn, access_token) do
    case Client.get_userinfo(access_token) do
      {:ok, userinfo} ->
        conn
        |> Auth.store_userinfo(userinfo)
        |> put_flash(:info, "Logged in successfully")
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Failed to fetch user info: #{inspect(reason)}")
        |> redirect(to: "/")
    end
  end
end

