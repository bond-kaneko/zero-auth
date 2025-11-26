defmodule ZeroAuth.Repo.Migrations.CreateAccessTokens do
  use Ecto.Migration

  def change do
    create table(:access_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :string, null: false
      add :refresh_token, :string
      add :client_id, references(:clients, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :scopes, {:array, :string}, default: []
      add :expires_at, :utc_datetime, null: false
      add :refresh_token_expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:access_tokens, :token)
    create unique_index(:access_tokens, :refresh_token)
    create index(:access_tokens, [:client_id])
    create index(:access_tokens, [:user_id])
    create index(:access_tokens, [:expires_at])
  end
end
