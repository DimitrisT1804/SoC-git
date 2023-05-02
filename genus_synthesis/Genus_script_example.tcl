set RTL "/home/"
set SYNC "/home/"

set libpath /home/

set_db library [glob $libpath/libs/...lib]


set VERILOG_FILES $RTL/7...v

set top_module_name ...

read_hdl $VERILOG_FILES

elaborate $top_module_name

# Current design
current_design $top_module_name

set_wire_load_model -name auto_select [get_designs *]

# Uniquify
uniquify $top_module_name

# Check design
check_design $top_module_name

# for {set clk_period 10} {$clk_period > 1} {set clk_period [expr {$clk_period - 1}]} {
set clk_period 2
create_clock -name clk -period $clk_period

set_input_delay 0 -clock clk [all_inputs]
set_output_delay 0 -clock clk [all_outputs]

set OUTPUT_DIR "$SYNC/${clk_period}ns_CCSlib"


if { [catch { exec mkdir $OUTPUT_DIR }] == 1 } {
  exec rm -rf $OUTPUT_DIR
  exec mkdir -p $OUTPUT_DIR
}

# Synthesize the design to the target library
set_db syn_generic_effort high
set_db auto_ungroup none
syn_generic
set_db syn_map_effort high
syn_map
set_db syn_opt_effort high
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