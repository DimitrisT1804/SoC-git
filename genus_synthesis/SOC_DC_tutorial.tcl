set search_path "."
set results_path "./postsynthesis"

exec mkdir $results_path


# Technology Library #
set target_library {./NangateOpenCellLibrary_worst_low_ccs.db}

# Synopsys DesignWare #
set synthetic_library {/home/edatools/synopsys/2016-17/RHELx86/SYN_2016.12/libraries/syn/dw_foundation.sldb}

# Libraries List used upon Synthesis #  
set link_library [ list $target_library $synthetic_library ]


# HDL In #
analyze -f Verilog {./counter.v ./top.v}

# Elaborate Design #
elaborate counter8 

# Set Top Module #
current_design counter8

# SDC #
create_clock "clk" -name clk -period 1
set auto_wire_load_selection true

set_max_fanout 25 [all_inputs]
set_max_area 0

# Link Design #
link

# Check Warnings and Errors #
check_design

# Synthesize #
compile -map_effort high
#compile_ultra 

# Check Warnings and Errors #
check_design > postsynthesischeckdesign_counter8.log



report_timing

report_area

report_area -hierarchy

# Write DDC File - Synopsys Design AND Library binary format #
write -h -f ddc -output $results_path/counter8_postsynthesis.ddc

# Write Verilog Netlist #
write -h -f verilog -output $results_path/counter8_postsynthesis.v

# Write SDC #
write_sdc $results_path/counter8_postsynthesis.sdc

# Write SDF #
write_sdf $results_path/counter8_postsynthesis.sdf




