*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Derek Willms, Binh Nguyen, Brian Quigley
* Date       :
* Description:
*-----------------------------------------------------------
    
begin           EQU     $00000000
end             EQU     $00FFFFFE

START:          ORG     $1000

start           LEA     greeting,A1         * Assign greeting to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display greeting
start_address   LEA     start_prompt,A1     * Assign starting address prompt to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display starting address prompt
                LEA     start_input,A1      * Assign start_input as address to store input
                MOVE.B  #2,D0               * Assign input task code to D0
                TRAP    #15                 * Store user input in A1
                JSR     validate            * Validate ASCII input
                JSR     even_check          * Check if given address is odd
                CMP.W   #-1,D3              * 
                BEQ     start_address       * If odd, display an error and ask for new starting address
                MOVE.L  #begin,D6           * Assign minimum address bound to D6
                CMP.L   D6,D3               * Compare address to minimum bound
                BLT     bound_error         * Error if address is below minimum
                MOVE.L  #end,D6             * Assign maximum address bound to D6
                CMP.L   D6,D3               * Compare address to maximum bound
                BGT     bound_error         * Error if address is above maximum
                MOVEA.L D3,A5               * Save the lower address into A5
end_address     LEA     end_prompt,A1       * Assign ending address prompt to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display ending address prompt
                LEA     end_input,A1        * Assign end_input as address to store input
                MOVE.B  #2,D0               * Assign input task code to D0
                TRAP    #15                 * Store user input in A1
                JSR     validate            * Validate ASCII input
                JSR     even_check          * Check if given address is odd
                CMP.W   #-1,D3              * 
                BEQ     end_address         * If odd, display an error and ask for new starting address
                CMP.L   A5,D3               * Compare address to lower address
                BLT     bound_error         * Error if address is below lower address
                MOVE.L  #end,D6             * Assign maximum address bound to D6
                CMP.L   D6,D3               * Compare address to maximum bound
                BGT     bound_error         * Error if address is above maximum
                MOVE.L  D3,D6               * Save the upper address into D6
                SUB.L   A5,D6               * Calculate length of instructions
                DIVU.W  #2,D6               * Calculate number of instructions
                ANDI.L  #$0000FFFF,D6       * Remove remainder                       

*********************************************************************
*********************************************************************
*
* SUBROUTINES
*
*********************************************************************
*********************************************************************
*////////////////////////////////////////////////////////////////////
*VALIDATE: transforms ASCII input into a hexadecimal address
*////////////////////////////////////////////////////////////////////
validate        MOVEQ   #$0,D5              * Clear D5 for null comparison
                MOVEQ   #$0,D3              * Clear D3 for new data
                CMP.B   D5,D1               * Null check on string
                BEQ     bound_error         * Error if null
                CMPI    #$8,D1              * Character check on string
                BGT     bound_error         * Error if more than 8 characters
translate       MOVE.B  (A1)+,D2            * Move next character into D2
                CMP.B   D5,D2               * Null check on character
                BEQ     result              * End of input if null
                CMP.B   #102,D2             * Compare with 102 (highest character code)
                BGT     bound_error         * Error if character is higher than 102
                CMP.B   #96,D2              * Compare with 96 (lowest lowercase hex)
                BGT     lowercase           * Branch to lowercase if above 96
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
lowercase       SUBI.B  #87,D2              * Subtract 87 from ASCII value to get hexadecimal value
                BRA     decoded             * Translation complete
uppercase       SUBI.B  #55,D2              * Subtract 55 from ASCII value to get hexadecimal value
decoded         ASL.L   #4,D3               * Clear the return location
                ADD.B   D2,D3               * Move the resulting character into the return location
                BRA     translate           * Check next character
result          RTS                         * Return
*////////////////////////////////////////////////////////////////////
*bound_error: The provided address was out of the valid range, print an error message and ask for
* a new one.
*////////////////////////////////////////////////////////////////////
bound_error     LEA     input_error,A1      * Assign input error message into A1
                MOVE.B  #14,D0              * Assign task code for message into D0
                TRAP    #15                 * Display message
                JMP     start_address       * Prompt for starting address again
*////////////////////////////////////////////////////////////////////
*even_check: Checks whether an address is even, returns an error message if odd.
*////////////////////////////////////////////////////////////////////
even_check      CLR.L   D1                  * Clear D1 for new address
                MOVE.L  #$00000002,D2       * Assign value 2 into D2
                MOVE.W  D3,D2               * Move address we want to check into D2
                DIVU    D2,D1               * Divide the address by 2
                SWAP    D1                  * Swap D1 to find the remainder
                CMP.B   #$01,D1             * Check if there is a remainder in D1
                BEQ     odd_error           * Branch to error if address is odd
                RTS                         * Return
                
odd_error       LEA     not_even,A1         * Assign odd error message to A1
                MOVE.B  #14,D0              * Assign prompt task code to D0
                TRAP    #15                 * Display odd error message
                NOT.L   D5                  * Assign D5's value to be -1
                MOVE.L  D5,D3               * Assign the given address to -1
                RTS                         * Return
*********************************************************************
*********************************************************************
*
* VARIABLES
*
*********************************************************************
*********************************************************************
CR              EQU     $0D                 * ASCII code for Carriage Return
LF              EQU     $0A                 * ASCII code for Line Feed
greeting        DC.B    'Welcome to EASY68K Disassembler!',CR,LF,0
start_prompt    DC.B    'Enter starting address: ($0 to $00FFFFFE)',CR,LF,0
end_prompt      DC.B    'Enter ending address: (start to $00FFFFE)',CR,LF,0
input_error     DC.B    'There was something wrong with the input',CR,LF,0
not_even        DC.B    'The specified address was odd',CR,LF,0
start_input     DS.B    80
end_input       DS.B    80


    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
