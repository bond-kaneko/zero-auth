defmodule ZeroAuthWeb.LoginLive do
  use ZeroAuthWeb, :live_view

  alias ZeroAuth.Users.User
  alias ZeroAuth.Repo
  alias Argon2

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: :user), oauth_params: %{})}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, oauth_params: params)}
  end

  def handle_event("login", %{"user" => user_params} = params, socket) do
    oauth_params = params["oauth_params"] || socket.assigns.oauth_params || %{}
    email = user_params["email"]
    password = user_params["password"]

    case Repo.get_by(User, email: email) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid email or password")
         |> assign(form: to_form(user_params, as: :user))}

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          # Redirect to session controller which will set session and redirect
          oauth_query = if oauth_params["client_id"], do: URI.encode_query(oauth_params), else: ""
          redirect_path = if oauth_query != "", do: "/sessions?user_id=#{user.id}&#{oauth_query}", else: "/sessions?user_id=#{user.id}"

          {:noreply, redirect(socket, to: redirect_path)}
        else
          {:noreply,
           socket
           |> put_flash(:error, "Invalid email or password")
           |> assign(form: to_form(user_params, as: :user))}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-sm">
        <h1 class="text-2xl font-bold mb-6">Login</h1>

        <.form for={@form} phx-submit="login" id="login-form">
          <input type="hidden" name="oauth_params[client_id]" value={@oauth_params["client_id"]} />
          <input type="hidden" name="oauth_params[redirect_uri]" value={@oauth_params["redirect_uri"]} />
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

