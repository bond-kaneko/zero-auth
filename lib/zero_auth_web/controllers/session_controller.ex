defmodule ZeroAuthWeb.SessionController do
  use ZeroAuthWeb, :controller

  alias Argon2
  alias ZeroAuth.Repo
  alias ZeroAuth.Users.User

  def create(conn, %{"user" => user_params} = params) do
    oauth_params = params["oauth_params"] || %{}
    email = user_params["email"]
    password = user_params["password"]

    case authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> redirect_after_login(oauth_params)

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: "/login?#{URI.encode_query(oauth_params)}")
    end
  end

  # Handle redirect from LiveView with user_id in query params
  def create(conn, %{"user_id" => user_id} = params) do
    case Repo.get(User, user_id) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: "/login")

      user ->
        oauth_params =
          params
          |> Map.drop(["user_id"])
          |> Enum.filter(fn {_key, value} -> value != nil && value != "" end)
          |> Map.new()

        conn
        |> put_session(:user_id, user.id)
        |> redirect_after_login(oauth_params)
    end
  end

  defp authenticate_user(email, password) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  defp redirect_after_login(conn, oauth_params) do
    if oauth_params["client_id"] do
      query_string = URI.encode_query(oauth_params)
      redirect(conn, to: "/oauth/authorize?#{query_string}")
    else
      redirect(conn, to: "/")
    end
  end
end
