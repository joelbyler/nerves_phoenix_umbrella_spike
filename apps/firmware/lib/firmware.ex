defmodule Firmware do
  use Application

  require System

  alias Nerves.Networking
  alias Porcelain.Result

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    unless :os.type == {:unix, :darwin} do     # don't start networking unless we're on nerves
      {:ok, _pid} = Networking.setup :eth0
    end

    # Define workers and child supervisors to be supervised
    children = [
      # worker(Firmware.Worker, [arg1, arg2, arg3]),
    ]

    migrate

    IO.puts "Running custom initialization script"
    {finit_output, return_val} = System.cmd("finit", ["start"])
    IO.puts "initialization result: #{finit_output}; #{return_val}"

    # IO.puts "Trying again with porcelain"
    # %Result{out: porcelain_output, status: porcelain_status} = Porcelain.shell("finit start")
    # IO.puts "porcelain result: #{porcelain_output}; #{porcelain_status}"

    # IO.puts "Trying to start hostapd directly"
    # {hostapd_output, hostapd_return_val} = System.cmd("hostapd", ["-d", "/etc/hostapd/hostapd.conf"])
    # IO.puts "initialization result: #{hostapd_output}; #{hostapd_return_val}"

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options

    opts = [strategy: :one_for_one, name: Firmware.Supervisor]
    Supervisor.start_link(children, opts)

  end

  # TODO: migrate db
  defp migrate do
    {:ok, _} = Application.ensure_all_started(:user_interface)

    path = Application.app_dir(:user_interface, "priv/repo/migrations")

    Ecto.Migrator.run(UserInterface.Repo, path, :up, all: true)
  end

end
