
; ===============================================================
; ---------------------------------------------------------------
; SMPS Extension Module
; 2014, Vladikcomper
; ---------------------------------------------------------------
;	* Updated FM channel tracker
;	* Alternative note system
;	* Improved frequency calculation
;	* Portamento support with 4 different modes
; ---------------------------------------------------------------

; WARNING! Memory used overlaps with v_1up_ram_copy

; Extended channel struct
		rsreset
note		rs.w	1
note_target	rs.w	1
note_step	rs.w	1
lastnote	rs.b	1		; last note read from track
slide_mode	rs.b	1
slide_speed	rs.b	1
unused		rs.b	1

TS_ExtChannelSize	= __RS-note

; Extended SMPS memory usage
		rsset	v_1up_ram_copy
TS_ExtChannels	rs.b	TS_ExtChannelSize*6		; extended RAM for 6 FM channels

; ===============================================================
; ---------------------------------------------------------------
; Subroutine to init extended channels RAM
; ---------------------------------------------------------------

TS_InitExtChannels:
	move.l	a5,-(sp)

	lea	TS_ExtChannels(a6),a5
	moveq	#0,d0
	moveq	#6-1,d1				; number of channels

@clearchannel:
	rept	TS_ExtChannelSize/4
		move.l	d0,(a5)+		; clear channel struct
	endr
	dbf	d1, @clearchannel

	move.l	(sp)+,a5
	rts

; ===============================================================
; ---------------------------------------------------------------
; Subroutine to update FM channel
; ---------------------------------------------------------------

ExtChannelsRAM:   
	dc.w	0
	dc.w	TS_ExtChannelSize
	dc.w	TS_ExtChannelSize*2
	dc.w	TS_ExtChannelSize*3
	dc.w	TS_ExtChannelSize*4
	dc.w	TS_ExtChannelSize*5

; ---------------------------------------------------------------
TS_FM_UpdateChannel:
	move.w	d7,d0
	add.w	d0,d0
	lea	TS_ExtChannels(a6),a3
	adda.w	ExtChannelsRAM(pc,d0),a3

	move.b	slide_speed(a3),d0	; load slide speed
	andi.b	#$7F,d0			; clear bit 7
	beq.s	@NoSlide		; if speed is zero, branch
	jsr	TS_FM_SlideNote		; otherwise, update sliding
@NoSlide:

	subq.b	#1,$E(a5)		; decrease note timer
	beq.s	@LoadNewNote		; if timer has expired, branch
	jsr	NoteFillUpdate
	jsr	DoModulation
	jmp	FMUpdateFreq

; ---------------------------------------------------------------
@LoadNewNote:
	pea	FMNoteOn
	pea	FMPrepareNote

	bclr	#4,(a5)			; Clear do not attack next note bit
	movea.l	4(a5),a4		; load channel track
	
@0	moveq	#0,d5
	move.b	(a4)+,d5		; get a byte from track
	cmpi.b	#$E0,d5			; is this a coordination flag?
	blo.s	@1
	move.l	a3,-(sp)
	jsr	CoordFlag		; execute coordinate flag
	move.l	(sp)+,a3
	bra.s	@0			; repeat
	
@1	jsr	TS_FM_NoteOff_SetSlide
	jsr	FMNoteOff		; call NoteOff event
	bclr	#1,(a5)			; clear track at rest bit
	tst.b	d5			; did we get a note?
	bpl.s	@RepeatNote		; if got duration, branch
	jsr	TS_FM_UpdateNote
	move.b	(a4)+,d5		; get a byte from track
	bpl.s	@UpdateDuration		; if this is duration, branch
	subq.w	#1,a4
	jmp	FinishTrackUpdate

; ---------------------------------------------------------------
@RepeatNote:
	move.w	d5,-(sp)		; save duration to stack
	move.b	note(a3),d5
	jsr	TS_FM_UpdateNote
	move.w	(sp)+,d5		; load duration from stack

@UpdateDuration:
	jsr	SetDuration
	jmp	FinishTrackUpdate


; ===============================================================
; ---------------------------------------------------------------
; Subroutine to calculate note sliding
; ---------------------------------------------------------------

TS_FM_SlideNote:
	move.w	note_step(a3),d1	; d1 = Note Step
	beq.s	@Ret
	move.w	note(a3),d0		; d0 = Note
	lsl.b	#3,d0			; d0 = Note (fractional format)
	add.w	d1,d0			; d0 = Note + Note Step
	move.w	note_target(a3),d2	; d2 = Target Note
	lsl.b	#3,d2			; d2 = Target Note (fractional format)
	sub.w	d2,d0			; d0 = (Note + Note Step) - Target Note
	eor.w	d0,d1
	bmi.s	@UpdateNote
	clr.w	note_step(a3)		; reset Note Step
	moveq	#0,d0			; set Note to Target Note

@UpdateNote:
	add.w	d2,d0
	lsr.b	#3,d0
	andi.b	#$1F,d0
	move.w	d0,note(a3)

	btst	#1,(a5)			; is track resting?
	bne.s	@Ret			; if yes, branch
        jsr	TS_SetNoteFrequency
        move.w	$10(a5),d6		; load frequency stored
	jmp	FMUpdateFreq		; apply it

@Ret	rts

; ===============================================================
; ---------------------------------------------------------------
; Subroutine to set sliding after note off
; ---------------------------------------------------------------

TS_FM_NoteOff_SetSlide:
	tst.b	lastnote(a3)		; was the last note zero?
	beq.s	@Ret			; if yes, branch
	btst	#7,slide_mode(a3)	; is sliding disabled on note off?
	beq.s	@Ret			; if yes, branch
	move.b	slide_speed(a3),d0	; load slide speed
	andi.w	#$7F,d0
	sub.w	#100,d0
	neg.w	d0
	add.w	d0,d0
	move.w	#$5FFC,d2		; set Target note to $5FFC

	btst	#6,slide_mode(a3)	; is sliding direction up?
	beq.s	@SetSlide		; branch if yes
	neg.w	d0
	moveq	#0,d2			; set Target note to $0000

@SetSlide:
	move.w	d0,note_step(a3)
	move.w	d2,note_target(a3)

@Ret	rts

; ===============================================================
; ---------------------------------------------------------------
; Coordination flag to set portamento mode
; ---------------------------------------------------------------

TS_Flag_SetPortamentoMode:
	move.b	(a4)+,d0
	andi.w	#3,d0
	add.w	d0,d0			; d0 = x*2
	move.w	d0,d1
	lsl.w	#3,d0			; d0 = x*16
	sub.w	d1,d0			; d0 = x*14
	jmp	@0(pc,d0)

; ---------------------------------------------------------------
@0	bclr	#7,slide_speed(a3)	; originally FlagF4
	bclr	#7,slide_mode(a3)
	rts
; ---------------------------------------------------------------
	bset	#7,slide_speed(a3)	; originally FlagF5
	bclr	#7,slide_mode(a3)
	rts
; ---------------------------------------------------------------
	bset	#7,slide_mode(a3)	; originally FlagF6
	bclr	#6,slide_mode(a3)
      	rts
; ---------------------------------------------------------------
	bset	#7,slide_mode(a3)	; originally FlagF7
	bset	#6,slide_mode(a3)
	rts

; ===============================================================
; ---------------------------------------------------------------
; Coordination flag to set portamento speed
; ---------------------------------------------------------------

TS_Flag_SetPortamentoSpeed:
	move.b	(a4)+,d0
	andi.b	#$7F,d0
	move.b	slide_speed(a3),d1
	andi.b	#$80,d1
	or.b	d0,d1
	move.b	d1,slide_speed(a3)
	rts

; ===============================================================
; ---------------------------------------------------------------
; Subroutine to update note
; ---------------------------------------------------------------
; INPUT:
;	d5 .b	Note
; ---------------------------------------------------------------

TS_FM_UpdateNote:
	subi.b	#$80,d5			; subtract $80 from the note
	beq.s	@SetRest		; if note $80, branch
	move.w	d5,-(sp)

	add.b	8(a5),d5		; add pitch to note
	andi.w	#$7F,d5
	jsr	TS_SetTargetNote
	jsr	TS_SetNoteFrequency

	move.w	(sp)+,d5
	move.b	d5,lastnote(a3)
	rts

; ---------------------------------------------------------------
@SetRest
	move.b	d5,lastnote(a3)		; save as last note read
	clr.w	$10(a5)
	bset	#1,(a5)
	rts

; ===============================================================
; ---------------------------------------------------------------
; Subroutine to set target note
; ---------------------------------------------------------------
; INPUT:
;	d5 .b	Pitched Note
; ---------------------------------------------------------------

TS_SetTargetNote:
	; TODOh: Frequency displacement support
	move.b	d5,note_target(a3)
	clr.b	note_target+1(a3)		; clear note's fractional part

	move.b	slide_speed(a3),d0
	andi.w	#$7F,d0
	beq.s	@NoPortamento
	btst	#7,slide_mode(a3)		; does sliding mode works for note off only?
	bne.s	@SetNoteToTarget		; if yes, branch
	tst.b	lastnote(a3)			; ~~ was the last note zero?
	bne.s	@SetSlide			; ~~ is yes, branch
	btst	#7,slide_speed(a3)
	bne.s	@NoPortamento

@SetSlide:
	sub.b	#100,d0
	move.w	note_target(a3),d2
	sub.w	note(a3),d2			; Target Note < Note ?
	bcs.s	@CalcNoteStep			; if yes, branch
	neg.b	d0				; otherwise, negate byte

@CalcNoteStep:
	ext.w	d0
	asl.w	#5,d0
	move.w	d0,note_step(a3)
	rts

; ---------------------------------------------------------------
@NoPortamento:
	clr.w	note_step(a3)
	
@SetNoteToTarget:
	move.w	note_target(a3),note(a3)	; set Note to Target Note
	rts

; ===============================================================
; ---------------------------------------------------------------
; Subroutine to update note
; ---------------------------------------------------------------

TS_SetNoteFrequency:
	move.b	note(a3),d5
	andi.w	#$7F,d5
	moveq	#-1,d4				; d4 = octave
	moveq	#12,d3				; d3 = octave size (in notes)

@SplitNoteAndOctave:
	addq.w	#1,d4
	sub.w	d3,d5
	bcc.s	@SplitNoteAndOctave
	add.w	d3,d5
	add.w	d5,d5				; d5 = Note*2
	move.w	FM_Frequencies(pc,d5),d0
	ror.w	#5,d4				; d4 = Octave<<11
	or.w	d4,d0				; d0 = Octave<<11 + Frequency
	move.b	note+1(a3),d3			; d3 = Subnote
	andi.w	#$1F,d3
	lsl.w	#4,d5				; d5 = Note*32
	add.w	d3,d5				; d5 = Note*32 + Subnote
	move.b	FM_PortamentoFreq(pc,d5),d3
	add.w	d3,d0				; d0 = Octave<<11 + Frequency + PortamentoFreq
	move.w	d0,$10(a5)			; save frequency
	rts

; ---------------------------------------------------------------
; FM Frequencies table
; ---------------------------------------------------------------

FM_Frequencies:
	dc.w	$284, $2AA, $2D3, $2FE, $32B, $35B, $38E, $3C4, $3FE, $43B, $47B, $4BF

FM_PortamentoFreq:
	dc.b	0, 1, 2, 4, 5, 6,  7,  8,   $A,  $B,  $C,  $D,  $E,  $10, $11, $12, $13, $14, $16, $17, $18, $19, $1A, $1C, $1D, $1E, $1F, $20, $21, $23, $24, $25
	dc.b	0, 1, 3, 4, 5, 6,  8,  9,   $A,  $B,  $D,  $E,  $F,  $10, $12, $13, $14, $16, $17, $18, $19, $1B, $1C, $1D, $1E, $20, $21, $22, $23, $25, $26, $27
	dc.b	0, 1, 3, 4, 5, 7,  8,  9,   $B,  $C,  $D,  $F,  $10, $11, $13, $14, $15, $17, $18, $1A, $1B, $1C, $1E, $1F, $20, $22, $23, $24, $26, $27, $28, $2A
	dc.b	0, 1, 3, 4, 6, 7,  9,  $A,  $B,  $D,  $E,  $10, $11, $12, $14, $15, $17, $18, $1A, $1B, $1C, $1E, $1F, $21, $22, $24, $25, $26, $28, $29, $2B, $2C
	dc.b	0, 2, 3, 5, 6, 8,  9,  $B,  $C,  $E,  $F,  $11, $12, $14, $15, $17, $18, $1A, $1B, $1D, $1E, $20, $21, $23, $24, $26, $27, $29, $2A, $2C, $2D, $2F
	dc.b	0, 2, 3, 5, 6, 8,  $A, $B,  $D,  $E,  $10, $12, $13, $15, $16, $18, $1A, $1B, $1D, $1E, $20, $22, $23, $25, $26, $28, $2A, $2B, $2D, $2E, $30, $31
	dc.b	0, 2, 3, 5, 7, 8,  $A, $C,  $E,  $F,  $11, $13, $14, $16, $18, $19, $1B, $1D, $1E, $20, $22, $24, $25, $27, $29, $2A, $2C, $2E, $2F, $30, $33, $34
	dc.b	0, 2, 4, 5, 7, 9,  $B, $D,  $E,  $10, $12, $14, $16, $17, $19, $1B, $1D, $1E, $20, $22, $24, $26, $27, $29, $2B, $2D, $2F, $30, $32, $34, $36, $38
	dc.b	0, 2, 4, 6, 8, 9,  $B, $D,  $F,  $11, $13, $15, $17, $19, $1B, $1C, $1E, $20, $22, $24, $26, $28, $2A, $2C, $2E, $2F, $31, $33, $35, $37, $39, $3B
	dc.b	0, 2, 4, 6, 8, $A, $C, $E,  $10, $12, $14, $16, $18, $1A, $1C, $1E, $20, $22, $24, $26, $28, $2A, $2C, $2E, $30, $32, $34, $36, $38, $3A, $3C, $3E
	dc.b	0, 2, 4, 6, 9, $B, $D, $F,  $11, $13, $15, $17, $1A, $1C, $1E, $20, $22, $24, $26, $28, $2B, $2D, $2F, $31, $33, $35, $37, $3A, $3C, $3E, $40, $42
	dc.b	0, 2, 5, 7, 9, $B, $E, $10, $12, $14, $17, $19, $1B, $1D, $20, $22, $24, $26, $29, $2B, $2D, $2F, $32, $34, $36, $38, $3B, $3D, $3F, $41, $44, $46

