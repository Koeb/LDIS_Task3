open_vcd sim/amba_sim.vcd
log_vcd [get_object *]
add_wave [get_object *]
run 100us
close_vcd