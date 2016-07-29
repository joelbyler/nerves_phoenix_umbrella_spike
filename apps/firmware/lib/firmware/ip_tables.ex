defmodule Firmware.IpTables do

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

  def insert_captive_portal_rule(destination, port) do
    System.cmd("iptables", ["-N", "internet", "-t", "mangle"])
    System.cmd("iptables", ["-t", "mangle", "-A", "PREROUTING", "-j", "internet"])
    System.cmd("iptables", ["-t", "mangle", "-A", "internet", "-j", "MARK", "--set-mark", "99"])
    System.cmd("iptables", ["-t", "nat", "-A", "PREROUTING", "-m", "mark", "--mark", "99", "-p", "tcp", "--dport", port, "-j", "DNAT", "--to-destination", destination])
    System.cmd("iptables", ["-t", "filter", "-A", "FORWARD", "-m", "mark", "--mark", "99", "-j", "DROP"])
    System.cmd("iptables", ["-t", "filter", "-A", "INPUT", "-p", "tcp", "--dport", "80", "-j", "ACCEPT"])
    System.cmd("iptables", ["-t", "filter", "-A", "INPUT", "-p", "udp", "--dport", "53", "-j", "ACCEPT"])
    System.cmd("iptables", ["-t", "filter", "-A", "INPUT", "-m", "mark", "--mark", "99", "-j", "DROP"])
  end

  def start_post_routing(interface) do # interface = eth0
    System.cmd("iptables", ["-t", "nat", "-A", "POSTROUTING"])
    System.cmd("iptables", ["-t", "nat", "-A", "POSTROUTING", "-o", interface, "-j", "MASQUERADE"])
  end

  def forward(from, to) do # to = "wlan0, from = "eth0"
    System.cmd("iptables", ["-A", "FORWARD", "-i", from, "-o", to, "-m", "state", "--state", "RELATED,ESTABLISHED", "-j", "ACCEPT"])
    System.cmd("iptables", ["-A", "FORWARD", "-i", to, "-o", from, "-j", "ACCEPT"])
  end


end
