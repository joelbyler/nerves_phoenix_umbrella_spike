defmodule UserInterface.ErrorView do
  use UserInterface.Web, :view

  def render("404.html", _assigns) do
    # DO THIS FOR CAPTIVE PORTAL
    render("/", %{})
  end

  def render("500.html", _assigns) do
    render("/", %{})
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
