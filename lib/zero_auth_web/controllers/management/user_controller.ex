defmodule ZeroAuthWeb.Management.UserController do
  use ZeroAuthWeb, :controller

  alias ZeroAuth.Users

  def index(conn, _params) do
    users = Users.list_users()
    json(conn, Enum.map(users, &user_to_json/1))
  end

  def show(conn, %{"id" => id}) do
    case Users.get_user(id) do
      nil ->
        error_response(conn, :not_found, "User not found")

      user ->
        json(conn, user_to_json(user))
    end
  end

  def create(conn, params) do
    case Users.create_user(params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(user_to_json(user))

      {:error, changeset} ->
        error_response(conn, :bad_request, format_changeset_errors(changeset))
    end
  end

  def update(conn, %{"id" => id} = params) do
    case Users.get_user(id) do
      nil ->
        error_response(conn, :not_found, "User not found")

      user ->
        update_params = Map.drop(params, ["id"])

        case Users.update_user(user, update_params) do
          {:ok, updated_user} ->
            json(conn, user_to_json(updated_user))

          {:error, changeset} ->
            error_response(conn, :bad_request, format_changeset_errors(changeset))
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Users.get_user(id) do
      nil ->
        error_response(conn, :not_found, "User not found")

      user ->
        case Users.delete_user(user) do
          {:ok, _} ->
            send_resp(conn, :no_content, "")

          {:error, changeset} ->
            error_response(conn, :bad_request, format_changeset_errors(changeset))
        end
    end
  end

  defp user_to_json(user) do
    %{
      "id" => user.id,
      "email" => user.email,
      "name" => user.name,
      "sub" => user.sub,
      "inserted_at" => DateTime.to_iso8601(user.inserted_at),
      "updated_at" => DateTime.to_iso8601(user.updated_at)
    }
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp error_response(conn, status, message) do
    conn
    |> put_status(status_code(status))
    |> json(%{"error" => message})
  end

  defp status_code(:not_found), do: 404
  defp status_code(:bad_request), do: 400
  defp status_code(_), do: 400
end

