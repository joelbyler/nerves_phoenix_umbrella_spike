require IEx
defmodule UserInterface.ParentController do
  use UserInterface.Web, :controller

  def login(conn, _params) do
    render conn, "login.html"
  end

  def authenticate(conn, params) do
    if params["password"] == "abc" do
      render(conn, "index.html")
    else
      render conn, "login.html"
    end
  end
end
