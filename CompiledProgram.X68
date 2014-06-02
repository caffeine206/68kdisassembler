*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Derek Willms, Binh Nguyen, Brian Quigley
* Date       :
* Description:
*-----------------------------------------------------------
    
begin           EQU     $00000000
end             EQU     $00FFFFFE
stack           EQU     $7000               * Stack address
shift           EQU     12                  * Shift 12 bits

current         DC.W    1
                
START:          ORG     $1000

start           LEA     stack,SP            * Load the Stack Pointer
                LEA     greeting,A1         * Assign greeting to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display greeting
                
get_start       LEA     start_prompt,A1     * Assign starting address prompt to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display starting address prompt
                
                LEA     start_input,A1      * Assign start_input as address to store input
                MOVE.B  #2,D0               * Assign input task code to D0
                TRAP    #15                 * Store user input in A1
                
                JSR     ascii_to_hex        * Translate ASCII input to HEX
                JSR     even_check          * Check if given address is odd
                CMP.W   #-1,D3              * Check result of odd check
                BEQ     get_start           * If odd, display an error and ask for new starting address
                
                MOVE.L  #begin,D5           * Assign minimum address bound to D5
                CMP.L   D5,D3               * Compare address to minimum bound
                BLT     bound_error         * Error if address is below minimum
                MOVE.L  #end,D5             * Assign maximum address bound to D5
                CMP.L   D5,D3               * Compare address to maximum bound
                BGT     bound_error         * Error if address is above maximum
                MOVEA.L D3,A6               * Save the lower address into A6
                
get_end         LEA     end_prompt,A1       * Assign ending address prompt to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display ending address prompt
                
                LEA     end_input,A1        * Assign end_input as address to store input
                MOVE.B  #2,D0               * Assign input task code to D0
                TRAP    #15                 * Store user input in A1
                
                JSR     ascii_to_hex        * Translate ASCII input to HEX
                JSR     even_check          * Check if given address is odd
                CMP.W   #-1,D3              * Check result of odd check
                BEQ     get_end             * If odd, display an error and ask for new starting address
                
                CMP.L   A6,D3               * Compare address to lower address
                BLT     bound_error         * Error if address is below lower address
                CMP.L   D5,D3               * Compare address to maximum bound
                BGT     bound_error         * Error if address is above maximum
                MOVE.L  D3,D6               * Save the upper address into D6
                
                CLR.L   D2                  * Clear D2
                CLR.L   D3                  * Clear D3
                CLR.L   D5                  * Clear D5
                

main            CLR.L   D0                  * Clear D0
                CLR.L   D1                  * Clear D1
                MOVE.L  A6,D0               * Get current memory pointer in D0
                MOVE.B  #4,D1               * Size for address is 4 bytes
                MOVE.L  #buffer,A1          * Set A1 to point to the print buffer
                JSR     hex_to_ascii        * Translate hex to ascii
                MOVE.B  #$9,(A1)+           * Add a tab
                
                BRA     op_code             * Begin decode 
                
rerun_check     LEA     rerun_message,A1    * Assign rerun message to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display rerun message
                
                LEA     rerun_input,A1      * Assign rerun input to A1
                MOVE.B  #2,D0               * Assign prompt task code to D0
                TRAP    #15                 * Store user input in A1
                
                CMP.B   #$79,(A1)           * Compare to lowercase y
                BEQ     get_start           * If equal, branch to get starting address again
                
end_program     LEA     end_message,A1      * Assign end message to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display end message
                STOP    #$00002700          * Stop        

*////////////////////////////////////////////////////////////////////////////////////////
*print: 
*////////////////////////////////////////////////////////////////////////////////////////               
print           MOVE.B  #$00,(A1)           * Add terminator              
                CLR.L   D0                  * Clear D0   
                MOVE.B  #13,D0              * Load Trap task number 13 for printing
                LEA     buffer,A1           * Load print buffer into A1 
                TRAP    #15                 * Print the buffer
                
                CMP.L   A6,D6               * Compare current memory pointer with ending address 
                BLE     end_check           * Less than equal zero, reach the end
                BRA     main                * Go to next memory

*////////////////////////////////////////////////////////////////////////////////////////
*op_code: get the data from current memory pointer, advance the memory pointer, separate 
*         the bits, and jump to the corresponding op_code decoding
*D0: Internal 
*D1: Internal
*D2: Store 3 bits for Source REGISTER
*D3: Store 3 bits for Source MODE
*D4: Store 3 bits for Destination MODE
*D5: Store 3 bits for Destination REGISTER
*current: Store the WORD data
*////////////////////////////////////////////////////////////////////////////////////////                
op_code         LEA     jmp_table,A0                    *Index into the table
                CLR.L   D0                              *Zero it
                
                MOVE.W  (A6)+,current                   *Get WORD and advance memory pointer                
                MOVE.W  current,D0                      *Copy WORD to D0            
                MOVE.W  D0,D1                           *Copy Word data to D1
                MOVEM.L D0,-(SP)                        *Copy Word data to the stack
    
                ANDI.W  #%0000000000000111,D1           *Get last 3 bits Source REG
                MOVE.B  D1,D2                           *Store in D2
    
                ROR.W   #3,D0                           *Rotate D0 right 3 bits
                MOVE.W  D0,D1                           *Copy Word to D1
                ANDI.W  #%0000000000000111,D1           *Get last 3 bits Source MODE
                MOVE.B  D1,D3                           *Store in D3
    
                ROR.W   #3,D0                           *Rotate D0 right 3 bits
                MOVE.W  D0,D1                           *Copy Word to D1
                ANDI.W  #%0000000000000111,D1           *Get last 3 bits Dest MODE
                MOVE.B  D1,D4                           *Store in D4
    
                ROR.W   #3,D0                           *Rotate D0 right 3 bits
                MOVE.W  D0,D1                           *Copy Word to D1
                ANDI.W  #%0000000000000111,D1           *Get last 3 bits Dest REG
                MOVE.B  D1,D5                           *Store in D5
    
                MOVEM.L (SP)+,D0                        *Pop Word data from stack to D0
                CLR.L   D1                              *Clear D1

                MOVE.B  #shift,D1                       *Shift 12 bits to the right 
                LSR.W   D1,D0                           *Move the bits
    
                CLR.L   D1                              *Clear D1
                MOVE.B  D0,D1                           *Copy 4 bits to D1
    
                MULU    #6,D0                           *Form offset
                JSR     0(A0,D0)                        *Jump indirect with index

jmp_table
    JMP     code0000                        *Bit manipulation/MOVEP/Immediate
    JMP     code0001                        *Move Byte
    JMP     code0010                        *Move Long
    JMP     code0011                        *Move Word
    JMP     code0100                        *Miscellaneous
    JMP     code0101                        *ADDQ/SUBQ/Scc/DBcc
    JMP     code0110                        *BSR,BRA,Bcc
    JMP     code0111                        *MOVEQ
    JMP     code1000                        *OR/DIV/SBCD
    JMP     code1001                        *SUB/SUBX
    JMP     code1010                        *Unassigned
    JMP     code1011                        *CMP/EOR
    JMP     code1100                        *AND/MUL/ABCD/EXG
    JMP     code1101                        *ADD/ADDA/ADDX
    JMP     code1110                        *Shift/Rotate
    JMP     code1111                        *Special/Reserved
    
code0000    STOP    #$2700

*////////////////////////////////////////////////////////////////////////////////////////
*code0001: MOVE Byte
*////////////////////////////////////////////////////////////////////////////////////////  
code0001
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    
    CLR.L   D0                              *Clear D0
    MOVE.B  #1,D0                           *size is 1 byte
    
       
    JSR     EAMode                          *Jump to EAMode
    
    MOVE.B  #',',(A1)+
    
    CLR.L   D2
    CLR.L   D3
    MOVE.B  D4,D3                           *Get Destination MODE
    MOVE.B  D5,D2                           *Get Source REG
    
    CMP.B   #1,D3                           *An not allowed
    BEQ     data_error

    JSR     EAMode                          *Jump to EAMode
    
    BRA     print

*////////////////////////////////////////////////////////////////////////////////////////
*code0001: MOVE Long
*//////////////////////////////////////////////////////////////////////////////////////// 
code0010    
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    
    JSR     MOVEA_check                     *Check for MOVEA      

    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    
    CLR.L   D0                              *Clear D0
    MOVE.B  #4,D0                           *size is 4 bytes
    
       
    JSR     EAMode                          *Jump to EAMode
    
    MOVE.B  #',',(A1)+
    
    CLR.L   D2
    CLR.L   D3
    MOVE.B  D4,D3                           *Get Destination MODE
    MOVE.B  D5,D2                           *Get Source REG
   
    JSR     EAMode                          *Jump to EAMode
    
    BRA     Print


*////////////////////////////////////////////////////////////////////////////////////////
*code0011: MOVE Word
*//////////////////////////////////////////////////////////////////////////////////////// 
code0011    
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    
    JSR     MOVEA_check                     *Check for MOVEA
    
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #' ',(A1)+
    
    CLR.L   D0                              *Clear D0
    MOVE.B  #2,D0                           *size is 2 bytes
    
       
    JSR     EAMode                          *Jump to EAMode
    
    MOVE.B  #',',(A1)+
    
    CLR.L   D2
    CLR.L   D3
    MOVE.B  D4,D3                           *Get Destination MODE
    MOVE.B  D5,D2                           *Get Source REG
    
    JSR     EAMode                          *Jump to EAMode
    
    BRA     Print


code0100    STOP    #$2700

code0101    STOP    #$2700
code0110    STOP    #$2700
code0111    STOP    #$2700
code1000    STOP    #$2700
code1001    STOP    #$2700
code1010    STOP    #$2700
code1011    STOP    #$2700
code1100    STOP    #$2700
code1101    STOP    #$2700
code1110    STOP    #$2700
code1111    BRA     data_error

*////////////////////////////////////////////////////////////////////////////////////////
*MOVEA_check: check if MOVEA, then add 'A' to print buffer
*D4: hold the Destination MODE for comparison
*//////////////////////////////////////////////////////////////////////////////////////// 
MOVEA_check
    CMP.B   #1,D4                           
    BEQ     is_MOVEA
    RTS

is_MOVEA
    MOVE.B  'A',(A1)+
    RTS


*////////////////////////////////////////////////////////////////////////////////////////
*data_error: current WORD couldn't be decoded, print the WORD data
*//////////////////////////////////////////////////////////////////////////////////////// 
data_error      MOVE.B  #'D',(A1)+
                MOVE.B  #'A',(A1)+
                MOVE.B  #'T',(A1)+
                MOVE.B  #'A',(A1)+
                MOVE.B  #$9,(A1)+           * Add a tab
                
                CLR.L   D0
                MOVE.W  current,D0          * Copy the WORD data to D0
                CLR.L   D1
                MOVE.B  #2,D1               * Byte size is 2
               
                JSR     hex_to_ascii
                BRA     Print        

***************************************************************************************************
***************************************************************************************************
*
* SUBROUTINES
*
***************************************************************************************************
***************************************************************************************************

*////////////////////////////////////////////////////////////////////////////////////////
*EAMode: take in the 6 bits EA and branch to the corresponding EA mode
*D0: byte size for immediate data
*D3: the 3 bits EA MODE
*D4: the 3 bits EA REG
*//////////////////////////////////////////////////////////////////////////////////////// 
EAMode
    CMP.B   #0,D3
    BEQ     EAmode0
    CMP.B   #1,D3
    BEQ     EAmode1
    CMP.B   #2,D3
    BEQ     EAmode2
    CMP.B   #3,D3
    BEQ     EAmode3
    CMP.B   #4,D3
    BEQ     EAmode4
    CMP.B   #5,D3
    BEQ     EAmode5
    CMP.B   #6,D3
    BEQ     EAmode6
    CMP.B   #7,D3
    BEQ     EAmode7    
      
EAmode0
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer

    RTS    
    
EAmode1
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    
    RTS

EAmode2
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    MOVE.B  #')',(A1)+

    RTS

EAmode3
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    MOVE.B  #')',(A1)+
    MOVE.B  #'+',(A1)+

    RTS

EAmode4
    MOVE.B  #'-',(A1)+
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    MOVE.B  #')',(A1)+

    RTS

EAmode5
    MOVE.B  #'I',(A1)+
    MOVE.B  #'N',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'E',(A1)+

    RTS    
 
EAmode6
    MOVE.B  #'I',(A1)+
    MOVE.B  #'N',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'E',(A1)+

    RTS

EAmode7
    CMP.B   #0,D2                           *WORD addressing mode
    BEQ     get_word  
  
    CMP.B   #1,D2                           *LONG WORD addressing mode        
    BEQ     get_long                   
    
    CMP.B   #4,D2                           *IMMEDIATE DATA addressing mode
    BEQ     IMMEDIATE_DATA

get_byte
    MOVE.B  #'$',(A1)+    
    CLR.L   D0                              *Clear D0
    MOVE.W  (A6)+,D0                        *Get next WORD from memory
    CLR.L   D1                              *Clear D1
    MOVE.B  #1,D1                           *Byte size is 1  
    
    JSR     hex_to_ascii
    
    RTS

get_word
    MOVE.B  #'$',(A1)+    
    CLR.L   D0                              *Clear D0
    MOVE.W  (A6)+,D0                        *Get next WORD from memory
    CLR.L   D1                              *Clear D1
    MOVE.B  #2,D1                           *Byte size is 2  
    
    JSR     hex_to_ascii
    
    RTS
    
    
get_long
    MOVE.B  #'$',(A1)+
    CLR.L   D0                              *Clear D0
    MOVE.L  (A6)+,D0                        *Get next LONG WORD from memory
    CLR.L   D1                              *Clear D1
    MOVE.B  #4,D1                           *Byte size is 4
    
    JSR     hex_to_ascii 

    RTS

immediate_data    
    MOVE.B  #'#',(A1)+
    CMP.B   #2,D0                           *Is the size WORD
    BEQ     get_word    
    CMP.B   #4,D0                           *Is the size LONG WORD
    BEQ     get_long
    CMP.B   #1,D0                           *Is the size BYTE
    BEQ     get_byte


*////////////////////////////////////////////////////////////////////////////////////////
*ascii_to_hex: transforms ASCII input into a hexadecimal address, returns error if invalid characters
*D1: ASCII parameter to be converted
*D2: Internal data used for comparison
*D3: Return data
*D6: Internal data used for NULL comparison
*////////////////////////////////////////////////////////////////////////////////////////
ascii_to_hex    MOVEQ   #$0,D6              * Clear D6 for null comparison
                MOVEQ   #$0,D3              * Clear D3 for new data
                CMP.B   D3,D1               * Null check on string
                BEQ     bound_error         * Error if null
                CMPI    #$0,D1              * Character check on string
                BLE     bound_error         * Error if less than 0
                CMPI    #$8,D1              * Character check on string
                BGT     bound_error         * Error if more than 8 characters
                
translate       MOVE.B  (A1)+,D2            * Move next character into D2
                CMP.B   D6,D2               * Null check on character
                BEQ     result              * End of input if null
                CMP.B   #102,D2             * Compare with 102 (highest character code)
                BGT     bound_error         * Error if character is higher than 102
                CMP.B   #96,D2              * Compare with 96 (lowest lowercase hex)
                BGT     bound_error         * Error if character is lowercase
                CMP.B   #70,D2              * Compare with 70 (highest uppercase hex)
                BGT     bound_error         * Error if character is between 70 and 96
                CMP.B   #64,D2              * Compare with 64 (lowest uppercase hex)
                BGT     uppercase           * Branch to uppercase if above 64
                CMP.B   #57,D2              * Compare with 57 (highest decimal number)
                BGT     bound_error         * Error if character is between 57 and 64
                CMP.B   #48,D2              * Compare with 48 (lowest decimal number)
                BLT     bound_error         * Error if character is below 48
                SUBI.B  #48,D2              * Subtract 48 from ASCII value to get hexadecimal value
                BRA     decoded             * Translation complete
                
uppercase       SUBI.B  #55,D2              * Subtract 55 from ASCII value to get hexadecimal value

decoded         ASL.L   #4,D3               * Clear the return location
                ADD.B   D2,D3               * Move the resulting character into the return location
                BRA     translate           * Check next character
                
result          RTS                         * Return
*////////////////////////////////////////////////////////////////////////////////////////
*bound_error: The provided address was out of the valid range, print an error message and ask for
* a new one.
*////////////////////////////////////////////////////////////////////////////////////////
bound_error     LEA     input_error,A1      * Assign input error message into A1
                MOVE.B  #14,D0              * Assign task code for message into D0
                TRAP    #15                 * Display message
                JMP     get_start           * Prompt for starting address again
*////////////////////////////////////////////////////////////////////////////////////////
*even_check: Checks whether an address is even, branches to error message if odd.  (Does not change 
* address if even).
*////////////////////////////////////////////////////////////////////////////////////////
even_check      CLR.L   D2                  * Clear D2 for new address
                MOVE.L  #$00000002,D1       * Assign value 2 into D1
                MOVE.W  D3,D2               * Move address we want to check into D2
                DIVU    D1,D2               * Divide the address by 2
                SWAP    D2                  * Swap D2 to find the remainder
                CMP.B   #$01,D2             * Check if there is a remainder in D2
                BEQ     odd_error           * Branch to error if address is odd
                RTS                         * Return
*////////////////////////////////////////////////////////////////////////////////////////
*odd_error: The provided address was odd, so print an error and return a -1 for the address.
*////////////////////////////////////////////////////////////////////////////////////////
odd_error       LEA     not_even,A1         * Assign odd error message to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display odd error message
                NOT.L   D6                  * Assign D6's value to be -1
                MOVE.L  D6,D3               * Assign the given address to -1
                RTS                         * Return
*////////////////////////////////////////////////////////////////////////////////////////
*hex_to_ascii: Translates a given HEX value to ASCII for printing
*A1: Resulting HEX value
*D0: Value to be converted
*D1: Size - Number of bytes to be converted
*D2: Current character being processed (internal)
*D3: Loop counter
*////////////////////////////////////////////////////////////////////////////////////////
hex_to_ascii    ANDI.L  #$000000FF,D1       * Isolate the size
                CMP.B   #4,D1               * Compare the size to 4
                BGT     hta_error           * Error if the size is > 4
                CMP.B   #0,D1               * Compare the size to 0
                BLE     hta_error           * Error if the size < 0
                MOVEM.L D0/D2-D3,-(A7)      * Push the register data onto the stack
                ROL.L   #1,D1               * Rotate left by 1 to multiply the size by 2
                MOVE.L  D1,D3               * Save the counter into D3
                
hta_loop        MOVE.L  D0,D2               * Copy data at D0 into D2
                ANDI.B  #%00001111,D2       * Select the first ASCII character in D2
                CMP.B   #9,D2               * Compare the character to 9
                BLE     hta_number          * Branch to hex number if <= 9
                ADDI    #55,D2              * If letter, add 55 to make it an ASCII value
                BRA     hta_continue        * Branch to stack operation
                
hta_number      ADDI    #48,D2              * If number, add 48 to make it an ASCII value

hta_continue    MOVE.B  D2,-(A7)            * Add the ASCII value to the stack
                ROR.L   #4,D0               * Rotate right by 4 to get the next character
                SUBI    #1,D1               * Subtract 1 from the counter
                CMP.B   #0,D1               * Compare the counter to 0
                BNE     hta_loop            * Branch to convert the next character if counter is not 0
                
hta_result      MOVE.B  (A7)+,(A1)+         * Retrieve ASCII values from the stack and put them in A1
                SUBI    #1,D3               * Subtract 1 from the counter
                CMP.B   #0,D3               * Compare the counter to 0
                BNE     hta_result          * Branch to retrieve the next character if counter is not 0
                MOVEM.L (A7)+,D0/D2-D3      * Retrieve original data for the register

hta_finish      RTS                         * Return
*////////////////////////////////////////////////////////////////////////////////////////
*odd_error: The provided address was odd, so print an error and return a -1 for the address.
*////////////////////////////////////////////////////////////////////////////////////////
hta_error       LEA     hta_error_msg,A1    * Assign hex to ascii error message into A1
                MOVE.B  #14,D0              * Assign task code for message into D0
                TRAP    #15                 * Display message
                RTS                         * Return
*////////////////////////////////////////////////////////////////////////////////////////
*page_check: Increment the page counter and see if we have filled an entire output page yet.  
* If so, prompt the user to press "enter" to continue.
*////////////////////////////////////////////////////////////////////////////////////////
page_check      LEA     page_counter,A2     * Assign the page counter to A2
                ADD.B   #1,(A2)             * Increment page counter
                CMP.B   #30,(A2)            * Compare A2 to the line per page limit
                BGT     next_page           * Branch to the next page if lines exceed 30
                RTS                         * Return
                
*////////////////////////////////////////////////////////////////////////////////////////
*next_page: Reset the page counter and prompt the user to press "enter" to continue
*////////////////////////////////////////////////////////////////////////////////////////
next_page       LEA     press_enter,A1      * Load the press enter message prompt
                MOVE.B  #0,(A2)             * Reset the page_counter
                MOVE.B  #2,D0               * Assign input task code to D0
                TRAP    #15                 * Display enter message prompt
                
                LEA     enter_prompt,A1     * Save user input into A1
                MOVE.L  #2,D0               * Copy the user input to D0
                TRAP    #15                 * Save the user input
                RTS                         * Return
***************************************************************************************************
***************************************************************************************************
*
* VARIABLES
*
***************************************************************************************************
***************************************************************************************************
CR              EQU     $0D                 * ASCII code for Carriage Return
LF              EQU     $0A                 * ASCII code for Line Feed
greeting        DC.B    'Welcome to EASY68K Disassembler!',CR,LF,0
start_prompt    DC.B    'Enter starting address: ($0 to $00FFFFFE)',CR,LF,0
end_prompt      DC.B    'Enter ending address: (start to $00FFFFE)',CR,LF,0
input_error     DC.B    'There was something wrong with the input',CR,LF,0
not_even        DC.B    'The specified address was odd',CR,LF,0
end_message     DC.B    'All done!  See you later!',CR,LF,0
hta_error_msg   DC.B    'The number of bytes was incorrect',CR,LF,0
press_enter     DC.B    'ENTER to continue',CR,LF,0
rerun_message   DC.B    'Run the program again? (y/n)',CR,LF,0
page_counter    DC.B    0
rerun_input     DS.B    80
enter_prompt    DS.B    80
buffer          DS.B    80
start_input     DS.B    80
end_input       DS.B    80


    END    START        ; last line of source













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
