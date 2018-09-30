; =====================================================================
; Main Screen
; $FFFF1000 - action number
; $FFFF1001 - timer
; $FFFF1002 - score
; =====================================================================
MainScreen:
		lea		$C00004,a6	; load VDP
		move.w	#$8004,(a6)	; Reg#00: H-Int disabled, line counter disabled
		move.w	#$8174,(a6)	; Reg#01: DISPLAY on, V-Int enabled, DMA on, 224
		move.w	#$8230,(a6)	; Reg#02: Plan A is $C000
		move.w	#$8407,(a6)	; Reg#04: Plan B is $E000
		move.w	#$8700,(a6)	; Reg#07: backColor is 0, 0
		move.w	#$8B03,(a6)	; Reg#11: Scrolling: V(F), H(EL)
		move.w	#$9011,(a6)	; Reg#16: 512x512
		
		; load background
		LoadArtUnc	Main_Art, 1856, $0020
		LoadPal		Main_Pal, $00, 16
		LoadMapUnc	Main_Map, 3584, $E000, 1, 64, 28
		
		; load foreground
		LoadArtUnc	Logo_Art, 5888, $0760
		LoadMapUnc	Logo_Map, 2240, $C000, 59, 40, 28
		
		; load Dino
		LoadArtUnc	Dino_Art, 1600, $1E60
		
		; load digits
		LoadArtUnc	Digit_Art, 384, $24A0
		
		; play music
		move.b	#$81,d0
		jsr		PlaySound
		
@loop
		; wait for VBlank
		move.b	#2,($FFFFF62A).w
		jsr		DelayProgram

		addq.w	#2,($FFFFFE04).w	; add #1 to level timer (parallax)
		jsr		MainScreen_Parallax	; do parallax
		jsr		MainScreen_Action	; do actions
		jsr		ClearSprites		; clear sprites before creating some new
		jsr		ObjectRun			; run object routines
		
		jmp		@loop				; loop
		
MainScreen_Action:
		moveq	#0,d0					; clear d0
		move.b	$FFFF1000,d0			; move routine number
		move.w	@Actions(pc,d0.w),d0	; get routine offset
		jmp		@Actions(pc,d0.w)		; jump to the routine
; ---------------------------------------------------------------------------
@Actions:
		dc.w	@WaitForStart-@Actions	; $00
		dc.w	@LogoUp-@Actions		; $02
		dc.w	@HUD-@Actions			; $04
		dc.w	@Nothing-@Actions		; $06
; ---------------------------------------------------------------------------
@WaitForStart:
		btst	#iStart,Joypad|Press	; if Start pressed?
		beq.s	@rts					; if not, branch
		
		addq.b	#2,$FFFF1000			; next routine
		
		move.b	#1,$FFFF8000			; create Dino object
		move.w	#$58,$FFFF8008			; set start Dino's X-pos
@rts	rts
; ---------------------------------------------------------------------------
@LogoUp:		
		cmp.w	#$96,$FFFF8008			; if Dino at right X-pos?
		beq.s	@checkDino				; if yes, branch
		addq.w	#1,$FFFF8008			; if not, move Dino
		
@checkDino:
		cmp.w	#146,ScrollBuffer|Y_A	; if logo above the screen?
		beq.s	@nextRoutine			; if yes, branch
		addq.w	#1,ScrollBuffer|Y_A		; if not, move logo
		rts

@nextRoutine:	
		addq.b	#2,$FFFF1000			; next routine
		rts
; ---------------------------------------------------------------------------
@HUD:	; first digit
		move.b	#2,$FFFF8040	; create digit object
		move.w	#$188,$FFFF8048	; set X-pos
		move.w	#$90,$FFFF804C	; set Y-pos
		move.b	#4,$FFFF8060	; set digit number
		
		; second digit
		move.b	#2,$FFFF8080	; create digit object
		move.w	#$190,$FFFF8088	; set X-pos
		move.w	#$90,$FFFF808C	; set Y-pos
		move.b	#3,$FFFF80A0	; set digit number
		
		; third digit
		move.b	#2,$FFFF80C0	; create digit object
		move.w	#$198,$FFFF80C8	; set X-pos
		move.w	#$90,$FFFF80CC	; set Y-pos
		move.b	#2,$FFFF80E0	; set digit number
		
		; fourth digit
		move.b	#2,$FFFF8100	; create digit object
		move.w	#$1A0,$FFFF8108	; set X-pos
		move.w	#$90,$FFFF810C	; set Y-pos
		move.b	#1,$FFFF8120	; set digit number
		
		; fiveth digit
		move.b	#2,$FFFF8140	; create digit object
		move.w	#$1A8,$FFFF8148	; set X-pos
		move.w	#$90,$FFFF814C	; set Y-pos
		move.b	#0,$FFFF8160	; set digit number
		
		addq.b	#2,$FFFF1000	; next routine
		move.b	#6,$FFFF1001	; set timer
; ---------------------------------------------------------------------------
@Nothing:	
		subq.b	#1,$FFFF1001	; subtract #1 from timer
		bne.w	@rts			; if it isn't a zero, branch
		addq.l	#1,$FFFF1002	; add #1 to score
		move.b	#6,$FFFF1001	; set timer
		
		move.l	$FFFF1002,d0	; get score
		divu	#100,d0			; divide by 100
		lsr.l	#8,d0			; get remainder
		lsr.l	#8,d0
		bne.w	@rts			; if it isn't zero, branch
		move.b	#$A1,d0			; move ok sound id to d0
		jmp		PlaySound		; play sound				
; ---------------------------------------------------------------------------
; Parallax
; ---------------------------------------------------------------------------
MainScreen_Parallax:
		lea		@ParallaxScript,a1		; load parallax params
		jmp		ExecuteParallaxScript	; run parallax engine
; ---------------------------------------------------------------
@ParallaxScript:
		;		Mode			Speed coef.	Number of lines
		dc.w	_moving|$09,	$0100,		69
		dc.w	_moving|$07,	$0100,		24
		dc.w	_moving|$06,	$0100,		24
		dc.w	_moving|$05,	$0100,		16
		dc.w	_moving|$04,	$0100,		16
		dc.w	_moving|$03,	$0100,		16
		dc.w	_moving|$02,	$0100,		16
		dc.w	_moving,		$0100,		43
		dc.w	-1
; ---------------------------------------------------------------------------
; Main Screen - Graphics
; ---------------------------------------------------------------------------
Main_Art:
		incbin	artunc\background.bin
Main_Map:
		incbin	mapunc\background.bin
Main_Pal:
		incbin	pallete\dino.pal
		
Logo_Art:
		incbin	artunc\logo.bin
Logo_Map:
		incbin	mapunc\logo.bin