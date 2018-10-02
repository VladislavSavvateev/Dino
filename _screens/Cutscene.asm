; ===========================================================================
; Cutscene Screen
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
		LoadPal		Cutscene_Pal, $00, 32
		
CutsceneScreen_Loop:
		move.b	#2,($FFFFF62A).w	; set VBlank routine
		jsr		DelayProgram		; run VBlank
		
		jmp		CutsceneScreen_Loop
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