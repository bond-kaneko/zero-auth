defmodule ZeroAuthWeb.OAuthControllerTest do
  use ZeroAuthWeb.ConnCase

  alias ZeroAuth.OIDC
  alias ZeroAuth.Users.User
  alias ZeroAuth.Repo

  setup do
    {:ok, client} =
      OIDC.create_client(%{
        client_id: "test_client",
        client_secret: "test_secret",
        name: "Test Client",
        redirect_uris: ["http://localhost:3000/callback"],
        scopes: ["openid", "profile", "email"]
      })

    {:ok, user} =
      Repo.insert(
        User.changeset(%User{}, %{
          email: "test@example.com",
          password: "password123",
          sub: "user123"
        })
      )

    %{client: client, user: user}
  end

  describe "GET /oauth/authorize" do
    test "redirects to login when user is not authenticated", %{conn: conn, client: client} do
      conn =
        get(conn, "/oauth/authorize", %{
          "client_id" => client.client_id,
          "redirect_uri" => "http://localhost:3000/callback",
          "response_type" => "code",
          "scope" => "openid profile"
        })

      assert redirected_to(conn) =~ "/login"
      assert redirected_to(conn) =~ "client_id="
    end

    test "creates authorization code when user is authenticated", %{
      conn: conn,
      client: client,
      user: user
    } do
      # Make a request first to initialize session, then set session and make another request
      conn = get(conn, "/")

      conn =
        conn
        |> recycle()
        |> init_test_session(%{user_id: user.id})
        |> get("/oauth/authorize", %{
          "client_id" => client.client_id,
          "redirect_uri" => "http://localhost:3000/callback",
          "response_type" => "code",
          "scope" => "openid profile"
        })

      assert redirected_to(conn) =~ "http://localhost:3000/callback"
      assert redirected_to(conn) =~ "code="
    end

    test "returns error for invalid client_id", %{conn: conn} do
      conn =
        get(conn, "/oauth/authorize", %{
          "client_id" => "invalid_client",
          "redirect_uri" => "http://localhost:3000/callback"
        })

      assert json_response(conn, 400)
    end

    test "returns error for invalid redirect_uri", %{conn: conn, client: client} do
      conn =
        get(conn, "/oauth/authorize", %{
          "client_id" => client.client_id,
          "redirect_uri" => "http://invalid.com/callback"
        })

      assert json_response(conn, 400)
    end
  end

  describe "POST /oauth/token" do
    test "exchanges authorization code for access token", %{
      conn: conn,
      client: client,
      user: user
    } do
      # Create authorization code
      {:ok, auth_code} =
        ZeroAuth.OIDC.Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid", "profile"],
          nil,
          nil
        )

      # Exchange code for token
      conn =
        post(conn, "/oauth/token", %{
          "grant_type" => "authorization_code",
          "code" => auth_code.code,
          "redirect_uri" => "http://localhost:3000/callback",
          "client_id" => client.client_id,
          "client_secret" => "test_secret"
        })

      response = json_response(conn, 200)
      assert response["access_token"] != nil
      assert response["token_type"] == "Bearer"
      assert response["expires_in"] == 3600
      assert response["refresh_token"] != nil
      assert response["id_token"] != nil
    end

    test "returns error for invalid authorization code", %{conn: conn, client: client} do
      conn =
        post(conn, "/oauth/token", %{
          "grant_type" => "authorization_code",
          "code" => "invalid_code",
          "redirect_uri" => "http://localhost:3000/callback",
          "client_id" => client.client_id,
          "client_secret" => "test_secret"
        })

      assert json_response(conn, 400)
    end

    test "refreshes access token with refresh_token", %{
      conn: conn,
      client: client,
      user: user
    } do
      # Create access token
      {:ok, access_token} =
        ZeroAuth.OIDC.Token.create_access_token(client, user, ["openid"])

      conn =
        post(conn, "/oauth/token", %{
          "grant_type" => "refresh_token",
          "refresh_token" => access_token.refresh_token,
          "client_id" => client.client_id,
          "client_secret" => "test_secret"
        })

      response = json_response(conn, 200)
      assert response["access_token"] != nil
      assert response["token_type"] == "Bearer"
      assert response["expires_in"] == 3600
      assert response["refresh_token"] != nil
    end
  end

  describe "GET /oauth/userinfo" do
    test "returns user info with valid access token", %{
      conn: conn,
      client: client,
      user: user
    } do
      {:ok, access_token} =
        ZeroAuth.OIDC.Token.create_access_token(client, user, ["openid", "profile"])

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token.token}")
        |> get("/oauth/userinfo")

      response = json_response(conn, 200)
      assert response["sub"] == user.sub
      assert response["email"] == user.email
      assert response["name"] == user.name
    end

    test "returns error for invalid access token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid_token")
        |> get("/oauth/userinfo")

      assert json_response(conn, 400)
    end
  end

  describe "GET /.well-known/openid-configuration" do
    test "returns OpenID configuration", %{conn: conn} do
      conn = get(conn, "/.well-known/openid-configuration")

      response = json_response(conn, 200)
      assert response["issuer"] != nil
      assert response["authorization_endpoint"] != nil
      assert response["token_endpoint"] != nil
      assert response["userinfo_endpoint"] != nil
      assert response["response_types_supported"] != nil
      assert response["grant_types_supported"] != nil
    end
  end
end

