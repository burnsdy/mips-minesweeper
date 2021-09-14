`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 03:43:21 PM
// Design Name: 
// Module Name: memory_mapper
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
module memory_mapper #(
    parameter wordsize=32
)(
    input wire cpu_wr,
    input wire [wordsize-1:0] cpu_addr,
    input wire [wordsize-1:0] cpu_writedata,
    output wire [wordsize-1:0] cpu_readdata,
    input wire [wordsize-1:0] keyb_char,
    input wire [wordsize-1:0] accel_val,
    output wire lights_wr, sound_wr, smem_wr, dmem_wr,
    input wire [wordsize-1:0] smem_readdata, dmem_readdata
    );
    
    assign lights_wr = (cpu_addr[17:16] == 2'b11 & cpu_addr[3:2] == 2'b11 & cpu_wr) ? 1'b1 : 1'b0;
    assign sound_wr = (cpu_addr[17:16] == 2'b11 & cpu_addr[3:2] == 2'b10 & cpu_wr) ? 1'b1 : 1'b0;
    assign smem_wr = (cpu_addr[17:16] == 2'b10 & cpu_wr) ? 1'b1 : 1'b0;
    assign dmem_wr = (cpu_addr[17:16] == 2'b01 & cpu_wr) ? 1'b1 : 1'b0;
    assign cpu_readdata = (cpu_addr[17:16] == 2'b01) ? dmem_readdata
                        : (cpu_addr[17:16] == 2'b10) ? smem_readdata
                        : (cpu_addr[17:16] == 2'b11) ?
                          ((cpu_addr[3:2] == 2'b00) ? keyb_char
                          : (cpu_addr[3:2] == 2'b01) ? accel_val : 32'b0) : 32'b0;
                          // ((cpu_addr[3:2] == 2'b00) ? keyb_char : accel_val) : 32'b0;
                          
endmodule
