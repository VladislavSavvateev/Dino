; ===========================================================================
; Subroutine that runs during Vertical Interruption
; ===========================================================================

;loc_B10:
VBlank:					; XREF: Vectors
		movem.l	d0-a6,-(sp)	; save all the registers to the stack
		tst.b	($FFFFF62A).w	; is VBlank routine set to #0?
		beq.s	VBlank_Sub00	; if yes, branch
		move.w	($C00004).l,d0
		move.l	#$40000010,($C00004).l
		move.l	($FFFFF616).w,($C00000).l
		btst	#6,($FFFFFFF8).w ; is Sega PAL (European)?
		beq.s	loc_B42		; если нет, бранч
		move.w	#$700,d0
		dbf	d0,*		; delay processor

loc_B42:
		move.b	($FFFFF62A).w,d0 ; load VBlank routine number
		move.b	#0,($FFFFF62A).w ; clear it
		move.w	#1,($FFFFF644).w
		andi.w	#$3E,d0
		move.w	VBlank_Routines(pc,d0.w),d0
		jsr	VBlank_Routines(pc,d0.w)

loc_B5E:				; XREF: VBlank_Sub00
		jsr	UpdateMusic

loc_B64:				; XREF: loc_D50
		addq.l	#1,($FFFFFE0C).w
		movem.l	(sp)+,d0-a6	; load saved registers from the stack
		rte

; ===========================================================================
;off_B6E:
VBlank_Routines:
		dc.w VBlank_Sub00-VBlank_Routines ; $00
		dc.w VBlank_Sub02-VBlank_Routines ; $02
		dc.w VBlank_Sub04-VBlank_Routines ; $04
		dc.w VBlank_Sub06-VBlank_Routines ; $06
		dc.w VBlank_Sub08-VBlank_Routines ; $08
		dc.w VBlank_Sub0A-VBlank_Routines ; $0A
		dc.w VBlank_Sub0C-VBlank_Routines ; $0C
		dc.w VBlank_Sub0E-VBlank_Routines ; $0E
		dc.w VBlank_Sub10-VBlank_Routines ; $10
		dc.w VBlank_Sub12-VBlank_Routines ; $12
		dc.w VBlank_Sub14-VBlank_Routines ; $14
		dc.w VBlank_Sub16-VBlank_Routines ; $16
		dc.w VBlank_Sub0C-VBlank_Routines ; $18
; ===========================================================================

;loc_B88:				; XREF: VBlank; VBlank_Routines
VBlank_Sub00:
		cmpi.b	#$8C,($FFFFF600).w	; is mode pre-Level?
		beq.s	loc_B9A			; if yes, branch
		cmpi.b	#$C,($FFFFF600).w	; is mode Level?
		bne.w	loc_B5E			; if yes, branch

loc_B9A:
		cmpi.b	#1,($FFFFFE10).w	; is level LZ ?
		bne.w	loc_B5E			; если нет, бранч
		move.w	($C00004).l,d0
		btst	#6,($FFFFFFF8).w	; is Sega PAL (European)?
		beq.s	loc_BBA			; если нет, бранч
		move.w	#$700,d0
		dbf	d0,*			; delay processor

loc_BBA:
		move.w	#1,($FFFFF644).w	; enable HBlank
;		move.w	#$100,($A11100).l
;
;loc_BC8:
;		btst	#0,($A11100).l
;		bne.s	loc_BC8
		tst.b	($FFFFF64E).w		; is water above top of screen?
		bne.s	loc_BFE			; if yes, branch
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_C22
; ===========================================================================

loc_BFE:				; XREF: loc_BC8
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_C22:				; XREF: loc_BC8
		move.w	($FFFFF624).w,(a5)
;		move.w	#0,($A11100).l
		bra.w	loc_B5E
; ===========================================================================

;loc_C32:
VBlank_Sub02:				; XREF: VBlank_Routines
		bsr.w	sub_106E

;loc_F9A:
VBlank_Sub14:				; XREF: VBlank_Routines
		tst.w	($FFFFF614).w
		beq.w	locret_C42
		subq.w	#1,($FFFFF614).w

locret_C42:
		rts	
; ===========================================================================

;loc_C44:
VBlank_Sub04:				; XREF: VBlank_Routines
		bsr.w	sub_106E
		tst.w	($FFFFF614).w		; is there time	left on	the demo?
		beq.w	locret_C5C		; if time is over, branch
		subq.w	#1,($FFFFF614).w	; subtract 1 from time left

locret_C5C:
		rts	
; ===========================================================================

;loc_C5E:
VBlank_Sub06:				; XREF: VBlank_Routines
		bsr.w	sub_106E
		rts
; ===========================================================================

;loc_C64:
VBlank_Sub10:				; XREF: VBlank_Routines
		cmpi.b	#$10,($FFFFF600).w ; is	game mode = $10	(special stage)	?
		beq.w	VBlank_Sub0A		; if yes, branch

;loc_C5E:
VBlank_Sub08:				; XREF: VBlank_Routines
;		move.w	#$100,($A11100).l ; остановка Z80
;
;loc_C76:
;		btst	#0,($A11100).l	; has Z80 stopped?
;		bne.s	loc_C76		; если нет, бранч
		bsr.w	ReadJoypads
		tst.b	($FFFFF64E).w
		bne.s	loc_CB0
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_CD4
; ===========================================================================

loc_CB0:				; XREF: loc_C76
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_CD4:				; XREF: loc_C76
		move.w	($FFFFF624).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		jsr	(ProcessDMAQueue).l

loc_D50:
		movem.l	($FFFFF700).w,d0-d7
		movem.l	d0-d7,($FFFFFF10).w
		movem.l	($FFFFF754).w,d0-d1
		movem.l	d0-d1,($FFFFFF30).w
		move.b	#1,($FFFFF64F).w
		addq.l	#4,sp
		bra.w	loc_B64

VBlank_Sub0A:				; XREF: VBlank_Routines
;		move.w	#$100,($A11100).l ; остановка Z80
;
;loc_DAE:
;		btst	#0,($A11100).l	; has Z80 stopped?
;		bne.s	loc_DAE		; если нет, бранч
		bsr.w	ReadJoypads
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
;		move.w	#0,($A11100).l
		jsr	ProcessDMAQueue

loc_E64:
		tst.w	($FFFFF614).w
		beq.w	locret_E70
		subq.w	#1,($FFFFF614).w

locret_E70:
		rts	
; ===========================================================================

;loc_E72:
VBlank_Sub0C:				; XREF: VBlank_Routines
;		move.w	#$100,($A11100).l ; остановка Z80
;
;loc_E7A:
;		btst	#0,($A11100).l	; has Z80 stopped?
;		bne.s	loc_E7A		; если нет, бранч
		bsr.w	ReadJoypads
		tst.b	($FFFFF64E).w
		bne.s	loc_EB4
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_ED8
; ===========================================================================

loc_EB4:				; XREF: loc_E7A
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_ED8:				; XREF: loc_E7A
		move.w	($FFFFF624).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)

loc_EEE:
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		jsr	ProcessDMAQueue

loc_F54:
;		move.w	#0,($A11100).l	; запуск Z80
		movem.l	($FFFFF700).w,d0-d7
		movem.l	d0-d7,($FFFFFF10).w
		movem.l	($FFFFF754).w,d0-d1
		movem.l	d0-d1,($FFFFFF30).w
		rts	
; ===========================================================================

;loc_F8A:
VBlank_Sub0E:				; XREF: VBlank_Routines
		bsr.w	sub_106E
		addq.b	#1,($FFFFF628).w
		move.b	#$E,($FFFFF62A).w
		rts	
; ===========================================================================

;loc_F9A:
VBlank_Sub12:				; XREF: VBlank_Routines
		bsr.w	sub_106E
		move.w	($FFFFF624).w,(a5)
; ===========================================================================

;loc_F9A:
VBlank_Sub16:				; XREF: VBlank_Routines
;		move.w	#$100,($A11100).l ; остановка Z80
;
;loc_FAE:
;		btst	#0,($A11100).l	; has Z80 stopped?
;		bne.s	loc_FAE		; если нет, бранч
		bsr.w	ReadJoypads
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
;		move.w	#0,($A11100).l	; запуск Z80
		jsr	ProcessDMAQueue

loc_1060:
		tst.w	($FFFFF614).w
		beq.w	locret_106C
		subq.w	#1,($FFFFF614).w

locret_106C:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_106E:				; XREF: VBlank_Sub02; et al
;		move.w	#$100,($A11100).l ; остановка Z80
;
;loc_1076:
;		btst	#0,($A11100).l	; has Z80 stopped?
;		bne.s	loc_1076	; если нет, бранч
		bsr.w	ReadJoypads
		tst.b	($FFFFF64E).w
		bne.s	loc_10B0
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_10D4
; ===========================================================================

loc_10B0:				; XREF: sub_106E
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_10D4:				; XREF: sub_106E
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
;		move.w	#0,($A11100).l	; запуск Z80
		rts
; End of function sub_106E
