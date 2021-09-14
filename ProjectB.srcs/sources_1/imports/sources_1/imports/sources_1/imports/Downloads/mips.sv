`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 3/23/2021
//
/////////////////////////////////////////////////////////////////////////////////

`default_nettype none

// NOTE: There should not be any need to modify anything below!!!!
// Any changes to parameters must be made in the tester, from which
// actual parameter values are inherited.


module mips#(
// DO NOT CHANGE
    parameter Dbits=32,                        // word size for the processor
    parameter Nreg=32                          // number of registers
)(
// DO NOT CHANGE
    input wire clk, 
    input wire reset,
    input wire enable,
    output wire [31:0] pc, 
    input wire [31:0] instr, 
    output wire mem_wr, 
    output wire [31:0] mem_addr,
    output wire [31:0] mem_writedata, 
    input wire [31:0] mem_readdata
    );
    
// DO NOT CHANGE

   wire [1:0] pcsel, wdsel, wasel;
   wire [4:0] alufn;
   wire Z, sgnext, bsel, dmem_wr, werf;
   wire [1:0] asel; 

   controller c(.enable(enable), .op(instr[31:26]), .func(instr[5:0]), .Z(Z),
                  .pcsel(pcsel), .wasel(wasel[1:0]), .sgnext(sgnext), .bsel(bsel), 
                  .wdsel(wdsel), .alufn(alufn), .wr(mem_wr), .werf(werf), .asel(asel));

   // Make sure your datapath module implementation is parameterized with two parameters,
   //   as shown below:
   //
   //     Nreg = number of registers in the register file
   //     Dbits = number of bits in data (for both size of each register and width of ALU)

   datapath #(.Nreg(Nreg), .Dbits(Dbits)) dp(.clk(clk), .reset(reset), .enable(enable),
                  .pc(pc), .instr(instr),
                  .pcsel(pcsel), .wasel(wasel[1:0]), .sgnext(sgnext), .bsel(bsel), 
                  .wdsel(wdsel), .alufn(alufn), .werf(werf), .asel(asel),
                  .Z(Z), .mem_addr(mem_addr), .mem_writedata(mem_writedata), .mem_readdata(mem_readdata));

endmodule
