`include "tb.svh"

module tb;

	logic clk;
	localparam PERIOD = 25;
	initial clk_gen(clk, PERIOD);
	logic rst;
	initial rst_gen(rst, clk);

	logic clk_divided;
	clkdiv #(
		.FACTOR(64)
	) clkdiv_inst (
		.clk_i(clk),
		.clk_o(clk_divided)
	);

	logic clk_core;
	logic emmc_cmd_wr;
	logic emmc_cmd_rd;
	logic emmc_cmd_oe;
	logic [jedec_p::DAT_WIDTH - 1 : 0] emmc_dat_wr;
	logic [jedec_p::DAT_WIDTH - 1 : 0] emmc_dat_rd;
	logic emmc_dat_oe;
	logic [1 : 0] emmc_dat_siz;
	logic sel_clk;
	logic we;
	logic start;
	logic [jedec_p::DAT_WIDTH - 1 : 0] dat_wr_eeprom;
	logic [jedec_p::DAT_WIDTH - 1 : 0] dat_rd_eeprom;
	logic dvalid;
	logic ready;

	logic emmc_cmd_wr2mem;
	assign emmc_cmd_wr2mem = emmc_cmd_oe ? emmc_cmd_wr : 'z;

	logic [$bits(emmc_dat_wr) - 1 : 0] emmc_dat_wr2mem;
	assign emmc_dat_wr2mem = emmc_dat_oe ? emmc_dat_wr : 'z;

	logic mmc_cmd_oe;
	logic emmc_cmd_rdfrommem;
	assign emmc_cmd_rdfrommem = mmc_cmd_oe ? emmc_cmd_rd : 'z;

	logic mmc_dat_oe;
	logic [$bits(emmc_dat_rd) - 1 : 0] emmc_dat_rdfrommem;
	assign emmc_dat_rdfrommem = mmc_dat_oe ? emmc_dat_rd : 'z;

	emmc_sm emmc_sm_inst (
		.clk_i(clk_core),
		.arst_i(rst),
		.emmc_cmd_i(emmc_cmd_rdfrommem),
		.emmc_cmd_o(emmc_cmd_wr),
		.emmc_cmd_oe_o(emmc_cmd_oe),
		.emmc_dat_i(emmc_dat_rdfrommem),
		.emmc_dat_o(emmc_dat_wr),
		.emmc_dat_oe_o(emmc_dat_oe),
		.emmc_dat_siz_o(emmc_dat_siz),
		.sel_clk_o(sel_clk),

		.we_i(we),
		.start_i(start),
		.dat_i(dat_wr_eeprom),
		.dat_o(dat_rd_eeprom),
		.dvalid_o(dvalid),
		.ready_o(ready)
	);
	assign clk_core = sel_clk ? clk : clk_divided;

	assign start = 1;
	always_ff @(posedge clk_core or posedge rst) begin
		if(rst) begin
			we <= '1;
			dat_wr_eeprom <= 'h55;
		end else if(ready) begin
			we <= ~we;
			if(we) dat_wr_eeprom <= ~dat_wr_eeprom; // preparing next value to be written
		end
	end

	logic clk_mmc;
	assign clk_mmc = clk_core;
	mmc_data_pipe mmc_data_pipe_inst (
		.sys_rst_n     (~rst),
		.sys_clk       (clk_mmc),

		.adr_i         (),
		.sel_i         (),
		.we_i          (),
		.dat_i         (),
		.dat_o         (),
		.ack_o         (),

		.mmc_clk_i     (clk_mmc),
		.mmc_cmd_i     (emmc_cmd_wr2mem),
		.mmc_cmd_o     (emmc_cmd_rd),
		.mmc_cmd_oe_o  (mmc_cmd_oe),
		.mmc_od_mode_o (),
		.mmc_dat_i     (emmc_dat_wr2mem),
		.mmc_dat_o     (emmc_dat_rd),
		.mmc_dat_oe_o  (mmc_dat_oe),
		.mmc_dat_siz_o (),

		.wr_clk_i      (clk_mmc),
		.wr_clk_en_i   (1'b1),
		.wr_reset_i    (rst),
		.wr_en_i       (),
		.wr_dat_i      (),
		.wr_fifo_level (),
		.wr_fifo_full  (),
		.wr_fifo_empty (),

		.rd_clk_i      (clk_mmc),
		.rd_clk_en_i   (1'b1),
		.rd_reset_i    (rst),
		.rd_en_i       (),
		.rd_dat_o      (),
		.rd_fifo_level (),
		.rd_fifo_full  (),
		.rd_fifo_empty (),

		.ram_clk_i     (),
		.ram_clk_en_i  (),
		.ram_adr_i     (),
		.ram_we_i      (),
		.ram_dat_i     (),
		.ram_dat_o     ()

	);


endmodule
