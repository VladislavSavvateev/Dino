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
		moveq	#0,d0					; clear routine counter
		move.b	1(a0),d0				; move current routine
		move.w	@Routines(pc,d0.w),d0	; get routine offset
		jmp		@Routines(pc,d0.w)		; jump to the routine
; ---------------------------------------------------------------------------
@Routines:
		dc.w	@Main-@Routines	; $00
		dc.w	@Loop-@Routines	; $02
; ---------------------------------------------------------------------------
@Main:
		addq.b	#2,1(a0)			; next routine
		move.w	#243,2(a0)			; art pointer
		;move.w	#$96,8(a0)			; X
		move.w	#$130,$C(a0)		; Y
		move.l	#Dino_Map,4(a0)		; mapping
		move.l	#Dino_Anim,$12(a0)	; animations
		move.b	#0,$11(a0)			; set run animation
		move.b	#2,$16(a0)			; load animation

@Loop:
		jsr		Obj_Dino_Control	; do control
		jsr		AnimateSprite		; animate sprite
		jmp		DisplaySprite		; display sprite
; ---------------------------------------------------------------------------
Obj_Dino_Control:
		tst.b	$22(a0)	; control is blocked?
		beq.s	@cont	; if not, branch
		rts
		
@cont	moveq	#0,d0				; clear d0
		move.b	$20(a0),d0			; get routine number
		move.w	@States(pc,d0.w),d0	; get routine offset
		jmp		@States(pc,d0.w)	; jump to the routine
; ---------------------------------------------------------------------------
@States:
		dc.w	@OnGround-@States	; $00
		dc.w	@Jumping-@States	; $02
		dc.w	@Falling-@States	; $04
		dc.w	@Ducking-@States	; $06
; ---------------------------------------------------------------------------
@OnGround:
		andi.b	#A+B+C+Up,Joypad|Press	; any of this buttons pressed?
		beq.s	@checkDuck				; if not, branch
		addq.b	#2,$20(a0)				; next routine
		move.b	#MAX_HEIGHT,$21(a0)		; set speed of jumping
		
		move.b	#1,$11(a0)	; set stand animation
		move.b	#2,$16(a0)	; load animation
		
		move.b	#$A9,d0		; move jump sound id to d0
		jmp		PlaySound	; play sound
		
@checkDuck
		btst	#iDown,Joypad|Held	; down is pressed?
		beq.s	@rts				; if not, branch
		
		move.b	#6,$20(a0)	; set Ducking state
		move.b	#3,$11(a0)	; set duck animation
		move.b	#2,$16(a0)	; load animation
@rts	rts
; ---------------------------------------------------------------------------
@Jumping:
		btst	#iDown,Joypad|Held	; down is pressed?
		bne.s	@next				; if not, branch
		
		moveq	#0,d0		; clear d0
		move.b	$21(a0),d0	; get speed of jumping
		cmp.b	#GRAVITY,d0	; it's more than gravity?
		ble.s	@ok			; if not, branch
		move.b	#GRAVITY,d0	; limit speed to gravity
		
@ok		sub.w	d0,$C(a0)	; subtract speed from Y-pos
		move.b	$21(a0),d0	; get speed of jumping
		subi.b	#1,d0		; decrement it
		bne.s	@still		; if it's more than zero, branch
		
@next	addq.b	#2,$20(a0)	; next routine
		move.b	#1,d0		
		
@still	move.b	d0,$21(a0)	; set speed of jumping
		rts
; ---------------------------------------------------------------------------
@Falling:
		moveq	#0,d0		; clear d0
		
		btst	#iDown,Joypad|Held	; down is pressed?
		beq.w	@nGr				; if no, branch
		move.b	#GRAVITY+2,d0		; MORE GRAVITY		
		jmp		@okF				; apply speed
		
@nGr	move.b	$21(a0),d0	; get speed of jumping
		cmp.b	#GRAVITY,d0	; it's more than gravity?
		ble.s	@okF		; if not, branch
		move.b	#GRAVITY,d0	; limit speed to gravity
		
@okF	add.w	d0,$C(a0)	; add speed to Y-pos
		move.b	$21(a0),d0	; get speed of jumping
		addi.b	#1,d0		; increment it
		
		cmp.w	#$130,$C(a0)	; Dino fall into ground?
		blt.w	@contF			; if not, branch
		move.w	#$130,$C(a0)	; set normal Y
		jmp		@nextF			; next routine
		
@contF	cmp.b	#MAX_HEIGHT+1,d0	; speed is equal to max_height+1?
		bne.s	@stillF				; if not, branch
		
@nextF	move.b	#0,$20(a0)	; set OnGround state
		move.b	#0,d0		
		move.b	#0,$11(a0)	; set run animation
		move.b	#2,$16(a0)	; load animation
		
@stillF	move.b	d0,$21(a0)	; set speed of jumping
		rts
; ---------------------------------------------------------------------------
@Ducking:
		btst	#iDown,Joypad|Held	; down is pressed?
		bne.w	@rts				; if yes, branch
		
		move.b	#0,$20(a0)	; set OnGround state
		move.b	#0,$11(a0)	; set run animation
		move.b	#2,$16(a0)	; load animation
		rts
; ---------------------------------------------------------------------------
; Dino - Graphics
; ---------------------------------------------------------------------------
Dino_Art:
		incbin	artunc\dino.bin
Dino_Map:
		include	_maps\Dino.asm
Dino_Anim:
		include	_anim\Dino.asm