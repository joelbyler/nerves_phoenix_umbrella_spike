defmodule UserInterface.NetworkConnectionHelper do
  import System

  def user_ip_address(conn), do: Enum.join(Tuple.to_list(conn.remote_ip),".")

  def user_mac_address(conn) do
    user_ip_address(conn) |> fetch_arp |> default_arp |> parse_arp_response
  end

  defp fetch_arp(ip) do
    {arp_result, arp_status} = cmd("arp", ["-a", ip])
  end

  defp default_arp({_, 1}) do
    {arp_result, arp_status} = cmd("arp", ["-a"])
  end

  defp parse_arp_response({arp_response, 0}) do
    List.first(Regex.run(~r/([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}/, arp_response || []))
  end

  defp parse_arp_response({_, _}) do
    ""
  end

  def ip_tables_list do
    cmd("iptables", ["-t", "mangle", "-L"])
  end

  def clear_ip_tables_for_mac(mac) do
    cmd("iptables", ["-D", "internet", "-t", "mangle", "-m", "--mac-source", mac])
  end

  def clear_restrictions_on_user(conn) do

  end

  # TOOD:
# while( $chain = shell_exec("sudo iptables -t mangle -L | grep ".strtoupper($mac) ) !== NULL ) {
#  exec("sudo iptables -D internet -t mangle -m mac --mac-source ".strtoupper($mac)." -j RETURN");

end
