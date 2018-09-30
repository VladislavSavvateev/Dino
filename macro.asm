
; =============================================================
; Joypad button indexes & values
; For theld and tpress macros
; -------------------------------------------------------------

; $FFFFF602	= SonicControl|Held
; $FFFFF603	= SonicControl|Press
; $FFFFF604	= Joypad|Held
; $FFFFF605	= Joypad|Press  


_normal = $0000
_moving	= $0200
_linear = $0400

SonicControl	equ	$FFFFF602
Joypad		equ	$FFFFF604

ScrollBuffer	equ	$FFFFF616
Y_A			equ		0
Y_B			equ		2
X_A			equ		-$2A16
X_B			equ		-$2A14

Held		equ	0
Press		equ	1

iStart		equ 	7
iA		equ 	6
iC		equ 	5
iB		equ 	4
iRight		equ 	3
iLeft		equ 	2
iDown		equ 	1
iUp		equ 	0

Start		equ 	1<<7
A		equ 	1<<6
C		equ 	1<<5
B		equ 	1<<4
Right		equ 	1<<3
Left		equ 	1<<2
Down		equ 	1<<1
Up		equ 	1

; =============================================================
; Macro to check button presses
; Arguments:	1 - buttons to check
;		2 - bitfield to check
; -------------------------------------------------------------
tpress	macro
	move.b	(\2+1),d0
	andi.b	#\1,d0
	endm

; =============================================================
; Macro to check if buttons are held
; Arguments:	1 - buttons to check
;		2 - bitfield to check
; -------------------------------------------------------------
theld	macro
	move.b	\2,d0
	andi.b	#\1,d0
	endm

; =============================================================
; Macro to align data
; Arguments:	1 - align value
; -------------------------------------------------------------
align	macro
	cnop 0,\1
	endm

; =============================================================
; Macro to set VRAM write access
; Arguments:	1 - raw VRAM offset
;		2 - register to write access bitfield in (Optional)
; -------------------------------------------------------------
vram	macro
	if (narg=1)
		move.l	#($40000000+((\1&$3FFF)<<16)+((\1&$C000)>>14)),($C00004).l
	else
		move.l	#($40000000+((\1&$3FFF)<<16)+((\1&$C000)>>14)),\2
	endc
	endm

; =============================================================
; Macro to raise an error in vectors
; Arguments:	1 - error number
;		2 - branch location
;		3 - if exists, adds 2 to stack pointer
; -------------------------------------------------------------
raise	macro
		move.w	#\1,(-$7FC0).w
		jmp	ErrorScreen+$38(pc)
	endm
	


; =============================================================
stopZ80		macro
 		move.w	#$100,($A11100).l
		nop
		nop
		nop

@wait\@:	btst	#0,($A11100).l
		bne.s	@wait\@
		endm

; =============================================================

startZ80	macro
		move.w	#0,($A11100).l	; start	the Z80
		endm

; =============================================================

waitYM		macro
@wait\@:	move.b	($A04000).l,d2
		btst	#7,d2
		bne.s	@wait\@
		endm
; =============================================================
; Macro to easy play DAC samples
; Arguments:	1 - track number (must be in hex!!) e.g. F; F=$8F
; -------------------------------------------------------------
PlayDAC		macro
		move.w	#$FFFFFF80,d0
		add.w	#$\1,d0
		jsr		PlaySample
		endm
; =============================================================
; Macro to easy play music and sounds
; Arguments:	1 - music or sound number
; -------------------------------------------------------------
PlaySoMu	macro
		move.b	#$\1,d0
		jsr		PlaySound
		endm
; =============================================================
; Macro to simple fade out music
; Arguments:	not used
; -------------------------------------------------------------
FadeOut		macro
		move.b	#$E0,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to simple stop music
; Arguments:	not used
; -------------------------------------------------------------
StopMusic	macro
		move.b	#$E4,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to simple speed up music
; Arguments:	not used
; -------------------------------------------------------------
SpeedUp		macro
		move.b	#$E2,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to simple back music to normal speed
; Arguments:	not used
; -------------------------------------------------------------
BackToNormalSpeed	macro
		move.b	#$E3,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to set object VRAM settings
; Arguments:	1 - VRAM pointer
;				2 - pallet row
;				3 - reverse
; -------------------------------------------------------------
SetVRAM	macro
		move.w	(((\2+\3)*$1000)+\1),$4(a0)
		endm
; =============================================================
; Macro to load art
; Arguments:	artoff - art offset (Nemesis)
;				vram_art - where store art in VRAM
;				paloff - pallet offset
;				palshft - pallet RAM shift
;				palclr - how many colors transfer
;				mapoff - map offset (Enigma)
;				enidec_param - parameter of EniDec
;				vram_map - where store map in VRAM
;				cols - cols
;				rows - rows
; -------------------------------------------------------------
LoadArt	macro artoff, vram_art, paloff, palshft, palclr, mapoff, enidec_param, vram_map, cols, rows
		vram	\vram_art
        lea		\artoff,a0
        jsr		NemDec
		
		lea		\paloff,a1
		lea		$FFFFFB00+\palshft,a2
		moveq	#\palclr-1,d0
@loop\@:
		move.w	(a1)+,(a2)+
		dbf		d0,@loop\@
		
        lea    	($FF0000).l,a1
        lea    	\mapoff,a0
        move.w	#\enidec_param,d0
        jsr		EniDec

		lea		($FF0000).l,a1
        vram	\vram_map,d0
        moveq   #\cols,d1
        moveq   #\rows,d2
        jsr		ShowVDPGraphics
		endm
		
LoadArtUnc	macro offset, size, vram
		move.l	#($40000000+((\vram&$3FFF)<<16)+((\vram&$C000)>>14)),($C00004).l
		move.l	#(\size/4)-1,d0
		lea		\offset,a0
@loop\@	move.l	(a0)+,$C00000
		dbf		d0,@loop\@
		endm

LoadMapUnc	macro offset, size, vram, arg, cols, rows
		lea		$FF0000,a0
		lea		\offset,a1
		move.l	#(\size/2)-1,d1
@loop\@	move.w	(a1)+,d0
		add.w	#\arg,d0
		move.w	d0,(a0)+
		dbf		d1,@loop\@

		lea		($FF0000).l,a1
        move.l	#($40000000+((\vram&$3FFF)<<16)+((\vram&$C000)>>14)),d0
        moveq   #\cols-1,d1
        moveq   #\rows-1,d2
        jsr		ShowVDPGraphics
		endm

LoadPal	macro offset, shift, colors
		lea		\offset,a0
		lea		$FFFFFB00+\shift,a1
		move.l	#\colors-1,d0
@loop\@	move.w	(a0)+,(a1)+
		dbf		d0,@loop\@
		endm