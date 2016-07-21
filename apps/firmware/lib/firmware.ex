defmodule Firmware do
  use Application

  require System

  alias Nerves.Networking
  alias Porcelain.Result

  def start(_type, _args) do
    import Supervisor.Spec

    unless :os.type == {:unix, :darwin} do     # don't start networking unless we're on nerves
      {:ok, _pid} = Networking.setup :eth0
    end

    migrate
    setup_network

    children = [ ]
    opts = [strategy: :one_for_one, name: Firmware.Supervisor]
    Supervisor.start_link(children, opts)

  end

  defp migrate do
    {:ok, _} = Application.ensure_all_started(:user_interface)

    path = Application.app_dir(:user_interface, "priv/repo/migrations")

    Ecto.Migrator.run(UserInterface.Repo, path, :up, all: true)
  end

  defp setup_network do
    setup_eth0_interface
  end

  defp setup_eth0_interface do
    interface      = :eth0
    static_config  = %{
      mode:      "static",              # use static IP
      dns1:      "8.8.8.8",             # DNS server 1 (Google)
      dns2:      "8.8.4.4",             # DNS server 2 (Google)
      hostname:  "nerves_box",          # hostname
      ip:        "192.168.1.2",         # target's IP address
      mask:      "8",                   # usable bits in subnet
      router:    "192.168.1.1",         # router's IP address
      subnet:    "255.255.255.0"        # subnet mask
    }

    IO.puts "Initializing eth0"
    {:ok, _pid}    = Networking.setup(:interface, static_config)

    IO.puts "Initializing dnsmasq"
    {dnsmasq_output, dnsmasq_return_val} = System.cmd("dnsmasq", [])
    IO.puts "result: #{dnsmasq_output}; #{dnsmasq_return_val}"

    IO.puts "Initializing iptables"
    {iptables_output, iptables_return_val} = System.cmd("init_nat", [])
    IO.puts "result: #{iptables_output}; #{iptables_return_val}"

    IO.puts "Initializing wlan0"
    {ip3_o, ip3_v} = System.cmd("ip", ["addr", "add", "10.0.0.1/24", "dev", "wlan0"])
    IO.puts "result: #{ip2_o}; #{ip2_v}"
    {ip2_o, ip2_v} = System.cmd("ip", ["link", "set", "wlan0", "up"])
    IO.puts "result: #{ip3_o}; #{ip3_v}"

    IO.puts "Initializing system"
    {hostapd_output, hostapd_return_val} = System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"])
    IO.puts "result: #{hostapd_output}; #{hostapd_return_val}"
  end

end
