; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:				; XREF: GameClrRAM; ChecksumError
		lea	($C00004).l,a0
		lea	($C00000).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

VDP_Loop:
		move.w	(a2)+,(a0)
		dbf	d7,VDP_Loop	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,($FFFFF60C).w
		move.w	#$8ADF,($FFFFF624).w
		moveq	#0,d0
		move.l	#$C0000000,($C00004).l ; установка VDP на запись в CRAM
		move.w	#$3F,d7

VDP_ClrCRAM:
		move.w	d0,(a1)
		dbf	d7,VDP_ClrCRAM	; очистка CRAM

		clr.l	($FFFFF616).w
		clr.l	($FFFFF61A).w
		move.l	d1,-(sp)
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$94FF93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080,(a5)
		move.w	#0,($C00000).l	; очистка экрана

loc_128E:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_128E

		move.w	#$8F02,(a5)
		move.l	(sp)+,d1
		rts	
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004, $8134, $8230, $8328	; XREF: VDPSetupGame
		dc.w $8407, $857C, $8600, $8700
		dc.w $8800, $8900, $8A00, $8B00
		dc.w $8C81, $8D3F, $8E00, $8F02
		dc.w $9001, $9100, $9200

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,($C00000).l

loc_12E6:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_12E6

		move.w	#$8F02,(a5)
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000083,(a5)
		move.w	#0,($C00000).l

loc_1314:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_1314

		move.w	#$8F02,(a5)
		move.l	#0,($FFFFF616).w
		move.l	#0,($FFFFF61A).w
		lea	($FFFFF800).w,a1
		moveq	#0,d0
		move.w	#$A0,d1

loc_133A:
		move.l	d0,(a1)+
		dbf	d1,loc_133A

		lea	($FFFFCC00).w,a1
		moveq	#0,d0
		move.w	#$100,d1

loc_134A:
		move.l	d0,(a1)+
		dbf	d1,loc_134A
		rts	
; End of function ClearScreen

; ---------------------------------------------------------------------------
; Subroutine to	display	patterns via the VDP
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowVDPGraphics:			; XREF: SegaScreen; TitleScreen; SS_BGLoad
		lea	($C00000).l,a6
		move.l	#$800000,d4
;loc_142C:
VDPGfx_Loop:
		move.l	d0,4(a6)	; set VDP access
		move.w	d1,d3		; load cols counter to d3
;loc_1432:
VDPGfx_Char:
		move.w	(a1)+,(a6)	; move plane mappings to VRAM
		dbf	d3,VDPGfx_Char	; repeat for the amount of cols

		add.l	d4,d0		; switch to the next screen row
        dbf	d2,VDPGfx_Loop	; repeat for the amount of rows
		rts
; End of function ShowVDPGraphics