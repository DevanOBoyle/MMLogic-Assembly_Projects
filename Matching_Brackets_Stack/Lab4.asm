# Created by: O'Boyle, Devan
#             doboyle
#             25 February 2021

# Assignment: Lab 4: Syntax Checker
#             CSE 12L, Computer Systems and Assembly Language
#             UC Santa Cruz, Winter 2021

# Description: This program opens a file an determines if it has correct syntax including if it has a balance of braces
# Notes: This program is intended to be run from MARS IDE

.data
     prompt: .asciiz "You entered the file:\n"
     success_1: .asciiz "SUCCESS: There are " 
     success_2: .asciiz " pairs of braces.\n"
     invalid: .asciiz "ERROR: Invalid program argument.\n"
     brace_msg: .asciiz "ERROR - There is a brace mismatch: "
     index_msg: .asciiz " at index "
     stack_msg: .asciiz "ERROR - Brace(s) still on stack: "
     newline: .asciiz "\n"
     buffer: .space 128
     
.text
     main: NOP
           
           li $v0, 4
           la $a0, prompt                                    # prints prompt
           syscall
           
           lw $s0, ($a1)
           move $a0, $s0                                     # prints the file name
           li $v0, 4
           syscall
           
           li $v0, 4
           la $a0, newline                                   # prints new line
           syscall
           
           li $t0, 48                                        # initialize ascii value for 0
           li $t1, 57                                        # initialize ascii value for 9
           lw $s0, 0($a1)   
           lb $t3, ($s0)
                                                             # checks if the first character of text file is a number
           bltu $t3,$t0, continue                            # Jump if char < 0
           bgtu $t3,$t1, continue                            # Jump if 9 < char
           
           j printInvalid                            
           
           continue: NOP
           	      li $t4, 0                                # initialize the index
           	      li $t5, 20                               # maximum number of characters
           	      lw $t2, 0($a1)
           	      countChars: NOP                          # counts the number of characters in the text file
               	             lb $t3, 0($t2)               # load the next character into t1
               	             beqz $t3, checkLength        # check for the null character
               	             addi $t2, $t2, 1             # increment the index
               	             addi $t4, $t4, 1             # increment the count
               	             j countChars
           
           checkLength: NOP
                        bgtu $t4, $t5, printInvalid           # if there are more than 20 characters in the file name, prints an invalid statement
                        
           li   $v0, 13                                       # system call for open file
           la   $a0, ($s0)                                    # board file name
           li   $a1, 0                                        # Open for reading
           li   $a2, 0
           syscall                                            # open a file (file descriptor returned in $v0)
           move $s6, $v0                                      # save the file descriptor 
           
           li $t1, 0                                          # initialize pair counter
           li $t4, 0                                          # initialize index pointer
           li $t7, 0                                          # initialize stack index
           
           li $v0, 4
           la $a0, newline
           syscall
           readFile: NOP                                      # read from file
                     li $t6, 0
                     li   $v0, 14                             # system call for read from file
                     move $a0, $s6                            # file descriptor 
                     la   $a1, buffer                         # address of buffer to which to read
                     la $a2, 128
                     syscall                                  # read from file
                     move $s1, $v0
                     la $s2, buffer
                     beq $s1, $zero, checkSuccess             # if buffer is empty print success
       
                     bufferLoop: NOP
                                 beq $t6, $s1, readFile       # if end of buffer is reached, load next bits
                                 lb $t3, ($s2)                # load the next character into t1
                                 
                                 beq $t3, 40, push            # push left parentheses
                                 beq $t3, 41, pop             # pop right parentheses
                                 beq $t3, 91, push            # push left brackets
                                 beq $t3, 93, pop             # pop right brackets
                                 beq $t3, 123, push           # push left {
                                 beq $t3, 125, pop            # pop right }
               	     
                                 returnP: NOP
                                 beq $t3, 41, opt1            # if character is left parentheses go to op1
                                 beq $t3, 93, opt2            # if character is left brackets go to op2
                                 beq $t3, 125, opt3           # if character is left { go to op3
                                 backtoLoop: NOP
                                             addi $s2, $s2, 1 # increment the string pointer
                                             addi $t6, $t6, 1 # increment bit counter
                                             addi $t4, $t4, 1 # increment index pointer
                                             j bufferLoop
               	    
           
           exit: NOP                                          # Close the file 
                 li   $v0, 16                                 # system call for close file
                 move $a0, $s6                                # file descriptor to close
                 syscall                                      # close file
                 
                 li $v0, 10                                   # exits the program
                 syscall
                 
     printInvalid: NOP
                   li $v0, 4
                   la $a0, newline                            # print a new line
                   syscall
                   
                   li $v0, 4
                   la $a0, invalid                            # prints out the invalid statement
                   syscall
               
                   j exit
     push: NOP                                                # push to stack
           addi $sp, $sp, -4                                  # decrements the stack pointer
           addi $t7, $t7, -1                                  # decrements the index
           sw $t3, ($sp)                                      # saves the new stack pointer
           j returnP
           
     pop: NOP                                                 # pop from stack
          lw $t2, ($sp)
          addi $t7, $t7, 1                                    # increments the index
          addi $sp, $sp, 4                                    # increments the stack pointer
          beq $t7, 1, printMismatch                           # if the index is 1, jump to print the mismatch error statement
          j returnP
      
      opt1: NOP
            beq $t2, 40, incrementPairs                       # increment the number of pairs if there is a matching set of parentheses
            j printMismatch                                   # otherwise print a mismatch error statement
      opt2: NOP
            beq $t2, 91, incrementPairs                       # increment the number of pairs if there is a matching set of brackets
            j printMismatch                                   # otherwise print a mismatch error statement
      
      opt3: NOP
            beq $t2, 123, incrementPairs                      # increment the number of pairs if there is a matching set of braces
            j printMismatch                                   # otherwise print a mismatch error statement
      
      incrementPairs: NOP
                      addi $t1, $t1, 1                        # increment the pair counter
                      j backtoLoop
                      
      checkSuccess: NOP
                    beq $t7, 0, printSuccess                 # if the stack is empty, print success
                    j printStack                             # otherwise, print the remaining braces left on the stack
      
      printSuccess: NOP
                    li $v0, 4
                    la $a0, success_1                        # print the first part of the success message
                    syscall
                   
                    li $v0, 1 
                    move $a0, $t1                            # print the number of pairs
                    syscall
                   
                    li $v0, 4
                    la $a0, success_2                        # print the second part of the success message
                    syscall
                    j exit
                   
     printMismatch: NOP
                    li $v0, 4
                    la $a0, brace_msg                        # print the mismatch statement
                    syscall
                   
                    li $v0, 11 
                    move $a0, $t3                            # print the mismatched brace
                    syscall
                 
                    li $v0, 4
                    la $a0, index_msg                        # print the middle part of the statement
                    syscall
                 
                    li $v0, 1 
                    move $a0, $t4                            # print the index
                    syscall
                   
                    li $v0, 4
                    la $a0, newline                          # print the new line
                    syscall
                    j exit
     
     printStack: NOP
                 li $v0, 4
                 la $a0, stack_msg                           # print the stack error message
                 syscall
                 
                 printingStack: NOP                          # prints each character on the stack
                                beq $t7, 0, printRest        # when the index pointer reaches 0, jump to print the end of the message
                                li $v0, 11 
                                lw $s7, ($sp)
                                move $a0, $s7           
                                syscall
                                addi $sp, $sp, 4             # increments the stack pointer
                                addi $t7, $t7, 1             # increments the index pointer
                                j printingStack
                 printRest: NOP
                            li $v0, 4
                            la $a0, newline                  # print new line
                            syscall
                            j exit
