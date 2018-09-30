; ---------------------------------------------------------------------------
; Routine for fading to pallete
; ---------------------------------------------------------------------------
Pal_FadeTo:
		lea		$FFFFFB00,a1	; load primary pallete
		lea		$FFFFFB80,a2	; load reserved pallete
		moveq	#0,d1
		moveq	#0,d2		
		moveq	#0,d3			; clear change counter
		
@loop:	move.b	(a1),d1		; get current B
		move.b	(a2)+,d2	; get reserved B
		cmp.w	d1,d2		; they're equal?
		beq.s	@G			; if yes, branch
		bpl.s	@B_Greater	; if less, branch
		add.b	#1,d3		; increment change counter
		sub.b	#2,d1		; subtract #2 from current
		jmp		@G			; jump
		
@B_Greater
		add.b	#2,d1		; add #2 to current
		add.b	#1,d3		; increment change counter
		
@G		move.b	d1,(a1)+	; send B
		move.b	(a1),d1		; get current GR
		move.b	(a2),d2		; get reserved GR
		and.b	#$E0,d1		; get only G
		and.b	#$E0,d2		;
		
		cmp.w	d1,d2		; they're equal?
		beq.s	@R			; if yes, branch
		bpl.s	@G_Greater	; if less, branch
		add.b	#1,d3		; increment change counter
		sub.b	#$20,d1		; subtract #2 from current
		jmp		@R			; jump
		
@G_Greater
		add.b	#$20,d1		; add #2 to current
		add.b	#1,d3		; increment change counter
		
@R		move.b	d1,d4		; save G
		move.b	(a1),d1		; get current GR
		move.b	(a2)+,d2	; get reserved GR
		and.b	#$E,d1		; get only R
		and.b	#$E,d2		;
		
		cmp.w	d1,d2		; they're equal?
		beq.s	@dbf		; if yes, branch
		bpl.s	@R_Greater	; if less, branch
		add.b	#1,d3		; increment change counter
		sub.b	#2,d1		; subtract #2 from current
		jmp		@dbf		; jump
		
@R_Greater
		add.b	#2,d1		; add #2 to current
		add.b	#1,d3		; increment change counter
		
@dbf	add.b	d1,d4		; add R to G
		move.b	d4,(a1)+	; send GR to current
		dbf		d0,@loop	; loop
		rts