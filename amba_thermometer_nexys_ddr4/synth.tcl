# -----------------------------------------------------------------------------
# This script generates the bitstream from the sources
# -----------------------------------------------------------------------------
#
create_project -part xc7a100t -force amba_thermometer ./synth/build/
#
# -----------------------------------------------------------------------------
#
read_vhdl src/AmbaDemux4.vhd
read_vhdl src/ambaMaster.vhd
read_vhdl src/ambaSlave.vhd
read_vhdl src/clkdivide.vhdl
read_vhdl src/DSPSlave.vhd
read_vhdl src/InputSlave.vhd
read_vhdl src/moving_average.vhd
read_vhdl src/OutputSlave.vhd
read_vhdl src/parsing7seg.vhd
read_vhdl src/SensorSlave.vhd
read_vhdl src/TempSensorCtl.vhdl
read_vhdl src/thermometer.vhdl
read_vhdl src/TWICtl.vhdl
read_vhdl src/whole7segment.vhdl
read_vhdl src/windowsize.vhd
#
# -----------------------------------------------------------------------------
#
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