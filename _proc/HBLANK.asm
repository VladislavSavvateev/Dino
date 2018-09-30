; ---------------------------------------------------------------------------
; Subroutine which runs during Horizontal Interruption
; Moves pallets from the RAM to CRAM
; ---------------------------------------------------------------------------

;PalToCRAM:
HBlank:
		move	#$2700,sr	; отключение прерываний
		tst.w	($FFFFF644).w	; was the pallete set to change?
		beq.s	HBlank_Rts	; если нет, бранч
		move.w	#0,($FFFFF644).w
		movem.l	a0-a1,-(sp)	; move registers to the stack
		lea	($C00000).l,a1
		lea	($FFFFFA80).w,a0 ; load	pallet from RAM
		move.l	#$C0000000,4(a1) ; установка VDP на запись в CRAM
		move.l	(a0)+,(a1)	; move pallet to CRAM
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.w	#$8ADF,4(a1)
		movem.l	(sp)+,a0-a1	; load saved registers from the stack
		tst.b	($FFFFF64F).w
		bne.s	loc_119E

HBlank_Rts:
		rte
; ===========================================================================

loc_119E:				; XREF: PalToCRAM
		clr.b	($FFFFF64F).w
		movem.l	d0-a6,-(sp)	; move all the registers to the stack
		jsr	UpdateMusic
		movem.l	(sp)+,d0-a6	; load saved registers from the stack
		rte	
; End of function PalToCRAM
