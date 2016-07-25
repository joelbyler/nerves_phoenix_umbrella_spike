defmodule IpTables do

  def clear do
    flush
    delete_chain
  end

  defp flush do
    System.cmd("iptables", ["--flush"])
    System.cmd("iptables", ["--t", "nat", "--flush"])
  end

  defp delete_chain do
    System.cmd("iptables", ["--delete-chain"])
    System.cmd("iptables", ["--t", "nat", "--delete-chain"])
  end

  def start_post_routing(interface) do # interface = eth0
    System.cmd("iptables", ["-t", "nat", "-A", "POSTROUTING"])
    System.cmd("iptables", ["-t", "nat", "-A", "POSTROUTING", "-o", interface, "-j", "MASQUERADE"])
  end

  def forward(from, to) do # to = "wlan0, from = "eth0"
    System.cmd("iptables", ["-A", "FORWARD", "-i", from, "-o", to, "-m", "state", "--state", "RELATED,ESTABLISHED", "-j", "ACCEPT"])
    System.cmd("iptables", ["-A", "FORWARD", "-i", to, "-o", from, "-j", "ACCEPT"])
  end

  # TOOD:
  # while( $chain = shell_exec("sudo iptables -t mangle -L | grep ".strtoupper($mac) ) !== NULL ) {
  #  exec("sudo iptables -D internet -t mangle -m mac --mac-source ".strtoupper($mac)." -j RETURN");

end
