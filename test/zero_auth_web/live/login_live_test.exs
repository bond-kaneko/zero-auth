defmodule ZeroAuthWeb.LoginLiveTest do
  use ZeroAuthWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ZeroAuth.Repo
  alias ZeroAuth.Users.User

  setup do
    {:ok, user} =
      Repo.insert(
        User.changeset(%User{}, %{
          email: "test@example.com",
          password: "password123",
          sub: "user123",
          name: "Test User"
        })
      )

    %{user: user}
  end

  describe "LoginLive" do
    test "renders login form", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/login")

      html = render(view)
      assert html =~ "login-form"
      assert html =~ "user[email]"
      assert html =~ "user[password]"
    end

    test "displays error for invalid credentials", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/login")

      view
      |> form("#login-form", user: %{email: "wrong@example.com", password: "wrong"})
      |> render_submit()

      assert render(view) =~ "Invalid"
    end

    test "redirects after successful login", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/login")

      assert {:error, {:redirect, %{to: redirect_path}}} =
               view
               |> form("#login-form", user: %{email: user.email, password: "password123"})
               |> render_submit()

      assert redirect_path =~ "/sessions"
      assert redirect_path =~ "user_id="
    end

    test "preserves oauth params in form", %{conn: conn} do
      {:ok, view, _html} =
        live(conn, "/login?client_id=test&redirect_uri=http://localhost:3000/callback")

      html = render(view)
      assert html =~ ~s/name="oauth_params[client_id]"/
      assert html =~ ~s/value="test"/
    end
  end
end
