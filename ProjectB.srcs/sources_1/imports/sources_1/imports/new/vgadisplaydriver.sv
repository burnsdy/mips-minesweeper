//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 1/31/2020
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.vh"

module vgadisplaydriver #(
    parameter Nchars,
    parameter smem_size,
    parameter bmem_init
) (
    input wire clk,
    input wire [$clog2(Nchars)-1:0] charcode, // was [11:0]
    // output wire [11:0] RGB,
    output wire [3:0] red, green, blue,
    output wire hsync, vsync,
    output wire [$clog2(smem_size)-1:0] smem_addr
    );

   wire [`xbits-1:0] x;
   wire [`ybits-1:0] y;
   wire activevideo;

   vgatimer myvgatimer(clk, hsync, vsync, activevideo, x, y);
   
   // smem_addr = mapping from (col,row) character coordinates to the address in screen memory
   // smem_addr = 40*row + col, because each row has 40 values
   // smem_addr = (row<<5) + (row<<3) + col
   // y[`ybits-1:4] is mapping from (x,y) pixel coordinates to the (col,row) grid coordinates
   assign smem_addr = ((y[`ybits-1:4]<<5) + (y[`ybits-1:4]<<3) + x[`xbits-1:4]);
   
   wire [$clog2(Nchars << 8)-1 : 0] bmem_addr;
   wire [11:0] bmem_color;
   // bmem_addr = mapping from the character code to the start location of the bitmap stored for that character in bitmap memory
   // bmem_addr = charcode*256 + yoffset*16 + xoffset
   // bmem_addr = {charcode, yoffset, xoffset}
   // x[3:0] and y[3:0] are mappings from the pixel coordinates to x and y offsets
   assign bmem_addr = {charcode, y[3:0], x[3:0]};
   rom_module #(.Nloc(Nchars << 8), .Dbits(12), .initfile(bmem_init)) B(bmem_addr, bmem_color);
   
   wire [11:0] RGB;
   assign RGB = (activevideo == 1) ? bmem_color : 12'b0;
   assign red = RGB[11:8];
   assign green = RGB[7:4];
   assign blue = RGB[3:0];
   
//   // value of red increases from bits 2 to 5 left to right
//   assign red[3:0]   = (activevideo == 1) ? x[5:2] : 4'b0;
//   // value of green increases from bits 2 to 5 top to bottom
//   assign green[3:0] = (activevideo == 1) ? y[5:2] : 4'b0;
//   // value of blue increases at sum of x and y from bits 2 to 5
//   assign blue[3:0]  = (activevideo == 1) ? x[5:2]+y[5:2] : 4'b0;

endmodule