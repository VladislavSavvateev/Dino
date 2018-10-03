; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_acr_y:	
		dc.w SME_acr_y_10-SME_acr_y, SME_acr_y_11-SME_acr_y	
		dc.w SME_acr_y_26-SME_acr_y, SME_acr_y_3B-SME_acr_y	
		dc.w SME_acr_y_78-SME_acr_y, SME_acr_y_83-SME_acr_y	
		dc.w SME_acr_y_8E-SME_acr_y, SME_acr_y_94-SME_acr_y	
SME_acr_y_10:	dc.b 0	
SME_acr_y_11:	dc.b 4	
		dc.b 0, 0, 0, 0, 8	
		dc.b 8, $A, 0, 1, 0	
		dc.b $20, 0, 0, $A, 8	
		dc.b $28, 8, 0, $B, 0	
SME_acr_y_26:	dc.b 4	
		dc.b 0, 4, 0, $E, 0	
		dc.b 8, $A, 0, $10, 0	
		dc.b $20, 0, 0, $19, 8	
		dc.b $28, 8, 0, $B, 0	
SME_acr_y_3B:	dc.b $C	
		dc.b 0, 0, 0, $1A, 8	
		dc.b 8, $A, 0, $1B, 0	
		dc.b $20, 4, 0, $24, 0	
		dc.b $28, 8, 0, $26, 0	
		dc.b 0, 7, 0, $29, $18	
		dc.b $20, 5, 0, $31, $18	
		dc.b $20, 5, 0, $35, $28	
		dc.b 8, $A, 0, $39, $28	
		dc.b 0, 4, 0, $42, $30	
		dc.b $20, 1, 0, $44, $38	
		dc.b 8, 2, 0, $46, $40	
		dc.b $28, 0, 0, $49, $40	
SME_acr_y_78:	dc.b 2	
		dc.b $10, 6, 0, $4A, 0	
		dc.b $28, 4, 0, $50, 0	
SME_acr_y_83:	dc.b 2	
		dc.b $10, 6, 0, $52, 0	
		dc.b $28, 4, 0, $50, 0	
SME_acr_y_8E:	dc.b 1	
		dc.b $10, 7, 0, $58, 0	
SME_acr_y_94:	dc.b 1	
		dc.b $10, 7, 0, $60, 0	
		even