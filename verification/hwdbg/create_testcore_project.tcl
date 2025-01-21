# Was used with Vivado 2020.2

set script_dir [file normalize [file dirname [lindex $argv end]]]
source $script_dir/../../auxiliary/set_dirs.tcl

cd $script_dir

set proj_name "emmc_testcore"

file delete -force "./.Xil/"
file delete -force $proj_name

source "$auxiliary_dir/find_files.tcl"
set v_files   [list \
	{*}[find_files $src_dir *.v] \
	{*}[find_files $src_dir *.sv] \
	{*}[find_files $hwdbg_dir *.v] \
	{*}[find_files $hwdbg_dir *.sv]\
	{*}[find_files $verification_dir *.v] \
	{*}[find_files $verification_dir *.sv] ]
set vh_files  [list {*}[find_files $src_dir *.vh] {*}[find_files $src_dir *.svh] {*}[find_files $hwdbg_dir *.vh] {*}[find_files $hwdbg_dir *.svh]]
set vhd_files [find_files $src_dir *.vhd]
set xdc_files [find_files $constraints_dir *.xdc]
set src_files [list {*}$v_files {*}$vh_files {*}$vhd_files]

create_project $proj_name $hwdbg_dir/emmc_testcore -part xc7a35tcpg236-1 -force

set project [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $project
set_property -name "enable_vhdl_2008" -value "1" -objects $project
set_property -name "ip_cache_permissions" -value "read write" -objects $project
set_property -name "ip_output_repo" -value "$ip_dir" -objects $project
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $project
set_property -name "part" -value "xc7a35tcpg236-1" -objects $project
set_property -name "sim.central_dir" -value "$sim_dir/vivado/emmc_testcore" -objects $project
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $project
set_property -name "simulator_language" -value "Mixed" -objects $project
set_property -name "source_mgmt_mode" -value "DisplayOnly" -objects $project
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $project

if {[llength $src_files] != 0} {add_files -norecurse -fileset [get_filesets sources_1] $src_files}
if {[llength $xdc_files] != 0} {add_files -norecurse -fileset [get_filesets constrs_1] $xdc_files}

if {[llength $vhd_files] != 0} {set_property -name "file_type" -value "VHDL 2008" -objects [get_files -of_objects [get_filesets sources_1] *.vhd]}
if {[llength $vh_files] != 0} {set_property -name "file_type" -value "Verilog Header" -objects [get_files -of_objects [get_filesets sources_1] *.*vh]}
if {[llength $v_files] != 0} {set_property -name "file_type" -value "SystemVerilog" -objects [get_files -of_objects [get_filesets sources_1] *.sv]}

set_property -name "top" -value "emmc_testcore" -objects [get_filesets sources_1]

file delete -force $ip_dir

file mkdir $ip_dir
create_ip -vlnv {xilinx.com:ip:vio:3.0} -module vio -dir $ip_dir
set_property -dict [list \
	CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
	CONFIG.C_NUM_PROBE_IN {0} \
	] [get_ips vio]
generate_target {instantiation_template} [get_files $ip_dir/vio/vio.xci]

create_ip -vlnv {xilinx.com:ip:ila:6.2} -module ila -dir $ip_dir
set_property -dict [list \
	CONFIG.C_PROBE0_WIDTH {512} \
	CONFIG.C_DATA_DEPTH {2048} \
	CONFIG.C_PROBE0_MU_CNT {2} \
	CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
	] [get_ips ila]
generate_target {instantiation_template} [get_files $ip_dir/ila/ila.xci]

exit
