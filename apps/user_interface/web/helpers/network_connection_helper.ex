defmodule UserInterface.NetworkConnectionHelper do
  import System
  alias Porcelain.Result

  def user_ip_address(conn) do
    IO.puts "ip: #{Enum.join(Tuple.to_list(conn.remote_ip),".")}"
    Enum.join(Tuple.to_list(conn.remote_ip),".")
  end

  def user_mac_address(conn) do
    user_ip_address(conn) |> fetch_arp |> default_arp |> parse_arp_response
  end

  def fetch_arp(ip) do
    # try do
    #   {Sh.arp("-a", ip), 0}
    # rescue
    #   x -> {"", 1}
    # end
    {arp_result, arp_status} = os_cmd("arp", ["-a", ip])
    IO.puts "arp -a #{ip} => (#{arp_status}): #{arp_result}"
    {arp_result, arp_status}
  end

  def default_arp({arp_result, 0}) do
    {arp_result, 0}
  end

  def default_arp({_, 1}) do
    # try do
    #   {Sh.arp("-a"), 0}
    # rescue
    #   x -> {"", 1}
    # end

    {arp_result, arp_status} = os_cmd("arp", ["-a"])
    IO.puts "arp -a => (#{arp_status}): #{arp_result}"
    {arp_result, arp_status}
  end

  def parse_arp_response({"", 0}) do
    IO.puts "bad arp:"
    "unkown"
  end

  def parse_arp_response({arp_response, 0}) do
    IO.puts("arp: #{arp_response}")
    List.first(Regex.run(~r/([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}/, arp_response || []))
  end

  def parse_arp_response({arp_response, _}) do
    IO.puts "bad arp: #{arp_response}"
    "error"
  end
  #
  # def ip_tables_list do
  #   os_cmd("iptables", ["-t", "mangle", "-L"])
  # end
  #
  # def clear_ip_tables_for_mac(mac) do
  #   os_cmd("iptables", ["-D", "internet", "-t", "mangle", "-m", "--mac-source", mac])
  # end

  # TOOD:
# while( $chain = shell_exec("sudo iptables -t mangle -L | grep ".strtoupper($mac) ) !== NULL ) {
#  exec("sudo iptables -D internet -t mangle -m mac --mac-source ".strtoupper($mac)." -j RETURN");
  defp os_cmd(command, arguments) do
    cmd(command, arguments)
  end
end
