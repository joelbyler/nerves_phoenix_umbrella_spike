defmodule Firmware.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi3"

  def project do
    [app: :firmware,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "0.1.2"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Firmware, []},
     applications: [:nerves, :logger]]
  end

  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:create_ap, github: 'oblique/create_ap', app: false}
    ]
  end

  def system(target) do
    [{:"nerves_system_#{target}", ">= 0.0.0", git: "git@github.com:joelbyler/nerves_system_rpi3.git"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
