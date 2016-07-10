defmodule Firmware.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi3"

  def project do
    [app: :firmware,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "0.1.3"],
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
     applications: [:nerves, :logger, :nerves_networking, :user_interface, :sqlitex, :porcelain]]
  end

  def deps do
    [{:nerves, "~> 0.3.0"},
     {:porcelain, "~> 2.0"},
     {:user_interface, in_umbrella: true},
     {:sqlite_ecto, ">= 0.0.0"},
     {:nerves_networking, github: "nerves-project/nerves_networking"}]
  end

  def system(target) do
    # [{:"nerves_system_#{target}", ">= 0.0.0", git: "git@github.com:joelbyler/nerves_system_rpi3_jcb.git"}]
    [{:"nerves_system_#{target}", ">= 0.0.0"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
