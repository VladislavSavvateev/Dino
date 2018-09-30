; This is a example of start of ROM.

		include	macro.asm												; macroses

StartOfRom:
Vectors:
		dc.l	$FFFE00,	EntryPoint,	BusError,	AddressError
		dc.l	IllegalInstr,	ZeroDivide,	ChkInstr,	TrapvInstr
		dc.l	PrivilegeViol,	Trace,	Line1010Emu,	Line1111Emu
		dc.l	ErrorExcept,	ErrorExcept,	ErrorExcept,	ErrorExcept
		dc.l	ErrorExcept,	ErrorExcept,	ErrorExcept,	ErrorExcept
		dc.l	ErrorExcept,	ErrorExcept,	ErrorExcept,	ErrorExcept
		dc.l	ErrorExcept,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	HBlank,	ErrorTrap,	VBlank,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
		dc.l	ErrorTrap,	ErrorTrap,	ErrorTrap,	ErrorTrap
Console:	dc.b 'SEGA MEGA DRIVE '										; Console Name
Date:		dc.b '(С)VS 2015.unk  '										; Release Date
Title_Local:	dc.b '                                                '	; Local Title
Title_Int:	dc.b '                                                '		; International Title
Serial:		dc.b 'SOMESERIALNMBR'										; Serial Number of cartridge
Checksum:	dc.w 0														; Checksum of ROM
		dc.b 'J               '											; Controller functions
RomStartLoc:	dc.l StartOfRom											; Offset of start of ROM
RomEndLoc:	dc.l EndOfRom-1												; Offset of end of ROM
RamStartLoc:	dc.l $FF0000											; Offset of start of ROM
RamEndLoc:	dc.l $FFFFFF												; Offset of end of ROM
SRAMSupport:	dc.l $5241F820											; SRAM value (change to $5241F820 for enable SRAM)
		dc.l $200000													; Offset of start of SRAM
		dc.l $203FFF													; Offset of end of SRAM
Notes:		dc.b '                                                    '	; Notes
Region:		dc.b 'JUE            '										; Region

; ===========================================================================
ErrorTrap:
		nop
		nop
		bra.s	ErrorTrap			; fuck the system!
; ===========================================================================
EntryPoint:
		tst.l	($A10008).l			; test port A
		bne.s	PortA_Ok			; if it OK, branch
		tst.w	($A1000C).l			; test port C

PortA_Ok:
		bne.s	PortC_Ok			; if it OK, branch
		lea	SetupValues(pc),a5		; load setup values to a5
		movem.w	(a5)+,d5-d7			; load values to d5-d7
		movem.l	(a5)+,a0-a4			; load addresses to a0-a4
		move.b	-$10FF(a1),d0		; move byte from $A10001 to d0
		andi.b	#$F,d0				; d0 And $F
		beq.s	SkipSecurity		; if it zero, branch
		move.l	#'SEGA',$2F00(a1)	; write a control word to $A13F00

SkipSecurity:
		move.w	(a4),d0				; check for working VDP
		moveq	#0,d0				; clear d0
		movea.l	d0,a6				; clear a6
		move.l	a6,usp				; set usp register to #0
		moveq	#$17,d1				; set repeat time

VDPInitLoop:
		move.b	(a5)+,d5			; move setup byte to d0
		move.w	d5,(a4)				; move setup byte from d0 to VDP
		add.w	d7,d5				; next VDP register
		dbf	d1,VDPInitLoop			; repeat all program #$17 times
		move.l	(a5)+,(a4)			; send request to VDP
		move.w	d0,(a3)				; clear screen
		move.w	d7,(a1)				; stop Z80
		move.w	d7,(a2)				; reset Z80

WaitForZ80:
		btst	d0,(a1)				; Z80 is stopped?
		bne.s	WaitForZ80			; if not, branch
		moveq	#$25,d2				; set repeat time

Z80InitLoop:
		move.b	(a5)+,(a0)+			; move command to Z80
		dbf	d2,Z80InitLoop			; repeat al program #$25 times
		move.w	d0,(a2)				; send byte to Z80
		move.w	d0,(a1)				; start Z80
		move.w	d7,(a2)				; reset Z80

ClrRAMLoop:
		move.l	d0,-(a6)			; send clear long word to RAM
		dbf	d6,ClrRAMLoop			; repeat all program #$3FFF times
		move.l	(a5)+,(a4)			; setup VDP
		move.l	(a5)+,(a4)			; setup VDP for CRAM write
		moveq	#$1F,d3				; set repeat time

ClrCRAMLoop:
		move.l	d0,(a3)				; send clear long word to CRAM
		dbf	d3,ClrCRAMLoop			; repeat all program #$1F times
		move.l	(a5)+,(a4)			; set VRAM for write
		moveq	#$13,d4				; set repeat time

ClrVDPStuff:
		move.l	d0,(a3)				; send clear long word to VRAM
		dbf	d4,ClrVDPStuff			; repeat all program #$13 times
		moveq	#3,d5				; set repeat time

PSGInitLoop:
		move.b	(a5)+,$11(a3)		; send volume level to PSG
		dbf	d5,PSGInitLoop			; repeat all program #3 times
		move.w	d0,(a2)				; clear reset address of Z80
		movem.l	(a6),d0-a6			; clear all registers
		move	#$2700,sr			; off exceptions

PortC_Ok:
		bra.s	GameProgram			; start program
; ===========================================================================
SetupValues:	dc.w $8000		; XREF: PortA_Ok
		dc.w $3FFF
		dc.w $100

		dc.l $A00000		; начало RAM Z80
		dc.l $A11100		; шина запросов Z80
		dc.l $A11200		; сброс Z80
		dc.l $C00000
		dc.l $C00004		; адрес регистров VDP

		dc.b 4,	$14, $30, $3C	; значения регистров VDP
		dc.b 7,	$6C, 0,	0
		dc.b 0,	0, $FF,	0
		dc.b $81, $37, 0, 1
		dc.b 1,	0, 0, $FF
		dc.b $FF, 0, 0,	$80

		dc.l $40000080

		dc.b $AF, 1, $D9, $1F, $11, $27, 0, $21, $26, 0, $F9, $77 ; инструкции Z80
		dc.b $ED, $B0, $DD, $E1, $FD, $E1, $ED,	$47, $ED, $4F
		dc.b $D1, $E1, $F1, 8, $D9, $C1, $D1, $E1, $F1,	$F9, $F3
		dc.b $ED, $56, $36, $E9, $E9

		dc.w $8104		; значение видеорежима VDP
		dc.w $8F02		; value	for VDP	increment
		dc.l $C0000000		; value	for CRAM write mode
		dc.l $40000010

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	($C00004).l				; test VDP
		btst	#6,($A1000D).l			; test 6 bit from $A1000D
		beq.s	CheckSumCheck			; if it zero, branch
		cmpi.l	#'init',($FFFFFFFC).w   ; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumCheck:
		lea	($FFFFFE00).w,a6
		moveq	#0,d7
		move.w	#$7F,d6

@ClearLoop:	move.l	d7,(a6)+
		dbf	d6,@ClearLoop	; repeat $7F more times
		move.b	($A10001).l,d0
		andi.b	#$C0,d0
		move.b	d0,($FFFFFFF8).w
		move.l	#'init',($FFFFFFFC).w ; set flag so checksum won't be run again

GameInit:
		lea	($FF0000).l,a6
		moveq	#0,d7
		move.w	#$3F7F-$20,d6

GameClrRAM:
		move.l	d7,(a6)+
		dbf	d6,GameClrRAM	; fill RAM ($0000-$FDFF) with $0
		bsr.w	VDPSetupGame
		bsr.w	SoundDriverLoad
		jsr		UpdateMusic
		bsr.w	JoypadInit
		move.b	#0,($FFFFF600).w ; set Game Mode to Sega Screen

; ===========================================================================
MainGameLoop:
		jsr		MainScreen
		bra.s	MainGameLoop
		

; ===========================================================================
; Main Screen
; ===========================================================================
		include _screens\Main.asm
		
; ===========================================================================
; Object Engine
; ===========================================================================
		include _obj\Routines.asm
; ===========================================================================
; Parallax Engine
; ===========================================================================
		include "_proc\Parallax Engine.asm"
; ===========================================================================
; Debugger
; ===========================================================================
		include _proc\Debugger.asm
; ===========================================================================
; VBLANK
; ===========================================================================
		include	"_proc\VBLANK.asm"

; ===========================================================================
; HBLANK
; ===========================================================================
		include	"_proc\HBLANK.asm"

; ===========================================================================
; VDP procedures
; ===========================================================================
		include	"_proc\VDP procedures.asm"

; ===========================================================================
; DMA procedures
; ===========================================================================
		include	"_proc\DMA procedures.asm"

; ===========================================================================
; Nemesis decompression	algorithm
; ===========================================================================
		include	"_proc\Nemesis Decompression.asm"
; ===========================================================================
; Debugging Modules
; ===========================================================================
		include _proc\ErrorHandler.asm
; ===========================================================================
; Enigma decompression algorithm
; ===========================================================================
		include	"_proc\Enigma Decompression.asm"

; ===========================================================================
; Kosinski decompression algorithm
; ===========================================================================
		include	"_proc\Kosinski Decompression.asm"

; ===========================================================================
; Pallet procedures
; ===========================================================================
		include	"_proc\Pallet procedures.asm"

; ===========================================================================
; Other procedures
; ===========================================================================
		include "_proc\Other procedures.asm"
; ===========================================================================
; SMPS Sound Driver by SEGA (improved by vladikcomper)
; ===========================================================================
		include	"_proc\swa.smps.asm"
		
EndOfRom:
		end