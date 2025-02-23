set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dat_io[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports cmd_io]
set_property IOSTANDARD LVCMOS18 [get_ports clk_i]
set_property IOSTANDARD LVCMOS18 [get_ports clk_pad_o]
set_property IOSTANDARD LVCMOS18 [get_ports nrst_o]
set_property PACKAGE_PIN W2 [get_ports {dat_io[0]}]
set_property PACKAGE_PIN T2 [get_ports {dat_io[1]}]
set_property PACKAGE_PIN T3 [get_ports {dat_io[2]}]
set_property PACKAGE_PIN W3 [get_ports {dat_io[3]}]
set_property PACKAGE_PIN V3 [get_ports {dat_io[4]}]
set_property PACKAGE_PIN V2 [get_ports {dat_io[5]}]
set_property PACKAGE_PIN R2 [get_ports {dat_io[6]}]
set_property PACKAGE_PIN R3 [get_ports {dat_io[7]}]
set_property PACKAGE_PIN U3 [get_ports clk_pad_o]
set_property PACKAGE_PIN U5 [get_ports cmd_io]
set_property PACKAGE_PIN U4 [get_ports nrst_o]
set_property PACKAGE_PIN A16 [get_ports clk_i]

set_property PULLUP true [get_ports cmd_io]
set_property PULLUP true [get_ports clk_pad_o]
set_property PULLUP true [get_ports {dat_io[7]}]
set_property PULLUP true [get_ports {dat_io[6]}]
set_property PULLUP true [get_ports {dat_io[5]}]
set_property PULLUP true [get_ports {dat_io[4]}]
set_property PULLUP true [get_ports {dat_io[3]}]
set_property PULLUP true [get_ports {dat_io[2]}]
set_property PULLUP true [get_ports {dat_io[1]}]
set_property PULLUP true [get_ports {dat_io[0]}]

set_property PULLDOWN true [get_ports nrst_o]
set_property SLEW SLOW [get_ports nrst_o]

set_property PULLUP true [get_ports clk_i]

set_property SLEW SLOW [get_ports {dat_io[7]}]
set_property SLEW SLOW [get_ports {dat_io[6]}]
set_property SLEW SLOW [get_ports {dat_io[5]}]
set_property SLEW SLOW [get_ports {dat_io[4]}]
set_property SLEW SLOW [get_ports {dat_io[3]}]
set_property SLEW SLOW [get_ports {dat_io[2]}]
set_property SLEW SLOW [get_ports {dat_io[1]}]
set_property SLEW SLOW [get_ports {dat_io[0]}]
set_property SLEW FAST [get_ports cmd_io]

create_clock -period 40.000 -name clk_i -waveform {0.000 20.000} [get_ports clk_i]
create_generated_clock -name clk_divided -source [get_ports clk_i] -divide_by 64 [get_pins clkdiv_inst/clk_reg/Q]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_i_IBUF_BUFG]
set_clock_groups -logically_exclusive \
	-group [get_clocks -include_generated_clock clk_i] \
	-group [get_clocks -include_generated_clock clk_divided]
