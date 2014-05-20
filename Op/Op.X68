*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    
stack       EQU     $7000                   *Stack address
example     EQU     %1101111001100001       *madeup
nop         EQU     %0100111001110001       *NOP
moveb       EQU     %0001000000111100       *MOVE.B
shift       EQU     12                      *Shift 12 bits

CR      EQU     $0D                         ASCII code for Carriage Return
LF      EQU     $0A                         ASCII code for Line Feed
MESSAGE DC.B    'D',CR,LF,0                   ASCII string with new line
BYE     DC.B    'Program terminated!',CR,LF,0 


    ORG    $1000
START:                  ; first instruction of program

* Put program code here
* Word Data in D0

    LEA     stack,SP                        *Load the SP
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
    CMPI.B  #%00000000,D4                   *Compare Dest MODE
    BEQ     Addressing_Dn                   *Branch to Dn

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

Addressing_Dn
    LEA     MESSAGE, A1                     *Load MESSAGE into address register A1
    MOVE.B  #14, D0                         *Moves the number 14 into data register D0
    TRAP    #15                             *Displays Message
    
    MOVE.B  #9, D0
    TRAP    #15
    
    RTS
    
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
