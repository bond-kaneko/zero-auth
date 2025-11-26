defmodule ZeroAuthWeb.Management.ClientControllerTest do
  use ZeroAuthWeb.ConnCase

  alias ZeroAuth.OIDC
  alias ZeroAuth.OIDC.Client

  describe "GET /management/clients" do
    test "lists all clients", %{conn: conn} do
      {:ok, _client1} =
        OIDC.create_client(%{
          client_id: "client1",
          client_secret: "secret1",
          name: "Client 1"
        })

      {:ok, _client2} =
        OIDC.create_client(%{
          client_id: "client2",
          client_secret: "secret2",
          name: "Client 2"
        })

      conn = get(conn, "/management/clients")

      assert json_response(conn, 200) |> length() == 2

      response = json_response(conn, 200)
      client_ids = Enum.map(response, & &1["client_id"])
      assert "client1" in client_ids
      assert "client2" in client_ids
    end

    test "returns empty list when no clients exist", %{conn: conn} do
      conn = get(conn, "/management/clients")

      assert json_response(conn, 200) == []
    end
  end

  describe "GET /management/clients/:id" do
    test "returns client when found", %{conn: conn} do
      {:ok, client} =
        OIDC.create_client(%{
          client_id: "test_client",
          client_secret: "test_secret",
          name: "Test Client",
          redirect_uris: ["http://localhost:3000/callback"],
          scopes: ["openid", "profile"]
        })

      conn = get(conn, "/management/clients/#{client.id}")

      assert %{
               "id" => _,
               "client_id" => "test_client",
               "name" => "Test Client",
               "redirect_uris" => ["http://localhost:3000/callback"],
               "scopes" => ["openid", "profile"]
             } = json_response(conn, 200)
    end

    test "returns 404 when client not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()

      conn = get(conn, "/management/clients/#{fake_id}")

      assert json_response(conn, 404) == %{"error" => "Client not found"}
    end
  end

  describe "POST /management/clients" do
    test "creates client with valid params", %{conn: conn} do
      params = %{
        "client_id" => "new_client",
        "client_secret" => "new_secret",
        "name" => "New Client",
        "redirect_uris" => ["http://localhost:3000/callback"],
        "scopes" => ["openid", "profile", "email"]
      }

      conn = post(conn, "/management/clients", params)

      assert %{
               "id" => _,
               "client_id" => "new_client",
               "name" => "New Client",
               "client_secret" => "new_secret",
               "redirect_uris" => ["http://localhost:3000/callback"],
               "scopes" => ["openid", "profile", "email"]
             } = json_response(conn, 201)
    end

    test "creates client with default values", %{conn: conn} do
      params = %{
        "client_id" => "default_client",
        "client_secret" => "secret",
        "name" => "Default Client"
      }

      conn = post(conn, "/management/clients", params)

      response = json_response(conn, 201)
      assert response["client_id"] == "default_client"
      assert response["redirect_uris"] == []
      assert response["grant_types"] == ["authorization_code"]
      assert response["scopes"] == ["openid", "profile", "email"]
    end

    test "returns error when client_id is missing", %{conn: conn} do
      params = %{
        "client_secret" => "secret",
        "name" => "Client"
      }

      conn = post(conn, "/management/clients", params)

      assert json_response(conn, 400)["error"] != nil
    end

    test "returns error when name is missing", %{conn: conn} do
      params = %{
        "client_id" => "client",
        "client_secret" => "secret"
      }

      conn = post(conn, "/management/clients", params)

      assert json_response(conn, 400)["error"] != nil
    end

    test "returns error when client_id already exists", %{conn: conn} do
      {:ok, _client} =
        OIDC.create_client(%{
          client_id: "existing_client",
          client_secret: "secret",
          name: "Existing Client"
        })

      params = %{
        "client_id" => "existing_client",
        "client_secret" => "secret2",
        "name" => "Another Client"
      }

      conn = post(conn, "/management/clients", params)

      assert json_response(conn, 400)["error"] != nil
    end
  end

  describe "PUT /management/clients/:id" do
    test "updates client with valid params", %{conn: conn} do
      {:ok, client} =
        OIDC.create_client(%{
          client_id: "update_client",
          client_secret: "secret",
          name: "Original Name"
        })

      params = %{
        "name" => "Updated Name",
        "redirect_uris" => ["http://localhost:4000/callback"]
      }

      conn = put(conn, "/management/clients/#{client.id}", params)

      response = json_response(conn, 200)
      assert response["name"] == "Updated Name"
      assert response["redirect_uris"] == ["http://localhost:4000/callback"]
      assert response["client_id"] == "update_client"
    end

    test "returns 404 when client not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()

      conn = put(conn, "/management/clients/#{fake_id}", %{"name" => "Updated"})

      assert json_response(conn, 404) == %{"error" => "Client not found"}
    end
  end

  describe "PATCH /management/clients/:id" do
    test "updates client with valid params", %{conn: conn} do
      {:ok, client} =
        OIDC.create_client(%{
          client_id: "patch_client",
          client_secret: "secret",
          name: "Original Name"
        })

      params = %{"name" => "Patched Name"}

      conn = patch(conn, "/management/clients/#{client.id}", params)

      response = json_response(conn, 200)
      assert response["name"] == "Patched Name"
    end
  end

  describe "DELETE /management/clients/:id" do
    test "deletes client when found", %{conn: conn} do
      {:ok, client} =
        OIDC.create_client(%{
          client_id: "delete_client",
          client_secret: "secret",
          name: "Delete Client"
        })

      conn = delete(conn, "/management/clients/#{client.id}")

      assert response(conn, 204)
      assert OIDC.get_client(client.id) == nil
    end

    test "returns 404 when client not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()

      conn = delete(conn, "/management/clients/#{fake_id}")

      assert json_response(conn, 404) == %{"error" => "Client not found"}
    end
  end

  describe "PUT /management/clients/:id/secret" do
    test "rotates client secret and returns new secret", %{conn: conn} do
      {:ok, client} =
        OIDC.create_client(%{
          client_id: "rotate_client",
          client_secret: "old_secret",
          name: "Rotate Client"
        })

      old_hash = client.client_secret_hash

      conn = put(conn, "/management/clients/#{client.id}/secret")

      response = json_response(conn, 200)
      assert response["client_secret"] != nil
      assert is_binary(response["client_secret"])

      # Verify the secret was actually updated
      updated_client = OIDC.get_client(client.id)
      assert updated_client.client_secret_hash != old_hash

      # Verify the new secret works
      assert Client.verify_secret(updated_client, response["client_secret"])
    end

    test "returns 404 when client not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()

      conn = put(conn, "/management/clients/#{fake_id}/secret")

      assert json_response(conn, 404) == %{"error" => "Client not found"}
    end
  end
end

