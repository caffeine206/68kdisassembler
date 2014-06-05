*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Derek Willms, Binh Nguyen, Brian Quigley
* Date       :
* Description:
*-----------------------------------------------------------
START:          ORG     $7000

    MOVE.B      D3,D4                   *Move byte data from D3 to D4
    MOVE.B      D3,(A4)                 *Move byte data from D3 to object in A4
    MOVE.B      D3,(A4)+                *Move byte data from D3 to object in A4 and increase pointer by 1
    MOVE.B      D3,-(A4)                *Move byte data from D3 to object in A4 after decrease pointer by 1
    MOVE.B      D3,$1234                *Move byte data from D3 to absolute address WORD
    MOVE.B      D3,$12345678            *Move byte data from D3 to absolute address LONG WORD    
    MOVE.B      (A3),D4                 *Move byte data from (A3) to D4
    MOVE.B      (A3),(A4)               *Move byte data from (A3) to object in A4
    MOVE.B      (A3),(A4)+              *Move byte data from (A3) to object in A4 and increase pointer by 1
    MOVE.B      (A3),-(A4)              *Move byte data from (A3) to object in A4 after decrease pointer by 1
    MOVE.B      (A3),$1234              *Move byte data from (A3) to absolute address WORD
    MOVE.B      (A3),$12345678          *Move byte data from (A3) to absolute address LONG WORD    
    MOVE.B      (A3)+,D4                *Move byte data from (A3)+ to D4
    MOVE.B      (A3)+,(A4)              *Move byte data from (A3)+ to object in A4
    MOVE.B      (A3)+,(A4)+             *Move byte data from (A3)+ to object in A4 and increase pointer by 1
    MOVE.B      (A3)+,-(A4)             *Move byte data from (A3)+ to object in A4 after decrease pointer by 1
    MOVE.B      (A3)+,$1234             *Move byte data from (A3)+ to absolute address WORD
    MOVE.B      (A3)+,$12345678         *Move byte data from (A3)+ to absolute address LONG WORD    
    MOVE.B      -(A3),D4                *Move byte data from -(A3) to D4
    MOVE.B      -(A3),(A4)              *Move byte data from -(A3) to object in A4
    MOVE.B      -(A3),(A4)+             *Move byte data from -(A3) to object in A4 and increase pointer by 1
    MOVE.B      -(A3),-(A4)             *Move byte data from -(A3) to object in A4 after decrease pointer by 1
    MOVE.B      -(A3),$1234             *Move byte data from -(A3) to absolute address WORD
    MOVE.B      -(A3),$12345678         *Move byte data from -(A3) to absolute address LONG WORD    
    MOVE.B      $1234,D4                *Move byte data from $1234 to D4
    MOVE.B      $1234,(A4)              *Move byte data from $1234 to object in A4
    MOVE.B      $1234,(A4)+             *Move byte data from $1234 to object in A4 and increase pointer by 1
    MOVE.B      $1234,-(A4)             *Move byte data from $1234 to object in A4 after decrease pointer by 1
    MOVE.B      $1234,$1234             *Move byte data from $1234 to absolute address WORD
    MOVE.B      $1234,$12345678         *Move byte data from $1234 to absolute address LONG WORD    
    MOVE.B      $12345678,D4            *Move byte data from $12345678 to D4
    MOVE.B      $12345678,(A4)          *Move byte data from $12345678 to object in A4
    MOVE.B      $12345678,(A4)+         *Move byte data from $12345678 to object in A4 and increase pointer by 1
    MOVE.B      $12345678,-(A4)         *Move byte data from $12345678 to object in A4 after decrease pointer by 1
    MOVE.B      $12345678,$1234         *Move byte data from $12345678 to absolute address WORD
    MOVE.B      $12345678,$12345678     *Move byte data from $12345678 to absolute address LONG WORD    
    MOVE.B      #$55,D4                 *Move byte data from #$55 to D4
    MOVE.B      #$55,(A4)               *Move byte data from #$55 to object in A4
    MOVE.B      #$55,(A4)+              *Move byte data from #$55 to object in A4 and increase pointer by 1
    MOVE.B      #$55,-(A4)              *Move byte data from #$55 to object in A4 after decrease pointer by 1
    MOVE.B      #$55,$1234              *Move byte data from #$55 to absolute address WORD
    MOVE.B      #$55,$12345678          *Move byte data from #$55 to absolute address LONG WORD

    MOVE.W      D3,D4                   *Move word data from D3 to D4
    MOVE.W      D3,(A4)                 *Move word data from D3 to object in A4
    MOVE.W      D3,(A4)+                *Move word data from D3 to object in A4 and increase pointer by 1
    MOVE.W      D3,-(A4)                *Move word data from D3 to object in A4 after decrease pointer by 1
    MOVE.W      D3,$1234                *Move word data from D3 to absolute address WORD
    MOVE.W      D3,$12345678            *Move word data from D3 to absolute address LONG WORD    
    MOVE.W      A3,D4                   *Move word data from A3 to D4
    MOVE.W      A3,(A4)                 *Move word data from A3 to object in A4
    MOVE.W      A3,(A4)+                *Move word data from A3 to object in A4 and increase pointer by 1
    MOVE.W      A3,-(A4)                *Move word data from A3 to object in A4 after decrease pointer by 1
    MOVE.W      A3,$1234                *Move word data from A3 to absolute address WORD
    MOVE.W      A3,$12345678            *Move word data from A3 to absolute address LONG WORD    
    MOVE.W      (A3),D4                 *Move word data from (A3) to D4
    MOVE.W      (A3),(A4)               *Move word data from (A3) to object in A4
    MOVE.W      (A3),(A4)+              *Move word data from (A3) to object in A4 and increase pointer by 1
    MOVE.W      (A3),-(A4)              *Move word data from (A3) to object in A4 after decrease pointer by 1
    MOVE.W      (A3),$1234              *Move word data from (A3) to absolute address WORD
    MOVE.W      (A3),$12345678          *Move word data from (A3) to absolute address LONG WORD    
    MOVE.W      (A3)+,D4                *Move word data from (A3)+ to D4
    MOVE.W      (A3)+,(A4)              *Move word data from (A3)+ to object in A4
    MOVE.W      (A3)+,(A4)+             *Move word data from (A3)+ to object in A4 and increase pointer by 1
    MOVE.W      (A3)+,-(A4)             *Move word data from (A3)+ to object in A4 after decrease pointer by 1
    MOVE.W      (A3)+,$1234             *Move word data from (A3)+ to absolute address WORD
    MOVE.W      (A3)+,$12345678         *Move word data from (A3)+ to absolute address LONG WORD    
    MOVE.W      -(A3),D4                *Move word data from -(A3) to D4
    MOVE.W      -(A3),(A4)              *Move word data from -(A3) to object in A4
    MOVE.W      -(A3),(A4)+             *Move word data from -(A3) to object in A4 and increase pointer by 1
    MOVE.W      -(A3),-(A4)             *Move word data from -(A3) to object in A4 after decrease pointer by 1
    MOVE.W      -(A3),$1234             *Move word data from -(A3) to absolute address WORD
    MOVE.W      -(A3),$12345678         *Move word data from -(A3) to absolute address LONG WORD    
    MOVE.W      $1234,D4                *Move word data from $1234 to D4
    MOVE.W      $1234,(A4)              *Move word data from $1234 to object in A4
    MOVE.W      $1234,(A4)+             *Move word data from $1234 to object in A4 and increase pointer by 1
    MOVE.W      $1234,-(A4)             *Move word data from $1234 to object in A4 after decrease pointer by 1
    MOVE.W      $1234,$1234             *Move word data from $1234 to absolute address WORD
    MOVE.W      $1234,$12345678         *Move word data from $1234 to absolute address LONG WORD    
    MOVE.W      $12345678,D4            *Move word data from $12345678 to D4
    MOVE.W      $12345678,(A4)          *Move word data from $12345678 to object in A4
    MOVE.W      $12345678,(A4)+         *Move word data from $12345678 to object in A4 and increase pointer by 1
    MOVE.W      $12345678,-(A4)         *Move word data from $12345678 to object in A4 after decrease pointer by 1
    MOVE.W      $12345678,$1234         *Move word data from $12345678 to absolute address WORD
    MOVE.W      $12345678,$12345678     *Move word data from $12345678 to absolute address LONG WORD    
    MOVE.W      #$5555,D4               *Move word data from #$5555 to D4
    MOVE.W      #$5555,(A4)             *Move word data from #$5555 to object in A4
    MOVE.W      #$5555,(A4)+            *Move word data from #$5555 to object in A4 and increase pointer by 1
    MOVE.W      #$5555,-(A4)            *Move word data from #$5555 to object in A4 after decrease pointer by 1
    MOVE.W      #$5555,$1234            *Move word data from #$5555 to absolute address WORD
    MOVE.W      #$5555,$12345678        *Move word data from #$5555 to absolute address LONG WORD
    
    MOVE.L      D3,D4                   *Move long word data from D3 to D4
    MOVE.L      D3,(A4)                 *Move long word data from D3 to object in A4
    MOVE.L      D3,(A4)+                *Move long word data from D3 to object in A4 and increase pointer by 1
    MOVE.L      D3,-(A4)                *Move long word data from D3 to object in A4 after decrease pointer by 1
    MOVE.L      D3,$1234                *Move long word data from D3 to absolute address WORD
    MOVE.L      D3,$12345678            *Move long word data from D3 to absolute address LONG WORD    
    MOVE.L      A3,D4                   *Move long word data from A3 to D4
    MOVE.L      A3,(A4)                 *Move long word data from A3 to object in A4
    MOVE.L      A3,(A4)+                *Move long word data from A3 to object in A4 and increase pointer by 1
    MOVE.L      A3,-(A4)                *Move long word data from A3 to object in A4 after decrease pointer by 1
    MOVE.L      A3,$1234                *Move long word data from A3 to absolute address WORD
    MOVE.L      A3,$12345678            *Move long word data from A3 to absolute address LONG WORD   
    MOVE.L      (A3),D4                 *Move long word data from (A3) to D4
    MOVE.L      (A3),(A4)               *Move long word data from (A3) to object in A4
    MOVE.L      (A3),(A4)+              *Move long word data from (A3) to object in A4 and increase pointer by 1
    MOVE.L      (A3),-(A4)              *Move long word data from (A3) to object in A4 after decrease pointer by 1
    MOVE.L      (A3),$1234              *Move long word data from (A3) to absolute address WORD
    MOVE.L      (A3),$12345678          *Move long word data from (A3) to absolute address LONG WORD    
    MOVE.L      (A3)+,D4                *Move long word data from (A3)+ to D4
    MOVE.L      (A3)+,(A4)              *Move long word data from (A3)+ to object in A4
    MOVE.L      (A3)+,(A4)+             *Move long word data from (A3)+ to object in A4 and increase pointer by 1
    MOVE.L      (A3)+,-(A4)             *Move long word data from (A3)+ to object in A4 after decrease pointer by 1
    MOVE.L      (A3)+,$1234             *Move long word data from (A3)+ to absolute address WORD
    MOVE.L      (A3)+,$12345678         *Move long word data from (A3)+ to absolute address LONG WORD    
    MOVE.L      -(A3),D4                *Move long word data from -(A3) to D4
    MOVE.L      -(A3),(A4)              *Move long word data from -(A3) to object in A4
    MOVE.L      -(A3),(A4)+             *Move long word data from -(A3) to object in A4 and increase pointer by 1
    MOVE.L      -(A3),-(A4)             *Move long word data from -(A3) to object in A4 after decrease pointer by 1
    MOVE.L      -(A3),$1234             *Move long word data from -(A3) to absolute address WORD
    MOVE.L      -(A3),$12345678         *Move long word data from -(A3) to absolute address LONG WORD    
    MOVE.L      $1234,D4                *Move long word data from $1234 to D4
    MOVE.L      $1234,(A4)              *Move long word data from $1234 to object in A4
    MOVE.L      $1234,(A4)+             *Move long word data from $1234 to object in A4 and increase pointer by 1
    MOVE.L      $1234,-(A4)             *Move long word data from $1234 to object in A4 after decrease pointer by 1
    MOVE.L      $1234,$1234             *Move long word data from $1234 to absolute address WORD
    MOVE.L      $1234,$12345678         *Move long word data from $1234 to absolute address LONG WORD    
    MOVE.L      $12345678,D4            *Move long word data from $12345678 to D4
    MOVE.L      $12345678,(A4)          *Move long word data from $12345678 to object in A4
    MOVE.L      $12345678,(A4)+         *Move long word data from $12345678 to object in A4 and increase pointer by 1
    MOVE.L      $12345678,-(A4)         *Move long word data from $12345678 to object in A4 after decrease pointer by 1
    MOVE.L      $12345678,$1234         *Move long word data from $12345678 to absolute address WORD
    MOVE.L      $12345678,$12345678     *Move long word data from $12345678 to absolute address LONG WORD    
    MOVE.L      #$55555555,D4           *Move long word data from #$55555555 to D4
    MOVE.L      #$55555555,(A4)         *Move long word data from #$55555555 to object in A4
    MOVE.L      #$55555555,(A4)+        *Move long word data from #$55555555 to object in A4 and increase pointer by 1
    MOVE.L      #$55555555,-(A4)        *Move long word data from #$55555555 to object in A4 after decrease pointer by 1
    MOVE.L      #$55555555,$1234        *Move long word data from #$55555555 to absolute address WORD
    MOVE.L      #$55555555,$12345678    *Move long word data from #$55555555 to absolute address LONG WORD

    MOVEA.W      D3,A4                   *Move word data from D3 to A4
    MOVEA.W      A3,A4                   *Move word data from A3 to A4
    MOVEA.W      (A3),A4                 *Move word data from (A3) to A4
    MOVEA.W      (A3)+,A4                *Move word data from (A3)+ to A4
    MOVEA.W      -(A3),A4                *Move word data from -(A3) to A4
    MOVEA.W      $1234,A4                *Move word data from $1234 to A4
    MOVEA.W      $12345678,A4            *Move word data from $12345678 to A4
    MOVEA.W      #$5555,A4               *Move word data from #$5555 to A4

    MOVEA.L      D3,A4                   *Move long word data from D3 to A4
    MOVEA.L      A3,A4                   *Move long word data from A3 to A4
    MOVEA.L      (A3),A4                 *Move long word data from (A3) to A4
    MOVEA.L      (A3)+,A4                *Move long word data from (A3)+ to A4
    MOVEA.L      -(A3),A4                *Move long word data from -(A3) to A4
    MOVEA.L      $1234,A4                *Move long word data from $1234 to A4
    MOVEA.L      $12345678,A4            *Move long word data from $12345678 to A4
    MOVEA.L      #$55555555,A4           *Move long word data from #$55555555 to A4

     MOVEM.W      A3,(A4)                 *Move word data from A3 to object in A4
     MOVEM.W      A3,-(A4)                *Move word data from A3 to object in A4 after decrease pointer by 1
     MOVEM.W      A3,$1234                *Move word data from A3 to absolute address WORD
     MOVEM.W      A3,$12345678            *Move word data from A3 to absolute address LONG WORD    
     MOVEM.W      (A3),D4                 *Move word data from (A3) to D4
     MOVEM.W      (A3),A4                 *Move word data from (A3) to A4

     MOVEM.L      A3,(A4)                 *Move long word data from A3 to object in A4
     MOVEM.L      A3,-(A4)                *Move long word data from A3 to object in A4 after decrease pointer by 1
     MOVEM.L      A3,$1234                *Move long word data from A3 to absolute address WORD
     MOVEM.L      A3,$12345678            *Move long word data from A3 to absolute address LONG WORD
     MOVEM.L      (A3),D4                 *Move long word data from (A3) to D4
     MOVEM.L      (A3),A4                 *Move long word data from (A3) to A4
    
    SUB.B      D3,D4                   *SUB byte data from D3 to D4
    SUB.B      D3,(A4)                 *SUB byte data from D3 to object in A4
    SUB.B      D3,(A4)+                *SUB byte data from D3 to object in A4 and increase pointer by 1
    SUB.B      D3,-(A4)                *SUB byte data from D3 to object in A4 after decrease pointer by 1
    SUB.B      D3,$1234                *SUB byte data from D3 to absolute address WORD
    SUB.B      D3,$12345678            *SUB byte data from D3 to absolute address LONG WORD
    SUB.B      (A3),D4                 *SUB byte data from (A3) to D4
    SUB.B      (A3)+,D4                *SUB byte data from (A3)+ to D4
    SUB.B      -(A3),D4                *SUB byte data from -(A3) to D4
    SUB.B      $1234,D4                *SUB byte data from $1234 to D4
    SUB.B      $12345678,D4            *SUB byte data from $12345678 to D4
    SUB.B      #$55,D4                 *SUB byte data from #$55 to D4

    SUB.W      D3,D4                   *SUB word data from D3 to D4
    SUB.W      D3,A4                   *SUB word data from D3 to A4
    SUB.W      D3,(A4)                 *SUB word data from D3 to object in A4
    SUB.W      D3,(A4)+                *SUB word data from D3 to object in A4 and increase pointer by 1
    SUB.W      D3,-(A4)                *SUB word data from D3 to object in A4 after decrease pointer by 1
    SUB.W      D3,$1234                *SUB word data from D3 to absolute address WORD
    SUB.W      D3,$12345678            *SUB word data from D3 to absolute address LONG WORD   
    SUB.W      A3,D4                   *SUB word data from A3 to D4
    SUB.W      (A3),D4                 *SUB word data from (A3) to D4
    SUB.W      (A3)+,D4                *SUB word data from (A3)+ to D4
    SUB.W      -(A3),D4                *SUB word data from -(A3) to D4
    SUB.W      $1234,D4                *SUB word data from $1234 to D4
    SUB.W      $12345678,D4            *SUB word data from $12345678 to D4
    SUB.W      #$5555,D4               *SUB word data from #$5555 to D4

    SUB.L      D3,D4                   *SUB long word data from D3 to D4
    SUB.L      A3,D4                   *SUB long word data from A3 to D4
    SUB.L      (A3),D4                 *SUB long word data from (A3) to D4
    SUB.L      (A3)+,D4                *SUB long word data from (A3)+ to D4
    SUB.L      -(A3),D4                *SUB long word data from -(A3) to D4
    SUB.L      $1234,D4                *SUB long word data from $1234 to D4
    SUB.L      $12345678,D4            *SUB long word data from $12345678 to D4
    SUB.L      #$55555555,D4           *SUB long word data from #$55555555 to D4

     SUBQ.B      #5,D4                 *SUBQ byte data from #5 to D4
     SUBQ.B      #5,(A4)               *SUBQ byte data from #5 to object in A4
     SUBQ.B      #5,(A4)+              *SUBQ byte data from #5 to object in A4 and increase pointer by 1
     SUBQ.B      #5,-(A4)              *SUBQ byte data from #5 to object in A4 after decrease pointer by 1
     SUBQ.B      #5,$1234              *SUBQ byte data from #5 to absolute address WORD
     SUBQ.B      #5,$12345678          *SUBQ byte data from #5 to absolute address LONG WORD

    SUBQ.W      #5,D4               *SUBQ word data from #5 to D4
    SUBQ.W      #5,A4               *SUBQ word data from #5 to A4
    SUBQ.W      #5,(A4)             *SUBQ word data from #5 to object in A4
    SUBQ.W      #5,(A4)+            *SUBQ word data from #5 to object in A4 and increase pointer by 1
    SUBQ.W      #5,-(A4)            *SUBQ word data from #5 to object in A4 after decrease pointer by 1
    SUBQ.W      #5,$1234            *SUBQ word data from #5 to absolute address WORD
    SUBQ.W      #5,$12345678        *SUBQ word data from #5 to absolute address LONG WORD

    SUBQ.L      #5,D4           *SUBQ long word data from #5 to D4
    SUBQ.L      #5,A4           *SUBQ long word data from #5 to A4
    SUBQ.L      #5,(A4)         *SUBQ long word data from #5 to object in A4
    SUBQ.L      #5,(A4)+        *SUBQ long word data from #5 to object in A4 and increase pointer by 1
    SUBQ.L      #5,-(A4)        *SUBQ long word data from #5 to object in A4 after decrease pointer by 1
    SUBQ.L      #5,$1234        *SUBQ long word data from #5 to absolute address WORD
    SUBQ.L      #5,$12345678    *SUBQ long word data from #5 to absolute address LONG WORD

     MULS.W      D3,D4                   *Move word data from D3 to D4
     MULS.W      (A3),D4                 *Move word data from (A3) to D4
     MULS.W      (A3)+,D4                *Move word data from (A3)+ to D4
     MULS.W      -(A3),D4                *Move word data from -(A3) to D4
     MULS.W      $1234,D4                *Move word data from $1234 to D4
     MULS.W      $12345678,D4            *Move word data from $12345678 to D4
     MULS.W      #$5555,D4               *Move word data from #$5555 to D4
    
     DIVS.W      D3,D4                   *Move word data from D3 to D4
     DIVS.W      (A3),D4                 *Move word data from (A3) to D4
     DIVS.W      (A3)+,D4                *Move word data from (A3)+ to D4
     DIVS.W      -(A3),D4                *Move word data from -(A3) to D4
     DIVS.W      $1234,D4                *Move word data from $1234 to D4
     DIVS.W      $12345678,D4            *Move word data from $12345678 to D4
     DIVS.W      #$5555,D4               *Move word data from #$5555 to D4

     LEA.L      (A3),A4                 *Move long word data from (A3) to A4
     LEA.L      $1234,A4                *Move long word data from $1234 to A4
     LEA.L      $12345678,A4            *Move long word data from $12345678 to A4

    OR.B      D3,D4                   *OR byte data from D3 to D4
    OR.B      D3,(A4)                 *OR byte data from D3 to object in A4
    OR.B      D3,(A4)+                *OR byte data from D3 to object in A4 and increase pointer by 1
    OR.B      D3,-(A4)                *OR byte data from D3 to object in A4 after decrease pointer by 1
    OR.B      D3,$1234                *OR byte data from D3 to absolute address WORD
    OR.B      D3,$12345678            *OR byte data from D3 to absolute address LONG WORD   
    OR.B      (A3),D4                 *OR byte data from (A3) to D4
    OR.B      (A3)+,D4                *OR byte data from (A3)+ to D4
    OR.B      -(A3),D4                *OR byte data from -(A3) to D4
    OR.B      $1234,D4                *OR byte data from $1234 to D4
    OR.B      $12345678,D4            *OR byte data from $12345678 to D4
    OR.B      #$55,D4                 *OR byte data from #$55 to D4

    OR.W      D3,D4                   *OR word data from D3 to D4
    OR.W      D3,(A4)                 *OR word data from D3 to object in A4
    OR.W      D3,(A4)+                *OR word data from D3 to object in A4 and increase pointer by 1
    OR.W      D3,-(A4)                *OR word data from D3 to object in A4 after decrease pointer by 1
    OR.W      D3,$1234                *OR word data from D3 to absolute address WORD
    OR.W      D3,$12345678            *OR word data from D3 to absolute address LONG WORD
    OR.W      (A3),D4                 *OR word data from (A3) to D4
    OR.W      (A3)+,D4                *OR word data from (A3)+ to D4
    OR.W      -(A3),D4                *OR word data from -(A3) to D4
    OR.W      $1234,D4                *OR word data from $1234 to D4
    OR.W      $12345678,D4            *OR word data from $12345678 to D4
    OR.W      #$5555,D4               *OR word data from #$5555 to D4

    OR.L      D3,D4                   *OR long word data from D3 to D4
    OR.L      D3,4                   *OR long word data from D3 to A4
    OR.L      D3,(A4)                 *OR long word data from D3 to object in A4
    OR.L      D3,(A4)+                *OR long word data from D3 to object in A4 and increase pointer by 1
    OR.L      D3,-(A4)                *OR long word data from D3 to object in A4 after decrease pointer by 1
    OR.L      D3,$1234                *OR long word data from D3 to absolute address WORD
    OR.L      D3,$12345678            *OR long word data from D3 to absolute address LONG WORD
    OR.L      (A3),D4                 *OR long word data from (A3) to D4
    OR.L      (A3)+,D4                *OR long word data from (A3)+ to D4
    OR.L      -(A3),D4                *OR long word data from -(A3) to D4
    OR.L      $1234,D4                *OR long word data from $1234 to D4
    OR.L      $12345678,D4            *OR long word data from $12345678 to D4
    OR.L      #$55555555,D4           *OR long word data from #$55555555 to D4
 
    ORI.B      #$55,D4                 *ORI byte data from #$55 to D4
    ORI.B      #$55,(A4)               *ORI byte data from #$55 to object in A4
    ORI.B      #$55,(A4)+              *ORI byte data from #$55 to object in A4 and increase pointer by 1
    ORI.B      #$55,-(A4)              *ORI byte data from #$55 to object in A4 after decrease pointer by 1
    ORI.B      #$55,$1234              *ORI byte data from #$55 to absolute address WORID
    ORI.B      #$55,$12345678          *ORI byte data from #$55 to absolute address LONG WORID

    ORI.W      #$5555,D4               *ORI wORId data from #$5555 to D4
    ORI.W      #$5555,(A4)             *ORI wORId data from #$5555 to object in A4
    ORI.W      #$5555,(A4)+            *ORI wORId data from #$5555 to object in A4 and increase pointer by 1
    ORI.W      #$5555,-(A4)            *ORI wORId data from #$5555 to object in A4 after decrease pointer by 1
    ORI.W      #$5555,$1234            *ORI wORId data from #$5555 to absolute address WORID
    ORI.W      #$5555,$12345678        *ORI wORId data from #$5555 to absolute address LONG WORID

    ORI.L      #$55555555,D4           *ORI long wORId data from #$55555555 to D4
    ORI.L      #$55555555,(A4)         *ORI long wORId data from #$55555555 to object in A4
    ORI.L      #$55555555,(A4)+        *ORI long wORId data from #$55555555 to object in A4 and increase pointer by 1
    ORI.L      #$55555555,-(A4)        *ORI long wORId data from #$55555555 to object in A4 after decrease pointer by 1
    ORI.L      #$55555555,$1234        *ORI long wORId data from #$55555555 to absolute address WORID
    ORI.L      #$55555555,$12345678    *ORI long wORId data from #$55555555 to absolute address LONG WORID

    OR.B      D3,D4                   *OR byte data from D3 to D4
    OR.B      D3,(A4)                 *OR byte data from D3 to object in A4
    OR.B      D3,(A4)+                *OR byte data from D3 to object in A4 and increase pointer by 1
    OR.B      D3,-(A4)                *OR byte data from D3 to object in A4 after decrease pointer by 1
    OR.B      D3,$1234                *OR byte data from D3 to absolute address WORD
    OR.B      D3,$12345678            *OR byte data from D3 to absolute address LONG WORD
    OR.B      (A3),D4                 *OR byte data from (A3) to D4
    OR.B      (A3)+,D4                *OR byte data from (A3)+ to D4
    OR.B      -(A3),D4                *OR byte data from -(A3) to D4
    OR.B      $1234,D4                *OR byte data from $1234 to D4
    OR.B      $12345678,D4            *OR byte data from $12345678 to D4
    OR.B      #$55,D4                 *OR byte data from #$55 to D4

    OR.W      D3,D4                   *OR word data from D3 to D4
    OR.W      D3,(A4)                 *OR word data from D3 to object in A4
    OR.W      D3,(A4)+                *OR word data from D3 to object in A4 and increase pointer by 1
    OR.W      D3,-(A4)                *OR word data from D3 to object in A4 after decrease pointer by 1
    OR.W      D3,$1234                *OR word data from D3 to absolute address WORD
    OR.W      D3,$12345678            *OR word data from D3 to absolute address LONG WORD
    OR.W      (A3),D4                 *OR word data from (A3) to D4
    OR.W      (A3)+,D4                *OR word data from (A3)+ to D4
    OR.W      -(A3),D4                *OR word data from -(A3) to D4
    OR.W      $1234,D4                *OR word data from $1234 to D4
    OR.W      $12345678,D4            *OR word data from $12345678 to D4 
    OR.W      #$5555,D4               *OR word data from #$5555 to D4

    OR.L      D3,D4                   *OR long word data from D3 to D4
    OR.L      D3,4                   *OR long word data from D3 to A4
    OR.L      D3,(A4)                 *OR long word data from D3 to object in A4
    OR.L      D3,(A4)+                *OR long word data from D3 to object in A4 and increase pointer by 1
    OR.L      D3,-(A4)                *OR long word data from D3 to object in A4 after decrease pointer by 1
    OR.L      D3,$1234                *OR long word data from D3 to absolute address WORD
    OR.L      D3,$12345678            *OR long word data from D3 to absolute address LONG WORD
    OR.L      (A3),D4                 *OR long word data from (A3) to D4
    OR.L      (A3)+,D4                *OR long word data from (A3)+ to D4
    OR.L      -(A3),D4                *OR long word data from -(A3) to D4
    OR.L      $1234,D4                *OR long word data from $1234 to D4
    OR.L      $12345678,D4            *OR long word data from $12345678 to D4
    OR.L      #$55555555,D4           *OR long word data from #$55555555 to D4

    NEG.B      D3                      *NEG byte data from D3            
    NEG.B      (A3)                    *NEG immediate address A3
    NEG.B      (A3)+                   *NEG immediate post increment A3
    NEG.B      -(A3)                   *NEG immediate post decrement A3
    NEG.B      $1234                   *NEG word address 1234
    NEG.B      $12345678               *NEG long word address 12345678

    NEG.W      D3                      *NEG byte data from D3            
    NEG.W      (A3)                    *NEG immediate address A3
    NEG.W      (A3)+                   *NEG immediate post increment A3
    NEG.W      -(A3)                   *NEG immediate post decrement A3
    NEG.W      $1234                   *NEG word address 1234
    NEG.W      $12345678               *NEG long word address 12345678
 
    NEG.L      D3                      *NEG byte data from D3            
    NEG.L      (A3)                    *NEG immediate address A3
    NEG.L      (A3)+                   *NEG immediate post increment A3
    NEG.L      -(A3)                   *NEG immediate post decrement A3
    NEG.L      $1234                   *NEG word address 1234
    NEG.L      $12345678               *NEG long word address 12345678

    EOR.B      D3,D4                   *EOR byte data from D3 to D4
    EOR.B      D3,(A4)                 *EOR byte data from D3 to object in A4
    EOR.B      D3,(A4)+                *EOR byte data from D3 to object in A4 and increase pointer by 1
    EOR.B      D3,-(A4)                *EOR byte data from D3 to object in A4 after decrease pointer by 1
    EOR.B      D3,$1234                *EOR byte data from D3 to absolute address WEORD
    EOR.B      D3,$12345678            *EOR byte data from D3 to absolute address LONG WEORD

    EOR.W      D3,D4                   *EOR wEORd data from D3 to D4
    EOR.W      D3,(A4)                 *EOR wEORd data from D3 to object in A4
    EOR.W      D3,(A4)+                *EOR wEORd data from D3 to object in A4 and increase pointer by 1
    EOR.W      D3,-(A4)                *EOR wEORd data from D3 to object in A4 after decrease pointer by 1
    EOR.W      D3,$1234                *EOR wEORd data from D3 to absolute address WEORD
    EOR.W      D3,$12345678            *EOR wEORd data from D3 to absolute address LONG WEORD

    EOR.L      D3,D4                   *EOR long worddata from D3 to D4
    EOR.L      D3,(A4)                 *EOR long word data from D3 to object in A4
    EOR.L      D3,(A4)+                *EOR long word data from D3 to object in A4 and increase pointer by 1
    EOR.L      D3,-(A4)                *EOR long word data from D3 to object in A4 after decrease pointer by 1
    EOR.L      D3,$1234                *EOR long word data from D3 to absolute address word
    EOR.L      D3,$12345678            *EOR long word data from D3 to absolute address LONG word

    LSR.B       #1,D0
    LSR.B       D1,D0
    
    LSR.W       #1,D0
    LSR.W       D1,D0
    LSR.W       (A1)
    LSR.W       (A1)+
    LSR.W       -(A1)
    LSR.W       $1234
    LSR.W       $55555555
    
    LSR.L       #1,D0
    LSR.L       D1,D0
 
    LSL.B       #1,D0
    LSL.B       D1,D0
    
    LSL.W       #1,D0
    LSL.W       D1,D0
    LSL.W       (A1)
    LSL.W       (A1)+
    LSL.W       -(A1)
    LSL.W       $1234
    LSL.W       $55555555
    
    LSL.L       #1,D0
    LSL.L       D1,D0

    ASR.B       #1,D0
    ASR.B       D1,D0
    
    ASR.W       #1,D0
    ASR.W       D1,D0
    ASR.W       (A1)
    ASR.W       (A1)+
    ASR.W       -(A1)
    ASR.W       $1234
    ASR.W       $55555555
    
    ASR.L       #1,D0
    ASR.L       D1,D0
 
    ASL.B       #1,D0
    ASL.B       D1,D0
    
    ASL.W       #1,D0
    ASL.W       D1,D0
    ASL.W       (A1)
    ASL.W       (A1)+
    ASL.W       -(A1)
    ASL.W       $1234
    ASL.W       $55555555
    
    ASL.L       #1,D0
    ASL.L       D1,D0
 
    ROR.B       #1,D0
    ROR.B       D1,D0
    
    ROR.W       #1,D0
    ROR.W       D1,D0
    ROR.W       (A1)
    ROR.W       (A1)+
    ROR.W       -(A1)
    ROR.W       $1234
    ROR.W       $55555555
    
    ROR.L       #1,D0
    ROR.L       D1,D0
 
    ROL.B       #1,D0
    ROL.B       D1,D0
    
    ROL.W       #1,D0
    ROL.W       D1,D0
    ROL.W       (A1)
    ROL.W       (A1)+
    ROL.W       -(A1)
    ROL.W       $1234
    ROL.W       $55555555
    
    ROL.L       #1,D0
    ROL.L       D1,D0

    BCLR.L       #1,D0
    BCLR.L       D1,D0

    CMP.B      D3,D4                   *Move byte data from D3 to D4
    CMP.B      (A3),D4                 *Move byte data from (A3) to D4  
    CMP.B      (A3)+,D4                *Move byte data from (A3)+ to D4
    CMP.B      -(A3),D4                *Move byte data from -(A3) to D4
    CMP.B      $1234,D4                *Move byte data from $1234 to D4
    CMP.B      $12345678,D4            *Move byte data from $12345678 to D4
    CMP.B      #$55,D4                 *Move byte data from #$55 to D4    

    CMP.W      D3,D4                   *Move word data from D3 to D4    
    CMP.W      A3,D4                   *Move word data from A3 to D4    
    CMP.W      (A3),D4                 *Move word data from (A3) to D4    
    CMP.W      (A3)+,D4                *Move word data from (A3)+ to D4    
    CMP.W      -(A3),D4                *Move word data from -(A3) to D4    
    CMP.W      $1234,D4                *Move word data from $1234 to D4   
    CMP.W      $12345678,D4            *Move word data from $12345678 to D4   
    CMP.W      #$5555,D4               *Move word data from #$5555 to D4

    CMP.L      D3,D4                   *Move long word data from D3 to D4
    CMP.L      A3,D4                   *Move long word data from A3 to D4
    CMP.L      (A3),D4                 *Move long word data from (A3) to D4
    CMP.L      (A3)+,D4                *Move long word data from (A3)+ to D4
    CMP.L      -(A3),D4                *Move long word data from -(A3) to D4
    CMP.L      $1234,D4                *Move long word data from $1234 to D4
    CMP.L      $12345678,D4            *Move long word data from $12345678 to D4
    CMP.L      #$55555555,D4           *Move long word data from #$55555555 to D4

    CMPI.B      #$55,D4                 *EOR byte data from #$55 to D4
    CMPI.B      #$55,(A4)               *EOR byte data from #$55 to object in A4
    CMPI.B      #$55,(A4)+              *EOR byte data from #$55 to object in A4 and increase pointer by 1
    CMPI.B      #$55,-(A4)              *EOR byte data from #$55 to object in A4 after decrease pointer by 1
    CMPI.B      #$55,$1234              *EOR byte data from #$55 to absolute address WEORD
    CMPI.B      #$55,$12345678          *EOR byte data from #$55 to absolute address LONG WEORD
    
    CMPI.W      #$5555,D4               *EOR wEORd data from #$5555 to D4
    CMPI.W      #$5555,(A4)             *EOR wEORd data from #$5555 to object in A4
    CMPI.W      #$5555,(A4)+            *EOR wEORd data from #$5555 to object in A4 and increase pointer by 1
    CMPI.W      #$5555,-(A4)            *EOR wEORd data from #$5555 to object in A4 after decrease pointer by 1
    CMPI.W      #$5555,$1234            *EOR wEORd data from #$5555 to absolute address WEORD
    CMPI.W      #$5555,$12345678        *EOR wEORd data from #$5555 to absolute address LONG WEORD 
    
    CMPI.L      #$55555555,D4           *EOR long word data from #$55555555 to D4
    CMPI.L      #$55555555,(A4)         *EOR long word data from #$55555555 to object in A4
    CMPI.L      #$55555555,(A4)+        *EOR long word data from #$55555555 to object in A4 and increase pointer by 1
    CMPI.L      #$55555555,-(A4)        *EOR long word data from #$55555555 to object in A4 after decrease pointer by 1
    CMPI.L      #$55555555,$1234        *EOR long word data from #$55555555 to absolute address word
    CMPI.L      #$55555555,$12345678    *EOR long word data from #$55555555 to absolute address LONG word  

SIMHALT             ; halt simulator
    
* Put variables and constants here

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
