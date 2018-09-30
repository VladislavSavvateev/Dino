; ---------------------------------------------------------------------------
; Subroutine to	fade out and fade in
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeTo:
		move.w	#$3F,($FFFFF626).w
 
Pal_FadeTo2:
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	($FFFFF627).w,d0
 
Pal_ToBlack:
		move.w	d1,(a0)+
		dbf	d0,Pal_ToBlack	; fill pallet with $000	(black)
		moveq	#$0E,d4					; MJ: prepare maximum colour check
		moveq	#$00,d6					; MJ: clear d6
 
loc_1DCE:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bchg	#$00,d6					; MJ: change delay counter
		beq	loc_1DCE				; MJ: if null, delay a frame
		bsr.s	Pal_FadeIn
		subq.b	#$02,d4					; MJ: decrease colour check
		bne	loc_1DCE				; MJ: if it has not reached null, branch
		move.b	#$12,($FFFFF62A).w			; MJ: wait for V-blank again (so colours transfer)
		bra	DelayProgram				; MJ: ''
 
; End of function Pal_FadeTo
 
; ---------------------------------------------------------------------------
; Pallet fade-in subroutine
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
 
 
Pal_FadeIn:				; XREF: Pal_FadeTo
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0
 
loc_1DFA:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1DFA
		cmpi.b	#1,($FFFFFE10).w
		bne.s	locret_1E24
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0
 
loc_1E1E:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1E1E
 
locret_1E24:
		rts	
; End of function Pal_FadeIn
 
 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
 
 
Pal_AddColor:				; XREF: Pal_FadeIn
		move.b	(a1),d5					; MJ: load blue
		move.w	(a1)+,d1				; MJ: load green and red
		move.b	d1,d2					; MJ: load red
		lsr.b	#$04,d1					; MJ: get only green
		andi.b	#$0E,d2					; MJ: get only red
		move.w	(a0),d3					; MJ: load current colour in buffer
		cmp.b	d5,d4					; MJ: is it time for blue to fade?
		bhi	FCI_NoBlue				; MJ: если нет, бранч
		addi.w	#$0200,d3				; MJ: increase blue
 
FCI_NoBlue:
		cmp.b	d1,d4					; MJ: is it time for green to fade?
		bhi	FCI_NoGreen				; MJ: если нет, бранч
		addi.b	#$20,d3					; MJ: increase green
 
FCI_NoGreen:
		cmp.b	d2,d4					; MJ: is it time for red to fade?
		bhi	FCI_NoRed				; MJ: если нет, бранч
		addq.b	#$02,d3					; MJ: increase red
 
FCI_NoRed:
		move.w	d3,(a0)+				; MJ: save colour
		rts						; MJ: return
 
; End of function Pal_AddColor
 
 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
 
 
Pal_FadeFrom:
		move.w	#$3F,($FFFFF626).w
		moveq	#$07,d4					; MJ: set repeat times
		moveq	#$00,d6					; MJ: clear d6
 
loc_1E5C:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bchg	#$00,d6					; MJ: change delay counter
		beq	loc_1E5C				; MJ: if null, delay a frame
		bsr.s	Pal_FadeOut
		dbf	d4,loc_1E5C
		rts	
; End of function Pal_FadeFrom
 
; ---------------------------------------------------------------------------
; Pallet fade-out subroutine
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Pal_FadeOut:				; XREF: Pal_FadeFrom
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0
 
loc_1E82:
		bsr.s	Pal_DecColor
		dbf	d0,loc_1E82
 
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0
 
loc_1E98:
		bsr.s	Pal_DecColor
		dbf	d0,loc_1E98
		rts	
; End of function Pal_FadeOut
 
 
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
 
 
Pal_DecColor:				; XREF: Pal_FadeOut
		move.w	(a0),d5					; MJ: load colour
		move.w	d5,d1					; MJ: copy to d1
		move.b	d1,d2					; MJ: load green and red
		move.b	d1,d3					; MJ: load red
		andi.w	#$0E00,d1				; MJ: get only blue
		beq	FCO_NoBlue				; MJ: if blue is finished, branch
		subi.w	#$0200,d5				; MJ: decrease blue
 
FCO_NoBlue:
		andi.w	#$00E0,d2				; MJ: get only green (needs to be word)
		beq	FCO_NoGreen				; MJ: if green is finished, branch
		subi.b	#$20,d5					; MJ: decrease green
 
FCO_NoGreen:
		andi.b	#$0E,d3					; MJ: get only red
		beq	FCO_NoRed				; MJ: if red is finished, branch
		subq.b	#$02,d5					; MJ: decrease red
 
FCO_NoRed:
		move.w	d5,(a0)+				; MJ: save new colour
		rts						; MJ: return
 
; End of function Pal_DecColor

; ---------------------------------------------------------------------------
; Subroutine to	fill the pallet	with white (special stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_MakeWhite:				; XREF: SpecialStage
		move.w	#$3F,($FFFFF626).w
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.w	#$EEE,d1
		move.b	($FFFFF627).w,d0

PalWhite_Loop:
		move.w	d1,(a0)+
		dbf	d0,PalWhite_Loop
		move.w	#$15,d4

loc_1EF4:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.s	Pal_WhiteToBlack
		dbf	d4,loc_1EF4
		rts	
; End of function Pal_MakeWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_WhiteToBlack:			; XREF: Pal_MakeWhite
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1F20:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_1F20

		cmpi.b	#1,($FFFFFE10).w
		bne.s	locret_1F4A
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1F44:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_1F44

locret_1F4A:
		rts	
; End of function Pal_WhiteToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor2:				; XREF: Pal_WhiteToBlack
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_1F78
		move.w	d3,d1
		subi.w	#$200,d1	; decrease blue	value
		bcs.s	loc_1F64
		cmp.w	d2,d1
		bcs.s	loc_1F64
		move.w	d1,(a0)+
		rts	
; ===========================================================================

loc_1F64:				; XREF: Pal_DecColor2
		move.w	d3,d1
		subi.w	#$20,d1		; decrease green value
		bcs.s	loc_1F74
		cmp.w	d2,d1
		bcs.s	loc_1F74
		move.w	d1,(a0)+
		rts	
; ===========================================================================

loc_1F74:				; XREF: loc_1F64
		subq.w	#2,(a0)+	; decrease red value
		rts	
; ===========================================================================

loc_1F78:				; XREF: Pal_DecColor2
		addq.w	#2,a0
		rts	
; End of function Pal_DecColor2

; ---------------------------------------------------------------------------
; Subroutine to	make a white flash when	you enter a special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_MakeFlash:				; XREF: SpecialStage
		move.w	#$3F,($FFFFF626).w
		move.w	#$15,d4

loc_1F86:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.s	Pal_ToWhite
		dbf	d4,loc_1F86
		rts	
; End of function Pal_MakeFlash


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_ToWhite:				; XREF: Pal_MakeFlash
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0

loc_1FAC:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_1FAC
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0

loc_1FC2:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_1FC2
		rts	
; End of function Pal_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor2:				; XREF: Pal_ToWhite
		move.w	(a0),d2
		cmpi.w	#$EEE,d2
		beq.s	loc_2006
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#$E,d1
		beq.s	loc_1FE2
		addq.w	#2,(a0)+	; increase red value
		rts	
; ===========================================================================

loc_1FE2:				; XREF: Pal_AddColor2
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#$E0,d1
		beq.s	loc_1FF4
		addi.w	#$20,(a0)+	; increase green value
		rts	
; ===========================================================================

loc_1FF4:				; XREF: loc_1FE2
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#$E00,d1
		beq.s	loc_2006
		addi.w	#$200,(a0)+	; increase blue	value
		rts	
; ===========================================================================

loc_2006:				; XREF: Pal_AddColor2
		addq.w	#2,a0
		rts	
; End of function Pal_AddColor2