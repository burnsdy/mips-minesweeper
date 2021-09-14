//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 4/9/2021
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter wordsize=32,                      // word size for the processor
    parameter Nreg=32,                          // number of registers
    parameter Nchars=16,                         // number of characters/sprites
    parameter imem_size=1024,                   // imem size, must be >= # instructions in program
`ifdef SYNTHESIS
    // parameter imem_init="imem_screentest.mem",  // version of program for synthesis, with pauses after each keystroke
    // parameter imem_init="imem_etchasketch.mem",
    // parameter imem_init="imem_full-IO-test.mem",
    parameter imem_init="imem.mem",
`else
    parameter imem_init="imem_screentest_nopause.mem",   // version of program for simulation, without pauses
`endif
    parameter dmem_size=1024,                   // dmem size, must be >= # words in .data of program + size of stack
    parameter dmem_init="dmem.mem",        // text file to initialize data memory
    parameter smem_size=1200,                   // smem size, 30 rows x 40 cols
    parameter smem_init="smem.mem", 	// text file to initialize screen memory
    parameter bmem_init="bmem.mem" 	// text file to initialize bitmap memory
)(    
    input wire clk, reset,                      // reset is the center push button (BTNC).  Include reset.xdc
    // VGA outputs
    output wire [3:0] red, green, blue,
    output wire hsync, vsync,
    // Keyboard inputs
    input wire ps2_data, ps2_clk,
    // 8-digit segmented display outputs
    output wire [7:0] segments,
    output wire [7:0] digitselect,
    //Sound outputs
    output wire audPWM,
    output wire audEn,
    //Accel input/output
    output wire aclSCK,
    output wire aclMOSI,
    input wire aclMISO,
    output wire aclSS,
    // LED lights
    output wire [15:0] LED
);

   wire enable = 1'b 1;
   wire [wordsize-1:0] pc, instr, mem_readdata, mem_writedata, mem_addr, keyb_char, accel_val, period;   
   wire mem_wr, clk12, clk100;
   wire [$clog2(smem_size)-1:0] smem_addr;
   wire [$clog2(Nchars)-1:0] charcode;
   
   // When synthesizing, the clock divider gets used.  It outputs clk12 (1/8th clock speed, i.e., 12.5 MHz)
   //   and clk100 (the full-speed 100 MHz clock).
   // When simulating, the clock divider is not to be used (doesn't simulate well).
   //
`ifdef SYNTHESIS
   clockdivider_Nexys4 clkdv(.clkin(clk), .clk12(clk12), .clk100(clk100));
`else
   assign clk100=clk; assign clk12=clk;
`endif

   // The MIPS and everything inside the memIO module must operate on clk12 (12.5 MHz) because the
   //   circuits inside will not run at 100 MHz (nor at 50 MHz, and possibly not even at 25 MHz for some).
   // But all the I/O devices --- the VGA display, keyboard, accelerometer, sound generator, 
   //   and segmented display --- should all use clk100 (100 MHz) because they were designed assuming
   //   the full clock speed.

   mips mips(.clk(clk12), .*);
   rom_module #(.Nloc(imem_size), .Dbits(wordsize), .initfile(imem_init)) imem(pc[31:2], instr);

   memIO #(.wordsize(wordsize), .dmem_size(dmem_size), .dmem_init(dmem_init), .Nchars(Nchars), .smem_size(smem_size), .smem_init(smem_init)
   ) memIO(
       .clk(clk12), .cpu_wr(mem_wr), .cpu_addr(mem_addr), .cpu_writedata(mem_writedata), .cpu_readdata(mem_readdata),
       .vga_addr(smem_addr), .vga_readdata(charcode), .keyb_char, .accel_val, .period, .lights(LED));

   vgadisplaydriver #(.Nchars(Nchars), .smem_size(smem_size), .bmem_init(bmem_init)) display(.clk(clk100), .smem_addr, .charcode, .*);
   
   keyboard keyb(.clk(clk100), .keyb_char, .*);
   
   //Accelerometer
   wire [8:0] accelX, accelY;      // The accelX and accelY values are 9-bit values, ranging from 9'h 000 to 9'h 1FF
   wire [11:0] accelTmp;           // 12-bit value for temperature    
   accelerometer accel(.clk(clk100), .accelX, .accelY, .accelTmp, .*);
   assign accel_val[31:0] = {7'b0, accelX[8:0], 7'b0, accelY[8:0]};

   // Sound
   montek_sound_Nexys4 sound(.clock100(clk100), .period, .*);
   assign audEn = (period != 32'b 0);               // period = 0 disables audio

   // Segmented display:  Use it for displaying anything for debugging purposes,
   //    e.g., keyb_char or accel_val or period, or even PC or instr or anything else.   
   display8digit disp(.val(keyb_char), .clk(clk100), .segments, .digitselect);

endmodule


//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// Below is a module to divide clock frequency from 100 MHz down to 12.5 MHz (1/8th)
//
//////////////////////////////////////////////////////////////////////////////////


module clockdivider_Nexys4(input wire clkin, output wire clk12, clk100);

   wire clkout0, clkout1, clkout2, clkout3, clkfbout, locked, clkfbin;
   wire clk25, clk50;

   MMCME2_BASE #(.CLKOUT0_DIVIDE_F(10), .CLKOUT1_DIVIDE(20), .CLKOUT2_DIVIDE(40), .CLKOUT3_DIVIDE(80),
            .CLKFBOUT_MULT_F(10), .CLKIN1_PERIOD(10.0)) 
            mmcm (.CLKOUT0(clkout0), .CLKOUT1(clkout1), .CLKOUT2(clkout2), .CLKOUT3(clkout3),
               .CLKFBOUT(clkfbout), .LOCKED(locked), .CLKIN1(clkin), .PWRDWN(1'b0),
               .RST(1'b0), .CLKFBIN(clkfbin));


   BUFG   bufclkfb (.I(clkfbout), .O(clkfbin));

   localparam N=2;
   logic [N:0] start_cnt=0;           // Count 2^N clock cycles of 100 MHz clock
   wire clock_enable=locked & start_cnt[N];  // Delay clock outputs by 2^N clock cycles of 100 MHz clock after lock
   always_ff @(posedge clkout0) begin
      if (locked & (start_cnt[N] != 1'b1))
         start_cnt <= start_cnt + 1'b1;
   end

   wire not_clock_enable;
   INV I1 (.I(clock_enable), .O(not_clock_enable));
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) buf100 (.O(clk100), .I0(clkout0), .I1(1'b0), .S(not_clock_enable));
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) buf50  (.O(clk50),  .I0(clkout1), .I1(1'b0), .S(not_clock_enable));
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) buf25  (.O(clk25),  .I0(clkout2), .I1(1'b0), .S(not_clock_enable));
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) buf12  (.O(clk12),  .I0(clkout3), .I1(1'b0), .S(not_clock_enable));
   
endmodule
