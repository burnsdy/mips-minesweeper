`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2021 08:27:30 PM
// Design Name: 
// Module Name: comparator
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
module comparator(
    input wire FlagN, FlagV, FlagC, bool0,
    output wire comparison
    );
    
    // Trying to find where A-B is negative for signed and unsigned
    assign comparison = bool0 ? ~FlagC : FlagN ^ FlagV;
    
endmodule
