# Name: Alex Vallejo
# Class: CS 447
# Date: 9/20/2013
# Project: Lab 2

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

# Get the random number
li	$a0, 1		# as said, this id is the same as random generator id
li	$a1, 5		# upper bound of the range
li	$v0, 42		# random int range
syscall

# $a0 now holds the random number
# print it
li	$v0, 1		# print integer syscall
syscall

##############################################################################
# Tell MARS to exit the program
##############################################################################
EXIT:
li	$v0, 10		# exit syscall
syscall
