defmodule ZeroAuth.Repo do
  use Ecto.Repo,
    otp_app: :zero_auth,
    adapter: Ecto.Adapters.Postgres
end
