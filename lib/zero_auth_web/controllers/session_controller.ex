defmodule ZeroAuthWeb.SessionController do
  use ZeroAuthWeb, :controller

  alias ZeroAuth.Users.User
  alias ZeroAuth.Repo
  alias Argon2

  def create(conn, %{"user" => user_params} = params) do
    oauth_params = params["oauth_params"] || %{}
    email = user_params["email"]
    password = user_params["password"]

    case Repo.get_by(User, email: email) do
      nil ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: "/login?#{URI.encode_query(oauth_params)}")

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          # Redirect to authorization if oauth params exist
          if oauth_params["client_id"] do
            query_string = URI.encode_query(oauth_params)
            conn
            |> put_session(:user_id, user.id)
            |> redirect(to: "/oauth/authorize?#{query_string}")
          else
            conn
            |> put_session(:user_id, user.id)
            |> redirect(to: "/")
          end
        else
          conn
          |> put_flash(:error, "Invalid email or password")
          |> redirect(to: "/login?#{URI.encode_query(oauth_params)}")
        end
    end
  end

  # Handle redirect from LiveView with user_id in query params
  def create(conn, %{"user_id" => user_id} = params) do
    user = Repo.get(User, user_id)

    if user do
      oauth_params = Map.drop(params, ["user_id"])

      if oauth_params["client_id"] do
        query_string = URI.encode_query(oauth_params)
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: "/oauth/authorize?#{query_string}")
      else
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: "/login")
    end
  end
end

