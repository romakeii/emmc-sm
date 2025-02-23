`include "emmc_sm.svh"

`define __SETUP_WAIT__(WAIT_FOR_WHAT, IDX, ARG) \
	do begin \
		next_state = WAIT_FOR_WHAT; \
		state_change_enbl = 1; \
		cmdh_cmd_info.idx = IDX; \
		cmdh_cmd_info.arg = ARG; \
		cmdh_start = 1; \
	end while (0)

`define __SETUP_WAIT_FOR_CMD__(IDX, ARG) \
	`__SETUP_WAIT__(emmc_sm_p::WAIT_CMD, IDX, ARG);

`define __SETUP_WAIT_FOR_DAT__(IDX, ARG) \
	`__SETUP_WAIT__(emmc_sm_p::WAIT_DAT, IDX, ARG);

module emmc_sm #(
	parameter logic ___SIMULATION___ = 0
) (
	input logic clk_i,
	input logic arst_i,

	input logic emmc_cmd_i,
	output logic emmc_cmd_o,
	output logic emmc_cmd_oe_o,
	input logic [7 : 0] emmc_dat_i,
	output logic [7 : 0] emmc_dat_o,
	output logic emmc_dat_oe_o,
	output logic [1 : 0] emmc_dat_siz_o,

	output logic sel_clk_o,

	// Interface
	input logic we_i,
	input logic start_i,
	input logic [31 : 0] blk_idx_i,
	input logic [jedec_p::BLK_CNT_WIDTH - 1 : 0] blk_cnt_i,
	input logic [7 : 0] dat_i,
	output logic [7 : 0] dat_o,
	output logic dvalid_o,
	output logic ready_o

);

	localparam logic [31 : 0] CARD_ADDR_ARG = 32'h40000;

	logic [31 : 0] cmdh_response_0;
	logic [31 : 0] cmdh_response_1;
	logic [31 : 0] cmdh_response_2;
	logic [31 : 0] cmdh_response_3;

	jedec_p::cid_t cid;
	jedec_p::csd_t csd;
	jedec_p::ext_csd_t ext_csd;
	logic [$bits(ext_csd) - 1 : 0] ext_csd_stream;
	logic [31 : 0] card_status; // TODO: replace with a structure defined in jedec_p

	enum int unsigned { CID, CSD, CARD_STATUS, EXT_CSD } regs;
	logic [regs.num() - 1 : 0] wr_enbl_of_reg;

	logic [7 : 0] dat_rev_order;
	assign dat_rev_order = {<< {dat_o}};
	always_ff @(posedge clk_i or posedge arst_i) begin
		if(arst_i) begin
			{cid, csd, card_status, ext_csd_stream} <= '0;
		end else begin
			if(wr_enbl_of_reg[CID])         cid <= {cmdh_response_0, cmdh_response_1, cmdh_response_2, cmdh_response_3};
			if(wr_enbl_of_reg[CSD])         csd <= {cmdh_response_0, cmdh_response_1, cmdh_response_2, cmdh_response_3};
			if(wr_enbl_of_reg[CARD_STATUS]) card_status <= cmdh_response_0;
			if(wr_enbl_of_reg[EXT_CSD])     ext_csd <= {dat_rev_order, ext_csd[$bits(ext_csd_stream) - 1 : 8]};
		end
	end

	logic sd_clk;
	logic cmdh_start;
	typedef struct packed {
		logic [5 : 0] idx;
		logic [31 : 0] arg;
	} cmd_info_t;
	cmd_info_t cmdh_cmd_info;
	logic cmdh_int_rst;
	typedef struct packed {
		logic cie;
		logic ccrce;
		logic cte;
		logic ei;
		logic cc;
	} cmd_int_status_t;
	cmd_int_status_t cmdh_int_status;

	assign sd_clk = clk_i;

	logic dath_busy;
	sd_cmd_host sd_cmd_host_inst (
		.sys_rst(arst_i),
		.sd_clk(sd_clk),
		.start_i(cmdh_start),
		.int_rst_i(cmdh_int_rst),
		.busy_i(dath_busy),
		.cmd_index_i(cmdh_cmd_info.idx),
		.argument_i(cmdh_cmd_info.arg),
		.timeout_i(16'hefff),
		.int_status_o(cmdh_int_status),
		.response_0_o(cmdh_response_0),
		.response_1_o(cmdh_response_1),
		.response_2_o(cmdh_response_2),
		.response_3_o(cmdh_response_3),
		.sd_cmd_i(emmc_cmd_i),
		.sd_cmd_o(emmc_cmd_o),
		.sd_cmd_oe_o(emmc_cmd_oe_o)
	);

	logic dath_tx_dat_rd;
	logic dath_rx_dat_we;
	logic dath_stop;
	logic dath_read;
	logic dath_write;
	logic dath_fsm_busy;
	logic dath_crc_ok;
	logic [1 : 0] dath_bus_size;
	logic [jedec_p::BLK_CNT_WIDTH - 1 : 0] dath_blk_cnt;
	logic [11 : 0] blksize;
	assign blksize = 512;

	sd_data_8bit_host sd_data_8bit_host_inst (
		.sd_clk(sd_clk),
		.sys_rst(arst_i),
		.tx_dat_i(dat_i),
		.tx_dat_rd_o(dath_tx_dat_rd),
		.rx_dat_o(dat_o),
		.rx_dat_we_o(dath_rx_dat_we),
		.sd_dat_siz_o(emmc_dat_siz_o),
		.sd_dat_oe_o(emmc_dat_oe_o),
		.sd_dat_o(emmc_dat_o),
		.sd_dat_i(emmc_dat_i),
		.blksize_i(blksize),
		.bus_size_i(dath_bus_size),
		.blkcnt_i(dath_blk_cnt),
		.d_stop_i(dath_stop),
		.d_read_i(dath_read),
		.d_write_i(dath_write),
		.bustest_w_i(1'b0),
		.bustest_r_i(1'b0),
		.bustest_res_o(),
		.sd_dat_busy_o(dath_busy),
		.fsm_busy_o(dath_fsm_busy),
		.crc_ok_o(dath_crc_ok)
	);

	logic [$clog2(4096) : 0] mp_cntr;
	logic mp_cntr_rst;
	logic mp_cntr_enbl;
	always_ff @(posedge clk_i or posedge arst_i) begin
		if(arst_i)            mp_cntr <= 0;
		else if(mp_cntr_rst)  mp_cntr <= 0;
		else if(mp_cntr_enbl) mp_cntr <= mp_cntr + 1;
	end
	function void mp_cntr_use(logic cond);
		mp_cntr_rst = 0;
		mp_cntr_enbl = cond;
	endfunction

	emmc_sm_p::state_t orig_state_pend;
	emmc_sm_p::state_t orig_state;
	emmc_sm_p::state_t curr_state;
	emmc_sm_p::state_t next_state;
	logic state_change_enbl;
	logic state_changed;
	always_ff @(posedge clk_i) state_changed <= state_change_enbl;

	assign cmdh_int_rst = state_change_enbl;

	logic dath_busy_d1;
	logic dath_busy_d2;
	logic dath_fsm_busy_d1;
	always @(posedge clk_i) {dath_busy_d1, dath_busy_d2, dath_fsm_busy_d1} <= {dath_busy, dath_busy_d1, dath_fsm_busy};
	logic card_not_busy_pulse;
	logic fsm_dat_not_busy;
	assign {card_not_busy_pulse, fsm_dat_not_busy} = {~dath_busy_d1 & dath_busy_d2, ~dath_fsm_busy & dath_fsm_busy_d1};

	logic sel_clk_o_pend;
	logic [1 : 0] bus_size_pend;
	logic enbl_clk_change;
	logic enbl_bus_size_change;
	always @(posedge clk_i or posedge arst_i) begin
		if(arst_i) sel_clk_o <= '0;
		else begin
			if(enbl_clk_change)      sel_clk_o <= sel_clk_o_pend;
			if(enbl_bus_size_change) dath_bus_size <= bus_size_pend;
		end
	end

	logic [31 : 0] rdwr_addr;
	always_ff @(posedge clk_i) if(curr_state == emmc_sm_p::DO_IDLE) rdwr_addr <= blk_idx_i;

	always_comb begin
		mp_cntr_use(0);
		wr_enbl_of_reg = '0;
		next_state = emmc_sm_p::INIT_START;
		state_change_enbl = '0;
		orig_state_pend = curr_state;
		mp_cntr_rst = 1;
		cmdh_cmd_info = '0;
		cmdh_start = '0;
		dath_stop = 0;
		dath_read = '0;
		dath_write = '0;
		sel_clk_o_pend = '0;
		enbl_clk_change = '0;
		bus_size_pend = '0;
		enbl_bus_size_change = '0;
		case (curr_state)
			emmc_sm_p::WAIT_CMD: begin
				// State change is enabled then CMD was received propertly
				state_change_enbl = cmdh_int_status.cc;
				case (orig_state)
					emmc_sm_p::INIT_IDLE: begin
						next_state = emmc_sm_p::INIT_READY;
					end
					emmc_sm_p::INIT_READY: begin
						next_state = cmdh_response_0[31] ? emmc_sm_p::INIT_IDENT : orig_state; // 32'hC0FF8080
					end
					emmc_sm_p::INIT_IDENT: begin
						jedec_p::cid_t cid;
						wr_enbl_of_reg[CID] = 1;
						cid = {cmdh_response_0, cmdh_response_1, cmdh_response_2, cmdh_response_3};
						if(___SIMULATION___) begin
							next_state = emmc_sm_p::INIT_STBY;
						end else begin
							if(cid.mid == 8'h70) next_state = emmc_sm_p::INIT_STBY;
							else                 next_state = emmc_sm_p::INIT_IDENT;
						end
					end
					emmc_sm_p::INIT_STBY: begin
						next_state = emmc_sm_p::INIT_GET_CSD;
						wr_enbl_of_reg[CARD_STATUS] = state_change_enbl;
					end
					emmc_sm_p::INIT_GET_CSD: begin
						next_state = emmc_sm_p::INIT_TRAN;
						wr_enbl_of_reg[CSD] = 1;
					end
					emmc_sm_p::INIT_TRAN: begin
						next_state = emmc_sm_p::INIT_GET_CSD_EXT;
						wr_enbl_of_reg[CARD_STATUS] = state_change_enbl;
					end
					// wait for cmd to wait for busy
					emmc_sm_p::INIT_GO_FAST,
					emmc_sm_p::INIT_SET_DWIDTH: begin
						next_state = emmc_sm_p::WAIT_BUSY;
						orig_state_pend = orig_state;
						wr_enbl_of_reg[CARD_STATUS] = state_change_enbl;
					end
					// wait for cmd to wait for dat
					emmc_sm_p::INIT_GET_CSD_EXT,
					emmc_sm_p::DO_SBLK_READ,
					emmc_sm_p::DO_MBLK_READ: begin
						next_state = emmc_sm_p::WAIT_DAT;
						orig_state_pend = orig_state;
						// The next line of code should be here and not in WAIT_DAT state description
						// The reason fot that is if it was in the WAIT_DAT state, and card responded with data quickly enough,
						// it would be a situation when host isn't ready for data receive
						// Here we are getting the host ready to receive a data preemptively
						dath_read = state_changed;
						wr_enbl_of_reg[CARD_STATUS] = state_change_enbl;
					end
					emmc_sm_p::DO_SBLK_WRITE,
					emmc_sm_p::DO_MBLK_WRITE: begin
						next_state = emmc_sm_p::WAIT_DAT;
						orig_state_pend = orig_state;
						wr_enbl_of_reg[CARD_STATUS] = state_change_enbl;
					end
					emmc_sm_p::DO_STOP_WRITE_TRANSACT: begin
						next_state = emmc_sm_p::WAIT_BUSY;
						orig_state_pend = orig_state;
					end
					emmc_sm_p::DO_STOP_READ_TRANSACT: begin
						next_state = emmc_sm_p::DO_IDLE;
						wr_enbl_of_reg[CARD_STATUS] = state_change_enbl;
					end
					default: begin
						next_state = emmc_sm_p::ERR;
					end
				endcase
			end
			emmc_sm_p::WAIT_DAT: begin
				state_change_enbl = fsm_dat_not_busy & dath_crc_ok;
				case(orig_state)
					emmc_sm_p::INIT_GET_CSD_EXT: begin
						wr_enbl_of_reg[EXT_CSD] = dvalid_o;
						next_state = emmc_sm_p::INIT_GO_FAST;
					end
					emmc_sm_p::DO_SBLK_WRITE: begin
						next_state = emmc_sm_p::DO_IDLE;
						dath_write = state_changed;
					end
					emmc_sm_p::DO_MBLK_WRITE: begin
						next_state = emmc_sm_p::DO_STOP_WRITE_TRANSACT;
						dath_write = state_changed;
					end
					emmc_sm_p::DO_SBLK_READ: begin
						next_state = emmc_sm_p::DO_IDLE;
						dath_read = state_changed;
					end
					emmc_sm_p::DO_MBLK_READ: begin
						next_state = emmc_sm_p::DO_STOP_READ_TRANSACT;
						dath_read = state_changed;
					end
					default: begin
						next_state = emmc_sm_p::ERR;
					end
				endcase
			end
			emmc_sm_p::WAIT_BUSY: begin
				state_change_enbl = card_not_busy_pulse;
				case (orig_state)
					emmc_sm_p::INIT_GO_FAST: begin
						next_state = emmc_sm_p::INIT_SET_DWIDTH;
						sel_clk_o_pend = 1;
						enbl_clk_change = state_change_enbl;
					end
					emmc_sm_p::INIT_SET_DWIDTH: begin
						next_state = emmc_sm_p::DO_IDLE;
						bus_size_pend = 2'b10;
						enbl_bus_size_change = 1;
					end
					emmc_sm_p::DO_STOP_WRITE_TRANSACT: begin
						next_state = emmc_sm_p::DO_IDLE;
					end
					default: begin
						next_state = emmc_sm_p::ERR;
					end
				endcase
			end
			emmc_sm_p::INIT_START: begin
				next_state = emmc_sm_p::INIT_IDLE;
				state_change_enbl = mp_cntr > 450;
				mp_cntr_use(1);
			end
			emmc_sm_p::INIT_IDLE: begin
				`__SETUP_WAIT_FOR_CMD__(0, 0);
			end
			emmc_sm_p::INIT_READY: begin
				`__SETUP_WAIT_FOR_CMD__(1, 32'h40FF8080);
			end
			emmc_sm_p::INIT_IDENT: begin
				`__SETUP_WAIT_FOR_CMD__(2, 0);
			end
			emmc_sm_p::INIT_STBY: begin
				`__SETUP_WAIT_FOR_CMD__(3, CARD_ADDR_ARG);
			end
			emmc_sm_p::INIT_GET_CSD: begin
				`__SETUP_WAIT_FOR_CMD__(9, CARD_ADDR_ARG);
			end
			emmc_sm_p::INIT_TRAN: begin
				`__SETUP_WAIT_FOR_CMD__(7, CARD_ADDR_ARG);
			end
			emmc_sm_p::INIT_GET_CSD_EXT: begin
				`__SETUP_WAIT_FOR_CMD__(8, 0);
			end
			emmc_sm_p::INIT_GO_FAST: begin // *
				`__SETUP_WAIT_FOR_CMD__(6, 32'h03b90100); // See Annex A8.2.24 in JEDEC eMMC Std v4.41
			end
			emmc_sm_p::INIT_SET_DWIDTH: begin // *
				`__SETUP_WAIT_FOR_CMD__(6, 32'h03B70200); // See Annex A8.3.36 in JEDEC eMMC Std v4.41
			end
			emmc_sm_p::DO_IDLE: begin
				if(blk_cnt_i == 0)      next_state = emmc_sm_p::DO_IDLE;
				else if(blk_cnt_i == 1) next_state = we_i ? emmc_sm_p::DO_SBLK_WRITE : emmc_sm_p::DO_SBLK_READ;
				else                    next_state = we_i ? emmc_sm_p::DO_MBLK_WRITE : emmc_sm_p::DO_MBLK_READ;
				state_change_enbl = start_i;
			end
			emmc_sm_p::DO_SBLK_WRITE: begin // **
				`__SETUP_WAIT_FOR_CMD__(24, rdwr_addr);
			end
			emmc_sm_p::DO_SBLK_READ: begin // **
				`__SETUP_WAIT_FOR_CMD__(17, rdwr_addr);
			end
			emmc_sm_p::DO_MBLK_WRITE: begin // **
				`__SETUP_WAIT_FOR_CMD__(25, 0);
			end
			emmc_sm_p::DO_MBLK_READ: begin // **
				`__SETUP_WAIT_FOR_CMD__(18, 0);
			end
			emmc_sm_p::DO_STOP_WRITE_TRANSACT: begin
				`__SETUP_WAIT_FOR_CMD__(12, 0);
			end
			emmc_sm_p::DO_STOP_READ_TRANSACT: begin
				`__SETUP_WAIT_FOR_CMD__(12, 0);
			end
			emmc_sm_p::DO_NOTHING: begin
				next_state = emmc_sm_p::DO_NOTHING;
				state_change_enbl = 0;
			end
		endcase
	end
	// *  - Current state switches to WAIT_CMD state, then to WAIT_BUSY state, and after that returns back to current state
	// ** - Current state switches to WAIT_CMD state, then to WAIT_DAT state, and after that returns back to current state

	always_ff @(posedge clk_i or posedge arst_i) begin
		if(arst_i)                 {orig_state, curr_state} <= {emmc_sm_p::INIT_START, emmc_sm_p::INIT_START};
		else if(state_change_enbl) {orig_state, curr_state} <= {orig_state_pend, next_state};
	end

	assign emmc_clk_o_pad = sd_clk;

	logic dath_tx_dat_rd_d1;
	always_ff @(posedge clk_i) dath_tx_dat_rd_d1 <= dath_tx_dat_rd;

	assign dvalid_o = dath_tx_dat_rd_d1 | dath_tx_dat_rd | dath_rx_dat_we;
	assign ready_o = curr_state == emmc_sm_p::DO_IDLE;

	always_ff @(posedge clk_i) begin
		if(curr_state == emmc_sm_p::INIT_GET_CSD_EXT) dath_blk_cnt <= 1;
		else if(curr_state == emmc_sm_p::DO_IDLE)     dath_blk_cnt <= blk_cnt_i;
	end

endmodule
