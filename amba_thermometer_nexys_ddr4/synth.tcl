# -----------------------------------------------------------------------------
# This script generates the bitstream from the sources
# -----------------------------------------------------------------------------
#
create_project -part xc7a100t -force amba_thermometer ./synth/build/
#
# -----------------------------------------------------------------------------
#
read_vhdl src/*
read_xdc  synth/constraints.xdc
#
# -----------------------------------------------------------------------------
#
synth_design -top thermometer
#
# -----------------------------------------------------------------------------
#
opt_design
place_design
route_design
#
# -----------------------------------------------------------------------------
#
write_bitstream -force thermometer.bit