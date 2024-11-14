module clkdiv #(
	parameter int unsigned FACTOR = 5
) (
	input logic clk_i,
	output logic clk_o
);

	generate

		if(FACTOR == 1) begin

			assign clk_o = clk_i;

		end else begin

			logic [$clog2(FACTOR) - 1 : 0] counter = '0;
			always_ff @(posedge clk_i) begin
				if(counter == (FACTOR - 1)) counter <= '0;
				else                        counter <= counter + 1'b1;
			end

			localparam logic IS_ODD = (FACTOR % 2) != '0;

			if(IS_ODD) begin

				localparam int unsigned MID_VAL = (FACTOR - 1) / 2;

				logic mid_val_pulse;
				assign mid_val_pulse = counter == MID_VAL;

				logic neg_mid_val_pulse_nck;
				logic neg_mid_val_pulse_nck_d1;
				always_ff @(negedge clk_i) begin
					neg_mid_val_pulse_nck <=    ~mid_val_pulse;
					neg_mid_val_pulse_nck_d1 <= neg_mid_val_pulse_nck;
				end

				logic le_mid_val;
				logic le_mid_val_d1;
				assign le_mid_val = counter <= MID_VAL;
				always_ff @(posedge clk_i) le_mid_val_d1 <= le_mid_val;

				assign clk_o = le_mid_val_d1 & neg_mid_val_pulse_nck_d1;

			end else begin

				logic switch;
				assign switch = (counter == FACTOR / 2 - 1) | (counter == FACTOR - 1);

				logic clk = 1'b0;
				always_ff @(posedge clk_i) if(switch) clk <= ~clk;

				assign clk_o = clk;

			end

		end

	endgenerate

endmodule
