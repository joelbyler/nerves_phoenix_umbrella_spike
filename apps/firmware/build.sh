#!/bin/sh

export NERVES_SYSTEM=~/Workspaces/nerves_systems/nerves_system_rpi3

mix compile
mix firmware
mix firmware.burn

diskutil unmountDisk disk2
