;coming from B0556

LeftDoubleTapBeginP1:
	;cmpa.l $413410,A0 ;are we P1 or P2?
	;cmpa.w $3410,A0 ;are we P1 or P2?
	cmpi.b #00,D3 ;00 is P1, FF is P2
	bne LeftDoubleTapBeginP2
	cmpi.b #04,(-$6AC,A5) ;is P1 non-unified holding LEFT?
	bne NotHoldingLeft
	jmp LeftDoubleTapBeginBoth

LeftDoubleTapBeginP2:
	cmpi.b #04,(-$6A8,A5) ;is P2 non-unified holding LEFT?
	bne NotHoldingLeft

LeftDoubleTapBeginBoth:
	cmpi.b #00,$AF(A0) ;are we within the timer window to double tap LEFT?
	beq FirstLeftTap ;if the timer window is zero, this was our first tap Left
	cmpi.b #01,$B0(A0) ;have we let go of left? (this is 00 if we have)
	beq SubLeftTimer
	move.b #$C4,$10(A0) ;set our cursor to C4 (pointing left)
	move.w #$0007,$4134BA ; SOUND - DOUBLE TAP LEFT
	move.b #00,$AF(A0) ;reset the timer window
	jmp OriginalCode

FirstLeftTap:
	move.b #20,$AF(A0) ;move 20 frame timer window for double tap LEFT
	move.b #01,$B0(A0) ;flag that says we are pressing LEFT currently
	jmp OriginalCode

NotHoldingLeft:
	move.b #00,$B0(A0) ;flag that says we are NOT pressing LEFT currently

SubLeftTimer:
	cmpi.b #00,$AF(A0) ;is the timer window at zero?
	beq RightDoubleTapBeginP1
	subi.b #01,$AF(A0) ;subtract 1 from the timer window

RightDoubleTapBeginP1:
	;cmpa.l $413410,A0
	;cmpa.w $3410,A0 ;are we P1 or P2?
	cmpi.b #00,D3 ;00 is P1, FF is P2
	bne RightDoubleTapBeginP2
	cmpi.b #08,(-$6AC,A5) ;is P1 non-unified holding RIGHT?
	bne NotHoldingRight
	jmp RightDoubleTapBeginBoth

RightDoubleTapBeginP2:
	cmpi.b #08,(-$6A8,A5) ;is P2 non-unified holding RIGHT?
	bne NotHoldingRight

RightDoubleTapBeginBoth:
	cmpi.b #00,$B1(A0) ;are we within the timer window to double tap RIGHT?
	beq FirstRightTap ;if the timer window is zero, this was our first tap RIGHT
	cmpi.b #01,$B2(A0) ;have we let go of RIGHT? (this is 00 if we have)
	beq SubRightTimer
	move.b #$3C,$10(A0) ;set our cursor to 3C (pointing right)
	move.w #$0007,$4134BA ; SOUND - DOUBLE TAP RIGHT
	move.b #00,$B1(A0) ;reset the timer window
	jmp OriginalCode

FirstRightTap:
	move.b #20,$B1(A0) ;move 20 frame timer window for double tap RIGHT
	move.b #01,$B2(A0) ;flag that says we are pressing RIGHT currently
	jmp OriginalCode

NotHoldingRight:
	move.b #00,$B2(A0) ;flag that says we are NOT pressing RIGHT currently

SubRightTimer:
	cmpi.b #00,$B1(A0) ;is the timer window at zero?
	beq OriginalCode
	subi.b #01,$B1(A0) ;subtract 1 from the timer window

OriginalCode:
	btst.b #2,$41F831
	bne.w MovingLeft
	btst.b #3,$41F831
	bne.w MovingRight
	jmp $B056E ;if we didn't do anything

MovingLeft:
	jmp $B0650

MovingRight:
	jmp $B0666