//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Pooling.v
//Description:	Max Pooling Operation
//Version:		0.1
//=====================================
`include "def.v"

module Pooling(
	clk,
	rst,
	en,
	Data_in,
	Data_out
);

	input clk;
	input rst;
	input en;
	input [`INTERNAL_BITS-1:0] Data_in;
	output [`INTERNAL_BITS-1:0] Data_out;

//complete your design here
	reg [`INTERNAL_BITS-1:0] poolmax;
	reg [1:0] counter;
	reg [`INTERNAL_BITS-1:0] Data_out;
	
always@(posedge clk or posedge rst) begin

	if(rst) begin
		poolmax <= 32'd0;
		counter <= 2'd0;
	end
	else if(en) begin
		
		if(counter == 2'd0) begin
			poolmax <= Data_in;
		end	
		
		else if(Data_in > poolmax) begin
			poolmax <= Data_in;
		end
		else;
		if(counter == 2'd3) begin
			counter <= 2'd0;
		end
		else begin
			counter <= counter + 2'd1;
		end	

		
	end
end

always@(*) begin
	Data_out = poolmax;
end	

endmodule
