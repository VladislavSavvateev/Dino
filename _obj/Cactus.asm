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
;	$23 - secondary instances
; ===========================================================================
Obj_Cactus:
		moveq	#0,d0					; clear d0
		move.b	1(a0),d0				; get routine number
		move.w	@Routines(pc,d0.w),d0	; get routine offset
		jmp		@Routines(pc,d0.w)		; jump to the routine
; ---------------------------------------------------------------------------
@Routines:
		dc.w	@Main-@Routines	; $01
		dc.w	@Loop-@Routines	; $02
; ---------------------------------------------------------------------------
@Main:	
		addq.b	#2,1(a0)			; next routine
		move.w	#305,2(a0)			; set artpointer
		move.l	#Cactus_Map,4(a0)	; set mapping
		
		jsr		@GetRandomType	; get random type
		
		tst.b	$22(a0)		; it's primary?
		beq.s	@Secondary	; if not, branch
		
		move.w	#$80,8(a0)	; TODO: change X
		move.w	#$80,$C(a0)	; TODO: change Y
		
		jmp		@Loop	; jump
		
@Secondary:
		move.w	-52(a0),$C(a0)	; get Y from previous cactus
		move.w	-56(a0),8(a0)	; get X from previous cactus
		
		cmp.b	#1,-31(a0)	; previous cactus is big?
		beq.s	@b			; if yes, branch
		add.w	#16,8(a0)	; add small width
		jmp		@Loop		; jump
@b		add.w	#24,8(a0)	; add big width
; ---------------------------------------------------------------------------
@Loop:
		jmp		DisplaySprite	; display sprite
; ---------------------------------------------------------------------------
@GetRandomType:
		jsr		RandomNumber	; get random
		and.l	#3,d0			; get only two bits
		move.b	d0,$21(a0)		; move type
		
		add.l	d0,d0				; multiply by two
		move.w	@Types(pc,d0.w),d0	; get type offset
		jmp		@Types(pc,d0.w)		; jump to the type routine
; ---------------------------------------------------------------------------
@Types:
		dc.w	@None-@Types	; $00
		dc.w	@Big-@Types		; $02
		dc.w	@Small-@Types	; $04
		dc.w	@Group-@Types	; $06
; ---------------------------------------------------------------------------
@None:
		jmp		DeleteObject	; if it's none, delete object
; ---------------------------------------------------------------------------
@Big:
		jsr		RandomNumber	; get random number
		and.l	#1,d0			; get only first bit
		add.l	#1,d0			; add #1
		move.b	d0,$10(a0)		; move to frame byte
		
		jmp		@MoveToNext		; move to next cactus
; ---------------------------------------------------------------------------
@Small:
		jsr		RandomNumber	; get random number
		and.l	#3,d0			; get only two bits
		add.l	#4,d0			; add #4
		move.b	d0,$10(a0)		; move to frame byte
		
		jmp		@MoveToNext		; move to next cactus
; ---------------------------------------------------------------------------
@Group:
		tst.b	$22(a0)	; it's primamy?
		beq.s	@None	; if not, branch
		
		move.b	#3,$10(a0)	; move group cactus
		move.b	#0,$20(a0)	; it's last cactus!
@rts	rts
; ---------------------------------------------------------------------------
@MoveToNext:
		tst.b	$22(a0)		; it's primary?
		beq.s	@cc			; if not, branch
		move.b	#2,$20(a0)	; set counter
		
@cc		tst.b	$20(a0)	; it's last cactus?
		beq.s	@rts	; if yes, branch
		
		lea		$40(a0),a1		; load next cactus
		move.b	#4,(a1)			; set id
		move.b	$20(a0),$20(a1)	; copy count
		sub.b	#1,$20(a1)		; subtract count
		move.b	#0,$22(a1)		; it's not primary
		
		rts
; ===========================================================================
; Cactus - Graphics
; ===========================================================================
Cactus_Art:
		incbin	artunc\cactus.bin
Cactus_Map:
		include	_maps\Cactus.asm