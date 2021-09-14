#############################################################################################
#
# Dylan Burns
# COMP 541 Final Project
# Apr 24, 2021
#
# This is a MIPS program that runs a simple Minesweeper game
#
# This program assumes the memory-IO map introduced in class specifically for the final
# projects. In MARS, please select:  Settings ==> Memory Configuration ==> Default.
#
#############################################################################################
#
# This program is suitable for board deployment, NOT for Vivado simulation (because there is
# no tester provided that can model the keyboard, accelerometer, etc.).
#
#############################################################################################

.data 0x10010000 		# Start of data memory
    sprite_char: .word 1	# Initialized sprite_char to be 1 (charcode for unflipped generic)
    num_bombs: .word 0		# Initialized num_bombs to be 0 for real_board
    num_flipped: .word 0	# Initialized num_flipped to be 0
    real_board: .space 1024	# Create real_board array for storing bomb and number locations
    check_board: .space 1024	# Create check_board array for storing whether a tile has been checked during recursive flip

.text 0x00400000                # Start of instruction memory
.globl main

main:
    lui     $sp, 0x1001         # Initialize stack pointer to the 1024th location above start of data
    ori     $sp, $sp, 0x1000    # top of the stack will be one word below
                                #   because $sp is decremented first.
    addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame

start_game:
	addi	$a0, $0, 10		# N is placed in $a0, N = 10 = 1/10 second
	jal 	pause_and_getkey       # pause_and_getkey(N), N is hundredths of a second assuming 12.5 MHz clock
	addi	$a1, $a1, 1		# counter variable for generating random real_board

cont_main:
	beq	$v0, $0, start_game	# 0 means no valid key
	jal	gen_minefield		# pass in counter variable in $a1, save real_board in memory, return nothing

# Used for printing out the board while still being able to play the game
#debugging_print:
#	li	$t0, 0			# set counter variable i=0
#	li	$a1, 0			# set x = 0
#	li	$a2, 0			# set y = 0
#print_loop:
#	slti	$t1, $t0, 256		# if i<256, continue the loop
#	bne	$t1, 1, rest_of_main
#	sll	$t2, $t0, 2		# Multiply by 4
#	lw	$a0, real_board($t2)
#	jal	putChar_atXY
#	addi	$a1, $a1, 1
#	bne	$a1, 16, rest_of_print_loop
#	li	$a1, 0
#	addi	$a2, $a2, 1
#rest_of_print_loop:
#	addi	$t0, $t0, 1		# i++
#	j	print_loop

rest_of_main:
	li	$s1, 20			# initialize to middle screen col (X=20)
	li	$s2, 15			# initialize to middle screen row (Y=15)

	move 	$a1, $s1
	move 	$a2, $s2
	jal	getChar_atXY		# get char at initial x and y
	sw	$v0, sprite_char($0)	# store char in sprite_char
	li	$a0, 0			# draw selector here (charcode=0)
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y --> initializing selector sprite

animate_loop:	
	addi	$a0, $0, 8		# N is placed in $a0, N = 10 = 1/10 second
	jal 	pause_and_getkey       # pause_and_getkey(N), N is hundredths of a second assuming 12.5 MHz clock
	move	$s5, $v0               # save key in $s5 to protect from called procedures

PLAYER:
	beq	$s5, $0, animate_loop	# 0 means no valid key
	move	$a0, $s5		# $a0 has key
	move	$a1, $s1		# $a1 has x value
	move	$a2, $s2		# $a2 has y value
	jal	move_player            # call move_player with PLAYER’s position and key
	move	$s1, $v0		# $v0 is new x value --> now in $s1
	move	$s2, $v1		# $v1 is new y value --> now in $s2
	j	animate_loop            # go back to start of animation loop

end:
	j	end          	# infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################

#####################################
# procedure move_player
# $a0:  key
# $a1:  curr x coord
# $a2:  curr y coord
#
# return values:
# $v0:  new x coord
# $v1:  new y coord
#####################################

move_player:
    addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    sw      $ra, 4($sp)         # Save $ra
    sw      $fp, 0($sp)         # Save $fp
    addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
                    
	move	$v0, $a1		# $v0 has x value
	move	$v1, $a2		# $v1 has y value
	move	$t0, $a0		# save key from $a0 in $t0
	li	$a0, 8			# N is placed in $a0, N = 30 = 3/10 second
	jal	pause			# pause(N), N is hundredths of a second assuming 12.5 MHz clock
	move	$a0, $t0		# return key to $a0

key1:	# 'A' key press
	bne	$a0, 1, key2
	lw	$a0, sprite_char($0)	# load sprite_char into $a0
	jal	putChar_atXY		# $a0 is char, $a1 is X, $a2 is Y
	addi	$v0, $v0, -1 		# move left
	slti	$1, $v0, 12		# make sure X >= 12
	beq	$1, $0, done_moving	# $1 is garbage register
	li	$v0, 12			# else, set X to 12
	j	done_moving

key2:	# 'D' key press
	bne	$a0, 2, key3
	lw	$a0, sprite_char($0)	# load sprite_char into $a0
	jal	putChar_atXY		# $a0 is char, $a1 is X, $a2 is Y
	addi 	$v0, $v0, 1 		# move right
	slti 	$1, $v0, 28		# make sure X < 28
	bne	$1, $0, done_moving	# $1 is garbage register
	li	$v0, 27			# else, set X to 27
	j	done_moving

key3:	# 'W' key press
	bne	$a0, 3, key4
	lw	$a0, sprite_char($0)	# load sprite_char into $a0
	jal	putChar_atXY		# $a0 is char, $a1 is X, $a2 is Y
	addi 	$v1, $v1, -1 		# move up
	slti	$1, $v1, 7		# make sure Y >= 7
	beq	$1, $0, done_moving	# $1 is garbage register
	li	$v1, 7			# else, set Y to 7
	j	done_moving

key4:	# 'S' key press
	bne	$a0, 4, key5		# read key again
	lw	$a0, sprite_char($0)	# load sprite_char into $a0
	jal	putChar_atXY		# $a0 is char, $a1 is X, $a2 is Y
	addi	$v1, $v1, 1 		# move down
	slti	$1, $v1, 23		# make sure Y < 23
	bne	$1, $0, done_moving	# $1 is garbage register
	li	$v1, 22			# else, set Y to 22
	j	done_moving

key5:	# 'F' key press
	bne	$a0, 5, key6			# read key again
	lw	$a0, sprite_char($0)		# load sprite_char into $a0 --> checking sprite_char
	li	$t1, 1				# set equal to charcode for unflipped blank
	beq	$a0, $t1, flag_tile		# if sprite_char == charcode for blank --> flag tile
	li	$t1, 2				# set equal to charcode for unflipped flag
	beq	$a0, $t1, unflag_tile		# if sprite_char == charcode for flag --> unflag tile
	j	return_from_move_player	# if sprite_char is not blank or flag, do nothing

key6:	# 'Space' key press
	bne	$a0, 6, return_from_move_player
	#lw	$t0, num_flipped($0)
	#beq	$t0, $0, flip_first_tile
	lw	$a0, sprite_char($0)		# load sprite_char into $a0 --> checking sprite_char
	li	$t1, 1				# set equal to charcode for unflipped blank
	beq	$a0, $t1, flip_tile		# if sprite_char == charcode for blank --> flip_tile
	li	$t1, 2				# set equal to charcode for unflipped flag
	beq	$a0, $t1, flip_tile		# if sprite_char == charcode for flag --> flip_tile
	j	return_from_move_player

# =============================================================

flip_first_tile:
# reset_check_board takes care of num_flipped++, 


flip_tile:
	# get index i for real_board
	li	$a0, 382219
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 0
	jal	put_sound
	jal	get_index			# go to get_index proc to get i in $v0 (parameters x in $a1, y in $a2)
	move	$a3, $v0			# move i into $a3
	move	$v0, $a1			# return x value back to $v0
	sll	$t7, $a3, 2
	lw	$t0, real_board($t7)		# get real_board[i] in $t0
	beq	$t0, 12, lost_game		# if real_board[i] is bomb --> lost_game
	sw	$t0, sprite_char($0)		# else --> store real_board[i] in sprite_char
	move	$s6, $v0
	move	$s7, $v1
	jal	recursive_flip			# else continued --> putChar_atXY of real_char, increment num_flipped
	move	$v0, $s6
	move	$v1, $s7
	li	$a3, 0					# check_counter = 0
	li	$t9, 0					# new num_flipped
reset_check_board:
	beq	$a3, 256, finished_resetting_check_board
	move	$s6, $v0
	move	$s7, $v1
	jal	get_xy
	move	$a1, $v0
	move	$a2, $v1
	jal	getChar_atXY
	beq	$v0, 1, reset_check_board_cont
	beq	$v0, 2, reset_check_board_cont
	addi	$t9, $t9, 1
reset_check_board_cont:
	move	$v0, $s6
	move	$v1, $s7
	sll	$t7, $a3, 2
	sw	$0, check_board($t7)			# store 0 at check_board[check_counter]
	addi	$a3, $a3, 1				# check_counter++
	j	reset_check_board
finished_resetting_check_board:
	sw	$t9, num_flipped($0)
	beq	$t9, 216, won_game		# If num_flipped == 216 --> won_game
	j	return_from_move_player

# =============================================================

flag_tile:
	li	$a0, 191113
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 0
	jal	put_sound
	li	$a0, 2				# set equal charcode for unflipped flag
	sw	$a0, sprite_char($0)		# set sprite_char equal to flag
	jal	putChar_atXY
	j	return_from_move_player

unflag_tile:
	li	$a0, 202478
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 0
	jal	put_sound
	li	$a0, 1				# set equal charcode for unflipped blank
	sw	$a0, sprite_char($0)		# set sprite_char equal to blank
	jal	putChar_atXY
	j	return_from_move_player

# =============================================================

lost_game:
	# call proc to reveal all BOMBS (leave blanks and numbers unrevealed)
	# play sound signaling loss
	li	$a0, 21845
	jal	put_leds
	li	$a0, 303370
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 340530
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 382219
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 0
	jal	put_sound
	li	$a0, 13
	sw	$a0, real_board($t7)		# $t7 still has i<<2 at this point
	jal	putChar_atXY			# putChar_atXY of red bomb
	j	reveal_bombs
reveal_bombs:
	li	$a3, 0			# set counter variable i=0
reveal_bombs_loop:
	slti	$t1, $a3, 256		# if i<256, continue the loop
	bne	$t1, 1, reset_game
	sll	$t2, $a3, 2		# Multiply by 4
	lw	$a0, real_board($t2)
	bne	$a0, 12, reveal_bombs_increment
	jal	get_xy
	move	$a1, $v0
	move	$a2, $v1
	jal	putChar_atXY
reveal_bombs_increment:
	addi	$a3, $a3, 1		# i++
	j	reveal_bombs_loop

# =============================================================

reset_game:
	li	$a0, 30
	jal	pause_and_getkey
	addi	$a1, $a1, 1		# counter variable for generating random real_board
	#move	$s0, $a1
reset_game_checker:
	beq	$v0, 0, reset_game
reset_game_load:
	li	$t0, 1
	sw	$t0, sprite_char($0)
	sw	$0, num_bombs($0)
	sw	$0, num_flipped($0)
	li	$a3, 0
	li	$a0, 1
reset_game_loop:
	slti	$t1, $a3, 256		# if i<256, continue the loop
	bne	$t1, 1, reset_game_finish
	jal	get_xy
	move	$a1, $v0
	move	$a2, $v1
	jal	putChar_atXY
	sll	$t2, $a3, 2		# Multiply by 4
	sw	$0, real_board($t2)
	sw	$0, check_board($t2)
	addi	$a3, $a3, 1
	j	reset_game_loop
reset_game_finish:
	li	$a0, 0
	jal	put_leds
	j	main

# =============================================================

won_game:
	li	$a0, 65535
	jal	put_leds		# Light up all 16 LEDs
	li	$a0, 303370
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 340530
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 382219
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 303370
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 340530
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 382219
	jal	put_sound
	li	$a0, 20
	jal	pause
	li	$a0, 0
	jal	put_sound
	j	reset_game

# =============================================================

done_moving:
	# Call getChar_atXY
	# Store charcode in memory
	# Call putChar_atXY for selector sprite
	move	$a1, $v0		# $a1 has x value
	move	$a2, $v1		# $a2 has y value
	jal	getChar_atXY		# get char of new tile
	sw	$v0, sprite_char($0)	# store char in memory
	move	$v0, $a1		# restore the value of $a1 to $v1 (return register)
	li	$a0, 0			# load the selector char (0)
	jal	putChar_atXY		# $a0 is char, $a1 is X, $a2 is Y
	j	return_from_move_player

return_from_move_player:
    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    jr      $ra             # Return from procedure

# =============================================================

# Parameters: $a1 = random number (seed)
gen_minefield:	
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
	sw      $ra, 4($sp)         # Save $ra
	sw      $fp, 0($sp)         # Save $fp
	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
	
	li	$s0, 0			# num_bombs counter variable
					# seed in $a1
	li	$t0, 257		# load N = 257
	li	$t1, 139		# load K = 139
	li	$t6, 0			# load make_more_rand = 0
	
	add	$t2, $t1, $a1		# compute seed+K in $t2
	j	checking_valid_rand
random_number_generator: 		# Randomly select number from 0 to 255
	add	$t2, $t2, $a1		# compute seed+K in $t2
	addi	$t6, $t6, 1		# make_more_rand++
checking_valid_rand:
	slt	$t3, $t2, $t0		# if sum less than N (what you want), set t3 to 1 else set t3 to 0
	beq	$t3, 1, place_bomb
mod_loop:
	sub	$t2, $t2, $t0				# mod operation:  if sum is larger than 257, then subtract 257.
	# Could subtract 1 from K here?
	j	checking_valid_rand
place_bomb:						# random number in $t2
	slti	$t3, $t2, 256				# if random number is less than 256 --> set $t3 to 1
	bne	$t3, 1, random_number_generator	# if random number is out of range, get a new random number
	sll	$t7, $t2, 2
	lw	$t4, real_board($t7)			# get real_board[random number] in $t4
	li	$t5, 12					# value for bomb charcode
	beq	$t4, $t5, random_number_generator	# if real_board[random number] has bomb, select new number
	
	beq	$t6, 3, make_more_rand1
	beq	$t6, 5, make_more_rand2
	beq	$t6, 8, make_more_rand3
	beq	$t6, 13, make_more_rand4
rest_of_place_bomb:
	sw	$t5, real_board($t7)			# else, place bomb (set value to 12) at real_board[random number]
	lw	$t3, num_bombs($0)			# load num_bombs into $t3
	addi	$t3, $t3, 1				# increment num_bombs
	sw	$t3, num_bombs($0)
	slti	$t4, $t3, 40				# if num_bombs < 40, set $t4 equal to 1
	beq	$t4, 1, random_number_generator	# if num_bombs < 40, continue placing bombs
	li	$a0, 0					# if num_bombs == 40, set counter variable i=0 ($a0)
	j	fill_board_numbers			# call fill_board numbers

make_more_rand1:
	li	$t1, 167				# load 167 into K
	addi	$t6, $t6, 1				# make_more_rand++
	addi	$t7, $t7, 4				# choose random number + 1
	slti	$t4, $t7, 256
	bne	$t4, 1, random_number_generator	# if random number is out of range, choose new one
	lw	$t4, real_board($t7)			# get real_board[random number + 1] in $t4
	beq	$t4, $t5, random_number_generator	# if real_board[random number + 1] has bomb, select new number
	j	rest_of_place_bomb
make_more_rand2:
	li	$t1, 143				# load 143 into K
	addi	$t6, $t6, 1				# make_more_rand++
	addi	$t7, $t7, -8				# choose random number - 2
	slti	$t4, $t7, 0
	bne	$t4, 0, random_number_generator	# if random number is out of range, choose new one
	lw	$t4, real_board($t7)			# get real_board[random number - 2] in $t4
	beq	$t4, $t5, random_number_generator	# if real_board[random number - 2] has bomb, select new number
	j	rest_of_place_bomb
make_more_rand3:
	li	$t1, 133				# load 133 into K
	addi	$t6, $t6, 1				# make_more_rand++
	addi	$t7, $t7, -4				# choose random number - 1
	slti	$t4, $t7, 0
	bne	$t4, 0, random_number_generator	# if random number is out of range, choose new one
	lw	$t4, real_board($t7)			# get real_board[random number - 1] in $t4
	beq	$t4, $t5, random_number_generator	# if real_board[random number - 1] has bomb, select new number
	j	rest_of_place_bomb
make_more_rand4:
	li	$t1, 151				# load 151 into K
	li	$t6, 1					# set make_more_rand back to 1
	addi	$t7, $t7, 8				# choose random number + 2
	slti	$t4, $t7, 256
	bne	$t4, 1, random_number_generator	# if random number is out of range, choose new one
	lw	$t4, real_board($t7)			# get real_board[random number + 2] in $t4
	beq	$t4, $t5, random_number_generator	# if real_board[random number + 2] has bomb, select new number
	j	rest_of_place_bomb

fill_board_numbers: # Now counter variable i in $a0
	beq	$a0, 256, return_from_gen_minefield	# if i==256 ($a0==256) --> return_from_gen_minefield
	sll	$t7, $a0, 2
	lw	$t0, real_board($t7)			# get real_board[i] in $t0
	beq	$t0, 12, set_bomb			# if real_board[i] == 12 (bomb) --> return_from_count_adjacent
	li	$a1, 0					# set counter variable mine_count=0 ($a1)
	jal	count_adjacent
	addi	$t1, $a1, 3				# add 3 to the mine_count (to match up with the sprite number)
	sll	$t7, $a0, 2
	sw	$t1, real_board($t7)			# store the value of $a1+3 at real_board[i]
	addi	$a0, $a0, 1				# i++
	j	fill_board_numbers
set_bomb:
	li	$t1, 12					# load charcode number of bomb into $t1
	sll	$t7, $a0, 2
	sw	$t1, real_board($t7)			# store the bomb at real_board[i]
	addi	$a0, $a0, 1				# i++
	j	fill_board_numbers

return_from_gen_minefield:
	addi    $sp, $fp, 4     # Restore $sp
	lw      $ra, 0($fp)     # Restore $ra
	lw      $fp, -4($fp)    # Restore $fp
	jr      $ra             # Return from procedure

# =============================================================

# Parameters: $a0 = i; $a1 = mine_count; returns $v0 = mine_count --> MUST IMPLEMENT THIS!
count_adjacent:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
	sw      $ra, 4($sp)         # Save $ra
	sw      $fp, 0($sp)         # Save $fp
	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
	
	sll	$t7, $a0, 2
	lw	$t0, real_board($t7)			# get real_board[i] in $t0
	beq	$t0, 12, return_from_count_adjacent	# if real_board[i] == 12 (bomb) --> return_from_count_adjacent

# real_board is ROW-WISE! Meaning row 0 --> row 1 --> ... --> row 15	
first_neighbor: # 1st Neighbor (North): (row-1, col) --> real_board[i-16]
	addi	$t0, $a0, -16				# x = i-16 in $t0
	slt	$t1, $t0, $0				# if x < 0 (out of bounds), set $t1=1, only need to check for <0 for 1st neighbor
	bne	$t1, $0, second_neighbor		# if not a valid tile, go to 2nd neighbor
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, second_neighbor		# if real_board[x] != 12, go to 2nd neighbor
	addi	$a1, $a1, 1				# else mine_count++
second_neighbor: # 2nd Neighbor (South): (row+1, col) --> real_board[i+16]
	addi	$t0, $a0, 16				# x = i+16 in $t0
	slti	$t1, $t0, 256				# if x < 256 (in bounds), set $t1=1, only need to check for >=255 for 2nd neighbor
	beq	$t1, $0, third_neighbor		# if not a valid tile, go to 3rd neighbor
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, third_neighbor		# if real_board[x] != 12, go to 3rd neighbor
	addi	$a1, $a1, 1				# else mine_count++
third_neighbor: # 3rd Neighbor (East): (row, col+1) --> real_board[i+1] --> if $a0 == (multiple of 16)-1 then out of bounds
	addi	$t0, $a0, 1				# x = i+1 in $t0
	add	$t1, $a0, $0				# copy i in $a0 to $t1
third_sub_loop:						# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, third_sub_loop			# continue looping addi -16 if $t1 is not negative
	beq	$t1, -1, fourth_neighbor		# if first negative value ($t1) == -1, then out of bounds
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, fourth_neighbor		# if real_board[x] != 12, go to 4th neighbor
	addi	$a1, $a1, 1				# else mine_count++
fourth_neighbor: # 4th Neighbor (West): (row, col-1) --> real_board[i-1] --> if $a0 = (multiple of 16) then out of bounds
	addi	$t0, $a0, -1				# x = i-1 in $t0
	add	$t1, $a0, $0				# copy i in $a0 to $t1
fourth_sub_loop:					# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, fourth_sub_loop		# continue looping addi -16 if $t1 is not negative
	beq	$t1, -16, fifth_neighbor		# if first negative value ($t1) == -16, then out of bounds
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, fifth_neighbor		# if real_board[x] != 12, go to 5th neighbor
	addi	$a1, $a1, 1				# else mine_count++
fifth_neighbor: # 5th Neighbor (North-East): (row-1, col+1) --> real_board[i-15]
	addi	$t0, $a0, -15				# x = i-15 in $t0
	slt	$t1, $t0, $0				# if x < 0 (out of bounds), set $t1=1
	bne	$t1, $0, sixth_neighbor		# if not a valid tile, go to 6th neighbor
	add	$t1, $a0, $0				# copy i in $a0 to $t1
fifth_sub_loop:						# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, fifth_sub_loop			# continue looping addi -16 if $t1 is not negative
	beq	$t1, -1, sixth_neighbor		# if first negative value ($t1) == -1, then out of bounds
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, sixth_neighbor		# if real_board[x] != 12, go to 6th neighbor
	addi	$a1, $a1, 1				# else mine_count++
sixth_neighbor: # 6th Neighbor (North-West): (row-1, col-1) --> real_board[i-17]
	addi	$t0, $a0, -17				# x = i-17 in $t0
	slt	$t1, $t0, $0				# if x < 0 (out of bounds), set $t1=1
	bne	$t1, $0, seventh_neighbor		# if not a valid tile, go to 7th neighbor
	add	$t1, $a0, $0				# copy i in $a0 to $t1
sixth_sub_loop:						# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, sixth_sub_loop			# continue looping addi -16 if $t1 is not negative
	beq	$t1, -16, seventh_neighbor		# if first negative value ($t1) == -16, then out of bounds
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, seventh_neighbor		# if real_board[x] != 12, go to 7th neighbor
	addi	$a1, $a1, 1				# else mine_count++
seventh_neighbor: # 7th Neighbor (South-East): (row+1, col+1) --> real_board[i+17]
	addi	$t0, $a0, 17				# x = i+17 in $t0
	slti	$t1, $t0, 256				# if x < 256 (in bounds), set $t1=1
	beq	$t1, $0, eighth_neighbor		# if not a valid tile, go to 8th neighbor
	add	$t1, $a0, $0				# copy i in $a0 to $t1
seventh_sub_loop:					# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, seventh_sub_loop		# continue looping addi -16 if $t1 is not negative
	beq	$t1, -1, eighth_neighbor		# if first negative value ($t1) == -1, then out of bounds
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, eighth_neighbor		# if real_board[x] != 12, go to 6th neighbor
	addi	$a1, $a1, 1				# else mine_count++	
eighth_neighbor: # 8th Neighbor (South-West): (row+1, col-1) --> real_board[i+15]
	addi	$t0, $a0, 15				# x = i+15 in $t0
	slti	$t1, $t0, 256				# if x < 256 (in bounds), set $t1=1
	beq	$t1, $0, return_from_count_adjacent	# if not a valid tile, return_from_count_adjacent
	add	$t1, $a0, $0				# copy i in $a0 to $t1
eighth_sub_loop:					# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, eighth_sub_loop		# continue looping addi -16 if $t1 is not negative
	beq	$t1, -16, return_from_count_adjacent	# if first negative value ($t1) == -16, then out of bounds
	sll	$t7, $t0, 2
	lw	$t1, real_board($t7)			# load real_board[x] in $t1
	bne	$t1, 12, return_from_count_adjacent	# if real_board[x] != 12, return_from_count_adjacent
	addi	$a1, $a1, 1				# else mine_count++

return_from_count_adjacent:
	addi    $sp, $fp, 4     # Restore $sp
	lw      $ra, 0($fp)     # Restore $ra
	lw      $fp, -4($fp)    # Restore $fp
	jr      $ra             # Return from procedure

# =============================================================

# Parameters: $a1 has x, $a2 has y, $a3 has i, return nothing
recursive_flip:
    addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    sw      $ra, 4($sp)         # Save $ra
    sw      $fp, 0($sp)         # Save $fp
    addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
    
    # Save any $sx registers that proc1 will modify
    addi    $sp, $sp, -12       # e.g., $s1, $s2, $s3
    sw      $s1, 8($sp)         # Save $s1
    sw      $s2, 4($sp)         # Save $s2
    sw      $s3, 0($sp)         # Save $s3
	
	# Base case: if checked --> return_from_recursive_flip
	sll	$t7, $a3, 2
	lw	$t0, check_board($t7)			# load check_board[i] in $t0
	beq	$t0, 1, return_from_recursive_flip
	
	# Base case: if number --> mark as checked, putChar_atXY --> return_from_recursive_flip
	# Don't need sll because $t7 already has $a3<<2
	li	$t0, 1
	sw	$t0, check_board($t7)			# mark as checked
	lw	$a0, real_board($t7)			# load real_board[i] into $a0
	jal	putChar_atXY				# putChar_atXY for real_board[i]
	beq	$a0, 3, recursive_first_neighbor	# if real_board[i] is blank, go to recursive case
	j	return_from_recursive_flip

recursive_first_neighbor: # 1st Neighbor (North): (row-1, col) --> real_board[i-16]
	addi	$t0, $a3, -16				# new_i (x) = i-16 in $t0
	slt	$t1, $t0, $0				# if new_i < 0 (out of bounds), set $t1=1
	bne	$t1, $0, recursive_second_neighbor	# if not a valid tile, go to 2nd neighbor
	move	$a3, $t0				# move new_i into $a3
	addi	$a2, $a2, -1				# new_y = old_y - 1
	jal	recursive_flip
	addi	$a2, $a2, 1				# return value of old y
	addi	$a3, $a3, 16				# return value of old i
recursive_second_neighbor: # 2nd Neighbor (South): (row+1, col) --> real_board[i+16]
	addi	$t0, $a3, 16				# new_i (x) = i+16 in $t0
	slti	$t1, $t0, 256				# if new_i < 256 (in bounds), set $t1=1
	beq	$t1, $0, recursive_third_neighbor	# if not a valid tile, go to 3rd neighbor
	move	$a3, $t0				# move new_i into $a3
	addi	$a2, $a2, 1				# new_y = old_y + 1
	jal	recursive_flip
	addi	$a2, $a2, -1				# return value of old y
	addi	$a3, $a3, -16				# return value of old i
recursive_third_neighbor: # 3rd Neighbor (East): (row, col+1) --> real_board[i+1] --> if $a0 == (multiple of 16)-1 then out of bounds
	addi	$t0, $a3, 1				# new_i (x) = i+1 in $t0
	add	$t1, $a3, $0				# copy i in $a3 to $t1
recursive_third_sub_loop:				# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, recursive_third_sub_loop	# continue looping addi -16 if $t1 is not negative
	beq	$t1, -1, recursive_fourth_neighbor	# if first negative value ($t1) == -1, then out of bounds
	move	$a3, $t0				# move new_i into $a3
	addi	$a1, $a1, 1				# new_x = old_x + 1
	jal	recursive_flip
	addi	$a1, $a1, -1				# return value of old x
	addi	$a3, $a3, -1				# return value of old i
recursive_fourth_neighbor: # 4th Neighbor (West): (row, col-1) --> real_board[i-1] --> if $a0 = (multiple of 16) then out of bounds
	addi	$t0, $a3, -1				# new_i (x) = i-1 in $t0
	add	$t1, $a3, $0				# copy i in $a3 to $t1
recursive_fourth_sub_loop:				# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, recursive_fourth_sub_loop	# continue looping addi -16 if $t1 is not negative
	beq	$t1, -16, recursive_fifth_neighbor	# if first negative value ($t1) == -16, then out of bounds
	move	$a3, $t0				# move new_i into $a3
	addi	$a1, $a1, -1				# new_x = old_x - 1
	jal	recursive_flip
	addi	$a1, $a1, 1				# return value of old x
	addi	$a3, $a3, 1				# return value of old i
recursive_fifth_neighbor: # 5th Neighbor (North-East): (row-1, col+1) --> real_board[i-15]
	addi	$t0, $a3, -15				# new_i (x) = i-15 in $t0
	slt	$t1, $t0, $0				# if x < 0 (out of bounds), set $t1=1
	bne	$t1, $0, recursive_sixth_neighbor	# if not a valid tile, go to 6th neighbor
	add	$t1, $a3, $0				# copy i in $a3 to $t1
recursive_fifth_sub_loop:				# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, recursive_fifth_sub_loop	# continue looping addi -16 if $t1 is not negative
	beq	$t1, -1, recursive_sixth_neighbor	# if first negative value ($t1) == -1, then out of bounds
	move	$a3, $t0				# move new_i into $a3
	addi	$a1, $a1, 1
	addi	$a2, $a2, -1
	jal	recursive_flip
	addi	$a1, $a1, -1
	addi	$a2, $a2, 1
	addi	$a3, $a3, 15
recursive_sixth_neighbor: # 6th Neighbor (North-West): (row-1, col-1) --> real_board[i-17]
	addi	$t0, $a3, -17				# new_i (x) = i-17 in $t0
	slt	$t1, $t0, $0				# if x < 0 (out of bounds), set $t1=1
	bne	$t1, $0, recursive_seventh_neighbor	# if not a valid tile, go to 7th neighbor
	add	$t1, $a3, $0				# copy i in $a3 to $t1
recursive_sixth_sub_loop:					# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, recursive_sixth_sub_loop	# continue looping addi -16 if $t1 is not negative
	beq	$t1, -16, recursive_seventh_neighbor	# if first negative value ($t1) == -16, then out of bounds
	move	$a3, $t0				# move new_i into $a3
	addi	$a1, $a1, -1
	addi	$a2, $a2, -1
	jal	recursive_flip
	addi	$a1, $a1, 1
	addi	$a2, $a2, 1
	addi	$a3, $a3, 17
recursive_seventh_neighbor: # 7th Neighbor (South-East): (row+1, col+1) --> real_board[i+17]
	addi	$t0, $a3, 17				# new_i (x) = i+17 in $t0
	slti	$t1, $t0, 256				# if x < 256 (in bounds), set $t1=1
	beq	$t1, $0, recursive_eighth_neighbor	# if not a valid tile, go to 8th neighbor
	add	$t1, $a3, $0				# copy i in $a3 to $t1
recursive_seventh_sub_loop:				# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, recursive_seventh_sub_loop	# continue looping addi -16 if $t1 is not negative
	beq	$t1, -1, recursive_eighth_neighbor	# if first negative value ($t1) == -1, then out of bounds
	move	$a3, $t0				# move new_i into $a3
	addi	$a1, $a1, 1
	addi	$a2, $a2, 1
	jal	recursive_flip
	addi	$a1, $a1, -1
	addi	$a2, $a2, -1
	addi	$a3, $a3, -17
recursive_eighth_neighbor: # 8th Neighbor (South-West): (row+1, col-1) --> real_board[i+15]
	addi	$t0, $a3, 15				# new_i (x) = i+15 in $t0
	slti	$t1, $t0, 256				# if x < 256 (in bounds), set $t1=1
	beq	$t1, $0, return_from_recursive_flip	# if not a valid tile, return_from_count_adjacent
	add	$t1, $a3, $0				# copy i in $a3 to $t1
recursive_eighth_sub_loop:				# returns first negative value of looping addi -16
	addi	$t1, $t1, -16
	slt	$t2, $t1, $0				# set $t2=1 if $t1 is negative
	bne	$t2, 1, recursive_eighth_sub_loop	# continue looping addi -16 if $t1 is not negative
	beq	$t1, -16, return_from_recursive_flip	# if first negative value ($t1) == -16, then out of bounds
	move	$a3, $t0				# move new_i into $a3
	addi	$a1, $a1, -1
	addi	$a2, $a2, 1
	jal	recursive_flip
	addi	$a1, $a1, 1
	addi	$a2, $a2, -1
	addi	$a3, $a3, -15

return_from_recursive_flip:
    lw  $s1,  -8($fp)           # Restore $s1
    lw  $s2, -12($fp)           # Restore $s2
    lw  $s3, -16($fp)           # Restore $s3

    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    jr      $ra             # Return from procedure

# =============================================================

# Parameters: $a1 has x, $ a2 has y; $v0 has index (-1 if error)
get_index:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
	sw      $ra, 4($sp)         # Save $ra
	sw      $fp, 0($sp)         # Save $fp
	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
	
	# check if in bounds first
	slti	$t0, $a1, 12			# make sure X >= 12
	beq	$t0, 1, get_index_error
	slti 	$t0, $a1, 28			# make sure X < 28
	bne	$t0, 1, get_index_error
	slti	$t0, $a2, 7			# make sure Y >= 7
	beq	$t0, 1, get_index_error
	slti	$t0, $a2, 23			# make sure Y < 23
	bne	$t0, 1, get_index_error
	# get index (I) for entire screen
	li	$v0, 0				# set I = 0 in $v0
	li	$t1, 0				# set add_40_counter = 0 in $t1
get_index_add_40:
	slt	$t0, $t1, $a2			# if add_40_counter < y
	bne	$t0, 1, get_index_add_x	# just add the x value to I
	addi	$v0, $v0, 40			# else add 40 to I
	addi	$t1, $t1, 1			# add_40_counter++
	j	get_index_add_40
get_index_add_x:
	add	$v0, $v0, $a1			# add x value to I
get_index_i:	# get i for real_board from I for whole screen
	addi	$v0, $v0, -292			# subtract (i=0 is at I=292) 292 from $v0
	addi	$t1, $a2, -7			# subtract 7 from y (for number of rows above game board) and store in $t1
get_index_sub_24:
	slti	$t0, $t1, 1			# if real_board_y is 0
	beq	$t0, 1, return_from_get_index	# then $v0 has the correct i
	addi	$v0, $v0, -24			# subtract 24 from $v0 $t1 times
	addi	$t1, $t1, -1			# counter--
	j	get_index_sub_24
get_index_error:
	li	$v0, -1
	j	return_from_get_index

return_from_get_index:
	addi    $sp, $fp, 4     # Restore $sp
	lw      $ra, 0($fp)     # Restore $ra
	lw      $fp, -4($fp)    # Restore $fp
	jr      $ra             # Return from procedure

# =============================================================

# Parameters: $a3 has i (leaves unchanged), $v0 has x, $v1 has y
get_xy:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
	sw      $ra, 4($sp)         # Save $ra
	sw      $fp, 0($sp)         # Save $fp
	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame

	li	$v0, 12				# x begins at 12 (0 value)
	li	$v1, 7				# y begins at 7 (0 value)
	move	$t0, $a3			# i in $t0
get_xy_sub_16:
	addi	$t0, $t0, -16			# sub 16 from i
	slt	$t1, $t0, $0			# if i is negative
	beq	$t1, 1, get_xy_add_x		# then stop the loop
	addi	$v1, $v1, 1			# y++
	j	get_xy_sub_16
get_xy_add_x:
	addi	$t0, $t0, 16			# add 16 to i to make it positive x value
	add	$v0, $v0, $t0			# add i to $v0 to get real x value

	addi    $sp, $fp, 4     # Restore $sp
	lw      $ra, 0($fp)     # Restore $ra
	lw      $fp, -4($fp)    # Restore $fp
	jr      $ra             # Return from procedure

# =============================================================

.include "procs_board.asm"               # Use this line for board implementation