`include "jedec.svh"

module testcore (
	input logic clk_i,
	output logic nrst_o,
	inout logic emmc_cmd_io,
	inout logic [jedec_p::DAT_WIDTH - 1 : 0] emmc_dat_io,
	output logic emmc_clk_o_pad
);

	logic clk_divided;
	clkdiv #(
		.FACTOR(64)
	) clkdiv_inst (
		.clk_i(clk_i),
		.clk_o(clk_divided)
	);
	logic sel_clk;
	logic clk_core;
	assign clk_core = sel_clk ? clk_i : clk_divided;

	vio vio_inst (
		.clk(clk_i),
		.probe_out0(system_start_i)
	);

	assign emmc_clk_o_pad = clk_core;

endmodule
