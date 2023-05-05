zset RTL "/run/media/dtsalapatas/C840-06DD/SoC-git/RTL"
set SYNC "/run/media/dtsalapatas/C840-06DD/SoC-git/out"

set libpath "/run/media/dtsalapatas/C840-06DD/NangateOpenCellLibrary_PDKv1_3_v2010_12/Front_End/Liberty/CCS"

set_db library [glob $libpath/NangateOpenCellLibrary_worst_low_ccs.lib]

# set VERILOG_FILES [list 
#     \ $RTL/top.v 
#     \ $RTL/FSM.v
#     \ $RTL/BM_lamda.v
#     \ $RTL/DP_RAM.v
#     \ $RTL/error_correction.v
#     \ $RTL/GF_matrix_ascending_binary.v
#     \ $RTL/GF_matrix_dec.v
#     \ $RTL/GF_mult_add_syndromes.v
#     \ $RTL/input_syndromes.v
#     \ $RTL/lamda_roots.v
#     \ $RTL/Omega_Phy.v
#     \ $RTL/out_stage.v
#     \ $RTL/part A.v
#     \ $RTL/receiver.v
#     \ $RTL/RS_dec.v
#     \ $RTL/SIPO.v
#     \ $RTL/transport_in2out.v
# ]

set VERILOG_FILES {$RTL/top.v $RTL/FSM.v $RTL/BM_lamda.v $RTL/DP_RAM.v $RTL/error_correction.v $RTL/GF_matrix_ascending_binary.v $RTL/GF_matrix_dec.v $RTL/GF_mult_add_syndromes.v $RTL/input_syndromes.v $RTL/lamda_roots.v $RTL/Omega_Phy.v $RTL/out_stage.v $RTL/part A.v $RTL/receiver.v $RTL/RS_dec.v $RTL/SIPO.v $RTL/transport_in2out.v}

set top_module_name "top.v"

read_hdl $VERILOG_FILES

elaborate $top_module_name

# Current design/ xreiazetai ama exoyme polla design 
current_design $top_module_name

set_wire_load_model -name auto_select [get_designs *]

# Uniquify/ diaforopoiei ta onomata apo ola se ena design gia na mhn uparjei conflict
uniquify $top_module_name  

# Check design/ bgazei ena report gia to design 
check_design $top_module_name

# for {set clk_period 10} {$clk_period > 1} {set clk_period [expr {$clk_period - 1}]} {
set clk_period 10
create_clock -name clk -period $clk_period

set_input_delay 0 -clock clk [all_inputs]
set_output_delay 0 -clock clk [all_outputs]

set OUTPUT_DIR "$SYNC/${clk_period}ns_CCSlib"

if { [catch { exec mkdir $OUTPUT_DIR }] == 1 } {
  exec rm -rf $OUTPUT_DIR
  exec mkdir -p $OUTPUT_DIR
}

# Synthesize the design to the target library / rota aurio
set_db syn_generic_effort low
set_db auto_ungroup none
syn_generic
set_db syn_map_effort low
syn_map
set_db syn_opt_effort low 
syn_opt
syn_opt -incremental

# Write out the reports
check_design $top_module_name > "$OUTPUT_DIR/check_design.log"
report_timing > "$OUTPUT_DIR/timing.log"
report_area   > "$OUTPUT_DIR/area.log"
report_power  > "$OUTPUT_DIR/power.log"

# Write out netlist and sdc files
write_hdl -mapped >  "$OUTPUT_DIR/${top_module_name}_${clk_period}ns.v"
write_sdc >  "$OUTPUT_DIR/out.sdc"
# }

quit
