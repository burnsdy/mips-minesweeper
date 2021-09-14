#############################################################################################
#
# Montek Singh
# COMP 541 Final Projects
# Nov 2, 2020
#
# This is a collection of helpful procedures for developing your final project demos.
#
# Use these in your actual MIPS code that is DEPLOYED ON THE BOARDS.
# (A separate version of a subset of these procedures is available for simulation in MARS.)
#
#
#
#    pause:         implements a pause of specified hundredths of second via busy looping
#    putChar_atXY:  puts a character at screen location (X, Y)
#    getChar_atXY:  reads the character from screen location (X, Y)
#    get_key:       reads keyboard and returns a match index from an array of scancodes
#    get_key2:      same as get_key but looks up a second array of scancodes (for player 2)
#    pause_and_getkey:  RESPONSIVE keyboard read + pause combined
#    pause_and_getkey_2player:  RESPONSIVE keyboard read + pause combined for 2 players
#    get_accel:     reads accelerometer value, format = {7'b0, accelX, 7'b0, accelY}
#    get_accelX:    reports just the X tilt value
#    get_accelY:    reports just the Y tilt value
#    put_sound:     sets the sound generator to a specified tone
#    sound_off:     turns sound off
#    put_leds:      set the LED lights to a specified pattern
#
#############################################################################################

.text	
		
	#########################################
	# pause(N), N is hundredths of a second #
	# assuming 12.5 MHz clock.              #
	# N is placed in $a0.                   #
	#########################################


pause:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$a0, 0($sp)
	sll     $a0, $a0, 16
	beq	$a0, $0, pse_done
pse_loop:
	addi    $a0, $a0, -1
	bne	$a0, $0, pse_loop
pse_done:
	lw	$a0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra


	#####################################
	# proc putChar_atXY                 #
	# write one char to (x,y) on screen #
	#                                   #
	#   $a0:  char                      #
	#   $a1:  x (col)                   #
	#   $a2:  y (row)                   #
	#                                   #
	# restores all registers            #
	#   before returning                #
	#####################################

.eqv screen_base 0x10020000 		# Base address of screen memory
	
putChar_atXY:	
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$t0, 8($sp)
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)
	
	li	$t0, screen_base 	# initialize to start address of screen:  0x10020000
	
	sll	$t1, $a2, 5		# t1 = a2 << 5
	sll	$t2, $a2, 3		# t2 = a2 << 3
	add	$t1, $t1, $t2		# t1 = (a2 << 5) + (a2 << 3) = 40*row
	add	$t1, $t1, $a1		# t1 = 40*row + col
	sll	$t1, $t1, 2		# (40*row + col) * 4 for memory addressing
	add	$t0, $t0, $t1		# add offset to screen base address
	
	sw 	$a0, 0($t0) 		# store character here
	
	lw	$ra, 12($sp)
	lw	$t0, 8($sp)
	lw	$t1, 4($sp)
	lw	$t2, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra


	#####################################
	# proc getChar_atXY                 #
	# read char from (x,y) on screen    #
	#                                   #
	#   $v0:  char read                 #
	#   $a1:  x (col)                   #
	#   $a2:  y (row)                   #
	#                                   #
	# restores all registers            #
	#   before returning                #
	#####################################
	
getChar_atXY:	
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$t0, 8($sp)
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)
	
	li	$t0, screen_base 	# initialize to start address of screen:  0x10020000
	
	sll	$t1, $a2, 5		# t1 = a2 << 5
	sll	$t2, $a2, 3		# t2 = a2 << 3
	add	$t1, $t1, $t2		# t1 = (a2 << 5) + (a2 << 3) = 40*row
	add	$t1, $t1, $a1		# t1 = 40*row + col
	sll	$t1, $t1, 2		# (40*row + col) * 4 for memory addressing
	add	$t0, $t0, $t1		# add offset to screen base address
	
	lw 	$v0, 0($t0) 		# read character from screen
	
	lw	$ra, 12($sp)
	lw	$t0, 8($sp)
	lw	$t1, 4($sp)
	lw	$t2, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra


	#####################################
	# proc get_key                      #
	# gets a key from the kayboard      #
	#                                   #
	#   $v0: 0 if no valid key          #
	#      : index 1 to N if valid key  #
	#                                   #
	# restores all registers            #
	#   before returning                #
	#####################################
	
.data
######                 a     d     w     s     f     space          # valid keys for which scancodes are on next line
key_array:	.word	0x1C, 0x23, 0x1D, 0x1B, 0x2B, 0x29   		# define as many scancodes here as you need
key_array_end:	    # marks end of key array, so number of keys can be calculated

## You can change the key scancodes above to suit your application.

.eqv keyb_mmio 0x10030000 		# from our memory map

.text
get_key:
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$t0, 8($sp)
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)

	lw	$v0, keyb_mmio($0)
	beq	$v0, $0, get_key_exit	# return 0 if no key available
	move	$t1, $v0
	
	li	$v0, 0
	la  $t0, key_array
	la  $t2, key_array_end
	sub $t2, $t2, $t0
	
get_key_loop:				# iterate through key_array to find match
	lw	$t0, key_array($v0)
	addi	$v0, $v0, 4		# go to next array element
	beq	$t0, $t1, get_key_exit
	slt	$1, $v0, $t2
	bne	$1, $0, get_key_loop
	li	$v0, 0			# key not found in key_array
	
get_key_exit:
	srl	$v0, $v0, 2		# index of key found = offset by 4
	lw	$ra, 12($sp)
	lw	$t0, 8($sp)
	lw	$t1, 4($sp)
	lw	$t2, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra


	#####################################
	# proc get_key2                     #
	# gets a key from the kayboard      #
	#                                   #
	#   $v0: 0 if no valid key          #
	#      : index 1 to N if valid key  #
	#                                   #
	# restores all registers            #
	#   before returning                #
	#####################################
	
.data
######                  ‘j’    ‘l’   ‘i’   ’k’          # valid keys for which scancodes are on next line
key_array2:	.word	0x3B, 0x4B, 0x43, 0x42   	# define as many scancodes here as you need
key_array_end2:     # marks end of key array, so number of keys can be calculated

## You can change the key scancodes above to suit your application.

.text
get_key2:
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$t0, 8($sp)
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)

	lw	$v0, keyb_mmio($0)
	beq	$v0, $0, get_key_exit2	    # return 0 if no key available
	move	$t1, $v0
	
	li	$v0, 0
	la  $t0, key_array2
	la  $t2, key_array_end2
	sub $t2, $t2, $t0

get_key_loop2:				# iterate through key_array to find match
	lw	$t0, key_array2($v0)
	addi	$v0, $v0, 4		# go to next array element
	beq	$t0, $t1, get_key_exit2
	slt	$1, $v0, $t2
	bne	$1, $0, get_key_loop2
	li	$v0, 0			# key not found in key_array
	
get_key_exit2:
	srl	$v0, $v0, 2		# index of key found = offset by 4
	lw	$ra, 12($sp)
	lw	$t0, 8($sp)
	lw	$t1, 4($sp)
	lw	$t2, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra


	#########################################
	# pause_and_getkey(N),                  #
	# N is hundredths of a second           #
	# assuming 12.5 MHz clock.              #
	# N is placed in $a0.                   #
	#                                       #
	#   $v0: value returned by get_key      #
	#     if key != 0 at any time           #
    #     during the pause, the latest      #
    #     non-zero key value is returned;   #
    #     else, 0 is returned.              #
	#########################################

pause_and_getkey:
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$a0, 4($sp)
	sw  $s0, 0($sp)
	li  $s0, 0
	sll $a0, $a0, 12
	beq	$a0, $0, pgk_done
pgk_loop:
	jal	get_key
	beq $v0, $0, pgk_inc
	move $s0, $v0            # if key !=0, copy it to $s0
pgk_inc:
	addi $a0, $a0, -1
	bne	 $a0, $0, pgk_loop
pgk_done:
	move $v0, $s0
	lw	$s0, 0($sp)
	lw	$a0, 4($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra


	#########################################
	# pause_and_getkey_2player(N),          #
	# N is hundredths of a second           #
	# assuming 12.5 MHz clock.              #
	# N is placed in $a0.                   #
	# Returns 2 key values (for 2 players)  #
	#                                       #
	#   $v0: value returned by get_key      #
	#     if key != 0 at any time           #
    #     during the pause, the latest      #
    #     non-zero key value is returned;   #
    #     else, 0 is returned.              #
	#                                       #
	#   $v1: value returned by get_key2     #
	#     if key != 0 at any time           #
    #     during the pause, the latest      #
    #     non-zero key value is returned;   #
    #     else, 0 is returned.              #
	#########################################

pause_and_getkey_2player:
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	sw  $s0, 4($sp)
	sw  $s1, 0($sp)
	li  $s0, 0
	li  $s1, 0
	
	sll $a0, $a0, 11
	beq	$a0, $0, pgk2_done
pgk2_loop:
	jal	get_key              # player 1 key
	beq $v0, $0, pgk2_A
	move $s0, $v0            # if key !=0, copy it to $s0
pgk2_A:
	jal	get_key2             # player 2 key
	beq $v0, $0, pgk2_inc
	move $s1, $v0            # if key !=0, copy it to $s1
pgk2_inc:
	addi $a0, $a0, -1
	bne	 $a0, $0, pgk2_loop
pgk2_done:
	move $v0, $s0
	move $v1, $s1
	
	lw	$s1, 0($sp)
	lw	$s0, 4($sp)
	lw	$a0, 8($sp)
	lw	$ra, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra


	#####################################
	# proc get_accel                    #
	# gets value from accelerometer     #
	#                                   #
	#   $v0: accel value                #
	#                                   #
	#####################################
	
.eqv accel_mmio 0x10030004 		# from our memory map

.text
get_accel:
	lw	$v0, accel_mmio($0)
	jr	$ra

get_accelX:
	lw	$v0, accel_mmio($0)
	srl	$v0, $v0, 16		# bits 16-24 is X accel (9 bits)
	andi	$v0, $v0, 0x01FF
	jr	$ra

get_accelY:
	lw	$v0, accel_mmio($0)
	andi	$v0, $v0, 0x01FF	# bits 0-8 is Y accel (9 bits)
	jr	$ra

	#####################################
	# proc put_sound                    #
	# generates a tone with a specified #
	#   period                          #
	#                                   #
	#   $a0: period (0 turns sound off) #
	#                                   #
	#####################################
	
.eqv sound_mmio 0x10030008 		# from our memory map

.text
put_sound:
	sw	$a0, sound_mmio($0)
	jr	$ra

sound_off:
	sw	$0, sound_mmio($0)
	jr	$ra


	#####################################
	# proc put_leds                     #
	# lights up a pattern on the        #
	#   16 LEDs                         #
	#                                   #
	#   $a0: pattern (lower 16 bits)    #
	#                                   #
	#####################################
	
.eqv leds_mmio 0x1003000C 		# from our memory map

.text
put_leds:
	sw	$a0, leds_mmio($0)
	jr	$ra
