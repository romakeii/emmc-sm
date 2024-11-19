set project_name emmc-sm

set launch_dir [pwd]
set script_dir [file normalize [file dirname [lindex $argv end]]]

set root_dir $script_dir
while {1} {
	# Check if we digged all the way to the root dir of a filesystem; if so, something went wrong
	if {[regexp {^[A-z]:\/$|^\/$} $root_dir]} {
		set root_dir 0
		break
	} else {
		set name_under_consideration [lindex [split $root_dir /] end]
		if {[string compare -nocase name_under_consideration project_name]} {break}
		set root_dir [file normalize $root_dir/..]
	}
}
set root_dir [file normalize $root_dir/..]

set src_dir [file normalize $root_dir/src]
set sim_dir [file normalize $root_dir/sim]
set auxiliary_dir [file normalize $root_dir/auxiliary]
set constraints_dir [file normalize $root_dir/constraints]
set hwdbg_dir [file normalize $root_dir/hwdbg]
set ip_dir [file normalize $root_dir/ip]
set vivado_dir [file normalize $root_dir/vivado]