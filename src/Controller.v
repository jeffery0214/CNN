//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Controller.v
//Description:	Controller
//Version:		0.1
//=====================================
`include "def.v"

module Controller(
	clk,
	rst,
	START,
	DONE,
	//ROM
	ROM_IM_CS,ROM_W_CS,ROM_B_CS,
	ROM_IM_OE,ROM_W_OE,ROM_B_OE,
	ROM_IM_A,ROM_W_A,ROM_B_A,
	//SRAM
	SRAM_CENA,SRAM_CENB,
	SRAM_WENB,
	SRAM_AA,SRAM_AB,
	//PE
	PE1_IF_w,PE2_IF_w,PE3_IF_w,
	PE1_W_w,PE2_W_w,PE3_W_w,
	//Pooling
	Pool_en,
	//Decoder
	Decode_en,
	//Adder
	Adder_mode,
	//MUX
	MUX1_sel,MUX2_sel,MUX3_sel
);

	input clk;
	input rst;
	input START;
	output DONE;
	output ROM_IM_CS,ROM_W_CS,ROM_B_CS;
	output ROM_IM_OE,ROM_W_OE,ROM_B_OE;
	output [`ROM_IM_ADDR_BITS-1:0] ROM_IM_A;
	output [`ROM_W_ADDR_BITS-1:0] ROM_W_A;
	output [`ROM_B_ADDR_BITS-1:0] ROM_B_A;
	output SRAM_CENA,SRAM_CENB;
	output SRAM_WENB;
	output [`SRAM_ADDR_BITS-1:0] SRAM_AA,SRAM_AB;
	output PE1_IF_w,PE2_IF_w,PE3_IF_w;
	output PE1_W_w,PE2_W_w,PE3_W_w;
	output Pool_en; 
	output Decode_en;
	output [1:0] Adder_mode;
	output [1:0] MUX2_sel;
	output MUX1_sel,MUX3_sel; 

//complete your design here
	parameter INIT = 4'b0,
			  READC_W = 4'b0001,
			  READC_C = 4'b0010,
			  READC_9 = 4'b0011,
			  WRITEC = 4'b0100,
			  READP = 4'b0101,
			  WRITEP = 4'b0110,
			  READF = 4'b0111,
			  WRITEF = 4'b1000,
			  DECODE_R = 4'b1001,
			  DECODE_W = 4'b1010,
			  OVER = 4'b1011;
				



	reg [3:0] state, n_state;
	reg [3:0] counter;
	reg [4:0] row;
	reg [4:0] column;
	reg conv;
	reg [`ROM_W_ADDR_BITS-1:0] InitW_A;
	reg [`SRAM_ADDR_BITS-1:0] Init_AA, Init_AB;
	reg [3:0] filter;
	reg [5:0] filter_mass;
	reg [2:0] channel;
	reg [4:0] RCNum;
	reg [9:0] FCNum;
	reg pool;
	reg [3:0] pool_N;
	reg FC;
	reg [9:0] FC_L;
	reg [7:0] FC_R;
	reg [`ROM_B_ADDR_BITS-1:0] tB_A;
	reg [2:0] tPE_W;
	reg [2:0] tPE_IF;

	
	reg ROM_IM_CS,ROM_W_CS,ROM_B_CS;
	reg ROM_IM_OE,ROM_W_OE,ROM_B_OE;
	reg [`ROM_IM_ADDR_BITS-1:0] ROM_IM_A;
	reg [`ROM_W_ADDR_BITS-1:0] ROM_W_A;
	reg [`ROM_B_ADDR_BITS-1:0] ROM_B_A;
	reg SRAM_CENA,SRAM_CENB;
	reg SRAM_WENB;
	reg [`SRAM_ADDR_BITS-1:0] SRAM_AA,SRAM_AB;
	reg PE1_IF_w,PE2_IF_w,PE3_IF_w;
	reg PE1_W_w,PE2_W_w,PE3_W_w;
	reg Pool_en; 
	reg Decode_en;
	reg [1:0] Adder_mode;
	reg [1:0] MUX2_sel;
	reg MUX1_sel,MUX3_sel;
	reg DONE;


always@(posedge START or posedge clk) begin
	if(START) begin
		state <= INIT;
	end
	else begin
		state <= n_state;
	end
end
	
always@(posedge rst or posedge clk) begin
	if(rst) begin
		row <= 5'd0;
		column <= 5'd0;
		FC_L <= 10'd0;
	end
	else begin
		if((state == READC_W) || (state == READC_9)) begin
			if((counter == 4'd2) || (counter == 4'd5) || (counter == 4'd8)) begin
				row <= row - 5'd2;
				column <= column + 5'd1;	
			end
			else if((counter == 4'd9) || (counter == 4'd10));
			else begin
				row <= row + 5'd1;
			end
		end
		
		else if(state == READC_C) begin
			if(counter == 4'd2) begin
				if(column == RCNum - 1) begin
				
					row <= row - 5'd1;
					column <= 5'd0;
				end
				else begin
					row <= row - 5'd2;
					column <= column + 5'd1;
				end
			end
			else if((counter == 4'd3) || (counter == 4'd4));
			else begin
				row <= row + 5'd1;
			end
		end
		
		else if(state == WRITEC) begin
			if((row == RCNum - 5'd2) && (column == 5'd0)) begin
				row <= 5'd0;
			end	
		end
		
		else if(state == READP) begin
			if(counter == 4'd1) begin
				row <= row - 5'd1;
				column <= column + 5'd1;
			end
			else if(counter == 4'd3) begin
				if(column == RCNum - 5'd1) begin
					row <= row + 5'd1;
					column <= 5'd0;
				end
				else begin
					row <= row - 5'd1;
					column <= column + 5'd1;

				end
			end
			else if(counter == 4'd4);	
			else begin
				row <= row + 5'd1;
			end
		end
		
		else if(state == WRITEP) begin
			if((row == RCNum) && (column == 5'd0)) begin
				row <= 5'd0;
			end
		end
		
		else if(state == READF) begin
			if((counter == 4'd9));
			else begin
				FC_L <= FC_L + 10'd1;
			end	
		end
		
		else if(state == WRITEF) begin
			if(FC_L == FCNum) begin
				FC_L <= 10'd0;
			end
		end	
		
	end
end

always@(posedge rst or posedge clk) begin
	if(rst) begin
		counter <= 4'd0;
	end
	
	else begin	
		if((state == READC_W) || (state == READC_9)) begin
			if(conv == 1'd0) begin
				if(counter == 4'd9) begin
					counter <= 4'd0;
				end
				else begin
					counter <= counter + 4'd1;
				end
			end
			else if(conv == 1'd1) begin
				if(counter == 4'd9) begin
					counter <= 4'd0;
				end
				else begin
					counter <= counter + 4'd1;
				end
			end
		end
			
		else if(state == READC_C) begin
			if(conv == 1'd0) begin
				if(counter == 4'd3) begin
					counter <= 4'd0;
				end
				else begin
					counter <= counter + 4'd1;
				end
			end
			else if(conv == 1'd1) begin
				if(counter == 4'd3) begin
					counter <= 4'd0;
				end
				else begin
					counter <= counter + 4'd1;
				end
			end
		end
		
		else if(state == READP) begin
			if(counter == 4'd4) begin
				counter <= 4'd0;
			end
			else begin
				counter <= counter + 4'd1;
			end
		end
		else if(state == READF) begin
			if(counter == 4'd9) begin
				counter <= 4'd0;
			end
			else begin
				counter <= counter + 4'd1;
			end
		end
		else if(state == DECODE_R) begin
			if(counter == 4'd10) begin
				counter <= 4'd0;
			end
			else begin
				counter <= counter + 4'd1;
			end
		end
	end	
		
end

always@(posedge rst or posedge clk) begin
	if(rst) begin
		conv <= 1'd0;
		filter <= 4'd0;
		filter_mass <= 6'd0;
		channel <= 3'd0;
		pool <= 1'd0;
		pool_N <= 4'd0;
		FC <= 1'd0;
		FC_R <= 8'd0;
		RCNum <= 5'd0;
		FCNum <= 10'd0;
		tB_A <= 8'd0;
	end
	
	else begin
		if(state == INIT) begin
			filter_mass <= 6'd9;
			RCNum <= 5'd30;
			FCNum <= 10'd540;
		end	
		else if(state == WRITEC) begin
			if((conv == 1'd0) && (row == RCNum - 5'd2) && (column == 5'd0)) begin
				
				if(filter == 4'd5) begin
					filter <= 4'd0;
					conv <= 1'd1;
					RCNum <= 5'd28;
					filter_mass <= 6'd54;
					tB_A <= tB_A + 8'd1;
				end
				else begin	
					filter <= filter + 4'd1;
					tB_A <= tB_A + 8'd1;
				end
				
			end
			else if((conv == 1'd1) && (row == RCNum - 5'd2) && (column == 5'd0)) begin
				if(channel == 3'd5) begin
					filter <= filter + 4'd1;
					tB_A <= tB_A + 8'd1;
					channel <= 3'd0;
				end
				else begin
					channel <= channel + 3'd1;
				end
				if((filter == 4'd14) && (channel == 3'd5)) begin
					filter <= 4'd0;
					RCNum <= 5'd12;
					tB_A <= tB_A + 8'd1;
				end
				
			end	
		end
		else if(state == WRITEP) begin
			if((pool == 1'd0) && (row == RCNum) && (column == 5'd0)) begin
				if(pool_N == 4'd5) begin
					pool_N <= 4'd0;
					pool <= 1'd1;
					RCNum <= 5'd14;
				end
				else begin
					pool_N <= pool_N + 4'd1;
				end
			end
			else if((pool == 1'd1) && (row == RCNum) && (column == 5'd0)) begin
				if(pool_N == 4'd14) begin
					pool_N <= 4'd0;
					RCNum <= 5'd6;
				end
				else begin
					pool_N <= pool_N + 4'd1;
				end	
			end
		end
		else if(state == WRITEF) begin
			if((FC == 1'd0) && (FC_L == FCNum)) begin
				if(FC_R == 8'd179) begin
					FC <= 1'd1;
					FC_R <= 8'd0;
					FCNum <= 10'd180;
					tB_A <= tB_A + 8'd1;
				end
				else begin
					FC_R <= FC_R + 8'd1;
					tB_A <= tB_A + 8'd1;
				end	
			end	
			else if((FC == 1'd1) && (FC_L == FCNum)) begin
				if(FC_R == 8'd9) begin
					FC_R <= 8'd0;
					FCNum <= 10'd10;
					tB_A <= tB_A + 8'd1;
				end
				else begin 
					FC_R <= FC_R + 8'd1;
					tB_A <= tB_A + 8'd1;
				end
			end
		end
	end
end	

always@(posedge rst or posedge clk) begin
	if(rst) begin
		tPE_IF <= 3'b0;
		tPE_W <= 3'b0;
	end
	else begin
		if(state == INIT) begin
			tPE_IF <= 3'b0;
			tPE_W <= 3'b0;
		end
		else if((state == READC_W) || (state == READF)) begin
			if((counter == 4'd0) || (counter == 4'd3) || (counter == 4'd6)) begin
				tPE_IF <= 3'b100;
				tPE_W <= 3'b100;
			end
			else if((counter == 4'd1) || (counter == 4'd4) || (counter == 4'd7)) begin
				tPE_IF <= 3'b010;
				tPE_W <= 3'b010;
			end
			else if((counter == 4'd2) || (counter == 4'd5) || (counter == 4'd8)) begin
				tPE_IF <= 3'b001;
				tPE_W <= 3'b001;
			end
			else begin
				tPE_IF <= 3'b0;
				tPE_W <= 3'b0;
			end
		end
		else if(state == READC_9) begin
			if((counter == 4'd0) || (counter == 4'd3) || (counter == 4'd6)) begin
				tPE_IF <= 3'b100;
				tPE_W <= 3'b0;
			end
			else if((counter == 4'd1) || (counter == 4'd4) || (counter == 4'd7)) begin
				tPE_IF <= 3'b010;
				tPE_W <= 3'b0;
			end
			else if((counter == 4'd2) || (counter == 4'd5) || (counter == 4'd8)) begin
				tPE_IF <= 3'b001;
				tPE_W <= 3'b0;
			end
			else begin
				tPE_IF <= 3'b0;
				tPE_W <= 3'b0;
			end
		end	
		else if((state == READC_C)) begin
			if((counter == 4'd0)) begin
				tPE_IF <= 3'b100;
				tPE_W <= 3'b0;
			end
			else if((counter == 4'd1)) begin
				tPE_IF <= 3'b010;
				tPE_W <= 3'b0;
			end
			else if((counter == 4'd2)) begin
				tPE_IF <= 3'b001;
				tPE_W <= 3'b0;
			end
			else begin
				tPE_IF <= 3'b0;
				tPE_W <= 3'b0;
			end
		end
		else if((state == WRITEC) || (state == WRITEF) || (state == WRITEP) || (state == READP) ) begin
				tPE_IF <= 3'b0;
				tPE_W <= 3'b0;
		end		
		
	end	
end

always@(*) begin

case(state)
INIT: begin
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	SRAM_CENA = 1'b0;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b0;
	MUX3_sel = 1'b0;
	Adder_mode = 2'b10;
	Pool_en = 1'b0;
	Decode_en = 1'b0;
	DONE = 1'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = 3'b0;
	{PE1_W_w, PE2_W_w, PE3_W_w} = 3'b0;
	SRAM_AA = 13'd0;
	SRAM_AB = 13'd0;
	ROM_B_A = 8'b0;
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	n_state = READC_W;
end
READC_W: begin
	ROM_B_CS = 1'b1;
	ROM_B_OE = 1'b1;
	ROM_W_CS = 1'b1;
	ROM_W_OE = 1'b1;
	Pool_en = 1'b0;
	Decode_en = 1'b0;
	DONE = 1'b0;
	
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	ROM_B_A = tB_A;
	SRAM_AB = 13'b0;
	if(conv == 1'd0) begin
		SRAM_CENA = 1'b0;
		MUX2_sel = 2'b0;
		MUX3_sel = 1'b1;
		Adder_mode = 2'b10;
		MUX1_sel = 1'b0;
		ROM_IM_CS = 1'b1;
		ROM_IM_OE = 1'b1;
		SRAM_AA = 13'b0;
		if(counter == 4'd9)begin
			n_state = WRITEC;
			ROM_IM_A = row*RCNum + column;
			ROM_W_A = 3*row + column + filter*filter_mass;
		end
		else begin
			ROM_IM_A = row*RCNum + column;
			ROM_W_A = 3*row + column + filter*filter_mass;
			n_state = READC_W;			
		end	
	end	
	else begin
		if(channel == 5'd0) begin
			Adder_mode = 2'b0;
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b1;
		end	
		else if(channel == 5'd5) begin
			MUX2_sel = 2'b0;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b10;
			
		end
		else begin
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b01;
		end
		SRAM_CENA = 1'b1;
		MUX1_sel = 1'b1;
		ROM_IM_CS = 1'b0;
		ROM_IM_OE = 1'b0;
		ROM_IM_A = 10'b0;
		
	    if(counter == 4'd9) begin
			SRAM_AA = row*12 + (column - 3) + filter*(RCNum-2)*(RCNum-2);
			ROM_W_A = 17'd54 + 3*row + column + filter*filter_mass + channel*9;
			n_state = WRITEC;
		end
		else begin	
			SRAM_AA = 13'd4704 + row*RCNum + column + channel*RCNum*RCNum;
			ROM_W_A = 17'd54 + 3*row + column + filter*filter_mass + channel*9;
			n_state = READC_W;
		end	
	end
	
	
	
end
WRITEC: begin
	ROM_B_CS = 1'b1;
	ROM_B_OE = 1'b1;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	Decode_en = 1'b0;	
	Pool_en = 1'b0;	
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	ROM_B_A = tB_A;
	SRAM_CENB = 1'b1;
	SRAM_WENB = 1'b1;
	SRAM_CENA = 1'b0;
	DONE = 1'b0;
	ROM_W_A = 17'd0;
	
	if(conv == 1'd0) begin
		MUX2_sel = 2'b0;
		MUX3_sel = 1'b1;
		Adder_mode = 2'b10;
		MUX1_sel = 1'b0;
		ROM_IM_CS = 1'b1;
		ROM_IM_OE = 1'b1;
		SRAM_AA = 13'b0;
		ROM_IM_A = row*RCNum + column;
		if(column == 5'd0) begin
			SRAM_AB = (row - 1)*28 + 13'd27 + filter*(RCNum-2)*(RCNum-2);
			if(row == RCNum-2) begin
				if(filter == 4'd5) begin

					n_state = READP;
				end
				else begin
					n_state = READC_W;
				end	
			end
			else begin
				n_state = READC_9;
			end
		end
		else begin
			SRAM_AB = row*28 + (column - 3) + filter*(RCNum-2)*(RCNum-2);
			n_state = READC_C;
		end	
			
			
	end
	else begin
		ROM_IM_CS = 1'b0;
		ROM_IM_OE = 1'b0;
		SRAM_CENA = 1'b1;
		MUX1_sel = 1'b1;
		ROM_IM_CS = 1'b0;
		ROM_IM_OE = 1'b0;
		ROM_IM_A = 10'b0;
		SRAM_AA = row*12 + (column - 3) + filter*(RCNum-2)*(RCNum-2);
		if(channel == 5'd0) begin
			Adder_mode = 2'b0;
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b1;
		end	
		else if(channel == 5'd5) begin
			MUX2_sel = 2'b0;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b10;
			
		end
		else begin
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b01;
		end
		if(column == 5'd0) begin
			SRAM_AB = (row - 1)*12 + 13'd11 + filter*(RCNum-2)*(RCNum-2);
			if(row == RCNum-2) begin
				if((filter == 4'd14) && (channel == 3'd5)) begin
					n_state = READP;
				end
				else begin
					n_state = READC_W;
				end	
			end
			else begin
				n_state = READC_9;
			end
		end
		else begin
			SRAM_AB = row*12 + (column - 3) + filter*(RCNum-2)*(RCNum-2);
			n_state = READC_C;
		end	
			
	end
	
	
end
READC_C: begin
	ROM_B_CS = 1'b1;
	ROM_B_OE = 1'b1;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	ROM_B_A = tB_A;
	Decode_en = 1'b0;
	Pool_en = 1'b0;
	
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	DONE = 1'b0;
	SRAM_AB = 13'b0;
	ROM_W_A = 17'd0;
	if(conv == 1'd0) begin
		SRAM_CENA = 1'b0;
		MUX2_sel = 2'b0;
		MUX3_sel = 1'b1;
		Adder_mode = 2'b10;
		MUX1_sel = 1'b0;
		ROM_IM_CS = 1'b1;
		ROM_IM_OE = 1'b1;
		SRAM_AA = 13'b0;
		if(counter == 4'd3)begin
			ROM_IM_A = row*RCNum + column;
			n_state = WRITEC;
		end
		else begin
			ROM_IM_A = row*RCNum + column;
			n_state = READC_C;			
		end	
	end	
	else begin
		if(channel == 5'd0) begin
			Adder_mode = 2'b0;
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b1;
		end	
		else if(channel == 5'd5) begin
			MUX2_sel = 2'b0;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b10;
			
		end
		else begin
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b01;
		end
		SRAM_CENA = 1'b1;
		MUX1_sel = 1'b1;
		ROM_IM_CS = 1'b0;
		ROM_IM_OE = 1'b0;
		ROM_IM_A = 10'b0;
		
		if(counter == 4'd3) begin
			n_state = WRITEC;
			if(column == 5'd0)  begin
				SRAM_AA = (row - 1)*12 + 13'd11 + filter*(RCNum-2)*(RCNum-2);
			end
			else begin	
				SRAM_AA = row*12 + (column - 3) + filter*(RCNum-2)*(RCNum-2);
			end	
			
		end
		else begin	
			SRAM_AA = 13'd4704 + row*RCNum + column + channel*RCNum*RCNum;
			n_state = READC_C;
		end	
	end
	
	
end

READC_9: begin
	ROM_B_CS = 1'b1;
	ROM_B_OE = 1'b1;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	Decode_en = 1'b0;
	Pool_en = 1'b0;
	DONE = 1'b0;
	
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	ROM_B_A = tB_A;
	SRAM_AB = 13'b0;
	ROM_W_A = 17'd0;
	if(conv == 1'd0) begin
		SRAM_CENA = 1'b0;
		MUX2_sel = 2'b0;
		MUX3_sel = 1'b1;
		Adder_mode = 2'b10;
		MUX1_sel = 1'b0;
		ROM_IM_CS = 1'b1;
		ROM_IM_OE = 1'b1;
		SRAM_AA = 13'b0;
		if(counter == 4'd9)begin
			n_state = WRITEC;
			ROM_IM_A = row*RCNum + column;
		end
		else begin
			ROM_IM_A = row*RCNum + column;
			n_state = READC_9;			
		end	
	end	
	else begin
		if(channel == 5'd0) begin
			Adder_mode = 2'b0;
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b1;
		end	
		else if(channel == 5'd5) begin
			MUX2_sel = 2'b0;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b10;
			
		end
		else begin
			MUX2_sel = 2'b01;
			MUX3_sel = 1'b0;
			Adder_mode = 2'b01;
		end
		SRAM_CENA = 1'b1;
		MUX1_sel = 1'b1;
		ROM_IM_CS = 1'b0;
		ROM_IM_OE = 1'b0;
		ROM_IM_A = 10'b0;
		if(counter == 4'd9) begin
			n_state = WRITEC;
			SRAM_AA = row*12 + (column - 3) + filter*(RCNum-2)*(RCNum-2);
			
		end
		else begin	
			SRAM_AA = 13'd4704 + row*RCNum + column + channel*RCNum*RCNum;
			n_state = READC_9;
		end	
	end

end

READP: begin
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	SRAM_CENA = 1'b1;
	Decode_en = 1'b0;
	DONE = 1'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b10;
	MUX3_sel = 1'b0;
	ROM_B_A = tB_A;
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	SRAM_AB = 13'b0;
	Adder_mode = 2'b0;
	
	if(counter == 4'd0) begin
		Pool_en = 1'b0;
	end
	else begin
		Pool_en = 1'b1;
	end	
	
	if(counter == 4'd4) begin
		n_state = WRITEP;
		SRAM_AA = row*RCNum + column + pool_N*RCNum*RCNum;
	end
	else begin	
		SRAM_AA = row*RCNum + column + pool_N*RCNum*RCNum;
		n_state = READP;
	end
end

WRITEP: begin
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	SRAM_CENA = 1'b0;
	Decode_en = 1'b0;
	Pool_en = 1'b0;
	Adder_mode = 2'b0;
	SRAM_CENB = 1'b1;
	SRAM_WENB = 1'b1;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b10;
	MUX3_sel = 1'b0;
	ROM_B_A = tB_A;
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	DONE = 1'b0;
	SRAM_AA = row*RCNum + column + pool_N*RCNum*RCNum;
	if(pool == 1'd0) begin
		if(column == 5'd0) begin
			SRAM_AB = ((row/2) - 1)*14 + 13'd13 + pool_N*196 + 13'd4704;
			if((row == RCNum) && (pool_N == 4'd5)) begin
				
				n_state = READC_W;
			end
			else begin
				n_state = READP;
			end	
		end
		else begin
			n_state = READP;
			if(row == 5'd0) begin
				SRAM_AB = row*14 + ((column/2)- 1)  + pool_N*196 + 13'd4704;
			end
			else begin
				SRAM_AB = (row/2)*14 + ((column/2)- 1) + pool_N*196 + 13'd4704;
			end
		end
	end
	
	else begin
		if(column == 5'd0) begin
			SRAM_AB = ((row/2) - 1)*6 + 13'd5 + pool_N*36 + 13'd4704;
			if((row == RCNum) && (pool_N == 4'd14)) begin
				
				n_state = READF;
			end
			else begin
				n_state = READP;
			end	
		end
		else begin
			n_state = READP;
			if(row == 5'd0) begin
				SRAM_AB = row*6 + ((column/2)- 1) + pool_N*36 + 13'd4704;
			end
			else begin
				SRAM_AB = (row/2)*6 + ((column/2)- 1) + pool_N*36 + 13'd4704;
			end
		end
	end

			
end

READF: begin
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;		
	ROM_B_CS = 1'b1;
	ROM_B_OE = 1'b1;
	ROM_W_CS = 1'b1;
	ROM_W_OE = 1'b1;
	Pool_en = 1'b0;
	Decode_en = 1'b0;
	DONE = 1'b0;
	
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	SRAM_CENA = 1'b1;
	ROM_B_A = tB_A;
	MUX1_sel = 1'b1;
	ROM_IM_A = 10'b0;
	SRAM_AB = 13'd0;
	if(FC_L > 10'd9) begin
		
		MUX3_sel = 1'b0;
		if(FC_L == FCNum) begin
			Adder_mode = 2'b10;
			
		end
		else begin
			Adder_mode = 2'b01;
		end
	end
	else begin
		MUX3_sel = 1'b1;
		Adder_mode = 2'b0;
	end
	
	if(FC == 1'd0) begin
		if(FC_L == FCNum) begin
			MUX2_sel = 2'b0;
		end
		else begin
			MUX2_sel = 2'b01;
		end
		
		if(counter == 4'd9) begin
			SRAM_AA = FC_R;
			ROM_W_A = 17'd864 + FC_L + FC_R*540;
			n_state = WRITEF;
		end
		else begin
			SRAM_AA = 13'd4704 + FC_L;
			ROM_W_A = 17'd864 + FC_L + FC_R*540;
			n_state = READF;
		end	
	end
	else begin
		MUX2_sel = 2'b01;
		if(counter == 4'd9) begin
			SRAM_AA = 13'd4704 + FC_R;
			ROM_W_A = 17'd98064 + FC_L + FC_R*180;
			n_state = WRITEF;
		end
		
		else begin
			SRAM_AA = FC_L;
			ROM_W_A = 17'd98064 + FC_L + FC_R*180;
			n_state = READF;
		end	
	end

end

WRITEF: begin
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	ROM_B_CS = 1'b1;
	ROM_B_OE = 1'b1;
	ROM_W_CS = 1'b1;
	ROM_W_OE = 1'b1;
	Pool_en = 1'b0;
	Decode_en = 1'b0;
	DONE = 1'b0;
	MUX1_sel = 1'b1;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b1;
	SRAM_WENB = 1'b1;
	SRAM_CENA = 1'b0;
	ROM_B_A = tB_A;
	ROM_IM_A = 10'b0;
	
	if(FC_L > 10'd9) begin
		
		MUX3_sel = 1'b0;
		if(FC_L == FCNum) begin
			Adder_mode = 2'b10;
			
		end
		else begin
			Adder_mode = 2'b01;
		end
	end
	else begin
		MUX3_sel = 1'b1;
		Adder_mode = 2'b0;
	end
	
	if(FC == 1'd0) begin
		ROM_W_A = 17'd864 + FC_L + FC_R*540;
		SRAM_AA = FC_R;
		if(FC_L == FCNum) begin
			MUX2_sel = 2'b0;
		end
		else begin
			MUX2_sel = 2'b01;
		end
		SRAM_AB = FC_R;
		n_state = READF;
	end
	else begin
		ROM_W_A = 17'd98064 + FC_L + FC_R*180;
		SRAM_AA = 13'd4704 + FC_R;
		MUX2_sel = 2'b01;
		SRAM_AB = 13'd4704 + FC_R;
		if((FC_L == FCNum) && (FC_R == 8'd9)) begin
			n_state = DECODE_R;
		end
		else begin
			n_state = READF;
		end
	end
	
end
DECODE_R: begin
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;	
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	Pool_en = 1'b0;
	DONE = 1'b0;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b11;
	MUX3_sel = 1'b0;
	Adder_mode = 2'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	SRAM_CENA = 1'b1;
	ROM_B_A = tB_A;
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	SRAM_AB = 13'd0;
	
	if(counter == 4'd0) begin
		n_state = DECODE_R;
		SRAM_AA = 13'd4704 + counter;
		Decode_en = 1'b0;
	end
	else if(counter == 4'd10) begin
		n_state = DECODE_W;
		SRAM_AA = 13'd4704 + counter - 1;
		Decode_en = 1'b1;
	end	
	else begin
		n_state = DECODE_R;
		SRAM_AA = 13'd4704 + counter;
		Decode_en = 1'b1;
	end	
			
end

DECODE_W: begin
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	Pool_en = 1'b0;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b11;
	MUX3_sel = 1'b0;
	DONE = 1'b0;
	Adder_mode = 2'b0;
	Decode_en = 1'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b1;
	SRAM_WENB = 1'b1;
	SRAM_CENA = 1'b0;
	ROM_B_A = tB_A;		
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	SRAM_AB = 13'd0;
	SRAM_AA = 13'd0;
	n_state = OVER;
	
end	

OVER: begin
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	Pool_en = 1'b0;
	DONE = 1'b1;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b0;
	MUX3_sel = 1'b0;
	Adder_mode = 2'b10;
	Decode_en = 1'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = tPE_IF;
	{PE1_W_w, PE2_W_w, PE3_W_w} = tPE_W;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	SRAM_CENA = 1'b0;
	SRAM_AA = 13'd0;
	SRAM_AB = 13'd0;
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	ROM_B_A = 8'b0;	
	n_state = OVER;	
end

default: begin
	ROM_B_CS = 1'b0;
	ROM_B_OE = 1'b0;
	ROM_IM_CS = 1'b0;
	ROM_IM_OE = 1'b0;
	ROM_W_CS = 1'b0;
	ROM_W_OE = 1'b0;
	SRAM_CENB = 1'b0;
	SRAM_WENB = 1'b0;
	SRAM_CENA = 1'b0;
	MUX1_sel = 1'b0;
	MUX2_sel = 2'b0;
	MUX3_sel = 1'b0;
	Adder_mode = 2'b10;
	Pool_en = 1'b0;
	Decode_en = 1'b0;
	DONE = 1'b0;
	{PE1_IF_w, PE2_IF_w, PE3_IF_w} = 3'b0;
	{PE1_W_w, PE2_W_w, PE3_W_w} = 3'b0;
	ROM_B_A = 8'b0;
	SRAM_AA = 13'd0;
	SRAM_AB = 13'd0;
	ROM_W_A = 17'd0;
	ROM_IM_A = 10'b0;
	n_state = OVER;	
end
endcase	
end		
endmodule
