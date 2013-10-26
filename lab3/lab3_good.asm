.data

msg_recursive:	.asciiz "This is the recursive version..."
msg_input: 	.asciiz "Which fibonicci number do you want?: "


.text

main:
	la	$a0, msg_input
	li	$v0, 4
	syscall

	li	$v0, 5
	syscall
	move	$a0, $v0	# $a0 contains the input
	move	$s7, $v0	# save the input for the iterative version of fibinocci calculation

	jal	fib
	
	add 	$a0,$v0,$zero
	li 	$v0,1
	syscall
	
	jal	fib_i		# find the nth fibonocci number iterativly
	

	li 	$v0,10
	syscall

#-------------------------------
# Prologue
#-------------------------------
fib:	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
#-------------------------------
# Begin fibinocci calculation
#-------------------------------
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

#-----------------------------
# Epilogue
#-----------------------------		
exit_fib:	
	lw 	$ra, 0($sp)
	lw 	$s0, 4($sp)
	lw 	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra		# Return to caller

return_1:	li 	$v0, 1
		j	exit_fib

return_0:	li	$v0, 0
		j	exit_fib
