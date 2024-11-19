`ifndef MFTYWDZPHP
`define MFTYWDZPHP

`timescale 1ps/1ps

`include "emmc_sm.svh"

task automatic clk_gen(ref logic clk, input real period);
	clk = '0;
	forever begin
		#(period / 2);
		clk = ~clk;
	end
endtask

task automatic rst_gen(ref logic rst, ref logic clk);
	rst = '1;
	@(clk);
	rst = '0;
endtask

`endif
