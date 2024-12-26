`include "jedec.svh"

module emmc_testcore #(
	parameter int unsigned ___SIMULATION___ = 0
) (
	input logic clk_i,
	input logic arst_i,
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

	logic rst_tk;

	logic host_cmd;
	logic host_cmd_oe;
	logic [jedec_p::DAT_WIDTH - 1 : 0] host_dat;
	logic host_dat_oe;

	assign cmd_io = host_cmd_oe ? host_cmd : 'z;
	assign dat_io = host_dat_oe ? host_dat : 'z;

	logic host_we;
	logic host_start;
	logic [7 : 0] host_wr_dat;
	logic [7 : 0] host_rd_dat;
	logic host_dvalid;
	logic host_ready;

	assign host_start = 1;
	always_ff @(posedge clk_core or posedge rst_tk) begin
		if(rst_tk) begin
			host_wr_dat <= 0;
			host_we <= 1;
		end else begin
			if(host_dvalid) host_wr_dat <= host_wr_dat + 1;
			if(host_ready)  host_we <= ~host_we;
		end

	end

	emmc_sm emmc_sm_inst (
		.clk_i(clk_core),
		.arst_i(rst_tk),

		.emmc_cmd_i(cmd_io),
		.emmc_cmd_o(host_cmd),
		.emmc_cmd_oe_o(host_cmd_oe),

		.emmc_dat_i(dat_io),
		.emmc_dat_o(host_dat),
		.emmc_dat_oe_o(host_dat_oe),

		.sel_clk_o(sel_clk),

		.blk_cnt_i(1),
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
					emmc_sm_inst.we_i,
					emmc_sm_inst.start_i,
					emmc_sm_inst.dat_i,
					emmc_sm_inst.dat_o,
					emmc_sm_inst.dvalid_o,
					emmc_sm_inst.ready_o,
					emmc_sm_inst.orig_state,
					emmc_sm_inst.curr_state,
					emmc_sm_inst.next_state,
					cmd_io,
					dat_io,
					emmc_sm_inst.card_status
				})
			);

			logic system_start;
			vio vio_inst (
				.clk(clk_i),
				.probe_out0(system_start)
			);
			assign rst_tk = ~system_start;

		end else begin
			assign rst_tk = arst_i;
		end

	endgenerate

endmodule
