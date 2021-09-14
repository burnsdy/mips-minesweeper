`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2021 03:02:24 PM
// Design Name: 
// Module Name: ALU
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
module ALU #(parameter N=32) (
    input wire [N-1:0] A, B,
    output wire [N-1:0] R,
    input wire [4:0] ALUfn,
    output wire FlagZ
    );
    
    wire FlagN, FlagC, FlagV;
    
    wire subtract, bool1, bool0, shft, math;
    assign {subtract, bool1, bool0, shft, math} = ALUfn[4:0];   // Separate ALUfn into named bits
    
    wire compResult;
    wire [N-1:0] addsubResult, shiftResult, logicalResult;      // Results from the three ALU components
    
    comparator C(FlagN, FlagV, FlagC, bool0, compResult);
    addsub #(N) AS(A, B, subtract, addsubResult, FlagN, FlagC, FlagV);
    shifter #(N) S(B, A[$clog2(N)-1:0], ~(bool1), ~(bool0), shiftResult);
    logical #(N) L(A, B, {bool1, bool0}, logicalResult);
    
    assign R =  (~shft & math)? addsubResult :                  // 4-way multiplexer to select result
                (shft & ~math)? shiftResult :
                (~shft & ~math)? logicalResult :
                (shft & math)? {{(N-1){1'b0}}, compResult} : 0;
    
    assign FlagZ = ~|R;                                         // "Big NOR gate on outputs of adder"
    
endmodule
