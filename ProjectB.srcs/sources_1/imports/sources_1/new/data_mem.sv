`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2021 09:19:18 PM
// Design Name: 
// Module Name: data_mem
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
module data_mem #(
    parameter Nloc = 1024, // dmem_size
    parameter Dbits = 32, // wordsize
    parameter initfile = "dmem.mem"
)(
    input wire clk,
    input wire dmem_wr,
    input wire [$clog2(Nloc)-1:0] cpu_addr,
    input wire [Dbits-1:0] cpu_writedata,
    output wire [Dbits-1:0] dmem_readdata
    );
    
    logic [Dbits-1:0] dmem [Nloc-1:0];
    initial $readmemh (initfile, dmem, 0, Nloc-1);
    
    always_ff @(posedge clk)
        if (dmem_wr)
            dmem[cpu_addr] <= cpu_writedata;
    
    assign dmem_readdata = dmem[cpu_addr];
    
endmodule
