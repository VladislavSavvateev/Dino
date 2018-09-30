; ===========================================================================
; Object #02 - Digit (used in HUD)
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
		
@Display:
		jmp		DisplaySprite
		
; ---------------------------------------------------------------------------
; Digit - Graphics
; ---------------------------------------------------------------------------
Digit_Art:
		incbin	artunc\digits.bin
Digit_Map:
		include	_maps\Digits.asm