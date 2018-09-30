; ===========================================================================
; Object #02 - Digit (used in HUD)
; Additional bytes:
;	$20 - digit position
; ===========================================================================
Obj_Digit:
		moveq	#0,d0					; clear d0
		move.b	1(a0),d0				; move routine number
		move.w	@Routines(pc,d0.w),d0	; get routine offset
		jmp		@Routines(pc,d0.w)		; jump to the routine
; ---------------------------------------------------------------------------
@Routines:
		dc.w	@Main-@Routines			; $00
		dc.w	@GetNumber-@Routines	; $02
; ---------------------------------------------------------------------------
@Main:
		addq.b	#2,1(a0)			; next routine
		move.w	#293,2(a0)			; set artpointer
		move.l	#Digit_Map,4(a0)	; set mapping

@GetNumber:		
		moveq	#1,d0			; set d0 = 1
		move.l	$FFFF1002,d2	; move score
		moveq	#0,d1			; clear d1
		move.b	$20(a0),d1		; move digit number to d1
		
		beq.s	@skip			; if it's zero, branch (no need to divide)
		subq.b	#1,d1			; subtract #1 from d1
@m		mulu	#10,d0			; multiply d0 by 10
		dbf		d1,@m			; do it d1 times
		divu	d0,d2			; divide score by d0
		and.l	#$0000FFFF,d2	; get quotient part
		
@skip	divu	#10,d2			; divide score by 10
		lsr.l	#8,d2			; get remainder
		lsr.l	#8,d2			;
		move.b	d2,$10(a0)		; set remainder as frame
		jmp		DisplaySprite	; display sprite
		
; ---------------------------------------------------------------------------
; Digit - Graphics
; ---------------------------------------------------------------------------
Digit_Art:
		incbin	artunc\digits.bin
Digit_Map:
		include	_maps\Digits.asm