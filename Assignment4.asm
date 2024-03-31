TITLE Assignment 4    (Assignment4.asm)

; Author(s): Lyle McCaffrey
; Course / Project ID: CS 271 001            Date: 03/01/2024
; Description:	This program sorts an array of random numbers and calculates the median


; couple notes: comments are included in-line, indicated by a semi-colon
; assembly language uses procedures instead of functions, but they are similar



INCLUDE Irvine32.inc					; irvine is a library used in assembly language
	Min			= 10					; global constants (min and max) are defined here
	Max			= 200
.data								; all variables, including text, that the program will use are defined in the .data section rather than later in the program
	; variable definitions
	intro_1		BYTE		"CS 271 Assignment 4 - Sorting Random Integers by Lyle McCaffrey", 0
	intro_2		BYTE		"This program generates random numbers in the range [lo .. hi], displays the original list, sorts the list,", 0
	intro_3		BYTE		"and calculates the median value.Finally, it displays the list sorted in descending order.", 0
	size_prompt	BYTE		"How many numbers should be generated? ", 0
	invalid_input	BYTE		"Invalid input", 0
	lower_prompt	BYTE		"Enter lower bound (lo): ", 0
	upper_prompt	BYTE		"Enter upper bound (high): ", 0
	spacer		BYTE		"   ", 0		; spacer to help with displayList formatting

	unsorted_title	BYTE		"The unsorted random numbers:", 0
	sorted_title	BYTE		"The sorted list:", 0
	median_text	BYTE		"The median is ", 0

	response		DWORD	?			; variable used to track whether the user instructs the program to repeat after it finishes
	again_prompt	BYTE		"Would you like to go again (0=NO, 1=YES):", 0

	random_array	DWORD	Max DUP(?)	; this creates an empty array of 200 DWORD data segments (800 BYTES)
	array_size	DWORD	?			; these are just empty variables which will have values assigned later in the program
	lo			DWORD	?
	hi			DWORD	?




.code								; with the variables defined, the .code section contains all the rest of the program
									; most lines are in this format:
									; operation	operand 1 (, operand 2)

main PROC								; lines like this are prodecure (function) definitions, so this is the main procedure

	call		Randomize					; Randomize is an external procedure used to initialize the RandomRange operator, which is used later to create random numbers
	call		introduction				

mainProgram:							; this is a label, is does nothing by itself but they can be jumped to from any other point in the code

	push		OFFSET array_size			; the push operation pushes a value onto the system stack
									; paramateres cannot be passed to procedures like you would pass function paramteres
									; so instead values are pushed to the system stack before calling a procedure and then retrieved from the stack wihtin the procedure

									; OFFSET takes the address of the variable/ its location in physical memory instead of the value of the variable
									; so this line really just lets me access and alter the array_size variable from within the next procedure I call
	push		OFFSET lo
	push		OFFSET hi
	call		getData

	push		array_size				; new set of parameters here for the fillArray procedure
									; not using OFFSET here because I want to use the variable value but I no longer need to access the variable in memory to change it
	push		lo
	push		hi
	push		OFFSET random_array
	call		fillArray

	push		OFFSET random_array
	push		array_size
	push		OFFSET unsorted_title
	call		displayList

	push		OFFSET random_array
	push		array_size
	call		sortList

	push		OFFSET random_array
	push		array_size
	call		displayMedian

	push		OFFSET random_array
	push		array_size
	push		OFFSET sorted_title
	call		displayList

	push		OFFSET response
	call		goAgain
	cmp		response, 1				; cmp compares operand 1 to operand 2, so this compares the value of response to 1
	je		mainProgram				; if response was equal to 1, this jumps back up to the mainProgram label on line 47
									; if response was not equal to 1, this does nothing and it goes to line 93

	exit	; exit to operating system		; program ends when it gets here
main ENDP								; this marks the end of the procedure


; procedure to display introduction message
; recieves: none
; returns: none
; preconditions: none
; registers changed : edx				; eax, ebx, ecx, edx, eip, esp, edp, ebp(maybe more) are registers in the cpu - places where I can put data to then do something with it
									; I need to know what registers are changed and where because each register can only hold one thing at a time and if I have something important
									; stored in a register, I need to avoid accidentaly overwriting it with another piece of data and losing the important thing
introduction PROC
	mov		edx, OFFSET intro_1	          ; edx is used to display text, so I move the address of the intro_1 variable to edx, then the next line  - call WriteString - writes whatever is in edx (like print)
									; the mov operation is literally just move a piece of data from one place to another. The first item (edx here) is the destination and the second item is the source
	call		WriteString
	call		Crlf						; just creates a new line
	mov		edx, OFFSET intro_2
	call		WriteString
	call		Crlf
	mov		edx, OFFSET intro_3
	call		writeString
	call		Crlf
	call		Crlf

	ret								; ends the procedure and returns to where ever the code was before the procedure was called (here its line 46)
introduction ENDP


; procedure to get the user input for the size of the array and the lower and upper bounds for its values
; recieves: addresses of array_size, lo, and hi on system stack
; returns: array_size = (user input), lo = (user input), hi = (user input)
; preconditions: none
; registers changed : eax, ebx, edx
	
getData PROC
	push		ebp						; system stack stuff, not really sure why I even need this but I know it does something important
	mov		ebp, esp
sizePrompt:
	mov		edx, OFFSET size_prompt		; prompt the user to enter an array size
	call		WriteString
	call		ReadInt					; ReadInt takes whatever the user writes and puts it into the eax register
	cmp		eax, min
	jl		invalidSize				; if user input is less than Min, reprompt them to enter a new array size
	cmp		eax, max
	jg		invalidSize				; if user input is greater than Max, reprompt
	jmp		validSize					; if user input was within the allowable range, jump to the validSize label

invalidSize:
	mov		edx, OFFSET invalid_input	; this section reprompts the user for a new array size
	call		WriteString
	call		Crlf
	jmp		sizePrompt

validSize:
	mov		ebx, [ebp+16]				; this is how the parameters pushed to the system stack are accessed
									; [ebp+16] accesses the third to last parameter pushed (+8 is the last one, 12 is second to last, etc)
	mov		[ebx], eax				; enter user input (in eax) into array_size variable (in ebx)
	mov		edx, OFFSET lower_prompt
	call		WriteString
	call		ReadInt
	mov		ebx, [ebp+12]				; move index of lo to ebx
	mov		[ebx], eax				; set lo to user input
	mov		edx, OFFSET upper_prompt
	call		WriteString
	call		ReadInt
	mov		ebx, [ebp+8]				; move index of hi to ebx
	mov		[ebx], eax				; set hi to user input
	
	pop		ebp
	ret		12
getData ENDP


; procedure to fill random_array with random numbers
; recieves: values of array_size, lo, and hi, and the address of random_array, all on the stack
; returns: random values in the first array_size spaces of random_array
; preconditions: none
; registers changed : eax, ecx, edi

fillArray PROC
	push		ebp
	mov		ebp, esp
	mov		ecx, [ebp+20]				; move array_size to ecx
	mov		edi, [ebp+8]				; address of random_array to edi
more:
	mov		eax, [ebp+12]				; hi into eax		
	sub		eax, [ebp+16]				; hi-lo in eax
	inc		eax						; increments eax by 1
	call		RandomRange				; random number in eax within the range of (hi-lo)
	add		eax, lo
	mov		[edi], eax				; put number in random_array at the location in edi
	add		edi, 4
	loop		more						; loop makes the code return to the given label (more) if ecx is greater than 0, also decrements ecx by 1
									; So if ecx is set to 20 on line 176, this section (178-186) will be done 20 times
	pop		ebp
	ret		16
fillArray ENDP


; procedure using selection sort to sort the array in descending order
; recieves: address of random array and value of array_size on the stack
; returns: sorted random_array
; preconditions: none
; registers changed : eax,ebx, ecx, edx, edi, esi

sortList PROC
	push		ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]				; size of array
	mov		edi, [ebp+12]				; random_array address

outerLoop:
	mov		ebx, edi					; address of first array item being compared
	mov		eax, [ebx]				
	mov		esi, ebx						
	mov		edx, ecx
	dec		edx						; set up counter for innerLoop, always 1 less than ecx
innerLoop:
	add		ebx, 4
	cmp		eax, [ebx]				; compare value of current maximum with value of the next item in the array
	jle		noChange
	mov		eax, [ebx]				; value of new max item
	mov		esi, ebx					; position of new max item
noChange:
	dec		edx
	cmp		edx, 0
	jg		innerLoop

	push		esi
	push		edi
	call		exchangeElements

	add		edi, 4
	loop		outerLoop

endSort:
	pop		ebp
	ret		8
sortList ENDP


; procedure to exchange two elements of random_array
; recieves: addresses of array elements to be swapped on the stack
; returns: swapped values of array elements at esi and edi
; preconditions: called each time the innerLoop of sortList finishes
; registers changed : eax, ebx, edx, esi

exchangeElements PROC
	push		ebp
	mov		ebp, esp

	mov		esi, [ebp+12]				; address of first item to exchange
	mov		edx, [ebp+8]				; address of second item
	mov		eax, [esi]				
	mov		ebx,	[edx]				
	mov		[esi], ebx
	mov		[edx], eax

	pop		ebp
	ret		8
exchangeElements ENDP


; procedure to calculate and display the median value of random_array
; recieves: address of random_array and value of array_size on the stack
; returns: none
; preconditions: none
; registers changed : eax, ebx, edx, esi

displayMedian PROC
	push		ebp
	mov		ebp, esp
	mov		esi, [ebp+12]				; address of first array item moved to esi
	mov		ebx, [ebp+8]				; size of array moved to ebx
	mov		eax, 1
	AND		eax, ebx					; AND just performs the boolean operator AND, here I use it to check whether the array size is even or odd
	cmp		eax, 1
	je		oddSize

	mov		eax, ebx					; calculations to find the median with an even number of items in the array
	mov		ebx, 2
	mul		ebx
	add		esi, eax
	mov		eax, [esi]
	sub		esi, 4
	add		eax, [esi]
	inc		eax
	div		ebx
	jmp		endMedian
	
oddSize:
	mov		eax, ebx					; calculations to find the median with an odd number of items in the array
	dec		eax
	mov		ebx, 2
	mul		ebx
	mov		eax, [esi]

endMedian:
	mov		edx, OFFSET median_text
	call		WriteString
	call		WriteDec
	call		Crlf
	call		Crlf
	pop		ebp
	ret		8
displayMedian ENDP


; procedure to display the list, 10 items to a line
; recieves: value of array_size, address of random_array, and appropirate title on stack
; returns: none
; preconditions: none
; registers changed : eax, ebx, ecx, edx, esi

displayList PROC
	push		ebp
	mov		ebp, esp
	mov		esi, [ebp+16]				; set esi to the first index of the array
	mov		ecx, [ebp+12]				; set ecx to array_size
	mov		ebx, 0					; initialize ebx to count to 10 numbers before starting a new line
	mov		edx,	[ebp+8]				; move title to edx
	call		WriteString
	call		Crlf
displayLoop:
	mov		eax, [esi]
	call		WriteDec
	mov		edx, OFFSET spacer
	call		WriteString
	add		esi, 4					; move to the next item in the array
	inc		ebx
	cmp		ebx, 10					; check whether a new line is needed
	je		newLine
	jmp		more
newLine:
	mov		ebx, 0
	call		Crlf
more:
	loop		displayLoop
	call		Crlf

	pop		ebp
	ret		12
displayList ENDP


; procedure to check whether to repeat the program
; recieves: address of response on stack
; returns: response = 0 or 1
; preconditions: none
; registers changed : eax, ebx, edx

goAgain PROC
	push		ebp
	mov		ebp, esp
	mov		ebx, [ebp+8]				; move the address of the response variable to ebx
	mov		edx, OFFSET again_prompt
	call		WriteString
	call		ReadInt
	mov		[ebx], eax				; assign the user input to the value of the response variable

	pop		ebp
	ret		4
goAgain ENDP


END main