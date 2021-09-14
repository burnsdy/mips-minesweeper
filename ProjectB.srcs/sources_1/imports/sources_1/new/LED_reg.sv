`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2021 08:27:21 PM
// Design Name: 
// Module Name: LED_reg
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
module LED_reg(
    input wire clk,
    input wire lights_wr,
    input wire [15:0] cpu_writedata,
    output logic [15:0] lights = 0
    );
    
    always_ff @(posedge clk) begin
        lights <= lights_wr ? cpu_writedata : lights;
    end
    
endmodule
