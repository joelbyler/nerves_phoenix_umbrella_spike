
defmodule UserInterface.UserHelper do

  def user_ip_address(conn), do: Enum.join(Tuple.to_list(conn.remote_ip),".")

  def user_mac_address(conn) do
    {arp_result, arp_status} = System.cmd("arp", ["-a", user_ip_address(conn)])
    # TODO: throw exception unless arp_status == 0
    List.first(Regex.run(~r/([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}/, arp_result))
  end
end
