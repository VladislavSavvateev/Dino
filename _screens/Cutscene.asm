; ===========================================================================
; Cutscene Screen
; Modem LEDs:
;	$FFFFFB1E
;	$FFFFFB22
;	$FFFFFB24
;	$FFFFFB26
;	$FFFFFB28
; ===========================================================================
CutsceneScreen:
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
		
		LoadArtUnc	Cutscene_Art, 13088, $0020
		LoadMapUnc	Cutscene_MapA, 2240, $C000, 1, 320/8, 224/8
		LoadMapUnc	Cutscene_MapB, 2240, $E000, (1<<13)+1, 320/8, 224/8
		LoadPal		Cutscene_Pal, $80, 32
		
		move.w	#270,$FFFF3000
		move.b	#0,$FFFF3002
		move.w	#120,$FFFF3004
		moveq	#$FFFFFF8C,d0
		jsr		PlaySample
		
CutsceneScreen_Loop:
		move.b	#2,($FFFFF62A).w	; set VBlank routine
		jsr		DelayProgram		; run VBlank
		
		jsr		ClearSprites
		jsr		ObjectRun
		
		jsr		@Blink
		jsr		@WaitForStart
		jsr		@Action
		
		cmp.b	#$1A,$FFFF3002
		bne.s	CutsceneScreen_Loop
		rts
; ---------------------------------------------------------------------------
@WaitForStart:
		cmp.b	#$10,$FFFF3002
		bge.w	@rts
		
		btst	#iStart,Joypad|Press
		beq.w	@rts
		move.b	#$10,$FFFF3002
		moveq	#$FFFFFF80,d0
		jmp		PlaySample
; ---------------------------------------------------------------------------
@Blink:
		cmp.b	#4,$FFFF3002
		bge.w	@rts
		
		subq.w	#1,$FFFF3000
		beq.s	@cont
		rts
		
@cont	move.w	#3,$FFFF3000
		moveq	#3,d2
		lea		$FFFFFB22,a0
@loop	jsr		RandomNumber
		btst	d2,d0
		beq.s	@off
		move.w	#$000A,(a0)+
		jmp		@dbf
@off	move.w	#$0000,(a0)+
@dbf	dbf		d2,@loop
		rts
; ---------------------------------------------------------------------------
@Action:
		moveq	#0,d0
		move.b	$FFFF3002,d0
		move.w	@Actions(pc,d0.w),d0
		jmp		@Actions(pc,d0.w)
; ---------------------------------------------------------------------------
@Actions:
		dc.w	@FadeIn-@Actions		; $00
		dc.w	@Wait-@Actions			; $02
		dc.w	@FadeIn-@Actions		; $04
		dc.w	@LoadNewArt-@Actions	; $06
		dc.w	@FadeIn-@Actions		; $08
		dc.w	@WaitForDino-@Actions	; $0A
		dc.w	@Wait-@Actions			; $0C
		dc.w	@FadeIn-@Actions		; $0E
		dc.w	@FillDinoPal-@Actions	; $10
		dc.w	@Wait-@Actions			; $12
		dc.w	@FadeIn-@Actions		; $14
		dc.w	@RemoveDino-@Actions	; $16
		dc.w	@Wait-@Actions			; $18
		dc.w	@rts-@Actions			; $1A
; ---------------------------------------------------------------------------
@FadeIn:
		subq.w	#1,$FFFF3004	; subtract #1 from timer
		beq.s	@fade			; if it's zero, branch
		rts
		
@fade	move.w	#3,$FFFF3004	; set timer
		moveq	#31,d0			; set color count
		jsr		Pal_FadeTo		; run pallet routine
		tst.b	d3				; changes are more than zero?
		bne.w	@rts			; if yes, branch
		
		jsr		ClearReservedPallete
		addq.b	#2,$FFFF3002	; next routine
		move.w	#470,$FFFF3004	; set timer
		rts
; ---------------------------------------------------------------------------
@Wait:
		subq.w	#1,$FFFF3004	; subtract #1 from timer
		beq.s	@c				; if it's zero, branch
		rts
		
@c		addq.b	#2,$FFFF3002	; next routine
		move.w	#3,$FFFF3004
		rts
; ---------------------------------------------------------------------------
@LoadNewArt:
		LoadArtUnc	Cutscene_Art2, 3712, $0020
		LoadMapUnc	Cutscene_Map2, 2240, $C000, 1, 320/8, 224/8
		LoadPal		Cutscene_Pal2, $80, 16
		
		LoadArtUnc	Dots_Art, 288, $0EA0
		LoadArtUnc	Dino_Art, 1600, $0FC0
		LoadPal		Main_Pal, $A0, 16
		
		move.b	#3,$FFFF8000
		
		addq.b	#2,$FFFF3002	; next routine
		move.w	#3,$FFFF3004	; set timer
		
		rts
; ---------------------------------------------------------------------------
@WaitForDino:
		cmp.b	#1,$FFFF8000	; first object is Dino?
		bne.s	@rts			; if not, branch
		
		addq.b	#2,$FFFF3002	; next routine
		move.w	#120,$FFFF3004	; set timer
		
		LoadPal	Main_Pal, $A0, 16
		moveq	#7,d0
		lea		$FFFFFB80,a0	; load needed line
		jmp		@FillPalWhite	; fill reserved pal with white
; ---------------------------------------------------------------------------
@FillDinoPal:		
		addq.b	#2,$FFFF3002	; next routine
		move.w	#60,$FFFF3004	; set timer
		moveq	#15,d0
		lea		$FFFFFB80,a0	; load needed line
		jmp		@FillPalWhite	; fill reserved pal with white		
; ---------------------------------------------------------------------------
@RemoveDino:
		addq.b	#2,$FFFF3002	; next routine
		move.w	#60,$FFFF3004	; set timer
		lea		$FFFF8000,a0
		jmp		DeleteObject
; ---------------------------------------------------------------------------
@rts:
		rts
; ---------------------------------------------------------------------------
@FillPalWhite:
		move.l	#$0EEE0EEE,(a0)+
		dbf		d0,@FillPalWhite
		rts
; ===========================================================================
; Graphic Data
; ===========================================================================
Cutscene_Art:
		incbin	"artunc\1frame.bin"
Cutscene_MapA:
		incbin	"mapunc\1frame_a.bin"
Cutscene_MapB:
		incbin	"mapunc\1frame_b.bin"
Cutscene_Pal:
		incbin	"pallete\1frame.bin"
Cutscene_Art2:
		incbin	"artunc\2frame.bin"
Cutscene_Map2:
		incbin	"mapunc\2frame.bin"
Cutscene_Pal2:
		incbin	"pallete\2frame.bin"