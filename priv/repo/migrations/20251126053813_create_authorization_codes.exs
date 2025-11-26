defmodule ZeroAuth.Repo.Migrations.CreateAuthorizationCodes do
  use Ecto.Migration

  def change do
    create table(:authorization_codes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string, null: false
      add :client_id, references(:clients, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :redirect_uri, :string, null: false
      add :scopes, {:array, :string}, default: []
      add :code_challenge, :string
      add :code_challenge_method, :string
      add :expires_at, :utc_datetime, null: false
      add :used, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:authorization_codes, :code)
    create index(:authorization_codes, [:client_id])
    create index(:authorization_codes, [:user_id])
    create index(:authorization_codes, [:expires_at])
  end
end
