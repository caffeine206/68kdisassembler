*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
   *-----------------------------------------------------------
* Title      : 68K test
* Written by : Team Rango
* Date       : 11/14/2013
* Description: intend to input data into memory location.
*-----------------------------------------------------------

    ORG         $0000A000
START

*-MOVE opcode-----------------------------------
    
    *---MOVE.B
    MOVE.B  #101,D1
    MOVE.B  $48,D2
    MOVE.B  #$AA,D1
    MOVE.B  D1,(A6)+
    MOVE.B  D0,(A2)
    MOVE.B  D0,-(A0)
    MOVE.B  (A1), D1
    MOVE.B  (A1)+,D1
    MOVE.B  -(A1),D1
    MOVE.B  #$40,D2
    MOVE.B  D0,D1
    MOVE.B  D0, $E111
    MOVE.B  D0, $E1234560
 
    *---MOVE.W
    MOVE.W  #1201,D1
    MOVE.W  $418,D2
    MOVE.W  #$ABA,D1
    MOVE.W  D1,(A6)+
    MOVE.W  D0,(A2)
    MOVE.W  D0,-(A0)
    MOVE.W  (A1), D1
    MOVE.W  (A1)+,D1
    MOVE.W  -(A1),D1
    MOVE.W  #$4120,D2
    MOVE.W  D0,D1
    MOVE.W  D0, $AE111
    MOVE.W  D0, $E1234
    
    *---MOVE.L
    MOVE.L  #1201,D1
    MOVE.L  $418,D2
    MOVE.L  #$ABA,D1
    MOVE.L  D1,(A6)+
    MOVE.L  D0,(A2)
    MOVE.L  D0,-(A0)
    MOVE.L  (A1), D1
    MOVE.L  (A1)+,D1
    MOVE.L  -(A1),D1
    MOVE.L  #$4120,D2
    MOVE.L  D0,D1
    MOVE.L  D0, $AE111
    MOVE.L  D0, $E1234
    
*-MOVEA opcode-----------------------------------
    *---MOVEA.W
    MOVEA.W  #%11001,A1
    MOVEA.W  $4180AABB,A2
    MOVEA.W  #$ACAA,A1
    MOVEA.W  21031,A4
    MOVEA.W  D1,A6
    MOVEA.W  A2,A2
    MOVEA.W  D0,A0
    MOVEA.W  (A1), A2
    MOVEA.W  (A1)+,A2
    MOVEA.W  -(A1),A2

    *---MOVEA.L
    MOVEA.L  #%11001,A1
    MOVEA.L  $4180AABB,A2
    MOVEA.L  #$ACAA,A1
    MOVEA.L  21031,A4
    MOVEA.L  D1,A6
    MOVEA.L  A2,A2
    MOVEA.L  D0,A0
    MOVEA.L  (A1), A2
    MOVEA.L  (A1)+,A2
    MOVEA.L  -(A1),A2

*--MOVEM OPCODE--------------------------------------
    MOVEM.L D0-D7/A0-A6,$1234
    MOVEM.L (A5),D0-D2/D5-D7/A0-A3/A6
    MOVEM.W (A7)+,D0-D5/D7/A0-A6
    MOVEM.W D0-D5/D7/A0-A6,-(A7)    
         
*----AND, ORI, EOR, EORI, NOT, CMP, CMPA, CMPI----
    ANDI    #%10000111,D7
    ANDI    #$FE00,$1234
    ANDI.B  #$F0,(A2)+
    ANDI.w  #$F0,-(A2) 
    ANDI.L  #$F0,(A2)
    ANDI    #$F0,(A2)
    ANDI    #$1234,(A2)

*----ORI---------
    ORI.B #%00000011,(A0)+
    ORI.B #%00000011,-(A0)
    ORI.B #%00000011,(A0)
    ORI.W #$F001,D0
    ORI.L #$11111111,D0
    
*----EORI
    EORI    #%10000111,D7
    EORI    #$FE00,$1234
    EORI.B  #$F0,(A2)+
    EORI.w  #$F0,-(A2) 
    EORI.L  #$F0,(A2)
    EORI    #$F0,(A2)
    EORI    #$123,(A2) 

*----NOT
    NOT       $FE00
    NOT.B     (A2)+
    NOT.w     -(A2) 
    NOT.L     (A2)  
    
*---CMP
    CMP     D0,D1
    CMP     A1,D2
    CMP     (A2)+,D3
    CMP     -(A2),D3
    CMP     (A3),D4
    CMP     #$1002,D5
    CMP     1110,D6

*---CMPA
    CMPA.L   A0,A1
    CMPA.W   $1000,A1
    CMPA.L   #$1000,A4
    CMPA.W   (A2)+,A6
    CMPA.L   D5,A2
    CMPA.L   -(A2),A3
    CMPA.L   (A2),A3
*---CMPI
 
    CMPI.B     #$12,(A4)
    CMPI.W     #$1234,-(A3)
    CMPI.L     #$1002,(A3)+
    CMPI.W     #1110,(A6)  
    CMPI       #$2000,D1 
    

************Rattanak: ADDA, ADDQ, SUB, SUBA,SUBI, MULU, MULS, LEA **********
*---ADD---------------------------------------------------------------------
*---ADD.B
    ADD.B  $48,D2
    ADD.B  #$AA,D1
    ADD.B  D1,(A6)+
    ADD.B  D0,(A2)
    ADD.B  D0,-(A0)
    ADD.B  #$40,D2
    ADD.B  D0, $E111
    ADD.B  D0, $E1234560	
*---ADD.W
    ADD.W  #101,A1
    ADD.W  $48,D2
    ADD.W  #$AA,D1
    ADD.W  D1,(A6)+
    ADD.W  D0,(A2)
    ADD.W  D0,-(A0)
    ADD.W  (A1), A2
    ADD.W  (A1)+,A2
    ADD.W  -(A1),A2
    ADD.W  #$40,D2
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
*---ADDA
    ADDA.W  #101,A1
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
    ADDA.L  #101,A1
    ADD.L  #$101,A1
*---ADDI
    ADDI.B  #101,D1
    ADDI.B  #10,D1
    ADDI.W  #$101,D1
    ADDI.W  #10, $E111
    ADDI.W  #10, $E1234560
    ADDI.L  #$101,D1
*---ADDQ
    ADDQ.B  #1,D1
    ADDQ.B  #1,D1
    ADDQ.W  #$1,D1
    ADDQ.W  #1, $E111
    ADDQ.W  #1, $E1234560
    ADDQ.L  #$1,D1
*---SUB
    SUB.B  #1,D1
    SUB.B  #1,D1
    SUB.W  #$1,D1
    SUB.W  #1, $E111
    SUB.W  #1, $E1234560
    SUB.L  #$1,D1
*---SUBA
    SUBA.W  A1,A1
    SUBA.W  D1,A2
    SUBA.W  #$1,A3
    SUBA.W  #1, A1
    SUBA.L  #$1,A2
*---SUBI
    SUBI.B  #1,D1
    SUBI.B  #1,$1234
    SUBI.W  #1,$1234
    SUBI.W  #1,D1
    SUBI.W  #$1,D1
    SUBI.W  #1, $1234
    SUBI.L  #$1, $1234
*---MULU
    MULU.W  #1,D1
    MULU.W  D0,D1
    MULU.W  #$00001,D0
    MULU.W  #$1,D1
    MULU.W  D0, D1
*---MULS
    MULS.W  #1,D1
    MULS.W  D0,D1
    MULS.W  #$00001,D0
    MULS.W  #$1,D1
    MULS.W  D0, D1
*---LEA
    LEA.L  $1000,A0
    LEA  $1001,A0
    LEA  $00001,A1
    
    
*****************Chamnap: ASL, LSR, BTST, Bcc, JSR, RTS***************
***************ASL******************************
    *MOVE.L      #%101, D0
    ASL.B       #1, D0
    ASL.W       #1, D0
    ASL.L       #1, D0
    
    *MOVE.L      #4, D1
    ASL.B       D1, D0
    ASL.W       D1, D0
    ASL.L       D1, D0
    
***************LSR******************************
	LSR.B		#1, D0
	LSR.W	#1, D0
	LSR.L		#1, D0

	LSR.B		D1, D0
	LSR.W	D1, D0
	LSR.L		D1, D0

****************BTST****************************
	*MOVEA.L	#$FFFF, A0
	BTST.L	D1, D0
	BTST.B	D1, (A0)
	BTST.B	D1, (A0)+
	BTST.B	D1, -(A0)
	BTST.B	D1, $FFFF
	BTST.B	D1, $0000A000

	BTST.L	#1, D0
	BTST.B	#1, (A0)
	BTST.B	#1, (A0)+
	BTST.B	#1, -(A0)
	BTST.B	#1, $FFFF
	BTST.B	#1, $0000A0000

*****************Bcc******************************
    	BCC     SomeLabel
    	BCS     SomeLabel
    	BEQ     SomeLabel
	BNE     SomeLabel
	BGE     SomeLabel
    	BGT     SomeLabel
    	BHI     SomeLabel
    	BLE     SomeLabel
    	BLS     SomeLabel
    	BLT     SomeLabel
    	BMI     SomeLabel
    	BPL     SomeLabel
    	BVS     SomeLabel
    	BVC     SomeLabel
    
****************JSR and RTS************************
    	JSR     test
test 	RTS 
    
someLabel
************Rattanak: ADDA, ADDQ, SUB, SUBA,SUBI, MULU, MULS, LEA **********
*---ADD---------------------------------------------------------------------
*---ADD.B
    ADD.B  $48,D2
    ADD.B  #$AA,D1
    ADD.B  D1,(A6)+
    ADD.B  D0,(A2)
    ADD.B  D0,-(A0)
    ADD.B  #$40,D2
    ADD.B  D0, $E111
    ADD.B  D0, $E1234560	
*---ADD.W
    ADD.W  #101,A1
    ADD.W  $48,D2
    ADD.W  #$AA,D1
    ADD.W  D1,(A6)+
    ADD.W  D0,(A2)
    ADD.W  D0,-(A0)
    ADD.W  (A1), A2
    ADD.W  (A1)+,A2
    ADD.W  -(A1),A2
    ADD.W  #$40,D2
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
*---ADDA
    ADDA.W  #101,A1
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
    ADDA.L  #101,A1
    ADD.L  #$101,A1
*---ADDI
    ADDI.B  #101,D1
    ADDI.B  #10,D1
    ADDI.W  #$101,D1
    ADDI.W  #10, $E111
    ADDI.W  #10, $E1234560
    ADDI.L  #$101,D1
*---ADDQ
    ADDQ.B  #1,D1
    ADDQ.B  #1,D1
    ADDQ.W  #$1,D1
    ADDQ.W  #1, $E111
    ADDQ.W  #1, $E1234560
    ADDQ.L  #$1,D1
*---SUB
    SUB.B  #1,D1
    SUB.B  #1,D1
    SUB.W  #$1,D1
    SUB.W  #1, $E111
    SUB.W  #1, $E1234560
    SUB.L  #$1,D1
*---SUBA
    SUBA.W  A1,A1
    SUBA.W  D1,A2
    SUBA.W  #$1,A3
    SUBA.W  #1, A1
    SUBA.L  #$1,A2
*---SUBI
    SUBI.B  #1,D1
    SUBI.B  #1,$1234
    SUBI.W  #1,$1234
    SUBI.W  #1,D1
    SUBI.W  #$1,D1
    SUBI.W  #1, $1234
    SUBI.L  #$1, $1234
*---MULU
    MULU.W  #1,D1
    MULU.W  D0,D1
    MULU.W  #$00001,D0
    MULU.W  #$1,D1
    MULU.W  D0, D1
*---MULS
    MULS.W  #1,D1
    MULS.W  D0,D1
    MULS.W  #$00001,D0
    MULS.W  #$1,D1
    MULS.W  D0, D1
*---LEA
    LEA.L  $1000,A0
    LEA  $1001,A0
    LEA  $00001,A1


*----ORI---------
    ORI.B #%00000011,(A0)+
    ORI.B #%00000011,-(A0)
    ORI.B #%00000011,(A0)
    ORI.W #$F001,D0
    ORI.L #$11111111,D0
    
*----EORI
    EORI    #%10000111,D7
    EORI    #$FE00,$1234
    EORI.B  #$F0,(A2)+
    EORI.w  #$F0,-(A2) 
    EORI.L  #$F0,(A2)
    EORI    #$F0,(A2)
    EORI    #$123,(A2) 

*----NOT
    NOT       $FE00
    NOT.B     (A2)+
    NOT.w     -(A2) 
    NOT.L     (A2)  
    
*---CMP
    CMP     D0,D1
    CMP     A1,D2
    CMP     (A2)+,D3
    CMP     -(A2),D3
    CMP     (A3),D4
    CMP     #$1002,D5
    CMP     1110,D6

*---CMPA
    CMPA.L   A0,A1
    CMPA.W   $1000,A1
    CMPA.L   #$1000,A4
    CMPA.W   (A2)+,A6
    CMPA.L   D5,A2
    CMPA.L   -(A2),A3
    CMPA.L   (A2),A3
*---CMPI
 
    CMPI.B     #$12,(A4)
    CMPI.W     #$1234,-(A3)
    CMPI.L     #$1002,(A3)+
    CMPI.W     #1110,(A6)  
    CMPI       #$2000,D1 
    
***************ASL******************************
    *MOVE.L      #%101, D0
    ASL.B       #1, D0
    ASL.W       #1, D0
    ASL.L       #1, D0
    
    *MOVE.L      #4, D1
    ASL.B       D1, D0
    ASL.W       D1, D0
    ASL.L       D1, D0
    
***************LSR******************************
	LSR.B		#1, D0
	LSR.W	#1, D0
	LSR.L		#1, D0

	LSR.B		D1, D0
	LSR.W	D1, D0
	LSR.L		D1, D0

****************BTST****************************
	*MOVEA.L	#$FFFF, A0
	BTST.L	D1, D0
	BTST.B	D1, (A0)
	BTST.B	D1, (A0)+
	BTST.B	D1, -(A0)
	BTST.B	D1, $FFFF
	BTST.B	D1, $0000A000

	BTST.L	#1, D0
	BTST.B	#1, (A0)
	BTST.B	#1, (A0)+
	BTST.B	#1, -(A0)
	BTST.B	#1, $FFFF
	BTST.B	#1, $0000A0000

*****************Bcc******************************
    	BCC     SomeLabel
    	BCS     SomeLabel
    	BEQ     SomeLabel
	    BNE     SomeLabel
	    BGE     SomeLabel
    	BGT     SomeLabel
    	BHI     SomeLabel
    	BLE     SomeLabel
    	BLS     SomeLabel
    	BLT     SomeLabel
    	BMI     SomeLabel
    	BPL     SomeLabel
    	BVS     SomeLabel
    	BVC     SomeLabel
    
****************JSR and RTS************************
    	JSR     test
*test 	RTS 

************Rattanak: ADDA, ADDQ, SUB, SUBA,SUBI, MULU, MULS, LEA **********
*---ADD---------------------------------------------------------------------
*---ADD.B
    ADD.B  $48,D2
    ADD.B  #$AA,D1
    ADD.B  D1,(A6)+
    ADD.B  D0,(A2)
    ADD.B  D0,-(A0)
    ADD.B  #$40,D2
    ADD.B  D0, $E111
    ADD.B  D0, $E1234560	
*---ADD.W
    ADD.W  #101,A1
    ADD.W  $48,D2
    ADD.W  #$AA,D1
    ADD.W  D1,(A6)+
    ADD.W  D0,(A2)
    ADD.W  D0,-(A0)
    ADD.W  (A1), A2
    ADD.W  (A1)+,A2
    ADD.W  -(A1),A2
    ADD.W  #$40,D2
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
*---ADDA
    ADDA.W  #101,A1
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
    ADDA.L  #101,A1
    ADD.L  #$101,A1
*---ADDI
    ADDI.B  #101,D1
    ADDI.B  #10,D1
    ADDI.W  #$101,D1
    ADDI.W  #10, $E111
    ADDI.W  #10, $E1234560
    ADDI.L  #$101,D1
*---ADDQ
    ADDQ.B  #1,D1
    ADDQ.B  #1,D1
    ADDQ.W  #$1,D1
    ADDQ.W  #1, $E111
    ADDQ.W  #1, $E1234560
    ADDQ.L  #$1,D1
*---SUB
    SUB.B  #1,D1
    SUB.B  #1,D1
    SUB.W  #$1,D1
    SUB.W  #1, $E111
    SUB.W  #1, $E1234560
    SUB.L  #$1,D1
*---SUBA
    SUBA.W  A1,A1
    SUBA.W  D1,A2
    SUBA.W  #$1,A3
    SUBA.W  #1, A1
    SUBA.L  #$1,A2
*---SUBI
    SUBI.B  #1,D1
    SUBI.B  #1,$1234
    SUBI.W  #1,$1234
    SUBI.W  #1,D1
    SUBI.W  #$1,D1
    SUBI.W  #1, $1234
    SUBI.L  #$1, $1234
*---MULU
    MULU.W  #1,D1
    MULU.W  D0,D1
    MULU.W  #$00001,D0
    MULU.W  #$1,D1
    MULU.W  D0, D1
*---MULS
    MULS.W  #1,D1
    MULS.W  D0,D1
    MULS.W  #$00001,D0
    MULS.W  #$1,D1
    MULS.W  D0, D1
*---LEA
    LEA.L  $1000,A0
    LEA  $1001,A0
    LEA  $00001,A1


     END           START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
