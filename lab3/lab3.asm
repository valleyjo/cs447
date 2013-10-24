.data

msg_recursive:	.asciiz "This is the recursive version..."
msg_input: 	.asciiz "Enter the number of recursive calls: "


.text

la	$a0, msg_input
li	$v0, 4
syscall

li	$v0, 5
syscall
move	$s0, $v0	# $s0 contains the input

