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

  # <?php
  # // get the user IP address from the query string
  # $ip = $_GET['ip'];
  #
  # // this is the path to the arp command used to get user MAC address
  # // from it's IP address in linux environment.
  # $arp = "/usr/sbin/arp";
  #
  # // execute the arp command to get their mac address
  # $mac = shell_exec("sudo $arp -an " . $ip);
  # preg_match('/..:..:..:..:..:../',$mac , $matches);
  # $mac = @$matches[0];
  #
  # // if MAC Address couldn't be identified.
  # if( $mac === NULL) { echo "Error: Can't retrieve user's MAC address."; exit; }
  # // Delete it from iptables bypassing rules entry.
  # while( $chain = shell_exec("sudo iptables -t mangle -L | grep ".strtoupper($mac) ) !== NULL ) {
  #   exec("sudo iptables -D internet -t mangle -m mac --mac-source ".strtoupper($mac)." -j RETURN");
  # }
  #
  # // Why in this while loop?
  # // Users may have been logged through the portal several times.
  # // So they may have chances to have multiple bypassing rules entry in iptables firewall.
  # // remove their connection track.
  # exec("sudo rmtrack " . $ip);
  # // remove their connection track
  # if any echo "Kickin' successful.";
  #
  # ?>
  #
  # /usr/sbin/conntrack -L \
  #     |grep $1 \
  #     |grep ESTAB \
  #     |grep 'dport=80' \
  #     |awk \
  #         "{ system(\"conntrack -D --orig-src $1 --orig-dst \" \
  #             substr(\$6,5) \" -p tcp --orig-port-src \" substr(\$7,7) \" \
  #             --orig-port-dst 80\"); }"
  #
  #
  #

  def unmark(conn) do
    {ip_result, ip_status} = user_ip_address(conn) |> unmark_ip
    IO.puts "unmark_ip: #{ip_result}; #{ip_status}"
    {mac_result, mac_status} = user_mac_address(conn) |> unmark_mac
    IO.puts "unmark_mac: #{mac_result}; #{mac_status}"
    [{ip_result, ip_status}, {mac_result, mac_status}]
  end

  def unmark_ip(ip) do
    os_cmd("conntrack", ["-D", "--orig-src", ip])
  end

  def unmark_mac(mac) do
    os_cmd("iptables", ["-t", "mangle", "-A", "wlan0_Outgoing", "-m", "mac", "--mac-source", mac, "-j", "MARK", "--set-mark", "2"])
  end

  # System.cmd("conntrack", ["--orig-src", "192.168.24.23"])
  #
  # NOTE, uppercase
  # iptables -t mangle -I internet 1 -m mac --mac-source USER-MAC-ADDRESS-HERE -j RETURN

  # TOOD:a
# while( $chain = shell_exec("sudo iptables -t mangle -L | grep ".strtoupper($mac) ) !== NULL ) {
#  exec("sudo iptables -D internet -t mangle -m mac --mac-source ".strtoupper($mac)." -j RETURN");
  defp os_cmd(command, arguments) do
    cmd(command, arguments)
  end
end
