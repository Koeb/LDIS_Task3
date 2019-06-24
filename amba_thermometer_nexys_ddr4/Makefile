all: synth sim

.PHONY: synth sim

synth:
	wget -O synth/TWICtl.vhd https://raw.githubusercontent.com/Digilent/Nexys-4-DDR-OOB/master/src/hdl/TWICtl.vhd
	wget -O synth/TempSensorCtl.vhd https://raw.githubusercontent.com/Digilent/Nexys-4-DDR-OOB/master/src/hdl/TempSensorCtl.vhd
	patch synth/TempSensorCtl.vhd -i synth/TempSensorCtl.patch
	vivado -mode batch -source synth.tcl
	rm -f synth/TempSensorCtl.vhd.orig
	rm -f synth/TempSensorCtl.vhd.rej

sim:
	vivado -mode batch -source sim.tcl

install:
	vivado -mode batch -source prog.tcl

cleansim:
	rm -rf ./sim/build/ 

cleansynth:
	rm -rf ./synth/build/
	rm -f ./synth/TWICtl.vhd
	rm -f ./synth/TempSensorCtl.vhd
	rm -f *.jou
	rm -f *.log
	rm -f thermometer.bit