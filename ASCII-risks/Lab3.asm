# Created by: O'Boyle, Devan
#             doboyle
#             11 February 2021

# Assignment: Lab 3: ASCII-risks (Asterisks)
#             CSE 12L, Computer Systems and Assembly Language
#             UC Santa Cruz, Winter 2021

# Description: This program takes a value greater than 0 and prints out a triangle of asterisks with the given height
# Notes: This program is intended to be run from MARS IDE

.data
     prompt: .asciiz "Enter the height of the pattern (must be greater than 0):	"
     invalid: .asciiz "Invalid Entry!\n"
     asterisk: .asciiz "*"
     tab: .asciiz "	"
     indexStart: .word 1
     newLine: .asciiz "\n"
.text
	# Register Usage:
	# $t0: user input
	# $t1: incremented value for Loop
	# $t2: incremented value for firstLoop
	# $t3: incremented value for secondLoop
	# $t4: used to initialize $t1, $t2, and $t3
     main: NOP
           li $v0, 4
           la $a0, prompt                           # prints prompt
           syscall

           li $v0, 5                                # reads user input
           syscall
		
           move $t0, $v0                            # moves the user input to $t0   
           blez $t0 printInvalid                    # if the user input is less than or equal to 0,
                                                    # jumps to printInvalid to print the invalid message
           lw $t1, indexStart($t4)                  # stores the value of 1 to $t1
           lw $t2, indexStart($t4)                  # stores the value of 1 to $t2
           lw $t3, indexStart($t4)                  # stores the value of 1 to $t3
           jal Loop                                 # jumps to the start of Loop

           exit: NOP
                 li $v0, 10                         # exits the program
                 syscall

     Loop: NOP                                      # loop encompassing the following code to print out each line of output
           bgt $t1, $t0, exit                       # jumps to exit the program when the loop is complete and the incremented value, $t1, 
                                                    # is greater than the user's input, $t0
                                                    
           firstLoop: NOP                           # for loop for asterisks before 
                      bge $t2, $t1, inputNumber     # jumps to the print the number value in the triangle if the incremented value, $t2, 
                                                    # is equal to the current iteration of $t1
                      li $v0, 4
                      la $a0, asterisk              # prints out an asterisk
                      syscall
               
                      li $v0, 4
                      la $a0, tab                   # prints out a tab
                      syscall
               
                      addi $t2, $t2, 1              # increments the value of $t2 by adding 1 to it
                      j firstLoop                   # jumps to the beginning of the loop

           inputNumber: NOP
                        li $v0, 1 
                        move $a0, $t1               # moves $t1 to $a0 to print the integer value of $t1
                        syscall

           secondLoop: NOP                          # for loop for asterisks after number
                       bge $t3, $t1, exitSecondLoop # jumps to the print the number value in the triangle if the incremented value, $t3, 
                                                    # is equal to the current iteration of $t1
                       li $v0, 4
                       la $a0, tab                  # prints out a tab
                       syscall
               
                       li $v0, 4
                       la $a0, asterisk             # prints out an asterisk
                       syscall
               
                       addi $t3, $t3, 1             # increments the value of $t3 by adding 1 to it
                       j secondLoop                 # jumps to the beginning of the loop
               
           exitSecondLoop: NOP
                           li $v0, 4
                           la $a0, newLine          # returns a to a new line, so that the output isn't all on one line
                           syscall
               
                           addi $t1, $t1, 1         # increments the value of $t1 by adding 1 to it
               
           lw $t2, indexStart($t4)                  # resets the value of $t2 back to 1 so that it can be used for more interations
           lw $t3, indexStart($t4)                  # resets the value of $t3 back to 1 so that it can be used for more interations
           j Loop                                   # jumps to the beginning of the loop
	
     printInvalid: NOP
                   li $v0, 4
                   la $a0, invalid                  # prints out the invalid statement
                   syscall
               
                   j main                           # jumps back to the beginning of main to ask for input again
		
	



