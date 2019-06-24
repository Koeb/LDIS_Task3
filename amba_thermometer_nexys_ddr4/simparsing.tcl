open_vcd sim/parsing_sim.vcd
log_vcd [get_object *]
add_wave [get_object *]
run 2us
close_vcd