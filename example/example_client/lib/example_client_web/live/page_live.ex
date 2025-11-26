defmodule ExampleClientWeb.PageLive do
  use ExampleClientWeb, :live_view

  def mount(_params, session, socket) do
    access_token = session["access_token"]
    userinfo = session["userinfo"]

    socket =
      socket
      |> assign(:authenticated?, access_token != nil)
      |> assign(:access_token, access_token)
      |> assign(:userinfo, userinfo)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-4xl">
        <h1 class="text-3xl font-bold mb-6">OIDC Client Example</h1>

        <%= if @authenticated? do %>
          <div class="bg-green-50 border border-green-200 rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4 text-green-800">Authenticated</h2>

            <%= if @userinfo do %>
              <div class="space-y-2">
                <p><strong>Subject:</strong> {@userinfo["sub"]}</p>
                <p><strong>Email:</strong> {@userinfo["email"]}</p>
                <%= if @userinfo["name"] do %>
                  <p><strong>Name:</strong> {@userinfo["name"]}</p>
                <% end %>
              </div>
            <% end %>

            <div class="mt-4">
              <.link
                navigate={~p"/auth/logout"}
                class="inline-block bg-red-500 hover:bg-red-600 text-white font-semibold py-2 px-4 rounded"
              >
                Logout
              </.link>
            </div>
          </div>
        <% else %>
          <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4 text-yellow-800">Not Authenticated</h2>
            <p class="mb-4">Click the button below to authenticate with zero-auth provider.</p>

            <.link
              navigate={~p"/auth/authorize"}
              class="inline-block bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded"
            >
              Login with zero-auth
            </.link>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end

