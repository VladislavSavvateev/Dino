; ===========================================================================
; Object #01 - Dino
; Start position:
;	X - $96
;	Y - $130
; Additional Byte:
;	$20 - state
;		#0 - on ground
;		#1 - jumping
;		#2 - falling down
;	$21 - vertical speed
;	$22 - "control block" flag
; ===========================================================================
GRAVITY equ 9
MAX_HEIGHT equ 18

Obj_Dino:
		moveq	#0,d0							; clear routine counter
		move.b	1(a0),d0						; move current routine
		move.w	Obj_Dino_Routines(pc,d0.w),d0	; get routine offset
		jmp		Obj_Dino_Routines(pc,d0.w)		; jump to the routine
; ---------------------------------------------------------------------------
Obj_Dino_Routines:
		dc.w	Obj_Dino_Main-Obj_Dino_Routines
		dc.w	Obj_Dino_Loop-Obj_Dino_Routines
; ---------------------------------------------------------------------------
Obj_Dino_Main:
		addq.b	#2,1(a0)			; next routine
		move.w	#243,2(a0)			; art pointer
		;move.w	#$96,8(a0)			; X
		move.w	#$130,$C(a0)		; Y
		move.l	#Dino_Map,4(a0)		; mapping
		move.l	#Dino_Anim,$12(a0)	; animations
		move.b	#0,$11(a0)			; set run animation
		move.b	#2,$16(a0)			; load animation

Obj_Dino_Loop:
		jsr		AnimateSprite
		jsr		Obj_Dino_Control
		jmp		DisplaySprite	; display sprite
		
Obj_Dino_Control:
		tst.b	$22(a0)
		beq.s	@cont
		rts
		
@cont	moveq	#0,d0
		move.b	$20(a0),d0
		move.w	Obj_Dino_Control_States(pc,d0.w),d0
		jmp		Obj_Dino_Control_States(pc,d0.w)
; ---------------------------------------------------------------------------
Obj_Dino_Control_States:
		dc.w	Obj_Dino_Control_OnGround-Obj_Dino_Control_States
		dc.w	Obj_Dino_Control_Jumping-Obj_Dino_Control_States
		dc.w	Obj_Dino_Control_Falling-Obj_Dino_Control_States
; ---------------------------------------------------------------------------
Obj_Dino_Control_OnGround:
		andi.b	#A+B+C+Up,Joypad|Press
		beq.s	@rts
		addq.b	#2,$20(a0)
		move.b	#MAX_HEIGHT,$21(a0)
		
		move.b	#1,$11(a0)			; set stand animation
		move.b	#2,$16(a0)			; load animation
@rts	rts
; ---------------------------------------------------------------------------
Obj_Dino_Control_Jumping:
		moveq	#0,d0
		move.b	$21(a0),d0
		cmp.b	#GRAVITY,d0
		ble.s	@ok
		move.b	#GRAVITY,d0
@ok		sub.w	d0,$C(a0)
		move.b	$21(a0),d0
		subi.b	#1,d0
		bne.s	@still
		addq.b	#2,$20(a0)
		move.b	#1,d0
@still	move.b	d0,$21(a0)
		rts
; ---------------------------------------------------------------------------
Obj_Dino_Control_Falling:
		moveq	#0,d0
		move.b	$21(a0),d0
		cmp.b	#GRAVITY,d0
		ble.s	@ok
		move.b	#GRAVITY,d0
@ok		add.w	d0,$C(a0)
		move.b	$21(a0),d0
		addi.b	#1,d0
		cmp.b	#MAX_HEIGHT+1,d0
		bne.s	@still
		move.b	#0,$20(a0)
		move.b	#0,d0
		move.b	#0,$11(a0)			; set run animation
		move.b	#2,$16(a0)			; load animation
@still	move.b	d0,$21(a0)
		rts
		
; ---------------------------------------------------------------------------
; Dino - Graphics
; ---------------------------------------------------------------------------
Dino_Art:
		incbin	artunc\dino.bin
Dino_Pal:
		incbin	pallete\dino.pal
Dino_Map:
		include	_maps\Dino.asm
Dino_Anim:
		include	_anim\Dino.asm