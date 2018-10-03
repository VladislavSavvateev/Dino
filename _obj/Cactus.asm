; ===========================================================================
; Object #4 - cactus
; Additional bytes:
;	$20 - count
;	$21 - type
;		#0 - none
;		#1 - big
;		#2 - small
;		#3 - group
;	$22 - priority flag
; ===========================================================================
Obj_Cactus:
		moveq	#0,d0
		move.b	1(a0),d0
		move.w	@Routines(pc,d0.w),d0
		jmp		@Routines(pc,d0.w)
; ---------------------------------------------------------------------------
@Routines:
		dc.w	@Main-@Routines
		dc.w	@Loop-@Routines
; ---------------------------------------------------------------------------
@Main:	
		addq.b	#2,1(a0)
		move.w	#305,2(a0)
		move.l	#Cactus_Map,4(a0)
		
		jsr		@GetRandomType
		
		tst.b	$22(a0)
		beq.s	@Secondary
		
		move.w	#$80,8(a0)
		move.w	#$80,$C(a0)
		
		jmp		@Loop
		
@Secondary:
		move.w	-52(a0),$C(a0)
		move.w	-56(a0),8(a0)
		add.w	#16,8(a0)
; ---------------------------------------------------------------------------
@Loop:
		jmp		DisplaySprite
; ---------------------------------------------------------------------------
@GetRandomType:
		jsr		RandomNumber
		and.l	#3,d0
		move.b	d0,$21(a0)
		add.l	d0,d0
		move.w	@Types(pc,d0.w),d0
		jmp		@Types(pc,d0.w)
; ---------------------------------------------------------------------------
@Types:
		dc.w	@None-@Types
		dc.w	@Big-@Types
		dc.w	@Small-@Types
		dc.w	@Group-@Types
; ---------------------------------------------------------------------------
@None:
		rts
; ---------------------------------------------------------------------------
@Big:
		jsr		RandomNumber
		and.l	#1,d0
		add.l	#1,d0
		move.b	d0,$10(a0)
		
		tst.b	$22(a0)
		beq.s	@cc
		move.b	#2,$20(a0)	
		
@cc		tst.b	$20(a0)
		beq.s	@rts
		
		lea		$40(a0),a1		; load next cactus
		move.b	#4,(a1)			; set id
		move.b	$20(a0),$20(a1)	; copy count
		sub.b	#1,$20(a1)		; subtract count
		move.b	#0,$22(a1)
		
@rts	rts
; ---------------------------------------------------------------------------
@Small:
		jsr		RandomNumber
		and.l	#3,d0
		add.l	#4,d0
		move.b	d0,$10(a0)
		
		tst.b	$22(a0)
		beq.s	@Scc
		move.b	#2,$20(a0)	
		
@Scc	tst.b	$20(a0)
		beq.s	@rts
		
		lea		$40(a0),a1		; load next cactus
		move.b	#4,(a1)			; set id
		move.b	$20(a0),$20(a1)	; copy count
		sub.b	#1,$20(a1)		; subtract count
		move.b	#0,$22(a1)
		
		rts
; ---------------------------------------------------------------------------
@Group:
		tst.b	$22(a0)
		beq.s	@rts
		move.b	#3,$10(a0)
		move.b	#0,$20(a0)	
		rts
; ===========================================================================
; Cactus - Graphics
; ===========================================================================
Cactus_Art:
		incbin	artunc\cactus.bin
Cactus_Map:
		include	_maps\Cactus.asm