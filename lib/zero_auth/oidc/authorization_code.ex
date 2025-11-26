defmodule ZeroAuth.OIDC.AuthorizationCode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, ZeroAuth.Types.UUID, autogenerate: true}
  @foreign_key_type ZeroAuth.Types.UUID

  schema "authorization_codes" do
    field :code, :string
    field :redirect_uri, :string
    field :scopes, {:array, :string}
    field :code_challenge, :string
    field :code_challenge_method, :string
    field :expires_at, :utc_datetime
    field :used, :boolean, default: false

    belongs_to :client, ZeroAuth.OIDC.Client
    belongs_to :user, ZeroAuth.Users.User

    timestamps(type: :utc_datetime)
  end

  def changeset(authorization_code, attrs) do
    authorization_code
    |> cast(
      attrs,
      [
        :code,
        :client_id,
        :user_id,
        :redirect_uri,
        :scopes,
        :code_challenge,
        :code_challenge_method,
        :expires_at,
        :used
      ]
    )
    |> validate_required([:code, :client_id, :user_id, :redirect_uri, :expires_at])
    |> unique_constraint(:code)
  end
end
