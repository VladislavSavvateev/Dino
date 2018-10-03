; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_ZDH_9:	
		dc.w SME_ZDH_9_A-SME_ZDH_9, SME_ZDH_9_1A-SME_ZDH_9	
		dc.w SME_ZDH_9_2A-SME_ZDH_9, SME_ZDH_9_3A-SME_ZDH_9	
		dc.w SME_ZDH_9_4A-SME_ZDH_9	
SME_ZDH_9_A:	dc.b 3	
		dc.b 0, 0, 0, 8, 8	
		dc.b 0, 0, 0, 8, $18	
		dc.b 0, 0, 0, 8, $28	
SME_ZDH_9_1A:	dc.b 3	
		dc.b $FC, 5, 0, 0, 4	
		dc.b 0, 0, 0, 8, $18	
		dc.b 0, 0, 0, 8, $28	
SME_ZDH_9_2A:	dc.b 3	
		dc.b $FC, 5, 0, 4, 4	
		dc.b $FC, 5, 0, 0, $14	
		dc.b 0, 0, 0, 8, $28	
SME_ZDH_9_3A:	dc.b 3	
		dc.b 0, 0, 0, 8, 8	
		dc.b $FC, 5, 0, 4, $14	
		dc.b $FC, 5, 0, 0, $24	
SME_ZDH_9_4A:	dc.b 3	
		dc.b 0, 0, 0, 8, $18	
		dc.b 0, 0, 0, 8, 8	
		dc.b $FC, 5, 0, 4, $24	
		even