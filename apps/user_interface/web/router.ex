defmodule UserInterface.Router do
  use UserInterface.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UserInterface do
    pipe_through :browser # Use the default browser stack

    get "/", MemberController, :welcome

    get "/parent/authenticate", ParentController, :login
    post "/parent/authenticate", ParentController, :authenticate
    get "/parent/signout", ParentController, :signout

    resources "/members", MemberController do
      resources "/devices", DeviceController
      resources "/chores", ChoreController
    end

    # some times captive portal will pass along url path and phoenix will return 404
    # this route will catch that
    get "/*path", MemberController, :welcome
  end

  # Other scopes may use custom stacks.
  # scope "/api", UserInterface do
  #   pipe_through :api
  # end
end
