//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		PE.v
//Description:	MAC Operation
//Version:		0.1
//=====================================
`include "def.v"

module PE( 
	clk,
	rst,
	IF_w,
	W_w,
	IF_in,
	W_in,
	Result
);

	input clk;
	input rst;
	input IF_w,W_w;
	input signed[`DATA_BITS-1:0] IF_in,W_in;
	output signed[`INTERNAL_BITS-1:0] Result;

//complete your design here
	reg signed [`DATA_BITS-1:0] Weight[2:0];
	reg signed[`DATA_BITS-1:0] Feature[2:0];
	reg signed[`INTERNAL_BITS-1:0] Result;
	
	integer i;
	
always@(posedge clk or posedge rst) begin

	if(rst) begin
		for(i = 0; i < 3; i = i + 1) begin
			Weight[i] <= 16'b0;
			Feature[i] <= 16'b0;
		end
	end	
	else begin
		if(W_w) begin
			Weight[0] <= W_in;
			for(i = 0; i < 2; i = i + 1) 
				Weight[i+1] <= Weight[i];
			end
		else;
		if(IF_w) begin
			Feature[0] <= IF_in;
			for(i = 0; i < 2; i = i + 1)
				Feature[i+1] <= Feature[i];
		end
		else;
	end
end

always@(*) begin
	Result = Weight[0] * Feature[0] + Weight[1] * Feature[1] + Weight[2] * Feature[2] ;	
end
	
endmodule
