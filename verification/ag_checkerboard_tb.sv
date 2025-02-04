module ag_checkerboard_tb;

	localparam WIDTH = 8;
	localparam LENGTH = 8;

	logic clk_i;
	logic srst_i;
	logic enbl_i;
	logic started_all_o;
	logic started_part_o;
	logic [WIDTH - 1 : 0] wr_data_o;
	logic wr_enbl_o;

	ag_checkerboard #(
		.WIDTH(WIDTH),
		.LENGTH(LENGTH),
		.INVERT_VALUES(0)
	) uut (
		.*
	);

	initial begin
		clk_i = 0;
		forever begin
			#8 clk_i = ~clk_i;
		end
	end

	initial begin
		srst_i = 1;
		#16;
		@(posedge clk_i);
		srst_i = 0;
	end

	assign enbl_i = 1;

endmodule
