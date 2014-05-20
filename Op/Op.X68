*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    
stack       EQU     $7000                   *Stack address
buffer      EQU     $5000                   *Buffer address
example     EQU     %1101111001100001       *madeup
nop         EQU     %0100111001110001       *NOP
moveb       EQU     %0001000000000001       *MOVE.B
shift       EQU     12                      *Shift 12 bits
buf         DS.B    80

CR      EQU     $0D                         ASCII code for Carriage Return
LF      EQU     $0A                         ASCII code for Line Feed
MESSAGE DC.B    'D',CR,LF,0                   ASCII string with new line
BYE     DC.B    'Program terminated!',CR,LF,0 


    ORG    $1000
START:                  ; first instruction of program

* Put program code here
* Word Data in D0

    LEA     stack,SP                        *Load the SP
    LEA     buffer,A6                       *Load buffer address
    LEA     jmp_table,A0                    *Index into the table
    CLR.L   D0                              *Zero it
    MOVE.W  #moveb,D0                       *Move byte
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
    
    MULU    #6,D0                           *Form offset
    JSR     0(A0,D0)                        *Jump indirect with index
    BRA     Done
    
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
    
EA_table
    *JMP     code000
    
    
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
    *MOVE.B  #$00,(A1)                  *Terminator
    


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
    
Print    
    MOVE.B  #$00,(A1)                       *Terminator
    LEA     buf,A1
    CLR.L   D0
    MOVE.B  #13,D0
    TRAP    #15
    
    RTS
    *BRA     Done
    
EAmode1
EAmode2
EAmode3
EAmode4
EAmode5
EAmode6
EAmode7


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
code1111    STOP    #$2700
    
Done
    LEA     BYE, A1                         *Load BYE into address register A1
    MOVE.B  #14, D0                         *Moves the number 14 into data register D0
    TRAP    #15                             *Displays Message

    SIMHALT                                 *halt simulator

* Put variables and constants here




    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
