.data

msg_recursive:	.asciiz "This is the recursive version...\n"
msg_input: 	.asciiz "Which fibonicci number do you want?: "
msg_iterative:	.asciiz "\n\nThis is the iterative version...\n"

.text
main:
	li	$v0, 4
	la	$a0, msg_recursive
	syscall
	
	la	$a0, msg_input
	syscall

	li	$v0, 5
	syscall
	move	$a0, $v0	# $a0 contains the input
	move	$s7, $v0	# save the input for the iterative version of fibinocci calculation

	jal	fib
	
	move	$a0, $v0
	li	$v0, 1
	syscall
	
	la	$a0, msg_iterative
	li	$v0, 4
	syscall
	
	move 	$a0,$s7		# restore the original input to $a0 as the argument to the iteritive version
	
	jal	fib_i		# find the nth fibonocci number iterativly
	
	move	$a0, $v0
	li	$v0, 1
	syscall

	li 	$v0,10
	syscall

#-------------------------------
# int fib(int n)
#    returns the nth fib number
#
# warning: n is assumed to be positive, an infinite loop will be created otherwise
# arguments: $a0 contains n
# trashes: $t1
# returns: $v0 is the nth fib number
#-------------------------------
fib:
	#---------
	# Prologue
	#---------
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
	# Begin fibinocci calculation
	add	$s0, $0, $a0		# $s0 contains $a0
	
	addi	$t1, $0, 1		# load $t1 with 1 to use as a comparision
	
	beq	$s0, $0, return_0	# return 1 if the number is equal to 1
	beq	$s0, $t1, return_1	# return 0 if the number is equal to 0
	
	addi	$a0, $s0, -1		# subtract 1 from the number
	
	jal	fib			# call fib again
	
	add	$s1, $0, $v0		# 
	add 	$s1, $0, $v0     	# s1 = fib(n - 1)
	addi 	$a0, $s0, -2		# 
	
	jal	fib			# $v0 = fib(n - 2)
	
	add 	$v0, $v0, $s1       	# $v0 = fib(n - 2) + fib(n - 1)

	#---------
	# Epilogue
	#---------		
exit_fib:	
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)
	lw 	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra			# Return to caller

return_1:	
	li 	$v0, 1
	j	exit_fib

return_0:	
	li	$v0, 0
	j	exit_fib
	
#-------------------------------
# int fib_i(int n)
#    returns the nth fib number
#
# warning: n is assumed to be positive, an infinite loop will be created otherwise
# arguments: $a0 contains n
# trashes: $t1
# returns: $v0 is the nth fib number
#-------------------------------
fib_i:	
	addi	$a0, $a0, -1	# decrease $a0 by 1 because 0 is our first iteration not 1
	
	# ensure used registers start at required values
	addi	$t0, $0, 0	# counter variable
	addi	$t1, $0, 0	# f(n-1)
	addi	$t2, $0, 1	# f(n-2)
	addi	$v0, $0, 0	# return value & total
	
loop:
	ble	$a0, $t0, fib_i_exit
	add	$v0, $t1, $t2
	move	$t1, $t2
	move 	$t2, $v0
	addi	$t0, $t0, 1
	j	loop

fib_i_exit:
	jr	$ra