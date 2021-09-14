`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2021 08:55:20 PM
// Design Name: 
// Module Name: sound_reg
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
module sound_reg #(
    parameter wordsize = 32
)(
    input wire clk,
    input wire sound_wr,
    input wire [wordsize-1:0] cpu_writedata,
    output logic [31:0] period = 0
    );
    
    always_ff @(posedge clk) begin
        period <= sound_wr ? cpu_writedata : period;
    end
    
endmodule
