; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:				; XREF: GameClrRAM
		move.w	#$100,($A11100).l ; остановка Z80

Joypad_WaitZ80:
		btst	#0,($A11100).l	; Z80 остановлен?
		bne.s	Joypad_WaitZ80	; если нет, бранч
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (extra)
		move.w	#0,($A11100).l	; запуск Z80
		rts	
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(Joypad).w,a0	; address where joypad states are written
		lea	($A10003).l,a1	; first	joypad port
		bsr.s	Joypad_Read	; do the first joypad
		addq.w	#2,a1		; do the second	joypad

Joypad_Read:
		move.b	#0,(a1)
		nop	
		nop	
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop	
		nop
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts	
; End of function ReadJoypads

; ---------------------------------------------------------------------------
; Subroutine to	delay the program by ($FFFFF62A) frames
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DelayProgram:				; XREF: PauseGame
		move	#$2300,sr	; отключение прерываний
	@wait:	tst.b	($FFFFF62A).w	; has VBlank routine finished?
		bne.s	@wait		; если нет, бранч
		rts	
; End of function DelayProgram

; ---------------------------------------------------------------------------
; Subroutine to	generate a pseudo-random number	in d0
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RandomNumber:
		move.l	($FFFFF636).w,d1
		bne.s	loc_29C0
		move.l	#$2A6D365A,d1

loc_29C0:
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1
		move.l	d1,($FFFFF636).w
		rts	
; End of function RandomNumber

; ===========================================================================
; Subroutine to calculate sine and cosine
; ===========================================================================
; Input:	d0 - Angle (0-$FF)
; Output:	d0 - Sine
;		d1 - Cosine
; ---------------------------------------------------------------------------

CalcSine:
		andi.w	#$FF,d0
		add.w	d0,d0
		addi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d1	; get cosine
		subi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d0	; get sine
		rts	

Sine_Data:	incbin	misc\sinewave.bin	; pre-calculated Sine values

; End of function CalcSine

; ===========================================================================
; Subroutine calculate an angle
; ===========================================================================
; Input:	d1 - X-axis distance
;		d2 - Y-axis distance
; Output:	d0 - Angle
; ---------------------------------------------------------------------------

CalcAngle:
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	loc_2D04
		move.w	d2,d4
		tst.w	d3
		bpl.w	loc_2CC2
		neg.w	d3

loc_2CC2:
		tst.w	d4
		bpl.w	loc_2CCA
		neg.w	d4

loc_2CCA:
		cmp.w	d3,d4
		bcc.w	loc_2CDC
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	Angle_Data(pc,d4.w),d0
		bra.s	loc_2CE6
; ===========================================================================

loc_2CDC:				; XREF: CalcAngle
		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	Angle_Data(pc,d3.w),d0

loc_2CE6:
		tst.w	d1
		bpl.w	loc_2CF2
		neg.w	d0
		addi.w	#$80,d0

loc_2CF2:
		tst.w	d2
		bpl.w	loc_2CFE
		neg.w	d0
		addi.w	#$100,d0

loc_2CFE:
		movem.l	(sp)+,d3-d4
		rts	
; ===========================================================================

loc_2D04:				; XREF: CalcAngle
		move.w	#$40,d0
		movem.l	(sp)+,d3-d4
		rts	
; End of function CalcAngle

; ===========================================================================

Angle_Data:	incbin	misc\angles.bin

; ===========================================================================
; ===========================================================================
; Subroutine to clear Scroll RAM Buffer
; Note:	corrupt the d7 content
; ===========================================================================
ClearScrollRAM:
		lea		$FFFFCC00,a0
		move.l	#223,d7
@loop:	move.l	#0,(a0)+
		dbf		d7,@loop
		rts