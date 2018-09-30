; =====================================================================
; ObjectRun - procedure for run object code
; Arguments:	none
; Return:		none
; =====================================================================
ObjectRun:
		lea		$FFFF8000,a0	; load object RAM
		moveq	#0,d7
		move.l	#79,d7			; set numbers of objects - 1
@loop:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	@rts
		subq.b	#1,d0
		lea		ObjectOffsets,a1
		add.w	d0,d0
		add.w	d0,d0
		adda.l	d0,a1
		movea.l	(a1),a1
		jsr		(a1)
		lea		$40(a0),a0
		dbf		d7,@loop
@rts	rts

; =====================================================================
; FindFreeObject - function for find free space in Object RAM
; Arguments:	none
; Return:		a0 - offset in RAM
; =====================================================================
FindFreeObject:
		lea		$FFFF8000,a0	; load object RAM
		moveq	#0,d7			; clear d7
		move.l	#79,d7			; set number of max objects - 1
@loop:
		moveq	#0,d0			; clear d0
		move.b	(a0),d0			; copy ID object to d0
		beq.s	@rts			; if ID = 0, exit proc
		lea		$40(a0),a0		; next object
		dbf		d7,@loop		; if it's last object, exit loop 
@rts	rts						; return

; =====================================================================
; FindFreeSprite - function for find free space in Sprite RAM
; Arguments:	none
; Return:		a1 - offset in RAM
; =====================================================================
FindFreeSprite:
		lea		$FFFFF800,a1	; load sprite RAM
		moveq	#0,d0			; clear d0
		move.l	#79,d0			; set max number of sprites
@loop:	tst.b	3(a1)			; link is zero?
		beq.s	@rts			; if yes, branch (clear sprite
								; has zero link)
		lea		8(a1),a1		; if no, load next place
		dbf		d0,@loop		; if it's last place, exit loop
@rts	rts						; return
		
; =====================================================================
; GetSpritesCount - function for getting sprites count
; Arguments:	none
; Return:		d0 - sprites count
; =====================================================================
GetSpritesCount:
		lea		$FFFF8000,a1	; load sprite RAM
		moveq	#0,d0			; set counter to zero
		move.l	#63,d1			; set max number of objects
@loop:	tst.b	(a1)			; object is zero?
		beq.s	@cont			; if yes, branch
		add.b	#1,d0			; if not, increment d0
@cont	lea		$40(a1),a1		; next object
		dbf		d1,@loop		; loop
		rts
		
; =====================================================================
; DisplaySprite - procedure for copy mapping to Sprite RAM
; Arguments:	2(a0) 	- artpointer (for shifting art)
;				4(a0) 	- mappings (for copy to RAM)
;				8(a0) 	- X-position on screen
;				$C(a0) 	- Y-position on screen
;				$10(a0)	- number of frame
; Return:		none
; =====================================================================
DisplaySprite:
		jsr		FindFreeSprite	; try to find free space for sprite
		movea.l	4(a0),a2		; load object mappings
		moveq	#0,d0			; clear d0
		move.b	$10(a0),d0		; load current frame
		add.w	d0,d0			; multiple by 2 to word
		
		; What? I used this? fuck, i just forgot about (an,dn.w)...
		
		; adda.l	d0,a2			; get offset to shift to mapping
		; move.w	(a2),d0			; get shift
		; movea.l	4(a0),a2		; load object mappings again
		; adda.l	d0,a2			; get 
		
		adda.w	(a2,d0.w),a2	; get mapping
		moveq	#0,d0			; clear d0
		move.b	(a2)+,d0		; get number of sprites
		subq.b	#1,d0			; subtract 1
@loop:
		moveq	#0,d1			; clear d1
		move.b	(a2)+,d1		; get Y-pos from mapping
		add.w	$C(a0),d1		; add Y-pos from object
		move.w	d1,(a1)+		; move Y-pos
		moveq	#0,d1			; clear d1
		move.b	(a2)+,(a1)+		; move size
		move.b	-8(a1),d1		; get link from previous sprite
		add.b	#1,d1			; increment link
		move.b	d1,(a1)+		; move link
		move.b	(a2)+,d1		; get art pointer from mapping
		lsl.w	#8,d1			; I hate Sega Genesis for his unable
		move.b	(a2)+,d1		; to read/write a words from non-odd address
		add.w	2(a0),d1		; add art pointer from object to d1
		move.w	d1,(a1)+		; move art pointer
		moveq	#0,d1			; clear d1
		move.b	(a2)+,d1		; get X-pos from mapping
		add.w	$8(a0),d1		; add X-pos from object
		move.w	d1,(a1)+		; move X-pos
		dbf		d0,@loop		; loop
		rts						; return
		
		
SpeedToPos:
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0	; load horizontal speed
		ext.l	d0
		asl.l	#8,d0		; multiply speed by $100
		add.l	d0,d2		; add to x-axis	position
		move.w	$12(a0),d0	; load vertical	speed
		ext.l	d0
		asl.l	#8,d0		; multiply speed by $100
		add.l	d0,d3		; add to y-axis	position
		move.l	d2,8(a0)	; update x-axis	position
		move.l	d3,$C(a0)	; update y-axis	position
		rts	
; =====================================================================
; ClearSprites - procedure for clear sprites
; Arguments:	none
; Return:		none
; =====================================================================
ClearSprites:
		lea		$FFFFF800,a0
		move.l	#79,d0
@loop:	move.l	#0,(a0)+
		move.l	#0,(a0)+
		dbf		d0,@loop
		rts
		
; =====================================================================
; AnimateSprite - function for animate sprite
; Arguments:	$11(a0) - number of animation
;				$12(a0) - offset of animation
;				$16(a0) - status of animation
;				$17(a0) - value of animation timer
;				$18(a0) - setup of animation timer
;				$19(a0) - current byte of animation
; Return:		$10(a0) - new frame
;				$16(a0) - new status of animation
;				$17(a0) - value of animation timer
; =====================================================================
AnimateSprite:
		cmp.b	#1,$16(a0)		; animation is stopped?
		bne.s	@check_load		; if not, check load
		rts						; if yes, GTFO
		
@check_load:
		cmp.b	#2,$16(a0)		; need to load new animation?
		bne.s	@check_timer	; if not, check timer
		move.b	#0,$19(a0)		; set first byte of animation
		movea.l	$12(a0),a1		; load animation to a1
		moveq	#0,d0			; clear	d0
		move.b	$11(a0),d0		; get animation number
		add.w	d0,d0			; double it!
		adda.w	(a1,d0.w),a1	; get animation
		move.b	(a1),$18(a0)	; set new setup of timer
		jmp		@change_frame	; get a frame
		
@check_timer:
		sub.b	#1,$17(a0)		; subtract 1 from timer
		beq.s	@change_frame	; if timer is over, change frame
		rts						; return
		
@change_frame:
		moveq	#0,d0			; clear d0
		move.b	$11(a0),d0		; get number of animation
		add.w	d0,d0			; multiple d0 to 2
		movea.l	$12(a0),a1		; load animation to a1
		adda.w	(a1,d0.w),a1	; get animation
		add.b	#1,$19(a0)		; next byte of animation
		moveq	#0,d0			; clear d0
		move.b	$19(a0),d0		; get number of byte
		adda.w	d0,a1			; get this byte
		tst.b	(a1)			; it's reserved bytes?
		bmi.s	@commands		; if yes, branch
		move.b	(a1),$10(a0)	; set new frame
		move.b	$18(a0),$17(a0)	; set new timer value
		move.b	#0,$16(a0)		; set normal status of animation
		rts						; return
		
@commands:
		cmp.b	#$F0,(a1)		; it's "end byte"?
		bne.s	@loop_byte		; if not, branch
		move.b	#1,$16(a0)		; set stop status of animation
		rts						; return
		
@loop_byte:
		cmp.b	#$F1,(a1)		; it's "loop byte"?
		bne.s	@rts			; if not, branch
		move.b	#0,$19(a0)		; set first byte
		jmp		@change_frame	; get new frame

@rts	rts						; return

@setup:
		
		
; =====================================================================
		
ObjectOffsets:
		dc.l	Obj_Dino
		
; =====================================================================
; Object Includes
; =====================================================================
		include	_obj\Dino.asm
		include _obj\Digit.asm