`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2021 11:22:54 PM
// Design Name: 
// Module Name: memIO
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
module memIO #(
    parameter wordsize=32,
    parameter dmem_size=1024,
    parameter dmem_init="dmem.mem",
    parameter Nchars=4,
    parameter smem_size=1200,
    parameter smem_init="smem.mem"
)(
    input wire clk,
    input wire cpu_wr,
    input wire [wordsize-1:0] cpu_addr, cpu_writedata,
    output wire [wordsize-1:0] cpu_readdata,
    input wire [$clog2(smem_size)-1:0] vga_addr,
    output wire [$clog2(Nchars)-1:0] vga_readdata,
    input wire [31:0] keyb_char,
    input wire [31:0] accel_val,
    output wire [31:0] period,
    output wire [15:0] lights
    );
    
    // Memory Mapper
    wire lights_wr, sound_wr, smem_wr, dmem_wr;
    wire [$clog2(Nchars)-1:0] smem_readdata;
    wire [wordsize-1:0] dmem_readdata;
    memory_mapper #(.wordsize(wordsize)) mm(.*, .lights_wr(lights_wr), .sound_wr(sound_wr), .smem_wr(smem_wr),
    .dmem_wr(dmem_wr), .smem_readdata({30'b0, smem_readdata}), .dmem_readdata(dmem_readdata));
    
    // LED Register
    LED_reg LED(.clk(clk), .lights_wr(lights_wr), .cpu_writedata(cpu_writedata[15:0]), .lights(lights));
    
    // Sound Register
    sound_reg #(.wordsize(wordsize)) sound(.clk(clk), .sound_wr(sound_wr), .cpu_writedata(cpu_writedata),
    .period(period));
    
    // Screen Memory
    screen_mem #(.Nloc(smem_size), .Dbits($clog2(Nchars)), .initfile(smem_init)) smem(.clk(clk),
    .smem_wr(smem_wr), .cpu_addr(cpu_addr[31:2]), .cpu_writedata(cpu_writedata), .vga_addr(vga_addr),
    .vga_readdata(vga_readdata), .smem_readdata(smem_readdata));
    
    // Data Memory
    data_mem #(.Nloc(dmem_size), .Dbits(wordsize), .initfile(dmem_init)) dmem(.clk(clk), .dmem_wr(dmem_wr),
    .cpu_addr(cpu_addr[31:2]), .cpu_writedata(cpu_writedata), .dmem_readdata(dmem_readdata));
    
endmodule
