; ===========================================================================
; Savok Screen
; ===========================================================================

CycOffset	equ	$FFFFD003	; 1 byte
CycStop		equ	$FFFFD004	; 1 byte

DeformPower	equ	$FFFFD005	; 1 byte
EndOfSvk	equ	$FFFFD006	; 1 byte

Routine 	equ	$FFFFD007	; 1 byte
Timer1		equ $FFFFD008	; 1 byte
Timer2		equ	$FFFFD009	; 1 byte

SavokScreen:
		lea		($C00004).l,a6      			; load command VDP
        move.w  #$8004,(a6)         			; mode register 1 setting
        move.w	#$8174,(a6)						; enable display
		move.w  #$8230,(a6)         			; map Plane A setting ($C000)
        move.w  #$8407,(a6)         			; map Plane B setting
        move.w  #$8700,(a6)         			; backdrop color setting
        move.w  #$8B07,(a6)         			; mode register 3 setting
        move.w  #$9001,(a6)         			; plane size setting
        move.w  #$9200,(a6)         			; window vertical position
        clr.b   ($FFFFF64E).w					; clear $FFFFF64E
        jsr		ClearScreen         			; clear the actual screen
		
		LoadArtUnc	Savok_Art, 2560, $0020
		LoadMapUnc	Savok_Map, 2240, $C000, 1, 320/8, 224/8
		LoadPal		Savok_Pal, $80, 16
		
		move.b	#3,Timer1			; set timer
		
SavokScreen_Loop:
		move.b	#2,($FFFFF62A).w	; set VBlank routine
		jsr		DelayProgram		; run VBlank
		
		jsr		@CheckStart		; check start
		jsr		Svk_Act			; do actions
		jsr		Svk_PalletCycle	; do pallet cycle
		jsr		Svk_PalletFade	; do palelt fade
		
		tst.b	EndOfSvk			; it's end?
		beq.s	SavokScreen_Loop	; if not, branch
		
		jmp		ClearScrollRAM		; clear scroll RAM
; ---------------------------------------------------------------------------
@CheckStart:
		btst	#iStart,Joypad|Press	; start is pressed?
		beq.s	@rts					; is not, branch
		
		cmp.b	#8,Routine	; needed routine is already running?
		bge.s	@rts		; if yes, branch
		
		move.b	#8,Routine	; set needed routine
		move.b	#4,Timer1	; set timers
		move.b	#2,Timer2		
		
		jmp		ClearReservedPallete		
@rts	rts
; ---------------------------------------------------------------------------
Svk_Act:
		moveq	#0,d0					; clear routine number
		move.b	Routine,d0				; get routine number
		move.w	@Routines(pc,d0.w),d0	; get routine offset
		jmp		@Routines(pc,d0.w)		; jump to the routine
; ---------------------------------------------------------------------------
@Routines:
		dc.w	Svk_FadeIn-@Routines	; $00
		dc.w	Svk_Wait-@Routines		; $02
		dc.w	Svk_rts-@Routines		; $04
		dc.w	Svk_Wait2-@Routines		; $06
		dc.w	Svk_Deform-@Routines	; $08
; ---------------------------------------------------------------------------
Svk_FadeIn:
		subq.b	#1,Timer1	; subtract #1 from timer
		beq.s	@fade		; if it's zero, branch
		rts
		
@fade	move.b	#3,Timer1	; set timer
		moveq	#15,d0		; set color count
		jsr		Pal_FadeTo	; run pallet routine
		tst.b	d3			; changes are more than zero?
		bne.s	@rts		; if yes, branch
		
		jsr		ClearReservedPallete
		addq.b	#2,Routine	; next routine
		move.b	#60,Timer1	; set timer
@rts	rts
; ---------------------------------------------------------------------------
Svk_Wait:
		sub.b	#1,Timer1	; subtract #1 from timer
		bne.s	@rts		; if it isn't zero, branch
		
		addq.b	#2,Routine	; next routine
		move.b	#2,Timer1	; set timer
		
		moveq	#$FFFFFF8B,d0	; load sample
		jsr		PlaySample		; play sample
@rts	rts
; ---------------------------------------------------------------------------
Svk_Wait2:
		sub.b	#1,Timer2	; subtract #1 from timer
		bne.s	@rts		; if it isn't zero, branch
		
		addq.b	#2,Routine	; next routine
		move.b	#2,Timer2	; set timer
@rts	rts
; ---------------------------------------------------------------------------
Svk_rts:
		move.b	#60,Timer2	; set timer
		rts
; ---------------------------------------------------------------------------
Svk_Deform:
		lea		$FFFFCD70,a0	; load parallax RAM
		moveq	#31,d2			; set line number
		
@loop:	move.w	(a0),d3			; get value
		moveq	#0,d4			; clear d4
		move.b	DeformPower,d4	; get deform power
		jsr		RandomNumber	; get random
		and.l	d4,d0			; perform AND on random by deform power
		move.b	d0,d4			; move result to d4
		
		jsr		RandomNumber	; get random
		and.l	#1,d0			; get only 0 bit
		beq.s	@cont			; if it's zero, branch
		not.w	d4				; negate d4
		
@cont	move.w	d4,(a0)+		; move d4 to parallax RAM
		lea		2(a0),a0		; load next line
		dbf		d2,@loop		; loop
		add.b	#1,DeformPower	; increase deform power
		rts
; ===========================================================================
Svk_PalletCycle:
		tst.b	CycStop	; cycle is stopped?
		bne.s	@rts	; if yes, branch
		
		cmp.b	#4,Routine	; routine bigger or equal than 4?
		bge.s	@timer		; if yes, branch
		rts
		
@timer
		subq.b	#1,Timer1	; subtract #1 from timer
		beq.s	@cyc		; if it's zero, branch
		rts
@cyc
		move.b	#2,Timer1				; set timer
		lea		Savok_PalletCycle,a0	; load cycle data
		lea		$FFFFFB06,a1			; load target pallete
		
		moveq	#0,d0			; clear d0
		move.b	CycOffset,d0	; load cycle offset
		adda.l	d0,a0			; add offset to start address
		moveq	#8,d1			; load color count
		
@loop:	cmp.l	Savok_PalletCycle+36,a0	; cycle ends?
		blt.s	@cont					; if not, branch
		suba.l	#36,a0					; start cycle from start
		move.b	#-2,CycOffset			; set offset
		
@cont	move.w	(a0)+,(a1)+	; move color from cycle data to pallete RAM
		dbf		d1,@loop	; loop
		
		add.b	#2,CycOffset	; next cycle pos
		tst.w	$FFFFFB06		; first color in cycle is black?
		bne.s	@rts			; if not, branch
		
		st.b	CycStop		; set "cycle stop" flag
		addq.b	#2,Routine	; next routine
		move.b	#4,Timer1	; set timer
@rts	rts		
; ===========================================================================
Svk_PalletFade:
		cmp.b	#8,Routine	; current routine is deformation?
		beq.s	@start		; if yes, branch
		rts
		
@start	subq.b	#1,Timer1	; subtract #1 from timer
		beq.s	@cont1		; if it's zero, branch
		rts
		
@cont1	move.b	#4,Timer1	; set timer

		move.l	#15,d0		; move color count
		jsr		Pal_FadeTo	; run pallete routine
		
		tst.b	d3			; check changes count
		bne.s	@rts		; if it's more than zero, branch
		st.b	EndOfSvk	; set "end" flag
@rts	rts
; ===========================================================================
ClearReservedPallete:
		moveq	#7,d0			; set loop count
		lea		$FFFFFB80,a0	; load reserved pallete
@cl		move.l	#0,(a0)+		; send zero to RAM
		dbf		d0,@cl			; loop
		rts
; ===========================================================================
; Graphic Data
; ===========================================================================
Savok_Art:
		incbin	"artunc\savok_logo.bin"
Savok_Map:
		incbin	"mapunc\savok_logo.bin"
Savok_Pal:
		incbin	"pallete\savok_logo.bin"
Savok_PalletCycle:
		incbin	"pallete\savok_logo_cyc.bin"