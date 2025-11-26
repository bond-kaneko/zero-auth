defmodule ZeroAuthWeb.Management.UserControllerTest do
  use ZeroAuthWeb.ConnCase

  alias ZeroAuth.Users

  @create_attrs %{
    "email" => "test@example.com",
    "password" => "password123",
    "sub" => "user123",
    "name" => "Test User"
  }
  @update_attrs %{
    "email" => "updated@example.com",
    "name" => "Updated User"
  }
  @invalid_attrs %{"email" => nil, "password" => nil, "sub" => nil}

  describe "index" do
    test "lists all users", %{conn: conn} do
      user = insert_user()
      conn = get(conn, "/management/users")
      response = json_response(conn, 200)
      assert is_list(response)
      assert Enum.any?(response, &(&1["id"] == user.id))
    end
  end

  describe "show" do
    test "shows user", %{conn: conn} do
      user = insert_user()
      conn = get(conn, "/management/users/#{user.id}")
      assert json_response(conn, 200)["id"] == user.id
    end

    test "returns 404 when user not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()
      conn = get(conn, "/management/users/#{fake_id}")
      assert json_response(conn, 404) == %{"error" => "User not found"}
    end
  end

  describe "create" do
    test "creates user with valid data", %{conn: conn} do
      conn = post(conn, "/management/users", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, "/management/users/#{id}")
      response = json_response(conn, 200)
      assert response["email"] == @create_attrs["email"]
      assert response["name"] == @create_attrs["name"]
      assert response["sub"] == @create_attrs["sub"]
    end

    test "returns error with invalid data", %{conn: conn} do
      conn = post(conn, "/management/users", @invalid_attrs)
      assert json_response(conn, 400)["error"] != %{}
    end

    test "returns error with duplicate email", %{conn: conn} do
      _user = insert_user(@create_attrs)
      conn = post(conn, "/management/users", @create_attrs)
      assert json_response(conn, 400)["error"] != %{}
    end

    test "returns error with duplicate sub", %{conn: conn} do
      _user = insert_user(@create_attrs)
      duplicate_attrs = Map.put(@create_attrs, "email", "different@example.com")
      conn = post(conn, "/management/users", duplicate_attrs)
      assert json_response(conn, 400)["error"] != %{}
    end

    test "returns error with short password", %{conn: conn} do
      short_password_attrs = Map.put(@create_attrs, "password", "short")
      conn = post(conn, "/management/users", short_password_attrs)
      assert json_response(conn, 400)["error"] != %{}
    end
  end

  describe "update" do
    test "updates user with valid data", %{conn: conn} do
      user = insert_user()
      conn = put(conn, "/management/users/#{user.id}", @update_attrs)
      response = json_response(conn, 200)
      assert response["id"] == user.id

      conn = get(conn, "/management/users/#{user.id}")
      response = json_response(conn, 200)
      assert response["email"] == @update_attrs["email"]
      assert response["name"] == @update_attrs["name"]
    end

    test "returns error with invalid data", %{conn: conn} do
      user = insert_user()
      conn = put(conn, "/management/users/#{user.id}", @invalid_attrs)
      assert json_response(conn, 400)["error"] != %{}
    end

    test "returns 404 when user not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()
      conn = put(conn, "/management/users/#{fake_id}", @update_attrs)
      assert json_response(conn, 404) == %{"error" => "User not found"}
    end
  end

  describe "delete" do
    test "deletes user", %{conn: conn} do
      user = insert_user()
      conn = delete(conn, "/management/users/#{user.id}")
      assert response(conn, 204)

      conn = get(conn, "/management/users/#{user.id}")
      assert json_response(conn, 404) == %{"error" => "User not found"}
    end

    test "returns 404 when user not found", %{conn: conn} do
      fake_id = Ecto.UUID.generate()
      conn = delete(conn, "/management/users/#{fake_id}")
      assert json_response(conn, 404) == %{"error" => "User not found"}
    end
  end

  defp insert_user(attrs \\ %{}) do
    default_attrs = %{
      "email" => "test@example.com",
      "password" => "password123",
      "sub" => Ecto.UUID.generate(),
      "name" => "Test User"
    }

    attrs = Map.merge(default_attrs, attrs)

    {:ok, user} = Users.create_user(attrs)
    user
  end
end
