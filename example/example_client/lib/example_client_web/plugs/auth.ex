defmodule ExampleClientWeb.Plugs.Auth do
  @moduledoc """
  Plug for managing authentication state
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    access_token = get_session(conn, :access_token)
    refresh_token = get_session(conn, :refresh_token)
    expires_at = get_session(conn, :expires_at)
    userinfo = get_session(conn, :userinfo)

    conn
    |> assign(:authenticated?, access_token != nil)
    |> assign(:access_token, access_token)
    |> assign(:refresh_token, refresh_token)
    |> assign(:expires_at, expires_at)
    |> assign(:userinfo, userinfo)
  end

  def store_tokens(conn, token_response) do
    access_token = token_response["access_token"]
    refresh_token = token_response["refresh_token"]
    expires_in = token_response["expires_in"] || 3600
    expires_at = DateTime.add(DateTime.utc_now(), expires_in, :second)

    conn
    |> put_session(:access_token, access_token)
    |> put_session(:refresh_token, refresh_token)
    |> put_session(:expires_at, DateTime.to_iso8601(expires_at))
  end

  def store_userinfo(conn, userinfo) do
    put_session(conn, :userinfo, userinfo)
  end

  def clear_session(conn) do
    conn
    |> configure_session(drop: true)
  end

  def token_expired?(conn) do
    case get_session(conn, :expires_at) do
      nil -> true
      expires_at_str ->
        case DateTime.from_iso8601(expires_at_str) do
          {:ok, expires_at, _} ->
            DateTime.compare(expires_at, DateTime.utc_now()) == :lt

          _ ->
            true
        end
    end
  end
end

