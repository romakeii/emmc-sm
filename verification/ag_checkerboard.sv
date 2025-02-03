module ag_checkerboard #(
	parameter int unsigned WIDTH = 8,
	parameter int unsigned LENGTH = 512,
	parameter logic INVERT_VALUES = 0
) (
	input logic clk_i,
	input logic srst_i,
	input logic enbl_i,
	output logic finished_o,
	output logic [WIDTH - 1 : 0] wr_data_o,
	output logic wr_enbl_o

);

	localparam logic [WIDTH - 1 : 0] INITIAL_VALUE = INVERT_VALUES ? 'h55555555 : 'haaaaaaaa;

	logic [$clog2(LENGTH) - 1 : 0] work_counter;
	logic [1 : 0] cycle_counter;
	logic work_counter_has_max_val;
	assign work_counter_has_max_val = work_counter == (LENGTH - 1);
	always_ff @(posedge clk_i) begin
		if(srst_i) begin
			work_counter <= 0;
			cycle_counter <= 0;
			wr_enbl_o <= 1;
		end else if(enbl_i) begin
			if(work_counter_has_max_val) begin
				work_counter <= 0;
				cycle_counter <= cycle_counter + 1;
				wr_enbl_o <= ~wr_enbl_o;
			end else begin
				work_counter <= work_counter + 1;
			end
		end
	end

	always_comb begin
		if(work_counter[0] == 0) wr_data_o = cycle_counter[1] == 0 ? INITIAL_VALUE : ~INITIAL_VALUE;
		else                     wr_data_o = cycle_counter[1] == 0 ? ~INITIAL_VALUE : INITIAL_VALUE;
	end
	assign finished_o = &cycle_counter & work_counter_has_max_val; // i.e. == 1 when cycle counter == 3 & cwork_counter_has_max_val

endmodule