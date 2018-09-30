		dc.w	Dino_Run-Dino_Anim
		dc.w	Dino_Static-Dino_Anim
		dc.w	Dino_Dies-Dino_Anim
		dc.w	Dino_Duck-Dino_Anim	; dino duck, ahahah
		
Dino_Run:
		dc.b	7, 1, 2, $F1
		
Dino_Static:
		dc.b	2, 0, $F0, 0
		
Dino_Dies:
		dc.b	2, 3, $F0, 0
		
Dino_Duck:
		dc.b	7, 4, 5, $F1