require IEx
defmodule UserInterface.ParentController do
  use UserInterface.Web, :controller
  import UserInterface.NetworkConnectionHelper

  def login(conn, _params) do
    render conn, "login.html"
  end

  def authenticate(conn, params) do
    # TODO: this shouldn't be hard coded
    if params["password"] == "trustme" do
      conn = put_session(conn, :parent, "authorized")
      render(conn, "index.html")
    else
      render conn, "login.html"
    end
  end

  def signout(conn, _params) do
    conn = configure_session(conn, drop: true)
    redirect(conn, to: "/")
  end

  def unmark(conn, _params) do
    unmark_result = Task.async(fn -> unmark(conn) end)

    redirect(conn, to: "/", unmark_result: Task.await(unmark_result))
  end
end
