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

    # TODO: build wrappers for all of these system calls

    IO.puts "Initializing eth0"
    Networking.setup(:eth0)

    IO.puts "Setting sysctl"
    System.cmd("sysctl", ["-w", "net.ipv4.ip_forward=1"])

    IO.puts "Initializing wlan0"
    System.cmd("ip", ["link", "set", "wlan0", "up"])
    System.cmd("ip", ["addr", "add", "10.0.0.1/24", "dev", "wlan0"])

    IO.puts "Initializing iptables"
    Firmware.IpTables.clear
    Firmware.IpTables.start_post_routing(:eth0)
    Firmware.IpTables.forward(:eth0, :wlan0)
    # System.cmd("iptables", ["--flush"])
    # System.cmd("iptables", ["--table", "nat", "--flush"])
    # System.cmd("iptables", ["--delete-chain"])
    # System.cmd("iptables", ["--table", "nat", "--delete-chain"])
    # System.cmd("iptables", ["--table", "nat", "--append", "POSTROUTING"])
    # System.cmd("iptables", ["-t", "nat", "-A", "POSTROUTING", "-o", "eth0", "-j", "MASQUERADE"])
    # System.cmd("iptables", ["-A", "FORWARD", "-i", "eth0", "-o", "wlan0", "-m", "state", "--state", "RELATED,ESTABLISHED", "-j", "ACCEPT"])
    # System.cmd("iptables", ["-A", "FORWARD", "-i", "wlan0", "-o", "eth0", "-j", "ACCEPT"])


    IO.puts "Initializing dnsmasq"
    System.cmd("dnsmasq", ["--dhcp-lease", "/root/dnsmasq.lease"])

    IO.puts "Initializing system"
    System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"])
  end

  def mac_for_ip(ip) do
    {arp_result, arp_status} = System.cmd("arp", ["-a", ip])
    # TODO: throw exception unless arp_status == 0
    List.first(Regex.run(~r/([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}/, arp_result))
  end

end
