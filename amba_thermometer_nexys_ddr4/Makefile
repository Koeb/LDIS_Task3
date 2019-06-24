all: synth sim

.PHONY: synth sim

synth:
	wget -O synth/TWICtl.vhd https://raw.githubusercontent.com/Digilent/Nexys-4-DDR-OOB/master/src/hdl/TWICtl.vhd
	wget -O synth/TempSensorCtl.vhd https://raw.githubusercontent.com/Digilent/Nexys-4-DDR-OOB/master/src/hdl/TempSensorCtl.vhd
	patch synth/TempSensorCtl.vhd -i synth/TempSensorCtl.patch
	vivado -mode batch -source synth.tcl
	rm -f synth/TempSensorCtl.vhd.orig
	rm -f synth/TempSensorCtl.vhd.rej
	rm thermometer.bit synth/thermometer.bit

sim:
	#ghdl -s src/AmbaDemux4.vhd src/ambaMaster.vhd src/ambaSlave.vhd sim/amba_tb.vhd
	#ghdl -a src/AmbaDemux4.vhd src/ambaMaster.vhd src/ambaSlave.vhd sim/amba_tb.vhd
	#ghdl -e amba_tb
	#ghdl -r amba_tb --vcd=amba.vcd
	#gtkwave amba.vcd &
	#parse sources
	xvhdl -nolog src/AmbaDemux4.vhd
	xvhdl -nolog src/ambaMaster.vhd
	xvhdl -nolog src/ambaSlave.vhd
	xvhdl -nolog sim/amba_tb.vhd
	#generate design snapshot
	xelab -nolog -debug typical amba_tb -s top_amba_sim
	#simulate design
	xsim top_amba_sim -nolog -gui -t sim.tcl -wdb sim/amba_sim.wdb

simmavg:
	xvhdl -nolog src/moving_average.vhd
	xvhdl -nolog sim/mavg_tb.vhd
	xelab -nolog -debug typical mavg_tb -s top_mavg_sim
	xsim top_mavg_sim -nolog -gui -t simmavg.tcl -wdb sim/mavg_sim.wdb

simparsing:
	xvhdl -nolog src/whole7segment.vhdl
	xvhdl -nolog src/parsing7seg.vhd
	xvhdl -nolog sim/parsing_tb.vhd
	xelab -nolog -debug typical parsing_tb -s top_parsing_sim
	xsim top_parsing_sim -nolog -gui -t simparsing.tcl -wdb sim/parsing_sim.wdb

install:
	vivado -mode batch -source prog.tcl

cleansim:
	rm -f sim/parsing_sim.wdb
	rm -f sim/parsing_sim.vcd
	rm -f sim/mavg_sim.wdb
	rm -f sim/mavg_sim.vcd
	rm -f sim/amba_sim.wdb
	rm -f sim/amba_sim.vcd
	rm -rf xsim.dir/
	rm -f *.pb
	rm -f *.jou
	rm -f *.log
	rm -rf .Xil

cleansynth:
	rm -rf ./synth/build/
	rm -f ./synth/TWICtl.vhd
	rm -f ./synth/TempSensorCtl.vhd
	rm -f *.jou
	rm -f *.log
	rm -f thermometer.bit
	rm -f ./synth/thermometer.bit
	rm -rf .Xil