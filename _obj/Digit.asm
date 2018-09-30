; ===========================================================================
; Object #02 - Digit (used in HUD)
; Additional bytes:
;	$20 - digit position
; ===========================================================================
Obj_Digit:
		moveq	#0,d0
		move.b	1(a0),d0
		move.w	@Routines(pc,d0.w),d0
		jmp		@Routines(pc,d0.w)
; ---------------------------------------------------------------------------
@Routines:
		dc.w	@Main-@Routines
		dc.w	@Display-@Routines
; ---------------------------------------------------------------------------
@Main:
		addq.b	#2,1(a0)
		move.w	#293,2(a0)
		move.l	#Digit_Map,4(a0)
		
		; get sprite by number
		moveq	#10,d0
		moveq	#0,d1
		move.b	$20(a0),d1
		move.l	$FFFF1002,d2
		mulu	d1,d0
		beq.s	@skip
		divu	d0,d2
@skip	and.l	#$0000FFFF,d2
		divu	#10,d2
		lsr.l	#8,d2		
		lsr.l	#8,d2		
		move.b	d2,$10(a0)
		

@Display:
		jmp		DisplaySprite
		
; ---------------------------------------------------------------------------
; Digit - Graphics
; ---------------------------------------------------------------------------
Digit_Art:
		incbin	artunc\digits.bin
Digit_Map:
		include	_maps\Digits.asm