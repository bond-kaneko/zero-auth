ExUnit.start()

# Start the Repo for tests
Application.ensure_all_started(:zero_auth)
Ecto.Adapters.SQL.Sandbox.mode(ZeroAuth.Repo, :manual)
