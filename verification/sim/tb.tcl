set script_dir [file normalize [file dirname [lindex $argv end]]]
source $script_dir/../../auxiliary/set_dirs.tcl
source $auxiliary_dir/find_files.tcl
source $auxiliary_dir/vcom_recursive.tcl

try {
	file delete {*}[glob $script_dir/wlft*]
} on error {} {
}

proc omt {} {
	global script_dir
	global launch_dir
	global root_dir
	quit -sim
	cd $root_dir
	do $script_dir/tb.tcl
}

set v_files   [list \
	{*}[find_files $src_dir *.v] \
	{*}[find_files $src_dir *.sv] \
	{*}[find_files $sim_dir *.v] \
	{*}[find_files $sim_dir *.sv] \
	{*}[find_files $verification_dir *.sv] \
	{*}[find_files $verification_dir *.v] ]
set vhd_files [find_files $src_dir *.vhd]

cd $sim_dir
vlib rtl_work
vmap work rtl_work

foreach txt_file [find_files $src_dir/sd_mmc_emulator *.txt] {
	set file_short_name [file tail $txt_file]
	set file_new_name $sim_dir/$file_short_name
	file copy -force $txt_file $file_new_name
}

foreach v_file $v_files {vlog -sv +incdir+$src_dir/inc $v_file}
vcom_recursive [find_files $src_dir/sd_mmc_emulator *pack.vhd]
foreach vhd_file $vhd_files {vcom -2008 $vhd_file}

vlog -sv +incdir+$src_dir/inc+$sim_dir $sim_dir/tb.sv

vsim -g emmc_sm_inst/___SIMULATION___=1 -t 1ps -voptargs="+acc" tb

add wave clk_core
add wave rst
add wave -divider
add wave emmc_sm_inst/orig_state
add wave emmc_sm_inst/curr_state
add wave emmc_sm_inst/next_state
add wave -divider
add wave emmc_sm_inst/sd_cmd_host_inst/serial_state
add wave emmc_sm_inst/sd_cmd_host_inst/cmd_state
add wave -divider
add wave emmc_sm_inst/sd_data_8bit_host_inst/state
add wave -divider
add wave mmc_data_pipe_inst/mmc_1/card_state
add wave -divider
add wave emmc_dat_wr
add wave emmc_dat_rd

run 20000ns
wave zoom full
