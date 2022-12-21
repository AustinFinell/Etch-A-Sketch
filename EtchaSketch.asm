# Name: Austin Finell
# Class: CSC 230
# Date: 12/5/2022
# Program Name: EtchaSketch.asm
# Program Description: 	Functional 512 x 512 etch-a-sketch using the bitmap display that allows color selection between RGB for drawing.
#						Additional functions include resetting the board and changing the RGB value of the frame color by gradient
# Keys: w - up
#		a - left
#		s - down
#		d - right
#		q - up/left
#		e - up/right
#		z - down/left
#		c - down/right
#		x - clear pointer pposition
#		r - change drawing color to red
#		g - change drawing color to green
#		b - change drawing color to blue
#		o - reset board
#		y - red value up
#		h - red value down
#		u - green value up
#		j - green value down
#		i - blue value up
# 		k - blue value down

.eqv BASEADDRESS 0x10040000
.eqv CENTER 0x10048060
.eqv WHITE 0xffffffff
.eqv GRAY 0x7e7e7e
.eqv RED 0xff0000
.eqv GREEN 0x00ff00
.eqv BLUE 0x0000ff
.eqv BLACK 0x0
.eqv CONTROLREGISTER 0xffff0000  	#tell if a key is pressed
.eqv DATAREGISTER 	 0xffff0004		#contains the key pressed


.text
	.globl main

main:
	li $a0, BASEADDRESS
	li $a1, GRAY
	jal DrawFrame
	
	li $s2, WHITE
	
	#Draw Center Dot
	li $s0, BASEADDRESS			#Reset Register to BASEADDRESS
	addi $s7, $s0, 8060 		# $s7 = Dot Address
	sw $s2, 0($s7)				# Draw Dot
	li $s5, RED					#Set initial Color
	li $s6, GRAY				#Set initial frame color
	mainLoop:
		li $s3, 0				# reset ASCII code
		jal Checkkeyboard		#call the subprogram to check keyboard
		move $s3, $v0			# save the ASCII code in $s3
		
		#left
		seq $s4, $s3, 0x61			# $s4 = (if 'a' is pressed)
		beqz $s4, right				# if !$s4 branch to next
			#true block
			addi $t1, $s7, -4		# $t1 = next left bit
			div $t0, $t1, 256		# Divide $t1 by 256
			mfhi $t2				# $t2 = remainder
			beqz $t2, endSwitch		# if the remainder is 0, move on
				or $a0, $s5, $zero	# $a0 = color
				or $a1, $s7, $zero	# $a1 = dot position
				li $a2, -4			# $a2 = dot movement amount
				jal DrawDot			# draw and move dot
				or $s7, $v0, $zero	# update dot position
		
		right:
		seq $s4, $s3, 0x64			# $s4 = (if 'd' is pressed)
		beqz $s4, up				# if !$s4 branch to next
			addi $t1, $s7, 8		# $t1 = 2 bits to the right
			div $t0, $t1, 256		# Divide $t1 by 256
			mfhi $t2				# $t2 = remainder
			beqz $t2, endSwitch		# if the remainder is 0, move on
				or $a0, $s5, $zero	# $a0 = color
				or $a1, $s7, $zero	# $a1 = dot position
				li $a2, 4			# $a2 = dot movement amount
				jal DrawDot			# draw and move dot
				or $s7, $v0, $zero	#update dot position
			
		up:
		seq $s4, $s3, 0x77			# $s4 = (if 'w' is pressed)
		beqz $s4, down				# if !$s4 branch to next
			#true block
			addi $t0, $s0, 508		# $t0 = 508 + BASEADDRESS
			sgt $t1, $s7, $t0		# $t1 = dot position > $t0
			beqz $t1, endSwitch		# if dot position < $t0 move on
				or $a0, $s5, $zero	# $a0 = color
				or $a1, $s7, $zero	# $a1 = dot position
				li $a2, -256		# $a2 = movement amount
				jal DrawDot			# draw and move dot
				or $s7, $v0, $zero	# update dot position
		
		down:
		seq $s4, $s3, 0x73			# $s4 = (if 's' is pressed)
		beqz $s4, upLeft			# if !$s4 branch to next
			#true block				
			addi $t0, $s0, 15868	# $t0 = BASEADDRESS + 15868
			slt $t1, $s7, $t0		# $t1 = $s7 < $t0
			beqz $t1, endSwitch		# if $s7 > $t0 move on
				or $a0, $s5, $zero	# $a0 = color
				or $a1, $s7, $zero	# $a1 = dot position
				li $a2, 256			# $a2 = movement amount
				jal DrawDot			# draw and move dot	
				or $s7, $v0, $zero	# update dot position
		
		upLeft:
		seq $s4, $s3, 0x71			# $s4 = (if 'q' is pressed)
		beqz $s4, upRight			# if !$s4 branch to next
			#true block			
			addi $t0, $s0, 508		#if the dot is below top line
			sgt $t1, $s7, $t0
			beqz $t1, endSwitch
				addi $t1, $s7, -4	#if the dot is right of the left line
				div $t0, $t1, 256
				mfhi $t2
				beqz $t2, endSwitch
					or $a0, $s5, $zero
					or $a1, $s7, $zero
					li $a2, -260
					jal DrawDot		#draw and move dot
					or $s7, $v0, $zero	#update position
			
		upRight:
		seq $s4, $s3, 0x65			#if 'e' is pressed
		beqz $s4, downLeft			
			#true block
			addi $t0, $s0, 508		#if dot is below top line
			sgt $t1, $s7, $t0
			beqz $t1, endSwitch
				addi $t1, $s7, 8	#if dot is left of right line
				div $t0, $t1, 256
				mfhi $t2
				beqz $t2, endSwitch
					or $a0, $s5, $zero
					or $a1, $s7, $zero
					li $a2, -252
					jal DrawDot		#draw and move dot
					or $s7, $v0, $zero	#update dot position
		
		downLeft:
		seq $s4, $s3, 0x7A				# if 'z' is pressed
		beqz $s4, downRight
			#true block
			addi $t0, $s0, 15868		#if dot above bottom line
			slt $t1, $s7, $t0
			beqz $t1, endSwitch
				addi $t1, $s7, -4		#if dot is right of left line
				div $t0, $t1, 256
				mfhi $t2
				beqz $t2, endSwitch
					or $a0, $s5, $zero
					or $a1, $s7, $zero
					li $a2, 252
					jal DrawDot			#draw and move dot
					or $s7, $v0, $zero	#update dot position
		
		downRight:
		seq $s4, $s3, 0x63				# if 'c' is pressed
		beqz $s4, delete
			#true block
			addi $t0, $s0, 15868		# if dot above bottom line
			slt $t1, $s7, $t0
			beqz $t1, endSwitch	
				addi $t1, $s7, 8		# if dot is left of right line
				div $t0, $t1, 256
				mfhi $t2
				beqz $t2, endSwitch	
					or $a0, $s5, $zero	
					or $a1, $s7, $zero
					li $a2, 260
					jal DrawDot			# draw and move dot
					or $s7, $v0, $zero	# update dot position
		
		delete:
		seq $s4, $s3, 0x78		# if 'x' is pressed
		beqz $s4, red
			#true block
			li $t0, BLACK		
			sw $t0, 0($s7)		# change dot position to black
			
		red:
		seq $s4, $s3, 0x72		# if 'r' is pressed
		beqz $s4, green
			#true block
			li $s5, RED			# change color to red
		
		green:
		seq $s4, $s3, 0x67		# if 'g' is pressed
		beqz $s4, blue
			#true block
			li $s5, GREEN		# change color to green
		
		blue:
		seq $s4, $s3, 0x62		#if 'b' is pressed
		beqz $s4, clearBoard
			#true block
			li $s5, BLUE		#change color to blue
		
		clearBoard:
		seq $s4, $s3, 0x6F		# if 'o' is pressed
		beqz $s4, frameRedUp
			#true block
			or $a0, $s7, $zero	# $a0 = dot position
			or $a1, $s6, $zero	# $a1 = frame color
			jal ClearBoard		# call clear board
			
		frameRedUp:				
		seq $s4, $s3, 0x79				# if 'y' is pressed
		beqz $s4, frameRedDown			
			addi $s6, $s6, 0x040000		# add 0x040000 to frame color
			li $a0, BASEADDRESS			# $a0 = BASEADDRESS
			move $a1, $s6				# $a1 = new frame color
			jal DrawFrame				# Draw new frame
		
		frameRedDown:
		seq $s4, $s3, 0x68				# if 'h' is pressed
		beqz $s4, frameGreenUp			
			addi $s6, $s6, -0x040000	# sub 0x040000 from frame color
			li $a0, BASEADDRESS			# $a0 = BASEADDRESS
			move $a1, $s6				# $a1 = new frame color
		    jal DrawFrame				# Draw new frame
		    
		frameGreenUp:
		seq $s4, $s3, 0x75				# if 'u' is pressed
		beqz $s4, frameGreenDown
			addi $s6, $s6, 0x000400		# add 0x000400 to frame color
			li $a0, BASEADDRESS			# $a0 = BASEADDRESS
			move $a1, $s6				# $a1 = new frame color
			jal DrawFrame				# Draw new frame
		
		frameGreenDown:
		seq $s4, $s3, 0x6A				# if 'j' is pressed
		beqz $s4, frameBlueUp
			addi $s6, $s6, -0x000400	# sub 0x000400 from frame color
			li $a0, BASEADDRESS			# $a0 = BASEADDRESS
			move $a1, $s6				# $a1 = new frame color
		    jal DrawFrame				# Draw new frame
		
		frameBlueUp:
		seq $s4, $s3, 0x69				# if 'i' is pressed
		beqz $s4, frameBlueDown
			addi $s6, $s6, 0x000004		# add 0x000004 to frame color
			li $a0, BASEADDRESS			# $a0 = BASEADDRESS
			move $a1, $s6				# $a1 = new frame color
			jal DrawFrame				# Draw new frame
		
		frameBlueDown:
		seq $s4, $s3, 0x6B				# if 'k' is pressed
		beqz $s4, escape
			addi $s6, $s6, -0x000004	# sub 0x000004 from frame color
			li $a0, BASEADDRESS			# $a0 = BASEADDRESS
			move $a1, $s6				# $a1 = new frame color
		    jal DrawFrame				# Draw new frame
		    
		escape:
		seq $s4, $s3, 0x1B				# if 'ESC' is pressed
		beqz $s4, endSwitch
			b endMainLoop				# end main loop
		
		endSwitch:
		b mainLoop						# branch to top
		
	endMainLoop:

	
exit:
	jal Exit

#Name: Checkkeyboard
#Input: keyboard
#Output: $v0 - ASCII code for the pressed key
# Description: returns the ASCII code for the pressed key

.text
	Checkkeyboard:
		li $t0, CONTROLREGISTER
		lw $t2, 0($t0)				#read the contents of the control register
									# only need bit 0 of control register
		and $t2, $t2, 0x01			# clear the rest of the bits except the LSB
		beqz $t2, Checkkeyboard		# if $t1 = 0 go back to the Checkkeyboard
			#else (key pressed)
			li $t1, DATAREGISTER
			lw $v0, 0($t1)			# load the ASCII code of the character in $v0
			jr $ra


# subprogram: DrawDot
# author: Austin Finell
# purpose: Move dot on bitmap
# input: 	$a0 - Color to draw
#			$a1 - Dot address
#			$a2 - Number to add to address of dot
# returns: $v0 - New dot location
# side effects: The dot draws on the bitmap, then moves to the new spot
.text
	DrawDot:
		move $t0, $a0
		sw $t0, 0($a1)
		li $t1, 0xffffffff
		add $v0, $a1, $a2
		sw $t1, 0($v0)
		jr $ra

# subprogram: DrawFrame
# author: Austin Finell
# purpose: Reset the board
# input: 	$a0 - Base Address
#			$a1 - Color
# returns: none
# side effects: The board frame is drawn with the given color
.text
	DrawFrame:
		
		move $t5, $a0				#$t5 = base address
		move $t4, $a1				#$t4 = color
		
		#Draw Top row
		move $t3, $t5				#$t3 = BASEADDRESS
		li $t0, 0					#LCV
		li $t1, 64					#Loop sentinel
		topRowLoop:					#Loop label
		slt $t2, $t0, $t1			#$t2 == ($t0 < $t1)
		beqz $t2, endTopRowLoop		#end loop if $t0 = $t1
			#true block
			sw $t4, 0($t3)			#Draw dot, BASEADDRESS is top right cell
			addi $t3, $t3, 4			#One Cell Right
			addi $t0, $t0, 1		#Increment LCV
			b topRowLoop			#Loop again
		endTopRowLoop:
		
		#Draw Bottom Row
		move $t3, $t5				#Reset Register to BASEADDRESS
		li $t0, 0					#LCV
		li $t1, 64					#Loop Sentinel
		botRowLoop:					
		slt $t2, $t0, $t1			#$t2 == ($t0 < $t1)
		beqz $t2, endBotRowLoop		#end loop if $t0 = $t1
			#true block
			sw $t4, 16128($t3)		#Draw dot, 16126 + BASEADDRESS is bottom left cell
			addi $t3, $t3, 4		#One Cell Right
			addi $t0, $t0, 1		#Increment LCV
			b botRowLoop			#Start loop again
		endBotRowLoop:
		
		#Draw Left Column
		move $t3, $t5				#Reset Register to BASEADDRESS
		li $t0, 0					#LCV
		li $t1, 64					#Loop Sentinel
		leftColLoop:
		slt $t2, $t0, $t1			#$t2 == ($t0 < $t1)
		beqz $t2, endLeftColLoop	#end loop if ($t0 = $t1)
			#true block
			sw $t4, 0($t3)			#Draw dot, Start at top left
			addi $t3, $t3, 256		#One Cell Down
			addi $t0, $t0, 1		#Increment LCV
			b leftColLoop			#Loop again
		endLeftColLoop:
		
		#Draw Right Column
		move $t3, $t5				#Reset Register to BASEADDRESS
		li $t0, 0					#LCV
		li $t1, 64					#Sentinel
		rightColLoop:				
		slt $t2, $t0, $t1			#$t2 == ($t0 < $t1)
		beqz $t2, endRightColLoop	#End loop if $t0 == $t1
			#true block
			sw $t4, 252($t3)		#Draw dot, 252 + BASEADDRESS is top right cell
			addi $t3, $t3, 256		#One Cell Down
			addi $t0, $t0, 1		#Increment LCV
			b rightColLoop			#Loop again
		endRightColLoop:
		jr $ra		


# subprogram: ClearBoard
# author: Austin Finell
# purpose: Reset the board
# input: 	$a0 - dot address
#			$a1 - frame color
# returns: none
# side effects: The board is cleared except for the dot location
.text
	ClearBoard:
		addi $sp, $sp, -4 	# make room for 4 bytes on the stack
		sw, $ra, 0($sp) 	# push the $ra on the stack
		
		li $t0, 0
		li $t1, 4096
		li $t2, BASEADDRESS
		li $t3, BLACK
		li $t5, WHITE
		
		startClearBoard:
		slt $t6, $t0, $t1 			# $t6 = ($t0 < 4096)
		beqz $t6, endClearBoard		# if !$t6 end loop
			#true block
			sw $t3, 0($t2)			# change cell to black
			addi $t2, $t2, 4		# move one cell to right
			addi $t0, $t0, 1		# increment LCV
			b startClearBoard		# loop again
		endClearBoard:
		
		move $t6, $a0				# $t6 = dot address
		sw $t5, 0($t6)				# redraw dot
		
		li $a0, BASEADDRESS			# redraw frame
		jal DrawFrame
		
		lw $ra, 0($sp)
    	addi $sp, $sp, 4	#pop main $ra
    	jr $ra



.include "utils.asm"
