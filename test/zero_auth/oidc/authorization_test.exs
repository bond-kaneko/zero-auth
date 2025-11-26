defmodule ZeroAuth.OIDC.AuthorizationTest do
  use ZeroAuth.DataCase

  alias ZeroAuth.OIDC
  alias ZeroAuth.OIDC.Authorization
  alias ZeroAuth.OIDC.Client
  alias ZeroAuth.Users.User

  setup do
    {:ok, client} =
      OIDC.create_client(%{
        client_id: "test_client",
        client_secret: "test_secret",
        name: "Test Client",
        redirect_uris: ["http://localhost:3000/callback"]
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

  describe "generate_code/0" do
    test "generates a unique code" do
      code1 = Authorization.generate_code()
      code2 = Authorization.generate_code()

      assert code1 != code2
      assert is_binary(code1)
      assert byte_size(code1) > 0
    end
  end

  describe "create_authorization_code/6" do
    test "creates authorization code with valid params", %{client: client, user: user} do
      assert {:ok, auth_code} =
               Authorization.create_authorization_code(
                 client,
                 user,
                 "http://localhost:3000/callback",
                 ["openid", "profile"],
                 nil,
                 nil
               )

      assert auth_code.code != nil
      assert auth_code.client_id == client.id
      assert auth_code.user_id == user.id
      assert auth_code.redirect_uri == "http://localhost:3000/callback"
      assert auth_code.scopes == ["openid", "profile"]
      assert auth_code.expires_at != nil
    end

    test "creates authorization code with PKCE", %{client: client, user: user} do
      code_challenge = "test_challenge"
      code_challenge_method = "S256"

      assert {:ok, auth_code} =
               Authorization.create_authorization_code(
                 client,
                 user,
                 "http://localhost:3000/callback",
                 ["openid"],
                 code_challenge,
                 code_challenge_method
               )

      assert auth_code.code_challenge == code_challenge
      assert auth_code.code_challenge_method == code_challenge_method
    end
  end

  describe "verify_authorization_code/4" do
    test "verifies valid authorization code", %{client: client, user: user} do
      {:ok, auth_code} =
        Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid"],
          nil,
          nil
        )

      assert {:ok, verified_code} =
               Authorization.verify_authorization_code(
                 auth_code.code,
                 client.id,
                 "http://localhost:3000/callback",
                 nil
               )

      assert verified_code.id == auth_code.id
    end

    test "rejects invalid code" do
      assert {:error, :invalid_code} =
               Authorization.verify_authorization_code(
                 "invalid_code",
                 Ecto.UUID.generate(),
                 "http://localhost:3000/callback",
                 nil
               )
    end

    test "rejects code for wrong client", %{client: client, user: user} do
      {:ok, auth_code} =
        Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid"],
          nil,
          nil
        )

      wrong_client_id = Ecto.UUID.generate()

      assert {:error, :invalid_client} =
               Authorization.verify_authorization_code(
                 auth_code.code,
                 wrong_client_id,
                 "http://localhost:3000/callback",
                 nil
               )
    end

    test "rejects code with wrong redirect_uri", %{client: client, user: user} do
      {:ok, auth_code} =
        Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid"],
          nil,
          nil
        )

      assert {:error, :invalid_redirect_uri} =
               Authorization.verify_authorization_code(
                 auth_code.code,
                 client.id,
                 "http://wrong.com/callback",
                 nil
               )
    end

    test "rejects expired code", %{client: client, user: user} do
      {:ok, auth_code} =
        Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid"],
          nil,
          nil
        )

      # Manually expire the code
      expired_time = DateTime.add(DateTime.utc_now(), -700, :second) |> DateTime.truncate(:second)
      auth_code |> Ecto.Changeset.change(expires_at: expired_time) |> Repo.update!()

      assert {:error, :expired_code} =
               Authorization.verify_authorization_code(
                 auth_code.code,
                 client.id,
                 "http://localhost:3000/callback",
                 nil
               )
    end

    test "verifies PKCE code challenge with S256", %{client: client, user: user} do
      code_verifier = "test_verifier"
      code_challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)

      {:ok, auth_code} =
        Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid"],
          code_challenge,
          "S256"
        )

      assert {:ok, _} =
               Authorization.verify_authorization_code(
                 auth_code.code,
                 client.id,
                 "http://localhost:3000/callback",
                 code_verifier
               )
    end

    test "rejects invalid PKCE code verifier", %{client: client, user: user} do
      code_challenge = "test_challenge"

      {:ok, auth_code} =
        Authorization.create_authorization_code(
          client,
          user,
          "http://localhost:3000/callback",
          ["openid"],
          code_challenge,
          "S256"
        )

      assert {:error, :invalid_code_verifier} =
               Authorization.verify_authorization_code(
                 auth_code.code,
                 client.id,
                 "http://localhost:3000/callback",
                 "wrong_verifier"
               )
    end
  end
end

