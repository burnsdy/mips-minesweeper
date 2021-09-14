`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2021 07:13:59 PM
// Design Name: 
// Module Name: datapath
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
module datapath #(
    parameter Nreg=32,
    parameter Dbits=32
)(
    input wire clk, reset, enable,
    output wire [31:0] pc,
    input wire [31:0] instr,
    input wire [1:0] pcsel, wasel,
    input wire sgnext, bsel,
    input wire [1:0] wdsel,
    input wire [4:0] alufn,
    input wire werf,
    input wire [1:0] asel,
    output wire Z,
    output wire [Nreg-1:0] mem_addr,
    output wire [Dbits-1:0] mem_writedata,
    input wire [Dbits-1:0] mem_readdata
    );
    
    // PCSEL
    wire [Dbits-1:0] newPC, JT, J, BT, pcPlus4;
    assign newPC = (pcsel == 2'b11) ? JT
                    : (pcsel == 2'b10) ? J
                    : (pcsel == 2'b01) ? BT
                    : pcPlus4;
    
    // PC
    logic [31:0] initPC = 32'h0040_0000;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            initPC <= 32'h0040_0000;
        else if (enable)
            initPC <= newPC;
    end
    assign pc = initPC;
    
    // For PCSEL
    assign pcPlus4 = pc + 4;
    assign J = {pc[31:28],instr[25:0],2'b00};
    
    // WASEL
    wire [$clog2(Nreg)-1:0] reg_writeaddr;
    assign reg_writeaddr = (wasel == 2'b00) ? instr[15:11] // Rd
                            : (wasel == 2'b01) ? instr[20:16] // Rt
                            : 5'b11111; // 31 in binary
    
    // Register File
    wire [Dbits-1:0] ReadData1, ReadData2;
    register_file #(.Nloc(Nreg), .Dbits(Dbits)) R(.clock(clk), .wr(werf),
       .ReadAddr1(instr[25:21]), .ReadAddr2(instr[20:16]), .WriteAddr(reg_writeaddr),
       .WriteData(reg_writedata), .ReadData1(ReadData1), .ReadData2(ReadData2));
    assign mem_writedata = ReadData2;
    // For PCSEL
    assign JT = ReadData1;
    
    // SGNEXT
    wire [Dbits-1:0] signImm;
    assign signImm = sgnext ? {{16{instr[15]}},instr[15:0]}
                            : {16'b0,instr[15:0]};
    // For PCSEL
    assign BT = (signImm<<2) + pcPlus4;
    
    // ASEL
    wire [Dbits-1:0] aluA;
    assign aluA = (asel == 2'b00) ? ReadData1
                    : (asel == 2'b01) ? instr[10:6]
                    : 5'b10000; // 16 in binary
    
    // BSEL
    wire [Dbits-1:0] aluB;
    assign aluB = bsel ? signImm
                    : ReadData2;
    
    // ALU
    wire [Dbits-1:0] alu_result;
    ALU #(Dbits) A(.A(aluA), .B(aluB), .R(alu_result), .ALUfn(alufn), .FlagZ(Z));
    assign mem_addr = alu_result;
    
    // WDSEL
    wire [Dbits-1:0] reg_writedata;
    assign reg_writedata = (wdsel == 2'b00) ? pcPlus4
                            : (wdsel == 2'b01) ? alu_result
                            : mem_readdata;
    
endmodule
