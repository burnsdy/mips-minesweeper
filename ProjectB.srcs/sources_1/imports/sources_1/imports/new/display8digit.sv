//////////////////////////////////////////////////////////////////////////////////
// Montek Singh
// 2/19/2021 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module display8digit(
    input wire [31:0] val,
    input wire clk, 					// 100 MHz clock
    output wire [7:0] segments,
    output wire [7:0] digitselect
    );

	logic [31:0] c = 0;					// Used for round-robin digit selection on display
	wire [2:0] topthree;
	wire [3:0] value4bit;
	
	always_ff @(posedge clk)
		c <= c + 1'b 1;
	
	assign topthree[2:0] = c[18:16];		// Used for round-robin digit selection on display
	// assign toptwo[1:0] = c[23:22];   // Try this instead to slow things down!

	
	assign digitselect = ~ (  			// Note inversion
					   topthree == 3'b000 ? 8'b 00000001
				     : topthree == 3'b001 ? 8'b 00000010
				     : topthree == 3'b010 ? 8'b 00000100
				     : topthree == 3'b011 ? 8'b 00001000
				     : topthree == 3'b100 ? 8'b 00010000
				     : topthree == 3'b101 ? 8'b 00100000
				     : topthree == 3'b110 ? 8'b 01000000
				     : 8'b 10000000 );
	
	assign value4bit   =   (
				  topthree == 3'b000 ? val[3:0]
				: topthree == 3'b001 ? val[7:4]
				: topthree == 3'b010 ? val[11:8]
				: topthree == 3'b011 ? val[15:12]
				: topthree == 3'b100 ? val[19:16]
				: topthree == 3'b101 ? val[23:20]
				: topthree == 3'b110 ? val[27:24]
				: val[31:28] );
	
	hexto7seg myhexencoder(value4bit, segments);

endmodule
