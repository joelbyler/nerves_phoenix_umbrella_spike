#!/bin/sh

export NERVES_SYSTEM=~/Workspaces/nerves_systems/nerves_system_rpi3
echo $NERVES_SYSTEM

mix deps.get
mix compile
mix firmware
mix firmware.burn
