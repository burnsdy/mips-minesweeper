`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 01:16:30 PM
// Design Name: 
// Module Name: screen_mem
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
module screen_mem #(
    parameter Nloc = 1200, // smem_size
    parameter Dbits = 2, // $clog2(Nchars)
    parameter initfile = "smem.mem"
)(
    input wire clk,
    input wire smem_wr, // wr
    input wire [$clog2(Nloc)-1:0] cpu_addr, // mem_addr
    input wire [Dbits-1:0] cpu_writedata, // wd
    input wire [$clog2(Nloc)-1:0] vga_addr, // smem_adddr, [11:0]
    output wire [Dbits-1:0] vga_readdata, // charcode
    output wire [Dbits-1:0] smem_readdata // mem_readdata
    );
    
    logic [Dbits-1:0] smem [Nloc-1:0];
    initial $readmemh (initfile, smem, 0, Nloc-1);
    
    always_ff @(posedge clk)
        if (smem_wr)
            smem[cpu_addr] <= cpu_writedata;
    
    assign vga_readdata = smem[vga_addr];
    assign smem_readdata = smem[cpu_addr];
    
endmodule
