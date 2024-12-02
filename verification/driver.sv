module driver (
	input logic clk_i,
	input logic arst_i,
	input logic host_ready,
	output logic host_we,
	output logic host_start,
	output logic host_wr_dat
);

	assign host_start = 1;
	always_ff @(posedge clk_i or posedge arst_i) begin
		if(arst_i) begin
			host_we <= '1;
			host_wr_dat <= 'h55;
		end else if(host_ready) begin
			host_we <= ~host_we;
			if(host_we) host_wr_dat <= ~host_wr_dat; // preparing next value to be written
		end
	end

endmodule
