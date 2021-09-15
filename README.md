# MIPS Assembly Minesweeper

I programmed the classic game [Minesweeper](https://minesweeperonline.com/) in MIPS Assembly Language. I then implemented the game on an FPGA development board, the Nexys 4 DDR, using Xilinx Vivado to generate the entire MIPS achitecture for the board from HDL files I created for the different components of the processor.

When implemented on the board, the player is able to move the cursor with `WASD` or the arrow keys, flip a tile using space bar, and flag a tile using `F`.

The board plays different jingles upon starting, winning, and losing the game, and different sounds when flipping or flagging tiles. The LED lights on the board also flash in different patterns upon winning or losing.

The mine locations on the game board are generated pseudo-randomly, and flipping a tile causes the surrounding tiles to be flipped recursively (like what happens in the normal implementation of the game).

All of the graphics were created by me to mimic the classic 8-bit design of the game. The graphics are specified in the screen memory (smem.mem) and bitmap memory (bmem.mem) files in the GameMemory folder.

This project was completed as the final assignment for UNC Chapel Hill's COMP 541: Digital Logic and Computer Design.

Many thanks to Montek Singh for his support during the semester.
