//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Decoder.v
//Description:	Index Decode
//Version:		0.1
//=====================================
`include "def.v"

module Decoder(
	clk,
	rst,
	en,
	Data_in,
	Index
);

	input clk;
	input rst;
	input en;
	input signed [`INTERNAL_BITS-1:0] Data_in;
	output [`INTERNAL_BITS-1:0] Index;

//complete your design here

	reg signed[`INTERNAL_BITS-1:0] maximum;
	reg [`INTERNAL_BITS-1:0] Index;
	reg [`INTERNAL_BITS-1:0] counter;
always@(posedge clk or posedge rst) begin
	if(rst) begin
		maximum <= 32'd0;
		counter <= 32'd0;
		
	end	
	else if(en) begin
		counter <= counter + 32'd1;	
		if(counter == 4'd0) begin
			maximum <= Data_in;
			Index <= counter;
		end
		
		else if(Data_in > maximum) begin
			maximum <= Data_in;
			Index <= counter;
			
		end
		
		
	end	
	
end



endmodule
