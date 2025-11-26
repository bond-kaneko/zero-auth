defmodule ZeroAuthWeb.Management.ClientController do
  use ZeroAuthWeb, :controller

  alias ZeroAuth.OIDC

  def index(conn, _params) do
    clients = OIDC.list_clients()
    json(conn, Enum.map(clients, &client_to_json/1))
  end

  def show(conn, %{"id" => id}) do
    case OIDC.get_client(id) do
      nil ->
        error_response(conn, :not_found, "Client not found")

      client ->
        json(conn, client_to_json(client))
    end
  end

  def create(conn, params) do
    case OIDC.create_client(params) do
      {:ok, client} ->
        # Extract client_secret from changeset if available
        client_secret = extract_client_secret_from_changeset(client, params)

        conn
        |> put_status(:created)
        |> json(client_to_json(client, client_secret))

      {:error, changeset} ->
        error_response(conn, :bad_request, format_changeset_errors(changeset))
    end
  end

  def update(conn, %{"id" => id} = params) do
    case OIDC.get_client(id) do
      nil ->
        error_response(conn, :not_found, "Client not found")

      client ->
        update_params = Map.drop(params, ["id"])

        case OIDC.update_client(client, update_params) do
          {:ok, updated_client} ->
            json(conn, client_to_json(updated_client))

          {:error, changeset} ->
            error_response(conn, :bad_request, format_changeset_errors(changeset))
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case OIDC.get_client(id) do
      nil ->
        error_response(conn, :not_found, "Client not found")

      client ->
        case OIDC.delete_client(client) do
          {:ok, _} ->
            send_resp(conn, :no_content, "")

          {:error, changeset} ->
            error_response(conn, :bad_request, format_changeset_errors(changeset))
        end
    end
  end

  def update_secret(conn, %{"id" => id}) do
    case OIDC.get_client(id) do
      nil ->
        error_response(conn, :not_found, "Client not found")

      client ->
        case OIDC.rotate_client_secret(client) do
          {:ok, updated_client, new_secret} ->
            json(conn, client_to_json(updated_client, new_secret))

          {:error, changeset} ->
            error_response(conn, :bad_request, format_changeset_errors(changeset))
        end
    end
  end

  defp client_to_json(client, client_secret \\ nil) do
    base_json = %{
      "id" => client.id,
      "client_id" => client.client_id,
      "name" => client.name,
      "redirect_uris" => client.redirect_uris || [],
      "grant_types" => client.grant_types || [],
      "scopes" => client.scopes || [],
      "inserted_at" => DateTime.to_iso8601(client.inserted_at),
      "updated_at" => DateTime.to_iso8601(client.updated_at)
    }

    if client_secret do
      Map.put(base_json, "client_secret", client_secret)
    else
      base_json
    end
  end

  defp extract_client_secret_from_changeset(_client, params) do
    params["client_secret"]
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
