Devan O'Boyle
doboyle
Winter 2021
Lab 2: Simple Data Path

Description:
In this lab we use MMLogic to make a circuit that performs left bitwise arithmetic shift on a value
based on another value. Both values are either entered from a keypad or come from the result of the previous shift operation.

Files:
Lab2.lgi - This file contains the Multimedia Logic program where the simulation for this lab is run

Instructions:
Click the green arrow on the top of the page in the Lab2.lgi file to run the program. While it is running,
click on any number on the keypad and use the write address switches to select the corresponding register
that you want the keypad value to update to. Once you have selected the write address, hit the update button
to update that value to one of the registers. Repeat this for as many values as you like, and you can hit
the clear button if you wish to clear all of the values in the registers. Now to perform the arithmetic shift,
use the switches in read address 1 to select the value of the number of times that you want the shifted value
to be shifted by. Then use read address 2 to select the value that you want to be shifted. The output will appear
at the ALU output display. Then by turning the store select switch to 1 you can set the outputed ALU value to another
register if you wish, or you can leave the switch at zero and repeat the process again with another keypad value. Click
the red box on the top of the screen to stop the program.
