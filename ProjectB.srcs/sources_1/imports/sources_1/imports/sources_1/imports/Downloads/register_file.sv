//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 3/15/2021
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
//
// NOTE:  There should be NO NEED TO MODIFY *ANYTHING* in this template
//        (other than filling in the blanks).
//        You do NOT need to modify any parameters at the top, nor any of
//        the bit widths of address or data.
//
//        Simply specify different values for the parameters inside the parent
//        when the register file is instantiated.
//
//        Modifying anything here is cause for much headache later on!
//////////////////////////////////////////////////////////////////////////////////



// EXCEPT FOR FILLING IN THE BLANKS!!!!!!!!!!!!!!
// DO NOT MODIFY *ANYTHING* BELOW!!!!!!!!!!!!!!!!
// DO NOT MODIFY *ANYTHING* BELOW!!!!!!!!!!!!!!!!
// DO NOT MODIFY *ANYTHING* BELOW!!!!!!!!!!!!!!!!
// DO NOT MODIFY *ANYTHING* BELOW!!!!!!!!!!!!!!!!
// DO NOT MODIFY *ANYTHING* BELOW!!!!!!!!!!!!!!!!
// DO NOT MODIFY *ANYTHING* BELOW!!!!!!!!!!!!!!!!

module register_file #(
   parameter Nloc = 32,                      // Number of memory locations
   parameter Dbits = 32                      // Number of bits in data
)(

   input wire clock,
   input wire wr,                            // WriteEnable:  if wr==1, data is written into mem
   input wire [$clog2(Nloc)-1 : 0] ReadAddr1, ReadAddr2, WriteAddr, 	
                                             // 3 addresses, two for reading and one for writing
   input wire [Dbits-1 : 0] WriteData,       // Data for writing into memory (if wr==1)
   output wire [Dbits-1 : 0] ReadData1, ReadData2
                                             // 2 output ports
   );

   logic [Dbits-1:0] rf [Nloc-1:0];          // The actual registers where data is stored
                                             // Usually no need to initialize register file,
                                             //   so initial $readmemh() not needed.


   always_ff @(posedge clock)                // Memory write: only when wr==1, and only at posedge clock
      if(wr)
         rf[WriteAddr] <= WriteData;

   // MODIFY the two lines below so if register 0 is being read, then the output
   // is 0 regardless of the actual value stored in register 0
   
   assign ReadData1 = (ReadAddr1 == 0) ? 0 : rf[ReadAddr1];     // First output port
   assign ReadData2 = (ReadAddr2 == 0) ? 0 : rf[ReadAddr2];     // Second output port
   
endmodule
