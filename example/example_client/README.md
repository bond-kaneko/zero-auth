# Example OIDC Client

This is an example OIDC client application that authenticates with the zero-auth provider using the authorization code flow.

## Prerequisites

- zero-auth provider running on `http://localhost:4000`
- A client registered in zero-auth with the following configuration:
  - `client_id`: `example_client` (or set via `OIDC_CLIENT_ID` environment variable)
  - `client_secret`: `example_secret` (or set via `OIDC_CLIENT_SECRET` environment variable)
  - `redirect_uri`: `http://localhost:4001/auth/callback`

## Setup

### 1. Register a client in zero-auth

First, register a client in the zero-auth provider:

```bash
curl -X POST http://localhost:4000/management/clients \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "example_client",
    "client_secret": "example_secret",
    "name": "Example Client",
    "redirect_uris": ["http://localhost:4001/auth/callback"],
    "scopes": ["openid", "profile", "email"]
  }'
```

Save the `client_secret` from the response - you'll need it for configuration.

### 2. Configure the client

Set environment variables or update `config/config.exs`:

```bash
export OIDC_CLIENT_ID=example_client
export OIDC_CLIENT_SECRET=your_client_secret_here
```

Or edit `config/config.exs` directly:

```elixir
config :example_client,
  client_id: "example_client",
  client_secret: "your_client_secret_here",
  redirect_uri: "http://localhost:4001/auth/callback",
  provider_url: "http://localhost:4000"
```

### 3. Install dependencies

```bash
cd example/example_client
mix deps.get
```

### 4. Start the server

```bash
mix phx.server
```

Or inside IEx:

```bash
iex -S mix phx.server
```

The application will be available at [`http://localhost:4001`](http://localhost:4001).

## Usage

1. Visit `http://localhost:4001` in your browser
2. Click "Login with zero-auth" button
3. You will be redirected to zero-auth login page
4. After successful login, you will be redirected back to the client
5. Your user information will be displayed on the page

## Features

- OIDC Authorization Code Flow
- Token exchange and storage
- User info retrieval
- Session management
- Logout functionality

## Project Structure

- `lib/example_client/oidc/client.ex` - OIDC client module for interacting with the provider
- `lib/example_client_web/controllers/auth_controller.ex` - Authentication controller
- `lib/example_client_web/live/page_live.ex` - Main page LiveView
- `lib/example_client_web/plugs/auth.ex` - Authentication plug for session management

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
