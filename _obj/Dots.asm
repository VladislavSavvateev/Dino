; ===========================================================================
; Object #3 - Dots
; Additional bytes:
;	$20 - timer (.w)
; ===========================================================================
Obj_Dots:
		moveq	#0,d0
		move.b	1(a0),d0
		move.w	@Routines(pc,d0.w),d0
		jmp		@Routines(pc,d0.w)
; ---------------------------------------------------------------------------
@Routines:
		dc.w	@Main-@Routines
		dc.w	@Loop-@Routines
		dc.w	@Delete-@Routines
; ---------------------------------------------------------------------------
@Main:
		addq.b	#2,1(a0)
		move.w	#(1<<13)+117,2(a0)
		move.l	#Dots_Map,4(a0)
		move.w	#$105,8(a0)
		move.w	#$DC,$C(a0)
		move.l	#Dots_Anim,$12(a0)
		move.b	#0,$11(a0)
		move.b	#2,$16(a0)
		move.w	#540,$20(a0)
; ---------------------------------------------------------------------------
@Loop:
		subq.w	#1,$20(a0)
		bne.s	@c
		addq.b	#2,1(a0)
		rts
		
@c		jsr		AnimateSprite
		jmp		DisplaySprite
; ---------------------------------------------------------------------------		
@Delete:
		jsr		DeleteObject
		lea		-$40(a0),a0
		move.b	#1,(a0)
		move.w	#$10C,8(a0)
		move.w	#$CE,$24(a0)
		move.b	#1,$23(a0)
		move.w	#(1<<13)+126,$26(a0)
		rts
		
; ---------------------------------------------------------------------------
; Dots - Graphics
; ---------------------------------------------------------------------------
Dots_Art:
		incbin	artunc\dots.bin
Dots_Map:
		include	_maps\Dots.asm
Dots_Anim:
		include	_anim\Dots.asm