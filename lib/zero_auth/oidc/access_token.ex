defmodule ZeroAuth.OIDC.AccessToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, ZeroAuth.Types.UUID, autogenerate: true}
  @foreign_key_type ZeroAuth.Types.UUID

  schema "access_tokens" do
    field :token, :string
    field :refresh_token, :string
    field :scopes, {:array, :string}
    field :expires_at, :utc_datetime
    field :refresh_token_expires_at, :utc_datetime

    belongs_to :client, ZeroAuth.OIDC.Client
    belongs_to :user, ZeroAuth.Users.User

    timestamps(type: :utc_datetime)
  end

  def changeset(access_token, attrs) do
    access_token
    |> cast(attrs, [
      :token,
      :refresh_token,
      :client_id,
      :user_id,
      :scopes,
      :expires_at,
      :refresh_token_expires_at
    ])
    |> validate_required([:token, :client_id, :expires_at])
    |> unique_constraint(:token)
    |> unique_constraint(:refresh_token)
  end
end
