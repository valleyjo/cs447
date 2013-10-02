# Name: Alex Vallejo
# Class: CS 447
# Date: 9/20/2013
# Project: Lab 2

.data
	blank_line:	.asciiz "\n"
	msg_prompt:	.asciiz "Enter a number [0,10]:"
	msg_lower: 	.asciiz "\nGuess lower\n"
	msg_higher: 	.asciiz "\nGuess higher\n"
	msg_exit:	.asciiz "\nYou guessed correctly! Congradulations!\n"

.text
##############################################################################
# seed the random number generator
##############################################################################

# get the time
li	$v0, 30		# get time in milliseconds (as a 64-bit value)
syscall

move	$t0, $a0	# save the lower 32-bits of time

# seed the random generator (just once)
li	$a0, 1		# random generator id (will be used later)
move 	$a1, $t0	# seed from time
li	$v0, 40		# seed random number generator syscall
syscall

li	$a0, 1		# as said, this id is the same as random generator id
li	$a1, 11		# upper bound of the range
li	$v0, 42		# load the instruction for get ranndom number
syscall			# get the random number

# $a0 now holds the random number

move 	$t0, $a0	# copy the random number to $t0
li	$t9, 1		# load 1 in $t9 to use as comparison for the bew & slt combo

LOOP:
#Prompt the user for input
la 	$a0, msg_prompt
li 	$v0, 4
syscall 

#Display a blank line for formatting purposes
la	$a0, blank_line
li	$v0, 4
syscall

#Get the user's guess
li 	$v0, 5		# load the read int from keyboard instruction
syscall			# get the user's input
move	$t1, $v0	# $t1 is the user's guess

beq	$t1, $t0, EXIT	# EXIT if user's guess eq computer number

slt	$s0, $t1, $t0	# if user's guess is < comp's num, $s0 => 1

beq	$t9, $s0, LESSTHAN	# $t9 => 1. If user's guess is lower than computer guess go to lessthan
				# Else fall through
la 	$a0, msg_lower
li 	$v0, 4
syscall

j LOOP

LESSTHAN:
la	$a0, msg_higher
li	$v0, 4
syscall

j LOOP

##############################################################################
# Tell MARS to exit the program
##############################################################################
EXIT:

la $a0, msg_exit	# load the exit message
li $v0, 4		# load the print string instruction number
syscall			# print the exit string

li	$v0, 10		# exit syscall
syscall
