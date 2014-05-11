*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    
START:      ORG    $1000

start_address   LEA     prompt_low,A1       * Load starting address prompt
                MOVE.L  #1,D0               * Load task code for prompt
                TRAP    #15                 * Display starting address prompt
                LEA     start_input,A1      * Store user input in A1
                MOVE.L  #2,D0               * Load task code for input
                JSR     validate            * Validate input
                CMP.B   #1,DR               * Check result of validation
                BEQ     validate_hex        * Validate the resulting address
validate_hex    JSR     
                
                       

*********************************************************************
*********************************************************************
*
* VALIDATE: transforms ASCII input into a hexadecimal address
*
*********************************************************************
*********************************************************************
validate        MOVEQ   #$0,D5              * Clear D5 for null comparison
                MOVEQ   #$0,D3              * Clear D3 for new data
                CMP.B   D5,D1               * Null check on string
                BEQ     inputerror          * Error if null
                CMPI    #$8,D1              * Character check on string
                BGT     inputerror          * Error if more than 8 characters
translate       MOVE.B  (A1)+,D2            * Move next character into D2
                CMP.B   D5,D2               * Null check on character
                BEQ     result              * End of input if null
                CMP.B   #102,D2             * Compare with 102 (highest character code)
                BGT     inputerror          * Error if character is higher than 102
                CMP.B   #96,D2              * Compare with 96 (lowest lowercase hex)
                BGT     lowercase           * Branch to lowercase if above 96
                CMP.B   #70,D2              * Compare with 70 (highest uppercase hex)
                BGT     inputerror          * Error if character is between 70 and 96
                CMP.B   #64,D2              * Compare with 64 (lowest uppercase hex)
                BGT     uppercase           * Branch to uppercase if above 64
                CMP.B   #57,D2              * Compare with 57 (highest decimal number)
                BGT     inputerror          * Error if character is between 57 and 64
                CMP.B   #48,D2              * Compare with 48 (lowest decimal number)
                BLT     inputerror          * Error if character is below 48
                SUBI.B  #48,D2              * Subtract 48 from ASCII value to get hexadecimal value
                BRA     decoded             * Translation complete
lowercase       SUBI.B  #87,D2              * Subtract 87 from ASCII value to get hexadecimal value
                BRA     decoded             * Translation complete
uppercase       SUBI.B  #55,D2              * Subtract 55 from ASCII value to get hexadecimal value
decoded         ASL.L   #4,D3               * Clear the return location
                ADD.B   D2,D3               * Move the resulting character into the return location
                BRA     examine             * Check next character
inputerror      MOVEQ   #$0,D4              * Assign bad input code into D4
                RTS                         * Return bad input
result          MOVEQ   #$1,D4              * Assign good input code into D4
                RTS                         * Return good input
*********************************************************************
*********************************************************************
*
* VARIABLES
*
*********************************************************************
*********************************************************************
start_address   DC.B    'Enter starting address: ($0 to $00FFFFFE)'
end_address     DC.B    'Enter ending address: (start to $00FFFFE)'
input_error     DC.B    'There was something wrong with the input'

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
