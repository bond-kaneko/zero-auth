defmodule ExampleClientWeb.PageController do
  use ExampleClientWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
