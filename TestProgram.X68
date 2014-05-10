*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

* Put program code here
*********************************************************************
*********************************************************************
*
*MOVE
*
*********************************************************************
*********************************************************************

*////////////////////////////////////////////////////////////////////
*MOVE.B
*////////////////////////////////////////////////////////////////////

    MOVE.B      D3,D4                   *Move byte data from D3 to D4
    *MOVE.B      D3,A4                   *Move byte data from D3 to A4
    MOVE.B      D3,(A4)                 *Move byte data from D3 to object in A4
    MOVE.B      D3,(A4)+                *Move byte data from D3 to object in A4 and increase pointer by 1
    MOVE.B      D3,-(A4)                *Move byte data from D3 to object in A4 after decrease pointer by 1
    MOVE.B      D3,$1234                *Move byte data from D3 to absolute address WORD
    MOVE.B      D3,$12345678            *Move byte data from D3 to absolute address LONG WORD
    *MOVE.B      D3,#$55                 *Move byte data from D3 to immediate data $55                
    
    *MOVE.B      A3,D4                   *Move byte data from A3 to D4
    *MOVE.B      A3,A4                   *Move byte data from A3 to A4
    *MOVE.B      A3,(A4)                 *Move byte data from A3 to object in A4
    *MOVE.B      A3,(A4)+                *Move byte data from A3 to object in A4 and increase pointer by 1
    *MOVE.B      A3,-(A4)                *Move byte data from A3 to object in A4 after decrease pointer by 1
    *MOVE.B      A3,$1234                *Move byte data from A3 to absolute address WORD
    *MOVE.B      A3,$12345678            *Move byte data from A3 to absolute address LONG WORD
    *MOVE.B      A3,#$55                 *Move byte data from A3 to immediate data $55
    
    MOVE.B      (A3),D4                 *Move byte data from (A3) to D4
    *MOVE.B      (A3),A4                 *Move byte data from (A3) to A4
    MOVE.B      (A3),(A4)               *Move byte data from (A3) to object in A4
    MOVE.B      (A3),(A4)+              *Move byte data from (A3) to object in A4 and increase pointer by 1
    MOVE.B      (A3),-(A4)              *Move byte data from (A3) to object in A4 after decrease pointer by 1
    MOVE.B      (A3),$1234              *Move byte data from (A3) to absolute address WORD
    MOVE.B      (A3),$12345678          *Move byte data from (A3) to absolute address LONG WORD
    *MOVE.B      (A3),#$55               *Move byte data from (A3) to immediate data $55
    
    MOVE.B      (A3)+,D4                *Move byte data from (A3)+ to D4
    *MOVE.B      (A3)+,A4                *Move byte data from (A3)+ to A4
    MOVE.B      (A3)+,(A4)              *Move byte data from (A3)+ to object in A4
    MOVE.B      (A3)+,(A4)+             *Move byte data from (A3)+ to object in A4 and increase pointer by 1
    MOVE.B      (A3)+,-(A4)             *Move byte data from (A3)+ to object in A4 after decrease pointer by 1
    MOVE.B      (A3)+,$1234             *Move byte data from (A3)+ to absolute address WORD
    MOVE.B      (A3)+,$12345678         *Move byte data from (A3)+ to absolute address LONG WORD
    *MOVE.B      (A3)+,#$55              *Move byte data from (A3)+ to immediate data $55
    
    MOVE.B      -(A3),D4                *Move byte data from -(A3) to D4
    *MOVE.B      -(A3),A4                *Move byte data from -(A3) to A4
    MOVE.B      -(A3),(A4)              *Move byte data from -(A3) to object in A4
    MOVE.B      -(A3),(A4)+             *Move byte data from -(A3) to object in A4 and increase pointer by 1
    MOVE.B      -(A3),-(A4)             *Move byte data from -(A3) to object in A4 after decrease pointer by 1
    MOVE.B      -(A3),$1234             *Move byte data from -(A3) to absolute address WORD
    MOVE.B      -(A3),$12345678         *Move byte data from -(A3) to absolute address LONG WORD
    *MOVE.B      -(A3),#$55              *Move byte data from -(A3) to immediate data $55
    
    MOVE.B      $1234,D4                *Move byte data from $1234 to D4
    *MOVE.B      $1234,A4                *Move byte data from $1234 to A4
    MOVE.B      $1234,(A4)              *Move byte data from $1234 to object in A4
    MOVE.B      $1234,(A4)+             *Move byte data from $1234 to object in A4 and increase pointer by 1
    MOVE.B      $1234,-(A4)             *Move byte data from $1234 to object in A4 after decrease pointer by 1
    MOVE.B      $1234,$1234             *Move byte data from $1234 to absolute address WORD
    MOVE.B      $1234,$12345678         *Move byte data from $1234 to absolute address LONG WORD
    *MOVE.B      $1234,#$55              *Move byte data from $1234 to immediate data $55
    
    MOVE.B      $12345678,D4            *Move byte data from $12345678 to D4
    *MOVE.B      $12345678,A4            *Move byte data from $12345678 to A4
    MOVE.B      $12345678,(A4)          *Move byte data from $12345678 to object in A4
    MOVE.B      $12345678,(A4)+         *Move byte data from $12345678 to object in A4 and increase pointer by 1
    MOVE.B      $12345678,-(A4)         *Move byte data from $12345678 to object in A4 after decrease pointer by 1
    MOVE.B      $12345678,$1234         *Move byte data from $12345678 to absolute address WORD
    MOVE.B      $12345678,$12345678     *Move byte data from $12345678 to absolute address LONG WORD
    *MOVE.B      $12345678,#$55          *Move byte data from $12345678 to immediate data $55
    
    MOVE.B      #$55,D4                 *Move byte data from #$55 to D4
    *MOVE.B      #$55,A4                 *Move byte data from #$55 to A4
    MOVE.B      #$55,(A4)               *Move byte data from #$55 to object in A4
    MOVE.B      #$55,(A4)+              *Move byte data from #$55 to object in A4 and increase pointer by 1
    MOVE.B      #$55,-(A4)              *Move byte data from #$55 to object in A4 after decrease pointer by 1
    MOVE.B      #$55,$1234              *Move byte data from #$55 to absolute address WORD
    MOVE.B      #$55,$12345678          *Move byte data from #$55 to absolute address LONG WORD
    *MOVE.B      #$55,#$55               *Move byte data from #$55 to immediate data $55

*////////////////////////////////////////////////////////////////////
*MOVE.W
*////////////////////////////////////////////////////////////////////    

    MOVE.W      D3,D4                   *Move word data from D3 to D4
    *MOVE.W      D3,A4                   *Move word data from D3 to A4
    MOVE.W      D3,(A4)                 *Move word data from D3 to object in A4
    MOVE.W      D3,(A4)+                *Move word data from D3 to object in A4 and increase pointer by 1
    MOVE.W      D3,-(A4)                *Move word data from D3 to object in A4 after decrease pointer by 1
    MOVE.W      D3,$1234                *Move word data from D3 to absolute address WORD
    MOVE.W      D3,$12345678            *Move word data from D3 to absolute address LONG WORD
    *MOVE.W      D3,#$5555               *Move word data from D3 to immediate data $5555 
    
    MOVE.W      A3,D4                   *Move word data from A3 to D4
    *MOVE.W      A3,A4                   *Move word data from A3 to A4
    MOVE.W      A3,(A4)                 *Move word data from A3 to object in A4
    MOVE.W      A3,(A4)+                *Move word data from A3 to object in A4 and increase pointer by 1
    MOVE.W      A3,-(A4)                *Move word data from A3 to object in A4 after decrease pointer by 1
    MOVE.W      A3,$1234                *Move word data from A3 to absolute address WORD
    MOVE.W      A3,$12345678            *Move word data from A3 to absolute address LONG WORD
    *MOVE.W      A3,#$5555               *Move word data from A3 to immediate data $5555
    
    MOVE.W      (A3),D4                 *Move word data from (A3) to D4
    *MOVE.W      (A3),A4                 *Move word data from (A3) to A4
    MOVE.W      (A3),(A4)               *Move word data from (A3) to object in A4
    MOVE.W      (A3),(A4)+              *Move word data from (A3) to object in A4 and increase pointer by 1
    MOVE.W      (A3),-(A4)              *Move word data from (A3) to object in A4 after decrease pointer by 1
    MOVE.W      (A3),$1234              *Move word data from (A3) to absolute address WORD
    MOVE.W      (A3),$12345678          *Move word data from (A3) to absolute address LONG WORD
    *MOVE.W      (A3),#$5555             *Move word data from (A3) to immediate data $5555
    
    MOVE.W      (A3)+,D4                *Move word data from (A3)+ to D4
    *MOVE.W      (A3)+,A4                *Move word data from (A3)+ to A4
    MOVE.W      (A3)+,(A4)              *Move word data from (A3)+ to object in A4
    MOVE.W      (A3)+,(A4)+             *Move word data from (A3)+ to object in A4 and increase pointer by 1
    MOVE.W      (A3)+,-(A4)             *Move word data from (A3)+ to object in A4 after decrease pointer by 1
    MOVE.W      (A3)+,$1234             *Move word data from (A3)+ to absolute address WORD
    MOVE.W      (A3)+,$12345678         *Move word data from (A3)+ to absolute address LONG WORD
    *MOVE.W      (A3)+,#$5555            *Move word data from (A3)+ to immediate data $5555
    
    MOVE.W      -(A3),D4                *Move word data from -(A3) to D4
    *MOVE.W      -(A3),A4                *Move word data from -(A3) to A4
    MOVE.W      -(A3),(A4)              *Move word data from -(A3) to object in A4
    MOVE.W      -(A3),(A4)+             *Move word data from -(A3) to object in A4 and increase pointer by 1
    MOVE.W      -(A3),-(A4)             *Move word data from -(A3) to object in A4 after decrease pointer by 1
    MOVE.W      -(A3),$1234             *Move word data from -(A3) to absolute address WORD
    MOVE.W      -(A3),$12345678         *Move word data from -(A3) to absolute address LONG WORD
    *MOVE.W      -(A3),#$5555            *Move word data from -(A3) to immediate data $5555
    
    MOVE.W      $1234,D4                *Move word data from $1234 to D4
    *MOVE.W      $1234,A4                *Move word data from $1234 to A4
    MOVE.W      $1234,(A4)              *Move word data from $1234 to object in A4
    MOVE.W      $1234,(A4)+             *Move word data from $1234 to object in A4 and increase pointer by 1
    MOVE.W      $1234,-(A4)             *Move word data from $1234 to object in A4 after decrease pointer by 1
    MOVE.W      $1234,$1234             *Move word data from $1234 to absolute address WORD
    MOVE.W      $1234,$12345678         *Move word data from $1234 to absolute address LONG WORD
    *MOVE.W      $1234,#$5555            *Move word data from $1234 to immediate data $5555
    
    MOVE.W      $12345678,D4            *Move word data from $12345678 to D4
    *MOVE.W      $12345678,A4            *Move word data from $12345678 to A4
    MOVE.W      $12345678,(A4)          *Move word data from $12345678 to object in A4
    MOVE.W      $12345678,(A4)+         *Move word data from $12345678 to object in A4 and increase pointer by 1
    MOVE.W      $12345678,-(A4)         *Move word data from $12345678 to object in A4 after decrease pointer by 1
    MOVE.W      $12345678,$1234         *Move word data from $12345678 to absolute address WORD
    MOVE.W      $12345678,$12345678     *Move word data from $12345678 to absolute address LONG WORD
    *MOVE.W      $12345678,#$5555        *Move word data from $12345678 to immediate data $5555
    
    MOVE.W      #$5555,D4               *Move word data from #$5555 to D4
    *MOVE.W      #$5555,A4               *Move word data from #$5555 to A4
    MOVE.W      #$5555,(A4)             *Move word data from #$5555 to object in A4
    MOVE.W      #$5555,(A4)+            *Move word data from #$5555 to object in A4 and increase pointer by 1
    MOVE.W      #$5555,-(A4)            *Move word data from #$5555 to object in A4 after decrease pointer by 1
    MOVE.W      #$5555,$1234            *Move word data from #$5555 to absolute address WORD
    MOVE.W      #$5555,$12345678        *Move word data from #$5555 to absolute address LONG WORD
    *MOVE.W      #$5555,#$5555           *Move word data from #$5555 to immediate data $5555
    
*////////////////////////////////////////////////////////////////////
*MOVE.L
*////////////////////////////////////////////////////////////////////

    MOVE.L      D3,D4                   *Move long word data from D3 to D4
    *MOVE.L      D3,A4                   *Move long word data from D3 to A4
    MOVE.L      D3,(A4)                 *Move long word data from D3 to object in A4
    MOVE.L      D3,(A4)+                *Move long word data from D3 to object in A4 and increase pointer by 1
    MOVE.L      D3,-(A4)                *Move long word data from D3 to object in A4 after decrease pointer by 1
    MOVE.L      D3,$1234                *Move long word data from D3 to absolute address WORD
    MOVE.L      D3,$12345678            *Move long word data from D3 to absolute address LONG WORD
    *MOVE.L      D3,#$55555555           *Move long word data from D3 to immediate data $55555555 
    
    MOVE.L      A3,D4                   *Move long word data from A3 to D4
    *MOVE.L      A3,A4                   *Move long word data from A3 to A4
    MOVE.L      A3,(A4)                 *Move long word data from A3 to object in A4
    MOVE.L      A3,(A4)+                *Move long word data from A3 to object in A4 and increase pointer by 1
    MOVE.L      A3,-(A4)                *Move long word data from A3 to object in A4 after decrease pointer by 1
    MOVE.L      A3,$1234                *Move long word data from A3 to absolute address WORD
    MOVE.L      A3,$12345678            *Move long word data from A3 to absolute address LONG WORD
    *MOVE.L      A3,#$55555555           *Move long word data from A3 to immediate data $55555555
    
    MOVE.L      (A3),D4                 *Move long word data from (A3) to D4
    *MOVE.L      (A3),A4                 *Move long word data from (A3) to A4
    MOVE.L      (A3),(A4)               *Move long word data from (A3) to object in A4
    MOVE.L      (A3),(A4)+              *Move long word data from (A3) to object in A4 and increase pointer by 1
    MOVE.L      (A3),-(A4)              *Move long word data from (A3) to object in A4 after decrease pointer by 1
    MOVE.L      (A3),$1234              *Move long word data from (A3) to absolute address WORD
    MOVE.L      (A3),$12345678          *Move long word data from (A3) to absolute address LONG WORD
    *MOVE.L      (A3),#$55555555         *Move long word data from (A3) to immediate data $55555555
    
    MOVE.L      (A3)+,D4                *Move long word data from (A3)+ to D4
    *MOVE.L      (A3)+,A4                *Move long word data from (A3)+ to A4
    MOVE.L      (A3)+,(A4)              *Move long word data from (A3)+ to object in A4
    MOVE.L      (A3)+,(A4)+             *Move long word data from (A3)+ to object in A4 and increase pointer by 1
    MOVE.L      (A3)+,-(A4)             *Move long word data from (A3)+ to object in A4 after decrease pointer by 1
    MOVE.L      (A3)+,$1234             *Move long word data from (A3)+ to absolute address WORD
    MOVE.L      (A3)+,$12345678         *Move long word data from (A3)+ to absolute address LONG WORD
    *MOVE.L      (A3)+,#$55555555        *Move long word data from (A3)+ to immediate data $55555555
    
    MOVE.L      -(A3),D4                *Move long word data from -(A3) to D4
    *MOVE.L      -(A3),A4                *Move long word data from -(A3) to A4
    MOVE.L      -(A3),(A4)              *Move long word data from -(A3) to object in A4
    MOVE.L      -(A3),(A4)+             *Move long word data from -(A3) to object in A4 and increase pointer by 1
    MOVE.L      -(A3),-(A4)             *Move long word data from -(A3) to object in A4 after decrease pointer by 1
    MOVE.L      -(A3),$1234             *Move long word data from -(A3) to absolute address WORD
    MOVE.L      -(A3),$12345678         *Move long word data from -(A3) to absolute address LONG WORD
    *MOVE.L      -(A3),#$55555555        *Move long word data from -(A3) to immediate data $55555555
    
    MOVE.L      $1234,D4                *Move long word data from $1234 to D4
    *MOVE.L      $1234,A4                *Move long word data from $1234 to A4
    MOVE.L      $1234,(A4)              *Move long word data from $1234 to object in A4
    MOVE.L      $1234,(A4)+             *Move long word data from $1234 to object in A4 and increase pointer by 1
    MOVE.L      $1234,-(A4)             *Move long word data from $1234 to object in A4 after decrease pointer by 1
    MOVE.L      $1234,$1234             *Move long word data from $1234 to absolute address WORD
    MOVE.L      $1234,$12345678         *Move long word data from $1234 to absolute address LONG WORD
    *MOVE.L      $1234,#$55555555        *Move long word data from $1234 to immediate data $55555555
    
    MOVE.L      $12345678,D4            *Move long word data from $12345678 to D4
    *MOVE.L      $12345678,A4            *Move long word data from $12345678 to A4
    MOVE.L      $12345678,(A4)          *Move long word data from $12345678 to object in A4
    MOVE.L      $12345678,(A4)+         *Move long word data from $12345678 to object in A4 and increase pointer by 1
    MOVE.L      $12345678,-(A4)         *Move long word data from $12345678 to object in A4 after decrease pointer by 1
    MOVE.L      $12345678,$1234         *Move long word data from $12345678 to absolute address WORD
    MOVE.L      $12345678,$12345678     *Move long word data from $12345678 to absolute address LONG WORD
    *MOVE.L      $12345678,#$55555555    *Move long word data from $12345678 to immediate data $55555555
    
    MOVE.L      #$55555555,D4           *Move long word data from #$55555555 to D4
    *MOVE.L      #$55555555,A4           *Move long word data from #$55555555 to A4
    MOVE.L      #$55555555,(A4)         *Move long word data from #$55555555 to object in A4
    MOVE.L      #$55555555,(A4)+        *Move long word data from #$55555555 to object in A4 and increase pointer by 1
    MOVE.L      #$55555555,-(A4)        *Move long word data from #$55555555 to object in A4 after decrease pointer by 1
    MOVE.L      #$55555555,$1234        *Move long word data from #$55555555 to absolute address WORD
    MOVE.L      #$55555555,$12345678    *Move long word data from #$55555555 to absolute address LONG WORD
    *MOVE.L      #$55555555,#$55555555   *Move long word data from #$55555555 to immediate data $55555555

    
    
    
    
    *************************************************************************************
    ******MOVEA*************************************************************************
    *********************************************************************************
    **word and long ONLY IN MOVEA -- SIGN EXTENSION -- SEE PG 224 MANUAL FOR MORE INFO
    
    MOVEA.W      D3,A4                   *Move word data from D3 to A4
    MOVEA.W      A3,A4                   *Move word data from D3 to A4
    MOVEA.W      (A4),A4                 *Move word data from D3 to object in A4
    MOVEA.W      (A4)+,A4                *Move word data from D3 to object in A4 and increase pointer by 1
    MOVEA.W      -(A4),A4                *Move word data from D3 to object in A4 after decrease pointer by 1
    MOVEA.W      $1234,A4                *Move word data from D3 to absolute address WORD
    MOVEA.W      $12345678,A4            *Move word data from D3 to absolute address LONG WORD
    MOVEA.W      #$55,A4                 *Move word data from D3 to immediate data $55            
    
    MOVEA.L      D3,A4                   *Move longword data from D3 to A4
    MOVEA.L      A3,A4                   *Move longword data from D3 to A4
    MOVEA.L      (A4),A4                 *Move longword data from D3 to object in A4
    MOVEA.L      (A4)+,A4                *Move longword data from D3 to object in A4 and increase pointer by 1
    MOVEA.L      -(A4),A4                *Move longword data from D3 to object in A4 after decrease pointer by 1
    MOVEA.L      $1234,A4                *Move longword data from D3 to absolute address WORD
    MOVEA.L      $12345678,A4            *Move longword data from D3 to absolute address LONG WORD
    MOVEA.L      #$55,A4                 *Move longword data from D3 to immediate data $55            
       
    
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    
    *************************************************************************************
    ******MOVEM*************************************************************************
    *********************************************************************************
    **word and long ONLY IN MOVEM -- SIGN EXTENSION -- SEE PG 232 MANUAL FOR MORE INFO
    
    MOVEM.W      D3,A4                   *Move word data from D3 to A4
    MOVEM.W      A3,A4                   *Move word data from D3 to A4
    MOVEM.W      (A4),A4                 *Move word data from D3 to object in A4
    MOVEM.W      (A4)+,A4                *Move word data from D3 to object in A4 and increase pointer by 1
    MOVEM.W      -(A4),A4                *Move word data from D3 to object in A4 after decrease pointer by 1
    MOVEM.W      $1234,A4                *Move word data from D3 to absolute address WORD
    MOVEM.W      $12345678,A4            *Move word data from D3 to absolute address LONG WORD
    MOVEM.W      #$55,A4                 *Move word data from D3 to immediate data $55            
    
    MOVEM.L      D3,A4                   *Move longword data from D3 to A4
    MOVEM.L      A3,A4                   *Move longword data from D3 to A4
    MOVEM.L      (A4),A4                 *Move longword data from D3 to object in A4
    MOVEM.L      (A4)+,A4                *Move longword data from D3 to object in A4 and increase pointer by 1
    MOVEM.L      -(A4),A4                *Move longword data from D3 to object in A4 after decrease pointer by 1
    MOVEM.L      $1234,A4                *Move longword data from D3 to absolute address WORD
    MOVEM.L      $12345678,A4            *Move longword data from D3 to absolute address LONG WORD
    MOVEM.L      #$55,A4                 *Move longword data from D3 to immediate data $55            
       

    
    
*/////////////////////////////////////////////////////////////////////////////////////////////////

*ADD  not sure about the logic for this for example how to tell when Dn is invalid
*NOTE 
*The Dn mode is used when the destination is a data register; the
*destination < ea > mode is invalid for a data register. 
*ADDA is used when the destination is an address register. ADDI
*and ADDQ are used when the source is immediate data. Most
*assemblers automatically make this distinction. 
    
    
   
    
    
    
    
    
    
    
    
    


    

    SIMHALT             ; halt simulator
    
* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
