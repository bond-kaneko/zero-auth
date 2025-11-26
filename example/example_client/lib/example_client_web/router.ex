defmodule ExampleClientWeb.Router do
  use ExampleClientWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExampleClientWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ExampleClientWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleClientWeb do
    pipe_through :browser

    live "/", PageLive, :index
    get "/auth/authorize", AuthController, :authorize
    get "/auth/callback", AuthController, :callback
    get "/auth/logout", AuthController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExampleClientWeb do
  #   pipe_through :api
  # end
end
