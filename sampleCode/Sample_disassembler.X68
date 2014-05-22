*-----------------------------------------------------------
* Program    : Final Project
* Written by : Brad Seefeld, Jared, Matt Lindquist
* Date       : 5/27/09
* Description: Dissasembler
*-----------------------------------------------------------

task1		EQU	$01		* Output string at A1 without CRLF
task2		EQU	$02		* Read the string into A1
task13		EQU	$0D
task14		EQU	$0E		* Output to screen without line break at end
START		EQU	$00001000
STOP		EQU	$00001032	
stack		EQU	$000A0000	*Where the stack pointer will be initialized to
NMASK		EQU	%00001111

min_addr	EQU	$00000000 	* The given addresses must be greater than this value.
max_addr	EQU	$FFFFFFFF 	* The given addresses must be less than this value.
scrn_lines	EQU	30

**********************************************************************************************
* List of registers being used
*
* A0 = Pointer to the next location in memory to process
* A2 = Pointer to the last location in memory to process
* A5 = Pointer to the end of the "good" string
* A6 = Pointer to the end of the "bad" string
* D7 = Error code (if non-zero)
**********************************************************************************************

	ORG	$1000
	LEA	stack,SP	* initialize the stack pointer
	
WELCOME
	MOVE.B	#task13, D0	* Load task number into D0
	LEA	welcome0,A1	* Get the address of the string.
	TRAP	#15		* Show message
	
	LEA	welcome1,A1	* Get the address of the string.
	TRAP	#15		* Show message
	
	LEA	welcome0, A1	* Display stars again
	TRAP	#15
	
	LEA	str_empty, A1
	TRAP	#15
	
PRMT_START
	* Prompt the user for the starting address
	MOVE.B	#task14, D0	* Load task number into D0
        LEA	str_prompt1, A1	* Get address of string
        TRAP	#15           	* Prompt for starting address

	* Get the input from the user
	MOVE.B	#task2, D0	* Change mode to allow user to enter input
	LEA	user_input, A1	* Load the pointer to the location where the user input will be saved
        TRAP	#15		* Prompt for input (start addr)
        			* A1 stores a pointer to the beginning of the info.
        			* D1 stores length

	* Convert the input
        JSR	ASCIITOHEX	* convert the entered value to an address value. It will be in D3      

	* Process the returned data
	CMP.L 	#0, D1		* Check to see if we returned an error when converting the start value
	BNE	ERROR_HANDLER	* Go to error handler
        MOVE.L	D3, A0		* Move the converted value to A0
        
        * Ensure it is even boundary
        MOVE.L	A0,D0		* Get A0 ready for change
	ANDI.L	#$FFFFFFFE,D0	* Convert to even number
	MOVEA.L	D0,A0		* Put it back

	* Make sure start is >= min value
	MOVE.B	#$03, D1	* Load the error number in D1 (in case there is an error)
	CMP.L	#min_addr, A0	* Check to see if A0 <= minimim_value 
	BLT	ERROR_HANDLER	* Go to error handler

PRMT_END
	* Prompt the user for the ending address.
	MOVE.B	#task14, D0	* Load new task number
        LEA	str_prompt2, A1	* Prompt for end addr.
        TRAP	#15		* Prompt
        
        MOVE.B	#task2, D0	* Change mode to allow user to enter input
	LEA	user_input, A1	* Load the pointer to the location where the user input will be saved
        TRAP	#15		* Prompt for input (end addr)
        
        BSR	ASCIITOHEX	* Convert entered info into an address

	* Process the returned data
	CMP.L 	#0, D1		* Check to see if we returned an error when converting the start value
	BNE	ERROR_HANDLER	* Go to error handler
        MOVE.L	D3, A3		* Move the converted value to A2

	* Make sure end is <= max value
	MOVE.B	#$04, D1	* Load the error number in D1 (in case there is an error)
	CMP.L	#max_addr, A3	* Check to see if A2 > max_value 
	BLT	ERROR_HANDLER	* Go to error handler
      
	* Make sure start and end are valid
	SUBQ.L	#4, A3		* Subtract 2 (bytes) from A6
	MOVE.B	#$02, D1	* Load the error number in D1 (in case there is an error)
	CMP.L	A3, A0		* Check to see if A5 < (A6 - 2): This will ensure that we have at least 1 WORD to process
	BGT	ERROR_HANDLER	* Go to error handler
	ADDQ.L	#4, A3		* Add 2 (bytes) back to A6
	
* Begin decoding program in memory.
DECODE
	MOVE.B	#0, D6		* setup counter, this is the number of lines we have decoded to this screen

DECODE_LOOP
	LEA	str_good,A5	* init the pointer for the good string
	LEA	str_bad,A6	* init the pointer for the bad string
	MOVE.B	$00,(A5)	
	MOVE.B	$00,(A6)
	
	* Print the current memory location before doing any disassembly
	MOVE.L 	A0, D0		* Move the memory address to D0 (this is the data we want to convert)
	MOVE.L	#4, D1		* We will need to convert the entire LONG (4 bytes)
	MOVE.L	#user_input, A1	* Set A1 to point to the string where we will save the data
	JSR	HEXTOASCII	* Convert the numbers into ascii
	MOVE.B	#$9,(A1)+	* Insert a tab
	MOVE.B	#task14, D0	* Load new task number
        LEA	user_input, A1	* Load message
	TRAP	#15		* Print memory location with tab.
	
	* Start building the good & bad strings (memory location)
	* Get the next instruction and attempt to decode 
	CLR.L	D0		* Clear D0	
	MOVE.W	(A0)+,D0	* Move the data pointed to by A0 (WORD) into D0 (this it the data we want to convert)
	JSR	OPCODE

	* Print the results
	CMP.B	#0,D7		* Check for errors
	BNE	PRINT_BAD	* If there was an error, print the "bad" string (otherwise we'll print the "good" string)
	MOVE.B	#task13,D0	* Load new task number
	
	* TODO: Print memory location and tab space

        LEA	str_good,A1	* Load the string 
        TRAP	#15		* Print the string
	
DECODE_DONE

	* Finished processing the instruction
	CMP.L	A0,A3		* Have we passed the end or where we were supposed to test?
	BLT	QUIT		* Go to the end if we're finished
	
	* clear strings to prevent re-print
	
	* check if we have filled a whole screen
	ADDQ.B	#1, D6		* increment counter
	CMP.B	#scrn_lines, D6	* check if we have filled the screen
	BGE	DECODE_SCN_FULL	* we have filled the screen
	
	BRA	DECODE_LOOP	* Otherwise continue processing
	
DECODE_SCN_FULL 		* A screen worth of output has been printed, prompt user for when ready
	
	MOVE.B	#0, D6		* Reset counter
	MOVE.B	#task14, D0	* Load new task number
	LEA	str_scrnfull,A1	* Load the string
	TRAP	#15		* Print the message
	
	* Prompt user to <enter>
	MOVE.B	#task2, D0	* Load new task number
	LEA	user_input,A1	* We dont want user to over-ride anything in memory
	TRAP	#15		* Prompt for user input
	BRA	DECODE_LOOP	* Go back to decoding

QUIT	MOVE.B	#task14,D0
	LEA	str_finito,A1
	TRAP	#15
	STOP 	#$2700		*quit out of the program/code

PRINT_BAD
	* Update the bad string with the current instruction/data (WORD)
	LEA	str_bad,A2	* init the pointer for the bad string
	LEA	str_unknown,A1	* prep the string
	JSR	STRCPY		* Call STRCPY
	MOVE.L	A2,D2		* copy the memory address of the end of the string to D2
	SUB.L	#str_bad,D2	* get the length of the good string
	SUBI.L	#10,D2		* subtract 8 from the length (should give us a negative number)
	MULU	#-1,D2		* multiply by -1 to make positive
PAD_MORE
	MOVE.B	#$20,(A2)+	* Add a space
	DBF	D2,PAD_MORE	* While D2 > 0 keep padding the string with spaces
	MOVE.B	#$24,(A2)+	* Add a "$" 
	MOVE.L	#2, D1		* We will need to convert the entire LONG (4 bytes)
	MOVE.L	A2, A1		* Set A1 to point to the string where we will save the data
	JSR	HEXTOASCII	* Convert the numbers into ascii
	MOVE.L	A1, A2		* Update the string pointer
	MOVE.B	#$00,(A2)+	* end the string

	* Print the string
	MOVE.B	#task13,D0	* Load new task number
        MOVE.L	#str_bad,A1	* Load the string 
        TRAP	#15		* Print the string
        BRA	DECODE_DONE	* Continue

TEST
	RTS

**********************************************************************************************
* ERROR_HANDLER - Display some error message based on the condition of the error.
*			After such error has been displayed, the program will return
*			to prompt the user for the starting address.
*	   
* D1 = Error code
*

ERROR_HANDLER
	CMP.B	#$01, D1	* Compare D1 with the next known error 
	BEQ	ERROR_01	* Load error01 if we found a match

	CMP.B	#$02, D1	* Compare D1 with the next known error
	BEQ	ERROR_02	* Load error02 if we found a match
	
	CMP.B	#$03, D1	* Compare D1 with the next known error
	BEQ	ERROR_03	* Load error03 if we found a match

	CMP.B	#$04, D1	* Compare D1 with the next known error
	BEQ	ERROR_04	* Load error03 if we found a match

	* If we didnt find a match, load up the default error message
	LEA	str_error00, A1	* Load the error string into A1
	BRA	ERROR_DISPLAY	* Go back to the start of the program (since we don't know what the error was)
	
ERROR_01	* Value entered was invalid
	LEA	str_error01, A1	* Load the error string into A1
	BRA	ERROR_DISPLAY	* Display the error message
	
ERROR_02	* Start >= (End - 4)
	LEA	str_error02, A1	* Load the error string into A1
	BRA	ERROR_DISPLAY	* Display the error message
	
ERROR_03	* Start < Min
	LEA	str_error03, A1	* Load the error string into A1
	BRA	ERROR_DISPLAY	* Display the error message
	
ERROR_04	* Start < Min
	LEA	str_error04, A1	* Load the error string into A1
	BRA	ERROR_DISPLAY	* Display the error message
	
ERROR_DISPLAY
	MOVE.B	#task13, D0	* Load task 13
	TRAP	#15		* call TRAP 15
	BRA 	PRMT_START	* Go back to the beginning
	
**********************************************************************************************
**********************************************************************************************
* OPCODE 
* This function takes a WORD (in D0) and attempts to decode the assembly language instruction.
* The decoded information is added to the string pointed to by A5.  If there is any EA information
* found the DECODEEA function is called.  If an error is encountered a non-zero value will be 
* returned in D7.
*
* A0 = Pointer to the next location in memory
* A5 = Pointer to the end of the "good" string
* D0 = The next opcode to process
* D7 = Error Code (if non-zero) that is returned
*
* Internally:
* D1 = scratch space
* D2 = scratch space
* D3 = Register bits
* D4 = Mode, Dn/An, Size
* D5 = EA bits

OPCODE
	MOVEM.L	A1-A4/D1-D6,-(A7)	* Push register data onto the stack so we can restore it at the end
	CLR.L	D7			* Clear the error code 
	LEA	OPCODE_JMPTABLE,A1	* Load up the jump table
	JSR	OPCODE_DECODE_GET	* Break out the OPCode (only useful if the OPCode is standard)
	CLR.L	D1			* Clear the temp register
	MOVE.L	D0,D1			* Copy the opcode into the temp register
	MOVE.B	#12,D2			* Copy 12 into D2
	LSR.W	D2,D1			* Left shift D1 by the number of bits in D2
	MULU	#6,D1			* Multiple D1 by 6
	JSR	00(A1,D1)		* Jumps to the decoder for each type of OPCode (first 4 bits)
	
OPCODE_DONE
	MOVEM.L	(A7)+,A1-A4/D1-D6	* Pop register data off the stack and restore it 
	MOVE.B	#$00,(A5)+		* Terminate the "good" string
	RTS

OPCODE_JMPTABLE		
	JMP	code0000	* Bit manipulation/MOVEP/Immediate
	JMP	code0001	* Move Byte
	JMP	code0010	* Move Long
	JMP	code0011	* Move Word
	JMP	code0100	* Miscellaneous
	JMP	code0101	* ADDQ/SUBQ/Scc/DBcc
	JMP	code0110	* BSR, BRA, Bcc
	JMP	code0111	* MOVEQ
	JMP	code1000	* OR/DIV/SBCD
	JMP	code1001	* SUB/SUBX
	JMP	code1010	* Unassigned
	JMP	code1011	* CMP/EOR
	JMP	code1100	* AND/MUL/ABCD/EXG
	JMP	code1101	* ADD/ADDA/ADDX
	JMP	code1110	* Shift/Rotate
	JMP	code1111	* Special/Reserved

**********************************************************************************************

* Bit manipulation/MOVEP/Immediate
code0000
	* Check for ADDI
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_ADDI,A1		* prep the string
	OR.B	#%00010000,D4		* Set to mode3 (Data,EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0000011000000000,D1	* Check to see if this is a ADDI
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for ANDI
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_ANDI,A1		* prep the string
	OR.B	#%00010000,D4		* Set to mode3 (Data,EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0000001000000000,D1	* Check to see if this is a ANDI
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for CMPI
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_CMPI,A1		* prep the string
	OR.B	#%00010000,D4		* Set to mode3 (Data,EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0000110000000000,D1	* Check to see if this is a CMPI
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for EORI
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_CMPI,A1		* prep the string
	OR.B	#%00010000,D4		* Set to mode3 (Data,EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0000101000000000,D1	* Check to see if this is an EORI
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for ORI
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_ORI,A1		* prep the string
	OR.B	#%00010000,D4		* Set to mode3 (Data,EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0000000000000000,D1	* Check to see if this is an ORI
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for SUBI
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_SUBI,A1		* prep the string
	OR.B	#%00010000,D4		* Set to mode3 (Data,EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0000010000000000,D1	* Check to see if this is an SUBI
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	MOVE.B 	#$01,D7			* Set error code because we were unable to decode the intruction
	RTS

* Move Byte
code0001
	* Check for MOVE (default)
	LEA	str_MOVE,A1		* prep the string
	MOVE.B	#%00110000,D4		* set size and mode
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction
	
* Move Long
code0010	
	* Check for MOVEA
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_MOVEA,A1		* prep the string
	MOVE.B	#%00000010,D4		* set size and mode
	ANDI.W	#%1111000111000000,D1	* Isolate bits 8-15
	CMP.W	#%0010000001000000,D1	* Check to see if this is an MOVEA
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for MOVE (default)
	LEA	str_MOVE,A1		* prep the string
	MOVE.B	#%00110010,D4		* set size and mode
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction
	
* Move Word
code0011	
	* Check for MOVEA
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_MOVEA,A1		* prep the string
	MOVE.B	#%00000001,D4		* set size and mode
	ANDI.W	#%1111000111000000,D1	* Isolate bits 8-15
	CMP.W	#%0011000001000000,D1	* Check to see if this is an MOVEA
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for MOVE (default)
	LEA	str_MOVE,A1		* prep the string
	MOVE.B	#%00110001,D4		* set size and mode
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction
	
* Miscellaneous	
code0100
	* Check for all instructions that have a valid size to start with

	* Check for CLR
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_CLR,A1		* prep the string
	OR.B	#%00101000,D4		* Set to mode6 (EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0100001000000000,D1	* Check to see if this is a CLR
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for NEG
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_NEG,A1		* prep the string
	ANDI.B	#%00000011,D4		* isolate the size
	ORI.B	#%00101000,D4		* set to mode6 (EA)
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0100010000000000,D1	* Check to see if this is a NEG
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for NOT
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_NOT,A1		* prep the string
	ANDI.B	#%00000011,D4		* isolate size
	OR.B	#%00101000,D4		* Set to mode6 (EA) 
	ANDI.W	#%1111111100000000,D1	* Isolate bits 6-15
	CMP.W	#%0100011000000000,D1	* Check to see if this is a NOT
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for all instructions that do not have a valid size to start with

	* Check for JMP
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_JMP,A1		* prep the string
	MOVE.B	#%00101011,D4		* Set to mode6 (EA) 
	ANDI.W	#%1111111111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100111011000000,D1	* Check to see if this is a JMP
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for JSR
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_JSR,A1		* prep the string
	MOVE.B	#%00101011,D4		* Set to mode6 (EA) 
	ANDI.W	#%1111111111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100111010000000,D1	* Check to see if this is a JSR
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for LEA
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_LEA,A1		* prep the string
	MOVE.B	#%00000011,D4		* Set to mode1 (EA,Rn) 
	ANDI.W	#%1111000111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100000111000000,D1	* Check to see if this is a LEA
	BEQ	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

	* Check for MOVEM
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_MOVEM,A1		* prep the string
	MOVE.B	#%00000001,D4		* set the size
	ANDI.W	#%1111111111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100100010000000,D1	* Check to see if this is a MOVEM.W (RegList,EA)
	BEQ	OPCODE_DECODE_MOVEM1	* fix
	MOVE.B	#%00000010,D4		* set the size
	ANDI.W	#%1111111111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100100011000000,D1	* Check to see if this is a MOVEM.L (RegList,EA)
	BEQ	OPCODE_DECODE_MOVEM1	* fix
	MOVE.B	#%00000001,D4		* set the size
	ANDI.W	#%1111111111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100110010000000,D1	* Check to see if this is a MOVEM.W (EA,Reglist)
	BEQ	OPCODE_DECODE_MOVEM2	* fix
	MOVE.B	#%00000010,D4		* set the size
	ANDI.W	#%1111111111000000,D1	* Isolate bits 6-15
	CMP.W	#%0100110011000000,D1	* Check to see if this is a MOVEM.L (EA,Reglist)
	BEQ	OPCODE_DECODE_MOVEM2	* fix

	* Check for NOP
	LEA	str_NOP,A1		* prep the string
	CMP.W	#%0100111001110001,D0	* Check to see if this is a NOP
	BEQ	OPCODE_DECODE_TYPEB	* decode the rest of the instruction

	* Check for RTS
	LEA	str_RTS,A1		* prep the string
	CMP.W	#%0100111001110101,D0	* Check to see if this is a RTS
	BEQ	OPCODE_DECODE_TYPEB	* decode the rest of the instruction

	* Check for SWAP
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	LEA	str_SWAP,A1		* prep the string
	ANDI.W	#%1111111111111000,D1	* Isolate bits 
	CMP.W	#%0100100001000000,D1	* Check to see if this is a SWAP
	BEQ	OPCODE_DECODE_FIX_SWAP	* decode the rest of the instruction

	MOVE.B 	#$01,D7			* Set error code because we were unable to decode the intruction
	RTS
	
OPCODE_DECODE_FIX_SWAP
	CLR.L	D3
	MOVE.B	#%01000110,D4		* set the size & mode
	MOVE.B	D5,D3			* copy D3 to D5 (this has the register bits)
	ANDI.B	#%00000111,D3		* isolate bits
	BRA	OPCODE_DECODE_TYPEA	

OPCODE_DECODE_MOVEM1
	* Update the "good" string
	MOVE.L	A5,A2			* Setup the "good" string as the DST
	JSR	STRCPY			* Call STRCPY
	MOVE.L	A2,A5			* Update the string pointer
	* Process the register list
	JSR 	OPCODE_PAD		* align the string for the next column
	MOVE.W	(A0)+,D1		* Read in the register list
	MOVE.B	#%00000001,D4		* Set to size = word
	MOVE.L	#15,D3			* setup the counter		
 	JSR	OPCODE_DECODE_MOVEM_POST
	MOVE.B	#$2C,(A5)+		* Add a ","
 	* get the EA
	JSR	EADECODE
	RTS

OPCODE_DECODE_MOVEM2
	* Update the "good" string
	MOVE.L	A5,A2			* Setup the "good" string as the DST
	JSR	STRCPY			* Call STRCPY
	MOVE.L	A2,A5			* Update the string pointer
 	* get the EA
	JSR 	OPCODE_PAD		* align the string for the next column
	JSR	EADECODE
	MOVE.B	#$2C,(A5)+		* Add a ","
	* Process the register list
	MOVE.W	(A0)+,D1		* Read in the register list
	MOVE.B	#%00000001,D4		* Set to size = word
	MOVE.L	#15,D3			* setup the counter		
 	JSR	OPCODE_DECODE_MOVEM_PRE
	RTS
	
OPCODE_DECODE_MOVEM_POST
	MOVE.W	D1,D2				* Make a copy of the register list
	ANDI.W	#1,D2				* check the 1st bit
	BEQ	OPCODE_DECODE_MOVEM_POST_X	* if the bit = false then don't print it 
	* otherwise we print
	LEA	str_movem_post,A2		* load a pointer to the array
	MOVE.L	D3,D2				* copy D3
	MULU	#2,D2				* multiply the count by 2 (since there are 2 bytes per)
	MOVE.B	00(A2,D2),(A5)+			* get the first byte
	ADDQ.L	#1,A2				* increment the pointer
	MOVE.B	00(A2,D2),(A5)+			* Get the second byte
	MOVE.B	#$2F,(A5)+			* Add a "/"
OPCODE_DECODE_MOVEM_POST_X
	ROR.W	#1,D1				* shift the bits to the right 
	DBF	D3,OPCODE_DECODE_MOVEM_POST	* keep processing until we've checked every Rn
	SUBQ.L	#1,A5				* get rid of the trailing "/"
	RTS

OPCODE_DECODE_MOVEM_PRE
	MOVE.W	D1,D2				* Make a copy of the register list
	ANDI.W	#1,D2				* check the 1st bit
	BEQ	OPCODE_DECODE_MOVEM_PRE_X	* if the bit = false then don't print it 
	* otherwise we print
	LEA	str_movem_pre,A2		* load a pointer to the array
	MOVE.L	D3,D2				* copy D3
	MULU	#2,D2				* multiply the count by 2 (since there are 2 bytes per)
	MOVE.B	00(A2,D2),(A5)+			* get the first byte
	ADDQ.L	#1,A2				* increment the pointer
	MOVE.B	00(A2,D2),(A5)+			* Get the second byte
	MOVE.B	#$2F,(A5)+			* Add a "/"
OPCODE_DECODE_MOVEM_PRE_X
	ROR.W	#1,D1				* shift the bits to the right 
	DBF	D3,OPCODE_DECODE_MOVEM_PRE	* keep processing until we've checked every Rn
	SUBQ.L	#1,A5				* get rid of the trailing "/"
	RTS

* ADDQ/SUBQ/Scc/DBcc
code0101	
	MOVE.B 	#$01,D7			* Set error code because we were unable to decode the intruction
	RTS
	
* BSR, BRA, Bcc
code0110
	* Check for BSR
	LEA	str_BSR,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%1111111100000000,D1	* Isolate bits 8-15
	CMP.W	#%0110000100000000,D1	* Check to see if this is a BSR
	BEQ	OPCODE_DECODE_BSR	* call special decoder for BSR
	MOVE.B 	#$01,D7			* Set error code because we were unable to decode the intruction
	RTS

OPCODE_DECODE_BSR
	* Update the "good" string
	MOVE.L	A5,A2		* Setup the "good" string as the DST
	JSR	STRCPY		* Call STRCPY
	MOVE.L	A2,A5		* Update the string pointer
	CLR.L	D1		* clear D1
	MOVE.W	D0,D1		* Make a copy of D0 (the OPCode)
	ANDI.W	#%0000000011111111,D1	* Isolate bits 0-7 (displacement)
	MOVE.L	A0,D0		* make a copy of the memory address we are pointing to	
	JSR 	OPCODE_PAD		* align the string for the next column
	CMP.B	#$00,D1			* is there a word operand?
	BEQ	OPCODE_DECODE_BSR_WORD	
	CMP.B	#$FF,D1			* is there a long operand?
	BEQ	OPCODE_DECODE_BSR_LONG
	* must be a byte		
	MOVE	D1,D2		* Make a copy of D1	
	ANDI.B	#$80,D2		* isolate the most significant bit
	CMP.B	#$80,D2		* is the most significant bit = true? (negative)
	BNE	OPCODE_DECODE_BSR_POS
	NOT.B	D1
	ADDQ.B	#1,D1
	SUB.L	D1,D0
	BRA	OPCODE_DECODE_BSR_FINISH
OPCODE_DECODE_BSR_WORD
	MOVE.W	(A0)+,D1	* read in the next word
	MOVE	D1,D2		* Make a copy of D1	
	ANDI.W	#$8000,D2	* isolate the most significant bit
	CMP.W	#$8000,D2	* is the most significant bit = true? (negative)
	BNE	OPCODE_DECODE_BSR_POS
	NOT.W	D1
	ADDQ.W	#1,D1
	SUB.L	D1,D0
	BRA	OPCODE_DECODE_BSR_FINISH
OPCODE_DECODE_BSR_LONG
	MOVE.W	(A0)+,D1	* read in the next long
	MOVE	D1,D2		* Make a copy of D1	
	ANDI.L	#$80000000,D2	* isolate the most significant bit
	CMP.L	#$80000000,D2	* is the most significant bit = true? (negative)
	BNE	OPCODE_DECODE_BSR_POS
	NOT.L	D1
	ADDQ.L	#1,D1
	SUB.L	D1,D0
	BRA	OPCODE_DECODE_BSR_FINISH
OPCODE_DECODE_BSR_POS
	ADD.L	D1,D0		* determine the destination address (displacement + address)
OPCODE_DECODE_BSR_FINISH
	CLR.L	D1		* clear D1
	MOVE.B	#4,D1		* setup the size
	MOVE.L	A5,A1		* setup the "good" string as the output
	JSR	HEXTOASCII	* convert the value and add it to the string
	MOVE.L	A1,A5		* update the string pointer
	RTS

* MOVEQ
code0111	
	MOVE.B 	#$01,D7		* Set error code because we were unable to decode the intruction
	RTS

* OR/DIV/SBCD
code1000
	* Check for OR.x (default)
	LEA	str_OR,A1		* prep the string
	JSR	OPCODE_MODE_FIX
	OR.B	#%00000100,D4		* Set bit 2 = true to show this is a Dn 
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

* SUB/SUBX
code1001
	* Check for SUBA
	LEA	str_SUBA,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%1111000011000000,D1	* Isolate bits 8-15
	CMP.W	#%1001000011000000,D1	* Check to see if this is a ADDA
	BEQ	OPCODE_FIX_SUBA		* fix the values so we can finish decoding

	* Check for SUB (default)
	LEA	str_SUB,A1		* prep the string
	JSR	OPCODE_MODE_FIX
	OR.B	#%00000100,D4		* bit 2 = true to show this is a Dn 
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

OPCODE_FIX_SUBA
	MOVE.B	D4,D1			* Make a copy of D4 (the OPMode)
	AND.B	#%00000111,D1		* isolate bits 0-1
	MOVE.B	#%00000001,D4		* prep the size	+ set bit 2 = false because this is an An
	CMP.B	#%00000011,D1		* Is this an OPCode match for SUBA.W?
	BEQ	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction
	MOVE.B	#%00000010,D4		* prep the size	+ set bit 2 = false because this is an An	
	BRA	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction

* Unassigned
code1010	
	MOVE.B 	#$01,D7		* Set error code because we were unable to decode the intruction
	RTS

* CMP/EOR
code1011
	* Check for CMPA
	LEA	str_CMPA,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%1111000011000000,D1	* Isolate bits 8-15
	CMP.W	#%1011000011000000,D1	* Check to see if this is a ADDA
	BEQ	OPCODE_FIX_CMPA		* fix the values so we can finish decoding

	* Check for EOR
	LEA	str_EOR,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%1111000100000000,D1	* Isolate bits 8-15
	CMP.W	#%1011000100000000,D1	* Check to see if this is an EOR
	BEQ	OPCODE_FIX_EOR		* fix the values so we can finish decoding

	* Check for CMP (default)
	LEA	str_CMP,A1		* prep the string
	OR.B	#%00000100,D4		* bit 2 = true to show this is a Dn 
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction
	RTS

OPCODE_FIX_CMPA
	MOVE.B	D4,D1			* Make a copy of D4 (the OPMode)
	AND.B	#%00000111,D1		* isolate bits 0-1
	MOVE.B	#%00000001,D4		* prep the size	+ set bit 2 = false because this is an An
	CMP.B	#%00000011,D1		* Is this an OPCode match for CMPA.W?
	BEQ	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction
	MOVE.B	#%00000010,D4		* prep the size	+ set bit 2 = false because this is an An	
	BRA	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction

OPCODE_FIX_EOR
	MOVE.B	D4,D1			* Make a copy of D4 (the OPMode)
	AND.B	#%00000011,D4		* isolate bits 0-1
	OR.B	#%00001100,D4		* set to mode1 (Rn,EA) & specify Dn
	BRA	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction

* AND/MUL/ABCD/EXG
code1100
	* Check for EXG
	LEA	str_EXG,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%1111000111111000,D1	* Isolate bits 8-15
	CMP.W	#%1100000101000000,D1	* Check to see if this is an EOR (Dn,Dn)
	BEQ	OPCODE_FIX_EXG_TYPEA	* fix the values so we can finish decoding
	CMP.W	#%1100000101001000,D1	* Check to see if this is an EOR (An,An)
	BEQ	OPCODE_FIX_EXG_TYPEB	* fix the values so we can finish decoding
	CMP.W	#%1100000110001000,D1	* Check to see if this is an EOR (Dn,An)
	BEQ	OPCODE_FIX_EXG_TYPEC	* fix the values so we can finish decoding
	
	* Check for AND (default)
	LEA	str_AND,A1		* prep the string
	JSR	OPCODE_MODE_FIX
	OR.B	#%00000100,D4		* Set bit 2 = true to show this is a Dn 
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

OPCODE_FIX_EXG_TYPEA
	MOVE.B	#%00011111,D4		* set for mode4, no size (11), and Dn
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction
OPCODE_FIX_EXG_TYPEB
	MOVE.B	#%00011011,D4		* set for mode4, no size (11), and An
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction
OPCODE_FIX_EXG_TYPEC
	MOVE.B	#%00111111,D4		* set for mode8 and no size (11)
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%0000000000000111,D1	* Isolate bits 0-2
	MOVE.B	D1,D5			* copy the dst register to D5
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

* ADD/ADDA/ADDX
code1101
	* Check for ADDA
	LEA	str_ADDA,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%1111000011000000,D1	* Isolate bits 8-15
	CMP.W	#%1101000011000000,D1	* Check to see if this is a ADDA
	BEQ	OPCODE_FIX_ADDA		* fix the values so we can finish decoding

	* Check for ADD (default)
	LEA	str_ADD,A1		* prep the string
	JSR	OPCODE_MODE_FIX
	OR.B	#%00000100,D4		* bit 2 = true to show this is a Dn 
	BRA	OPCODE_DECODE_TYPEA	* decode the rest of the instruction

OPCODE_FIX_ADDA
	MOVE.B	D4,D1			* Make a copy of D4 (the OPMode)
	AND.B	#%00000111,D1		* isolate bits 0-1
	MOVE.B	#%00000001,D4		* prep the size	+ set bit 2 = false because this is an An
	CMP.B	#%00000011,D1		* Is this an OPCode match for ADDA.W?
	BEQ	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction
	MOVE.B	#%00000010,D4		* prep the size	+ set bit 2 = false because this is an An	
	BRA	OPCODE_DECODE_TYPEA	* If we found a match we're ready to decode the rest of the instruction

* Shift/Rotate
code1110
	* Check for ASR
	LEA	str_ASR,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00101100,D4		* set for mode6
	ANDI.W	#%1111111111000000,D1	* Isolate bits 
	CMP.W	#%1110000011000000,D1	* Check to see if this is a ASR w EA
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00100100,D4		* set for mode5
	ANDI.W	#%1111000100111000,D1	* Isolate bits 
	CMP.W	#%1110000000000000,D1	* Check to see if this is a ASR w/o EA (reg = shift count)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00011100,D4		* set for mode4
	CMP.W	#%1110000000100000,D1	* Check to see if this is a ASR w/o EA (reg = reg)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding

	* Check for ASL
	LEA	str_ASL,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00101100,D4		* set for mode6
	ANDI.W	#%1111111111000000,D1	* Isolate bits 
	CMP.W	#%1110000111000000,D1	* Check to see if this is a ASL w EA
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00100100,D4		* set for mode5
	ANDI.W	#%1111000100111000,D1	* Isolate bits 
	CMP.W	#%1110000100000000,D1	* Check to see if this is a ASL w/o EA (reg = shift count)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00011100,D4		* set for mode4
	CMP.W	#%1110000100100000,D1	* Check to see if this is a ASL w/o EA (reg = reg)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding

	* Check for LSR
	LEA	str_LSR,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00101100,D4		* set for mode6
	ANDI.W	#%1111111111000000,D1	* Isolate bits 
	CMP.W	#%1110001011000000,D1	* Check to see if this is a LSR w EA
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00100100,D4		* set for mode5
	ANDI.W	#%1111000100111000,D1	* Isolate bits 
	CMP.W	#%1110000000001000,D1	* Check to see if this is a LSR w/o EA (reg = shift count)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00011100,D4		* set for mode4
	CMP.W	#%1110000000101000,D1	* Check to see if this is a LSR w/o EA (reg = reg)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding

	* Check for LSL
	LEA	str_LSL,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00101100,D4		* set for mode6
	ANDI.W	#%1111111111000000,D1	* Isolate bits 
	CMP.W	#%1110001111000000,D1	* Check to see if this is a LSL w EA
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00100100,D4		* set for mode5
	ANDI.W	#%1111000100111000,D1	* Isolate bits 
	CMP.W	#%1110000100001000,D1	* Check to see if this is a LSL w/o EA (reg = shift count)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00011100,D4		* set for mode4
	CMP.W	#%1110000100101000,D1	* Check to see if this is a LSL w/o EA (reg = reg)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding

	* Check for ROR
	LEA	str_ROR,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00101100,D4		* set for mode6
	ANDI.W	#%1111111111000000,D1	* Isolate bits 
	CMP.W	#%1110011011000000,D1	* Check to see if this is a ROR w EA
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00100100,D4		* set for mode5
	ANDI.W	#%1111000100111000,D1	* Isolate bits 
	CMP.W	#%1110000000011000,D1	* Check to see if this is a ROR w/o EA (reg = shift count)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00011100,D4		* set for mode4
	CMP.W	#%1110000000111000,D1	* Check to see if this is a ROR w/o EA (reg = reg)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding

	* Check for ROL
	LEA	str_ROL,A1		* prep the string
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00101100,D4		* set for mode6
	ANDI.W	#%1111111111000000,D1	* Isolate bits 
	CMP.W	#%1110011111000000,D1	* Check to see if this is a ROL w EA
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	MOVE.W	D0,D1			* Make a copy of D1 (the OPCode)
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00100100,D4		* set for mode5
	ANDI.W	#%1111000100111000,D1	* Isolate bits 
	CMP.W	#%1110000100011000,D1	* Check to see if this is a ROL w/o EA (reg = shift count)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding
	ANDI.W	#%00000011,D4 		* keep the size
	ORI.W	#%00011100,D4		* set for mode4
	CMP.W	#%1110000100111000,D1	* Check to see if this is a ROL w/o EA (reg = reg)
	BEQ	OPCODE_DECODE_TYPEA	* fix the values so we can finish decoding

	MOVE.B 	#$01,D7		* Set error code because we were unable to decode the intruction
	RTS

* Special/Reserved
code1111	
	MOVE.B 	#$01,D7		* Set error code because we were unable to decode the intruction
	RTS
	
**********************************************************************************************

OPCODE_DECODE_TYPEA
	* D4 breakdown:
	*   bits 0-1 = the size
	*   bit 2    = type of register (0 = An, 1 = Dn)    
	*   bits 3-6 = mode

	* Update the "good" string
	MOVE.L	A5,A2			* Setup the "good" string as the DST
	JSR	STRCPY			* Call STRCPY
	MOVE.L	A2,A5			* Update the string pointer
	* Add the size (unless size = 11)
	MOVE.B	D4,D1			* Make a copy of D4
	AND.B	#%00000011,D1		* isolate bit #0-1
	CMP.B	#%00000000,D1		* is this a BYTE?
	BEQ	OPCODE_SIZE_B
	CMP.B	#%00000001,D1		* is this a WORD?
	BEQ	OPCODE_SIZE_W
	CMP.B	#%00000010,D1		* is this a LONG?
	BEQ	OPCODE_SIZE_L		
OPCODE_DECODE_TYPEA_CONT
	JSR 	OPCODE_PAD		* align the string for the next column
	MOVE.B	D4,D1			* Make a copy of D4
	AND.B	#%01111000,D1		* isolate bit #2-5
	CMP.B	#%00000000,D1		* 000 = mode1 (EA,Rn)
	BEQ	OPCODE_MODE1	 
	CMP.B	#%00001000,D1		* 0001 = mode2 (Rn,EA)
	BEQ	OPCODE_MODE2	
	CMP.B	#%00011000,D1		* 0011 = mode4 (Rn,Rn)
	BEQ	OPCODE_MODE4	
	CMP.B	#%00100000,D1		* 0100 = mode5 (#shift,Rn)
	BEQ	OPCODE_MODE5	
	CMP.B	#%00101000,D1		* 0101 = mode6 (EA)
	BEQ	OPCODE_MODE6	
	CMP.B	#%00110000,D1		* 0101 = mode7 (EA,EA)
	BEQ	OPCODE_MODE7	
	CMP.B	#%00111000,D1		* 0101 = mode8 (Dn,An)
	BEQ	OPCODE_MODE8	
	CMP.B	#%01000000,D1		* 1000 = mode9 (Rn)
	BEQ	OPCODE_MODE9	
	
	MOVE.B	D4,D1			* Make a copy of D4
	AND.B	#%00111011,D1		* isolate bit #0-4
	CMP.B	#%00010000,D1		* 01100 = mode3 w/byte (#,EA)
	BEQ	OPCODE_MODE3_BYTE	
	CMP.B	#%00010001,D1		* 01101 = mode3 w/word (#,EA)
	BEQ	OPCODE_MODE3_WORD	
	CMP.B	#%00010010,D1		* 01110 = mode3 w/long (#,EA)
	BEQ	OPCODE_MODE3_LONG	

	MOVE.B 	#$01,D7			* Set error code because we were unable to decode the intruction
	RTS
OPCODE_MODE1
	JSR	EADECODE		* Try to decode the EA
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	OPCODE_PRINTREG		* print the reg
	RTS	
OPCODE_MODE2
	JSR	OPCODE_PRINTREG		* print the reg
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	EADECODE		* Try to decode the EA
	RTS	
OPCODE_MODE3_BYTE
	MOVE.B	#$23,(A5)+		* Add a "#" 
	MOVE.B	#$24,(A5)+		* Add a "$" 
	MOVE.W	(A0)+,D0		* read in the next word (but we will only look at the byte)
	CLR.L	D1			* clear D1
	MOVE.L	#1,D1			* setup the size (1 byte)
	MOVE.L	A5,A1			* setup the "good" string as the output
	JSR	HEXTOASCII		* convert the value and add it to the string
	MOVE.L	A1,A5			* update the string pointer
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE3_WORD
	MOVE.B	#$23,(A5)+		* Add a "#" 
	MOVE.B	#$24,(A5)+		* Add a "$" 
	MOVE.W	(A0)+,D0		* read in the next word
	CLR.L	D1			* clear D1
	MOVE.L	#2,D1			* setup the size (2 byte)
	MOVE.L	A5,A1			* setup the "good" string as the output
	JSR	HEXTOASCII		* convert the value and add it to the string
	MOVE.L	A1,A5			* update the string pointer
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE3_LONG
	MOVE.B	#$23,(A5)+		* Add a "#" 
	MOVE.B	#$24,(A5)+		* Add a "$" 
	MOVE.L	(A0)+,D0		* read in the next long
	MOVE.L	#4,D1			* setup the size (4 bytes)
	MOVE.L	A5,A1			* setup the "good" string as the output
	JSR	HEXTOASCII		* convert the value and add it to the string
	MOVE.L	A1,A5			* update the string pointer
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE4
	JSR	OPCODE_PRINTREG		* print the reg
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D0,D3			* copy the OPCode to D3 (register)
	ANDI.W	#$0007,D3		* isolate the register data
	JSR	OPCODE_PRINTREG		* print the second reg
	RTS
OPCODE_MODE5
	MOVE.B	#$23,(A5)+		* Add a "#" 
	MOVE.B	#$24,(A5)+		* Add a "$" 
	MOVE.W	D0,D5			* copy the OPCode to D5 (register)
	ANDI.W	#$0007,D5		* isolate the register data
	MOVE.B	D3,D0			* Move D3 (the # of bits to shift) to D0
	MOVE.L	#1,D1			* setup the size (1 byte)
	MOVE.L	A5,A1			* setup the "good" string as the output
	JSR	HEXTOASCII		* convert the value and add it to the string
	MOVE.L	A1,A5			* update the string pointer
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D5,D3			* copy the D5 (the register) to D3
	JSR	OPCODE_PRINTREG		* print the reg
	RTS
OPCODE_MODE6
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE7
	* Need to decode 2 EA addresses (MOVE)
	JSR	EADECODE		* Try to decode the EA
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D0,D5			* copy D0 
	ANDI.W	#%0000111000000000,D5	* isolate bits
	ROR.W	#6,D5			* shift the bits
	ROR.W	#3,D5			* shift the bits
	MOVE.W	D0,D1			* copy D0 
	ANDI.W	#%0000000111000000,D1	* isolate bits
	ROR.W	#3,D1			* shift the bits
	OR.W	D1,D5			* combine the values (in the correct order)
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE8
	* Src register # must be in D3 (Dn)
	* Dst register # must be in D5 (An)
	ORI.B	#%00000100,D4		* set Dn
	JSR	OPCODE_PRINTREG		* print the reg
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D5,D3			* copy the Dst register to D3
	ANDI.B	#%00000011,D4		* make sure we're set for An
	JSR	OPCODE_PRINTREG		* print the second reg
	RTS
OPCODE_MODE9
	JSR	OPCODE_PRINTREG		* print the reg
	RTS	

* call to add size info
OPCODE_SIZE_B
	MOVE.B	#$2E,(A5)+		* Add a period 
	MOVE.B	#$42,(A5)+		* Add a "B"
	BRA	OPCODE_DECODE_TYPEA_CONT
OPCODE_SIZE_W
	MOVE.B	#$2E,(A5)+		* Add a period 
	MOVE.B	#$57,(A5)+		* Add a "W"
	BRA	OPCODE_DECODE_TYPEA_CONT
OPCODE_SIZE_L
	MOVE.B	#$2E,(A5)+		* Add a period 
	MOVE.B	#$4C,(A5)+		* Add a "L"
	BRA	OPCODE_DECODE_TYPEA_CONT

* call this to print the Rn (as specified in D3 and the Rn bit in D4)
OPCODE_PRINTREG
	* D4 = the mode info (Dn/An)
	* D3 = the register number
	MOVE.B	D4,D1			* Make a copy of D4
	AND.B	#%00000100,D1		* isolate bit #3
	CMP.B	#%00000000,D1		* see if bit #3 = false (An)
	BEQ	OPCODE_PRINTREG_An	* if match then print an An
	MOVE.B	#$44,(A5)+		* Add a "D" 
	BRA 	OPCODE_PRINTREG_CONT
OPCODE_PRINTREG_An
	MOVE.B	#$41,(A5)+		* Add a "A" 
OPCODE_PRINTREG_CONT
	ADD.B	#$30,D3			* convert to ascii
	MOVE.B	D3,(A5)+		* Add the number to the string 
	RTS

* Call this for any instruction that only needs to update the good string and nothing else
OPCODE_DECODE_TYPEB
	* Update the "good" string
	MOVE.L	A5,A2			* Setup the "good" string as the DST
	JSR	STRCPY			* Call STRCPY
	MOVE.L	A2,A5			* Update the string pointer
	RTS

* Call this for instructions with the EA, OPMode, and Register data in standard locations
OPCODE_DECODE_GET
	* Parameters:
	* D0 = the OPCode
	*
	* Returns:
	* D3 = Register bits
	* D4 = OPMode bits
	* D5 = EA bits
	MOVEM.L	D0,-(SP)		* Push register data onto the stack so we can restore it at the end

	MOVE.W	D0,D1			* Copy the OPCode to D1
	ANDI.W	#%0000000000111111,D1	* Get the last 6 bits
	MOVE.B	D1,D5			* copy the EA bits into D5
	
	ROR.W	#6,D0			* Roll the bits right by 6
	MOVE.W	D0,D1			* Copy the OPCode to D1
	ANDI.W	#%0000000000000111,D1	* Get the last 3 bits
	MOVE.B	D1,D4			* copy the OPMode bits into D4
	
	ROR.W	#3,D0			* Roll the bits right by 3
	MOVE.W	D0,D1			* Copy the OPode to D1
	ANDI.W	#%0000000000000111,D1	* Get the last 3 bits
	MOVE.B	D1,D3			* copy the Register bits into D3

	MOVEM.L	(SP)+,D0		* Pop register data off the stack and restore it 
	RTS

* Call this for commands like ADD and OR where they could be EA,Rn or Rn,EA depending on the 3rd bit in the OPMODE
OPCODE_MODE_FIX
	MOVE.B	D4,D1			* make a copy
	ANDI.B	#%00000100,D1		* isoate bit #3
	CMP.B	#%00000100,D1		* is the bit = true?
	BNE	OPCODE_MODE_FIX_DONE
	ANDI.B	#%00000011,D4		* isolate the size bits
	OR.B	#%00001000,D4		* set for mode2 (Rn,EA)
OPCODE_MODE_FIX_DONE
	RTS
	
* This small function will ensure that the next column lines up correctly
OPCODE_PAD
	MOVE.L	A5,D2			* copy the memory address of the end of the string to D2
	SUB.L	#str_good,D2		* get the length of the good string
	SUBI.L	#10,D2			* subtract 8 from the length (should give us a negative number)
	MULU	#-1,D2			* multiply by -1 to make positive
OPCODE_PAD_MORE
	MOVE.B	#$20,(A5)+		* Add a space
	DBF	D2,OPCODE_PAD_MORE	* While D2 > 0 keep padding the string with spaces
	RTS

**********************************************************************************************
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
; SUBROUTINE EADECODE
; this subroutine can be called to decode the 6 bit EA code from an instruction
; opcode. If further memory reading is deemed necessary, the read data will be
; sent to the subroutine HEXTOASCII.
;
; ASSUMPTIONS:
;		HEXTOASCII uses D0 and D1 as parameters.
;		HEXTOASCII will add the converted values to the A1 pointer.
;
; REQUIREMENTS (from OPCODE SR):
;	D4	can be used to store the size of the operation. This should be
;		initialized by the OPCode person, but is only necessary if the
;		EA turns out to be immediate data.
;	D5	must contain the mode and reg bits that comprise the EA.
;	A0	must represent the pointer to the next memory word to be read.
;		If this pointer is not current, problems will ensue.
;	A1	must represent the pointer to the end of the "good buffer".
;		If this is not current then there will be problems with I/O.
;	SP	is the stack pointer. So long as no one misuses this, there
;		shouldn't be any problems.
; NOTE:
;	D7	is or contains flags to ultimately signal the I/O to print
;		the "good" or "bad" buffer. This subroutine does not test
;		for any illegality so D7 is likely untouched
; USES:
;	D0	will be used to store words read from memory that need to be
;		converted to ASCII by the subroutine HEXTOASCII.
;	D1	will be used to store the size of the data in D0 in bytes. Will
;		be set to 2 for a word or 4 for a long word.
;	D3	will contain the reg bits.
;
;
EADECODE	MOVEM.L		D0-D6/A2-A4,-(SP)	; save registers that will be used for things are purely local
;************************************************************************************
		MOVE.L		A5,A1		; copy the good buffer pointer to A1
	;----------------------------------------------------------------
	; SEPARATE THE MODE AND REG
		MOVE.B		D5,D3
		ANDI.B		#%00000111,D3
		ANDI.B		#%00111000,D5
		LSR.B		#3,D5
	;----------------------------------------------------------------
	; A JUMP TABLE
		CMP.B		#0,D5
		BEQ		MODE_ZERO
		CMP.B		#1,D5
		BEQ		MODE_ONE
		CMP.B		#2,D5
		BEQ		MODE_TWO
		CMP.B		#3,D5
		BEQ		MODE_THREE
		CMP.B		#4,D5
		BEQ		MODE_FOUR
		CMP.B		#5,D5
		BEQ		MODE_FIVE
		CMP.B		#6,D5
		BEQ		MODE_SIX
		CMP.B		#7,D5
		BEQ		MODE_SEVEN
	;----------------------------------------------------------------
	; INVALID MODE
		ORI.B		#$02,D7	; FLAG SET
		BRA		FINISH
;*************************************************************************************
; DATA REGISTER DIRECT MODE
; Basic EA that displays a capital 'D' and a number
; ex: D4
MODE_ZERO	ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$44,(A1)+	; add 'D' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
		BRA		FINISH		; we have now added D# to the good buffer
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER DIRECT MODE
; Basic EA that displays a capital 'A' and a number
; ex: A2
MODE_ONE	CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGONE
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MONE_X		BRA		FINISH		; we have now added A# to the good buffer
SPREGONE	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MONE_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT MODE
; Slightly more complicated than the previous EA. Displays 'A' and number in parentheses.
; ex: (A6)
MODE_TWO	MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGTWO
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MTWO_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		FINISH		; we have now added (A#) to the good buffer
SPREGTWO	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MTWO_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH POSTINCREMENT MODE
; Slightly more complicated that the previous EA. Displays parenthized 'A' and number with
; a '+' at the end.
; ex: (A1)+
MODE_THREE	MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGTHR
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MTHR_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		MOVE.B		#$2B,(A1)+	; add '+' to the good buffer
		BRA		FINISH		; we have now added (A#) to the good buffer
SPREGTHR	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MTHR_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH PREDECREMENT MODE
; Similar to the previous EA except with a '-' at the beginning instead of a '+' at the end.
; ex: -(A5)
MODE_FOUR	MOVE.B		#$2D,(A1)+	; add '-' to the good buffer
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGFOR
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MFOR_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		FINISH		; we have now added (A#) to the good buffer
SPREGFOR	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MFOR_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH DISPLACEMENT MODE
; This is like the ADDRESS REGISTER INDIRECT (parenthized A#) but with a 16bit displacement
; immediately preceding. Negative displacements are actually displayed as negatives.
; ex: $7C49(A3)
; NOTE there are other (not used) acceptable syntax
; -- ($7C49)(A3)
; -- ($7C49,A3)
; NOTE displacements are sign-extended to 32bits
MODE_FIVE	MOVE.W		(A0)+,D0	; read one word from memory into D0
		MOVE.B		#$02,D1		; size of D0 in bytes
	; if the displacement is greater that 7fff then it is negative
		MOVE.W		D0,D6
		ANDI.W		#$8000,D6	; MASK the sign bit
		BNE		ARID_ADJ	; if sign bit is 1 then goto adjuster
ARID_CB		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXTOASCII	; SEND D0 TO FUNCTION TOHEX
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGFIV
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MFIV_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		FINISH		; we have now added [####(A#)]
ARID_ADJ	MOVE.B		#$2D,(A1)+	; add '-' to signify a negative displacement
	; twos complement means flip every bit, and add one
		NOT.W		D0
		ADDQ.W		#1,D0
		BRA		ARID_CB		; resume normal flow
SPREGFIV	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MFIV_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH INDEX (8-BIT DISP) MODE
; This is similar to the above EA but w/ an addtional figure to add in (an Index). The
; displacement is only 8bits long this time. The index is displayed after a comma inside
; the parentheses. The index is a register dot size. Negative displacements are actually
; displayed as negatives.
; ex: $5B(A6,D4.L)
; NOTE there are other (not used) acceptable syntax
; -- ($5B)(A6,D4.L)
; -- ($5B,A6,D4.L)
; NOTE displacements are sign-extended to 32bits
MODE_SIX	MOVE.W		(A0)+,D0	; read one word into a scratch data register
		MOVE.W		D0,D6		; copy the word
		ANDI.W		#$00FF,D0	; the displacement
		ANDI.W		#$FF00,D6	; the index
		LSR.W		#8,D6		; is moved to lsbp
		MOVE.B		#1,D1		; for counter
	; if the displacement is greater that 7f then it is negative
		MOVE.W		D0,D2		; make copy for anding
		ANDI.L		#$00000080,D2	; MASK sign bit
		BNE		ARII_ADJ
ARII_CB		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXTOASCII	; add the displacement to the good buffer
		; D0 and D2 ARE FREE AGAIN
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGSIX
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		D3,(A1)+	; add number to the good buffer
		; d3 is free
MSIX_X		MOVE.B		#$2C,(A1)+	; add ',' to the good buffer
		LSL.B		#1,D6		; PUSH into x
		BCC		DREG
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		BRA		NXT
DREG		MOVE.B		#$44,(A1)+	; add 'D' to the good buffer
NXT		MOVE.B		D6,D2
		ANDI.B		#$E0,D2
		LSR.B		#5,D2		; IND REG number
		ADDI.B		#48,D2		; convert number to ascii
		MOVE.B		D2,(A1)+	; add number to the good buffer
		MOVE.B		#$2E,(A1)+	; add '.' to the good buffer
		ANDI.B		#$10,D6
		BEQ		SIZB
		MOVE.B		#$4C,(A1)+	; add 'L' to the good buffer
		BRA		NXT2
SIZB		MOVE.B		#$57,(A1)+	; add 'W' to the good buffer
NXT2		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		FINISH		;
ARII_ADJ	MOVE.B		#$2D,(A1)+	; add a '-' because the displacement is negative
	; twos complement means flip every bit, and add one
		NOT.B		D0
		ADDQ.B		#1,D0
		BRA		ARII_CB
SPREGSIX	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MSIX_X
;-------------------------------------------------------------------------------------
; The following five codes are for when the MODE IS 7 (111)
;-------------------------------------------------------------------------------------
; since mode seven is the only one that has several addressing modes, it is fortunate
; that it is that last one (according to its mode number)
	;----------------------------------------------------------------
	; A JUMP TABLE
MODE_SEVEN	CMP.B		#0,D3
		BEQ		REG_ZERO
		CMP.B		#1,D3
		BEQ		REG_ONE
		CMP.B		#2,D3
		BEQ		REG_TWO
		CMP.B		#3,D3
		BEQ		REG_THREE
		CMP.B		#4,D3
		BEQ		REG_FOUR
	;----------------------------------------------------------------
	; INVALID REGISTER
		ORI.B		#$01,D7		; FLAG SET
		BRA		FINISH
;-------------------------------------------------------------------------------------
; REG 000 ABSOLUTE SHORT ADDRESSING MODE
REG_ZERO	MOVE.W		(A0)+,D0	; read one word from memory into D0
		MOVE.B		#$02,D1		; size of D0 in bytes
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXTOASCII	; SEND D6 TO FUNCTION TOHEX
		BRA		FINISH
;-------------------------------------------------------------------------------------
; REG 001 ABSOLUTE LONG ADDRESSING MODE
REG_ONE		MOVE.L		(A0)+,D0	; read one word from memory into D0
		MOVE.B		#$04,D1		; size of D0 in bytes
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXTOASCII	; SEND D6 TO FUNCTION TOHEX
		BRA		FINISH
;-------------------------------------------------------------------------------------
; REG 010 PROGRAM COUNTER INDIRECT WITH DISPLACEMENT MODE
; displacement is sign-extended
REG_TWO		MOVEA.W		A0,A2		; save a copy of the "PC" of the test program
		MOVE.W		(A0)+,D0	; D0 is current displacement
		ADDQ.L		#2,D0		; D0 is now actual displacement from the calling command
		MOVE.L		D0,D2		; save disp for analysis
		ANDI.L		#$00008000,D0	; mask the sign bit
		BNE		PCID_ADJ	; if disp is negative, then adjust
PCID_CB		ADD.L		A2,D0		; add complete disp to get address with that displacement
		MOVE.L		#$04,D1		; start size of address at long
		MOVE.L		D0,D2		; if first byte is zero, decrease size
		AND.L		#$FF000000,D2
		BNE		SIZEREADY1
		SUBQ.B		#1,D1
		MOVE.L		D0,D2		; if second byte is zero, decrease size
		AND.L		#$00FF0000,D2
		BNE		SIZEREADY1
		SUBQ.B		#1,D1
	; now size has been reduced to prevent unneccessary leading zeros
SIZEREADY1	MOVE.B		#$24,(A1)+	; print '$'
		JSR		HEXTOASCII	; print address
		MOVE.B		#$28,(A1)+	; print '('
		MOVE.B		#$50,(A1)+	; pring 'P'
		MOVE.B		#$43,(A1)+	; print 'C'
		MOVE.B		#$29,(A1)+	; print ')'
		BRA		FINISH
PCID_ADJ	MOVE.L		#$FFFF0000,D0	; manually sign-extend
		ADD.W		D2,D0		; with adding
		BRA		PCID_CB
;-------------------------------------------------------------------------------------
; REG 011 PROGRAM COUNTER INDIRECT WITH INDEX (8-BIT DISP) MODE ?UNNECESSARY?
; displacement is sign-extended
REG_THREE	ADDI.B		#48,D3		; convert register into number
	; because it is PC
		MOVEA.W		A0,A2		; save a copy of the "PC" of the test program
		MOVE.W		(A0)+,D0	; read one word into a scratch data register
		MOVE.W		D0,D3		; copy the word
		ANDI.W		#$00FF,D0	; D0 is the current displacement
		ADDQ.L		#2,D0		; D0 is now actual displacement from the calling command
		; this is for the displacement
		MOVE.L		D0,D2		; copy disp for anding
		ANDI.L		#$00000080,D0	; mask the sign bit
		BNE		PCII_ADJ	; if negative, then adjust
PCII_CB		ADD.L		A2,D0		; add disp to PC to get address 
		; GOT THE ADDRESS AND D2 IS NOW FREE
		MOVE.L		#$04,D1		; start size of address at long
		MOVE.L		D0,D2		; if first byte is zero, decrease size
		AND.L		#$FF000000,D2
		BNE		SIZEREADY2
		SUBQ.B		#1,D1
		MOVE.L		D0,D2		; if second byte is zero, decrease size
		AND.L		#$00FF0000,D2
		BNE		SIZEREADY2
		SUBQ.B		#1,D1
		; GOT THE CORRECT SIZE OF THE ADDRESS
SIZEREADY2	ANDI.W		#$FF00,D3	; the index
		LSR.W		#8,D3		; is moved to lsbp
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXTOASCII	; add the displacement to the good buffer
		; D0 IS FREE AGAIN
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		MOVE.B		#$50,(A1)+	; add 'P' to the good buffer
		MOVE.B		#$43,(A1)+	; add 'C' to the good buffer
		MOVE.B		#$2C,(A1)+	; add ',' to the good buffer
		LSL.B		#1,D3		; PUSH into x
		BCC		DREG2
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		BRA		NXT11
DREG2		MOVE.B		#$44,(A1)+	; add 'D' to the good buffer
NXT11		MOVE.B		D3,D2		; copy the rest of the index
		ANDI.B		#$E0,D2		; mask number
		LSR.B		#5,D2		; shift
		ADDI.B		#48,D2		; convert
		MOVE.B		D2,(A1)+	; add number to the good buffer
		;NUMBER
		MOVE.B		#$2E,(A1)+	; add '.' to the good buffer
		ANDI.B		#$10,D6		; mask size bit
		BEQ		SIZB1
		MOVE.B		#$4C,(A1)+	; add 'L' to the good buffer
		BRA		NXT12
SIZB1		MOVE.B		#$57,(A1)+	; add 'W' to the good buffer
NXT12		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		FINISH		;
PCII_ADJ	MOVE.L		#$FFFFFF00,D0	; manually sign-extend
		ADD.B		D2,D0
		BRA		PCII_CB
;-------------------------------------------------------------------------------------
; REG 100 IMMEDIATE DATA
; Pretty simple but requires knowledge of operation size. Size should be stored the lowest
; two bits of D4.
REG_FOUR	ANDI.B		#%00000011,D4	; mask the size bits
		CMP.B		#$02,D4		; is the size LONG?
		BNE		WORB		; if not, go to the section for word
		MOVE.B		#$04,D1		; for a long put size (in bytes)
		MOVE.L		(A0)+,D0	; take a long from mem
		BRA		FIN		; skip over word
WORB		MOVE.B		#$02,D1		; for a word put size (in bytes)
		MOVE.W		(A0)+,D0	; take a word from mem
FIN		MOVE.B		#$23,(A1)+	; add '#' to the good buffer
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXTOASCII	; SEND D0 and D1 TO FUNCTION HEXTOASCII
FINISH		MOVEM.L		(SP)+,D0-D6/A2-A4
		MOVE.L		A1,A5		
		RTS
**********************************************************************************************
* STRCPY - 
*	   
* A1 = SRC: The memory location of the start of the string.
* A2 = DST: The memory location of the start of the string.
* D1 = Internal
* D2 = Internal
*

STRCPY
	MOVEM.L	D1-D2,-(A7)	* Push register data onto the stack so we can restore it at the end
	CLR.L	D1		* Clear D1 (counter)
	MOVE.B	$FF,D1		* Set D1 to $FF (max string length)

STRCPY_NEXT
	MOVE.B	(A1)+,D2	* Copy the next byte into a register
	CMP.B	#$00,D2		* See if we hit a null/end of string
	BEQ	STRCPY_DONE	* Go to the end if we're finished
	
	MOVE.B	D2,(A2)+	* Copy the byte to the dest string
	DBF D1,STRCPY_NEXT	* If there is more to process, go to the next byte

STRCPY_DONE
	MOVEM.L	(A7)+,D1-D2	* Pop register data off the stack and restore it 
	RTS	

**********************************************************************************************
**********************************************************************************************
* ASCIITOHEX - This function converts a string input from user to an address value.
* Valid inputs are numbers and uppercase letters (A-F) only
*	   
* A1 = The memory location of the start of the string.
* D0 = Internal - holds temp value
* D1 = Length of string (param assigned from outside), on return holds 0 (success) or non-zero (error)
* D2 = Internal (counter)
* D3 = Final address value (return value)

ASCIITOHEX
	MOVEM.L	D0/D2,-(SP)	*Push register data onto the stack so we can restore it at the end

	* Test input. WHAT ARE WE REALLY TESTING?
	CMP.B	#8, D1			* Make sure D1 <= 8
	BGT	ASCIITOHEX_ERROR	* Invalid address size, exit
	CMP.B	#0, D1			* Make sure D1 is > 0
	BLE	ASCIITOHEX_ERROR	* Invalid address size, exit
	
	CLR.L	D3		* Clear the return value
	SUBQ.B	#1,D1		* Subtract 1 from the counter (zero based)

ASCIITOHEX_LOOP	* This loop uses D1 as its counter
	ROL.L	#4, D3			* shift the bits left by 4
	MOVE.B	(A1)+, D0		* Copy the next byte from memory for conversion
	CMP.B	#$39, D0		* If the value is < $39 it is either a number or it is invalid
	BGT	ASCIITOHEX_LETTER	* If this is a letter, go to the letter processing 
	CMP.B	#$30, D0		* If the value is < $30 then it is invalid
	BLT	ASCIITOHEX_ERROR	* Return an error
	SUBI.B	#$30, D0		* Since this is a valid number, subtract $30
	BRA	ASCIITOHEX_FINISH_LOOP

ASCIITOHEX_LETTER
	CMP.B	#$66, D0		* If the value is > $66 then the input is invalid
	BGT	ASCIITOHEX_ERROR	* Return an error
	CMP.B	#$61, D0		* If the value >= $61 then this is a valid lower case letter
	BGE	ASCIITOHEX_LLETTER	* Process a lowercase letter
	
	CMP.B	#$46, D0		* If the value is > $46 then the input is invalid
	BGT	ASCIITOHEX_ERROR	* Return an error
	CMP.B	#$41, D0		* If the value is < $41 then the input is invalid
	BLT	ASCIITOHEX_ERROR	* Return an error
	SUBI.B	#$37, D0		* Since this is a valid letter (A-F) subtract $37
	BRA	ASCIITOHEX_FINISH_LOOP
	
ASCIITOHEX_LLETTER
	SUBI.B	#$57, D0
	BRA	ASCIITOHEX_FINISH_LOOP
	
ASCIITOHEX_FINISH_LOOP
	OR.B	D0, D3			* OR the results into the return value
	DBF	D1, ASCIITOHEX_LOOP	* decement the counter and loop while > 0
	CLR.L	D1			* clear D1 to show that the conversion was successful
	BRA	ASCIITOHEX_X		* finished

ASCIITOHEX_ERROR
	MOVE.B	#$01,D1		* Return error in D1 (0 = success)
ASCIITOHEX_X
	MOVEM.L	(SP)+,D0/D2	* Pop register data off the stack and restore it
	RTS			* Exit sub-routine

**************************************************************************************************
**********************************************************************************************
* HEXTOASCII - this function takes 2 parameters.  A number is converted into
*         hex (ascii) and saved at the memory location specified
*
* A1 = The memory location where the output will be written
* D0 = The value to convert 
* D1 = The size of the operation (1-4: this is the number of bytes to process)
* D2 = Internal
* D3 = Internal

HEXTOASCII
	*Test inputs and setup
	ANDI.L	#$000000FF,D1	*Clear everything except the byte
	CMP.B	#4,D1		*Make sure D1 is <= 3
	BGT	HEXTOASCII_X	*If invalid exit with no action
	CMP.B	#0,D1		*Make sure D1 is > 0
	BLE	HEXTOASCII_X	*If invalid exit with no action
	MOVEM.L	D0/D2-D3,-(A7)	*Push register data onto the stack so we can restore it at the end
	ROL.L	#1,D1		*multiple the counter by 2 (since we need to look at nibbles)
	SUBQ.L	#1,D1		*decrement the counter (since it needs to be zero based)
	MOVE.L	D1,D3		*Save the counter so we can use it at the end to pop the chars off the stack
	
*Loop1: This is where each hex digit is converted into ascii
HEXTOASCII_LOOP1
	MOVE.L 	D0,D2		*Make a copy of the data we're going to convert
	ANDI.B	#NMASK,D2	*only look at the first nibble
	CMP.B	#9,D2		*Compare to 9
	BGT	HEXTOASCII_LETTER	*Is this a letter? (if the value is > 9)
	ADDI	#48,D2		*For numbers add 48 (the value is <= 9)
	BRA	HEXTOASCII_NEXT	*Skip the letter section
HEXTOASCII_LETTER
	ADDI	#55,D2		*For letters add 55
HEXTOASCII_NEXT	
	MOVE.B 	D2,-(A7) 		*Push the data onto the stack
	ROR.L	#4,D0			*Shift the bits in D0 to the right (by 4 bits)
	DBF	D1,HEXTOASCII_LOOP1	*Use D1 as the counter 

*Loop2: This is where we write the output as a string to the memory location in A1
HEXTOASCII_LOOP2
	MOVE.B	(A7)+,(A1)+		*Pop each ascii character off the stack (and now in the correct order)
	DBF	D3,HEXTOASCII_LOOP2	*decement the counter and loop while > 0
	
	*All finished, time for clean up
	MOVEM.L	(A7)+,D0/D2-D3	*Pop register data off the stack and restore the registers
	
HEXTOASCII_X	RTS

**********************************************************************************************

**********************************************************************************************

* Variables and Strings
user_input	DCB.B	256,0	* this will store the input entered by the user
str_good	DCB.B	256,0	* string containing the "good" data
str_bad		DCB.B	256,0	* string containing the "bad" data

***********************
* Declare some error messages used in I/O
str_error00	DC.B	'Unknown error.',$0
str_error01	DC.B	'Value entered was invalid.',$0
str_error02	DC.B	'Start address is >= (End address - 4).',$0
str_error03	DC.B	'Start address is < min address.',$0
str_error04	DC.B	'End address is > max address. ',$0
************************

welcome0	DC.B	'***************************************************', $0
welcome1	DC.B	'Welcome to our CSS 422 Disassembler!', $0
str_empty	DC.B	'', $0
str_prompt1	DC.B    'What is the starting address of the program? ',$0  
str_prompt2	DC.B	'  What is the ending address of the program? ',$0
str_scrnfull	DC.B	'Click enter to continue... ',$0
str_finito	DC.B	'Program Completely Decoded',$0

str_movem_pre	DC.B	'A7','A6','A5','A4','A3','A2','A1','A0','D7','D6','D5','D4','D3','D2','D1','D0'
str_movem_post	DC.B	'D0','D1','D2','D3','D4','D5','D6','D7','A0','A1','A2','A3','A4','A5','A6','A7'
str_unknown	DC.B	'DATA',$0
str_ADD		DC.B	'ADD',$00
str_ADDA	DC.B	'ADDA',$00
str_ADDI	DC.B	'ADDI',$00
str_AND		DC.B	'AND',$00
str_ANDI	DC.B	'ANDI',$00
str_ASL		DC.B	'ASL',$00
str_ASR		DC.B	'ASR',$00
str_BSR		DC.B	'BSR',$00
str_CLR		DC.B	'CLR',$00
str_CMP		DC.B	'CMP',$00
str_CMPA	DC.B	'CMPA',$00
str_CMPI	DC.B	'CMPI',$00
str_DATA	DC.B	'DATA',$00
str_EOR		DC.B	'EOR',$00
str_EORI	DC.B	'EORI',$00
str_EXG		DC.B	'EXG',$00
str_JMP		DC.B	'JMP',$00
str_JSR		DC.B	'JSR',$00
str_LEA		DC.B	'LEA',$00
str_LSR		DC.B	'LSR',$00
str_LSL		DC.B	'LSL',$00
str_MOVE	DC.B	'MOVE',$00
str_MOVEA	DC.B	'MOVEA',$00
str_MOVEM	DC.B	'MOVEM',$00
str_NEG		DC.B	'NEG',$00
str_NOP		DC.B	'NOP',$00
str_NOT		DC.B	'NOT',$00
str_OR		DC.B	'OR',$00
str_ORI		DC.B	'ORI',$00
str_ROL		DC.B	'ROL',$00
str_ROR		DC.B	'ROR',$00
str_RTS		DC.B	'RTS',$00
str_SUB		DC.B	'SUB',$00
str_SUBA	DC.B	'SUBA',$00
str_SUBI	DC.B	'SUBI',$00
str_SWAP	DC.B	'SWAP',$00

	END	$1000		

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
