all: synth sim

.PHONY: synth sim

synth:
	vivado -mode batch -source synth.tcl

sim:
	vivado -mode batch -source sim.tcl

install:
	vivado -mode batch -source prog.tcl

cleansim:
	rm -rf ./sim/build/ 

cleansynth:
	rm -rf ./synth/build/
	rm -f *.jou
	rm -f *.log
	rm -f thermometer.bit