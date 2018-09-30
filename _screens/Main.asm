; =====================================================================
; Main Screen
; $FFFF1000 - action number
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
		move.b	#2,($FFFFF62A).w
		jsr		DelayProgram
		
		addq.w	#2,($FFFFFE04).w
		jsr		MainScreen_Parallax
		jsr		MainScreen_Action
		jsr		ClearSprites
		jsr		ObjectRun
		
		jmp		@loop
		
MainScreen_Action:
		moveq	#0,d0
		move.b	$FFFF1000,d0
		move.w	@Actions(pc,d0.w),d0
		jmp		@Actions(pc,d0.w)
; ---------------------------------------------------------------------------
@Actions:
		dc.w	@WaitForStart-@Actions
		dc.w	@LogoUp-@Actions
		dc.w	@Nothing-@Actions
; ---------------------------------------------------------------------------
@WaitForStart:
		btst	#iStart,Joypad|Press
		beq.s	@rts
		addq.b	#2,$FFFF1000
		move.b	#1,$FFFF8000
		move.w	#$58,$FFFF8008
@rts	rts
; ---------------------------------------------------------------------------
@LogoUp:		
		cmp.w	#$96,$FFFF8008
		beq.s	@checkDino
		addq.w	#1,$FFFF8008
		
@checkDino:
		cmp.w	#146,ScrollBuffer|Y_A
		beq.s	@nextRoutine
		addq.w	#1,ScrollBuffer|Y_A
		rts

@nextRoutine:	
		addq.b	#2,$FFFF1000
		rts
; ---------------------------------------------------------------------------
@Nothing:
		rts
				
; ---------------------------------------------------------------------------
; Parallax
; ---------------------------------------------------------------------------
MainScreen_Parallax:
		lea	@ParallaxScript,a1
		jmp	ExecuteParallaxScript
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