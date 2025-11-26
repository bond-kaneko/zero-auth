defmodule ZeroAuthWeb.Router do
  use ZeroAuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ZeroAuthWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZeroAuthWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/login", LoginLive, :index
    post "/sessions", SessionController, :create
    get "/sessions", SessionController, :create
  end

  scope "/oauth", ZeroAuthWeb do
    pipe_through :browser

    get "/authorize", OAuthController, :authorize
    post "/authorize", OAuthController, :authorize
  end

  scope "/oauth", ZeroAuthWeb do
    pipe_through :api

    post "/token", OAuthController, :token
    get "/userinfo", OAuthController, :userinfo
  end

  scope "/.well-known", ZeroAuthWeb do
    pipe_through :api

    get "/openid-configuration", OAuthController, :openid_configuration
  end

  scope "/management", ZeroAuthWeb.Management do
    pipe_through :api

    get "/clients", ClientController, :index
    get "/clients/:id", ClientController, :show
    post "/clients", ClientController, :create
    put "/clients/:id", ClientController, :update
    patch "/clients/:id", ClientController, :update
    delete "/clients/:id", ClientController, :delete
    put "/clients/:id/secret", ClientController, :update_secret
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZeroAuthWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:zero_auth, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ZeroAuthWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
