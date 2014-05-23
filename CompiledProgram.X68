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
                
                CLR.L   D2
                CLR.L   D3
                CLR.L   D5
                

main            CLR.L   D0
                CLR.L   D1
                MOVE.L  A6,D0
                MOVE.B  #4,D1
                MOVE.L  #buffer,A1
                JSR     hex_to_ascii
                MOVE.B  #$9,(A1)+
                
                BRA     op_code
                
Print    
    *MOVE.B  #$00,(A1)                       *Add Terminator
    *LEA     buf,A1                          *Load buffer into A1
    *CLR.L   D0                              *Clear D0
    *MOVE.B  #13,D0                          *Trap task 13
    *TRAP    #15                             *Call Trap 15
    
    *RTS
    *BRA     Done                
                
                *CLR.L   D0
                *MOVE.W  (A6)+,D0
                *CLR.L   D1
                *MOVE.B  #2,D1
                
                *JSR     hex_to_ascii
                
                MOVE.B  #$00,(A1)
                CLR.L   D0
                MOVE.B  #13,D0
                LEA     buffer,A1
                TRAP    #15
                
                CMP.L   A6,D6
                BLE     end_check
                BRA     main
                
op_code         LEA     jmp_table,A0                    *Index into the table
                CLR.L   D0                              *Zero it
                
                MOVE.W  (A6)+,current
                
                MOVE.W  current,D0
                
                
                
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
    
    CLR.L   D0                          *Clear D0 for counter of EA loop

EAMode
    *Compare EAmode 0-7 and branch accordingly
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

*EA, EA set up    
EApart2
    MOVE.B  D4,D3                           *Move Dest MODE to D3
    MOVE.B  D5,D2                           *Move Dest REG to D2
    MOVE.B  #',',(A1)+
     
    BRA     EAMode                          *Branch to EAMode      
    
    
    
EAmode0
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA    
    
EAmode1
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA

EAmode2
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    MOVE.B  #')',(A1)+

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA

EAmode3
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    MOVE.B  #')',(A1)+
    MOVE.B  #'+',(A1)+

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA

EAmode4
    MOVE.B  #'-',(A1)+
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer
    MOVE.B  #')',(A1)+

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA

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

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA    
 
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

    ADD     #1,D0                           *Increase EA loop counter
    
    CMP.B   #2,D0                           *EA done twice?
    BEQ     Print                           *Print
    
    BRA     EApart2                         *EA done once, go to second EA 

EAmode7
    CMP.B   #0,D2                           *WORD addressing mode
    BEQ     ABSOLUTE_WORD
    
    CMP.B   #1,D2                           *LONG WORD addressing mode        
    BEQ     ABSOlUTE_LONG                   
    
    CMP.B   #4,D2                           *IMMEDIATE DATA addressing mode
    BEQ     IMMEDIATE_DATA

ABSOLUTE_WORD
    CLR.L   D0                              *Clear D0
    MOVE.W  (A5)+,D0                        *Get next WORD from memory
    CLR.L   D1
    MOVE.B  #2,D1  
    
    JSR     hex_to_ascii
    BRA     print
    
    
ABSOLUTE_LONG
    CLR.L   D0                              *Clear D0
    MOVE.L  (A5)+,D0                        *Get next LONG WORD from memory

    CLR.L   D1
    MOVE.B  #4,D1  
    
    JSR     hex_to_ascii 
    BRA     print

IMMEDIATE_DATA
    ANDI.W  #%0000000000000011,D1           *Get last 2 bits for size
    
    MOVE.B  #'#',(A1)+
    
    CMP.B   #3,D1                           *Is the size WORD
    BEQ     ABSOLUTE_WORD
    
    CMP.B   #2,D1                           *Is the size LONG WORD
    BEQ     ABSOLUTE_LONG

    


code0010    STOP    #$2700
code0011    STOP    #$2700
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


data_error
                CLR.L   D0
                MOVE.W  current,D0
                CLR.L   D1
                MOVE.B  #2,D1
               
                JSR     hex_to_ascii
                BRA     Print


    
end_check       
                
                LEA     end_message,A1      * Assign end message to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display end message
                STOP    #$00002700          * Stop                

***************************************************************************************************
***************************************************************************************************
*
* SUBROUTINES
*
***************************************************************************************************
***************************************************************************************************
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
buffer          DS.B    80
start_input     DS.B    80
end_input       DS.B    80


    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
