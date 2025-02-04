set script_dir [file normalize [file dirname [lindex $argv end]]]
set root_dir $script_dir/../

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
	do $script_dir/ag_checkerboard_tb.tcl
}

vlib rtl_work
vmap work rtl_work

vlog -sv $script_dir/ag_checkerboard.sv
vlog -sv $script_dir/ag_checkerboard_tb.sv

vsim -t 1ps -voptargs="+acc" ag_checkerboard_tb

add wave *
add wave uut/part_counter
add wave uut/work_counter

run 200ns
wave zoom full
