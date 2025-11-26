defmodule ZeroAuthWeb.LoginLive do
  use ZeroAuthWeb, :live_view

  alias Argon2
  alias ZeroAuth.Repo
  alias ZeroAuth.Users.User

  def mount(params, _session, socket) do
    # Extract oauth_params from query params (client_id, redirect_uri, scope, state)
    oauth_params = %{
      "client_id" => params["client_id"] || "",
      "redirect_uri" => params["redirect_uri"] || "",
      "scope" => params["scope"] || "",
      "state" => params["state"] || ""
    }
    {:ok, assign(socket, form: to_form(%{}, as: :user), oauth_params: oauth_params)}
  end

  def handle_params(params, _uri, socket) do
    # Extract oauth_params from query params (client_id, redirect_uri, scope, state)
    oauth_params = %{
      "client_id" => params["client_id"] || "",
      "redirect_uri" => params["redirect_uri"] || "",
      "scope" => params["scope"] || "",
      "state" => params["state"] || ""
    }
    {:noreply, assign(socket, oauth_params: oauth_params)}
  end

  def handle_event("login", params, socket) do
    # Extract user_params from params - handle both nested and flat structures
    user_params = params["user"] || %{}
    oauth_params = params["oauth_params"] || socket.assigns.oauth_params || %{}
    email = user_params["email"] || params["email"]
    password = user_params["password"] || params["password"]

    if email && password do
      case authenticate_user(email, password) do
        {:ok, user} ->
          redirect_path = build_redirect_path(user.id, oauth_params)
          {:noreply, redirect(socket, to: redirect_path)}

        {:error, :invalid_credentials} ->
          {:noreply,
           socket
           |> put_flash(:error, "Invalid email or password")
           |> assign(form: to_form(user_params, as: :user))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Email and password are required")
       |> assign(form: to_form(user_params, as: :user))}
    end
  end

  defp authenticate_user(email, password) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  defp build_redirect_path(user_id, oauth_params) do
    base_path = "/sessions?user_id=#{user_id}"

    if oauth_params["client_id"] && oauth_params["client_id"] != "" do
      oauth_query = URI.encode_query(oauth_params)
      "#{base_path}&#{oauth_query}"
    else
      base_path
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-sm">
        <h1 class="text-2xl font-bold mb-6">Login</h1>

        <.form for={@form} phx-submit="login" id="login-form">
          <input type="hidden" name="oauth_params[client_id]" value={@oauth_params["client_id"]} />
          <input
            type="hidden"
            name="oauth_params[redirect_uri]"
            value={@oauth_params["redirect_uri"]}
          />
          <input type="hidden" name="oauth_params[scope]" value={@oauth_params["scope"]} />
          <input type="hidden" name="oauth_params[state]" value={@oauth_params["state"]} />
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <div class="mt-4">
            <.button type="submit" class="w-full">Login</.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end
end
