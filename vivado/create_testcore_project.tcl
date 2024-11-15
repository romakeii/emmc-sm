set launch_dir [pwd]
set script_dir [file normalize [file dirname [lindex $argv end]]]
set root_dir [file normalize $script_dir/..]

source "$root_dir/auxiliary/find_files.tcl"

set proj_name "testcore"

set v_files   [list {*}[find_files $root_dir/src *.v] {*}[find_files $root_dir/src *.sv] {*}[find_files $root_dir/hwdbg *.v] {*}[find_files $root_dir/hwdbg *.sv]]
set vh_files  [list {*}[find_files $root_dir/src *.vh] {*}[find_files $root_dir/src *.svh] {*}[find_files $root_dir/hwdbg *.vh] {*}[find_files $root_dir/hwdbg *.svh]]
set vhd_files [find_files $root_dir/src *.vhd]
set xdc_files [find_files $root_dir/constraints *.xdc]
set src_files [list {*}$v_files {*}$vh_files {*}$vhd_files]

create_project $proj_name $root_dir/vivado -part xc7a35tcpg236-1 -force

set project [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $project
set_property -name "enable_vhdl_2008" -value "1" -objects $project
set_property -name "ip_cache_permissions" -value "read write" -objects $project
set_property -name "ip_output_repo" -value "$root_dir/ip" -objects $project
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $project
set_property -name "part" -value "xc7a35tcpg236-1" -objects $project
set_property -name "sim.central_dir" -value "$root_dir/sim/vivado" -objects $project
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $project
set_property -name "simulator_language" -value "Mixed" -objects $project
set_property -name "source_mgmt_mode" -value "DisplayOnly" -objects $project
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $project

if {[llength $src_files] != 0} {add_files -norecurse -fileset [get_filesets sources_1] $src_files}

if {[llength $vhd_files] != 0} {set_property -name "file_type" -value "VHDL 2008" -objects [get_files -of_objects [get_filesets sources_1] *.vhd]}
if {[llength $vh_files] != 0} {set_property -name "file_type" -value "Verilog Header" -objects [get_files -of_objects [get_filesets sources_1] *.*vh]}
if {[llength $v_files] != 0} {set_property -name "file_type" -value "SystemVerilog" -objects [get_files -of_objects [get_filesets sources_1] *.sv]}

set_property -name "top" -value "testcore" -objects [get_filesets sources_1]

create_ip -vlnv {xilinx.com:ip:vio:3.0} -module vio -dir $root_dir/ip/
set_property -dict [list \
	CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
	CONFIG.C_NUM_PROBE_IN {0} \
	] [get_ips vio]
generate_target {instantiation_template} [get_files $root_dir/ip/vio/vio.xci]

exit
