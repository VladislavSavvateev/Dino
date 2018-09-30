; ===========================================================================
; ---------------------------------------------------------------------------
; SONIC 1 SMPS DRIVER
; Mod by Vladikcomper
; ---------------------------------------------------------------------------
;	* Extended slots
;;	* PAL tempo modifier
;;	* CD Digital Audio playback
;	* 4-stage sound queue
;	* Mega PCM Support
;	* HQ Digital audio playback
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Memory map
; ---------------------------------------------------------------------------

v_snddriver_ram:  = $FFFFF000 ; start of RAM for the sound driver data

v_sndprio:		= $000	; sound priority (priority of new music/SFX must be higher or equal to this value or it won't play; bit 7 of priority being set prevents this value from changing)
v_main_tempo_timeout:	= $001	; Counts down to zero; when zero, resets to next value and delays song by 1 frame
v_main_tempo:		= $002	; Used for music only
f_stopmusic:		= $003	; flag set to stop music when paused
v_fadeout_counter:	= $004
v_cda_playing		= $005	; flag stating if CDA plays

v_fadeout_delay:	= $006
v_extension:		= $007

f_updating_dac:		= $008	; $80 if updating DAC, $00 otherwise
v_playsnd0:		= $009	; sound or music copied from below

v_playqueue		= $00A	; $00A-$00D - sound queue for 4 entries
v_playsnd1:		= $00A	; sound or music to play
;v_playsnd2:		= $00B	; special sound to play
;v_playnull:		= $00C	; unused sound to play

f_voice_selector:	= $00E	; $00 = use music voice pointer; $40 = use special voice pointer; $80 = use track voice pointer
v_revsound:		= $00F	; revving sound effect

v_voice_ptr:		= $018	; voice data pointer (4 bytes)

v_special_voice_ptr:	= $020	; voice data pointer for special SFX ($D0-$DF) (4 bytes)

f_fadein_flag:		= $024	; Flag for fade in
v_fadein_delay:		= $025
v_fadein_counter:	= $026	; Timer for fade in/out
f_1up_playing:		= $027	; flag indicating 1-up song is playing
v_tempo_mod:		= $028	; music - tempo modifier
v_speeduptempo:		= $029	; music - tempo modifier with speed shoes
f_speedup:		= $02A	; flag indicating whether speed shoes tempo is on ($80) or off ($00)
v_ring_speaker:		= $02B	; which speaker the "ring" sound is played in (00 = right; 01 = left)
f_push_playing:		= $02C	; if set, prevents further push sounds from playing

v_track_ram:		= $040	; Start of music RAM

v_dac_track:		= $040
v_dac_playback_control:	= $040	; Playback control bits for DAC channel
v_dac_voice_control:	= $041	; Voice control bits for DAC channel
v_dac_tempo_time:	= $042	; music - tempo dividing timing
v_dac_ptr:		= $044	; DAC channel pointer (4 bytes)
v_dac_amsfmspan:	= $04A
v_dac_stack_ptr:	= $04D
v_dac_note_timeout:	= $04E	; Counts down to zero; when zero, a new DAC sample is needed
v_dac_note_duration:	= $04F
v_dac_curr_sample:	= $050
v_dac_loop_index:	= $064	; Several bytes, may overlap with gosub/return stack

v_dac_playid		= $068	; ### New Variable

; Note: using the channel assignment bits to determine FM channel #. Thus, there is no FM 3.

v_fm1_track:		= $070
v_fm1_playback_control:	= $070	; Playback control bits for FM1
v_fm1_voice_control:	= $071	; Voice control bits
v_fm1_tempo_time:	= $072	; music - tempo dividing timing
v_fm1_ptr:		= $074	; FM channel 0 pointer (4 bytes)
v_fm1_key:		= $078	; FM channel 0 key displacement
v_fm1_volume:		= $079	; FM channel 0 volume attenuation
v_fm1_amsfmspan:	= $07A
v_fm1_voice:		= $07B
v_fm1_stack_ptr:	= $07D
v_fm1_note_timeout:	= $07E	; Counts down to zero; when zero, a new note is needed
v_fm1_note_duration:	= $07F
v_fm1_curr_note:	= $080
v_fm1_note_fill:	= $082
v_fm1_note_fill_master:	= $083
v_fm1_modulation_ptr:	= $084	; 4 bytes
v_fm1_modulation_wait:	= $088
v_fm1_modulation_speed:	= $089
v_fm1_modulation_delta:	= $08A
v_fm1_modulation_steps:	= $08B
v_fm1_modulation_freq:	= $08C	; 2 bytes
v_fm1_freq_adjust:	= $08E
v_fm1_feedbackalgo:	= $08F
v_fm1_loop_index:	= $094	; Several bytes, may overlap with gosub/return stack

v_fm2_track:		= $0A0
v_fm2_playback_control:	= $0A0	; Playback control bits for FM2
v_fm2_voice_control:	= $0A1	; Voice control bits
v_fm2_tempo_time:	= $0A2	; music - tempo dividing timing
v_fm2_ptr:		= $0A4	; FM channel 1 pointer (4 bytes)
v_fm2_key:		= $0A8	; FM channel 1 key displacement
v_fm2_volume:		= $0A9	; FM channel 1 volume attenuation
v_fm2_amsfmspan:	= $0AA
v_fm2_voice:		= $0AB
v_fm2_stack_ptr:	= $0AD
v_fm2_note_timeout:	= $0AE	; Counts down to zero; when zero, a new note is needed
v_fm2_note_duration:	= $0AF
v_fm2_curr_note:	= $0B0
v_fm2_note_fill:	= $0B2
v_fm2_note_fill_master:	= $0B3
v_fm2_modulation_ptr:	= $0B4	; 4 bytes
v_fm2_modulation_wait:	= $0B8
v_fm2_modulation_speed:	= $0B9
v_fm2_modulation_delta:	= $0BA
v_fm2_modulation_steps:	= $0BB
v_fm2_modulation_freq:	= $0BC	; 2 bytes
v_fm2_freq_adjust:	= $0BE
v_fm2_feedbackalgo:	= $0BF
v_fm2_loop_index:	= $0C4	; Several bytes, may overlap with gosub/return stack

v_fm3_track:		= $0D0
v_fm3_playback_control:	= $0D0	; Playback control bits for FM3
v_fm3_voice_control:	= $0D1	; Voice control bits
v_fm3_tempo_time:	= $0D2	; music - tempo dividing timing
v_fm3_ptr:		= $0D4	; FM channel 2 pointer (4 bytes)
v_fm3_key:		= $0D8	; FM channel 2 key displacement
v_fm3_volume:		= $0D9	; FM channel 2 volume attenuation
v_fm3_amsfmspan:	= $0DA
v_fm3_voice:		= $0DB
v_fm3_stack_ptr:	= $0DD
v_fm3_note_timeout:	= $0DE	; Counts down to zero; when zero, a new note is needed
v_fm3_note_duration:	= $0DF
v_fm3_curr_note:	= $0E0
v_fm3_note_fill:	= $0E2
v_fm3_note_fill_master:	= $0E3
v_fm3_modulation_ptr:	= $0E4	; 4 bytes
v_fm3_modulation_wait:	= $0E8
v_fm3_modulation_speed:	= $0E9
v_fm3_modulation_delta:	= $0EA
v_fm3_modulation_steps:	= $0EB
v_fm3_modulation_freq:	= $0EC	; 2 bytes
v_fm3_freq_adjust:	= $0EE
v_fm3_feedbackalgo:	= $0EF
v_fm3_loop_index:	= $0F4	; Several bytes, may overlap with gosub/return stack

v_fm4_track:		= $100
v_fm4_playback_control:	= $100	; Playback control bits for FM4
v_fm4_voice_control:	= $101	; Voice control bits
v_fm4_tempo_time:	= $102	; music - tempo dividing timing
v_fm4_ptr:		= $104	; FM channel 4 pointer (4 bytes)
v_fm4_key:		= $108	; FM channel 4 key displacement
v_fm4_volume:		= $109	; FM channel 4 volume attenuation
v_fm4_amsfmspan:	= $10A
v_fm4_voice:		= $10B
v_fm4_stack_ptr:	= $10D
v_fm4_note_timeout:	= $10E	; Counts down to zero; when zero, a new note is needed
v_fm4_note_duration:	= $10F
v_fm4_curr_note:	= $110
v_fm4_note_fill:	= $112
v_fm4_note_fill_master:	= $113
v_fm4_modulation_ptr:	= $114	; 4 bytes
v_fm4_modulation_wait:	= $118
v_fm4_modulation_speed:	= $119
v_fm4_modulation_delta:	= $11A
v_fm4_modulation_steps:	= $11B
v_fm4_modulation_freq:	= $11C	; 2 bytes
v_fm4_freq_adjust:	= $11E
v_fm4_feedbackalgo:	= $11F
v_fm4_loop_index:	= $124	; Several bytes, may overlap with gosub/return stack

v_fm5_track:		= $130
v_fm5_playback_control:	= $130	; Playback control bits for FM5
v_fm5_voice_control:	= $131	; Voice control bits
v_fm5_tempo_time:	= $132	; music - tempo dividing timing
v_fm5_ptr:		= $134	; FM channel 5 pointer (4 bytes)
v_fm5_key:		= $138	; FM channel 5 key displacement
v_fm5_volume:		= $139	; FM channel 5 volume attenuation
v_fm5_amsfmspan:	= $13A
v_fm5_voice:		= $13B
v_fm5_stack_ptr:	= $13D
v_fm5_note_timeout:	= $13E	; Counts down to zero; when zero, a new note is needed
v_fm5_note_duration:	= $13F
v_fm5_curr_note:	= $140
v_fm5_note_fill:	= $142
v_fm5_note_fill_master:	= $143
v_fm5_modulation_ptr:	= $144	; 4 bytes
v_fm5_modulation_wait:	= $148
v_fm5_modulation_speed:	= $149
v_fm5_modulation_delta:	= $14A
v_fm5_modulation_steps:	= $14B
v_fm5_modulation_freq:	= $14C	; 2 bytes
v_fm5_freq_adjust:	= $14E
v_fm5_feedbackalgo:	= $14F
v_fm5_loop_index:	= $154	; Several bytes, may overlap with gosub/return stack

v_fm6_track:		= $160
v_fm6_playback_control:	= $160	; Playback control bits for FM6
v_fm6_voice_control:	= $161	; Voice control bits
v_fm6_tempo_time:	= $162	; music - tempo dividing timing
v_fm6_ptr:		= $164	; FM channel 6 pointer (4 bytes)
v_fm6_key:		= $168	; FM channel 6 key displacement
v_fm6_volume:		= $169	; FM channel 6 volume attenuation
v_fm6_amsfmspan:	= $16A
v_fm6_voice:		= $16B
v_fm6_stack_ptr:	= $16D
v_fm6_note_timeout:	= $16E	; Counts down to zero; when zero, a new note is needed
v_fm6_note_duration:	= $16F
v_fm6_curr_note:	= $170
v_fm6_note_fill:	= $172
v_fm6_note_fill_master:	= $173
v_fm6_modulation_ptr:	= $174	; 4 bytes
v_fm6_modulation_wait:	= $178
v_fm6_modulation_speed:	= $179
v_fm6_modulation_delta:	= $17A
v_fm6_modulation_steps:	= $17B
v_fm6_modulation_freq:	= $17C	; 2 bytes
v_fm6_freq_adjust:	= $17E
v_fm6_feedbackalgo:	= $17F
v_fm6_loop_index:	= $184	; Several bytes, may overlap with gosub/return stack

v_psg1_track:		= $190
v_psg1_playback_control:= $190	; Playback control bits for PSG1
v_psg1_voice_control:	= $191	; Voice control bits
v_psg1_tempo_time:	= $192	; music - tempo dividing timing
v_psg1_ptr:		= $194	; PSG channel 1 pointer (4 bytes)
v_psg1_key:		= $198	; PSG channel 1 key displacement
v_psg1_volume:		= $199	; PSG channel 1 volume attenuation
v_psg1_amsfmspan:	= $19A
v_psg1_tone:		= $19B
v_psg1_flutter_index:	= $19C
v_psg1_stack_ptr:	= $19D
v_psg1_note_timeout:	= $19E	; Counts down to zero; when zero, a new note is needed
v_psg1_note_duration:	= $19F
v_psg1_curr_note:	= $1A0
v_psg1_note_fill:	= $1A2
v_psg1_note_fill_master:= $1A3
v_psg1_modulation_ptr:	= $1A4	; 4 bytes
v_psg1_modulation_wait:	= $1A8
v_psg1_modulation_speed:= $1A9
v_psg1_modulation_delta:= $1AA
v_psg1_modulation_steps:= $1AB
v_psg1_modulation_freq:	= $1AC	; 2 bytes
v_psg1_freq_adjust:	= $1AE
v_psg1_noise:		= $1AF
v_psg1_loop_index:	= $1B4	; Several bytes, may overlap with gosub/return stack

v_psg2_track:		= $1C0
v_psg2_playback_control:= $1C0	; Playback control bits for PSG2
v_psg2_voice_control:	= $1C1	; Voice control bits
v_psg2_tempo_time:	= $1C2	; music - tempo dividing timing
v_psg2_ptr:		= $1C4	; PSG channel 2 pointer (4 bytes)
v_psg2_key:		= $1C8	; PSG channel 2 key displacement
v_psg2_volume:		= $1C9	; PSG channel 2 volume attenuation
v_psg2_amsfmspan:	= $1CA
v_psg2_tone:		= $1CB
v_psg2_flutter_index:	= $1CC
v_psg2_stack_ptr:	= $1CD
v_psg2_note_timeout:	= $1CE	; Counts down to zero; when zero, a new note is needed
v_psg2_note_duration:	= $1CF
v_psg2_curr_note:	= $1D0
v_psg2_note_fill:	= $1D2
v_psg2_note_fill_master:= $1D3
v_psg2_modulation_ptr:	= $1D4	; 4 bytes
v_psg2_modulation_wait:	= $1D8
v_psg2_modulation_speed:= $1D9
v_psg2_modulation_delta:= $1DA
v_psg2_modulation_steps:= $1DB
v_psg2_modulation_freq:	= $1DC	; 2 bytes
v_psg2_freq_adjust:	= $1DE
v_psg2_noise:		= $1DF
v_psg2_loop_index:	= $1E4	; Several bytes, may overlap with gosub/return stack

v_psg3_track:		= $1F0
v_psg3_playback_control:= $1F0	; Playback control bits for PSG3
v_psg3_voice_control:	= $1F1	; Voice control bits
v_psg3_tempo_time:	= $1F2	; music - tempo dividing timing
v_psg3_ptr:		= $1F4	; PSG channel 3 pointer (4 bytes)
v_psg3_key:		= $1F8	; PSG channel 3 key displacement
v_psg3_volume:		= $1F9	; PSG channel 3 volume attenuation
v_psg3_amsfmspan:	= $1FA
v_psg3_tone:		= $1FB
v_psg3_flutter_index:	= $1FC
v_psg3_stack_ptr:	= $1FD
v_psg3_note_timeout:	= $1FE	; Counts down to zero; when zero, a new note is needed
v_psg3_note_duration:	= $1FF
v_psg3_curr_note:	= $200
v_psg3_note_fill:	= $202
v_psg3_note_fill_master:= $203
v_psg3_modulation_ptr:	= $204	; 4 bytes
v_psg3_modulation_wait:	= $208
v_psg3_modulation_speed:= $209
v_psg3_modulation_delta:= $20A
v_psg3_modulation_steps:= $20B
v_psg3_modulation_freq:	= $20C	; 2 bytes
v_psg3_freq_adjust:	= $20E
v_psg3_noise:		= $20F
v_psg3_loop_index:	= $214	; Several bytes, may overlap with gosub/return stack

v_sfx_track_ram:	= $220	; Start of sfx RAM

v_sfx_fm3_track:	= $220
v_sfx_fm3_playback_control:	= $220	; Playback control bits for sfx FM3
v_sfx_fm3_voice_control:	= $221	; Voice control bits
v_sfx_fm3_tempo_time:	= $222	; sfx - tempo dividing timing
v_sfx_fm3_ptr:		= $224	; FM channel 2 pointer (4 bytes)
v_sfx_fm3_key:		= $228	; FM channel 2 key displacement
v_sfx_fm3_volume:	= $229	; FM channel 2 volume attenuation
v_sfx_fm3_amsfmspan:	= $22A
v_sfx_fm3_voice:	= $22B
v_sfx_fm3_stack_ptr:	= $22D
v_sfx_fm3_note_timeout:	= $22E	; Counts down to zero; when zero, a new note is needed
v_sfx_fm3_note_duration:	= $22F
v_sfx_fm3_curr_note:	= $230
v_sfx_fm3_note_fill:	= $232
v_sfx_fm3_note_fill_master:	= $233
v_sfx_fm3_modulation_ptr:	= $234	; 4 bytes
v_sfx_fm3_modulation_wait:	= $238
v_sfx_fm3_modulation_speed:	= $239
v_sfx_fm3_modulation_delta:	= $23A
v_sfx_fm3_modulation_steps:	= $23B
v_sfx_fm3_modulation_freq:	= $23C	; 2 bytes
v_sfx_fm3_freq_adjust:	= $23E
v_sfx_fm3_feedbackalgo:	= $23F
v_sfx_fm3_voice_ptr:	= $240
v_sfx_fm3_loop_index:	= $244	; Several bytes, may overlap with gosub/return stack

v_sfx_fm4_track:	= $250
v_sfx_fm4_playback_control:	= $250	; Playback control bits for sfx FM4
v_sfx_fm4_voice_control:	= $251	; Voice control bits
v_sfx_fm4_tempo_time:	= $252	; sfx - tempo dividing timing
v_sfx_fm4_ptr:		= $254	; FM channel 4 pointer (4 bytes)
v_sfx_fm4_key:		= $258	; FM channel 4 key displacement
v_sfx_fm4_volume:	= $259	; FM channel 4 volume attenuation
v_sfx_fm4_amsfmspan:	= $25A
v_sfx_fm4_voice:	= $25B
v_sfx_fm4_stack_ptr:	= $25D
v_sfx_fm4_note_timeout:	= $25E	; Counts down to zero; when zero, a new note is needed
v_sfx_fm4_note_duration:	= $25F
v_sfx_fm4_curr_note:	= $260
v_sfx_fm4_note_fill:	= $262
v_sfx_fm4_note_fill_master:	= $263
v_sfx_fm4_modulation_ptr:	= $264	; 4 bytes
v_sfx_fm4_modulation_wait:	= $268
v_sfx_fm4_modulation_speed:	= $269
v_sfx_fm4_modulation_delta:	= $26A
v_sfx_fm4_modulation_steps:	= $26B
v_sfx_fm4_modulation_freq:	= $26C	; 2 bytes
v_sfx_fm4_freq_adjust:	= $26E
v_sfx_fm4_feedbackalgo:	= $26F
v_sfx_fm4_voice_ptr:	= $270
v_sfx_fm4_loop_index:	= $274	; Several bytes, may overlap with gosub/return stack

v_sfx_fm5_track:	= $280
v_sfx_fm5_playback_control:	= $280	; Playback control bits for sfx FM5
v_sfx_fm5_voice_control:	= $281	; Voice control bits
v_sfx_fm5_tempo_time:	= $282	; sfx - tempo dividing timing
v_sfx_fm5_ptr:	= $284	; FM channel 5 pointer (4 bytes)
v_sfx_fm5_key:	= $288	; FM channel 5 key displacement
v_sfx_fm5_volume:	= $289	; FM channel 5 volume attenuation
v_sfx_fm5_amsfmspan:	= $28A
v_sfx_fm5_voice:	= $28B
v_sfx_fm5_stack_ptr:	= $28D
v_sfx_fm5_note_timeout:	= $28E	; Counts down to zero; when zero, a new note is needed
v_sfx_fm5_note_duration:	= $28F
v_sfx_fm5_curr_note:	= $290
v_sfx_fm5_note_fill:	= $292
v_sfx_fm5_note_fill_master:	= $293
v_sfx_fm5_modulation_ptr:	= $294	; 4 bytes
v_sfx_fm5_modulation_wait:	= $298
v_sfx_fm5_modulation_speed:	= $299
v_sfx_fm5_modulation_delta:	= $29A
v_sfx_fm5_modulation_steps:	= $29B
v_sfx_fm5_modulation_freq:	= $29C	; 2 bytes
v_sfx_fm5_freq_adjust:	= $29E
v_sfx_fm5_feedbackalgo:	= $29F
v_sfx_fm5_voice_ptr:	= $2A0
v_sfx_fm5_loop_index:	= $2A4	; Several bytes, may overlap with gosub/return stack

v_sfx_psg1_track:	= $2B0
v_sfx_psg1_playback_control:	= $2B0	; Playback control bits for sfx PSG1
v_sfx_psg1_voice_control:	= $2B1	; Voice control bits
v_sfx_psg1_tempo_time:	= $2B2	; sfx - tempo dividing timing
v_sfx_psg1_ptr:	= $2B4	; PSG channel 1 pointer (4 bytes)
v_sfx_psg1_key:	= $2B8	; PSG channel 1 key displacement
v_sfx_psg1_volume:	= $2B9	; PSG channel 1 volume attenuation
v_sfx_psg1_amsfmspan:	= $2BA
v_sfx_psg1_tone:	= $2BB
v_sfx_psg1_flutter_index:	= $2BC
v_sfx_psg1_stack_ptr:	= $2BD
v_sfx_psg1_note_timeout:	= $2BE	; Counts down to zero; when zero, a new note is needed
v_sfx_psg1_note_duration:	= $2BF
v_sfx_psg1_curr_note:	= $2C0
v_sfx_psg1_note_fill:	= $2C2
v_sfx_psg1_note_fill_master:	= $2C3
v_sfx_psg1_modulation_ptr:	= $2C4	; 4 bytes
v_sfx_psg1_modulation_wait:	= $2C8
v_sfx_psg1_modulation_speed:	= $2C9
v_sfx_psg1_modulation_delta:	= $2CA
v_sfx_psg1_modulation_steps:	= $2CB
v_sfx_psg1_modulation_freq:	= $2CC	; 2 bytes
v_sfx_psg1_freq_adjust:	= $2CE
v_sfx_psg1_noise:	= $2CF
v_sfx_psg1_loop_index:	= $2D4	; Several bytes, may overlap with gosub/return stack

v_sfx_psg2_track:	= $2E0
v_sfx_psg2_playback_control:	= $2E0	; Playback control bits for sfx PSG2
v_sfx_psg2_voice_control:	= $2E1	; Voice control bits
v_sfx_psg2_tempo_time:	= $2E2	; sfx - tempo dividing timing
v_sfx_psg2_ptr:	= $2E4	; PSG channel 2 pointer (4 bytes)
v_sfx_psg2_key:	= $2E8	; PSG channel 2 key displacement
v_sfx_psg2_volume:	= $2E9	; PSG channel 2 volume attenuation
v_sfx_psg2_amsfmspan:	= $2EA
v_sfx_psg2_tone:	= $2EB
v_sfx_psg2_flutter_index:	= $2EC
v_sfx_psg2_stack_ptr:	= $2ED
v_sfx_psg2_note_timeout:	= $2EE	; Counts down to zero; when zero, a new note is needed
v_sfx_psg2_note_duration:	= $2EF
v_sfx_psg2_curr_note:	= $2F0
v_sfx_psg2_note_fill:	= $2F2
v_sfx_psg2_note_fill_master:	= $2F3
v_sfx_psg2_modulation_ptr:	= $2F4	; 4 bytes
v_sfx_psg2_modulation_wait:	= $2F8
v_sfx_psg2_modulation_speed:	= $2F9
v_sfx_psg2_modulation_delta:	= $2FA
v_sfx_psg2_modulation_steps:	= $2FB
v_sfx_psg2_modulation_freq:	= $2FC	; 2 bytes
v_sfx_psg2_freq_adjust:	= $2FE
v_sfx_psg2_noise:	= $2FF
v_sfx_psg2_loop_index:	= $304	; Several bytes, may overlap with gosub/return stack

v_sfx_psg3_track:	= $310
v_sfx_psg3_playback_control:	= $310	; Playback control bits for sfx PSG3
v_sfx_psg3_voice_control:	= $311	; Voice control bits
v_sfx_psg3_tempo_time:	= $312	; sfx - tempo dividing timing
v_sfx_psg3_ptr:	= $314	; PSG channel 3 pointer (4 bytes)
v_sfx_psg3_key:	= $318	; PSG channel 3 key displacement
v_sfx_psg3_volume:	= $319	; PSG channel 3 volume attenuation
v_sfx_psg3_amsfmspan:	= $31A
v_sfx_psg3_tone:	= $31B
v_sfx_psg3_flutter_index:	= $31C
v_sfx_psg3_stack_ptr:	= $31D
v_sfx_psg3_note_timeout:	= $31E	; Counts down to zero; when zero, a new note is needed
v_sfx_psg3_note_duration:	= $31F
v_sfx_psg3_curr_note:	= $320
v_sfx_psg3_note_fill:	= $322
v_sfx_psg3_note_fill_master:	= $323
v_sfx_psg3_modulation_ptr:	= $324	; 4 bytes
v_sfx_psg3_modulation_wait:	= $328
v_sfx_psg3_modulation_speed:	= $329
v_sfx_psg3_modulation_delta:	= $32A
v_sfx_psg3_modulation_steps:	= $32B
v_sfx_psg3_modulation_freq:	= $32C	; 2 bytes
v_sfx_psg3_freq_adjust:	= $32E
v_sfx_psg3_noise:	= $32F
v_sfx_psg3_loop_index:	= $334	; Several bytes, may overlap with gosub/return stack

v_sfx2_track_ram:	= $340	; Start of special sfx RAM

v_sfx2_fm4_track:	= $340
v_sfx2_fm4_playback_control:	= $340	; Playback control bits for sfx FM4
v_sfx2_fm4_voice_control:	= $341	; Voice control bits
v_sfx2_fm4_tempo_time:	= $342	; sfx - tempo dividing timing
v_sfx2_fm4_ptr:	= $344	; FM channel 4 pointer (4 bytes)
v_sfx2_fm4_key:	= $348	; FM channel 4 key displacement
v_sfx2_fm4_volume:	= $349	; FM channel 4 volume attenuation
v_sfx2_fm4_amsfmspan:	= $34A
v_sfx2_fm4_voice:	= $34B
v_sfx2_fm4_stack_ptr:	= $34D
v_sfx2_fm4_note_timeout:	= $34E	; Counts down to zero; when zero, a new note is needed
v_sfx2_fm4_note_duration:	= $34F
v_sfx2_fm4_curr_note:	= $350
v_sfx2_fm4_note_fill:	= $352
v_sfx2_fm4_note_fill_master:	= $353
v_sfx2_fm4_modulation_ptr:	= $354	; 4 bytes
v_sfx2_fm4_modulation_wait:	= $358
v_sfx2_fm4_modulation_speed:	= $359
v_sfx2_fm4_modulation_delta:	= $35A
v_sfx2_fm4_modulation_steps:	= $35B
v_sfx2_fm4_modulation_freq:	= $35C	; 2 bytes
v_sfx2_fm4_freq_adjust:	= $35E
v_sfx2_fm4_feedbackalgo:	= $35F
v_sfx2_fm4_voice_ptr:	= $360
v_sfx2_fm4_loop_index:	= $364	; Several bytes, may overlap with gosub/return stack

v_sfx2_psg3_track:	= $370
v_sfx2_psg3_playback_control:	= $370	; Playback control bits for sfx PSG3
v_sfx2_psg3_voice_control:	= $371	; Voice control bits
v_sfx2_psg3_tempo_time:	= $372	; sfx - tempo dividing timing
v_sfx2_psg3_ptr:	= $374	; PSG channel 3 pointer (4 bytes)
v_sfx2_psg3_key:	= $378	; PSG channel 3 key displacement
v_sfx2_psg3_volume:	= $379	; PSG channel 3 volume attenuation
v_sfx2_psg3_amsfmspan:	= $37A
v_sfx2_psg3_tone:	= $37B
v_sfx2_psg3_flutter_index:	= $37C
v_sfx2_psg3_stack_ptr:	= $37D
v_sfx2_psg3_note_timeout:	= $37E	; Counts down to zero; when zero, a new note is needed
v_sfx2_psg3_note_duration:	= $37F
v_sfx2_psg3_curr_note:	= $380
v_sfx2_psg3_note_fill:	= $382
v_sfx2_psg3_note_fill_master:	= $383
v_sfx2_psg3_modulation_ptr:	= $384	; 4 bytes
v_sfx2_psg3_modulation_wait:	= $388
v_sfx2_psg3_modulation_speed:	= $389
v_sfx2_psg3_modulation_delta:	= $38A
v_sfx2_psg3_modulation_steps:	= $38B
v_sfx2_psg3_modulation_freq:	= $38C	; 2 bytes
v_sfx2_psg3_freq_adjust:	= $38E
v_sfx2_psg3_noise:	= $38F
v_sfx2_psg3_loop_index:	= $394	; Several bytes, may overlap with gosub/return stack

v_1up_ram_copy:	= $3A0

f_fastmusic:	= $3CA	; flag set to speed up the music (00 = normal; 80 = fast)

;Consts
PSG: 		equ $C00011
zTrackSz:	equ $30

; Sound effects
sfx_Jump:	equ ((ptr_sndA0-SoundIndex)/4)+$A0
sfx_Lamppost:	equ ((ptr_sndA1-SoundIndex)/4)+$A0
sfx_A2:		equ ((ptr_sndA2-SoundIndex)/4)+$A0
sfx_Death:	equ ((ptr_sndA3-SoundIndex)/4)+$A0
sfx_Skid:	equ ((ptr_sndA4-SoundIndex)/4)+$A0
sfx_A5:		equ ((ptr_sndA5-SoundIndex)/4)+$A0
sfx_HitSpikes:	equ ((ptr_sndA6-SoundIndex)/4)+$A0
sfx_Push:	equ ((ptr_sndA7-SoundIndex)/4)+$A0
sfx_SSGoal:	equ ((ptr_sndA8-SoundIndex)/4)+$A0
sfx_SSItem:	equ ((ptr_sndA9-SoundIndex)/4)+$A0
sfx_Splash:	equ ((ptr_sndAA-SoundIndex)/4)+$A0
sfx_AB:		equ ((ptr_sndAB-SoundIndex)/4)+$A0
sfx_HitBoss:	equ ((ptr_sndAC-SoundIndex)/4)+$A0
sfx_Bubble:	equ ((ptr_sndAD-SoundIndex)/4)+$A0
sfx_Fireball:	equ ((ptr_sndAE-SoundIndex)/4)+$A0
sfx_Shield:	equ ((ptr_sndAF-SoundIndex)/4)+$A0
sfx_Saw:	equ ((ptr_sndB0-SoundIndex)/4)+$A0
sfx_Electric:	equ ((ptr_sndB1-SoundIndex)/4)+$A0
sfx_Drown:	equ ((ptr_sndB2-SoundIndex)/4)+$A0
sfx_Flamethrower:equ ((ptr_sndB3-SoundIndex)/4)+$A0
sfx_Bumper:	equ ((ptr_sndB4-SoundIndex)/4)+$A0
sfx_Ring:	equ ((ptr_sndB5-SoundIndex)/4)+$A0
sfx_SpikesMove:	equ ((ptr_sndB6-SoundIndex)/4)+$A0
sfx_Rumbling:	equ ((ptr_sndB7-SoundIndex)/4)+$A0
sfx_B8:		equ ((ptr_sndB8-SoundIndex)/4)+$A0
sfx_Collapse:	equ ((ptr_sndB9-SoundIndex)/4)+$A0
sfx_SSGlass:	equ ((ptr_sndBA-SoundIndex)/4)+$A0
sfx_Door:	equ ((ptr_sndBB-SoundIndex)/4)+$A0
sfx_Teleport:	equ ((ptr_sndBC-SoundIndex)/4)+$A0
sfx_ChainStomp:	equ ((ptr_sndBD-SoundIndex)/4)+$A0
sfx_Roll:	equ ((ptr_sndBE-SoundIndex)/4)+$A0
sfx_Continue:	equ ((ptr_sndBF-SoundIndex)/4)+$A0
sfx_Basaran:	equ ((ptr_sndC0-SoundIndex)/4)+$A0
sfx_BreakItem:	equ ((ptr_sndC1-SoundIndex)/4)+$A0
sfx_Warning:	equ ((ptr_sndC2-SoundIndex)/4)+$A0
sfx_GiantRing:	equ ((ptr_sndC3-SoundIndex)/4)+$A0
sfx_Bomb:	equ ((ptr_sndC4-SoundIndex)/4)+$A0
sfx_Cash:	equ ((ptr_sndC5-SoundIndex)/4)+$A0
sfx_RingLoss:	equ ((ptr_sndC6-SoundIndex)/4)+$A0
sfx_ChainRise:	equ ((ptr_sndC7-SoundIndex)/4)+$A0
sfx_Burning:	equ ((ptr_sndC8-SoundIndex)/4)+$A0
sfx_Bonus:	equ ((ptr_sndC9-SoundIndex)/4)+$A0
sfx_EnterSS:	equ ((ptr_sndCA-SoundIndex)/4)+$A0
sfx_WallSmash:	equ ((ptr_sndCB-SoundIndex)/4)+$A0
sfx_Spring:	equ ((ptr_sndCC-SoundIndex)/4)+$A0
sfx_Switch:	equ ((ptr_sndCD-SoundIndex)/4)+$A0
sfx_RingLeft:	equ ((ptr_sndCE-SoundIndex)/4)+$A0
sfx_Signpost:	equ ((ptr_sndCF-SoundIndex)/4)+$A0
sfx_Waterfall:	equ $D0
sfx_Sega:	equ $E1

bgm_ExtraLife	equ	$9F

; ---------------------------------------------------------------------------
Go_SoundPriorities:	dc.l SoundPriorities
Go_SoundD0:		dc.l ptr_sndD0
Go_MusicIndex:		dc.l MusicIndex
Go_MusicIndex2:		dc.l MusicIndex2
Go_SoundIndex:		dc.l SoundIndex
Go_SpeedUpIndex:	dc.l SpeedUpIndex
Go_PSGIndex:		dc.l PSG_Index

; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------

PSG_Index:
		dc.l PSG1, PSG2, PSG3
		dc.l PSG4, PSG5, PSG6
		dc.l PSG7, PSG8, PSG9
PSG1:		incbin	"sound/psg1.bin"
PSG2:		incbin	"sound/psg2.bin"
PSG3:		incbin	"sound/psg3.bin"
PSG4:		incbin	"sound/psg4.bin"
PSG6:		incbin	"sound/psg6.bin"
PSG5:		incbin	"sound/psg5.bin"
PSG7:		incbin	"sound/psg7.bin"
PSG8:		incbin	"sound/psg8.bin"
PSG9:		incbin	"sound/psg9.bin"

; ---------------------------------------------------------------------------
; New tempos for songs during speed shoes
; ---------------------------------------------------------------------------
; DANGER! several songs will use the first few bytes of MusicIndex as their main
; tempos while speed shoes are active. If you don't want that, you should add
; their "correct" sped-up main tempos to the list.
; ---------------------------------------------------------------------------

SpeedUpIndex:	dc.b 7,	$72, $73, $26, $15, 8, $FF, 5

; ---------------------------------------------------------------------------
; Priority of sound. New music or SFX must have a priority higher than or equal
; to what is stored in v_sndprio or it won't play. If bit 7 of new priority is
; set ($80 and up), the new music or SFX will not set its priority -- meaning
; any music or SFX can override it (as long as it can override whatever was
; playing before). Usually, SFX will only override SFX, special SFX ($D0-$DF)
; will only override special SFX and music will only override music.
; ---------------------------------------------------------------------------

SoundPriorities:
		dc.b     $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $80+
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $90+
		dc.b $80,$70,$70,$70,$70,$70,$70,$70,$70,$70,$68,$70,$70,$70,$60,$70	; $A0+
		dc.b $70,$60,$70,$60,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$7F	; $B0+
		dc.b $60,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70	; $C0+
		dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80	; $D0+
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $E0+
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $F0+
		even
		
; ===========================================================================
; Several subroutines from Sonic 1
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	load the sound driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SoundDriverLoad:			; XREF: GameClrRAM; TitleScreen
		nop
		move.w	#$100,d0
		move.w	d0,($A11100).l
		move.w	d0,($A11200).l
		lea	(MegaPCM).l,a0
		lea	($A00000).l,a1
		move.w	#(MegaPCM_End-MegaPCM)-1,d1

	@Load:	move.b	(a0)+,(a1)+
		dbf	d1,@Load
		moveq	#0,d1
		move.w	d1,($A11200).l
		nop
		nop
		nop
		nop
		move.w	d0,($A11200).l
		move.w	d1,($A11100).l
		rts
; End of function SoundDriverLoad

; ---------------------------------------------------------------------------
; Subroutine to	play a DAC sample
; ---------------------------------------------------------------------------

PlaySample:
	move.w	#$100,($A11100).l	; остановка Z80
@0	btst	#0,($A11100).l
	bne.s	@0
	move.b	d0,$A01FFF
	move.w	#0,($A11100).l
	rts

; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlaySound:
		move.b	d0,($FFFFF00A).w
		rts	
; End of function PlaySound



; ---------------------------------------------------------------------------
; Subroutine to update music more than once per frame
; (Called by horizontal & vert. interrupts)
; ---------------------------------------------------------------------------

;sub_71B4C:
UpdateMusic:				; XREF: VBlank; HBlank

; ---------------------------------------------------------------------------
; PAL-modifier
; ---------------------------------------------------------------------------

;		tst.b	SMPS_PALTimer		; is mode PAL
;		beq.s	@SMPS_Proc		; if not, branch
;		subq.b	#1,SMPS_PALTimer
;		bne.s	@SMPS_Proc
;		bsr.s	@SMPS_Proc
;		move.b	#6,SMPS_PALTimer

@SMPS_Proc:
; ---------------------------------------------------------------------------
		lea	(v_snddriver_ram&$FFFFFF).l,a6
		clr.b	f_voice_selector(a6)
		tst.b	f_stopmusic(a6)			; is music paused?
		bne.w	PauseMusic			; if yes, branch



		subq.b	#1,v_main_tempo_timeout(a6)	; Has main tempo timer expired?
		bne.s	@skipdelay
		jsr	TempoWait(pc)

@skipdelay:
		move.b	v_fadeout_counter(a6),d0
		beq.s	@skipfadeout
		jsr	DoFadeOut(pc)

@skipfadeout:
		tst.b	f_fadein_flag(a6)
		beq.s	@skipfadein
		jsr	DoFadeIn(pc)

@skipfadein:
		tst.w	v_playsnd1(a6)		; is a music or sound queued for played?
		beq.s	@nosndinput		; if not, branch
		jsr	Sound_Play(pc)

@nosndinput:
		cmpi.b	#$80,v_playsnd0(a6)	; is song queue set for silence?
		beq.s	@nonewsound		; If yes, branch
		jsr	Sound_ChkValue(pc)

@nonewsound:
		lea	v_dac_track(a6),a5
		tst.b	(a5)			; Is DAC track playing?
		bpl.s	@dacdone		; Branch if not
		jsr	UpdateDAC(pc)

@dacdone:
		clr.b	f_updating_dac(a6)
		moveq	#5,d7
		
		lea	FMUpdateTrack,a0	; ++ use standard FM update routine
		tst.b	v_extension(a6)		; ++ is extension active?
		beq.s	@0			; ++ if not, branch
		lea	TS_FM_UpdateChannel,a0	; ++ use extension FM update routine
	@0:

@bgmfmloop:
		lea	zTrackSz(a5),a5
		tst.b	(a5)		; Is track playing?
		bpl.s	@bgmfmnext	; Branch if not
		move.l	a0,-(sp)
		jsr	(a0)
		move.l	(sp)+,a0

@bgmfmnext:
		dbf	d7,@bgmfmloop

		moveq	#2,d7

@bgmpsgloop:
		adda.w	#zTrackSz,a5
		tst.b	(a5)
		bpl.s	@bgmpsgnext
		jsr	PSGUpdateTrack(pc)

@bgmpsgnext:
		dbf	d7,@bgmpsgloop

		move.b	#$80,f_voice_selector(a6)	; Now at SFX tracks
		moveq	#2,d7

@sfxfmloop:
		adda.w	#zTrackSz,a5
		tst.b	(a5)		; Is track playing?
		bpl.s	@sfxfmnext	; Branch if not
		jsr	FMUpdateTrack(pc)

@sfxfmnext:
		dbf	d7,@sfxfmloop

		moveq	#2,d7

@sfxpsgloop:
		adda.w	#zTrackSz,a5
		tst.b	(a5)
		bpl.s	@sfxpsgnext
		jsr	PSGUpdateTrack(pc)

@sfxpsgnext:
		dbf	d7,@sfxpsgloop
		
		move.b	#$40,f_voice_selector(a6)	; Now at special SFX tracks
		adda.w	#zTrackSz,a5
		tst.b	(a5)		; Is track playing?
		bpl.s	@specfmdone	; Branch if not
		jsr	FMUpdateTrack(pc)

@specfmdone:
		adda.w	#zTrackSz,a5
		tst.b	(a5)
		bpl.s	UpdateMusic_Done
		jsr	PSGUpdateTrack(pc)

UpdateMusic_Done:
		rts
; End of function UpdateMusic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


UpdateDAC:
		subq.b	#1,$E(a5)	; Has DAC sample timeout expired?
		bne.s	@locret	; Return if not
		move.b	#$80,f_updating_dac(a6)	; Set flag to indicate this is the DAC
		movea.l	4(a5),a4	; DAC track data pointer

@sampleloop:
		moveq	#0,d5
		move.b	(a4)+,d5	; Get next SMPS unit
		cmpi.b	#$E0,d5		; Is it a coord. flag?
		blo.s	@notcoord	; Branch if not
		jsr	CoordFlag(pc)
		bra.s	@sampleloop
; ===========================================================================

@notcoord:
		tst.b	d5			; Is it a sample?
		bpl.s	@gotduration	; Branch if not (duration)
		move.b	d5,$10(a5)	; Store new sample
		move.b	(a4)+,d5	; Get another byte
		bpl.s	@gotduration	; Branch if it is a duration
		subq.w	#1,a4		; Put byte back
		move.b	$F(a5),$E(a5)	; Use last duration
		bra.s	@gotsampleduration
; ===========================================================================

@gotduration:
		jsr	SetDuration(pc)

@gotsampleduration:
		move.l	a4,4(a5)	; Save pointer
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@locret	; Return if yes
		moveq	#0,d0
		move.b	$10(a5),d0	; Get sample
		cmpi.b	#$80,d0		; Is it a rest?
		beq.s	@locret		; Return if yes      
		
		move.b	d0,$28(a5)	; ++

		stopZ80
		move.b	d0,($A01FFF).l
		startZ80

@locret:
		rts
; End of function UpdateDAC

; ===========================================================================
; Note: this only defines rates for samples $88-$8D, meaning $8E-$8F are invalid.
; Also, $8C-$8D are so slow you may want to skip them.
DAC_sample_rate: dc.b $12, $15, $1C, $1D, $FF, $FF

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMUpdateTrack:
		subq.b	#1,$E(a5)	; Update duration timeout
		bne.s	@notegoing	; Branch if it hasn't expired
		bclr	#4,(a5)		; Clear do not attack next note bit
		jsr	FMDoNext(pc)
		jsr	FMPrepareNote(pc)
		bra.w	FMNoteOn
; ===========================================================================

@notegoing:
		jsr	NoteFillUpdate(pc)
		jsr	DoModulation(pc)
		bra.w	FMUpdateFreq
; End of function FMUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMDoNext:
		movea.l	4(a5),a4	; Track data pointer
		bclr	#1,(a5)		; Clear 'track at rest' bit

@noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5	; Get byte from track
		cmpi.b	#$E0,d5		; Is this a coord. flag?
		blo.s	@gotnote	; Branch if not
		jsr	CoordFlag(pc)
		bra.s	@noteloop
; ===========================================================================

@gotnote:
		jsr	FMNoteOff(pc)
		tst.b	d5			; Is this a note?
		bpl.s	@gotduration	; Branch if not
		jsr	FMSetFreq(pc)
		move.b	(a4)+,d5	; Get another byte
		bpl.s	@gotduration	; Branch if it is a duration
		subq.w	#1,a4		; Otherwise, put it back
		bra.w	FinishTrackUpdate
; ===========================================================================

@gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function FMDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMSetFreq:
		subi.b	#$80,d5		; Make it a zero-based index
		beq.s	TrackSetRest
		add.b	8(a5),d5	; Add track key displacement
		andi.w	#$7F,d5		; Clear high byte and sign bit
		lsl.w	#1,d5
		lea	FM_Notes(pc),a0
		move.w	(a0,d5.w),d6
		move.w	d6,$10(a5)	; Store new frequency
		rts	
; End of function FMSetFreq


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetDuration:
		move.b	d5,d0
		move.b	2(a5),d1	; Get dividing timing

@multloop:
		subq.b	#1,d1
		beq.s	@donemult
		add.b	d5,d0
		bra.s	@multloop
; ===========================================================================

@donemult:
		move.b	d0,$F(a5)	; Save duration
		move.b	d0,$E(a5)	; Save duration timeout
		rts	
; End of function SetDuration

; ===========================================================================

TrackSetRest:
		bset	#1,(a5)		; Set track at rest bit
		clr.w	$10(a5)		; Clear frequency

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FinishTrackUpdate:
		move.l	a4,4(a5)	; Store new track position
		move.b	$F(a5),$E(a5)	; Reset note timeout
		btst	#4,(a5)		; Is track set to not attack note?
		bne.s	@locret		; If so, branch
		move.b	$13(a5),$12(a5)		; Reset note fill timeout
		clr.b	$C(a5)		; Reset PSG flutter index
		btst	#3,(a5)		; Is modulation on?
		beq.s	@locret		; If not, return
		movea.l	$14(a5),a0	; Modulation data pointer
		move.b	(a0)+,$18(a5)	; Reset wait
		move.b	(a0)+,$19(a5)	; Reset speed
		move.b	(a0)+,$1A(a5)	; Reset delta
		move.b	(a0)+,d0	; Get steps
		lsr.b	#1,d0		; Halve them
		move.b	d0,$1B(a5)	; Then store
		clr.w	$1C(a5)		; Reset frequency change

@locret:
		rts	
; End of function FinishTrackUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NoteFillUpdate:
		tst.b	$12(a5)		; Is note fill on?
		beq.s	@locret
		subq.b	#1,$12(a5)	; Update note fill timeout
		bne.s	@locret		; Return if it hasn't expired
		bset	#1,(a5)		; Put track at rest
		tst.b	1(a5)		; Is this a psg track?
		bmi.w	@psgnoteoff	; If yes, branch
		jsr	FMNoteOff(pc)
		addq.w	#4,sp		; Do not return to caller
		rts	
; ===========================================================================

@psgnoteoff:
		jsr	PSGNoteOff(pc)
		addq.w	#4,sp		; Do not return to caller

@locret:
		rts	
; End of function NoteFillUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoModulation:
		addq.w	#4,sp		; Do not return to caller (but see below)
		btst	#3,(a5)		; Is modulation active?
		beq.s	@locret		; Return if not
		tst.b	$18(a5)		; Has modulation wait expired?
		beq.s	@waitdone	; If yes, branch
		subq.b	#1,$18(a5)	; Update wait timeout
		rts	
; ===========================================================================

@waitdone:
		subq.b	#1,$19(a5)	; Update speed
		beq.s	@updatemodulation	; If it expired, want to update modulation
		rts	
; ===========================================================================

@updatemodulation:
		movea.l	$14(a5),a0	; Get modulation data
		move.b	1(a0),$19(a5)	; Restore modulation speed
		tst.b	$1B(a5)		; Check number of steps
		bne.s	@calcfreq	; If nonzero, branch
		move.b	3(a0),$1B(a5)	; Restore from modulation data
		neg.b	$1A(a5)		; Negate modulation delta
		rts	
; ===========================================================================

@calcfreq:
		subq.b	#1,$1B(a5)	; Update modulation steps
		move.b	$1A(a5),d6	; Get modulation delta
		ext.w	d6
		add.w	$1C(a5),d6	; Add cumulative modulation change
		move.w	d6,$1C(a5)	; Store it
		add.w	$10(a5),d6	; Add note frequency to it
		subq.w	#4,sp		; In this case, we want to return to caller after all

@locret:
		rts	
; End of function DoModulation


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMPrepareNote:
		btst	#1,(a5)		; Is track resting?
		bne.s	locret_71E48	; Return if so
		move.w	$10(a5),d6		; Get current note frequency
		beq.s	FMSetRest		; Branch if zero

FMUpdateFreq:
		move.b	$1E(a5),d0	; Get frequency adjustment
		ext.w	d0
		add.w	d0,d6		; Add note frequency
		btst	#2,(a5)		; Is track being overridden?
		bne.s	locret_71E48	; Return if so
		move.w	d6,d1
		lsr.w	#8,d1
		move.b	#$A4,d0		; Register for upper 6 bits of frequency
		jsr	WriteFMIorII(pc)
		move.b	d6,d1
		move.b	#$A0,d0		; Register for lower 8 bits of frequency
		jsr	WriteFMIorII(pc)

locret_71E48:
		rts	
; ===========================================================================

FMSetRest:
		bset	#1,(a5)		; Set track at rest bit
		rts	
; End of function FMPrepareNote

; ===========================================================================

PauseMusic:
		bmi	@unpausemusic		; Branch if music is being unpaused
		cmpi.b	#2,f_stopmusic(a6)
		beq.w	@unpausedallfm
		move.b	#2,f_stopmusic(a6)
		
;	tst.b	v_cda_playing(a6)
;	beq.s	@0
;	mcdsend	#_MCD_PauseTrack
;@0

		moveq	#2,d3
		move.b	#$B4,d0		; Command to set AMS/FMS/panning
		moveq	#0,d1		; No panning, AMS or FMS

@killpanloop:
		jsr	WriteFMI(pc)
		jsr	WriteFMII(pc)
		addq.b	#1,d0
		dbf	d3,@killpanloop

		moveq	#2,d3
		moveq	#$28,d0		; Key on/off register

@noteoffloop:
		move.b	d3,d1		; FM1, FM2, FM3
		jsr	WriteFMI(pc)
		addq.b	#4,d1		; FM4, FM5, FM6
		jsr	WriteFMI(pc)
		dbf	d3,@noteoffloop

		stopZ80
		move.b	#$7F,($A01FFF).l; pause DAC
		startZ80

		jsr	PSGSilenceAll(pc)
		bra.w	UpdateMusic_Done
; ===========================================================================

@unpausemusic:
		clr.b	f_stopmusic(a6)

;	tst.b	v_cda_playing(a6)
;	beq.s	@1
;	mcdsend	#_MCD_UnPauseTrack
;@1

		moveq	#zTrackSz,d3
		lea	v_track_ram(a6),a5
		moveq	#6,d4

@bgmfmloop:
		btst	#7,(a5)		; Is track playing?
		beq.s	@bgmfmnext	; Branch if not
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@bgmfmnext	; Branch if yes
		move.b	#$B4,d0		; Command to set AMS/FMS/panning
		move.b	$A(a5),d1	; Get value from track RAM
		jsr	WriteFMIorII(pc)

@bgmfmnext:
		adda.w	d3,a5
		dbf	d4,@bgmfmloop

		lea	v_sfx_track_ram(a6),a5
		moveq	#2,d4

@sfxfmloop:
		btst	#7,(a5)		; Is track playing?
		beq.s	@sfxfmnext	; Branch if not
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@sfxfmnext	; Branch if yes
		move.b	#$B4,d0		; Command to set AMS/FMS/panning
		move.b	$A(a5),d1	; Get value from track RAM
		jsr	WriteFMIorII(pc)

@sfxfmnext:
		adda.w	d3,a5
		dbf	d4,@sfxfmloop

		lea	v_sfx2_track_ram(a6),a5
		btst	#7,(a5)		; Is track playing?
		beq.s	@unpausedac	; Branch if not
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@unpausedac	; Branch if yes
		move.b	#$B4,d0		; Command to set AMS/FMS/panning
		move.b	$A(a5),d1	; Get value from track RAM
		jsr	WriteFMIorII(pc)

@unpausedac:
		stopZ80
		move.b	#0,($A01FFF).l	; unpause DAC
		startZ80

@unpausedallfm:
		bra.w	UpdateMusic_Done

; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sound_Play:				; XREF: UpdateMusic
	movea.l	(Go_SoundPriorities).l,a0
	lea	v_playqueue(a6),a1		; load sound queue
	move.b	v_sndprio(a6),d3		; Get priority of currently playing SFX

	move.b	(a1)+,d0			; get sound id to play
	beq.s	@locret				; if nothing to play, branch
	move.b	d0,d1
	subi.b	#$81,d0				; Make it into 0-based index
	cmpi.b	#$80,v_playsnd0(a6)		; is SMPS processing a sound already?
	bne.s	@locret				; If yes, branch

	; Get ready to play sound
	andi.w	#$7F,d0				; Clear high byte and sign bit
	move.b	(a0,d0.w),d2			; Get sound type
	cmp.b	d3,d2				; Is it a lower priority sound?
	blo.s	@shiftqueue			; Branch if yes
	move.b	d1,v_playsnd0(a6)		; Queue sound for play
	move.b	d2,d3				; Store new priority
	bmi.s	@shiftqueue			; We don't want to change sound priority if it is negative
	move.b	d3,v_sndprio(a6)

@shiftqueue:
	; Shifting sound queue
	lea	-1(a1),a0
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)				; clear last queue entry

@locret:
	rts


;		movea.l	(Go_SoundPriorities).l,a0
;		lea	v_playsnd1(a6),a1	; load music track number
;		move.b	v_sndprio(a6),d3	; Get priority of currently playing SFX
;		moveq	#2,d4
;
;@inputloop:
;		move.b	(a1),d0		; move track number to d0
;		move.b	d0,d1
;		clr.b	(a1)+		; Clear entry
;		subi.b	#$81,d0		; Make it into 0-based index
;		blo.s	@nextinput	; If negative (i.e., it was $80 or lower), branch
;		cmpi.b	#$80,v_playsnd0(a6)	; Is v_playsnd0 a $80 (silence)?
;		beq.s	@havesound	; If yes, branch
;		move.b	d1,v_playsnd1(a6)	; Put sound into v_playsnd1
;		bra.s	@nextinput
;; ===========================================================================
;
;@havesound:
;		andi.w	#$7F,d0		; Clear high byte and sign bit
;		move.b	(a0,d0.w),d2	; Get sound type
;		cmp.b	d3,d2		; Is it a lower priority sound?
;		blo.s	@nextinput	; Branch if yes
;		move.b	d2,d3		; Store new priority
;		move.b	d1,v_playsnd0(a6)	; Queue sound for play
;
;@nextinput:
;		dbf	d4,@inputloop
;
;		tst.b	d3		; We don't want to change sound priority if it is negative
;		bmi.s	@locret
;		move.b	d3,v_sndprio(a6)	; Set new sound priority
;
;@locret:
;		rts
; End of function Sound_Play


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sound_ChkValue:
		moveq	#0,d7
		move.b	v_playsnd0(a6),d7
		beq.w	StopSoundAndMusic
		bpl.s	@locret			; If >= 0, return (not a valid sound, bgm or command)
		move.b	#$80,v_playsnd0(a6)	; reset	music flag
		cmpi.b	#$9F,d7			; Is this music ($81-$9F)?
		bls.w	Sound_PlayBGM		; Branch if yes
		cmpi.b	#$CF,d7			; Is this sfx ($A0-$CF)?
		bls.w	Sound_PlaySFX		; Branch if yes
		cmpi.b	#$D0,d7			; Is this sound $D0?
		beq.w	Sound_PlaySpecial	; Branch if yes
		cmpi.b	#$DF,d7			; Is this sound $D1-$DF?
		bls	Sound_PlaySFX
		cmpi.b	#$E4,d7			; Is this $E0-$E4?
		bls.s	Sound_E0toE4		; Branch if yes
	;	bra.s	Sound_CDA		; $E5-$FF
		bra.s	Sound_PlayBGM2

@locret:
		rts
; ===========================================================================

;Sound_CDA:
;	tst.b	SegaCDMode
;	beq.s	@ret			; if we aren't in Sega CD mode, don't give a fuck
;
;	sf.b	v_sndprio(a6)		; clear sound priority
;	sf.b	f_1up_playing(a6)	; clear 1-up playback flag
;	sf.b	v_fadein_counter(a6)	; clear fade-in counter
;	jsr	InitMusicPlayback	; reset SMPS memory
;
;	st.b	v_cda_playing(a6)	; set CDA playing flag
;	moveq	#_MCD_PlayTrack,d6	; play track repeatedly
;
;	cmpi.b	#_CDA_LevelComplete,d7	; is this level complete jingle?
;	seq	d5			; set D5 if yes
;	cmpi.b	#_CDA_LevelFail,d7	; is this level fail jignle?
;	seq	d4			; set D4 if yes
;	or.b	d4,d5			; is the track one of them?
;	beq.s	@play			; if not, branch
;	moveq	#_MCD_PlayTrack_Once,d6	; if yes, set track to play once
;
;@play	subi.w	#$E5,d7			; subtract $E5 to get track number
;	mcdsend	d6, d7, .w		; request MCD a track
;
;	addq.w	#4,sp			; Tamper return value so we don't return to caller
;@ret	rts

; ===========================================================================
Sound_E0toE4:				; XREF: Sound_ChkValue
		subi.b	#$E0,d7
		add.w	d7,d7	;++
		add.w	d7,d7	;++
		jmp	Sound_ExIndex(pc,d7.w)
; ===========================================================================

Sound_ExIndex:
		bra.w	FadeOutMusic		; $E0
; ===========================================================================
		bra.w	PlaySega		; $E1
; ===========================================================================
		bra.w	SpeedUpMusic		; $E2
; ===========================================================================
		bra.w	SlowDownMusic		; $E3
; ===========================================================================
		bra.w	StopSoundAndMusic	; $E4
; ===========================================================================
; ---------------------------------------------------------------------------
; Play "Say-gaa" PCM sound
; ---------------------------------------------------------------------------

PlaySega:
;		stopZ80
;		move.b	#$8F,($A01FFF).l	; Queue Sega PCM
;		startZ80
;
;		move.w	#$11,d1
;
;@busyloop_outer:
;		move.w	#-1,d0
;
;@busyloop:
;		nop
;		dbf	d0,@busyloop
;
;		dbf	d1,@busyloop_outer
;
;		addq.w	#4,sp	; Tamper return value so we don't return to caller
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $E5-FF
; ---------------------------------------------------------------------------

Sound_PlayBGM2:
		clr.b	f_1up_playing(a6)
		clr.b	v_fadein_counter(a6)

        	jsr	InitMusicPlayback(pc)
		movea.l	(Go_SpeedUpIndex).l,a4		; ~~
		subi.b	#$E5,d7				; ~~
		move.b	(a4,d7.w),v_speeduptempo(a6)	; ~~
		movea.l	(Go_MusicIndex2).l,a4
		lsl.w	#2,d7
		movea.l	(a4,d7.w),a4	; a4 now points to (uncompressed) song data
		
		jmp	Sound_LoadBGM

; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------

Sound_PlayBGM:
;		cmpi.b	#bgm_ExtraLife,d7		; is the "extra life" music to be played?
;		bne.s	@bgmnot1up	; if not, branch
;		tst.b	f_1up_playing(a6)	; Is a 1-up music playing?
;		bne.w	@locdblret	; if yes, branch
;		lea	v_track_ram(a6),a5
;		moveq	#9,d0	; [(1 DAC + 6 FM) or (7 FM)] + 3 PSG
;
;@clearsfxloop:
;		bclr	#2,(a5)	; Clear 'SFX is overriding' bit
;		adda.w	#zTrackSz,a5
;		dbf	d0,@clearsfxloop
;
;		lea	v_sfx_track_ram(a6),a5
;		moveq	#5,d0	; 3 FM + 3 PSG tracks (SFX)
;
;@cleartrackplayloop:
;		bclr	#7,(a5)	; Clear 'track is playing' bit
;		adda.w	#zTrackSz,a5
;		dbf	d0,@cleartrackplayloop
;
;		clr.b	v_sndprio(a6)	; Clear priority
;		movea.l	a6,a0
;		lea	v_1up_ram_copy(a6),a1
;		move.w	#$87,d0	; Backup $220 bytes
;
;@backupramloop:
;		move.l	(a0)+,(a1)+
;		dbf	d0,@backupramloop
;
;		move.b	#$80,f_1up_playing(a6)
;		clr.b	0(a6)
;		bra.s	@bgm_loadMusic
;; ===========================================================================
;
;@bgmnot1up:
		clr.b	f_1up_playing(a6)
		clr.b	v_fadein_counter(a6)

@bgm_loadMusic:

;	; If CDA is playing, stop it
;	tst.b	v_cda_playing(a6)
;	beq.s	@NoCD
;	mcdsend	#_MCD_StopTrack
;	sf.b	v_cda_playing(a6)
;@NoCD

		jsr	InitMusicPlayback(pc)
		movea.l	(Go_SpeedUpIndex).l,a4
		subi.b	#$81,d7
		move.b	(a4,d7.w),v_speeduptempo(a6)
		movea.l	(Go_MusicIndex).l,a4
		lsl.w	#2,d7
		movea.l	(a4,d7.w),a4	; a4 now points to (uncompressed) song data
		
Sound_LoadBGM:
		moveq	#0,d0
		move.w	(a4),d0		; load voice pointer
		add.l	a4,d0		; It is a relative pointer
		move.l	d0,v_voice_ptr(a6)
		move.b	5(a4),d0	; load tempo
		move.b	d0,v_tempo_mod(a6)
		tst.b	f_speedup(a6)
		beq.s	@nospeedshoes
		move.b	v_speeduptempo(a6),d0

@nospeedshoes:
		move.b	d0,v_main_tempo(a6)
		move.b	d0,v_main_tempo_timeout(a6)
		moveq	#0,d1
		movea.l	a4,a3
		addq.w	#6,a4		; Point past header
		moveq	#0,d7
		move.b	2(a3),d7	; load number of FM+DAC channels
		beq.w	@bgm_fmdone	; branch if zero
		bclr	#7,d7		; ++
		sne.b	v_extension(a6)	; ++
		subq.b	#1,d7
		move.b	#$C0,d1		; Default AMS+FMS+Panning
		move.b	4(a3),d4	; load tempo dividing timing
		moveq	#zTrackSz,d6
		move.b	#1,d5		; Note duration for first "note"
		lea	v_track_ram(a6),a1
		lea	FMDACInitBytes(pc),a2

@bmg_fmloadloop:
		bset	#7,(a1)		; Initial playback control: set 'track playing' bit
		move.b	(a2)+,1(a1)	; Voice control bits
		move.b	d4,2(a1)
		move.b	d6,$D(a1)	; set "gosub" (coord flag F8h) stack init value
		move.b	d1,$A(a1)	; Set AMS/FMS/Panning
		move.b	d5,$E(a1)	; Set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0	; load DAC/FM pointer
		add.l	a3,d0		; Relative pointer
		move.l	d0,4(a1)	; Store track pointer
		move.w	(a4)+,8(a1)	; load FM channel modifier
		adda.w	d6,a1
		dbf	d7,@bmg_fmloadloop
		
		cmpi.b	#7,2(a3)	; Are 7 FM channels defined?
		bne.s	@silencefm6
		moveq	#$2B,d0		; DAC enable/disable register
		moveq	#0,d1		; Disable DAC
		jsr	WriteFMI(pc)
		bra.w	@bgm_fmdone
; ===========================================================================

@silencefm6:
		moveq	#$28,d0		; Key on/off register
		moveq	#6,d1		; Note off on all operators of channel 6
		jsr	WriteFMI(pc)
		move.b	#$42,d0		; TL for operator 1 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$4A,d0		; TL for operator 3 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$46,d0		; TL for operator 2 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$4E,d0		; TL for operator 4 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$B6,d0		; AMS/FMS/panning of FM6
		move.b	#$C0,d1		; Stereo
		jsr	WriteFMII(pc)

@bgm_fmdone:
		moveq	#0,d7
		move.b	3(a3),d7	; Load number of PSG channels
		beq.s	@bgm_psgdone	; branch if zero
		subq.b	#1,d7
		lea	v_psg1_track(a6),a1
		lea	PSGInitBytes(pc),a2

@bgm_psgloadloop:
		bset	#7,(a1)		; Initial playback control: set 'track playing' bit
		move.b	(a2)+,1(a1)	; Voice control bits
		move.b	d4,2(a1)
		move.b	d6,$D(a1)	; set "gosub" (coord flag F8h) stack init value
		move.b	d5,$E(a1)	; Set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0	; load PSG channel pointer
		add.l	a3,d0		; Relative pointer
		move.l	d0,4(a1)	; Store track pointer
		move.w	(a4)+,8(a1)	; load PSG modifier
		move.b	(a4)+,d0	; load redundant byte
		move.b	(a4)+,$B(a1)	; Initial PSG tone
		adda.w	d6,a1
		dbf	d7,@bgm_psgloadloop

@bgm_psgdone:
		lea	v_sfx_fm3_track(a6),a1
		moveq	#5,d7		; 6 SFX tracks

@sfxstoploop:
		tst.b	(a1)		; Is SFX playing?
		bpl.w	@sfxnext	; Branch if not
		moveq	#0,d0
		move.b	1(a1),d0	; Get playback control bits
		bmi.s	@sfxpsgchannel	; Branch if this is a PSG channel
		subq.b	#2,d0		; SFX can't have FM1 or FM2
		lsl.b	#2,d0		; Convert to index
		bra.s	@gotchannelindex
; ===========================================================================

@sfxpsgchannel:
		lsr.b	#3,d0		; Convert to index

@gotchannelindex:
		lea	BGMChannelRAM(pc),a0
		movea.l	(a0,d0.w),a0
		bset	#2,(a0)		; Set 'SFX is overriding' bit

@sfxnext:
		adda.w	d6,a1
		dbf	d7,@sfxstoploop

		tst.w	v_sfx2_fm4_playback_control(a6)	; Is special SFX being played?
		bpl.s	@checkspecialpsg		; Branch if not
		bset	#2,v_fm4_playback_control(a6)	; Set 'SFX is overriding' bit

@checkspecialpsg:
		tst.w	v_sfx2_psg3_playback_control(a6)	; Is special SFX being played?
		bpl.s	@sendfmnoteoff		; Branch if not
		bset	#2,v_psg3_playback_control(a6)	; Set 'SFX is overriding' bit

@sendfmnoteoff:
		lea	v_fm1_track(a6),a5
		moveq	#5,d4

@fmnoteoffloop:
		jsr	FMNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,@fmnoteoffloop	; run all FM channels
		moveq	#2,d4

@psgnoteoffloop:
		jsr	PSGNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,@psgnoteoffloop	; run all PSG channels

@locdblret:
		addq.w	#4,sp	; Tamper with return value to not return to caller
		rts	
; ===========================================================================
FMDACInitBytes:	dc.b 6,	0, 1, 2, 4, 5, 6, 0
		even
PSGInitBytes:	dc.b $80, $A0, $C0, 0
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------

Sound_PlaySFX:
		tst.b	f_1up_playing(a6)	; Is 1-up playing?
		bne.w	PlaySFX_ResetPrio	; Exit is it is
		tst.b	v_fadeout_counter(a6)	; Is music being faded out?
		bne.w	PlaySFX_ResetPrio	; Exit if it is
		tst.b	f_fadein_flag(a6)	; Is music being faded in?
		bne.w	PlaySFX_ResetPrio	; Exit if it is
		
		cmpi.b	#$D1,d7			; ++ is this Spin Dash sound?
		beq.s	@DontResetRev
		clr.b	v_revsound(a6)
	@DontResetRev:

		cmpi.b	#sfx_Ring,d7		; is ring sound	effect played?
		bne.s	@sfx_notRing		; if not, branch
		tst.b	v_ring_speaker(a6)	; Is the ring sound playing on right speaker?
		bne.s	@gotringspeaker		; Branch if not
		move.b	#sfx_RingLeft,d7		; play ring sound in left speaker

	@gotringspeaker:
		bchg	#0,v_ring_speaker(a6)	; change speaker

	@sfx_notRing:
		cmpi.b	#sfx_Push,d7		; is "pushing" sound played?
		bne.s	Sound_LoadSFX		; if not, branch
		tst.b	f_push_playing(a6)	; Is pushing sound already playing?
		bne.w	PlaySFX_Done		; Return if not
		move.b	#$80,f_push_playing(a6)	; Mark it as playing

; ===========================================================================
Sound_LoadSFX:
		movea.l	(Go_SoundIndex).l,a0
		subi.b	#$A0,d7		; Make it 0-based
		lsl.w	#2,d7		; Convert sfx ID into index
		movea.l	(a0,d7.w),a3	; SFX data pointer
		movea.l	a3,a1
		moveq	#0,d1
		move.w	(a1)+,d1	; Voice pointer
		add.l	a3,d1		; Relative pointer
		move.b	(a1)+,d5	; Dividing timing
		move.b	(a1)+,d7	; Number of channels (FM + PSG)
		subq.b	#1,d7
		moveq	#zTrackSz,d6

	@sfx_loadloop:
		moveq	#0,d3
		move.b	1(a1),d3	; Channel assignment bits
		move.b	d3,d4
		bmi.s	@sfxinitpsg	; Branch if PSG
		subq.w	#2,d3		; SFX can only have FM3, FM4 or FM5
		lsl.w	#2,d3
		lea	BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,(a5)		; Mark music track as being overridden
		bra.s	@sfxoverridedone

	@sfxinitpsg:
		lsr.w	#3,d3
		lea	BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,(a5)		; Mark music track as being overridden
		cmpi.b	#$C0,d4		; Is this PSG 3?
		bne.s	@sfxoverridedone	; Branch if not
		move.b	d4,d0
		ori.b	#$1F,d0		; Command to silence PSG 3
		move.b	d0,(PSG).l
		bchg	#5,d0		; Command to silence noise channel
		move.b	d0,(PSG).l

	@sfxoverridedone:
		movea.l	SFXChannelRAM(pc,d3.w),a5
		movea.l	a5,a2
		moveq	#$B,d0	; $30 bytes

	@clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,@clearsfxtrackram

		move.w	(a1)+,(a5)	; Initial playback control bits
		move.b	d5,2(a5)	; Initial voice control bits
		moveq	#0,d0
		move.w	(a1)+,d0	; Track data pointer
		add.l	a3,d0		; Relative pointer
		move.l	d0,4(a5)	; Store track pointer
		move.w	(a1)+,8(a5)	; load FM/PSG channel modifier
		move.b	#1,$E(a5)	; Set duration of first "note"
		move.b	d6,$D(a5)	; set "gosub" (coord flag F8h) stack init value
		tst.b	d4			; Is this a PSG channel?
		bmi.s	@sfxpsginitdone	; Branch if yes
		move.b	#$C0,$A(a5)	; AMS/FMS/Panning
		move.l	d1,$20(a5)	; Voice pointer

	@sfxpsginitdone:
		dbf	d7,@sfx_loadloop

		tst.b	v_sfx_fm4_playback_control(a6)	; Is special SFX being played?
		bpl.s	@doneoverride		; Branch if not
		bset	#2,v_sfx2_fm4_playback_control(a6)	; Set SFX is overriding bit

	@doneoverride:
		tst.b	v_sfx_psg3_track(a6)	; Is special SFX being played?
		bpl.s	PlaySFX_Done		; Branch if not
		bset	#2,v_sfx2_psg3_playback_control(a6)	; Set SFX is overriding bit

PlaySFX_Done:
		rts	
; ===========================================================================

PlaySFX_ResetPrio:
		clr.b	v_sndprio(a6)		; Clear priority
		rts	
		

; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for FM and PSG channel variables
; ---------------------------------------------------------------------------
BGMChannelRAM:	dc.l (v_snddriver_ram+v_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram+v_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_psg3_track)&$FFFFFF	; Plain PSG3
		dc.l (v_snddriver_ram+v_psg3_track)&$FFFFFF	; Noise
SFXChannelRAM:	dc.l (v_snddriver_ram+v_sfx_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram+v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx_psg3_track)&$FFFFFF	; Plain PSG3
		dc.l (v_snddriver_ram+v_sfx_psg3_track)&$FFFFFF	; Noise
; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------

Sound_PlaySpecial:
		tst.b	f_1up_playing(a6)	; Is 1-up playing?
		bne.w	@locret		; Return if so
		tst.b	v_fadeout_counter(a6)	; Is music being faded out?
		bne.w	@locret		; Exit if it is
		tst.b	f_fadein_flag(a6)	; Is music being faded in?
		bne.w	@locret		; Exit if it is
		movea.l	(Go_SoundD0).l,a0
		subi.b	#$D0,d7		; Make it 0-based
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0	; Voice pointer
		add.l	a3,d0		; Relative pointer
		move.l	d0,$20(a6)	; Store voice pointer
		move.b	(a1)+,d5	; Dividing timing
		move.b	(a1)+,d7	; Number of channels (FM + PSG)
		subq.b	#1,d7
		moveq	#zTrackSz,d6

@sfxloadloop:
		move.b	1(a1),d4	; Voice control bits
		bmi.s	@sfxoverridepsg	; Branch if PSG
		bset	#2,v_fm4_playback_control(a6)	; Set SFX is overriding bit
		lea	v_sfx2_fm4_track(a6),a5
		bra.s	@sfxinitpsg
; ===========================================================================

@sfxoverridepsg:
		bset	#2,v_psg3_playback_control(a6)	; Set SFX is overriding bit
		lea	v_sfx2_psg3_track(a6),a5

@sfxinitpsg:
		movea.l	a5,a2
		moveq	#$B,d0

@clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,@clearsfxtrackram

		move.w	(a1)+,(a5)	; Initial playback control bits
		move.b	d5,2(a5)	; Initial voice control bits
		moveq	#0,d0
		move.w	(a1)+,d0	; Track data pointer
		add.l	a3,d0		; Relative pointer
		move.l	d0,4(a5)	; Store track pointer
		move.w	(a1)+,8(a5)	; load FM/PSG channel modifier
		move.b	#1,$E(a5)	; Set duration of first "note"
		move.b	d6,$D(a5)	; set "gosub" (coord flag F8h) stack init value
		tst.b	d4			; Is this a PSG channel?
		bmi.s	@sfxpsginitdone	; Branch if yes
		move.b	#$C0,$A(a5)	; AMS/FMS/Panning

@sfxpsginitdone:
		dbf	d7,@sfxloadloop

		tst.b	v_sfx_fm4_playback_control(a6)	; Is track playing?
		bpl.s	@doneoverride	; Branch if not
		bset	#2,v_sfx2_fm4_playback_control(a6)	; Set SFX is overriding track

@doneoverride:
		tst.b	v_sfx_psg3_playback_control(a6)	; Is track playing?
		bpl.s	@locret		; Branch if not
		bset	#2,v_sfx2_psg3_playback_control(a6)	; Set SFX is overriding track
		ori.b	#$1F,d4		; Command to silence channel
		move.b	d4,(PSG).l
		bchg	#5,d4		; Command to silence noise channel
		move.b	d4,(PSG).l

@locret:
		rts	
; End of function Sound_ChkValue

; ===========================================================================
; Unused
		dc.l (v_snddriver_ram+v_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_psg3_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx_psg3_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx2_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram+v_sfx2_psg3_track)&$FFFFFF

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Snd_FadeOutSFX:
		clr.b	v_sndprio(a6)		; Clear priority
		lea	v_sfx_track_ram(a6),a5
		moveq	#5,d7

@trackloop:
		tst.b	(a5)		; Is track playing?
		bpl.w	@nexttrack	; Branch if not
		bclr	#7,(a5)		; Stop track
		moveq	#0,d3
		move.b	1(a5),d3	; Get voice control bits
		bmi.s	@trackpsg	; Branch if PSG
		jsr	FMNoteOff(pc)
		cmpi.b	#4,d3		; Is this FM4?
		bne.s	@getfmpointer	; Branch if not
		tst.b	v_sfx2_fm4_playback_control(a6)	; Is special SFX playing?
		bpl.s	@getfmpointer	; Branch if not
		movea.l	a5,a3
		; DANGER! there is a missing 'movea.l	a5,a3' here, without which the
		; code is broken. It is dangerous to do a fade out when a GHZ waterfall
		; is playing its sound!
		lea	v_sfx2_fm4_track(a6),a5
		movea.l	v_special_voice_ptr(a6),a1	; Get special voice pointer
		bra.s	@gotfmpointer
; ===========================================================================

@getfmpointer:
		subq.b	#2,d3		; SFX only has FM3 and up
		lsl.b	#2,d3
		lea	BGMChannelRAM(pc),a0
		movea.l	a5,a3
		movea.l	(a0,d3.w),a5
		movea.l	v_voice_ptr(a6),a1	; Get music voice pointer

@gotfmpointer:
		bclr	#2,(a5)		; Clear SFX is overriding bit
		bset	#1,(a5)		; Set track at rest bit
		move.b	$B(a5),d0	; Current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5
		bra.s	@nexttrack
; ===========================================================================

@trackpsg:
		jsr	PSGNoteOff(pc)
		lea	v_sfx2_psg3_track(a6),a0
		cmpi.b	#$E0,d3		; Is this a noise channel:
		beq.s	@gotpsgpointer	; Branch if yes
		cmpi.b	#$C0,d3		; Is this PSG 3?
		beq.s	@gotpsgpointer	; Branch if yes
		lsr.b	#3,d3
		lea	BGMChannelRAM(pc),a0
		movea.l	(a0,d3.w),a0

@gotpsgpointer:
		bclr	#2,(a0)		; Clear SFX is overriding bit
		bset	#1,(a0)		; Set track at rest bit
		cmpi.b	#$E0,1(a0)	; Is this a noise channel?
		bne.s	@nexttrack	; Branch if not
		move.b	$1F(a0),(PSG).l	; Set noise type

@nexttrack:
		adda.w	#zTrackSz,a5
		dbf	d7,@trackloop

		rts	
; End of function Snd_FadeOutSFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Snd_FadeOutSFX2:
		lea	v_sfx2_fm4_track(a6),a5
		tst.b	(a5)		; Is track playing?
		bpl.s	@fadedfm	; Branch if not
		bclr	#7,(a5)		; Stop track
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	@fadedfm	; Branch if not
		jsr	SendFMNoteOff(pc)
		lea	v_fm4_track(a6),a5
		bclr	#2,(a5)		; Clear SFX is overriding bit
		bset	#1,(a5)		; Set track at rest bit
		tst.b	(a5)		; Is track playing?
		bpl.s	@fadedfm	; Branch if not
		movea.l	v_voice_ptr(a6),a1	; Voice pointer
		move.b	$B(a5),d0	; Current voice
		jsr	SetVoice(pc)

@fadedfm:
		lea	v_sfx2_psg3_track(a6),a5
		tst.b	(a5)		; Is track playing?
		bpl.s	@fadedpsg	; Branch if not
		bclr	#7,(a5)		; Stop track
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	@fadedpsg	; Return if not
		jsr	SendPSGNoteOff(pc)
		lea	v_psg3_track(a6),a5
		bclr	#2,(a5)		; Clear SFX is overriding bit
		bset	#1,(a5)		; Set track at rest bit
		tst.b	(a5)		; Is track playing?
		bpl.s	@fadedpsg	; Return if not
		cmpi.b	#$E0,1(a5)	; Is this a noise channel?
		bne.s	@fadedpsg	; Return if not
		move.b	$1F(a5),(PSG).l	; Set noise type

@fadedpsg:
		rts
; End of function Snd_FadeOutSFX2

; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------

FadeOutMusic:
		jsr	Snd_FadeOutSFX(pc)
		jsr	Snd_FadeOutSFX2(pc)
		move.b	#3,v_fadeout_delay(a6)		; Set fadeout delay to 3
		move.b	#$28,v_fadeout_counter(a6)		; Set fadeout counter
		clr.b	v_dac_playback_control(a6)	; Stop DAC track
		clr.b	f_speedup(a6)	; Disable speed shoes tempo
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoFadeOut:
		move.b	v_fadeout_delay(a6),d0	; Has fadeout delay expired?
		beq.s	@continuefade	; Branch if yes
		subq.b	#1,v_fadeout_delay(a6)
		rts
; ===========================================================================

@continuefade:

;	; Fade out CD track
;	tst.b	v_cda_playing(a6)
;	beq.s	@0
;	moveq	#0,d0
;	move.b	v_fadeout_counter(a6),d0
;	mulu.w	#$19,d0
;	mcdsend	#_MCD_SetVolume, d0, .w
;@0

		subq.b	#1,v_fadeout_counter(a6)	; Update fade counter
		beq.w	StopSoundAndMusic	; Branch if fade is done
		move.b	#3,v_fadeout_delay(a6)	; Reset fade delay
		lea	v_fm1_track(a6),a5
		moveq	#5,d7

@fmloop:
		tst.b	(a5)		; Is track playing?
		bpl.s	@nextfm	; Branch if not
		addq.b	#1,9(a5)	; Increase volume attenuation
		bpl.s	@sendfmtl	; Branch if still positive
		bclr	#7,(a5)		; Stop track
		bra.s	@nextfm
; ===========================================================================

@sendfmtl:
		jsr	SendVoiceTL(pc)

@nextfm:
		adda.w	#zTrackSz,a5
		dbf	d7,@fmloop

		moveq	#2,d7

@psgloop:
		tst.b	(a5)		; Is track playing?
		bpl.s	@nextpsg	; branch if not
		addq.b	#1,9(a5)	; Increase volume attenuation
		cmpi.b	#$10,9(a5)	; Is it greater than $F?
		blo.s	@sendpsgvol	; Branch if not
		bclr	#7,(a5)		; Stop track
		bra.s	@nextpsg
; ===========================================================================

@sendpsgvol:
		move.b	9(a5),d6	;Store new volume attenuation
		jsr	SetPSGVolume(pc)

@nextpsg:
		adda.w	#zTrackSz,a5
		dbf	d7,@psgloop

		rts	
; End of function DoFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMSilenceAll:
		moveq	#2,d3		; 3 FM channels for each YM2612 parts
		moveq	#$28,d0		; FM key on/off register

@noteoffloop:
		move.b	d3,d1
		jsr	WriteFMI(pc)
		addq.b	#4,d1		; Move to YM2612 part 1
		jsr	WriteFMI(pc)
		dbf	d3,@noteoffloop

		moveq	#$40,d0		; Set TL on FM channels...
		moveq	#$7F,d1		; ... to total attenuation...
		moveq	#2,d4		; ... for all 3 channels...

@channelloop:
		moveq	#3,d3		; ... for all operators on each channel...

@channeltlloop:
		jsr	WriteFMI(pc)	; ... for part 0...
		jsr	WriteFMII(pc)	; ... and part 1.
		addq.w	#4,d0		; Next TL operator
		dbf	d3,@channeltlloop

		subi.b	#$F,d0		; Move to TL operator 1 of next channel
		dbf	d4,@channelloop

		rts	
; End of function FMSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------

StopSoundAndMusic:

;	; If CDA is playing, stop it
;	tst.b	v_cda_playing(a6)
;	beq.s	@NoCD
;	mcdsend	#_MCD_StopTrack
;	sf.b	v_cda_playing(a6)
;@NoCD

		moveq	#$2B,d0		; Enable/disable DAC
		move.b	#$80,d1		; Enable DAC
		jsr	WriteFMI(pc)
		moveq	#$27,d0		; Timers, FM3/FM6 mode
		moveq	#0,d1		; FM3/FM6 normal mode, disable timers
		jsr	WriteFMI(pc)
		movea.l	a6,a0
		move.w	#$E3,d0		; Clear $390 bytes

@clearramloop:
		clr.l	(a0)+
		dbf	d0,@clearramloop

		stopZ80
		move.b	#$80,($A01FFF).l ; stop DAC playback
		startZ80

		move.b	#$80,v_playsnd0(a6)	; set music to $80 (silence)
		jsr	FMSilenceAll(pc)
		bra.w	PSGSilenceAll

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


InitMusicPlayback:
		movea.l	a6,a0
		; Save several values
		move.b	v_sndprio(a6),d1
		move.b	f_1up_playing(a6),d2
		move.b	f_speedup(a6),d3
		move.b	v_fadein_counter(a6),d4
		move.l	v_playsnd1(a6),d5	; fixed to L

		moveq	#$220/$10-1,d0		; Clear $220 bytes
		moveq	#0,d6

@clearramloop:
		move.l	d6,(a0)+
		move.l	d6,(a0)+
		move.l	d6,(a0)+
		move.l	d6,(a0)+
		dbf	d0,@clearramloop

		; Restore the values saved above
		move.b	d1,v_sndprio(a6)
		move.b	d2,f_1up_playing(a6)
		move.b	d3,f_speedup(a6)
		move.b	d4,v_fadein_counter(a6)
		move.l	d5,v_playsnd1(a6)	; fixed to L
		move.b	#$80,v_playsnd0(a6)	; set music to $80 (silence)

		sf.b	v_extension(a6)		; reset extension flague
		jsr	TS_InitExtChannels	; ++
		jsr	FMSilenceAll(pc)
		bra.w	PSGSilenceAll
; End of function InitMusicPlayback


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TempoWait:
		move.b	v_main_tempo(a6),v_main_tempo_timeout(a6)	; Reset main tempo timeout
		lea	v_dac_note_timeout(a6),a0
		moveq	#zTrackSz,d0
		moveq	#9,d1	; [(1 DAC + 6 FM) or (7 FM)] + 3 PSG

@tempoloop:
		addq.b	#1,(a0)	; Delay note by 1 frame
		adda.w	d0,a0	; Advance to next track
		dbf	d1,@tempoloop

		rts	
; End of function TempoWait

; ===========================================================================
; ---------------------------------------------------------------------------
; Speed	up music
; ---------------------------------------------------------------------------

SpeedUpMusic:
		tst.b	f_1up_playing(a6)
		bne.s	@speedup_1up
		move.b	v_speeduptempo(a6),v_main_tempo(a6)
		move.b	v_speeduptempo(a6),v_main_tempo_timeout(a6)
		move.b	#$80,f_speedup(a6)
		rts	
; ===========================================================================

@speedup_1up:
		move.b	v_1up_ram_copy+v_speeduptempo(a6),v_1up_ram_copy+v_main_tempo(a6)
		move.b	v_1up_ram_copy+v_speeduptempo(a6),v_1up_ram_copy+v_main_tempo_timeout(a6)
		move.b	#$80,v_1up_ram_copy+f_speedup(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change music back to normal speed
; ---------------------------------------------------------------------------

SlowDownMusic:
		tst.b	f_1up_playing(a6)
		bne.s	@slowdown_1up
		move.b	v_tempo_mod(a6),v_main_tempo(a6)
		move.b	v_tempo_mod(a6),v_main_tempo_timeout(a6)
		clr.b	f_speedup(a6)
		rts	
; ===========================================================================

@slowdown_1up:
		move.b	v_1up_ram_copy+v_tempo_mod(a6),v_1up_ram_copy+v_main_tempo(a6)
		move.b	v_1up_ram_copy+v_tempo_mod(a6),v_1up_ram_copy+v_main_tempo_timeout(a6)
		clr.b	v_1up_ram_copy+f_speedup(a6)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoFadeIn:
		tst.b	v_fadein_delay(a6)	; Has fadein delay expired?
		beq.s	@continuefade		; Branch if yes
		subq.b	#1,v_fadein_delay(a6)
		rts	
; ===========================================================================

@continuefade:
		tst.b	v_fadein_counter(a6)	; Is fade done?
		beq.s	@fadedone			; Branch if yes
		subq.b	#1,v_fadein_counter(a6)	; Update fade counter
		move.b	#2,v_fadein_delay(a6)	; Reset fade delay
		lea	v_fm1_track(a6),a5
		moveq	#5,d7

@fmloop:
		tst.b	(a5)		; Is track playing?
		bpl.s	@nextfm	; Branch if not
		subq.b	#1,9(a5)	; Reduce volume attenuation
		jsr	SendVoiceTL(pc)

@nextfm:
		adda.w	#zTrackSz,a5
		dbf	d7,@fmloop
		moveq	#2,d7

@psgloop:
		tst.b	(a5)		; Is track playing?
		bpl.s	@nextpsg	; Branch if not
		subq.b	#1,9(a5)	; Reduce volume attenuation
		move.b	9(a5),d6	; Get value
		cmpi.b	#$10,d6		; Is it is < $10?
		blo.s	@sendpsgvol	; Branch if yes
		moveq	#$F,d6		; Limit to $F (maximum attenuation)

@sendpsgvol:
		jsr	SetPSGVolume(pc)

@nextpsg:
		adda.w	#zTrackSz,a5
		dbf	d7,@psgloop
		rts	
; ===========================================================================

@fadedone:
		bclr	#2,v_dac_playback_control(a6)	; Clear SFX overriding bit
		clr.b	f_fadein_flag(a6)		; Stop fadein
		rts	
; End of function DoFadeIn

; ===========================================================================

FMNoteOn:
		btst	#1,(a5)		; Is track resting?
		bne.s	@locret		; Return if so
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@locret		; Return if so
		moveq	#$28,d0		; Note on/off register
		move.b	1(a5),d1	; Get channel bits
		ori.b	#$F0,d1		; Note on on all operators
		bra.w	WriteFMI
; ===========================================================================

@locret:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMNoteOff:
		btst	#4,(a5)		; Is 'do not attack next note' set?
		bne.s	locret_72714	; Return if yes
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	locret_72714	; Return if yes

SendFMNoteOff:
		moveq	#$28,d0		; Note on/off register
		move.b	1(a5),d1	; Note off to this channel
		bra.w	WriteFMI
; ===========================================================================

locret_72714:
		rts	
; End of function FMNoteOff

; ===========================================================================

WriteFMIorIIMain:
		btst	#2,(a5)		; Is track being overriden by sfx?
		bne.s	@locret	; Return if yes
		bra.w	WriteFMIorII
; ===========================================================================

@locret:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WriteFMIorII:
		btst	#2,1(a5)	; Is this bound for part I or II?
		bne.s	WriteFMIIPart	; Branch if for part II
		add.b	1(a5),d0	; Add in voice control bits
; End of function WriteFMIorII


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WriteFMI:
		stopZ80
		waitYM
		move.b	d0,($A04000).l
		waitYM
		move.b	d1,($A04001).l
		waitYM
		move.b	#$2A,($A04000).l
		startZ80
		rts
; End of function WriteFMI

; ===========================================================================

WriteFMIIPart:
		move.b	1(a5),d2	; Get voice control bits
		bclr	#2,d2		; Clear chip toggle
		add.b	d2,d0		; Add in to destination register

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WriteFMII:
		stopZ80
		waitYM
		move.b	d0,($A04002).l
		waitYM
		move.b	d1,($A04003).l
		waitYM
		move.b	#$2A,($A04000).l
		startZ80
		rts
; End of function WriteFMII

; ===========================================================================
; ---------------------------------------------------------------------------
; FM Note Values: b-0 to a#8
; ---------------------------------------------------------------------------
FM_Notes:
	dc.w $025E,$0284,$02AB,$02D3,$02FE,$032D,$035C,$038F,$03C5,$03FF,$043C,$047C
	dc.w $0A5E,$0A84,$0AAB,$0AD3,$0AFE,$0B2D,$0B5C,$0B8F,$0BC5,$0BFF,$0C3C,$0C7C
	dc.w $125E,$1284,$12AB,$12D3,$12FE,$132D,$135C,$138F,$13C5,$13FF,$143C,$147C
	dc.w $1A5E,$1A84,$1AAB,$1AD3,$1AFE,$1B2D,$1B5C,$1B8F,$1BC5,$1BFF,$1C3C,$1C7C
	dc.w $225E,$2284,$22AB,$22D3,$22FE,$232D,$235C,$238F,$23C5,$23FF,$243C,$247C
	dc.w $2A5E,$2A84,$2AAB,$2AD3,$2AFE,$2B2D,$2B5C,$2B8F,$2BC5,$2BFF,$2C3C,$2C7C
	dc.w $325E,$3284,$32AB,$32D3,$32FE,$332D,$335C,$338F,$33C5,$33FF,$343C,$347C
	dc.w $3A5E,$3A84,$3AAB,$3AD3,$3AFE,$3B2D,$3B5C,$3B8F,$3BC5,$3BFF,$3C3C,$3C7C

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateTrack:
		subq.b	#1,$E(a5)		; Update note timeout
		bne.s	@notegoing
		bclr	#4,(a5)			; Clear 'do not attack note' flag
		jsr	PSGDoNext(pc)
		jsr	PSGDoNoteOn(pc)
		bra.w	PSGDoVolFX
; ===========================================================================

@notegoing:
		jsr	NoteFillUpdate(pc)
		jsr	PSGUpdateVolFX(pc)
		jsr	DoModulation(pc)
		jsr	PSGUpdateFreq(pc)
		rts	
; End of function PSGUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGDoNext:
		bclr	#1,(a5)		; Clear track at rest bit
		movea.l	4(a5),a4	; Get track data pointer

@noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5	; Get byte from track
		cmpi.b	#$E0,d5		; Is it a coord. flag?
		blo.s	@gotnote	; Branch if not
		jsr	CoordFlag(pc)
		bra.s	@noteloop
; ===========================================================================

@gotnote:
		tst.b	d5			; Is it a note?
		bpl.s	@gotduration	; Branch if not
		jsr	PSGSetFreq(pc)
		move.b	(a4)+,d5	; Get another byte
		tst.b	d5			; Is it a duration?
		bpl.s	@gotduration	; Branch if yes
		subq.w	#1,a4		; Put byte back
		bra.w	FinishTrackUpdate
; ===========================================================================

@gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function PSGDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGSetFreq:
		subi.b	#$81,d5		; Convert to 0-based index
		blo.s	@restpsg	; If $80, put track at rest
		add.b	8(a5),d5	; Add in channel key displacement
		andi.w	#$7F,d5		; Clear high byte and sign bit
		lsl.w	#1,d5
		lea	PSGFrequencies(pc),a0
		move.w	(a0,d5.w),$10(a5)	; Set new frequency
		bra.w	FinishTrackUpdate
; ===========================================================================

@restpsg:
		bset	#1,(a5)		; Set track at rest bit
		move.w	#-1,$10(a5)	; Invalidate note frequency
		jsr	FinishTrackUpdate(pc)
		bra.w	PSGNoteOff
; End of function PSGSetFreq


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGDoNoteOn:
		move.w	$10(a5),d6	; Get note frequency
		bmi.s	PSGSetRest	; If invalid, branch
; End of function PSGDoNoteOn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateFreq:
		move.b	$1E(a5),d0		; Get frequency note adjustment
		ext.w	d0
		add.w	d0,d6		; Add to frequency
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@locret		; Return if yes
		btst	#1,(a5)		; Is track at rest?
		bne.s	@locret		; Return if yes
		move.b	1(a5),d0	; Get channel bits
		cmpi.b	#$E0,d0		; Is it a noise channel?
		bne.s	@notnoise	; Branch if not
		move.b	#$C0,d0		; Use PSG 3 channel bits

@notnoise:
		move.w	d6,d1
		andi.b	#$F,d1		; Low nibble of frequency
		or.b	d1,d0		; Latch tone data to channel
		lsr.w	#4,d6		; Get upper 6 bits of frequency
		andi.b	#$3F,d6		; Send to latched channel
		move.b	d0,(PSG).l
		move.b	d6,(PSG).l

@locret:
		rts	
; End of function PSGUpdateFreq

; ===========================================================================

PSGSetRest:
		bset	#1,(a5)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateVolFX:
		tst.b	$B(a5)		; Test PSG tone
		beq.w	locret_7298A	; Return if it is zero

PSGDoVolFX:
		move.b	9(a5),d6	; Get volume
		moveq	#0,d0
		move.b	$B(a5),d0	; Get PSG tone
		beq.s	SetPSGVolume
		movea.l	(Go_PSGIndex).l,a0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a0,d0.w),a0
		move.b	$C(a5),d0	; Get flutter index
		move.b	(a0,d0.w),d0	; Flutter value
		addq.b	#1,$C(a5)	; Increment flutter index
		btst	#7,d0		; Is flutter value negative?
		beq.s	@gotflutter	; Branch if not
		cmpi.b	#$80,d0		; Is it the terminator?
		beq.s	FlutterDone	; If so, branch

@gotflutter:
		add.w	d0,d6		; Add flutter to volume
		cmpi.b	#$10,d6		; Is volume $10 or higher?
		blo.s	SetPSGVolume	; Branch if not
		moveq	#$F,d6		; Limit to silence and fall through
; End of function PSGUpdateVolFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetPSGVolume:
		btst	#1,(a5)		; Is track at rest?
		bne.s	locret_7298A	; Return if so
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	locret_7298A	; Return if so
		btst	#4,(a5)		; Is track set to not attack next note?
		bne.s	PSGCheckNoteFill	; Branch if yes

PSGSendVolume:
		or.b	1(a5),d6	; Add in track selector bits
		addi.b	#$10,d6		; Mark it as a volume command
		move.b	d6,(PSG).l

locret_7298A:
		rts	
; ===========================================================================

PSGCheckNoteFill:
		tst.b	$13(a5)		; Is note fill on?
		beq.s	PSGSendVolume	; Branch if not
		tst.b	$12(a5)		; Has note fill timeout expired?
		bne.s	PSGSendVolume	; Branch if not
		rts	
; End of function SetPSGVolume

; ===========================================================================

FlutterDone:
		subq.b	#1,$C(a5)	; Decrement flutter index
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGNoteOff:
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	locret_729B4	; Return if so

SendPSGNoteOff:
		move.b	1(a5),d0	; PSG channel to change
		ori.b	#$1F,d0		; Maximum volume attenuation
		move.b	d0,(PSG).l

locret_729B4:
		rts	
; End of function PSGNoteOff


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGSilenceAll:
		lea	(PSG).l,a0
		move.b	#$9F,(a0)	; Silence PSG 1
		move.b	#$BF,(a0)	; Silence PSG 2
		move.b	#$DF,(a0)	; Silence PSG 3
		move.b	#$FF,(a0)	; Silence noise channel
		rts	
; End of function PSGSilenceAll

; ===========================================================================
PSGFrequencies:
		dc.w $356, $326, $2F9, $2CE, $2A5, $280, $25C, $23A
		dc.w $21A, $1FB, $1DF, $1C4, $1AB, $193, $17D, $167
		dc.w $153, $140, $12E, $11D, $10D,  $FE,  $EF,  $E2
		dc.w  $D6,  $C9,  $BE,  $B4,  $A9,  $A0,  $97,  $8F
		dc.w  $87,  $7F,  $78,  $71,  $6B,  $65,  $5F,  $5A
		dc.w  $55,  $50,  $4B,  $47,  $43,  $40,  $3C,  $39
		dc.w  $36,  $33,  $30,  $2D,  $2B,  $28,  $26,  $24
		dc.w  $22,  $20,  $1F,  $1D,  $1B,  $1A,  $18,  $17
		dc.w  $16,  $15,  $13,  $12,  $11,    0

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CoordFlag:
		subi.w	#$E0,d5
		lsl.w	#2,d5
		jmp	coordflagLookup(pc,d5.w)
; End of function CoordFlag

; ===========================================================================

coordflagLookup:
		bra.w	cfPanningAMSFMS		; $E0
; ===========================================================================
		bra.w	cfAlterNotes		; $E1
; ===========================================================================
		bra.w	cfUnknown1		; $E2
; ===========================================================================
		bra.w	cfJumpReturn		; $E3
; ===========================================================================
		bra.w	cfFadeInToPrevious	; $E4
; ===========================================================================
		bra.w	cfSetTempoDivider	; $E5
; ===========================================================================
		bra.w	cfSetVolume		; $E6
; ===========================================================================
		bra.w	cfPreventAttack		; $E7
; ===========================================================================
		bra.w	cfNoteFill		; $E8
; ===========================================================================
		bra.w	cfAddKey		; $E9
; ===========================================================================
		bra.w	cfSetTempo		; $EA
; ===========================================================================
		bra.w	cfSetTempoMod		; $EB
; ===========================================================================
		bra.w	cfChangeVolume		; $EC
; ===========================================================================
		bra.w	cfClearPush		; $ED
; ===========================================================================
		bra.w	cfStopSpecialFM4	; $EE
; ===========================================================================
		bra.w	cfSetVoice		; $EF
; ===========================================================================
		bra.w	cfModulation		; $F0
; ===========================================================================
		bra.w	cfEnableModulation	; $F1
; ===========================================================================
		bra.w	cfStopTrack		; $F2
; ===========================================================================
		bra.w	cfSetPSGNoise		; $F3
; ===========================================================================
		bra.w	cfDisableModulation	; $F4
; ===========================================================================
		bra.w	cfSetPSGTone		; $F5
; ===========================================================================
		bra.w	cfJumpTo		; $F6
; ===========================================================================
		bra.w	cfRepeatAtPos		; $F7
; ===========================================================================
		bra.w	cfJumpToGosub		; $F8
; ===========================================================================
		bra.w	cfOpF9			; $F9
; ===========================================================================
		bra.w	TS_Flag_SetPortamentoMode	; $FA
; ===========================================================================  
		bra.w	TS_Flag_SetPortamentoSpeed	; $FB
; ===========================================================================
		bra.w	cfRevving			; $FC
; ===========================================================================

cfPanningAMSFMS:
		move.b	(a4)+,d1	; New AMS/FMS/panning value
		tst.b	1(a5)		; Is this a PSG track?
		bmi.s	locret_72AEA	; Return if yes
		move.b	$A(a5),d0	; Get current AMS/FMS/panning
		andi.b	#$37,d0		; Retain bits 0-2, 3-4 if set
		or.b	d0,d1		; Mask in new value
		move.b	d1,$A(a5)	; Store value
		move.b	#$B4,d0		; Command to set AMS/FMS/panning
		bra.w	WriteFMIorIIMain
; ===========================================================================

locret_72AEA:
		rts	
; ===========================================================================

cfAlterNotes:
		move.b	(a4)+,$1E(a5)	; Set frequency adjustment
		rts	
; ===========================================================================

cfUnknown1:
;		move.b	(a4)+,7(a6)		; Set otherwise unused value to parameter
		rts	
; ===========================================================================

cfJumpReturn:
		moveq	#0,d0
		move.b	$D(a5),d0		; Track stack pointer
		movea.l	(a5,d0.w),a4	; Set track return address
		move.l	#0,(a5,d0.w)	; Set 'popped' value to zero
		addq.w	#2,a4			; Skip jump target address from gosub flag
		addq.b	#4,d0			; Actually 'pop' value
		move.b	d0,$D(a5)		; Set new stack pointer
		rts	
; ===========================================================================

cfFadeInToPrevious:
		movea.l	a6,a0
		lea	v_1up_ram_copy(a6),a1
		move.w	#$87,d0		; $220 bytes to restore

@restoreramloop:
		move.l	(a1)+,(a0)+
		dbf	d0,@restoreramloop

		bset	#2,v_dac_playback_control(a6)	; Set SFX overriding bit
		movea.l	a5,a3
		move.b	#$28,d6
		sub.b	v_fadein_counter(a6),d6		; If fade already in progress, this adjusts track volume accordingly
		moveq	#5,d7
		lea	v_fm1_track(a6),a5

@fmloop:
		btst	#7,(a5)		; Is track playing?
		beq.s	@nextfm	; Branch if not
		bset	#1,(a5)		; Set track at rest bit
		add.b	d6,9(a5)	; Apply current volume fade-in
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	@nextfm	; Branch if yes
		moveq	#0,d0
		move.b	$B(a5),d0	; Get voice
		movea.l	v_voice_ptr(a6),a1	; Voice pointer
		jsr	SetVoice(pc)

@nextfm:
		adda.w	#zTrackSz,a5
		dbf	d7,@fmloop

		moveq	#2,d7

@psgloop:
		btst	#7,(a5)		; Is track playing?
		beq.s	@nextpsg	; Branch if not
		bset	#1,(a5)		; Set track at rest bit
		jsr	PSGNoteOff(pc)
		add.b	d6,9(a5)	; Apply current volume fade-in

@nextpsg:
		adda.w	#zTrackSz,a5
		dbf	d7,@psgloop
		
		movea.l	a3,a5
		move.b	#$80,f_fadein_flag(a6)	; Trigger fade-in
		move.b	#$28,v_fadein_counter(a6)	; Fade-in delay
		clr.b	f_1up_playing(a6)
		startZ80
		addq.w	#8,sp		; Tamper return value so we don't return to caller
		rts	
; ===========================================================================

cfSetTempoDivider:
		move.b	(a4)+,2(a5)	; Set tempo divider on current track
		rts	
; ===========================================================================

cfSetVolume:
		move.b	(a4)+,d0	; Get parameter
		add.b	d0,9(a5)	; Add to current volume
		bra.w	SendVoiceTL
; ===========================================================================

cfPreventAttack:
		bset	#4,(a5)		; Set 'do not attack next note' bit
		rts	
; ===========================================================================

cfNoteFill:
		move.b	(a4),$12(a5)	; Note fill timeout
		move.b	(a4)+,$13(a5)	; Note fill master
		rts	
; ===========================================================================

cfRevving:
		move.b	(a4)+,d0
		add.b	v_revsound(a6),d0
		cmp.b	#$10,d0
		bhi.s	@0
		move.b	d0,v_revsound(a6)
	@0:	add.b	d0,8(a5)
        	rts

; ===========================================================================
cfAddKey:
		move.b	(a4)+,d0	; Get parameter
		add.b	d0,8(a5)	; Add to track key displacement
		rts
; ===========================================================================

cfSetTempo:
		move.b	(a4),v_main_tempo(a6)	; Set main tempo
		move.b	(a4)+,v_main_tempo_timeout(a6)	; And reset timeout (!)
		rts	
; ===========================================================================

cfSetTempoMod:
		lea	v_track_ram(a6),a0
		move.b	(a4)+,d0		; Get new tempo divider
		moveq	#zTrackSz,d1
		moveq	#9,d2

@trackloop:
		move.b	d0,2(a0)	; Set track's tempo divider
		adda.w	d1,a0
		dbf	d2,@trackloop

		rts	
; ===========================================================================

cfChangeVolume:
		move.b	(a4)+,d0	; Get volume change
		add.b	d0,9(a5)	; Apply it
		rts	
; ===========================================================================

cfClearPush:
		clr.b	f_push_playing(a6)	; Allow push sound to be played once more
		rts	
; ===========================================================================

cfStopSpecialFM4:
		bclr	#7,(a5)		; Stop track
		bclr	#4,(a5)		; Clear 'do not attack next note' bit
		jsr	FMNoteOff(pc)
		tst.b	v_sfx_fm4_track(a6)		; Is SFX using FM4?
		bmi.s	@locexit	; Branch if yes
		movea.l	a5,a3
		lea	v_fm4_track(a6),a5
		movea.l	v_voice_ptr(a6),a1	; Voice pointer
		bclr	#2,(a5)		; Clear SFX is overriding bit
		bset	#1,(a5)		; Set track at rest bit
		move.b	$B(a5),d0	; Current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5

@locexit:
		addq.w	#8,sp		; Tamper with return value so we don't return to caller
		rts	
; ===========================================================================

cfSetVoice:
		moveq	#0,d0
		move.b	(a4)+,d0	; Get new voice
		move.b	d0,$B(a5)	; Store it
		btst	#2,(a5)		; Is SFX overriding this track?
		bne.w	locret_72CAA	; Return if yes
		movea.l	v_voice_ptr(a6),a1	; Music voice pointer
		tst.b	f_voice_selector(a6)	; Are we updating a music track?
		beq.s	SetVoice	; If yes, branch
		movea.l	$20(a5),a1	; SFX track voice pointer
		tst.b	f_voice_selector(a6)	; Are we updating a SFX track?
		bmi.s	SetVoice	; If yes, branch
		movea.l	v_special_voice_ptr(a6),a1	; Special SFX voice pointer

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetVoice:
		subq.w	#1,d0
		bmi.s	@havevoiceptr
		move.w	#25,d1

@voicemultiply:
		adda.w	d1,a1
		dbf	d0,@voicemultiply

@havevoiceptr:
		move.b	(a1)+,d1	; feedback/algorithm
		move.b	d1,$1F(a5)	; Save it to track RAM
		move.b	d1,d4
		move.b	#$B0,d0		; Command to write feedback/algorithm
		jsr	WriteFMIorII(pc)
		lea	FMInstrumentOperatorTable(pc),a2
		moveq	#$13,d3		; Don't want to send TL yet

@sendvoiceloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		jsr	WriteFMIorII(pc)
		dbf	d3,@sendvoiceloop

		moveq	#3,d5
		andi.w	#7,d4		; Get algorithm
		move.b	FMSlotMask(pc,d4.w),d4	; Get slot mask for algorithm
		move.b	9(a5),d3	; Track volume attenuation

@sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4		; Is bit set for this operator in the mask?
		bcc.s	@sendtl		; Branch if not
		add.b	d3,d1		; Include additional attenuation

@sendtl:
		jsr	WriteFMIorII(pc)
		dbf	d5,@sendtlloop
		
		move.b	#$B4,d0		; Register for AMS/FMS/Panning
		move.b	$A(a5),d1	; Value to send
		jsr	WriteFMIorII(pc)

locret_72CAA:
		rts	
; End of function SetVoice

; ===========================================================================
FMSlotMask:	dc.b 8,	8, 8, 8, $A, $E, $E, $F

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SendVoiceTL:
		btst	#2,(a5)		; Is SFX overriding?
		bne.s	@locret	; Return if so
		moveq	#0,d0
		move.b	$B(a5),d0	; Current voice
		movea.l	v_voice_ptr(a6),a1	; Voice pointer
		tst.b	f_voice_selector(a6)
		beq.s	@gotvoiceptr
		; DANGER! This uploads the wrong voice! It should have been a5 instead
		; of a6!
		movea.l	$20(a6),a1
		tst.b	f_voice_selector(a6)
		bmi.s	@gotvoiceptr
		movea.l	v_special_voice_ptr(a6),a1

@gotvoiceptr:
		subq.w	#1,d0
		bmi.s	@gotvoice
		move.w	#25,d1

@voicemultiply:
		adda.w	d1,a1
		dbf	d0,@voicemultiply

@gotvoice:
		adda.w	#21,a1		; Want TL
		lea	FMInstrumentTLTable(pc),a2
		move.b	$1F(a5),d0		; Get feedback/algorithm
		andi.w	#7,d0			; Want only algorithm
		move.b	FMSlotMask(pc,d0.w),d4	; Get slot mask
		move.b	9(a5),d3		; Get track volume attenuation
		bmi.s	@locret	; If negative, stop
		moveq	#3,d5

@sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4		; Is bit set for this operator in the mask?
		bcc.s	@senttl		; Branch if not
		add.b	d3,d1		; Include additional attenuation
		blo.s	@senttl		; Branch on overflow
		jsr	WriteFMIorII(pc)

@senttl:
		dbf	d5,@sendtlloop

@locret:
		rts	
; End of function SendVoiceTL

; ===========================================================================
FMInstrumentOperatorTable:
		dc.b  $30								; Detune/multiple operator 1
		dc.b  $38								; Detune/multiple operator 3
		dc.b  $34								; Detune/multiple operator 2
		dc.b  $3C								; Detune/multiple operator 4
		dc.b  $50								; Rate scalling/attack rate operator 1
		dc.b  $58								; Rate scalling/attack rate operator 3
		dc.b  $54								; Rate scalling/attack rate operator 2
		dc.b  $5C								; Rate scalling/attack rate operator 4
		dc.b  $60								; Amplitude modulation/first decay rate operator 1
		dc.b  $68								; Amplitude modulation/first decay rate operator 3
		dc.b  $64								; Amplitude modulation/first decay rate operator 2
		dc.b  $6C								; Amplitude modulation/first decay rate operator 4
		dc.b  $70								; Secondary decay rate operator 1
		dc.b  $78								; Secondary decay rate operator 3
		dc.b  $74								; Secondary decay rate operator 2
		dc.b  $7C								; Secondary decay rate operator 4
		dc.b  $80								; Secondary amplitude/release rate operator 1
		dc.b  $88								; Secondary amplitude/release rate operator 3
		dc.b  $84								; Secondary amplitude/release rate operator 2
		dc.b  $8C								; Secondary amplitude/release rate operator 4
FMInstrumentTLTable:
		dc.b  $40								; Total level operator 1
		dc.b  $48								; Total level operator 3
		dc.b  $44								; Total level operator 2
		dc.b  $4C								; Total level operator 4
; ===========================================================================

cfModulation:
		bset	#3,(a5)		; Turn on modulation
		move.l	a4,$14(a5)	; Save pointer to modulation data
		move.b	(a4)+,$18(a5)	; Modulation delay
		move.b	(a4)+,$19(a5)	; Modulation speed
		move.b	(a4)+,$1A(a5)	; Modulation delta
		move.b	(a4)+,d0	; Modulation steps...
		lsr.b	#1,d0		; ... divided by 2...
		move.b	d0,$1B(a5)	; ... before being stored
		clr.w	$1C(a5)		; Total accumulated modulation frequency change
		rts	
; ===========================================================================

cfEnableModulation:
		bset	#3,(a5)		; Turn on modulation
		rts	
; ===========================================================================

cfStopTrack:
		bclr	#7,(a5)		; Stop track
		bclr	#4,(a5)		; Clear 'do not attack next note' bit
		tst.b	1(a5)		; Is this a PSG track?
		bmi.s	@stoppsg	; Branch if yes
		tst.b	f_updating_dac(a6)	; Is this the DAC we are updating?
		bmi.w	@locexit	; Exit if yes
		jsr	FMNoteOff(pc)
		bra.s	@stoppedchannel
; ===========================================================================

@stoppsg:
		jsr	PSGNoteOff(pc)

@stoppedchannel:
		tst.b	f_voice_selector(a6)	; Are we updating SFX?
		bpl.w	@locexit				; Exit if not
		clr.b	v_sndprio(a6)		; Clear priority
		moveq	#0,d0
		move.b	1(a5),d0	; Get voice control bits
		bmi.s	@getpsgptr	; Branch if PSG
		lea	BGMChannelRAM(pc),a0
		movea.l	a5,a3
		cmpi.b	#4,d0	; Is this FM4?
		bne.s	@getpointer	; Branch if not
		tst.b	v_sfx2_fm4_playback_control(a6)	; Is special SFX playing?
		bpl.s	@getpointer		; Branch if not
		lea	v_sfx2_fm4_track(a6),a5
		movea.l	v_special_voice_ptr(a6),a1	; Get voice pointer
		bra.s	@gotpointer
; ===========================================================================

@getpointer:
		subq.b	#2,d0		; SFX can only use FM3 and up
		lsl.b	#2,d0
		movea.l	(a0,d0.w),a5
		tst.b	(a5)		; Is track playing?
		bpl.s	@novoiceupd	; Branch if not
		movea.l	v_voice_ptr(a6),a1	; Get voice pointer

@gotpointer:
		bclr	#2,(a5)		; Clear SFX overriding bit
		bset	#1,(a5)		; Set track at rest bit
		move.b	$B(a5),d0	; Current voice
		jsr	SetVoice(pc)

@novoiceupd:
		movea.l	a3,a5
		bra.s	@locexit
; ===========================================================================

@getpsgptr:
		lea	v_sfx2_psg3_track(a6),a0
		tst.b	(a0)	; Is track playing?
		bpl.s	@getchannelptr	; Branch if not
		cmpi.b	#$E0,d0		; Is it the noise channel?
		beq.s	@gotchannelptr	; Branch if yes
		cmpi.b	#$C0,d0		; Is it PSG 3?
		beq.s	@gotchannelptr	; Branch if yes

@getchannelptr:
		lea	BGMChannelRAM(pc),a0
		lsr.b	#3,d0
		movea.l	(a0,d0.w),a0

@gotchannelptr:
		bclr	#2,(a0)		; Clear SFX overriding bit
		bset	#1,(a0)		; Set track at rest bit
		cmpi.b	#$E0,1(a0)	; Is this a noise pointer?
		bne.s	@locexit	; Branch if not
		move.b	$1F(a0),(PSG).l	; Set noise tone

@locexit:
		addq.w	#8,sp		; Tamper with return value so we don't go back to caller
		rts	
; ===========================================================================

cfSetPSGNoise:
		move.b	#$E0,1(a5)	; Turn channel into noise channel
		move.b	(a4)+,$1F(a5)	; Save noise tone
		btst	#2,(a5)		; Is track being overridden?
		bne.s	@locret	; Return if yes
		move.b	-1(a4),(PSG).l	; Set tone

@locret:
		rts	
; ===========================================================================

cfDisableModulation:
		bclr	#3,(a5)		; Disable modulation
		rts	
; ===========================================================================

cfSetPSGTone:
		move.b	(a4)+,$B(a5)	; Set current PSG tone
		rts	
; ===========================================================================

cfJumpTo:
		move.b	(a4)+,d0	; High byte of offset
		lsl.w	#8,d0		; Shift it into place
		move.b	(a4)+,d0	; Low byte of offset
		adda.w	d0,a4		; Add to current position
		subq.w	#1,a4		; Put back one byte
		rts	
; ===========================================================================

cfRepeatAtPos:
		moveq	#0,d0
		move.b	(a4)+,d0	; Loop index
		move.b	(a4)+,d1	; Repeat count
		tst.b	$24(a5,d0.w)	; Has this loop already started?
		bne.s	@loopexists	; Branch if yes
		move.b	d1,$24(a5,d0.w)	; Initialize repeat count

@loopexists:
		subq.b	#1,$24(a5,d0.w)	; Decrease loop's repeat count
		bne.s	cfJumpTo	; If nonzero, branch to target
		addq.w	#2,a4	; Skip target address
		rts	
; ===========================================================================

cfJumpToGosub:
		moveq	#0,d0
		move.b	$D(a5),d0	; Current stack pointer
		subq.b	#4,d0		; Add space for another target
		move.l	a4,(a5,d0.w)	; Put in current address (*before* target for jump!)
		move.b	d0,$D(a5)	; Store new stack pointer
		bra.s	cfJumpTo
; ===========================================================================

cfOpF9:
		move.b	#$88,d0		; D1L/RR of Operator 3
		move.b	#$F,d1		; Loaded with fixed value (max RR, 1TL)
		jsr	WriteFMI(pc)
		move.b	#$8C,d0		; D1L/RR of Operator 4
		move.b	#$F,d1		; Loaded with fixed value (max RR, 1TL)
		bra.w	WriteFMI

; ===========================================================================

		include	'_proc\swa.smps.extension.asm'
		include	'_proc\swa.smps.music.asm'
		include	'_proc\swa.smps.sounds.asm'
		include	'_proc\swa.megapcm.asm'

