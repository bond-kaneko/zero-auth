defmodule ZeroAuth.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :client_id, :string, null: false
      add :client_secret_hash, :string, null: false
      add :name, :string, null: false
      add :redirect_uris, {:array, :string}, default: []
      add :grant_types, {:array, :string}, default: ["authorization_code"]
      add :scopes, {:array, :string}, default: ["openid", "profile", "email"]

      timestamps(type: :utc_datetime)
    end

    create unique_index(:clients, :client_id)
  end
end
