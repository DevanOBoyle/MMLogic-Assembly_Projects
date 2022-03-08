# Created by: O'Boyle, Devan
#             doboyle
#             25 February 2021

# Assignment: Lab 4: Syntax Checker
#             CSE 12L, Computer Systems and Assembly Language
#             UC Santa Cruz, Winter 2021
# Winter 2021 CSE12 Lab5
#Description: This program takes a color, and calls subroutines that can draw lines or fill the entire canvas
#using memory-mapped bitmap graphics.
#Notes: This program is intended to be run using Mars IDE, and the bitmap display can be used to view the changes in color on the bitmap
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	srl %x, %input, 16 #shifts input to the right
	sll %y, %input, 16 #shifts input to the left to get rid of the x coords in the input
	srl %y, %y, 16     #shifts input back to the right
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	sll %output, %x, 16      #shifts the x coord to the left
	add %output, %output, %y #adds the y coord in
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y %origin)
	# YOUR CODE HERE
	mul %output, %y, 128          #multiplies %y by 128 column bits
	add %output, %output, %x      #adds the remaining column bits
	mul %output, %output, 4       #multiplies the output by 4
	add %output, %output, %origin #adds the originAddress
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t0, originAddress #origin
	li $t1, 65536 #end of 2d array
	fillMap:
	     beq $t1, 0, finishClear #if the end of the array is reached, stop filling the bitmap
	     sw $a0, ($t0)           #changes the color at that particular address
	     addi $t0, $t0, 4        #increments $t0 by 4
	     addi $t1, $t1, -4       #increments %t1 by 4
	     j fillMap               #loops through
	finishClear:
 	     jr $ra                  #when done, jump back to where the subroutine was initially called

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t3, originAddress #origin
	getCoordinates($a0 $t1 $t2)      #calls getCoordinates macro
	getPixelAddress($t0 $t1 $t2 $t3) #calls getPixelAddress macro
	sw $a1 ($t0)                     #changes the color of the pixel at a particular address
	jr $ra                           #jumps back to where subroutine was initially called
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t3, originAddress #origin
	getCoordinates($a0 $t1 $t2)      #calls getCoordinates macro
	getPixelAddress($a1 $t1 $t2 $t3) #calls getPixelAddress
	lw $v0, ($a1)                    #returns the color of the pixel to $v0
	jr $ra                           #jumps back to where subroutine was initially called

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	li $t0, 0
	li $t1, 0 #x value
	li $t2, 0 #y value
	lw $t3, originAddress #origin
	loopCols:
	     getPixelAddress($t0 $t1 $a0 $t3) #calls getPixelAddress
	     sw $a1, ($t0)                    #changes the color at a particular address
	     addi $t1, $t1, 1                 #increments the column counter, a.k.a. the x value
	     beq $t1, 128, endLoopCols        #if the column counter reaches 128, exits the loop
	     j loopCols                       #loops through until the entire horizontal line is drawn
	endLoopCols:
	     li $t0, 0
 	     jr $ra #jumps back to where subroutine was initially called


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	li $t0, 0 
	li $t1, 0 #x value
	li $t2, 0 #y value
	lw $t3, originAddress #origin
	loopRows:
	     getPixelAddress($t0 $a0 $t2 $t3) #calls getPixel Address
	     sw $a1, ($t0)                    #changes the color of the pixel at a particular address
	     addi $t2, $t2, 1                 #increments the row counter, a.k.a. the y value
	     beq $t2, 128, endLoopRows        #if the row counter reaches 128, exits the loop
	     j loopRows                       #loops through until the entire vertical line is drawn
	endLoopRows:
	     li $t3, 0
 	     jr $ra #jumps back to where the subroutine was initially called


#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s5 $sp

	move $s0 $a0  # store 0x00XX00YY in s0
	move $s1 $a1  # store 0x00RRGGBB in s1
	getCoordinates($a0 $s2 $s3)  # store x and y in s2 and s3 respectively
	
	# get current color of pixel at the intersection, store it in s4
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	lw $s4 originAddress                #loads the originAddress to s4
	getPixelAddress($s0, $s2, $s3, $s4) #calls getPixelAddress
	lw $s4, ($s0)                       #saves the color at the intersection address to $4
	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0, $s3            #moves the y-value to $a0 for input in the subroutine
	move $a1, $s1            #moves the x-value to $a1 for input in the subroutines
     jal draw_horizontal_line #calls the subroutine to draw a horizontal line
	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0, $s2          #moves the y-value to $a0 for input in the subroutine
	move $a1, $s1          #moves the x-value to $a1 for input in the subroutine
     jal draw_vertical_line #calls the subroutine to draw a vertical line
	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
     sw $s4, ($s0) #sets the value of $s4 back to the address of the intersection
	move $sp $s5  #sets the previous color back
	
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
