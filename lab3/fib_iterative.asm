# Compute first twelve Fibonacci numbers and put in array, then print
      .data
fibs: .word   0 : 50        # "array" of 12 words to contain fib values
size: .word  12             # size of "array" 
      .text
      
      li	$v0, 5
      syscall
      move	$t7, $v0
      
      la   $t0, fibs        # load address of array
      la   $t5, size        # load address of size variable
      lw   $t5, 0($t5)      # load array size
      li   $t2, 1           # 1 is first and second Fib. number
      add.d $f0, $f2, $f4
      sw   $t2, 0($t0)      # F[0] = 1
      sw   $t2, 4($t0)      # F[1] = F[0] = 1
      addi $t1, $t5, -2     # Counter for loop, will execute (size-2) times
loop: lw   $t3, 0($t0)      # Get value from array F[n] 
      lw   $t4, 4($t0)      # Get value from array F[n+1]
      add  $t2, $t3, $t4    # $t2 = F[n] + F[n+1]
      sw   $t2, 8($t0)      # Store F[n+2] = F[n] + F[n+1] in array
      addi $t0, $t0, 4      # increment address of Fib. number source
      addi $t1, $t1, -1     # decrement loop counter
      bgtz $t1, loop        # repeat if not finished yet.
      la   $a0, fibs        # first argument for print (array)
      add  $a1, $zero, $t5  # second argument for print (size)
      jal  print            # call print routine. 
      li   $v0, 10          # system call for exit
      syscall               # we are out of here.
		
#########  routine to print the numbers on one line. 

      .data
space:.asciiz  " "          # space to insert between numbers
head: .asciiz  "The Fibonacci numbers are:\n"
      .text
print:
	la	$a3, fibs
	li	$t2, 4
	mult	$t7, $t2     # The offst for the fib number requested by the user
	mflo	$t3
	add	$a3, $a3, $t3 # a3 = a3 + 4 * t7 Find where the nubmer is located in the array
	addi	$a3, $a3, -8
	lw   $a0, 0($a3)      # load fibonacci number for syscall
      	li   $v0, 1           # specify Print Integer service
      	syscall               # print fibonacci number
      	jr   $ra              # return
	
