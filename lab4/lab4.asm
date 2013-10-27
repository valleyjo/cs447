.data 
	space: .asciiz " "
	newline: .asciiz "\n"

	maze: .word 	1,1,1,1,1,1,1,1,
			3,0,0,0,0,0,0,1,
			1,1,1,1,1,1,0,1,
			1,2,1,0,0,0,0,1,
			1,0,1,0,1,0,1,1,
			1,0,1,1,1,0,1,1,
			1,0,0,0,0,0,1,1,
			1,1,1,1,1,1,1,1
			
.text

	jal	draw_maze

	li $v0, 10
	syscall

#---------------------------------------------------------------
# void draw_maze()
#   draws the maze on the screen
#   
# arguments: none
# trashes: none
# returns: none
#---------------------------------------------------------------
draw_maze:
	# --------
	# Prologue
	# --------
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)	

	li	$s0, 0	
rows:
	li	$s1, 0
	
cols:
	move	$a0, $s0
	move	$a1, $s1
	
	jal	maze_value_at
	move	$a2, $v0
	jal	_setLED
	
	#-Debug print statement-
	move	$a0, $a2
	li	$v0, 1
	syscall
	
	la	$a0, space
	li	$v0, 4
	syscall
	#---------------------
	
	addi $s1, $s1, 1			# change the column
	slti $t0, $s1, 8
	bne $t0, $zero, cols
	
	#-Debug print statement-
	la	$a0, newline
	li	$v0, 4
	syscall 
	# ---------------------
	
	addi $s0, $s0, 1			# change the row
	slti $t0, $s0, 8
	bne $t0, $zero, rows
		
	#---------
	# Prologue
	#---------
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra				# Return
	
#---------------------------------------------------------------
# int maze_value_at(int x, int y)
#   returns the value of the maze array at the location (x, y)
#
#  warning:   x and y are assumed to be legal values (0-7,0-7)
#  arguments: $a0 holds x, $a1 holds y
#  trashes:   $t0-$t3
#  returns:   $v0 holds the value maze at the position
#---------------------------------------------------------------
maze_value_at:
	# compute maze[x][y] = location of maze in memory + (x * sizeof(row) + y * sizeof(cell))
	la	$t0, maze
	sll	$t1, $a0, 2
	sll	$t2, $a1, 2
	add	$t3, $t1, $t2
	add	$t0, $t0, $t3
	lb	$v0, 0($t0)
	jr   	$ra
	
#---------------------------------------------------------------
# void _setLED(int x, int y, int color)
#   sets the LED at (x,y) to color
#   color: 0=off, 1=red, 2=orange, 3=green
#
# warning:   x, y and color are assumed to be legal values (0-63,0-63,0-3)
# arguments: $a0 is x, $a1 is y, $a2 is color 
# trashes:   $t0-$t3
# returns:   none
#---------------------------------------------------------------
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra

#---------------------------------------------------------------
# int _getLED(int x, int y)
#   returns the value of the LED at position (x,y)
#
#  warning:   x and y are assumed to be legal values (0-63,0-63)
#  arguments: $a0 holds x, $a1 holds y
#  trashes:   $t0-$t2
#  returns:   $v0 holds the value of the LED (0, 1, 2, 3)
#---------------------------------------------------------------
_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra


	# int _getKeyPress(void)
	#	returns the key last pressed, unless there is none
	#
	# trashes: $t0-$t1
	# returns in $v0:
	#	0	No key pressed
	# 	0x42	Middle button pressed
	# 	0xE0	Up arrow 
	# 	0xE1	Down arrow 
	# 	0xE2	Left arrow 
	# 	0xE3 Right arrow
	#
_getKeyPress:
	la	$t1, 0xffff0000			# status register
	li	$v0, 0				# default to no key pressed
	lw	$t0, 0($t1)			# load the status
	beq	$t0, $zero, _keypress_return	# no key pressed, return
	lw	$v0, 4($t1)			# read the key pressed
_keypress_return:
	jr $ra
