`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2021 10:07:54 AM
// Design Name: 
// Module Name: vgatimer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
`include "display640x480.vh"
module vgatimer(
    input wire clk,
    output wire hsync, vsync, activevideo,
    output wire [`xbits-1:0] x,
    output wire [`ybits-1:0] y
    );
    
    // These lines below allow you to count every 2nd clock tick and 4th clock tick
    // This is because, depending on the display mode, we may need to count at 50 MHz or 25 MHz
    
    logic [1:0] clk_count=0;
    always_ff @(posedge clk)
        clk_count <= clk_count + 2'b01;
    
    wire Every2ndTick = (clk_count[0] == 1'b1);
    wire Every4thTick = (clk_count[1:0] == 2'b11);
    
    // This part instantiates an xy-counter using the appropriate clock tick counter
    // xycounter #(`WholeLine, `WholeFrame) xy(clk, Every2ndTick, x, y); // Count at 50 MHz
    xycounter #(`WholeLine, `WholeFrame) xy(clk, Every4thTick, x, y); // Count at 25 MHz
    
    // Generate the monitor sync signals
    // If hsync/vsync is within start and end range, output down to 0, else output up to 1
    assign hsync = ((x >= `hSyncStart) & (x <= `hSyncEnd)) ? ~(`hSyncPolarity) : `hSyncPolarity;
    assign vsync = ((y >= `vSyncStart) & (y <= `vSyncEnd)) ? ~(`vSyncPolarity) : `vSyncPolarity;
    assign activevideo = ((x < `hVisible) & (y < `vVisible)) & x >= 0 & y >= 0 ? 1'b1 : 1'b0;
    
endmodule
