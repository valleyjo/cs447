.data
	msg_hit_stand:		.asciiz "\n\nWould you like to \"hit\" or \"stand\"? "
	msg_exit:		.asciiz "\n\nI don't always waste money, but when I do it's at Soaring Eagle's Casino!"
	msg_welcome:		.asciiz "Welcome to Soraing Eagle's Casino \n"
	msg_name_prompt:	.asciiz "Please enter your name: "
	msg_dealer:		.asciiz "The dealer:\n" 
	msg_dealer_score:	.asciiz "? + "
	msg_colon:		.asciiz ":"
	msg_plus:		.asciiz " + "
	msg_equals_sign:	.asciiz " = "
	msg_blank_line:		.asciiz "\n"
	player_name:		.asciiz
	player_input:		.asciiz	

.text
#------------------------------------------------------------------------------
# Prepare the random number generator
#------------------------------------------------------------------------------

# get the time
li	$v0, 30				# get time in milliseconds (as a 64-bit value)
syscall

move	$t0, $a0			# save the lower 32-bits of time

# seed the random generator (just once)
li	$a0, 1				# random generator id (will be used later)
move 	$a1, $t0			# seed from time
li	$v0, 40				# seed random number generator syscall
syscall	

#------------------------------------------------------------------------------
# Display welcome message
#------------------------------------------------------------------------------

la	$a0, msg_welcome		# load the welcome message
li	$v0, 4
syscall					# print the welcome string

la	$a0, msg_name_prompt		# load the welcome prompt string
syscall					# Print the welcome input string prompt

la	$a0, player_name		# The start of the input buffer for the string that will be read
li	$a1, 20				# The maximum number of characters to read

li	$v0, 8				# Read the player's name
syscall

#------------------------------------------------------------------------------
# Give the dealer and the player 2 cards each to start
#------------------------------------------------------------------------------
BEGIN_PLAY:

jal	GET_CARD
move	$s0, $t0			# The dealer's hand value is held in $s0

jal	GET_CARD
add	$s0, $s0, $t0			# The dealer has been given two cards to start
move	$s2, $t0			# $s2 holds the dealer's most recent card as it is displayed to the other player

jal 	GET_CARD		
move	$s1, $t0			# The player's hand value is held in $s1
move	$s3, $t0			# The player's first card is held in $s3 (for display purposes)

jal	GET_CARD		
add	$s1, $s1, $t0			# The player has been given two cards to start
move 	$s4, $t0			# Player's second card is held in $s4 (for display purposes)

DEAL:

#------------------------------------------------------------------------------
# Display the dealer's total
# Output:
#  The Dealer:
#  ? + 4
#------------------------------------------------------------------------------
li	$v0, 4
la	$a0, msg_blank_line		# Line break
syscall

li	$v0, 4
la	$a0, msg_dealer			# Display "The Dealer:"
syscall

la	$a0, msg_dealer_score		# Display the dealer's score
syscall

move	$a0, $s2			# put the dealer's most recent card in the display register
li	$v0, 1
syscall

#------------------------------------------------------------------------------
# Display the player's total
# output: 
#  Alex:
#  10 + 4 = 14
#------------------------------------------------------------------------------
li	$v0, 4
la	$a0, msg_blank_line		# Line break
syscall

la	$a0, msg_blank_line		# Line break
syscall

la	$a0, player_name		# Display the player's name
syscall

#la	$a0, msg_colon			# Display a colon
#syscall

li	$v0, 1
move	$a0, $s3			# Display the player's first card
syscall

la	$a0, msg_plus			# Display a plus sign
li	$v0, 4
syscall

move	$a0, $s4			# Display the player's second card
li	$v0, 1
syscall

la	$a0, msg_equals_sign		# Display an equals sign
li	$v0, 4
syscall

move 	$a0, $s1			# Display the player's total
li	$v0, 1
syscall

#------------------------------------------------------------------------------
# Resume playing! :D
#------------------------------------------------------------------------------

li $t1, 17				# Dealer hits if his score is below this value, otherwise doesn't 

blt	$t1, $s0, PLAYER_HIT_CHECK	# branch to player prompt if 17 is less than the dealer's hand
jal	GET_CARD			 
add	$s0, $s0, $t0			# add a card to the dealer's hand

PLAYER_HIT_CHECK:			# Validate that the player has not busted before prompting the player to hit again
li	$t0, 21				# The value that constitues a bust
blt	$t0, $s1, CHECKS		# Branches to value checks if the player has busted

PROMPT_HIT:
la	$a0, msg_hit_stand		#Ask the user if he wants to hit
li	$v0, 4
syscall

la	$a0, player_input		# The start of the input buffer for the input string
li	$a1, 20				# The maximum number of characters to read

li	$v0, 8				# load read character syscall number			
syscall					# Read the player's input (hit or stand)

lb	$t0, player_input		# The first byte of player input
li	$t1, 104			# 'h' which is ASCII 104

bne	$t0, $t1, CHECKS		# if player input != "h*" branch to the check area
jal	GET_CARD
add	$s1, $s1, $t0			# add the new card's value to the player's total value
add	$s3, $s3, $s4			# add the player's first and second cards
move	$s4, $t0			# $s4 now holds the value of the most recent card

j	DEAL	

CHECKS:

	

#------------------------------------------------------------------------------
# Tell MARS to exit the program
#------------------------------------------------------------------------------
EXIT:

la $a0, msg_exit	# load the exit message
li $v0, 4		# load the print string instruction number
syscall			# print the exit string

li	$v0, 10		# exit syscall
syscall

#------------------------------------------------------------------------------
# Returns a card that was drawn from the deck
# The card is put into $t0
# Uses: $t0 $v0 $a0 $a1 $ra
#------------------------------------------------------------------------------
GET_CARD:

li	$a0, 1		# as said, this id is the same as random generator id
li	$a1, 11		# upper bound of the range
li	$v0, 42		# load the instruction for get ranndom number
syscall			# get the random number

# $a0 now holds the random number
addi	$a0, $a0, 1	# add 1 to the number so it is [1,11]

move 	$t0, $a0	# copy the random number to $t0
jr	$ra