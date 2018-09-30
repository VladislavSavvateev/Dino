
; ---------------------------------------------------------------------------
; Sound	effect pointers
; ---------------------------------------------------------------------------
SoundIndex:
ptr_sndA0:	dc.l SoundA0
ptr_sndA1:	dc.l SoundA1
ptr_sndA2:	dc.l SoundA2
ptr_sndA3:	dc.l SoundA3
ptr_sndA4:	dc.l SoundA4
ptr_sndA5:	dc.l SoundA5
ptr_sndA6:	dc.l SoundA6
ptr_sndA7:	dc.l SoundA7
ptr_sndA8:	dc.l SoundA8
ptr_sndA9:	dc.l SoundA9
ptr_sndAA:	dc.l SoundAA
ptr_sndAB:	dc.l SoundAB
ptr_sndAC:	dc.l SoundAC
ptr_sndAD:	dc.l SoundAD
ptr_sndAE:	dc.l SoundAE
ptr_sndAF:	dc.l SoundAF
ptr_sndB0:	dc.l SoundB0
ptr_sndB1:	dc.l SoundB1
ptr_sndB2:	dc.l SoundB2
ptr_sndB3:	dc.l SoundB3
ptr_sndB4:	dc.l SoundB4
ptr_sndB5:	dc.l SoundB5
ptr_sndB6:	dc.l SoundB6
ptr_sndB7:	dc.l SoundB7
ptr_sndB8:	dc.l SoundB8
ptr_sndB9:	dc.l SoundB9
ptr_sndBA:	dc.l SoundBA
ptr_sndBB:	dc.l SoundBB
ptr_sndBC:	dc.l SoundBC
ptr_sndBD:	dc.l SoundBD
ptr_sndBE:	dc.l SoundBE
ptr_sndBF:	dc.l SoundBF
ptr_sndC0:	dc.l SoundC0
ptr_sndC1:	dc.l SoundC1
ptr_sndC2:	dc.l SoundC2
ptr_sndC3:	dc.l SoundC3
ptr_sndC4:	dc.l SoundC4
ptr_sndC5:	dc.l SoundC5
ptr_sndC6:	dc.l SoundC6
ptr_sndC7:	dc.l SoundC7
ptr_sndC8:	dc.l SoundC8
ptr_sndC9:	dc.l SoundC9
ptr_sndCA:	dc.l SoundCA
ptr_sndCB:	dc.l SoundCB
ptr_sndCC:	dc.l SoundCC
ptr_sndCD:	dc.l SoundCD
ptr_sndCE:	dc.l SoundCE
ptr_sndCF:	dc.l SoundCF
ptr_sndD0:	dc.l SoundD0
		dc.l SoundD1
		dc.l SoundD2
		dc.l SoundD3
		dc.l SoundD4
		dc.l SoundD5
		dc.l SoundD6
		dc.l SoundD7

SoundA0:	incbin	sound\soundA0.bin
		even
SoundA1:	incbin	sound\soundA1.bin
		even
SoundA2:	incbin	sound\soundA2.bin
		even
SoundA3:	incbin	sound\soundA3.bin
		even
SoundA4:	incbin	sound\soundA4.bin
		even
SoundA5:	incbin	sound\soundA5.bin
		even
SoundA6:	incbin	sound\soundA6.bin
		even
SoundA7:	incbin	sound\soundA7.bin
		even
SoundA8:	incbin	sound\soundA8.bin
		even
SoundA9:	incbin	sound\soundA9.bin
		even
SoundAA:	incbin	sound\soundAA.bin
		even
SoundAB:	incbin	sound\soundAB.bin
		even
SoundAC:	incbin	sound\soundAC.bin
		even
SoundAD:	incbin	sound\soundAD.bin
		even
SoundAE:	incbin	sound\soundAE.bin
		even
SoundAF:	incbin	sound\soundAF.bin
		even
SoundB0:	incbin	sound\soundB0.bin
		even
SoundB1:	incbin	sound\soundB1.bin
		even
SoundB2:	incbin	sound\soundB2.bin
		even
SoundB3:	incbin	sound\soundB3.bin
		even
SoundB4:	incbin	sound\soundB4.bin
		even
SoundB5:	incbin	sound\soundB5.bin
		even
SoundB6:	incbin	sound\soundB6.bin
		even
SoundB7:	incbin	sound\soundB7.bin
		even
SoundB8:	incbin	sound\soundB8.bin
		even
SoundB9:	incbin	sound\soundB9.bin
		even
SoundBA:	incbin	sound\soundBA.bin
		even
SoundBB:	incbin	sound\soundBB.bin
		even
SoundBC:	incbin	sound\soundBC.bin
		even
SoundBD:	incbin	sound\soundBD.bin
		even
SoundBE:	incbin	sound\soundBE.bin
		even
SoundBF:	incbin	sound\soundBF.bin
		even
SoundC0:	incbin	sound\soundC0.bin
		even
SoundC1:	incbin	sound\soundC1.bin
		even
SoundC2:	incbin	sound\soundC2.bin
		even
SoundC3:	incbin	sound\soundC3.bin
		even
SoundC4:	incbin	sound\soundC4.bin
		even
SoundC5:	incbin	sound\soundC5.bin
		even
SoundC6:	incbin	sound\soundC6.bin
		even
SoundC7:	incbin	sound\soundC7.bin
		even
SoundC8:	incbin	sound\soundC8.bin
		even
SoundC9:	incbin	sound\soundC9.bin
		even
SoundCA:	incbin	sound\soundCA.bin
		even
SoundCB:	incbin	sound\soundCB.bin
		even
SoundCC:	incbin	sound\soundCC.bin
		even
SoundCD:	incbin	sound\soundCD.bin
		even
SoundCE:	incbin	sound\soundCE.bin
		even
SoundCF:	incbin	sound\soundCF.bin
		even
SoundD0:	incbin	sound\soundD0.bin
		even
		
; Spin Dash charge (Sonic 2)
SoundD1:	dc.w @0-SoundD1,$0101
		dc.w $8005,@2-SoundD1,$FE00-$100
@2		dc.b	$EF,$00
		dc.b	$FC,$01		; ++ rev sound
		dc.b	$F0,$00,$01,$20,$F6
		dc.b	$C4,$16,$E7,$F4,$D0,$18,$E7
@1		dc.b	$04,$E7,$E6
		dc.w	$03F7,$0010,@1-*-1
		dc.b	$F2
@0:		dc.b $34,$00,$0C,$03,$09,$9F,$8C,$8F,$95,$00,$00,$00		; 02/03 swap
		dc.b $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$1D,$00	; 17/18 swap
		even
		
; Bullet sound (Sonic 3)
SoundD2:	incbin	sound\soundD2.bin
		even

; Rising lava sound (SWA original)
SoundD3:	incbin	sound\soundD3.bin
		even
		
; Error sound (Sonic 2)
SoundD4:	dc.w @0-SoundD4,$0101
		dc.w $8005,@1-SoundD4,$0004
@1:		dc.b $EF,$00,$B0,$06,$80,$06,$B0,$18,$F2
@0:		dc.b $38,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$00,$00,$00		; 02/03 swap
		dc.b $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$1F,$17,$0C,$00	; 17/18 swap

; Metal Sonic Buzz saw (Sonic 2, modification)
SoundD5:	dc.w SoundD5_voice-SoundD5,$0101
		dc.w $8005,SoundD5_track-SoundD5,$0000
SoundD5_track	dc.b	$EF, $00	; smpsFMVoice 0
		dc.b	$C6,$14,$E7	; $24 --> $14
@2		dc.b	$C6,$04,$E7, $E6,$08
		dc.b	$F7,$00,04	; smpsLoop
		dc.w	@2-*-1
		dc.b	$F2		; smpsStop
SoundD5_voice	dc.b $33,$00,$00,$10,$31,$1F,$1D,$1E,$0E,$00,$0C,$1D		; 02/03 swap
		dc.b $00,$00,$00,$01,$00,$0F,$0F,$0F,$0F,$08,$07,$06,$80	; 17/18 swap
		even

; Metal Sonic Buzz saw, far away (Sonic 2, modification)
SoundD6:	dc.w SoundD6_voice-SoundD6,$0101
		dc.w $8005,@0-SoundD6,$0006
@0		dc.b	$E0, $80	; pan-L
		dc.b	$F6
		dc.w	SoundD5_track-*-1
SoundD6_voice	dc.b $33,$00,$00,$10,$31,$1F,$1D,$1E,$0E,$00,$0C,$1D		; 02/03 swap
		dc.b $00,$00,$00,$01,$00,$0F,$0F,$0F,$0F,$08,$07,$06,$80	; 17/18 swap
		even

; Metal Sonic Stomp sound (Sonic 3)
SoundD7: 	dc.w @0-SoundD7,$0101
		dc.w $8005,@1-SoundD7,$EC00
@1:		dc.b	$EF, $00	; smpsFMVoice 0
		dc.b	$A3, $10
		dc.b	$F2		; smpsStop
@0:		dc.b	$20
		dc.b	$00, $00, $00, $00,	$1F, $1F, $1F, $1F, 	$00, $11, $00, $00
		dc.b	$00, $00, $00, $09,	$0F, $FF, $FF, $0F, 	$03, $10, $1A, $80
		even
