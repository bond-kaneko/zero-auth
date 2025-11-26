defmodule ZeroAuth.OIDC.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2

  @primary_key {:id, ZeroAuth.Types.UUID, autogenerate: true}
  @foreign_key_type ZeroAuth.Types.UUID

  schema "clients" do
    field :client_id, :string
    field :client_secret_hash, :string
    field :client_secret, :string, virtual: true
    field :name, :string
    field :redirect_uris, {:array, :string}
    field :grant_types, {:array, :string}
    field :scopes, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  def changeset(client, attrs) do
    client
    |> cast(attrs, [:client_id, :client_secret, :name, :redirect_uris, :grant_types, :scopes])
    |> validate_required([:client_id, :name])
    |> unique_constraint(:client_id)
    |> put_client_secret_hash()
    |> set_defaults()
  end

  defp put_client_secret_hash(%Ecto.Changeset{valid?: true, changes: %{client_secret: secret}} = changeset) do
    change(changeset, client_secret_hash: Argon2.hash_pwd_salt(secret))
  end

  defp put_client_secret_hash(changeset), do: changeset

  defp set_defaults(changeset) do
    changeset
    |> put_change(:redirect_uris, Ecto.Changeset.get_change(changeset, :redirect_uris) || [])
    |> put_change(:grant_types, Ecto.Changeset.get_change(changeset, :grant_types) || ["authorization_code"])
    |> put_change(:scopes, Ecto.Changeset.get_change(changeset, :scopes) || ["openid", "profile", "email"])
  end

  def verify_secret(%__MODULE__{client_secret_hash: hash}, secret) when is_binary(secret) do
    Argon2.verify_pass(secret, hash)
  end

  def verify_secret(_, _), do: false

  def generate_client_secret do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end
end

