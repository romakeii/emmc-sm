`include "jedec.svh"

module testcore #(
	parameter int unsigned ___SIMULATION___ = 0
) (
	input logic clk_i,
	output logic nrst_o,
	inout logic cmd_io,
	inout logic [jedec_p::DAT_WIDTH - 1 : 0] dat_io,
	output logic clk_pad_o
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

	logic rst_manual;

	logic host_cmd;
	logic host_cmd_oe;
	logic [jedec_p::DAT_WIDTH - 1 : 0] host_dat;
	logic host_dat_oe;

	assign cmd_io = host_cmd_oe ? host_cmd : 'z;
	assign dat_io = host_dat_oe ? host_dat : 'z;

	logic host_we;
	logic host_start;
	logic host_wr_dat;
	logic host_rd_dat;
	logic host_dvalid;
	logic host_ready;

	emmc_sm emmc_sm_inst (
		.clk_i(clk_core),
		.arst_i(rst_manual),

		.emmc_cmd_i(cmd_io),
		.emmc_cmd_o(host_dat),
		.emmc_cmd_oe_o(host_cmd_oe),

		.emmc_dat_i(dat_io),
		.emmc_dat_o(host_cmd),
		.emmc_dat_oe_o(host_dat_oe),

		.sel_clk_o(sel_clk),

		.blk_cnt_i(2),
		.we_i(host_we),
		.start_i(host_start),
		.dat_i(host_wr_dat),
		.dat_o(host_rd_dat),
		.dvalid_o(host_dvalid),
		.ready_o(host_ready)
	);

	assign clk_pad_o = clk_core;

	generate

		if(~___SIMULATION___) begin

			ila ila_inst (
				.clk(clk_core),
				.probe0({
					emmc_sm_inst.fsm_dat_not_busy,
					emmc_sm_inst.dath_crc_ok
				})
			);

			logic system_start;
			vio vio_inst (
				.clk(clk_i),
				.probe_out0(system_start)
			);
			assign rst_manual = ~system_start;

		end

	endgenerate

endmodule
