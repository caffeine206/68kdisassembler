*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Derek Willms, Binh Nguyen, Brian Quigley
* Date       : 6/01/2014
* Description: Translate machine codes back to instructions
*              based on a user input range of address.
*              Minimum starting address: $00007000
*              Maximum ending address: $00FFFFFE
*-----------------------------------------------------------
                
START:          ORG     $1000

start           
    LEA     stack,SP                        * Load the Stack Pointer
    LEA     greeting,A1                     * Assign greeting to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display greeting
    MOVE.B  #0,line_count                   * Initial line count for display
                
get_start       
    LEA     start_prompt,A1                 * Assign starting address prompt to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display starting address prompt
                
    LEA     start_input,A1                  * Assign start_input as address to store input
    MOVE.B  #2,D0                           * Assign input task code to D0
    TRAP    #15                             * Store user input in A1
                
    JSR     ascii_to_hex                    * Translate ASCII input to HEX
    JSR     even_check                      * Check if given address is odd
    CMP.W   #-1,D3                          * Check result of odd check
    BEQ     get_start                       * If odd, display an error and ask for new starting address
                
    MOVE.L  #begin,D5                       * Assign minimum address bound to D5
    CMP.L   D5,D3                           * Compare address to minimum bound
    BLT     bound_error                     * Error if address is below minimum
    MOVE.L  #end,D5                         * Assign maximum address bound to D5
    CMP.L   D5,D3                           * Compare address to maximum bound
    BGT     bound_error                     * Error if address is above maximum
    MOVEA.L D3,A6                           * Save the lower address into A6
                
get_end         
    LEA     end_prompt,A1                   * Assign ending address prompt to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display ending address prompt
                
    LEA     end_input,A1                    * Assign end_input as address to store input
    MOVE.B  #2,D0                           * Assign input task code to D0
    TRAP    #15                             * Store user input in A1
                
    JSR     ascii_to_hex                    * Translate ASCII input to HEX
    JSR     even_check                      * Check if given address is odd
    CMP.W   #-1,D3                          * Check result of odd check
    BEQ     get_end                         * If odd, display an error and ask for new starting address
                
    CMP.L   A6,D3                           * Compare address to lower address
    BLE     bound_error                     * Error if address is below or equal lower address
    CMP.L   D5,D3                           * Compare address to maximum bound
    BGT     bound_error                     * Error if address is above maximum
    MOVE.L  D3,D6                           * Save the upper address into D6
                
    CLR.L   D2                              * Clear D2
    CLR.L   D3                              * Clear D3
    CLR.L   D5                              * Clear D5                

main            
    CLR.L   D0                              * Clear D0
    CLR.L   D1                              * Clear D1
    MOVE.L  A6,D0                           * Get current memory pointer in D0
    MOVE.B  #4,D1                           * Size for address is 4 bytes
    MOVE.L  #buffer,A1                      * Set A1 to point to the print buffer
    JSR     hex_to_ascii                    * Translate hex to ascii
    MOVE.B  #$9,(A1)+                       * Add a tab
    MOVE.B  #$00,(A1)                       * Add terminator              
    CLR.L   D0                              * Clear D0   
    MOVE.B  #14,D0                          * Load Trap task number 14 for printing
    LEA     buffer,A1                       * Load print buffer into A1 
    TRAP    #15                             * Print the buffer
    MOVE.L  #buffer,A1                      * Set A1 to point to the print buffer
    BRA     op_code                         * Begin decode 
                
Print           
    MOVE.B  #$00,(A1)                       * Add terminator              
    CLR.L   D0                              * Clear D0   
    MOVE.B  #13,D0                          * Load Trap task number 13 for printing
    LEA     buffer,A1                       * Load print buffer into A1 
    TRAP    #15                             * Print the buffer              
    CMP.L   A6,D6                           * Compare current memory pointer with ending address 
    BLE     end_check                       * Less than equal zero, reach the end
    ADD.B   #1,line_count                   * Increase line count by 1
    CMP.B   #max_line,line_count            * Compare to max line
    BEQ     print_break
    
Print_cont
    BRA     main                            * Go to next memory

print_break
    MOVE.B  #0,line_count                   * Reset line count
    LEA     empty_line,A1                   * Assign empty line to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display an empty line  
    LEA     screen_enter,A1                 * String asking user to press enter
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display string
    LEA     discard,A1                      * Assign discard as address to store input
    MOVE.B  #2,D0                           * Assign input task code to D0
    TRAP    #15                             * Store user input in A1
    BRA     Print_cont                      * Go back to next instructions        

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
op_code         
    LEA     jmp_table,A0                    *Index into the table
    CLR.L   D0                              *Zero it
                
    MOVE.W  (A6)+,current                   *Get WORD and advance memory pointer                
    MOVE.W  current,D0                      *Copy WORD to D0            
    MOVE.W  D0,D1                           *Copy Word data to D1
    MOVEM.L D0,-(SP)                        *Copy Word data to the stack
    
    ANDI.W  #$0007,D1                       *Get last 3 bits Source REG
    MOVE.B  D1,D2                           *Store in D2
    
    LSR.W   #3,D0                           *Rotate D0 right 3 bits
    MOVE.W  D0,D1                           *Copy Word to D1
    ANDI.W  #$0007,D1                       *Get last 3 bits Source MODE
    MOVE.B  D1,D3                           *Store in D3
    
    LSR.W   #3,D0                           *Rotate D0 right 3 bits
    MOVE.W  D0,D1                           *Copy Word to D1
    ANDI.W  #$0007,D1                       *Get last 3 bits Dest MODE
    MOVE.B  D1,D4                           *Store in D4
    
    LSR.W   #3,D0                           *Rotate D0 right 3 bits
    MOVE.W  D0,D1                           *Copy Word to D1
    ANDI.W  #$0007,D1                       *Get last 3 bits Dest REG
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

*////////////////////////////////////////////////////////////////////////////////////////
*code0000: Bit manipulation/MOVEP/Immediate
* ORI - CMPI - BCLR
*////////////////////////////////////////////////////////////////////////////////////////    
code0000
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Shift right by 2 bits
    ANDI.B  #$01,D0                         * Get bit 8
    CMP.B   #1,D0                           * Check if 1
    BEQ     BCLR_dynamic_check

    MOVE.W  current,D0                      * Copy the WORD data to D0
    LSR.W   #6,D0                           * Shift right by 6 bits
    ANDI.W  #$3F,D0                         * Get bits 6-11
    CMP.B   #34,D0                          * Check if 34
    BEQ     is_BCLR_static                        

    CMP.B   #0,D5                           * ORI
    BEQ     is_ORI
    
    CMP.B   #6,D5                           * CMPI
    BEQ     is_CMPI
    
    BRA     data_error                      * Other not required instructions
    
BCLR_dynamic_check    
    CMP.B   #6,D4                           * BCLR dynamic
    BEQ     is_BCLR_dynamic
    
    BRA     data_error                      * Other not required instructions    
    
is_ORI
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bit 6-7 for size
    JSR     get_size                        * Get size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment
    CLR.L   D1
    MOVE.B  D0,D1                           * Copy byte size to D1
    JSR     immediate_data                  * Get immediate data
    CLR.L   D0
    MOVE.B  D1,D0                           * Copy byte size back to D0
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * Get destination EA
    BRA     Print       

is_CMPI
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'C',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'P',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bit 6-7 for size
    JSR     get_size                        * Get size
    MOVE.B  #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    CLR.L   D1
    MOVE.B  D0,D1                           * Copy byte size to D1
    JSR     immediate_data                  * Get immediate data
    CLR.L   D0
    MOVE.B  D1,D0                           * Copy byte size back to D0
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * Get destination EA
    BRA     Print    

is_BCLR_dynamic
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #4,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * Get destination EA        
    BRA     Print    

is_BCLR_static
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #4,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    CLR.L   D0
    MOVE.B  #1,D0                           * byte size is 2
    JSR     immediate_data                  * get immediate data
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * Get destination EA        
    BRA     Print      

*////////////////////////////////////////////////////////////////////////////////////////
*code0001: MOVE Byte
*////////////////////////////////////////////////////////////////////////////////////////  
code0001
    CMP.B   #1,D4                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
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
    
    BRA     Print

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
    ADD.B   #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment      
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
    ADD.B   #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
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

*////////////////////////////////////////////////////////////////////////////////////////
*MOVEA_check: check if MOVEA, then add 'A' to print buffer
*D4: hold the Destination MODE for comparison
*//////////////////////////////////////////////////////////////////////////////////////// 
MOVEA_check
    CMP.B   #1,D4                           
    BEQ     is_MOVEA
    RTS

is_MOVEA
    MOVE.B  #'A',(A1)+
    ADD.B   #1,char_count                   * Increase character count
    RTS

*////////////////////////////////////////////////////////////////////////////////////////
*code0100: Miscellaneous
* NOP - NEG - RTS - JSR - MOVEM - LEA
*////////////////////////////////////////////////////////////////////////////////////////
code0100
    MOVE.W  current,D0                      * Copy the WORD data to D0
    CMP.W   #$4E71,D0                       * NOP
    BEQ     is_NOP

    CMP.W   #$4E75,D0                       * RTS
    BEQ     is_RTS

    LSR.W   #8,D0                           * Shift right by 8 bits
    ANDI.W  #$0F,D0                         * Get bits 8-11
    CMP.B   #4,D0                           * Check if 4
    BEQ     is_NEG                          * NEG

    CMP.B   #7,D4                           * LEA
    BEQ     is_LEA

    MOVE.W  current,D0                      * Copy the WORD data to D0
    LSR.W   #6,D0                           * Shift right by 6 bits
    ANDI.W  #$3F,D0                         * Get bits 6-11
    CMP.B   #58,D0                          * JSR
    BEQ     is_JSR                                          

    CMP.B   #34,D0                          * MOVEM reg to mem word
    BEQ     is_MOVEM_word_reg_to_mem

    CMP.B   #35,D0                          * MOVEM reg to mem long
    BEQ     is_MOVEM_long_reg_to_mem

    CMP.B   #50,D0                          * MOVEM mem to reg word
    BEQ     is_MOVEM_word_mem_to_reg

    CMP.B   #51,D0                          * MOVEM mem to reg long
    BEQ     is_MOVEM_long_mem_to_reg     
    
    BRA     data_error                      * Other not required instructions

is_NOP
    MOVE.B  #'N',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'P',(A1)+
    BRA     Print

is_RTS
    MOVE.B  #'R',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #'S',(A1)+
    BRA     Print

is_NEG
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'N',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'G',(A1)+        
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bit 6-7 for size
    JSR     get_size                        * Get size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    JSR     EAMode                          * Get destination EA
    BRA     Print

is_LEA
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'L',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    JSR     EAMode                          * Get EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print         

is_JSR
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'J',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment  
    JSR     EAMode                          * Get EA
    BRA     Print

is_MOVEM_word_reg_to_mem
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+    
    MOVE.B  #7,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    BRA     reg_to_mem 
                       
is_MOVEM_long_reg_to_mem
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+     
    MOVE.B  #7,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    BRA     reg_to_mem

is_MOVEM_word_mem_to_reg
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+     
    MOVE.B  #7,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    BRA     mem_to_reg

is_MOVEM_long_mem_to_reg
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+    
    MOVE.B  #7,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    BRA     mem_to_reg

reg_to_mem
    CMP.B   #4,D3                           * check for predecrement
    BEQ     reg_to_mem_pre
    LEA     MOVEM_post,A2                   * Not predecrement, then postincrement    

reg_to_mem_cont
    CLR.L   D0
    MOVE.W  (A6)+,D0                        * Get WORD and advance memory pointer
    CLR.L   D1
    MOVE.B  #15,D1                          * Counter for 16 bits
    CLR.L   D7
    MOVE.B  #31,D7                          * Counter for getting registers number   
    CLR.L   D4
    MOVE.B  #30,D4                          * Counter for getting registers letter  
    JSR     MOVEM_mask_loop                 * Get the registers
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * Get destination EA
    BRA     Print    

reg_to_mem_pre
    LEA     MOVEM_pre,A2                    * Load predecrement string to A2
    BRA     reg_to_mem_cont    

mem_to_reg
    CLR.L   D5
    MOVE.W  (A6)+,D5                        * Save WORD for registers
    JSR     EAMode                          * Get destination EA    
    MOVE.B  #',',(A1)+
    CMP.B   #4,D3                           * check for predecrement
    BEQ     mem_to_reg_pre
    LEA     MOVEM_post,A2                   * Not predecrement, then postincrement    

mem_to_reg_cont    
    CLR.L   D0
    MOVE.W  D5,D0                           * Get registers WORD
    CLR.L   D1
    MOVE.B  #15,D1                          * Counter for 16 bits
    CLR.L   D7
    MOVE.B  #31,D7                          * Counter for getting registers number   
    CLR.L   D4
    MOVE.B  #30,D4                          * Counter for getting registers letter
    JSR     MOVEM_mask_loop                 * Get the registers
    BRA     Print

mem_to_reg_pre
    LEA     MOVEM_pre,A2                    * Load predecrement string to A2
    BRA     mem_to_reg_cont  

*////////////////////////////////////////////////////////////////////////////////////////
*MOVEM_mask_loop: get the corresponding registers in the operand for MOVEM instruction
*////////////////////////////////////////////////////////////////////////////////////////     
MOVEM_mask_loop
    CLR.L   D5
    MOVE.W  D0,D5                           * Copy D0 to D5
    ANDI.W  #$0001,D5                       * Get the first bit only
    CMP.B   #0,D5
    BNE     MOVEM_get_register              * Bit is not 0    
    SUBI    #2,D7                           * Decrease counter for registers number
    SUBI    #2,D4                           * Decrease counter for registers letter   
   
MOVEM_mask_loop_cont
    LSR.W   #1,D0                           * Shift right by 1 bit
    SUBI    #1,D1                           * Decrease counter    
    CMPI    #0,D1                           * Check counter
    BGE     MOVEM_mask_loop
    MOVE.B  -(A1),D0                        * Get rid of extra '/'
  
    RTS
             
MOVEM_get_register
    MOVE.B  (A2,D4),(A1)+                   * get the register
    SUBI    #2,D4                           * Decrease counter for registers number
    MOVE.B  (A2,D7),(A1)+                   * get the register
    SUBI    #2,D7                           * Decrease counter for registers letter    
    MOVE.B  #'/',(A1)+     
    BRA     MOVEM_mask_loop_cont

*////////////////////////////////////////////////////////////////////////////////////////
*code0101: ADDQ/SUBQ/Scc/DBcc
* SUBQ
*////////////////////////////////////////////////////////////////////////////////////////    
code0101
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    ANDI.B  #$01,D0                         * Mask all bits except first
    BNE     check_SUBQ                      * Not 0, may be SUBQ
    
    BRA     data_error
    
check_SUBQ
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get first 2 bits
    CMPI    #3,D0                           * Not 3, then SUBQ
    BNE     is_SUBQ

    BRA     data_error

is_SUBQ
    MOVE.B  #'S',(A1)+
    MOVE.B  #'U',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #'Q',(A1)+
    JSR     get_size                        * Get size
    MOVE.B  #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment  
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+    
    JSR     SUBQ_data
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * Get EA destination    
    BRA     Print    
    
SUBQ_data
    CMPI    #0,D5                           * Compare data to 0
    BEQ     SUBQ_data_zero

SUBQ_data_cont    
    ADD     #$30,D5                         *Convert hex number to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    RTS   
    
SUBQ_data_zero
    ADDI    #8,D5                           * 0 represents 8
    BRA     SUBQ_data_cont

*////////////////////////////////////////////////////////////////////////////////////////
*code0110: BSR,BRA,Bcc
* BRA - BCS - BVC - BGE - BLT
*////////////////////////////////////////////////////////////////////////////////////////           
code0110
    CLR.L   D0
    MOVE.W  current,D0                      * Copy the WORD data to D0
    LSR.W   #8,D0                           * Shift right 8 bits
    ANDI.W  #$0F,D0                         * Get bits 8-11
    
    CMP.B   #0,D0                           * BRA
    BEQ     is_BRA
    
    CMP.B   #5,D0                           * BCS
    BEQ     is_BCS

    CMP.B   #8,D0                           * BVC
    BEQ     is_BVC    

    CMP.B   #12,D0                          * BGE
    BEQ     is_BGE

    CMP.B   #13,D0                          * BLT
    BEQ     is_BLT
    
    BRA     data_error                      * Other not required instructions
    
is_BRA
    MOVE.B  #'B',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_ascii                    * get the displacement        
    BRA     Print

is_BCS
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment     
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_ascii                    * get the displacement  
    BRA     Print

is_BVC
    MOVE.B  #'B',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment     
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_ascii                    * get the displacement  
    BRA     Print

is_BGE
    MOVE.B  #'B',(A1)+
    MOVE.B  #'G',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment     
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_ascii                    * get the displacement  
    BRA     Print

is_BLT
    MOVE.B  #'B',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #3,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    JSR     displacement_check
    MOVE.B  #'$',(A1)+    
    JSR     hex_to_ascii                    * get the displacement  
    BRA     Print    


*////////////////////////////////////////////////////////////////////////////////////////
*displacement_check: check the 8 bits displacement and return value in D1
*D1: holds 1, 2, 4 for byte, word, long word displacement respectively
*////////////////////////////////////////////////////////////////////////////////////////
displacement_check
    CLR.L   D0
    CLR.L   D1
    MOVE.W  current,D0                      * Copy the WORD data to D0    
    ANDI.W  #$FF,D0                         * Get 8 bits displacement
    
    CMP.B   #$00,D0                         * 16-bits displacement
    BEQ     displacement_word
    
    CMP.B   #$FF,D0                         * 32-bits displacement
    BEQ     displacement_long
    
    BRA     displacement_byte               * no need additional data for displacement  
        
displacement_byte
    MOVE.L  A6,D3                           * Get PC current
    ADD.B   D0,D3                           * Get target address
    CLR.L   D0    
    MOVE.L  D3,D0                           * Copy to D0                              

    CLR.L   D1
    MOVE.B  #4,D1                           * byte size for address is 4
    RTS              
    
displacement_word
    MOVE.L  A6,D3                           * Get PC current
    MOVE.W  (A6)+,D0                        * Get displacement word from memory  
    ADD.W   D0,D3                           * Get target address
    CLR.L   D0
    MOVE.L  D3,D0                           * Copy to D0                              

    CLR.L   D1
    MOVE.B  #4,D1                           * byte size for address is 4  
    RTS
    
displacement_long
    MOVE.L  A6,D3                           * Get PC current
    MOVE.L  (A6)+,D0                        * Get displacement long word from memory
    ADD.L   D0,D3                           * Get target address
    CLR.L   D0    
    MOVE.L  D3,D0                           * Copy to D0                              

    CLR.L   D1
    MOVE.B  #4,D1                           * byte size for address is 4    
    RTS 
        
       
*////////////////////////////////////////////////////////////////////////////////////////
*code0111: MOVEQ
*//////////////////////////////////////////////////////////////////////////////////////// 
code0111
    BRA     data_error                      * Other not required instructions

*////////////////////////////////////////////////////////////////////////////////////////
*code1000: OR/DIV/SBCD
* OR - DIVS
*////////////////////////////////////////////////////////////////////////////////////////     
code1000
    CMP.B   #7,D4                           * DIVS
    BEQ     is_DIVS
    
    CMP.B   #3,D4                           * DIVU
    BEQ     data_error                      * Other not required instructions    
    
    CLR.L   D0
    CLR.L   D1
    MOVE.W  current,D0                      * Copy the WORD data to D0         
    LSR.W   #4,D0                           * Shift right by 4 bits
    ANDI.W  #$1F,D0                         * Get bits 4-8
    CMP.B   #16,D0                          * SBCD
    BEQ     data_error                      * Other not required instructions
    
    BRA     is_OR                           * instruction should be OR    

is_DIVS
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'D',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+    
    MOVE.B  #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment 
    MOVE.B  #2,D0                           * Byte size is 2    
    JSR     EAMode                          * Get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print         

is_OR
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #4,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D4,D1                           * Copy bits 6-8 to D1
    ANDI.B  #$04,D1                         * Get bits 8
    CMP.B   #0,D1                           * if 0
    BEQ     OR_ea_to_Dn

    BRA     OR_Dn_to_ea    
        
OR_ea_to_Dn
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    JSR     EAMode                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print

OR_Dn_to_ea
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error    
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * get source EA
    BRA     Print
    
*////////////////////////////////////////////////////////////////////////////////////////
*code1001: SUB/SUBX
* SUB
*////////////////////////////////////////////////////////////////////////////////////////
code1001
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMP.B   #3,D0                           * SUBA
    BEQ     data_error                      * Other not required instructions

    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$04,D0                         * Get bits 8
    CMP.B   #1,D0                           * May be SUBX
    BEQ     check_SUBX

    BRA     is_SUB     
     
check_SUBX
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #1,D0                           * Shift right 1 bit
    ANDI.B  #3,D0                           * Get bits 4-5
    CMP.B   0,D0                            * SUBX
    BEQ     data_error                      * Other not required instructions

    BRA     is_SUB                          * Instruction should be SUB

is_SUB
    MOVE.B  #'S',(A1)+
    MOVE.B  #'U',(A1)+
    MOVE.B  #'B',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    MOVE.B  D4,D1                           * Copy bits 6-8 to D1
    ANDI.B  #$04,D1                         * Get bits 8
    CMP.B   #0,D1                           * if 0
    BEQ     SUB_ea_to_Dn

    BRA     SUB_Dn_to_ea                              

SUB_ea_to_Dn
    JSR     EAMode                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print

SUB_Dn_to_ea
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * get source EA
    BRA     Print


*////////////////////////////////////////////////////////////////////////////////////////
*code1010: Unassigned
*////////////////////////////////////////////////////////////////////////////////////////
code1010
    BRA     data_error                      * Other not required instructions


*////////////////////////////////////////////////////////////////////////////////////////
*code1011: CMP/EOR
* CMP - EOR
*////////////////////////////////////////////////////////////////////////////////////////
code1011
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMPI.B  #0,D0                           * May be CMP / CMPA
    BEQ     CMPA_check
    
    CMP.B   #1,D3                           * CMPM
    BEQ     data_error                      * Other not required instructions
    
    BRA     is_EOR                          * instruction should be EOR
    
CMPA_check
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMPI.B  #3,D0                           * CMPA
    BEQ     data_error                      * Other not required instructions
    BRA     is_CMP                          * instruction should be CMP

is_CMP
    MOVE.B  #'C',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'P',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment  
    JSR     EAMode                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print    
          
is_EOR
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'E',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * get destination EA
    BRA     Print    


*////////////////////////////////////////////////////////////////////////////////////////
*code1100: AND/MUL/ABCD/EXG
* MULS
*////////////////////////////////////////////////////////////////////////////////////////
code1100
    CMP.B   #7,D4                           * MULS
    BEQ     is_MULS
    
    BRA     data_error                      * Other not required instructions
    
is_MULS
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'U',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+    
    MOVE.B  #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment   
    MOVE.B  #2,D0                           * Byte size is 2
    JSR     EAMode                          * Get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print         


*////////////////////////////////////////////////////////////////////////////////////////
*code1101: ADD/ADDA/ADDX
* ADD - ADDA
*////////////////////////////////////////////////////////////////////////////////////////
code1101
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMPI.B  #3,D0                           * ADDA
    BEQ     is_ADDA
    
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #1,D0                           * May be ADDX
    BEQ     ADDX_check
    BRA     is_ADD                          * Instruction should be ADD
    
ADDX_check
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #1,D0                           * Get bits 4-5
    CMP.B   #0,D0                           * ADDX
    BEQ     data_error                      * Other not required instructions
    BRA     is_ADD                          * Instruction should be ADD
    
is_ADDA
    MOVE.B  #'A',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'A',(A1)+
    CMP.B   #3,D4                           * Word operation
    BEQ     ADDA_Word
    BRA     ADDA_Long                       * Long operation

ADDA_cont   
    MOVE.B  #6,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment  
    JSR     EAMode                          * Get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print    

ADDA_Word
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #2,D0                           * Byte size is 2
    BRA     ADDA_cont

ADDA_Long
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #4,D0                           * Byte size is 4
    BRA     ADDA_cont         

is_ADD    
    MOVE.B  #'A',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'D',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D4,D1                           * Copy bits 6-8 to D1
    ANDI.B  #$04,D1                         * Get bits 8
    CMP.B   #0,D1                           * if 0
    BEQ     ADD_ea_to_Dn

    BRA     ADD_Dn_to_ea                              

ADD_ea_to_Dn
    JSR     EAMode                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print

ADD_Dn_to_ea
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error    
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     EAMode                          * get source EA
    BRA     Print


*////////////////////////////////////////////////////////////////////////////////////////
*code1110: Shift/Rotate
* LSR - LSL - ASR - ASL - ROR - ROL
*////////////////////////////////////////////////////////////////////////////////////////
code1110
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMP.B   #3,D0                           * Memory shift
    BEQ     memory_shift
    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    ANDI.B  #$03,D0                         * Get bits 3-4
    
    CMP.B   #0,D0                           * ASd register
    BEQ     ASd_check_register_shift
    
    CMP.B   #1,D0                           * LSd register
    BEQ     LSd_check_register_shift

    CMP.B   #3,D0                           * ROd register
    BEQ     ROd_check_register_shift 

    BRA     data_error                      * Other not required instructions   

memory_shift
    CMP.B   #0,D5                           * ASd
    BEQ     ASd_check_memory_shift
    
    CMP.B   #1,D5                           * LSd
    BEQ     LSd_check_memory_shift

    CMP.B   #3,D5                           * ROd
    BEQ     ROd_check_memory_shift 

    BRA     data_error                      * Other not required instructions
    
ASd_check_memory_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ASR
    BEQ     ASR_memory_shift
    BRA     ASL_memory_shift

ASR_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error    
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment
    JSR     EAMode                          * Get EA source
    BRA     Print            

ASL_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment
    JSR     EAMode                          * Get EA source
    BRA     Print        

LSd_check_memory_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * LSR
    BEQ     LSR_memory_shift
    BRA     LSL_memory_shift

LSR_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment 
    JSR     EAMode                          * Get EA source
    BRA     Print            

LSL_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment 
    JSR     EAMode                          * Get EA source
    BRA     Print

ROd_check_memory_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ROR
    BEQ     ROR_memory_shift
    BRA     ROL_memory_shift

ROR_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment 
    JSR     EAMode                          * Get EA source
    BRA     Print            

ROL_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    JSR     EAMode                          * Get EA source
    BRA     Print  

ASd_check_register_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ASR
    BEQ     ASR_register_shift
    BRA     ASL_register_shift
    
ASR_register_shift
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ASR_register_shift_register
    BRA     ASR_register_shift_immediate

ASR_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ASR_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

ASL_register_shift
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ASL_register_shift_register
    BRA     ASL_register_shift_immediate

ASL_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ASL_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

LSd_check_register_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * LSR
    BEQ     LSR_register_shift
    BRA     LSL_register_shift
    
LSR_register_shift
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment     
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     LSR_register_shift_register
    BRA     LSR_register_shift_immediate

LSR_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

LSR_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

LSL_register_shift
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     LSL_register_shift_register
    BRA     LSL_register_shift_immediate

LSL_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

LSL_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

ROd_check_register_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ROR
    BEQ     ROR_register_shift
    BRA     ROL_register_shift
    
ROR_register_shift
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ROR_register_shift_register
    BRA     ROR_register_shift_immediate

ROR_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ROR_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

ROL_register_shift
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #5,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ROL_register_shift_register
    BRA     ROL_register_shift_immediate

ROL_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ROL_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    
    
shift_immediate_data
    CMPI    #0,D5                           * Compare data to 0
    BEQ     shift_immediate_zero

shift_immediate_cont    
    ADD     #$30,D5                         *Convert hex number to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    RTS   
    
shift_immediate_zero
    ADDI    #8,D5                           * 0 represents 8
    BRA     shift_immediate_cont


*////////////////////////////////////////////////////////////////////////////////////////
*code1111: Special/Reserved
*////////////////////////////////////////////////////////////////////////////////////////
code1111    
    BRA     data_error


*////////////////////////////////////////////////////////////////////////////////////////
*data_error: current WORD couldn't be decoded, print the WORD data
*//////////////////////////////////////////////////////////////////////////////////////// 
data_error
    MOVE.L  #buffer,A1                      * Set A1 to point to the print buffer
    MOVE.B  #'D',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #4,char_count                   * Increase character counts
    JSR     get_space                       * Get more spaces for alignment                
    CLR.L   D0
    MOVE.W  current,D0                      * Copy the WORD data to D0
    CLR.L   D1
    MOVE.B  #2,D1                           * Byte size is 2               
    JSR     hex_to_ascii
    BRA     Print

*////////////////////////////////////////////////////////////////////////////////////////
*end_check: Ask the user for rerun the program with new decoding address
*////////////////////////////////////////////////////////////////////////////////////////
end_check
    CLR.L   D0                              * Clear all data registers
    CLR.L   D1
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    CLR.L   D5
    CLR.L   D6
    CLR.L   D7
    SUBA.L  A0,A0                           * Clear all address registers
    SUBA.L  A1,A1  
    SUBA.L  A2,A2  
    SUBA.L  A3,A3  
    SUBA.L  A4,A4  
    SUBA.L  A5,A5  
    SUBA.L  A6,A6      
    LEA     empty_line,A1                   * Assign empty line to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display an empty line      
    LEA     reset_message,A1                * Assign reset message to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display reset message    
    MOVE.B  #5,D0                           * Assign input task code to D0
    TRAP    #15                             * Read a single character to D1
    LEA     empty_line,A1                   * Assign empty line to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display an empty line
    LEA     empty_line,A1                   * Assign empty line to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display an empty line      
    CMP.B   #$59,D1                         * is it Y
    BEQ     start
    CMP.B   #$79,D1                         * is it y
    BEQ     start    
          
    LEA     end_message,A1                  * Assign end message to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display end message
    STOP    #$00002700                      * Stop                

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
*D2: the 3 bits EA REG
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
    MOVE.L  #buffer,A1                      * Set A1 to point to the print buffer
    JSR     data_error                      * Invalid EA mode  

    RTS              
 
EAmode6
    MOVE.L  #buffer,A1                      * Set A1 to point to the print buffer
    JSR     data_error                      * Invalid EA mode 

    RTS

EAmode7
    CMP.B   #0,D2                           *WORD addressing mode
    BEQ     get_word  
  
    CMP.B   #1,D2                           *LONG WORD addressing mode        
    BEQ     get_long                   
    
    CMP.B   #4,D2                           *IMMEDIATE DATA addressing mode
    BEQ     immediate_data


*////////////////////////////////////////////////////////////////////////////////////////
*get_byte: get next byte from memory and put in the print buffer
*A6: pointer to current memory
*A1: pointer to the print buffer
*D0: hold the data from memory
*D1: hold the size 
*////////////////////////////////////////////////////////////////////////////////////////
get_byte
    MOVE.B  #'$',(A1)+    
    CLR.L   D0                              *Clear D0
    MOVE.W  (A6)+,D0                        *Get next WORD from memory
    CLR.L   D1                              *Clear D1
    MOVE.B  #1,D1                           *Byte size is 1  
    
    JSR     hex_to_ascii
    
    RTS

*////////////////////////////////////////////////////////////////////////////////////////
*get_word: get next word from memory and put in the print buffer
*A6: pointer to current memory
*A1: pointer to the print buffer
*D0: hold the data from memory
*D1: hold the size 
*////////////////////////////////////////////////////////////////////////////////////////
get_word
    MOVE.B  #'$',(A1)+    
    CLR.L   D0                              *Clear D0
    MOVE.W  (A6)+,D0                        *Get next WORD from memory
    CLR.L   D1                              *Clear D1
    MOVE.B  #2,D1                           *Byte size is 2  
    
    JSR     hex_to_ascii
    
    RTS
    
*////////////////////////////////////////////////////////////////////////////////////////
*get_long: get next long word from memory and put in the print buffer
*A6: pointer to current memory
*A1: pointer to the print buffer
*D0: hold the data from memory
*D1: hold the size 
*////////////////////////////////////////////////////////////////////////////////////////    
get_long
    MOVE.B  #'$',(A1)+
    CLR.L   D0                              *Clear D0
    MOVE.L  (A6)+,D0                        *Get next LONG WORD from memory
    CLR.L   D1                              *Clear D1
    MOVE.B  #4,D1                           *Byte size is 4
    
    JSR     hex_to_ascii 

    RTS

*////////////////////////////////////////////////////////////////////////////////////////
*immediate_data: get the immediate data from memory and put in the print buffer
*A1: pointer to the print buffer
*D0: hold the size
*////////////////////////////////////////////////////////////////////////////////////////
immediate_data    
    MOVE.B  #'#',(A1)+
    CMP.B   #2,D0                           *Is the size WORD
    BEQ     get_word    
    CMP.B   #4,D0                           *Is the size LONG WORD
    BEQ     get_long
    CMP.B   #1,D0                           *Is the size BYTE
    BEQ     get_byte

*////////////////////////////////////////////////////////////////////////////////////////
*get_size: take in 2 bits for size and add the corresponding size to the print buffer
*          also return 1, 2, or 4 for byte, word, or long in D0 respectively
*D0: the 2 bits for size
*A1: pointer to the print buffer
*////////////////////////////////////////////////////////////////////////////////////////
get_size
    CMP.B   #0,D0
    BEQ     byte_size
    CMP.B   #1,D0
    BEQ     word_size
    CMP.B   #2,D0
    BEQ     long_size
    
byte_size
    MOVE.B  #'.',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #1,D0                           * Put 1 in D0 for 1 byte
    RTS

word_size
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #2,D0                           * Put 2 in D0 for 2 bytes
    RTS    
    
long_size
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #4,D0                           * Put 4 in D0 for 1 bytes     
    RTS     

*////////////////////////////////////////////////////////////////////////////////////////
*get_space: use for aligning operands
*A1: pointer to the print buffer
*///////////////////////////////////////////////////////////////////////////////////////
get_space
    CMP.B   #max_char,char_count            * Compare character counts to max_char
    BNE     add_space                       * Add more space if not equal
    MOVE.B  #0,char_count                   * Reset character counts
    RTS    
    
add_space
    MOVE.B  #' ',(A1)+                      * Add a space
    ADD.B   #1,char_count                   * Increase character counts
    BRA     get_space    


*////////////////////////////////////////////////////////////////////////////////////////
*ascii_to_hex: transforms ASCII input into a hexadecimal address, 
*              returns error if invalid characters
*D1: ASCII parameter to be converted
*D2: Internal data used for comparison
*D3: Return data
*D6: Internal data used for NULL comparison
*////////////////////////////////////////////////////////////////////////////////////////
ascii_to_hex    
    MOVEQ   #$0,D6                          * Clear D6 for null comparison
    MOVEQ   #$0,D3                          * Clear D3 for new data
    CMP.B   D3,D1                           * Null check on string
    BEQ     bound_error                     * Error if null
    CMPI    #$0,D1                          * Character check on string
    BLE     bound_error                     * Error if less than 0
    CMPI    #$8,D1                          * Character check on string
    BGT     bound_error                     * Error if more than 8 characters
                
translate       
    MOVE.B  (A1)+,D2                        * Move next character into D2
    CMP.B   D6,D2                           * Null check on character
    BEQ     result                          * End of input if null
    CMP.B   #102,D2                         * Compare with 102 (highest character code)
    BGT     bound_error                     * Error if character is higher than 102
    CMP.B   #96,D2                          * Compare with 96 (lowest lowercase hex)
    BGT     bound_error                     * Error if character is lowercase
    CMP.B   #70,D2                          * Compare with 70 (highest uppercase hex)
    BGT     bound_error                     * Error if character is between 70 and 96
    CMP.B   #64,D2                          * Compare with 64 (lowest uppercase hex)
    BGT     uppercase                       * Branch to uppercase if above 64
    CMP.B   #57,D2                          * Compare with 57 (highest decimal number)
    BGT     bound_error                     * Error if character is between 57 and 64
    CMP.B   #48,D2                          * Compare with 48 (lowest decimal number)
    BLT     bound_error                     * Error if character is below 48
    SUBI.B  #48,D2                          * Subtract 48 from ASCII value to get hexadecimal value
    BRA     decoded                         * Translation complete
                
uppercase       
    SUBI.B  #55,D2                          * Subtract 55 from ASCII value to get hexadecimal value

decoded         
    ASL.L   #4,D3                           * Clear the return location
    ADD.B   D2,D3                           * Move the resulting character into the return location
    BRA     translate                       * Check next character
                
result
    RTS                                     * Return
    
*////////////////////////////////////////////////////////////////////////////////////////
*bound_error: The provided address was out of the valid range, print an error message and ask for
* a new one.
*////////////////////////////////////////////////////////////////////////////////////////
bound_error     
    LEA     input_error,A1                  * Assign input error message into A1
    MOVE.B  #14,D0                          * Assign task code for message into D0
    TRAP    #15                             * Display message
    JMP     get_start                       * Prompt for starting address again
    
*////////////////////////////////////////////////////////////////////////////////////////
*even_check: Checks whether an address is even, branches to error message if odd.  
*            (Does not change address if even).
*////////////////////////////////////////////////////////////////////////////////////////
even_check      
    CLR.L   D2                              * Clear D2 for new address
    MOVE.L  #$00000002,D1                   * Assign value 2 into D1
    MOVE.W  D3,D2                           * Move address we want to check into D2
    DIVU    D1,D2                           * Divide the address by 2
    SWAP    D2                              * Swap D2 to find the remainder
    CMP.B   #$01,D2                         * Check if there is a remainder in D2
    BEQ     odd_error                       * Branch to error if address is odd
    RTS                                     * Return
    
*////////////////////////////////////////////////////////////////////////////////////////
*odd_error: The provided address was odd, so print an error and return a -1 for the address.
*////////////////////////////////////////////////////////////////////////////////////////
odd_error       
    LEA     not_even,A1                     * Assign odd error message to A1
    MOVE.B  #14,D0                          * Assign prompt task code to D0
    TRAP    #15                             * Display odd error message
    NOT.L   D6                              * Assign D6's value to be -1
    MOVE.L  D6,D3                           * Assign the given address to -1
    RTS                                     * Return
    
*////////////////////////////////////////////////////////////////////////////////////////
*hex_to_ascii: Translates a given HEX value to ASCII for printing
*A1: Resulting HEX value
*D0: Value to be converted
*D1: Size - Number of bytes to be converted
*D2: Current character being processed (internal)
*D3: Loop counter
*////////////////////////////////////////////////////////////////////////////////////////
hex_to_ascii    
    ANDI.L  #$000000FF,D1                   * Isolate the size
    CMP.B   #4,D1                           * Compare the size to 4
    BGT     hta_error                       * Error if the size is > 4
    CMP.B   #0,D1                           * Compare the size to 0
    BLE     hta_error                       * Error if the size < 0
    MOVEM.L D0/D2-D3,-(A7)                  * Push the register data onto the stack
    ROL.L   #1,D1                           * Rotate left by 1 to multiply the size by 2
    MOVE.L  D1,D3                           * Save the counter into D3
                
hta_loop        
    MOVE.L  D0,D2                           * Copy data at D0 into D2
    ANDI.B  #%00001111,D2                   * Select the first ASCII character in D2
    CMP.B   #9,D2                           * Compare the character to 9
    BLE     hta_number                      * Branch to hex number if <= 9
    ADDI    #55,D2                          * If letter, add 55 to make it an ASCII value
    BRA     hta_continue                    * Branch to stack operation
                
hta_number      
    ADDI    #48,D2                          * If number, add 48 to make it an ASCII value

hta_continue    
    MOVE.B  D2,-(A7)                        * Add the ASCII value to the stack
    ROR.L   #4,D0                           * Rotate right by 4 to get the next character
    SUBI    #1,D1                           * Subtract 1 from the counter
    CMP.B   #0,D1                           * Compare the counter to 0
    BNE     hta_loop                        * Branch to convert the next character if counter is not 0
                
hta_result      
    MOVE.B  (A7)+,(A1)+                     * Retrieve ASCII values from the stack and put them in A1
    SUBI    #1,D3                           * Subtract 1 from the counter
    CMP.B   #0,D3                           * Compare the counter to 0
    BNE     hta_result                      * Branch to retrieve the next character if counter is not 0
    MOVEM.L (A7)+,D0/D2-D3                  * Retrieve original data for the register

hta_finish      
    RTS                                     * Return
    
*////////////////////////////////////////////////////////////////////////////////////////
*odd_error: The provided address was odd, so print an error and return a -1 for the address.
*////////////////////////////////////////////////////////////////////////////////////////
hta_error       
    LEA     hta_error_msg,A1                * Assign hex to ascii error message into A1
    MOVE.B  #14,D0                          * Assign task code for message into D0
    TRAP    #15                             * Display message
    RTS                                     * Return
    
***************************************************************************************************
***************************************************************************************************
*
* VARIABLES
*
***************************************************************************************************
***************************************************************************************************
begin           EQU     $00007000           * Minimum starting
end             EQU     $00FFFFFE           * Minimum ending
stack           EQU     $7000               * Stack address
shift           EQU     12                  * Shift 12 bits
CR              EQU     $0D                 * ASCII code for Carriage Return
LF              EQU     $0A                 * ASCII code for Line Feed
max_line        EQU     20                  * How many lines to display per screen
max_char        EQU     10                  * How many characters between instruction and operands
current         DC.W    1                   * Store the current WORD
line_count      DC.B    1                   * Store the current screen line count
char_count      DC.B    1                   * Store the instruction characters count    
start_prompt    DC.B    'Enter starting address: ($7000 to $00FFFFFE)',CR,LF,0
end_prompt      DC.B    'Enter ending address: (start to $00FFFFE)',CR,LF,0
input_error     DC.B    'There was something wrong with the input',CR,LF,0
not_even        DC.B    'The specified address was odd',CR,LF,0
reset_message   DC.B    'Do you want to run the program again? (Enter Y or y to run again)',CR,LF,0
screen_enter    DC.B    'Press Enter to continue!',CR,LF,0
empty_line      DC.B    ' ',CR,LF,0
hta_error_msg   DC.B    'The number of bytes was incorrect',CR,LF,0
buffer          DS.B    80
start_input     DS.B    80
end_input       DS.B    80
discard         DS.B    1
MOVEM_post      DC.B	'A7','A6','A5','A4','A3','A2','A1','A0','D7','D6','D5','D4','D3','D2','D1','D0',0
MOVEM_pre       DC.B    'D0','D1','D2','D3','D4','D5','D6','D7','A0','A1','A2','A3','A4','A5','A6','A7',0
greeting        DC.B    'Welcome to EASY68K Disassembler by Team FIREBALL!',CR,LF
                DC.B    ' ',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNNMMMMMM',CR,LF
                DC.B    'MMMMMMMMNhymMMMMMMMMMMMNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNNmmmNNNNMMMMMMM',CR,LF
                DC.B    'MMMMMMMMysohMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNNNNNNNmdhhmNNMNMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMNhdNMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNNNNNNNNNmmmmmmdyyydNNNMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNNNNNNmmmmmmmmddhhhysshdmNNMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMNMMMMMMMMMMMMMMMMMMMNNNNNNNNNmmmmmmmddddhyyyyo+oydmmNNNNMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNmmmmmmddddddhhyyysossyyhdmmNNNNNMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMMMNNNNNNmmmmmmdddddhhhhhyso+ooosyyhdmmmNNNNNMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMNNNNmmdddddddhhhhhyyyysoo+++ooosyhdmmmNNNNMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMNNNNmmmddhhhhhhhyyyssossso+/://oosyhddmmmNNNNMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMNNNmmdddhhyyyyyyyssoo++oo+/:::/++oshhddmmNNNNNMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMNNmmddhhyyyysssssoo+//++ooo+//++osyhhdddmmNNNNMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMNNNNmmdhhyysssssoooo+///:/++o++/+ooosyhdddmmNNNNMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMNNNmmdhhyssoooo++++++/+oo++++///osssyhhddmmNNNNMMMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMNNmmdhyysoooo++++++++ooooo+++/+osyyyhhddmmNNNMNMMMMMMMMMMMMNNNNNMMMMMMMMM',CR,LF
                DC.B    'MMMMMMNNmdhyso+++++o++++ooooysso++o+ossyyhhddmmNNNMMMMMMMMMMMMMMmysyyydNMMMMMMMM',CR,LF
                DC.B    'MMMMMNNmdhso+////ooossssyyysoo++++osssyyhhddmNNNMMMMMMMMMMMMMMMmossosydNMMMMMMMM',CR,LF
                DC.B    'MMMMMNmdys+:-:/oyhdhdhysoos++++++oossyyhhdmmNNMMMMMMMMMMMMMMMNMhoysssydNMMMMMMMM',CR,LF
                DC.B    'MMMMNNmhs+-./yydmmNmmmhhyso++++ooossyyhddmNNMMMMMMMMMNNMMMMMMMMmssyhhdNMMMMMMMMM',CR,LF
                DC.B    'MMMMNNdyo:.:shdmNNmmmmhsoo+++ooossyyhddmNNNMMMMMMMMMMMMMMMMMMMMMmhdmNNMMMMMMMMMM',CR,LF
                DC.B    'MMMMMNdyo/.:+sdmmNmmmdooo++++oosyhhddmNNNMMMMMMMMMMMMMNMMMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMNmhs+-.:oshdmmmh++/+++osyyhddmmNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMNmhyo/-:/oyso/:/++osyyhddmmNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMNNmdhso+///+osyyhhddmmNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMNNNmmddddmmmmNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM',CR,LF
                DC.B    ' ',CR,LF,0                    
end_message     DC.B    'All done!  See you later!',CR,LF
                DC.B    ' ',CR,LF
                DC.B    '                   `-//.```                                                     ',CR,LF         
                DC.B    '                   .ooooooo+.  `                                                ',CR,LF
                DC.B    '                ```/oooooo+/+/--.`                                              ',CR,LF
                DC.B    '               .+ooooo//++:-----.`                                              ',CR,LF
                DC.B    '               /soooo+----------.                                               ',CR,LF
                DC.B    '               .-sooo/:/:--.`.``                                                ',CR,LF
                DC.B    '                 .+++ooo+--.                                                    ',CR,LF
                DC.B    '                    `+soo:---`                                                  ',CR,LF
                DC.B    '                     .:ooo+--                                                   ',CR,LF
                DC.B    '                      `:-:/+-      /::o+:                                       ',CR,LF
                DC.B    '                           `::.`  .dhhho//                                      ',CR,LF
                DC.B    '                `--/         .:.` :ymmNmy//              `--`                   ',CR,LF
                DC.B    '              `-//+.          `..``+mmmmm++/.            :::+                   ',CR,LF
                DC.B    '           `-+++:+:.             ` .dmmmmdsh+/`           -+//.`                ',CR,LF
                DC.B    '          `+:o+o+:/o             `--dmNNNNosoo.            ++o///:              ',CR,LF
                DC.B    '         -:/yhdddh/+:         `/+++sydNNNN+//o`           ://+o+/+-             ',CR,LF
                DC.B    '       `:-+hhhdmddh/o.        `/::+mhssyd+::+/+`         .+:oddddy+:`           ',CR,LF
                DC.B    '     `-/:shhhhhmmhhy/+           smdddho/:/os/o+.        //sddddddhs+-          ',CR,LF
                DC.B    '     -/:+hhhhhhmmhhhso`          /yyyysso+so` -++       -/yddmhdddddho/-`       ',CR,LF
                DC.B    '     /:/hhhhhhhdmdhhd+-           ..:dyso//+    `      -:ohhdmhhhhhdddyo/:`     ',CR,LF
                DC.B    '    `o+hhhhhhhhdddhhd//--.          .soo+://         `::+hhhmmhhhhhhhhddy++     ',CR,LF
                DC.B    '   `+shhhhhhdhhdddhhhs:..::.        .+:/:://       `.///hhhhhmdhhhhhhhhhhhs-    ',CR,LF
                DC.B    '   /shhhhhhhddhhdhhhyhhyo/:::`      `+::::// -:.`.-//:+hhhhhhmmhhhhhhhhhhhdo.   ',CR,LF
                DC.B    '  :ohhhhhhhhddhhmsosso+hhhhs++-.::.`:/:::::+:s//++++oyhhhhhhhmddhyysyhhhhhhy+.  ',CR,LF
                DC.B    '`-+yhhhhhhhdddhhss+/+/:yhhhddho/:/o/++/::::+yoshdddddhhhhhhhhdddysssyhhhhhhd++. ',CR,LF
                DC.B    './/dhhhhhhhddddds+o+::+dhhhhdhhy/+/:+oo++:::+hhhdddhhhhyhhshhhdmysoo//shhhhhh:+.',CR,LF
                DC.B    './shhhhhhhhyo//yhmho/::yhhhho-:++::::::::::::/o:+dhhyhd+oo+hsddhyso/--+hhhhhdo/+',CR,LF
                DC.B    ':/hhhhhys/.`   .sdhhy/::+o++::::::///////::::::::yyh-:hoo+++ohhyoo+:-:yhhhhhhdo+',CR,LF
                DC.B    '+/dhhy+.        `+hhhy+//++++s::+/:----::/+/:::+os/::/+/+o+:-ossoo/--/syyhhhhd+:',CR,LF
                DC.B    'o+dhs.            -oh:.-.`` :+/+-........../+:::s-:+::://:` /++/o+--/oo:`-ohhdo-',CR,LF
                DC.B    '+ohy`             `.::------o/+.............-o/:// -+/:-`  `+/--::--::++`  -ydo.',CR,LF
                DC.B    ':hd-           `.:///::::++soo...............-s::s.`        -/-:+/------    .ho`',CR,LF
                DC.B    ' +y`         `-:-.:+o+oo/--+y-................+/:o//:       `.-o+o--.        oo ',CR,LF
                DC.B    ' `:`        -/:-....:+/...-/y--::----.........o/+:::/+/.`  ``-++y. ``        -. ',CR,LF
                DC.B    '          `+/::::::+/.....::s::::::::::--....-ys/:::::o+/:++so+s:               ',CR,LF
                DC.B    '         /s/:::::o-..---::/os:::::::::::::::sh/:::::::s/::/oso-                 ',CR,LF
                DC.B    '          `+o+/://s.-:::::/ooss/::::::::::::sh+::::::/+ohssss:`                 ',CR,LF
                DC.B    '           `++osssy::/++ossysyooo+::::::/+osso:://++ooos+::-`                   ',CR,LF
                DC.B    '            `////::+o/:/+ossss:::/oo:---.`:oosssysssooo.                        ',CR,LF
                DC.B    '               `.-/yo::::::+oy/--.         /+:/+oooos+``                        ',CR,LF
                DC.B    '                 /-:so//+/++s+             `-o++++s/s/-:-                       ',CR,LF
                DC.B    '                 :--o:::+++-/                `/:/--:::o::                       ',CR,LF
                DC.B    '                   `+-    -.                   -     .:`                        ',CR,LF
                DC.B    ' ',CR,LF,0 

    END    START  













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
