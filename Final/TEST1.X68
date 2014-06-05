*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program
   
    SUBI.W  #300,D1     *invalid starting case, should show 2 invalids
    
    ********************move commands********************
        *MOVE.B
    MOVE.B   #$3,D1
    MOVE.B   #$24,D3
    MOVE.B   #$34,(A3)
    MOVE.B   #$34,(A3)+
    MOVE.B   #$34,-(A3)
    MOVE.B   D1,D1
    MOVE.B   (A3),D3
    MOVE.B   (A2)+,(A3)
    MOVE.B   D5,(A3)+
    MOVE.B   $3000,-(A3)
        *MOVE.W
    MOVE.W   #$3,D1
    MOVE.W   #$204,D3
    MOVE.W   #$34,(A3)
    MOVE.W   #$3000,(A3)+
    MOVE.W   #$34,-(A3)
    MOVE.W   D1,D1
    MOVE.W   (A3),D3
    MOVE.W   (A2)+,(A3)
    MOVE.W   D5,(A3)+
    MOVE.W   $020456,-(A3)
        *MOVE.L
    MOVE.L   #$204,D3
    MOVE.L   #$34,(A3)
    MOVE.L   #$39004,(A3)+
    MOVE.L   #$020456,$020456
    MOVE.L   #$304,$3906
    MOVE.L   #$34,-(A3)
    MOVE.L   D1,D1
    MOVE.L   (A3),D3
    MOVE.L   (A2)+,(A3)
    MOVE.L   D5,(A3)+
    MOVE.L   $30000,-(A3)
    
        *MOVEA.W
    MOVEA.W  #$0002,A1
    MOVEA.W  D5,A1
    MOVEA.W  $2000,A1
        *MOVEA.L
    MOVEA.L  #$00001000,A2
    MOVEA.L  D5,A1
    MOVEA.L  $2000,A1
    
        *MOVEM.W - ADDRESS REG TO OTHER ADDRESS
    MOVEM.W A2,$123456 
    MOVEM.W A2,$1234
    MOVEM.W A2,(A3)
    MOVEM.W A2,-(A3)
        *MOVEM.W - DATA REG TO OTHER ADDRESS
    MOVEM.W D3,$123456 
    MOVEM.W D3,$1234
    MOVEM.W D3,(A3)
    MOVEM.W D3,-(A3)
        *MOVEM.W - OTHER ADDRESS TO MULTIPLE REG
    MOVEM.W $123456,D5/D6/D7/A5
    MOVEM.W $1234,D3/A2
    MOVEM.W (A3),D2-D5/A2-A7
    MOVEM.W (A3)+,D3/A2
        *MOVEM.W - OTHER ADDRESS TO DATA REG
    MOVEM.W $123456,D3
    MOVEM.W $1234,D3
    MOVEM.W (A3),D3
    MOVEM.W (A3)+,D3
        *MOVEM.W - OTHER ADDRESS TO ADDRESS REG
    MOVEM.W $123456,A2
    MOVEM.W $1234,A2
    MOVEM.W (A3),A2
    MOVEM.W (A3)+,A2
        *MOVEM.W - MULTIPLE REG TO OTHER ADDRESS
    MOVEM.W D3/A2,$123456 
    MOVEM.W D3/A2,$1234
    MOVEM.W D3/A2,(A3)
    MOVEM.W D5/D6/D7/A5,$123456
    MOVEM.W D3/A2,$1234
    MOVEM.W D2-D5/A2-A7,(A3)
    MOVEM.W D3/A2,-(A3)
    MOVEM.W D5/D6/D7/A5,-(A3)
    MOVEM.W D2-D5/A2-A7,-(A3)
        *MOVEM.L - ADDRESS REG TO OTHER ADDRESS
    MOVEM.L A2,$123456 
    MOVEM.L A2,$1234
    MOVEM.L A2,(A3)
    MOVEM.L A2,-(A3)
        *MOVEM.L - DATA REG TO OTHER ADDRESS
    MOVEM.L D3,$123456 
    MOVEM.L D3,$1234
    MOVEM.L D3,(A3)
    MOVEM.L D3,-(A3)
        *MOVEM.L - OTHER ADDRESS TO MULTIPLE REG
    MOVEM.L $123456,D5/D6/D7/A5
    MOVEM.L $1234,D3/A2
    MOVEM.L (A3),D2-D5/A2-A7
    MOVEM.L (A3)+,D3/A2
        *MOVEM.L - OTHER ADDRESS TO DATA REG
    MOVEM.L $123456,D3
    MOVEM.L $1234,D3
    MOVEM.L (A3),D3
    MOVEM.L (A3)+,D3
        *MOVEM.L - OTHER ADDRESS TO ADDRESS REG
    MOVEM.L $123456,A2
    MOVEM.L $1234,A2
    MOVEM.L (A3),A2
    MOVEM.L (A3)+,A2
        *MOVEM.L - MULTIPLE REG TO OTHER ADDRESS
    MOVEM.L D3/A2,$123456 
    MOVEM.L D3/A2,$1234
    MOVEM.L D3/A2,(A3)
    MOVEM.L D5/D6/D7/A5,$123456
    MOVEM.L D3/A2,$1234
    MOVEM.L D2-D5/A2-A7,(A3)
    MOVEM.L D3/A2,-(A3)
    MOVEM.L D5/D6/D7/A5,-(A3)
    MOVEM.L D2-D5/A2-A7,-(A3)

    SUBI.W  #300,D1     *invalid case, should show 2 invalids

    ********************Branching commands********************
        *BRA
    BRA     $8008
    BRA     $7FF
    BRA     $8500
    BRA     $700
    
        *BCS
    BCS     $8008
    BCS     $7FFF
    BCS     $8500
    BCS     $700   
    
        *BGE
    BGE     $8008
    BGE     $7FFF
    SUBI.W  #300,D1     *invalid case, should show 2 invalids
    BGE     $8500
    BGE     $700  
    
        *BCC
    BCC     $8008
    BCC     $7FFF
    BCC     $800
    BCC     $7000 
 
        *BVC
    BVC     $808
    BVC     $7FFF
    BVC     $500
    BVC     $7000
    
        *BLT
    BLT     $808
    BLT     $7FF
    BLT     $8500
    BLT     $7000
    
    ********************Jumping / Returning ********************
    JSR      TST
TST RTS     

    ********************Bit Clear command********************
    BCLR.L  #$2,D1
    BCLR.L  #$20,D1
    BCLR.L  #$31,D1
    BCLR.B  #$2,(A1)
    BCLR.B  #$2,-(A1)
    BCLR.B  #$20,(A1)+
    BCLR.B   D2,$40
    BCLR.B   D2,$48850
    BCLR.B   D2,$025
    BCLR.L   D2,D0
    
    ********************Or commands********************
        *OR
    OR.B   D2,D1
    OR.B   $1234,D1       
    OR.W   $020456,D1  
    OR.L   #$12,D1    
    OR.W   (A1),D1 
    OR.B   -(A1),D1
    OR.B   (A1)+,D1 
    OR.B   D1,(A1)+
    OR.B   D1,$1234      
    OR.L   D1,$020456
    OR.B   D1,(A3)   
    OR.L   D1,(A1)
    OR.W   D1,-(A1)
    OR.B   D1,(A1)+
    
        *ORI
    ORI.L   #$020456,$020456
    ORI.B   #$4,D3
    ORI.W   #$234,D3
    ORI.W   #$304,(A3)
    ORI.W   #$304,(A3)+
    ORI.W   #$304,-(A3)
    ORI.L   #$020456,$020456
    ORI.B   #$34,$8010
    
        *EOR.B
    EOR.B   D1,$020456
    EOR.B   D1,(A2)
    EOR.B   D2,$300
    EOR.B   D1,(A2)+
    EOR.B   D1,-(A2)
        *EOR.W
    EOR.W   D1,$020456
    EOR.W   D1,(A2)
    EOR.W   D2,$30
    EOR.W   D1,(A2)+
    EOR.W   D1,-(A2)
        *EOR.L
    EOR.L   D1,$020456
    EOR.L   D1,(A2)
    EOR.L   D2,$30
    EOR.L   D1,(A2)+
    EOR.L   D1,-(A2)
    
    ********************Compare commands********************
        *CMP.B
    CMP.B     $12,D1
    CMP.B     $1234,D1
    CMP.B     $020456,D1
    CMP.B     (A1),D1
    CMP.B     -(A1),D1
    CMP.B     (A1)+,D1
    CMP.B     #$12,D1
        *CMP.W
    CMP.W     $12,D1
    CMP.W     $1234,D1
    CMP.W     $020456,D1
    CMP.W     (A1),D1
    CMP.W     -(A1),D1
    CMP.W     (A1)+,D1
    CMP.W     A1,D1
    CMP.W     #$12,D1
    CMP.W     #$1234,D1
        *CMP.L
    CMP.L     $12,D1
    CMP.L     $1234,D1
    CMP.L     $020456,D1
    CMP.L     (A1),D1
    CMP.L     -(A1),D1
    CMP.L     (A1)+,D1
    CMP.L     A1,D1
    CMP.L     #$12,D1
    CMP.L     #$1234,D1
    CMP.L     #$020456,D1
    
        *CMPI
    CMPI.L   #$020456,$020456
    CMPI.B   #$4,D3
    CMPI.W   #$234,D3
    CMPI.W   #$304,(A3)
    CMPI.W   #$304,(A3)+
    CMPI.W   #$304,-(A3)
    CMPI.L   #$020456,$020456
    CMPI.B   #$34,$8010  
    
    ********************LEA commands********************
    LEA    $12,A1
    LEA    (A1),A2
    LEA    $020456,A2 
    
    ********************Arithmetic Commands ********************
        *NEG.B
    NEG.B    $12
    NEG.B    $1234
    NEG.B    $020456
    NEG.B    D1
    SUBI.W  #300,D1     *invalid case, should show 2 invalids
    NEG.B    (A1)+   
    NEG.B    -(A1)
    NEG.B    (A1)
        *NEG.W
    NEG.W    $12
    NEG.W    $1234
    NEG.W    $020456
    NEG.W    D1
    NEG.W    (A1)+
    NEG.W    -(A1)
    NEG.W    (A1)
        *NEG.L
    NEG.L    $12
    NEG.L    $1234
    NEG.L    $020456
    NEG.L    D1
    NEG.L    (A1)+
    NEG.L    -(A1)
    NEG.L    (A1)
    
        *ADD.B
    ADD.B    D2,D1
    ADD.B    $1234,D1
    ADD.B    $020456,D1
    ADD.B    (A1),D1
    ADD.B    -(A1),D1
    ADD.B    (A1)+,D5
    ADD.B    (A1),D4 
        *ADD.W
    ADD.W    D2,D1
    ADD.W    $1234,D1
    ADD.W    $020456,D1
    ADD.W    (A1),D1
    ADD.W    -(A1),D1
    ADD.W    (A1)+,D5
    ADD.W    (A1),D4
        *ADD.L
    ADD.L    D2,D1
    ADD.L    $1234,D1
    ADD.L    $020456,D1
    ADD.L    (A1),D1
    ADD.L    -(A1),D1
    ADD.L    (A1)+,D5
    ADD.L    (A1),D4
        *ADDA
    ADDA.L  #$40,A1
    ADDA.W  #$4000,A1
    ADDA.W  D1,A1
    ADDA.L  (A2)+,A1
    ADDA.L  -(A2),A1
    ADDA.W  (A2),A1
    ADDA.L  $50005,A1  

        *SUB.B
    SUB.B    D2,D1
    SUB.B    $1234,D1
    SUB.B    $020456,D1
    SUB.B    (A1),D1
    SUB.B    -(A1),D1
    SUB.B    (A1)+,D5
    SUB.B    (A1),D4 
        *SUB.W
    SUB.W    D2,D1
    SUB.W    $1234,D1
    SUB.W    $020456,D1
    SUB.W    (A1),D1
    SUB.W    -(A1),D1
    SUB.W    (A1)+,D5
    SUB.W    (A1),D4
        *SUB.L
    SUB.L    D2,D1
    SUB.L    $1234,D1
    SUB.L    $020456,D1
    SUB.L    (A1),D1
    SUB.L    -(A1),D1
    SUB.L    (A1)+,D5
    SUB.L    (A1),D4
    
        *SUBQ
    SUBQ.B  #$1,D1    
    SUBQ.W  #$2,A1 
    SUBQ.L  #$3,(A3)+ 
        
        *MULS.W
    MULS.W    #$20,D1
    MULS.W    D2,D1
    MULS.W    #$20,D2
    MULS.W    (A1),D1
    SUBI.W  #300,D1     *invalid case, should show 2 invalids
    MULS.W    -(A1),D1
    MULS.W    (A1)+,D5
    MULS.W    (A1),D4    
    
        *DIVS.W
    DIVS.W    #$20,D1
    DIVS.W    D2,D1
    DIVS.W    #$20,D2
    DIVS.W    (A1),D1
    DIVS.W    -(A1),D1
    DIVS.W    (A1)+,D5
    DIVS.W    (A1),D4 
    ********************Shifting Commands ********************
        *LSR
    LSR.B   #8,D1
    LSR.B   D2,D1
    LSR.W   #5,D1
    LSR.W   D2,D1
    LSR.W   (A1)
    LSR.W   (A1)+
    LSR.W   -(A1)
    LSR.W   $3000
    LSR.L   #5,D1
    LSR.L   D2,D1
    
        *ASR
    ASR.B   #5,D1
    ASR.B   D2,D1
    ASR.W   #8,D1
    ASR.W   D2,D1
    ASR.W   (A1)
    ASR.W   (A1)+  
    ASR.W   -(A1)
    ASR.W   $3000
    ASR.L   #5,D1
    ASR.L   D2,D1
    
        *ROR
    ROR.B   #5,D1
    ROR.B   D2,D1
    ROR.W   #8,D1
    ROR.W   D2,D1
    ROR.W   (A1)
    ROR.W   (A1)+
    ROR.W   -(A1)
    ROR.W   $3000
    ROR.L   #8,D1
    ROR.L   D2,D1
    
        *LSL
    LSL.B   #5,D1
    LSL.B   D2,D1
    LSL.W   #8,D1
    LSL.W   D2,D1
    LSL.W   (A1)
    LSL.W   (A1)+
    LSL.W   -(A1)
    LSL.W   $3000
    LSL.L   #5,D1
    LSL.L   D2,D1
    
        *ASL
    ASL.B   #8,D1
    ASL.B   D2,D1
    ASL.W   #5,D1
    ASL.W   D2,D1
    ASL.W   (A1)
    ASL.W   (A1)+
    SUBI.W  #300,D1     *invalid case, should show 2 invalids
    ASL.W   -(A1)
    ASL.W   $3000
    ASL.L   #5,D1
    ASL.L   D2,D1
    
        *ROL
    ROL.B   #5,D1
    ROL.B   D2,D1
    ROL.W   #8,D1
    ROL.W   D2,D1
    ROL.W   (A1)
    ROL.W   (A1)+
    ROL.W   -(A1)
    ROL.W   $3000
    ROL.L   #8,D1
    ROR.L   D2,D1
    SUBI.W  #300,D1     *end invalid case, should show 2 invalids

    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
