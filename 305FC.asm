;coming from B056E, we are now at 305FC

	cmpi.b #02,$41f773;sanity check to make sure game is going on
	bne OriginalCodeB056E

NudgeAllowedCheck:
	cmpi.b #00,$A4(A0) ;is the nudge check 00? if not, leave, no nudges allowed
	bne AllowNudgeNextTime
	;if nudge check was 00, proceed down to permitting nudge

NudgeLeft:
	cmpi.b #$20,$41f831.l
	bne NudgeRight ;if we aren't pressing button 2, let's go check to see if we are pressing btn 3
	cmpi.b #$C4,$10(A0) ;are we at the far left maximum
	beq SetGuideOnP1 ;we are at the far left max, so let's leave
	subi.b #$1,$10(A0) ;subtract 1 from cursor position
	move.w #$001B,$4134BA ; SOUND - NUDGE LEFT
	move.b #30,$A4(A0) ;set the nudge delay byte to 30
	;bge.b SetGuideOnP1 ;if we are greater than or equal to C4, we leave
	;move.b #$C4,$10(A0) ;if it was less than C4, we move C4 in there
	bra SetGuideOnP1 ;we did our nudge, let's now leave (no further actions)

NudgeRight:
	cmpi.b     #$40,$41f831.l
	bne DoubleTapUp ;let's move on to trying the next event thing
	cmpi.b #$3C,$10(A0) ;are we at the far right maximum
	beq SetGuideOnP1 ;we are at the far right, let's leave
	addi.b #$1,$10(A0)
	move.w #$001B,$4134BA ; SOUND - NUDGE RIGHT
	move.b #30,$A4(A0) ;set the nudge byte to 30
	;ble.b SetGuideOnP1 ;if it's less than or equal to 3C, leave
	;move.b #$3C,$10(A0) ;if it was greater than 3C, we move 3C in there ;we did our nudge, let's now leave (no further actions)
	bra SetGuideOnP1 ;we did our nudge, let's now leave (no further actions)

AllowNudgeNextTime:
	subi.b #1,$A4(A0) ;subtract 1 from nudge delay byte

DoubleTapUp:
	cmpi.b #00,D3 ;00 is P1, FF is P2
	bne DoubleTapUpCheckP2
	cmpi.b #01,(-$6AC,A5) ;is P1 non-unified holding UP? (DO NOT SET THIS TO CMPI.B #00 - we need 01 as the input for up)
	bne NotHoldingUp
	jmp DoubleTapUpStart

DoubleTapUpCheckP2:
	cmpi.b #01,(-$6A8,A5) ;is P2 non-unified holding up? (DO NOT SET THIS TO CMPI.B #00 - we need 01 as the input for up)
	bne NotHoldingUp

DoubleTapUpStart:
	cmpi.b #00,$A5(A0) ;are we within the timer window to double tap UP?
	beq FirstUpTap ;if the timer window is zero, this was our first tap UP
	cmpi.b #00,$A6(A0) ;have we let go of up? (this is 00 if we have)
	bne SubUpTimer
	move.b #00,$A5(A0) ;reset the timer window
	cmpi.b #00,$10(A0) ;are we already at up?
	beq SetGuideOnP1 ;if we're already at up, don't need to do double tap, leave
	move.b #00,$10(A0) ;set our cursor to 00 (pointing up)
	move.w #$0007,$4134BA ; SOUND - DOUBLE TAP UP
	jmp SetGuideOnP1; jmp OriginalCode

FirstUpTap:
	move.b #13,$A5(A0) ;move 13 frame timer window for double tap UP
	move.b #01,$A6(A0) ;flag that says we are pressing UP currently
	jmp SetGuideOnP1; jmp OriginalCode

NotHoldingUp:
	move.b #00,$A6(A0) ;flag that says we are NOT pressing UP currently

SubUpTimer:
	cmpi.b #00,$A5(A0) ;is the timer window at zero?
	beq SetGuideOnP1
	subi.b #01,$A5(A0) ;subtract 1 from the timer window

SetGuideOnP1:
	cmpi.w #$00F0,$413464
	ble TurnGuideOffP1 ;the timer warning is NOT on, so let's turn off the guide (if need be)
	ori.b #$80,$41F836 ;the shot timer is above F0, now we will turn the guide is on
	jmp SetGuideOnP2

TurnGuideOffP1:
	andi.b #$7F,$41F836 ;turn off the guide

SetGuideOnP2:
	cmpi.w #$00F0,$413564
	ble TurnGuideOffP2 ;the timer warning is NOT on, so let's turn off the guide (if need be)
	ori.b #$80,$41F837 ;now the guide is on
	jmp HoldDownExchangeP1

TurnGuideOffP2:
	;cmpi.w #$0000,$413564
	;beq HoldDownExchangeP1
	andi.b #$7F,$41F837 ;turn off the guide

HoldDownExchangeP1:
	cmpi.b #$08,$4134B7 ;after they swap, set 4134B7 to 08, if it's 08, don't allow any of this. set 4134B7 to 00 after shot fired (should be after let go of down)
	beq P1TimerCheckDown ;we need to be able to reset it if the player just shot, so don't just skip past to Player 2
	cmpi.b #02,$407954 ;P1 input - is down held?
	bne TurnOffP1Down
	;add a check for whether the preview and current are the same
	addi.w #01,$4134B7 ;p1 held down accumulator
	addi.b #01,$4134B9 ;cursor angle counter thingie
	cmpi.b #$08,$4134B9 ;code related to cursor shaking - is it halfway?
	bgt OscillatorSubP1
	addi.b #01,$413420 ;add 1 to p1 cursor angle (shaking)
	cmpi.b #$3C,$10(A0) ;are we at the far right maximum
	ble.b P1TimerCheckDown ;if it's less than or equal to 3C, leave
	move.b #$3C,$10(A0) ;if it was greater than 3C, we move 3C in there
	jmp P1TimerCheckDown

OscillatorSubP1:
	move.w #$00B0,$4134BA ; SOUND - HELDDOWN OSCILLATOR
	subi.b #01,$413420
	cmpi.b #$C4,$10(A0) ;are we at the far left maximum
	bge.b CheckOscP1 ;if we are greater than or equal to C4, we leave
	move.b #$C4,$10(A0) ;if it was less than C4, we move C4 in there
CheckOscP1:
	cmpi.b #$10,$4134B9 ;is it full way?
	bne P1TimerCheckDown
	move.b #00,$4134B9 ;reset oscillator

P1TimerCheckDown:
	cmpi.w #$0004,$413464
	bgt P1HeldDownCheckTimer
	move.w #$0000,$4134B7 ;reset it if the shot timer just restarted
	jmp HoldDownExchangeP2
	
P1HeldDownCheckTimer:
	cmpi.w #$100,$4134B7 ;is P1 helddown enough time?
	beq SwitchP1
	jmp HoldDownExchangeP2

SwitchP1:
	move.b $413412,$4134B7 ;move whatever's at 412 into the hold down spot
	move.b $413421,$413412
	move.b $4134B7,$413421
	;after they swap, set 4134B7 to arbitrary, if it's that arbitrary at start, don't allow any of this. set 4134B7 to 00 after shot fired
	move.b #$08,$4134B7
	move.w #$001E,$4134BA ; SOUND - SWITCH
	jmp HoldDownExchangeP2

TurnOffP1Down:
	move.w #0000,$4134B7 ;turn off the p1 held down byte

HoldDownExchangeP2:
	cmpi.b #$08,$4134BC ;have they swapped yet?
	beq P2TimerCheckDown ;we need to be able to reset it if the player just shot
	cmpi.b #02,$407958 ;P2 input - is down held?
	bne TurnOffP2Down
	;cmpi.l $413521,$2(A0) ;are preview and current same for P2?
	;beq PlaySound ;if so, leave
	addi.w #01,$4134BC ;P2 held down accumulator
	addi.b #01,$4134BE;cursor angle counter thingie
	cmpi.b #$0B,$4134BE
	bgt OscillatorSubP2
	addi.b #01,$413520 ;add 1 to P2 cursor angle
	cmpi.b #$3C,$10(A0) ;are we at the far right maximum
	ble.b P2TimerCheckDown ;if it's less than or equal to 3C, leave
	move.b #$3C,$10(A0) ;if it was greater than 3C, we move 3C in there
	jmp P2TimerCheckDown

OscillatorSubP2:
	move.w #$00B0,$4134BA ; SOUND - HELDDOWN OSCILLATOR
	subi.b #01,$413520
	cmpi.b #$C4,$10(A0) ;are we at the far left maximum
	bge.b CheckOscP2 ;if we are greater than or equal to C4, we leave
	move.b #$C4,$10(A0) ;if it was less than C4, we move C4 in there
CheckOscP2:
	cmpi.b #$16,$4134BE
	bne P2TimerCheckDown
	move.b #00,$4134BE

P2TimerCheckDown:
	cmpi.w #$0004,$413564
	bgt P2HeldDownCheckTimer
	move.w #$0000,$4134BC ;reset it if the shot timer just restarted
	jmp PlaySound
	
P2HeldDownCheckTimer:
	cmpi.w #$100,$4134BC ;is P2 helddown enough time?
	beq SwitchP2
	jmp PlaySound

SwitchP2:
	move.b $413512,$4134BC ;move whatever's at 412 into the hold down spot
	move.b $413521,$413512
	move.b $4134BC,$413521
	move.b #$08,$4134BC
	move.w #$001E,$4134BA ; SOUND - SWITCH
	jmp PlaySound

TurnOffP2Down:
	move.w #0000,$4134BC ;turn off the P2 held down byte

PlaySound:
	cmpi.b #00,$4134BB
	beq OriginalCodeB056E
	move.w $4134BA,-(SP) ;set the sound to be played
	move.w #0000,$4134BA ;clear the queue
	jmp $B06A2 ;go to the code where we jsr to function_sound

OriginalCodeB056E:
	btst.b #0,$41F831
	beq GoRTS
	tst.b $10(A0)
	beq GoRTS
	btst.b #$07,$10(A0)
	bmi.w GoRight
	jmp $B0650 ;go left, this is B058C

GoRTS
	jmp $B06AC

GoRight
	jmp $B0666