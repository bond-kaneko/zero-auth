defmodule ZeroAuthWeb.PageController do
  use ZeroAuthWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
