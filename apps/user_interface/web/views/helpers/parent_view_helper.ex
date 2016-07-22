defmodule UserInterface.ParentViewHelper do
  def parent?(conn), do: Plug.Conn.get_session(conn, :parent) == "authorized"
end
