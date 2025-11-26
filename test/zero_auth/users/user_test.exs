defmodule ZeroAuth.Users.UserTest do
  use ZeroAuth.DataCase

  alias ZeroAuth.Users.User

  describe "changeset/2" do
    test "validates required fields" do
      changeset = User.changeset(%User{}, %{})

      assert %{
               email: ["can't be blank"],
               password: ["can't be blank"],
               sub: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email format" do
      changeset =
        User.changeset(%User{}, %{
          email: "invalid-email",
          password: "password123",
          sub: "user123"
        })

      assert %{email: ["must be a valid email"]} = errors_on(changeset)
    end

    test "validates password length" do
      changeset =
        User.changeset(%User{}, %{
          email: "test@example.com",
          password: "short",
          sub: "user123"
        })

      assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)
    end

    test "creates valid user" do
      attrs = %{
        email: "test@example.com",
        password: "password123",
        name: "Test User",
        sub: "user123"
      }

      assert {:ok, user} = Repo.insert(User.changeset(%User{}, attrs))
      assert user.email == "test@example.com"
      assert user.name == "Test User"
      assert user.sub == "user123"
      assert user.password_hash != nil
      assert user.password_hash != "password123"
    end

    test "enforces unique email" do
      attrs = %{
        email: "test@example.com",
        password: "password123",
        sub: "user123"
      }

      {:ok, _user} = Repo.insert(User.changeset(%User{}, attrs))

      assert {:error, changeset} = Repo.insert(User.changeset(%User{}, attrs))
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "enforces unique sub" do
      attrs = %{
        email: "test@example.com",
        password: "password123",
        sub: "user123"
      }

      {:ok, _user} = Repo.insert(User.changeset(%User{}, attrs))

      attrs2 = %{
        email: "test2@example.com",
        password: "password123",
        sub: "user123"
      }

      assert {:error, changeset} = Repo.insert(User.changeset(%User{}, attrs2))
      assert %{sub: ["has already been taken"]} = errors_on(changeset)
    end
  end
end


