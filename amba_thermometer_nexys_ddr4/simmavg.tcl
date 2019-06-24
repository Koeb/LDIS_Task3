open_vcd sim/mavg_sim.vcd
log_vcd [get_object *]
add_wave [get_object *]
run 22us
close_vcd