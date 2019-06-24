open_vcd sim/amba_sim.vcd
#log_vcd [get_object /<toplevel_testbench/uut/*>]
log_vcd [get_object *]
add_wave [get_object *]
#/<top_amba_sim/uut_m>]
run 100us
close_vcd