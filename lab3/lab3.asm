.data
msg1:.asciiz "Give a number: "
.text
.globl main
main:

li $v0,4
la $a0,msg1
syscall #print msg
li $v0,5
syscall #read an int
add $a0,$v0,$zero #move to $a0

jal fib #call fib

add $a0,$v0,$zero
li $v0,1
syscall

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

fib:
#a0=y
#if (y==0) return 0;
#if (y==1) return 1;
#return( fib(y-1)+fib(y-2) );

addi $sp,$sp,-12 #save in stack
sw $ra,0($sp)
sw $s0,4($sp)
sw $s1,8($sp)

add $s0,$a0,$zero

addi $t1,$zero,1
beq $s0,$zero,return0
beq $s0,$t1,return1

addi $a0,$s0,-1

jal fib

add $s1,$zero,$v0     #s1=fib(y-1)

addi $a0,$s0,-2

jal fib               #v0=fib(n-2)

add $v0,$v0,$s1       #v0=fib(n-2)+$s1
exitfib:

lw $ra,0($sp)       #read registers from stack
lw $s0,4($sp)
lw $s1,8($sp)
addi $sp,$sp,12       #bring back stack pointer
jr $ra

return1:
 li $v0,1
 j exitfib
return0 :     li $v0,0
 j exitfib
