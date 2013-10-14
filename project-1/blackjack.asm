.data
	msg_hit_stand:		.asciiz "\n\nWould you like to \"hit\" or \"stand\": "
	msg_exit:		.asciiz "\nI don't always waste money, but when I do it's at Soaring Eagle's Casino!\n"
	msg_welcome:		.asciiz "Welcome to Soraing Eagle's Casino \n"
	msg_name_prompt:	.asciiz "Please enter your name: "
	msg_dealer:		.asciiz "The dealer\n" 
	msg_dealer_score:	.asciiz "? + "
	msg_colon:		.asciiz ":"
	msg_plus:		.asciiz " + "
	msg_equals_sign:	.asciiz " = "
	msg_blank_line:		.asciiz "\n"
	msg_player_busted:	.asciiz "\n\nYou busted. Dealer wins :(\n"
	msg_play_again:		.asciiz "\nWould you like to play again? "
	msg_dealer_busted:	.asciiz "\nThe dealer busted! You win :)\n"
	msg_player_win:		.asciiz "\nYou win! Congratulations!\n"
	msg_dealer_win:		.asciiz	"\nThe dealer wins! :(\n"
	msg_deck_empty:		.asciiz "\nThe deck is empty! You must really like this game. Please restart to re-shuffle the deck.\n"
	player_name:		.ascii	"ThisSpaceIs20Charact"
	player_input:		.ascii	"ThisSpaceIs20Charact"
	player_continue:	.ascii	"ThisSpaceIs20Charact"
	card_array:		.space	15 # only 1-11 are used. Skipping 0 makes the offset easier
					   # b/c you just add the card drawn to the address to get 
					   # the number of times that card was drawn

.text

#------------------------------------------------------------------------------
# Initializations
#------------------------------------------------------------------------------
li $s7, 21				# The value that constitues a bust, must be one higher than what the bust actually is

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

li $s5, 0				# The number of aces the player holds at any given time. It is reset each time a new game is started

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

DEAL:					# Adjust player's hand to reflect any drawn aces causing overflow 
					# Presents an interface with the player's and dealer's score
jal ADJUST_ACES			
					
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

PLAYER_HIT_CHECK:			# Validate that the player has not busted before prompting the player to hit again
ble	$s1, $s7, PROMPT_HIT		# Asks the player to hit if he has not busted,
					
jal	ADJUST_ACES			# IF he has busted, call the ace adjustment function

ble	$s7, $s1, CHECKS		# IF the player is still busted after calling ADJUST_ACES
					# branch to the CHECKS section where the winner will be decided!

PROMPT_HIT:
la	$a0, msg_hit_stand		#Ask the user if they want to hit
li	$v0, 4
syscall

la	$a0, player_input		# The start of the input buffer for the input string
li	$a1, 20				# The maximum number of characters to read

li	$v0, 8				# load read string syscall number			
syscall					# Read the player's input (hit or stand)

lb	$t0, player_input		# The first byte of player input
li	$t1, 104			# 'h' which is ASCII 104

bne	$t0, $t1, CHECKS		# if player input != "h*" branch to the check area
jal	GET_CARD

li	$t1, 11

bne	$t0, $t1, PLAYER_ADD_CARD	# branch to player add card if the card drawn is not an ace
addi	$s5, $s5, 1			# if the drawn card is an ace, add 1 to the number of aces the player holds

PLAYER_ADD_CARD:
add	$s1, $s1, $t0			# add the new card's value to the player's total value
add	$s3, $s3, $s4			# add the player's first and second cards
move	$s4, $t0			# $s4 now holds the value of the most recent card

j	DEAL	

CHECKS:

DEALER_HIT_LOOP:
li $t1, 17				# Dealer hits if his score is below this value, otherwise doesn't 

blt	$t1, $s0, PLAYER_BUST_CHECK	# branch to player prompt if 17 is less than the dealer's hand
jal	GET_CARD			# otherwise, add a hit to the dealer			 
add	$s0, $s0, $t0			# add the hit to the dealer's total
j	DEALER_HIT_LOOP

PLAYER_BUST_CHECK:
ble	$s1, $s7 DEALER_BUST_CHECK	# branch to check if the dealer busted if the player did not bust

la	$a0, msg_player_busted		# if the player busted, tell them!
li	$v0, 4
syscall

j 	PLAY_AGAIN			# Ask the player if they want to play again

DEALER_BUST_CHECK:
ble	$s0, $s7, PLAYER_WIN_CHECK	# If the dealer did not bust, check if the player won

la	$a0, msg_dealer_busted		# If dealer busted, tell the player
li	$v0, 4
syscall

j	PLAY_AGAIN

PLAYER_WIN_CHECK:
blt	$s1, $s0, DEALER_WIN		# if the player lost, branch to the dealer win

li	$v0, 4				
la	$a0, msg_player_win		# Print the message that the player won!
syscall

j 	PLAY_AGAIN			# Ask the player if they want to play again

DEALER_WIN:

li	$v0, 4
la	$a0, msg_dealer_win		# Prompt the player that the dealer won
syscall

PLAY_AGAIN:
li	$v0, 4
la	$a0, msg_play_again		# Ask the player if they want to play again
syscall

la	$a0, player_continue		# The start of the input buffer for the input string
li	$a1, 20				# The maximum number of characters to read

li	$v0, 8				# load read string syscall number			
syscall					# Read the player's input (hit or stand)

lb	$t0, player_continue		# load 'y' (ASCII 121) into $t0
li	$t1, 121			# grab the first byte of input from the user

beq	$t0, $t1, BEGIN_PLAY		# branch to the begining of the game if the player wants to play again 
					# (i.e. entered input begining with y)
					# otherwise fall through to exit

#------------------------------------------------------------------------------
# Tell MARS to exit the program
#------------------------------------------------------------------------------
EXIT:

la $a0, msg_exit	# load the exit message
li $v0, 4		# load the print string instruction number
syscall			# print the exit string

li	$v0, 10		# exit syscall
syscall

###############################################################################
# This function similates drawing a card from a deck.
# @return $t0 => the card that was drawn from the deck
# @uses $t0
#	$t9 is the memory address of the card array that allows you to draw from
#		an actual deck (not allowing over 4 of each card etc...)
#	$v0 
#	$a0 
#	$a1
#	$ra
###############################################################################
GET_CARD:

move 	$t7, $ra		# save the value of the program counter to get us back to the main game

jal	VERIFY_NON_EMPTY_DECK	# ensure that the deck is not empty!
				# IF the deck is empty, the displays a message and quits!

move 	$ra, $t7		#return the program counter to it's previous location

li	$a0, 1			# as said, this id is the same as random generator id
li	$a1, 11			# upper bound of the range
li	$v0, 42			# load the instruction for get ranndom number
syscall				# get the random number

# $a0 now holds the random number
addi	$a0, $a0, 1		# add 1 to the number so it is [1,11]

la	$t1, card_array		# Store the address of the card array in $t1
add	$t1, $t1, $a0		# Add the value of the card to $t1 for the required offset

lb	$t2, 0($t1)		# load the byte that represents the number of times the chosen card was drawn

li	$t3, 10			# 10 can be drawn 16 times, all the other cards can only be drawn 4 times

bne	$a0, $t3, OTHER_NUMBERS	# if 10 was not chosen, go to the area that handles the other numbers
# The card chosen is a 10
li	$t4, 16			# 10 can be drawn 16 times in a normal deck (4 10's + 4 jacks + 4 queens + 4 kings)
				# We use a blt so the number in $t4 must be one more than allowed

ble	$t2, $t4, VALID_CARD	# if the card was drawn less than the max, go to a valid card

j	GET_CARD		# if the card was drawn more than allowed, get a different card

OTHER_NUMBERS:
#The card chosen is not a ten
li	$t4, 4			# all cards can be drawn a maximum of 4 times
				# we use a blt so the number in $t4 must be one more than allowed
ble	$t2, $t4, VALID_CARD	# if the card was drawn less than the max allowed, branch to the valid card action

j	GET_CARD		# if the card was drawn more than allowed, get a different card

VALID_CARD:
addi	$t2, $t2, 1		# add 1 to the number of times that card was drawn 
sb	$t2, 0($t1)		# store that value in the memory location associated with that card
move 	$t0, $a0		# copy the card to $t0
jr	$ra			# return

###############################################################################
# Adjusts the player's score approperiatly based on the number of aces the 
# player holds
#
# @uses $s1 access and adjust the player's card values 
#	$s3 modify the first card value if necessiary
#	$s4 modify the second card value if necessiary
#	$s5 access and decrement the ace value
#	$t1 holds the value of an ace
#	$ra return
###############################################################################
ADJUST_ACES:

AA_LOOP:
beq	$s5, $0, RETURN			# IF the player has more than 0 aces
ble	$s1, $s7, RETURN		# AND IF the player has busted
					# CONTINUE

					# subtract the value of one ace, and chance the cards in his hand if necessiary
addi	$s1, $s1, -10			# subtract 10 from the player's score
addi	$s5, $s5, -1			# subtract 1 from the player's ace count

li	$t1, 11				# load the value of an ace

bne	$s4, $t1, ADJUST_SECOND_CARD	# IF the player's second card is not an ace, branch
li	$s4, 1				# ELSE change the player's second card to a 1

j	AA_LOOP

ADJUST_SECOND_CARD:
addi	$s3, $s3, -10			# subtract 10 from the second card value 

j	AA_LOOP				# loop again to subtract another ace's worth

RETURN:
jr	$ra

###############################################################################
# Ensures that the deck being used is not empty! If it is empty the program exits
# Can probably be re-factored into a loop, but I don't have time for that now
#
# @uses $t0 card_array memory address
#	$t1 number of times a card was drawn
#	$t2 number of times a card can be drawn
#
###############################################################################
VERIFY_NON_EMPTY_DECK:

la 	$t0, card_array				# load the card array
li	$t2, 4					# the number of cards that can be drawn per card
li	$t3, 0					# The loop iterator count
li	$t4, 9					# the number of times we will loop

LOOP_VD:
blt	$t4, $t3, FINAL_CHECK			# if the iterator is 
addi	$t3, $t3, 1

add	$t5, $t0, $t3	# put the memory address and offset into t5
lb	$t1, 0($t5)

ble	$t1, $t2, FINAL_CHECK
j	LOOP_VD

FINAL_CHECK:	

li	$t2, 16
addi	$t5, $t5, 1
lb 	$t1, 0($t5)
ble 	$t1, $t2, RETURN_VD

li	$t2, 4
addi	$t5, $t5, 1
lb	$t1, 0($t5)
ble	$t1, $t2, RETURN_VD


li	$v0, 4
la	$a0, msg_deck_empty
syscall
j	EXIT

RETURN_VD:
jr	$ra
