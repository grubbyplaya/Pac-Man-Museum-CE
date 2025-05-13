.ASSUME ADL=0

#define PatternGen	SegaVRAM + $2800
#define ColorTable	SegaVRAM + $3F80
#define SpritePTR	SegaVRAM + $2000

.db $FF
.ORG 0

.dl MuseumHeader
.dl MuseumIcon
.dl HeaderEnd

MuseumHeader:
	.db $83, "Super Pac-Man (Sord Ver.)",0,0
MuseumIcon:
#import "src/includes/gfx/logos/superpac.bin"
HeaderEnd:

.ORG $4018

SetupGame:
	ld hl, $C000
	ld de, $C000 + 1
	ld bc, $0FFF
	ld (hl), $00
	ldir

	ld hl, HandleInterrupt
	ld de, $0038
	ld bc, 3
	ldir

	ld.lil hl, DATA_401C + romStart
	ld.lil de, SegaVRAM + $2800
	ld bc, $0450
	ldir.lil

	ld.lil hl, DATA_4474 + romStart
	ld.lil de, SegaVRAM + $3F80
	ld bc, $20
	ldir.lil

	ld e, 0
	ld a, $D0
	ld.lil (de), a

LABEL_2007:
	di
	ld sp, $C300
	call LABEL_27DB
	call LABEL_2B10
	ld hl, $C300
	ld de, $C300 + 1
	ld bc, $00FF
	ld (hl), $00
	ldir
	ld hl, DATA_20EE
	ld de, $C300
	ld bc, $0030
	ldir
	call LABEL_3F3F
	call LABEL_2CF6
	call LABEL_211E
	ld a, $FF
	ld ($C33D), a
	ld a, $01
	ld ($C33E), a
	ld ($C39A), a
	ld ($C335), a
	ld a, $03
	ld ($C33F), a
	ld hl, LABEL_2E0B
	ld ($C400), hl
LABEL_205B:
	di

	ld a, (FrameCounter)
	rrca
	call nc, DrawScreen

	ld hl, FrameCounter
	inc (hl)

	ei
_:	ld hl, ($C330)
	dec l
	jr nz, -_
	inc h
	ld ($C330), hl
	ld.lil hl, $CF00 + romStart
	ld.lil de, SegaVRAM + $3F00
	ld bc, $0080
	call LABEL_3F48
	call LABEL_2C73
	call LABEL_2D44
	call LABEL_20C9
	call LABEL_33DA
	call LABEL_3E84
	call LABEL_3DAD
	call LABEL_2149
	jr LABEL_205B

LABEL_2089:
	ex af, af'

	call.lil CheckForExit

	ld a, 8
	ld.lil (mpLcdIcr), a
	ld a, $01
	ld ($C330), a
	ex af, af'
	reti

FrameCounter:
	.db $00

GetDPADInput:
	ld.lil a, (KbdG7)
	ld c, a
	xor a
	bit 0, c
	jr z, +_
	set 3, a
_:	bit 1, c
	jr z, +_
	set 2, a
_:	bit 2, c
	jr z, +_
	set 0, a
_:	bit 3, c
	jr z, +_
	set 1, a
_:	push hl
	ld l, a
	ld h, $11
	mlt hl
	ld a, l
	pop hl
	ret

; Data from 2094 to 20A3 (16 bytes)
DATA_2094:
	.db $00, $80, $E2, $81, $0F, $82, $FE, $83, $05, $84, $7E, $85, $04, $86, $00, $87

LABEL_20A4:
	call LABEL_20AE
	push af
	call LABEL_20AE
	pop hl
	ld l, a
	ret

LABEL_20AE:
	ld hl, ($C37E)
	ld a, l
	add a, a
	add a, a
	ld a, l
	inc a
	ld l, a
	ld a, h
	and $90
	jr z, LABEL_20C0
	xor $90
	jr nz, LABEL_20C1
LABEL_20C0:
	scf
LABEL_20C1:
	ld a, h
	rla
	ld h, a
	ld ($C37E), hl
	add a, l
	ret

LABEL_20C9:
	ld a, ($C340)
	and a
	ret nz
	ld hl, $0000

	; check for mode, 1, 2, 5, or 6 keys
	ld.lil a, (KbdG1)
	bit kbitMode, a
	jr nz, LABEL_20DF	; enable 1 player mode if keys 1, mode, or 5 are pressed
	ld.lil a, (KbdG3)
	bit kbit1, a
	jr nz, LABEL_20DF
	ld.lil a, (KbdG4)
	bit kbit5, a
	jr nz, LABEL_20DF
	bit kbit2, a
	jr nz, LABEL_20DE
	ld.lil a, (KbdG5)
	bit kbit6, a
	ret z
LABEL_20DE:	; enable 2 player mode if keys 2 or 6 are pressed
	inc h
LABEL_20DF:
	ld ($C332), hl
	ld hl, LABEL_2ECF
	ld ($C400), hl
	ld a, $01
	ld ($C340), a
	ret

; Data from 20EE to 211D (48 bytes)
DATA_20EE:
	.db $EB, $BE, $82, $28, $C3, $3C, $AA, $AA, $C5, $3A, $00, $3C, $AA, $AA, $AA, $AA
	.fill 18, $F0
	.db $60, $50, $D0, $A0, $20, $20, $B0, $90, $50, $50, $90, $50, $50, $50

LABEL_211E:
	ld hl, DATA_22B6
	ld de, $C610
	ld bc, $000B
	ldir
	ld hl, $C620
	ld bc, $1800
LABEL_212F:
	ld (hl), c
	inc l
	djnz LABEL_212F
	ld de, $2020
	ld ($C640), de
	ld ($C642), de
	ld hl, $C600
	ld bc, $1000
LABEL_2144:
	ld (hl), c
	inc l
	djnz LABEL_2144
	ret

LABEL_2149:
	ld hl, $C640
	ld de, $C600
	ld bc, $0606
	call LABEL_2185
	bit 5, (hl)
	jr nz, LABEL_2164
	jp LABEL_2178

LABEL_2164:
	inc l
	ld de, $C606
	ld bc, $040A
	call LABEL_2185
	inc l
	ld de, $C60A
	ld bc, $0610
	call LABEL_2185
LABEL_2178:
	ld hl, $C600
	ld bc, $0B00
LABEL_217E:
	ld (hl), c
	inc l
	djnz LABEL_217E
	jp LABEL_219F

LABEL_2185:
	ld a, (de)
	and a
	jr nz, LABEL_218D
	inc e
	djnz LABEL_2185
	ret

LABEL_218D:
	ld a, c
	sub b
	ld b, a
	ld a, (hl)
	bit 5, a
	jr nz, LABEL_219A
	and $1F
	cp b
	ret c
	ret z
LABEL_219A:
	ld a, b
	add a, $80
	ld (hl), a
	ret

LABEL_219F:
	ld hl, $C640
	ld de, $C610
	ld ix, $C620
	ld bc, $0200
	ld a, (hl)
	bit 5, a
	jr nz, LABEL_21D6
	bit 7, a
	jr z, LABEL_21D2
	ld a, $20
	ld ($C641), a
	ld ($C642), a
	ld ($C643), a
	ld a, $9F
	ld ($C612), a
	ld a, $BF
	ld ($C615), a
	ld a, $DF
	ld ($C618), a
	call LABEL_21F3
LABEL_21D2:
	call LABEL_221B
	ret

LABEL_21D6:
	inc l
LABEL_21D7:
	ld a, (hl)
	bit 7, a
	call nz, LABEL_21F3
	ld a, (hl)
	bit 6, a
	call nz, LABEL_221B
	push hl
	ex de, hl
	ld de, $0003
	add hl, de
	ld e, $08
	add ix, de
	ex de, hl
	pop hl
	inc l
	djnz LABEL_21D7
	ret

LABEL_21F3:
	push bc
	push hl
	push de
	ld a, (hl)
	sub $40
	ld (hl), a
	add a, a
	add a, a
	ld c, a
	ld a, b
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_2217 - 2
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld b, $00
	ld hl, DATA_22D9
	add hl, bc
	ld c, $04
	ldir
	pop de
	pop hl
	pop bc
	ret

; Pointer Table from 2217 to 221A (2 entries, indexed by unknown)
DATA_2217:
	.dw $C628, $C620

LABEL_221B:
	push bc
	push hl
	push de
	ld a, (ix+6)
	and a
	jp nz, LABEL_2283
	ld l, (ix+0)
	ld h, (ix+1)
	inc hl
	ld a, (hl)
	ld (ix+6), a
	inc hl
	ld (ix+0), l
	ld (ix+1), h
	dec hl
	dec hl
	ld a, (hl)
	inc a
	jp z, LABEL_22A2
	dec a
	ld c, a
	and $0F
	jp z, LABEL_227D
	dec a
	ld b, a
	ld a, c
	and $F0
	rrca
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, DATA_22C1
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
LABEL_2258:
	add hl, hl
	djnz LABEL_2258
	ld a, l
	rrca
	rrca
	rrca
	rrca
	and $0F
	ld b, a
	pop de
	push de
	ld a, (de)
	and $F0
	add a, b
	ld (de), a
	inc e
	ld a, h
	ld (de), a
	dec e
	ld a, (ix+2)
	ld (ix+4), a
	ld a, (ix+3)
	ld (ix+5), a
	jp LABEL_2283

LABEL_227D:
	ld (ix+4), $17
	pop de
	push de
LABEL_2283:
	inc e
	inc e
	ld a, (de)
	and $F0
	ld b, a
	ld l, (ix+4)
	ld h, (ix+5)
	ld a, (hl)
	and $0F
	add a, b
	ld (de), a
	inc hl
	ld (ix+4), l
	ld (ix+5), h
	dec (ix+6)
	pop de
	pop hl
	pop bc
	ret

LABEL_22A2:
	pop de
	pop hl
	ld a, (hl)
	sub $20
	ld (hl), a
	inc e
	inc e
	ld a, (de)
	or $0F
	ld (de), a
	dec e
	dec e
	xor a
	ld (ix+6), a
	pop bc
	ret

; Data from 22B6 to 22C0 (11 bytes)
DATA_22B6:
	.db $80, $00, $9F, $A0, $00, $BF, $C0, $00, $DF, $E0, $FF

; Data from 22C1 to 22D8 (24 bytes)
DATA_22C1:
	.db $FC, $01, $DE, $01, $C4, $01, $AB, $01, $93, $01, $7D, $01, $67, $01, $53, $01
	.db $40, $01, $2E, $01, $1D, $01, $0D, $01

; Data from 22D9 to 25F2 (794 bytes)
DATA_22D9:
	.dw DATA_2357, DATA_2327, DATA_238E, DATA_2327, DATA_23AF, DATA_2327, DATA_241A, DATA_2337
	.dw DATA_2491, DATA_2337, DATA_24A2, DATA_2337, DATA_24E3, DATA_2337, DATA_2502, DATA_2337
	.dw DATA_2517, DATA_2337, DATA_2530, DATA_2337, DATA_254D, DATA_2337, DATA_256E, DATA_2347
	.dw DATA_2581, DATA_2347, DATA_258C, DATA_2347, DATA_25A5, DATA_2347, DATA_25C6, DATA_2347
	.dw $0F0F, $0F0F, $0F0F, $0F0F, $0F0F, $0F0F, $0F0F
	

; 2nd entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2327 to 2336 (16 bytes)	
DATA_2327:	
	.db $0F, $0F, $00, $01, $02, $03, $04, $05, $06, $07, $07, $07, $07, $07, $07, $07, $07, $07
	
; 8th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2337 to 2346 (16 bytes)	
DATA_2337:	
	.fill 16, $00
	
; 24th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2347 to 2356 (16 bytes)	
DATA_2347:	
	.fill 16, $02
	
; 1st entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2357 to 238D (55 bytes)	
DATA_2357:	
	.db $94, $0C, $A4, $04, $33, $08, $73, $08, $A3, $08, $A3, $08, $A3, $10, $A4
	.db $0C, $B4, $04, $43, $08, $83, $08, $B3, $08, $B3, $08, $B3, $10, $94, $0C, $A4
	.db $04, $33, $08, $73, $08, $A3, $08, $A3, $08, $A3, $10, $83, $08, $63, $10, $43
	.db $08, $33, $08, $33, $08, $33
	
; 3rd entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 238E to 23AE (33 bytes)	
DATA_238E:	
	.db $10, $FF, $34, $08, $34, $08, $34, $08, $04, $04, $A5, $04, $34, $08, $64, $08, $84
	.db $08, $94, $08, $83, $08, $63, $08, $33, $08, $63, $08, $33, $08, $C0, $08, $35
	
; 5th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 23AF to 2419 (107 bytes)	
DATA_23AF:	
	.db $08, $FF, $34, $08, $34, $08, $34, $08, $04, $04, $A5, $04, $34, $08, $64, $08, $84
	.db $08, $94, $08, $A3, $02, $B3, $02, $A3, $02, $93, $02, $83, $02, $73, $02, $93
	.db $02, $A3, $02, $93, $02, $83, $02, $73, $02, $63, $02, $83, $02, $93, $02, $83
	.db $02, $73, $02, $63, $02, $53, $02, $73, $02, $83, $02, $73, $02, $63, $02, $53
	.db $02, $43, $02, $63, $02, $73, $02, $63, $02, $53, $02, $43, $02, $33, $02, $53
	.db $02, $63, $02, $53, $02, $43, $02, $33, $02, $23, $02, $43, $02, $53, $02, $43
	.db $02, $33, $02, $84, $08, $74, $08, $C0, $08, $35
	
; 7th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 241A to 2490 (119 bytes)	
DATA_241A:	
	.db $08, $FF, $A3, $02, $B3, $02, $A3, $02, $93, $02, $83, $02, $73, $02, $93, $02, $A3
	.db $02, $93, $02, $83, $02, $73, $02, $63, $02, $83, $02, $93, $02, $83, $02, $73
	.db $02, $63, $02, $53, $02, $73, $02, $83, $02, $73, $02, $63, $02, $53, $02, $43
	.db $02, $63, $02, $73, $02, $63, $02, $53, $02, $43, $02, $33, $02, $53, $02, $63
	.db $02, $53, $02, $43, $02, $33, $02, $23, $02, $43, $02, $53, $02, $43, $02, $33
	.db $02, $23, $02, $13, $02, $85, $01, $04, $01, $44, $01, $84, $01, $03, $01, $43
	.db $01, $83, $01, $02, $01, $C0, $02, $85, $01, $04, $01, $44, $01, $84, $01, $03
	.db $01, $43, $01, $83, $01, $02	
; 9th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2491 to 24A1 (17 bytes)	
DATA_2491:	
	.db $01, $FF, $33, $06, $32, $06, $A3, $06, $73, $06, $32, $06, $A3, $06, $C0, $06, $12
	
; 11th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 24A2 to 24E2 (65 bytes)	
DATA_24A2:	
	.db $10, $FF, $05, $01, $45, $01, $85, $01, $A5, $01, $05, $01, $25, $01, $45, $01, $65
	.db $01, $85, $01, $A5, $01, $04, $01, $14, $01, $24, $01, $34, $01, $44, $01, $54
	.db $01, $64, $01, $74, $01, $84, $01, $94, $01, $A4, $01, $B4, $01, $03, $01, $23
	.db $01, $43, $01, $63, $01, $83, $01, $A3, $01, $02, $01, $32, $01, $62, $01, $92
	
; 13th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 24E3 to 2501 (31 bytes)	
DATA_24E3:	
	.db $01, $FF, $74, $02, $84, $02, $A4, $02, $03, $02, $23, $02, $84, $02, $A4, $02, $03
	.db $02, $23, $02, $33, $02, $A4, $02, $03, $02, $23, $02, $33, $02, $53
	
; 15th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2502 to 2516 (21 bytes)	
DATA_2502:	
	.db $02, $FF, $04, $01, $12, $02, $24, $03, $32, $01, $44, $02, $52, $03, $44, $01, $32
	.db $02, $24, $03, $12
	
; 17th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2517 to 252F (25 bytes)	
DATA_2517:	
	.db $01, $FF, $B6, $02, $B3, $02, $05, $04, $63, $02, $15, $02, $13, $04, $25, $02, $84
	.db $02, $35, $04, $34, $02, $45, $02, $95
	
; 19th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2530 to 254C (29 bytes)	
DATA_2530:	
	.db $04, $FF, $04, $01, $44, $01, $74, $01, $A4, $01, $03, $01, $23, $01, $C0, $02, $23
	.db $01, $03, $01, $A4, $01, $74, $01, $44, $01, $04, $01, $C0
	
; 21st entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 254D to 256D (33 bytes)	
DATA_254D:	
	.db $01, $FF, $33, $08, $53, $08, $73, $08, $83, $08, $A3, $08, $02, $08, $22, $08, $32
	.db $08, $33, $08, $53, $08, $73, $08, $83, $08, $A3, $08, $02, $08, $22, $08, $32
	
; 23rd entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 256E to 2580 (19 bytes)	
DATA_256E:	
	.db $08, $FF, $02, $04, $83, $04, $12, $04, $93, $04, $22, $04, $A3, $04, $32, $04, $B3
	.db $04, $C0
	
; 25th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 2581 to 258B (11 bytes)	
DATA_2581:	
	.db $03, $35, $02, $25, $02, $A5, $02, $B5, $02, $C0
	
; 27th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 258C to 25A4 (25 bytes)	
DATA_258C:	
	.db $03, $FF, $84, $01, $A4, $01, $03, $01, $33, $01, $53, $01, $73, $01, $53, $01, $33
	.db $01, $03, $01, $A4, $01, $84, $01, $C0
	
; 29th entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 25A5 to 25C5 (33 bytes)	
DATA_25A5:	
	.db $02, $FF, $84, $01, $94, $01, $B4, $01, $03, $01, $13, $01, $33, $01, $43, $01, $53
	.db $01, $33, $01, $23, $01, $13, $01, $B4, $01, $A4, $01, $94, $01, $74, $01, $C0
	
; 31st entry of Pointer Table from 22D8 (indexed by $C641)	
; Data from 25C6 to 25F1 (44 bytes)	
DATA_25C6:	
	.db $03, $FF, $84, $01, $94, $01, $A4, $01, $B4, $01, $03, $01, $13, $01, $23, $01, $33
	.db $01, $43, $01, $53, $01, $43, $01, $33, $01, $23, $01, $13, $01, $03, $01, $B4
	.db $01, $A4, $01, $94, $01, $84, $01, $74, $01, $C0, $04, $FF
	
; Data from 25F2 to 27D9 (488 bytes)	
DATA_25F2:	
	.db $3C, $42, $99, $A1, $A1, $99, $42, $3C, $00, $00, $00, $0F, $3F, $70, $40, $70
	.db $00, $00, $00, $80, $E0, $76, $19, $71, $7F, $7F, $3F, $3F, $1F, $0F, $07, $00
	.db $F1, $F6, $F8, $E0, $C0, $80, $00, $00, $00, $00, $01, $1D, $3E, $3F, $3F, $3F
	.db $00, $00, $00, $70, $F8, $FC, $FC, $FC, $3F, $3F, $1F, $1F, $0F, $06, $00, $00
	.db $EC, $EC, $D8, $F8, $F0, $E0, $00, $00, $00, $00, $00, $00, $00, $01, $1E, $3B
	.db $00, $00, $0C, $3C, $D0, $10, $20, $40, $3E, $2D, $35, $1D, $01, $00, $00, $00
	.db $B0, $B8, $F8, $78, $98, $F0, $00, $00, $00, $00, $1F, $3F, $72, $72, $07, $0C
	.db $00, $00, $F8, $FC, $4E, $4E, $E0, $30, $08, $19, $19, $38, $3C, $3F, $00, $00
	.db $10, $98, $98, $5C, $3C, $FC, $00, $00, $00, $00, $00, $02, $07, $01, $02, $02
	.db $00, $78, $84, $8C, $7C, $9E, $7E, $FE, $0D, $1D, $3F, $7F, $7F, $7F, $3F, $00
	.db $FE, $FE, $FC, $F0, $C0, $80, $00, $00, $00, $01, $03, $0F, $1F, $1F, $3E, $3F
	.db $00, $00, $C0, $F0, $F8, $F8, $FC, $7C, $3F, $3F, $1F, $0C, $03, $07, $00, $00
	.db $7C, $7C, $78, $B0, $80, $00, $00, $00, $00, $03, $00, $19, $3F, $37, $19, $06
	.db $20, $C0, $00, $98, $FC, $74, $98, $60, $0F, $0D, $06, $01, $03, $03, $01, $00
	.db $F0, $D0, $60, $80, $C0, $40, $80, $00, $00, $00, $00, $01, $03, $06, $06, $0F
	.db $00, $18, $F4, $F8, $38, $7C, $FC, $FC, $0F, $1F, $30, $38, $1D, $03, $03, $00
	.db $FC, $FC, $8E, $86, $9C, $78, $00, $00
DATA_26FB:
	.db $FF, $FF, $C0, $C0, $C0, $C0, $C0, $C0
	.db $C0, $80, $00, $00, $00, $00, $00, $00, $FF, $FF, $00, $00, $00, $00, $00, $00
	.db $FF, $00, $00, $00, $00, $00, $00, $00, $80, $40
	.fill 10, $00
	.db $03, $07, $0F, $0F, $00, $00, $00, $03, $0F, $0F, $1F, $1F, $00, $03, $0F, $1F
	.db $3F, $3F, $7F, $7F, $00, $00, $03, $07, $03, $01, $00, $00, $00, $00, $C0, $F0
	.db $F8, $F8, $FC, $7C, $07, $1F, $0F, $07, $03, $01, $00, $00, $E0, $F8, $FC, $FE
	.db $FE, $FF, $FF, $7F, $00, $00, $03, $0F, $1F, $0F, $03, $00, $00, $00, $C0, $F0
	.db $F8, $F8, $FC, $FC, $07, $1F, $3F, $7F, $3F, $0F, $03, $00, $E0, $F8, $FC, $FE
	.db $FE, $FF, $FF, $FF, $00, $00, $03, $0F, $1F, $1F, $3F, $3F, $3F, $3F, $3F, $3F
	.db $36, $22, $00, $00, $3F, $3F, $3F, $3F, $3B, $11
	.fill 10, $00
	.db $C0, $C0, $C0, $C0, $C1, $C1, $CF, $C7, $C3, $C7, $C6, $C4, $C0, $C0, $C0, $C0
	.db $00, $00, $00, $00, $07, $1F, $3F, $3F, $7F, $7F, $7F, $66, $00, $00, $00, $00
	.db $7F, $7F, $7F, $39, $00, $00, $00, $00, $00, $03, $07, $0F, $0F, $0F, $1F, $1F
	.db $1F, $1F, $1F, $1F, $1F, $16, $12, $00, $1F, $1F, $1F, $1F, $1F, $1D, $09, $00

LABEL_27DB:
	ld c, $40
	ld de, $C800
LABEL_27E0:
	ld b, $10
	ld hl, DATA_2840
	call LABEL_2B45
	ld a, c
	add a, $10
	ld c, a
	cp $80
	jr nz, LABEL_27E0
	ld bc, $1000
	call LABEL_2B45
	ld hl, $CA40
	ld bc, $0100
	ldir
	ld hl, DATA_2860
	ld bc, $1000
	call LABEL_2B45
	ld hl, $CB80
	ld bc, $0080
	ldir
	ld hl, DATA_2890
	ld bc, $0280
	ldir
	ld de, $CA40
	ld hl, DATA_2870
	ld c, $09
LABEL_281F:
	call LABEL_2831
	dec c
	jr nz, LABEL_281F
	ld.lil hl, $C800 + romStart
	ld.lil de, SegaVRAM + $2000
	ld bc, $0800
	jp LABEL_3F48

LABEL_2831:
	push hl
	call LABEL_2836
	pop hl
LABEL_2836:
	ld b, $20
LABEL_2838:
	ld a, (de)
	xor (hl)
	ld (de), a
	inc de
	inc hl
	djnz LABEL_2838
	ret

; Data from 2840 to 2840 (1 bytes)
DATA_2840:
	.db $0C

; Pointer Table from 2841 to 2842 (1 entries, indexed by unknown)
	.dw $040A

; Data from 2843 to 285F (29 bytes)
	.db $02, $07, $0A, $03, $0D, $00, $05, $08, $0D, $0C, $01, $08, $06, $6C, $6A, $68
	.db $6D, $7C, $7A, $78, $7D, $80, $88, $84, $8C, $80, $90, $84, $94

; Data from 2860 to 286F (16 bytes)
DATA_2860:
	.db $B0, $B8, $B4, $BC, $B0, $C0, $B4, $C4, $C8, $D0, $CC, $D4, $C8, $D8, $CC, $DC

; Data from 2870 to 288F (32 bytes)
DATA_2870:
	.db $00, $00, $00, $00, $00, $00, $04, $00, $00, $09, $16
	.fill 11, $00
	.db $20, $00, $00, $90, $68, $00, $00, $00, $00, $00

; Data from 2890 to 2B0F (640 bytes)
DATA_2890:
	.db $00, $00, $00, $00, $03, $04, $05, $05, $02
	.fill 11, $00
	.db $60, $90, $B0, $B0, $40
	.fill 11, $00
	.db $06, $0F, $09, $06
	.fill 12, $00
	.db $C0, $E0, $20, $C0
	.fill 12, $00
	.db $06, $09, $0D, $0D, $02
	.fill 11, $00
	.db $C0, $20, $A0, $A0, $40
	.fill 13, $00
	.db $03, $04, $07, $03
	.fill 12, $00
	.db $60, $90, $F0, $60
	.fill 12, $00
	.db $03, $05, $05
	.fill 13, $00
	.db $30, $D8, $18
	.fill 10, $00
	.db $06, $06, $05, $05, $02
	.fill 11, $00
	.db $C0, $C0, $40, $40, $80
	.fill 14, $00
	.db $0C, $1B, $19
	.fill 13, $00
	.db $C0, $A0, $A0
	.fill 11, $00
	.db $01, $02, $02, $03, $03
	.fill 11, $00
	.db $40, $A0, $A0, $60, $60
	.fill 11, $00
	.db $31, $4A, $0A, $12, $22, $42, $79
	.fill 9, $00
	.db $8C, $52, $52, $52, $52, $52, $8C
	.fill 9, $00
	.db $11, $32, $52, $92, $FA, $12, $11
	.fill 9, $00
	.db $8C, $52, $52, $52, $52, $52, $8C
	.fill 9, $00
	.db $31, $4A, $4A, $32, $4A, $4A, $31
	.fill 9, $00
	.db $8C, $52, $52, $52, $52, $52, $8C
	.fill 9, $00
	.db $88, $91, $A1, $B9, $A5, $A5, $98
	.fill 9, $00
	.db $C6, $29, $29, $29, $29, $29, $C6
	.fill 9, $00
	.db $67, $95, $15, $25, $45, $85, $F7
	.fill 9, $00
	.db $77, $55, $55, $55, $55, $55, $77
	.fill 9, $00
	.db $F7, $85, $85, $E5, $15, $15, $15, $E7, $00, $00, $00, $00, $00, $00, $00, $00
	.db $77, $55, $55, $55, $55, $55, $55, $77, $00, $00, $00, $00, $00, $00, $00, $60
	.db $70, $78, $7C, $7E, $3F, $3F, $1F, $07, $00, $00, $00, $00, $00, $00, $00, $0C
	.db $1C, $3C, $7C, $FC, $F8, $F8, $F0, $C0
	.fill 9, $00
	.db $F0, $FC, $FF, $7F, $3F, $0E
	.fill 10, $00
	.db $0E, $7E, $FE, $FC, $F8, $E0
	.fill 12, $00
	.db $0F, $FF, $FF, $FF, $7F, $1E
	.fill 10, $00
	.db $E0, $FE, $FE, $FC, $F0
	.fill 11, $00
	.db $01, $03, $0F, $1F, $7F, $7E, $3C
	.fill 10, $00
	.db $80, $E0, $F0, $FC, $FC, $78
	.fill 9, $00
	.db $01, $01, $03, $03, $03, $07, $02
	.fill 11, $00
	.db $80, $80, $80, $C0, $80, $00, $00, $00, $00, $00, $00, $04, $02, $10, $08, $00
	.db $30, $00, $08, $12, $04, $00, $00, $00, $00, $00, $00, $40, $90, $20, $00, $18
	.db $00, $20, $10, $80, $40, $00, $00

LABEL_2B10:
	ld hl, DATA_25F2
	ld de, $CC58
	ld bc, $0108
	ldir
	ld hl, DATA_2C0F
	ld bc, $4400
	call LABEL_2B45
	ld hl, $CE80
LABEL_2B27:
	ld de, DATA_2C53
	ld b, $20
LABEL_2B2C:
	ld a, (de)
	or (hl)
	inc h
	ld (hl), a
	dec h
	inc l
	inc de
	djnz LABEL_2B2C
	ld a, l
	and a
	jr nz, LABEL_2B27
	ld.lil hl, $CC58 + romStart
	ld.lil de, $2C58 + SegaVRAM
	ld bc, $03A8
	jp LABEL_3F48

LABEL_2B45:
	push bc
	push hl
	push de
	call LABEL_2B5A
	pop de
	ld hl, $C300
	ld bc, $0008
	ldir
	pop hl
	pop bc
	inc hl
	djnz LABEL_2B45
	ret

LABEL_2B5A:
	ld a, (hl)
	and $F8
	add a, c
	ld de, DATA_26FB
	add a, e
	ld e, a
	jr nc, LABEL_2B66
	inc d
LABEL_2B66:
	ld a, (hl)
	and $07
	add a, a
	ld hl, DATA_2B77
	add a, l
	ld l, a
	jr nc, LABEL_2B72
	inc h
LABEL_2B72:
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

; Jump Table from 2B77 to 2B7E (4 entries, indexed by unknown)
DATA_2B77:
	.dw LABEL_2B87, LABEL_2B91, LABEL_2BA4, LABEL_2BB7

; Jump Table from 2B7F to 2B86 (4 entries, indexed by unknown)
DATA_2B7F:
	.dw LABEL_2BCA, LABEL_2BDD, LABEL_2BE9, LABEL_2BFC

; 1st entry of Jump Table from 2B77 (indexed by unknown)
LABEL_2B87:
	ex de, hl
	ld de, $C300
	ld bc, $0008
	ldir
	ret

; 2nd entry of Jump Table from 2B77 (indexed by unknown)
LABEL_2B91:
	ld c, $08
LABEL_2B93:
	ld hl, $C300
	ld a, (de)
	ld b, $08
LABEL_2B99:
	rrca
	rl (hl)
	inc hl
	djnz LABEL_2B99
	inc de
	dec c
	jr nz, LABEL_2B93
	ret

; 3rd entry of Jump Table from 2B77 (indexed by unknown)
LABEL_2BA4:
	ld c, $08
	ld hl, $C307
LABEL_2BA9:
	ld a, (de)
	ld b, $08
LABEL_2BAC:
	rlca
	rr (hl)
	djnz LABEL_2BAC
	inc de
	dec hl
	dec c
	jr nz, LABEL_2BA9
	ret

; 4th entry of Jump Table from 2B77 (indexed by unknown)
LABEL_2BB7:
	ld c, $08
LABEL_2BB9:
	ld hl, $C300
	ld a, (de)
	ld b, $08
LABEL_2BBF:
	rlca
	rr (hl)
	inc hl
	djnz LABEL_2BBF
	inc de
	dec c
	jr nz, LABEL_2BB9
	ret

; 1st entry of Jump Table from 2B7F (indexed by unknown)
LABEL_2BCA:
	ld c, $08
	ld hl, $C300
LABEL_2BCF:
	ld a, (de)
	ld b, $08
LABEL_2BD2:
	rlca
	rr (hl)
	djnz LABEL_2BD2
	inc hl
	inc de
	dec c
	jr nz, LABEL_2BCF
	ret

; 2nd entry of Jump Table from 2B7F (indexed by unknown)
LABEL_2BDD:
	ld b, $08
	ld hl, $C307
LABEL_2BE2:
	ld a, (de)
	ld (hl), a
	dec hl
	inc de
	djnz LABEL_2BE2
	ret

; 3rd entry of Jump Table from 2B7F (indexed by unknown)
LABEL_2BE9:
	ld c, $08
LABEL_2BEB:
	ld hl, $C300
	ld a, (de)
	ld b, $08
LABEL_2BF1:
	rrca
	rr (hl)
	inc hl
	djnz LABEL_2BF1
	inc de
	dec c
	jr nz, LABEL_2BEB
	ret

; 4th entry of Jump Table from 2B7F (indexed by unknown)
LABEL_2BFC:
	ld c, $08
LABEL_2BFE:
	ld hl, $C300
	ld a, (de)
	ld b, $08
LABEL_2C04:
	rlca
	rl (hl)
	inc hl
	djnz LABEL_2C04
	inc de
	dec c
	jr nz, LABEL_2BFE
	ret

; Pointer Table from 2C0F to 2C10 (1 entries, indexed by unknown)
DATA_2C0F:
	.dw $4840

; Data from 2C11 to 2C52 (66 bytes)
	.db $45, $4D, $0A, $0D, $0C, $08, $28, $2C, $2D, $2A, $30, $34, $35, $32, $38, $3C
	.db $3D, $3A, $98, $98, $98, $98, $28, $2C, $2D, $2A, $20, $24, $27, $21, $25, $22
	.db $23, $26, $00, $04, $05, $02, $08, $0C, $0D, $0A, $10, $10, $15, $15, $11, $13
	.db $11, $13, $18, $19, $1D, $1B, $1D, $1D, $98, $98, $11, $13, $11, $13, $A0, $A4
	.db $A8, $AC

; Data from 2C53 to 2C72 (32 bytes)
DATA_2C53:
	.db $00, $00, $00, $01, $06, $07, $07, $01, $00, $00, $00, $80, $60, $E0, $E0, $80
	.db $01, $01, $01, $01, $01, $00, $00, $00, $80, $C0, $80, $C0, $80, $00, $00, $00

LABEL_2C73:
	ld c, $00
	ld hl, ($C332)
	call LABEL_2CD3
	call LABEL_2CE5
	ld a, c
	ld ($C33C), a
	call LABEL_2CA3
	call GetDPADInput
	or e
	ld c, a
	ld a, ($C332)
	and a
	ld a, c
	jr z, LABEL_2C94
	rrca
	rrca
	rrca
	rrca
LABEL_2C94:
	ld b, $04
LABEL_2C96:
	rrca
	jr c, LABEL_2C9C
	djnz LABEL_2C96
	ret

LABEL_2C9C:
	ld a, $04
	sub b
	ld ($C458), a
	ret

LABEL_2CA3:
	ld e, $01
	ld hl, DATA_2CC3
LABEL_2CA8:
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	in a, (c)
	xor b
	jr nz, LABEL_2CB2
	scf
LABEL_2CB2:
	rl e
	jr nc, LABEL_2CA8
	ld a, ($C333)
	and a
	ret nz
	ld a, e
	rlca
	rlca
	rlca
	rlca
	or e
	ld e, a
	ret

; Data from 2CC3 to 2CC4 (2 bytes)
DATA_2CC3:
	.db $DC, $DF

LABEL_2CC5:
	ld (hl), $20
	ld (hl), $04
	ld (hl), $40
	inc (hl)
	ld (bc), a
	inc sp
	ld (bc), a
	ld ($3304), a
	inc b
LABEL_2CD3:
	ld a, l
	and h
	ret nz
	xor a
	and $05
	jr nz, LABEL_2CE2

	ld.lil a, (KbdG3)
	bit kbit1, a
	jr nz, LABEL_2CE2
	ld.lil a, (KbdG4)
	bit kbit2, a
	ret z
LABEL_2CE2:
	ld c, $01
	ret

LABEL_2CE5:
	ld a, l
	xor h
	ret nz
	xor a
	and $48
	jr nz, LABEL_2CE2
	ret

LABEL_2CF6:
	ld hl, $CF00
	ld de, $CF80
	ld bc, $0080
	ldir
	ld hl, $00F0
	ld ($CF00), hl
	ld l, $00
	ld ($CF02), hl
	ld hl, $CF00
	ld de, $CF04
	ld bc, $007C
	ldir
	ld hl, $C400
	ld de, $C500
	ld bc, $0100
	ldir
	ld hl, $C400
	ld bc, $0604
	call LABEL_2D31
	ld hl, $C440
	ld bc, $0E06
LABEL_2D31:
	push bc
	ld de, LABEL_2D92
	ld (hl), e
	inc l
	ld (hl), d
	inc l
	ld c, $00
LABEL_2D3B:
	ld (hl), c
	inc l
	djnz LABEL_2D3B
	pop bc
	dec c
	jr nz, LABEL_2D31
	ret

LABEL_2D44:
	ld ix, $C400
	ld b, $04
LABEL_2D4A:
	push bc
	push hl
	call LABEL_2D85
	ld bc, $0008
	add ix, bc
	pop hl
	pop bc
	djnz LABEL_2D4A
	ld ix, $C440
	ld iy, $CF00
	ld hl, $C450
	ld b, $05
LABEL_2D65:
	push bc
	push hl
	ld de, $C440
	ld bc, $0010
	ldir
	call LABEL_2D85
	pop de
	ld hl, $C440
	ld bc, $0010
	ldir
	ex de, hl
	ld bc, $0004
	add iy, bc
	pop bc
	djnz LABEL_2D65
	ret

LABEL_2D85:
	ld l, (ix+0)
	ld h, (ix+1)
	jp (hl)

LABEL_2D88:
	pop hl
	ld sp, $C2F8
	ld (ix+0), l
	ld (ix+1), h
LABEL_2D92:
	ret

LABEL_2D93:
	ld (ix+2), l
	ld (ix+3), h
	pop hl
	ld sp, $C2F8
	ld (ix+0), l
	ld (ix+1), h
	jp (hl)

LABEL_2DA4:
	ld l, (ix+2)
	ld h, (ix+3)
	dec hl
	ld (ix+2), l
	ld (ix+3), h
	ld a, l
	or h
	jr z, LABEL_2D88
LABEL_2DB9:
	inc sp
	inc sp
	ret

LABEL_2DBC:
	pop hl
	ld sp, $C2F8
	ld (ix+4), l
	ld (ix+5), h
	xor a
	ld (ix+2), a
	ld (ix+3), a
	ld hl, LABEL_2DD6
	ld (ix+0), l
	ld (ix+1), h
LABEL_2DD6:
	ld l, (ix+4)
	ld h, (ix+5)
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	inc bc
	ld a, c
	or b
	jr z, LABEL_2D88
	dec bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ld l, (ix+2)
	ld h, (ix+3)
	and a
	sbc hl, bc
	add hl, bc
	inc hl
	ld (ix+2), l
	ld (ix+3), h
	jr nz, LABEL_2DB9
	call LABEL_2E09
	pop hl
	ld (ix+4), l
	ld (ix+5), h
	ret

LABEL_2E09:
	ex de, hl
	jp (hl)

LABEL_2E0B:
	xor a
	ld ($C340), a
	ld a, $80
	ld ($C334), a
	ld ($C33B), a
	call LABEL_2E1E
	call LABEL_2D88
	ret

LABEL_2E1E:
	ld hl, $0000
LABEL_2E21:
	call LABEL_3E46
	ld a, h
	cp $03
	jr nz, LABEL_2E21
	ld hl, $0020
	ld de, DATA_2E5B
LABEL_2E2F:
	ld a, (de)
	ld c, a
	ld b, $08
LABEL_2E33:
	sla c
	ld a, $20
	jr nc, LABEL_2E3B
	ld a, $80
LABEL_2E3B:
	call LABEL_3E48
	djnz LABEL_2E33
	inc de
	ld a, h
	cp $02
	jr nz, LABEL_2E2F
	ld de, DATA_2E97
	ld hl, $0228
	call LABEL_3ECC
	ld hl, $0287
	call LABEL_3ECC
	ld hl, $02C7
	jp LABEL_3ECC

; Data from 2E5B to 2E96 (60 bytes)
DATA_2E5B:
	.db $3C, $72, $2F, $BC, $22, $8A, $28, $22, $22, $8A, $28, $22, $3C, $8A, $AF, $3C
	.db $20, $8A, $A8, $28, $20, $8B, $68, $24, $20, $72, $2F, $A2, $00, $00, $00, $00
	.db $00, $F0, $87, $00, $00, $89, $48, $80, $00, $8A, $28, $00, $00, $F2, $28, $00
	.db $00, $83, $E8, $00, $00, $82, $28, $80, $00, $82, $27, $00

; Data from 2E97 to 2ECE (56 bytes)
DATA_2E97:
	.db $8B, $20, $31, $39, $38, $32, $20, $4E, $41, $4D, $43, $4F, $20, $4C, $54, $44
	.db $2E, $00, $31, $20, $50, $4C, $41, $59, $45, $52, $20, $20, $20, $22, $31, $22
	.db $20, $4B, $45, $59, $00, $32, $20, $50, $4C, $41, $59, $45, $52, $53, $20, $20
	.db $22, $32, $22, $20, $4B, $45, $59, $00

LABEL_2ECF:
	call LABEL_2CF6
	xor a
	ld hl, $C38E
	ld (hl), a
	inc l
	ld (hl), a
	inc l
	ld (hl), a
	ld hl, $C3CE
	ld (hl), a
	inc l
	ld (hl), a
	inc l
	ld (hl), a
	ld ($C399), a
	inc a
	ld ($C334), a
	ld ($C33B), a
	ld ($C600), a
	ld a, ($C33E)
	ld ($C39A), a
	ld a, $03
	ld ($C391), a
	call LABEL_3EE1
	call LABEL_3071
	ld hl, $C380
	ld de, $C3C0
	ld bc, $0040
	ldir
	call LABEL_300E
	call LABEL_3039
	ld hl, $00B4
	call LABEL_2D93
	call LABEL_2DA4
LABEL_2F1B:
	call LABEL_3027
	call LABEL_304B
	ld hl, $C391
	dec (hl)
	call LABEL_30B7
LABEL_2F28:
	ld hl, LABEL_355E
	ld ($C450), hl
	ld hl, LABEL_341B
	ld ($C408), hl
	xor a
	ld ($C345), a
	call LABEL_2D88
	ld a, ($C392)
	and a
	jr nz, LABEL_2F7A
	call LABEL_3833
	inc a
	ld ($C601), a
	call LABEL_2CF6
	ld hl, ($CF80)
	ld ($CF00), hl
	ld hl, ($CF82)
	ld ($CF02), hl
	ld hl, $0078
	call LABEL_2D93
	call LABEL_3F58
	call LABEL_2DA4
	call.lil ClearTileFlags
	ld hl, $00F0
	ld ($CF00), hl
	call LABEL_3EF2
	call LABEL_3071
	ld hl, $003C
	call LABEL_2D93
	call LABEL_2DA4
	jr LABEL_2F28

LABEL_2F7A:
	ld a, ($C345)
	and a
	ret z
	ld a, ($C333)
	and a
	jr nz, LABEL_2F9E
	ld a, ($C391)
	and a
	jr nz, LABEL_2FAD
	inc a
	ld ($C602), a
	call LABEL_305D
	ld hl, $00F0
	call LABEL_2D93
	call LABEL_2DA4
	jp LABEL_2E0B

LABEL_2F9E:
	ld a, ($C391)
	and a
	jr z, LABEL_2FC2
	ld a, ($C3D1)
	and a
	jr z, LABEL_2FAD
LABEL_2FAA:
	call LABEL_2FF8
LABEL_2FAD:
	call LABEL_3080
	call LABEL_300E
	call LABEL_3039
	ld hl, $003C
	call LABEL_2D93
	call LABEL_2DA4
	jp LABEL_2F1B

LABEL_2FC2:
	call LABEL_300E
	call LABEL_305D
	ld a, $01
	ld ($C602), a
	ld hl, $00B4
	call LABEL_2D93
	call LABEL_2DA4
	call LABEL_3027
	call LABEL_304B
	ld a, ($C3D1)
	and a
	jr nz, LABEL_2FAA
	call LABEL_305D
	ld hl, $003C
	call LABEL_2D93
	call LABEL_2DA4
	ld a, ($C332)
	and a
	call nz, LABEL_2FF8	
	jp LABEL_2E0B

LABEL_2FF8:
	ld a, ($C332)
	xor $01
	ld ($C332), a
	ld hl, $C380
	ld de, $C3C0
	ld b, $40
_:	ld c, (hl)
	ld a, (de)
	ld (hl), a
	ld a, c
	ld (de), a
	inc hl
	inc de
	djnz -_
LABEL_300E:
	ld hl, $0169
	ld de, DATA_301F
	call LABEL_3ECC
	ld a, ($C332)
	add a, $31
	jp LABEL_3E48

; Data from 301F to 3026 (8 bytes)
DATA_301F:
	.db $50, $4C, $41, $59, $45, $52, $20, $00

LABEL_3027:
	ld hl, $0169
	ld de, DATA_3030
	jp LABEL_3ECC

; Data from 3030 to 3038 (9 bytes)
DATA_3030:
	.db $D5, $D8, $D8, $D8, $D8, $D8, $D8, $D4, $00

LABEL_3039:
	ld hl, $0189
	ld de, DATA_3042
	jp LABEL_3ECC

; Data from 3042 to 304A (9 bytes)
DATA_3042:
	.db $20, $52, $45, $41, $44, $59, $21, $20, $00

LABEL_304B:
	ld hl, $0189
	ld de, DATA_3054
	jp LABEL_3ECC

; Data from 3054 to 305C (9 bytes)
DATA_3054:
	.db $D7, $DA, $DA, $D6, $D7, $DA, $DA, $D6, $00

LABEL_305D:
	ld hl, $0188
	ld de, DATA_3066
	jp LABEL_3ECC	

; Data from 3066 to 3070 (11 bytes)
DATA_3066:
	.db $47, $41, $4D, $45, $20, $20, $4F, $56, $45, $52, $00

LABEL_3071:
	ld hl, $C380
	ld bc, $0EFF
LABEL_3077:
	ld (hl), c
	inc l
	djnz LABEL_3077
	ld a, $23
	ld ($C392), a
LABEL_3080:
	ld hl, $0000
LABEL_3083:
	call LABEL_3E46
	ld a, h
	cp $03
	jr nz, LABEL_3083
	call LABEL_3114
	call LABEL_31FE
	call LABEL_32C1
	call LABEL_3346
	ld de, DATA_30F7
	ld hl, $0019
	call LABEL_3ECC
	ld hl, $003A
	call LABEL_3ECC
	ld hl, $02B9
	call LABEL_3ECC
	ld a, $01
	ld ($C338), a
	call LABEL_3DAD
	call LABEL_3108
LABEL_30B7:
	ld b, $06
LABEL_30B9:
	call LABEL_30BF
	djnz LABEL_30B9
	ret

LABEL_30BF:
	ld hl, $01F7
	ld de, $0040
	ld a, b
	dec a
LABEL_30C7:
	add hl, de
	sub $03
	jr nc, LABEL_30C7
LABEL_30CC:
	inc l
	inc l
	inc a
	jr nz, LABEL_30CC
	ld a, ($C391)
	cp b
	jr nc, LABEL_30E6
LABEL_30D7:
	ld a, $20
	call LABEL_30E0
	ld de, $001E
	add hl, de
LABEL_30E0:
	call LABEL_3E48
	jp LABEL_3E48

LABEL_30E6:
	ld a, $AC
LABEL_30E8:
	call LABEL_30EF
	ld de, $001E
	add hl, de
LABEL_30EF:
	call LABEL_30F2
LABEL_30F2:
	call LABEL_3E48
	inc a
	ret

; Data from 30F7 to 3107 (17 bytes)
DATA_30F7:
	.db $48, $49, $47, $48, $00, $53, $43, $4F, $52, $45, $00, $52, $4F, $55, $4E, $44
	.db $00

LABEL_3108:
	ld hl, $02DD
	ld de, $C398
	ld bc, $0100
	jp LABEL_3E1E

LABEL_3114:
	ld de, DATA_3158
	ld hl, $0001
LABEL_311A:
	ld a, (de)
	rlca
	rlca
	rlca
	and $07
	inc a
	ld b, a
	ld a, (de)
	and $1F
	inc a
	cp $1F
	ret z
	jr nc, LABEL_3153
	add a, $CF
	ld c, a
LABEL_312E:
	ld a, c
	call LABEL_3E48
	push hl
	ld a, l
	xor $1F
	sub $05
	ld l, a
	ld a, c
	xor $01
	call LABEL_3E48
	pop hl
	djnz LABEL_312E
LABEL_3142:
	ld a, l
	and $1F
	cp $0D
	jr nz, LABEL_3150
	ld a, $14
	add a, l
	ld l, a
	jr nc, LABEL_3150
	inc h
LABEL_3150:
	inc de
	jr LABEL_311A

LABEL_3153:
	ld a, b
	add a, l
	ld l, a
	jr LABEL_3142

; Data from 3158 to 31FD (166 bytes)
DATA_3158:
	.db $07, $EA, $4A, $0D, $00, $E8, $28, $0D, $0C, $07, $3F, $06, $07, $6A, $1F, $0D
	.db $0C, $0D, $3F, $0C, $BF, $0D, $0C, $0D, $3F, $0C, $BF, $0D, $0C, $05, $3F, $04
	.db $05, $88, $0D, $0C, $07, $3F, $2A, $06, $07, $2A, $14, $0D, $0C, $0D, $7F, $0C
	.db $0D, $5F, $0D, $0C, $0D, $7F, $0C, $0D, $3F, $16, $0D, $0C, $05, $08, $01, $3F
	.db $0C, $0D, $5F, $03, $02, $0B, $06, $0D, $3F, $0C, $0D, $5F, $FF, $05, $48, $FF
	.db $07, $2A, $06, $01, $00, $08, $04, $05, $28, $04, $0D, $3F, $0C, $0D, $0C, $07
	.db $3F, $06, $07, $0A, $03, $2A, $0C, $0D, $0C, $0D, $3F, $0C, $BF, $0D, $0C, $0D
	.db $3F, $0C, $BF, $0D, $0C, $0D, $3F, $0C, $0D, $3F, $00, $08, $04, $0D, $0C, $0D
	.db $3F, $0C, $0D, $3F, $0C, $07, $1F, $0D, $0C, $05, $3F, $04, $05, $3F, $04, $0D
	.db $1F, $0D, $0C, $07, $2A, $06, $07, $4A, $03, $1F, $0D, $0C, $FF, $3F, $0D, $0C
	.db $FF, $3F, $05, $E8, $48, $1E

LABEL_31FE:
	ld b, $21
LABEL_3200:
	call LABEL_3208
	dec b
	jp p, LABEL_3200
	ret

LABEL_3208:
	call LABEL_324F
	and (hl)
	jr z, LABEL_3228
	call LABEL_3266
	add a, $E0
	bit 0, a
	jp z, LABEL_30E0
LABEL_3218:
	call LABEL_3E48
	ld de, $001F
	add hl, de
	jp LABEL_3E48

LABEL_3222:
	call LABEL_324F
	cpl
	and (hl)
	ld (hl), a
LABEL_3228:
	call LABEL_3266
	bit 0, a
	ld a, $20
	jp z, LABEL_30E0
	jr LABEL_3218

LABEL_3233:	
	call LABEL_324F	
	cpl
	and (hl)
	ld (hl), a
	call LABEL_3266	
	add a, a
	add a, $C8
	bit 1, a
	jp z, LABEL_30EF	
	call LABEL_30F2	
	ld de, $001F
	add hl, de
	jp LABEL_30F2	

LABEL_324F:
	ld hl, $C380
LABEL_3252:
	ld a, b
	and $F8
	rrca
	rrca
	rrca
	add a, l
	ld l, a
	ld a, b
	and $07
	ld c, a
	ld a, $01
	ret z
LABEL_3261:
	add a, a
	dec c
	jr nz, LABEL_3261
	ret

LABEL_3266:
	ld hl, DATA_327D
LABEL_3269:
	ld a, b
	add a, a
	add a, l
	ld l, a
	jr nc, LABEL_3270
	inc h
LABEL_3270:
	ld e, (hl)
	inc hl
	ld a, (hl)
	and $03
	ld d, a
	ld a, (hl)
	srl a
	srl a
	ex de, hl
	ret

; Data from 327D to 32C0 (68 bytes)
DATA_327D:
	.db $44, $08, $4C, $08, $54, $08, $A4, $00, $67, $0C, $72, $04, $B4, $00, $C4, $08
	.db $D4, $08, $61, $0D, $64, $05, $65, $0D, $68, $05, $71, $0D, $74, $05, $75, $0D
	.db $78, $05, $C4, $09, $E7, $0D, $EC, $05, $ED, $0D, $F2, $05, $D4, $09, $64, $02
	.db $68, $02, $4C, $0A, $70, $02, $74, $02, $A3, $0E, $A6, $06, $A7, $0E, $B2, $06
	.db $B3, $0E, $B6, $06

LABEL_32C1:
	ld b, $0D
LABEL_32C3:
	call LABEL_32CB
	dec b
	jp p, LABEL_32C3
	ret

LABEL_32CB:
	call LABEL_32F7
	and (hl)
	jr z, LABEL_32F0
	call LABEL_32FD
	ld c, $20
LABEL_32D6:
	call LABEL_32E0
	ld a, $1E
	add a, l
	ld l, a
	jr nc, LABEL_32E0
	inc h
LABEL_32E0:
	call LABEL_32E3
LABEL_32E3:
	ld a, (de)
	add a, c
	call LABEL_3E48
	inc de
	ret

LABEL_32EA:
	call LABEL_32F7
	cpl
	and (hl)
	ld (hl), a
LABEL_32F0:
	call LABEL_32FD
	ld c, $00
	jr LABEL_32D6

LABEL_32F7:
	ld hl, $C386
	jp LABEL_3252

LABEL_32FD:
	ld hl, DATA_3326
	call LABEL_3269
	add a, a
	add a, a
	ld de, DATA_330E
	add a, e
	ld e, a
	jr nc, LABEL_330D
	inc d
LABEL_330D:
	ret

; Data from 330E to 3325 (24 bytes)
DATA_330E:
	.db $D0, $D9, $DE, $D7, $D8, $D1, $D6, $DF, $D4, $D5, $DA, $DB, $DC, $D5, $D2, $DB
	.db $D4, $DD, $DA, $D3, $DC, $D5, $DE, $D7, $D4, $DD, $D6, $DF

; Data from 3326 to 3345 (32 bytes)
DATA_3326:
	.db $22, $00, $36, $04, $A6, $08, $B2, $08, $22, $0D, $36, $11
	.db $A2, $01, $A8, $11, $B0, $0D, $B6, $05, $62, $16, $6A, $12, $6E, $0E, $76, $1A

LABEL_3346:
	ld b, $1C
LABEL_3348:
	call LABEL_3350
	dec b
	jp p, LABEL_3348
	ret

LABEL_3350:
	call LABEL_3374
	and (hl)
	jr z, LABEL_336E
	call LABEL_337A
	ld a, ($C394)
LABEL_3356:
	ld de, DATA_33BA
	add a, e
	ld e, a
	jr nc, LABEL_3364
	inc d
LABEL_3364:
	ld a, (de)
	jp LABEL_30E8

LABEL_3367:	
	call LABEL_3374	
	cpl
	and (hl)
	ld (hl), a
LABEL_336E:
	call LABEL_337A
	jp LABEL_30D7

LABEL_3374:
	ld hl, $C388
	jp LABEL_3252

LABEL_337A:
	ld hl, DATA_3380
	jp LABEL_3269

; Data from 3380 to 33B9 (58 bytes)
DATA_3380:
	.db $68, $00, $6A, $00, $6C, $00, $6E, $00, $70, $00, $E4, $00, $E6, $00, $F2, $00
	.db $F4, $00, $26, $01, $32, $01, $62, $01, $66, $01, $72, $01, $76, $01, $E4, $01
	.db $EA, $01, $EE, $01, $F4, $01, $24, $02, $28, $02, $30, $02, $34, $02, $6C, $02
	.db $A8, $02, $AA, $02, $AC, $02, $AE, $02, $B0, $02

; Data from 33BA to 33C1 (8 bytes)
DATA_33BA:
	.db $90, $A8, $A0, $9C, $94, $A4, $98, $8C

LABEL_33C2:
	call LABEL_33CE
	cpl
	and (hl)
	ld (hl), a
LABEL_33C8:
	call LABEL_33D4
	jp LABEL_30D7

LABEL_33CE:
	ld hl, $C38D
	jp LABEL_3252

LABEL_33D4:
	ld hl, DATA_340F
	jp LABEL_3269

LABEL_33DA:
	ld a, ($C33B)
	and a
	ret m
	ld a, ($C331)
	and $07
	sub $02
	ret c
	ld b, a
	call LABEL_33CE
	and (hl)
	jp z, LABEL_33C8
	call LABEL_33D4
	ld a, ($C33B)
	dec a
	jr nz, LABEL_33FB
	ld a, ($C331)
LABEL_33FB:
	and $18
	rrca
	add a, $B0
	ld c, a
	ld a, b
	cp $02
	ld a, c
	jp c, LABEL_30E8
	add a, $10
	and $F7
	jp LABEL_30E8

; Pointer Table from 340F to 3412 (2 entries, indexed by $C331)
DATA_340F:
	.dw $01E8, $01F0

; Data from 3413 to 341A (8 bytes)
	.db $64, $00, $74, $00, $A4, $02, $B4, $02

LABEL_341B:
	ld hl, LABEL_39A5
	ld ($C460), hl
	ld hl, LABEL_39A8
	ld ($C470), hl
	ld hl, LABEL_39AC
	ld ($C480), hl
	ld hl, LABEL_39B0
	ld ($C490), hl
	call LABEL_2DBC

; Data from 3436 to 3463 (46 bytes)
	.db $00, $00
	.dw LABEL_347C 
	.db $A4, $01
	.dw LABEL_3471
	.db $C2, $01
	.dw LABEL_3465
	.db $DC, $05
	.dw LABEL_346A
	.db $FA, $05
	.dw LABEL_348A
	.db $08, $07
	.dw LABEL_3476
	.db $26, $07
	.dw LABEL_3465
	.db $B8, $0B
	.dw LABEL_3476
	.db $D6, $0B
	.dw LABEL_348A
	.db $E4, $0C
	.dw LABEL_3476
	.db $02, $0D
	.dw LABEL_3465
	.db $FF, $FF

LABEL_3464:
	ret

LABEL_3465:
	xor a
	ld ($C339), a
	ret

LABEL_346A:
	ld a, $01
	ld ($C496), a
	jr LABEL_3476

LABEL_3471:
	ld a, $01
	ld ($C486), a
LABEL_3476:
	ld a, $01
	ld ($C339), a
	ret

LABEL_347C:
	xor a
	ld ($C496), a
	ld ($C486), a
	inc a
	ld ($C476), a
	ld ($C466), a
LABEL_348A:
	ld a, $02
	ld ($C339), a
	ret

LABEL_3490:
	ld hl, ($C3A0)
	call LABEL_2D93
	ld l, (ix+2)
	ld h, (ix+3)
	ld bc, $003C
	and a
	sbc hl, bc
	ld a, $02
	jr nc, LABEL_34A7
	dec a
LABEL_34A7:
	ld ($C456), a
	call LABEL_2DA4
	xor a
	ld ($C456), a
	call LABEL_2D88
	ret

LABEL_34B5:
	call LABEL_3509
	ld a, ($C340)
	ld ($C60B), a
	ld hl, $0078
	call LABEL_2D93
	call LABEL_352E
	call LABEL_3526
	call LABEL_34F4
	call LABEL_2DA4
	ld hl, $01E0
	call LABEL_2D93
	call LABEL_3526
	call LABEL_34F4
	call LABEL_2DA4
	xor a
	ld ($C60B), a
	call LABEL_34F0
	call LABEL_3544	
	call LABEL_3540	
	call LABEL_2D88
	ret

LABEL_34F0:
	ld a, $DC
	jr LABEL_3503

LABEL_34F4:
	ld a, ($C331)
	and $07
	dec a
	ret nz
	ld a, ($C331)
	and $08
	rrca
	add a, $E8
LABEL_3503:
	ld hl, $01AC
	jp LABEL_30E8

LABEL_3509:
	call LABEL_20AE
	and $07
	ld ($C372), a
	call LABEL_20AE
	and $07
	ld ($C376), a
	ld hl, $1010
	ld ($C370), hl
	ld hl, $1515
	ld ($C374), hl
	ret

LABEL_3526:
	ld hl, $C374
	ld de, $01AE
	jr LABEL_3534

LABEL_352E:
	ld hl, $C370
	ld de, $01AA
LABEL_3534:
	ld a, (hl)
	inc l
	dec (hl)
	ret nz
	ld (hl), a
	inc l
	ld a, (hl)
	inc a
	and $07
	ld (hl), a
	ex de, hl
	jp LABEL_3356

LABEL_3540:
	ld hl, $01AE
	jr LABEL_3548
LABEL_3544:
	ld hl, $01AA
LABEL_3548:
	call LABEL_3E46
	call LABEL_3E48
	ld de, $001E
	add hl, de
	ld a, $DA
	call LABEL_3E48
	jp LABEL_3E48

LABEL_355E:	
	call LABEL_35C2
	call LABEL_2D88
	call LABEL_35D7
	call LABEL_3619
	ld hl, LABEL_36A7
LABEL_356D:
	ld ($C37C), hl
	ld hl, ($C44A)
	ld a, ($C44C)
	add a, l
	ld ($C44C), a
	ld a, ($C44D)
	adc a, h
	ret z
	ld ($C44D), a
LABEL_3582:
	call LABEL_358F
	call LABEL_3593
	ld hl, $C44D
	dec (hl)
	jr nz, LABEL_3582
	ret

LABEL_358F:
	ld hl, ($C37C)
	jp (hl)

LABEL_3593:
	ld a, ($C449)
	and a
	ret m
	jr z, LABEL_35A4
	cp $02
	jr c, LABEL_35B1
	jr z, LABEL_35B5
	inc (iy+0)
	ret

LABEL_35A4:
	ld a, (iy+1)
	inc a
	cp $C0
	jr c, LABEL_35AD
	xor a
LABEL_35AD:
	ld (iy+1), a
	ret

LABEL_35B1:
	dec (iy+0)
	ret

LABEL_35B5:
	ld a, (iy+1)
	sub $01
	jr nc, LABEL_35BE
	ld a, $BF
LABEL_35BE:
	ld (iy+1), a
	ret

LABEL_35C2:
	ld hl, $6058
	ld ($CF00), hl
	xor a
	ld ($C446), a
	ld l, a
	ld h, a
	ld ($C44C), hl
	ld hl, $0202
	ld ($C448), hl
LABEL_35D7:
	ld a, ($C446)
	dec a
	ld a, $0A
	jr nz, LABEL_35E8
	ld hl, ($C331)
	bit 3, (hl)
	jr z, LABEL_35E8
	ld a, $0F
LABEL_35E8:
	ld ($CF03), a
	ld a, ($C331)
	and $07
	ld hl, DATA_3611
	add a, l
	ld l, a
	jr nc, LABEL_35F8
	inc h
LABEL_35F8:
	ld a, ($C446)
	and a
	ld a, (hl)
	jr z, LABEL_3600
	inc a
LABEL_3600:
	cp $10
	jr nc, LABEL_360B
	add a, a
	add a, a
	ld c, a
	ld a, ($C449)
	add a, c
LABEL_360B:
	add a, a
	add a, a
	ld ($CF02), a
	ret

; Data from 3611 to 3618 (8 bytes)
DATA_3611:
	.db $02, $02, $00, $00, $00, $02, $10, $10

LABEL_3619:
	ld a, ($C446)
	and a
	jr z, LABEL_362F
	ld a, ($C33C)
	and a
	ld hl, $0180
	jr z, LABEL_362B
	ld hl, $0200
LABEL_362B:
	ld ($C44A), hl
	ret

LABEL_362F:
	ld hl, $C39E
	ld a, ($C392)
	cp l
	jr nc, LABEL_3649
	cp h
	jr nc, LABEL_3642
	ld hl, ($C3AA)
	ld ($C44A), hl
	ret

LABEL_3642:
	ld hl, ($C3A8)
	ld ($C44A), hl
	ret

LABEL_3649:
	ld hl, ($C3A4)
	ld ($C44A), hl
	ret

LABEL_3654:
	call LABEL_368B	
	ld a, ($C340)
	ld ($C603), a
	ld hl, $0078
	call LABEL_2D93
	ld a, ($C442)
	and $F8
	rrca
	rrca
	rrca
	ld hl, DATA_369D
	add a, l
	ld l, a
	jr nc, LABEL_3673
	inc h
LABEL_3673:
	ld l, (hl)
	ld h, $0A
	ld ($CF02), hl
	call LABEL_2DA4
	ld hl, $00F0
	ld ($CF00), hl
	ld a, $01
	ld ($C345), a
	call LABEL_2D88
	ret

LABEL_368B:
	xor a
	ld ($C60B), a
	xor a
	ld ($C60C), a
	ld ($C60D), a
	ld ($C60E), a
	ld ($C60F), a
	ret

; Data from 369D to 36A6 (10 bytes)
DATA_369D:
	.db $DC, $DC, $DC, $DC, $DC, $DC, $DC, $D8, $D4, $D0

	call z, $04C8
	inc h
	.db $40
LABEL_36A7:
	call LABEL_3912	
	ld hl, ($C448)
	ld a, l
	xor $02
	cp h
	jr z, LABEL_36F3
	ld a, (iy+1)
	and $0F
	ret nz
	ld a, (iy+0)
	sub $08
	and $0F
	ret nz
	xor a
	ld ($C30B), a
	ld a, ($C448 - 2)
	and a
	jr z, LABEL_36D6
	ld hl, $0000
	ld ($C308), hl
LABEL_36D6:
	call LABEL_3715
	ld a, $3C
	ld ($C30B), a
	ld hl, LABEL_3AC5
	ld ($C308), hl
	call LABEL_37AD
	ld hl, ($C448)
	ld a, l
	cp h
	jr z, LABEL_36FA
	call LABEL_370C	
	jr c, LABEL_36F5
LABEL_36F3:
	ld a, ($C448)
	ld ($C449), a
	ret

LABEL_36F5:
	ld a, ($C449)
	and a
	ret m

LABEL_36FA:
	call LABEL_370C	
	ret nc
LABEL_36FF:
	ld a, ($C449)
	or $80
	ld ($C449), a
	ret

; Data from 370C to 370F (4 bytes)
LABEL_3708:
LABEL_370C:
	ld b, a
	inc b
	ld a, ($C379)
LABEL_3710:	
	rrca
	djnz LABEL_3710
	ret

LABEL_3715:
	ld hl, $0F08
	call LABEL_3769
	ld hl, $1008
	call LABEL_375E
	ld hl, $0700
	call LABEL_3769
	ld hl, $07FF
	call LABEL_375E
	ld hl, $0008
	call LABEL_3769
	ld hl, $FF08
	call LABEL_375E
	ld hl, $070F
	call LABEL_3769
	ld hl, $0710
	call LABEL_375E
	ld a, (iy+0)
	cp $58
	jr z, LABEL_374F
	cp $78
	ret nz
LABEL_374F:
	ld a, (iy+1)
	cp $50
	jr z, LABEL_3759
	cp $70
	ret nz
LABEL_3759:
	ld a, ($C379)
	or $0A
	ld ($C379), a
	ret

; Data from 3762 to 3768 (7 bytes)
LABEL_375E:
	call nc, LABEL_3769	
	ld a, ($C379)
	rla
	ld ($C379), a
	ret

LABEL_3769:
	call LABEL_377F
	add a, $30
	ret nc
	and $1F
	rra
	ld l, a
	ld h, $C3
	ld a, (hl)
	jr c, LABEL_3780
LABEL_377B:	
	rlca
	djnz LABEL_377B
	ret

LABEL_3780:
	rrca
	djnz LABEL_3780
	ret

LABEL_377F:
	ld b, $00
	ld a, (iy+1)
	add a, l
	cp $08
	jr nc, LABEL_378F
	add a, $C0
LABEL_378F:	
	ld l, a
	ld a, (iy+0)
	add a, h
	rra
	rra
	rra
	rl b
	rra
	rr l
	rra
	rr l
	rra
	rr l
	rl b
	inc b
	and $03
LABEL_37A8:
	add a, $CC
	ld h, a
	ld a, (hl)
	ret

LABEL_37AD:
	ld hl, $0000
	call LABEL_377F
	cp $F0
	jp nc, LABEL_37CB
	cp $E8
	jp nc, LABEL_37E3
	cp $C8
	ret nc
	cp $B0
	jp nc, LABEL_385D
	cp $8C
	jp nc, LABEL_38CC
	ret

LABEL_37CB:
	ld de, DATA_3326
	call LABEL_394D
	call LABEL_32EA
	call LABEL_395F
	ld a, ($C340)
	ld ($C608), a
	ld de, $0050
	jp LABEL_3D81

LABEL_37E3:
	call LABEL_3833
	call LABEL_34F0
	ld hl, LABEL_2D92
	ld ($C418), hl
	call LABEL_2CF6
	ld hl, $CF80
	ld de, $CF00
	ld bc, $0080
	ldir
	ld a, ($C396)
	and $FC
	add a, $B0
	ld l, a
	ld c, $3C
	ld a, ($C372)
	ld b, a
	ld a, ($C376)
	cp b
	jr nz, LABEL_3823
	ld a, ($C340)
	ld ($C60A), a
	ld c, $78
	ld l, $C0
	ld a, ($C394)
	cp b
	jr nz, LABEL_3823
	ld l, $C4
LABEL_3823:
	ld h, $0F
	ld ($CF02), hl
	ld a, l
	sub $B0
	rrca
	rrca
	call LABEL_3D7A
	ld l, c
	ld h, $00
LABEL_3845:
	call LABEL_2D93
	call LABEL_2DA4
	call LABEL_3544
	call LABEL_3540
	ld hl, $C500
	ld de, $C400
	ld bc, $0100
	ldir
	ret

LABEL_3833:
	xor a
	ld ($C60B), a
	xor a
	ld ($C60C), a
	ld ($C60D), a
	ld ($C60E), a
	ld ($C60F), a
	ret

LABEL_385D:
	ld de, DATA_340F
	call LABEL_394D
	call LABEL_33C2
	call LABEL_3878
	ld a, ($C340)
	ld ($C606), a
	ld de, $0100
	call LABEL_3D81
	jp LABEL_38ED

LABEL_3878:
	ld a, b
	cp $02
	jr nc, LABEL_3889
	ld a, $02
	ld ($C446), a
	ld hl, LABEL_3490
	ld ($C410), hl
	ret

LABEL_3889:
	xor a
	ld ($C33A), a
	ld hl, $C469
	ld de, $0010
	ld b, $04
LABEL_3895:
	ld a, (hl)
	xor $02
	ld (hl), a
	add hl, de
	djnz LABEL_3895
	ld hl, LABEL_3A57
	call LABEL_38BB
	ld hl, ($C3A2)
	ld de, ($C412)
	and a
	sbc hl, de
	add hl, de
	jr c, LABEL_38B2
	ld ($C412), hl
LABEL_38B2:
	ld ($C462), hl
	ld ($C472), hl
	ld ($C482), hl
	ld ($C492), hl
	ret

; Data from 38BF to 38CB (13 bytes)
LABEL_38BB:
	.db $22, $60, $C4, $22, $70, $C4, $22, $80, $C4, $22, $90, $C4, $C9

LABEL_38CC:
	ld de, DATA_3380
	call LABEL_394D
	call LABEL_3367
	ld a, ($C340)
	ld ($C609), a
	ld a, ($C397)
	add a, a
	ld hl, DATA_38FE
	add a, l
	ld l, a
	jr nc, LABEL_38E7
	inc h
LABEL_38E7:
	ld e, (hl)
	inc hl
	ld d, (hl)
	call LABEL_3D81
LABEL_38ED:
	ld a, ($C392)
	dec a
	ld ($C392), a
	cp $14
	ret nz
	ld hl, LABEL_34B5
	ld ($C418), hl
	ret

; Data from 38FE to 394C (79 bytes)
DATA_38FE:
	.db $10, $00, $10, $00, $20, $00, $30, $00, $40, $00, $50, $00, $60, $00, $70, $00
	.db $80, $00, $00, $01

LABEL_3912:	
	ld a, (iy+1)
LABEL_3915:	
	and $07
	ret nz
	ld a, (iy+0)
	and $07
	ret nz
	ld hl, $0000
	call LABEL_377F
	and $FE
	cp $E2
	jr z, LABEL_3938
	inc hl
	ld a, (hl)
	cp $E1
	jr z, LABEL_3938
	ld de, $001F
	add hl, de
	ld a, (hl)
	cp $E0
	ret nz
LABEL_3938:	
	ld de, DATA_327D
	call LABEL_394D
	call LABEL_3233
	ld a, ($C340)
	ld ($C607), a
	ld de, $0200
	jp LABEL_3D81

LABEL_394D:
	ld b, $00
LABEL_394F:
	ld a, (de)
	cp l
	jr nz, LABEL_395A
	inc de
	ld a, (de)
	dec de
	xor h
	and $03
	ret z
LABEL_395A:
	inc de
	inc de
	inc b
	jr LABEL_394F

LABEL_395F:
	ld a, b
	add a, a
	add a, b
	ld hl, DATA_3961
	add a, l
	ld l, a
	jr nc, LABEL_396A
	inc h
LABEL_396A:
	ld b, $03
LABEL_396C:
	ld a, (hl)
	inc hl
	and a
	ret m
	push hl
	push bc
	ld b, a
	call LABEL_3222
	pop bc
	pop hl
	djnz LABEL_396C
	ret

; Data from 397B to 399D (35 bytes)
DATA_3961:
	.db $00, $03, $80, $02, $06, $80, $01, $04, $80, $05, $19, $80, $07, $0B, $0A, $08
	.db $0E, $0F, $11, $17, $80, $0C, $12, $13, $0D, $14, $15, $16, $1B, $80, $1C, $1D
	.db $80, $09, $18

	ld e, $10
	ld a, (de)
	rra
	ld hl, $8020

LABEL_39A5:
	xor a
	jr LABEL_39B4

LABEL_39A8:
	ld a, $01
	jr LABEL_39B4

LABEL_39AC:
	ld a, $02
	jr LABEL_39B4

LABEL_39B0:
	ld a, $03
LABEL_39B4:
	call LABEL_39E0	; init sprite
	call LABEL_2D88
LABEL_399E:
	call LABEL_3A02
	call LABEL_3AA2
	xor a
	ld ($C60D), a
	ld ($C60E), a
	ld ($C60F), a
	ld de, $C60F
	ld hl, ($C39E)
	ld a, ($C392)
	cp l
	jr nc, LABEL_39DB
	dec de
	cp h
	jr nc, LABEL_39DB
	dec de
LABEL_39DB:
	ld a, ($C340)
	ld (de), a
	ret

LABEL_39E0:
	ld hl, $C447
	ld (hl), a
	add a, a
	add a, (hl)
	ld hl, DATA_3A31
	add a, l
	ld l, a
	jr nc, LABEL_39EE
	inc h
LABEL_39EE:
	ld a, (hl)
	inc hl
	ld ($C449), a
	ld a, (hl)
	inc hl
	ld (iy+1), a
	ld a, (hl)
	ld (iy+0), a
	ld hl, $0000
	ld ($C44C), hl
LABEL_3A02:
	ld a, ($C339)
	dec a
	jr z, LABEL_3A38
	ld a, ($C449)
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, ($C331)
	and $04
	add a, c
LABEL_3A15:
	add a, $50
	ld c, a
	ld a, ($C456)	; Is Pac-Man Super?
	and a
	ld a, c
	jr z, LABEL_3A21
	add a, $20
LABEL_3A21:
	ld (iy+2), a
	ld a, ($C447)
	ld hl, DATA_3A18
	add a, l
	ld l, a
	jr nc, LABEL_3A2F
	inc h
LABEL_3A2F:
	ld a, (hl)
	ld (iy+3), a
	ret

; Data from 3A34 to 3A37 (4 bytes)
DATA_3A18:
	.db $06, $0D, $07, $09


LABEL_3A38:
	ld a, ($C331)
	and $01
	ld c, a
	add a, a
	add a, a
	add a, c
	ld c, a
	ld a, ($C449)
	and $01
	add a, a
	add a, c
	add a, a
	add a, a
	jr LABEL_3A15

; Data from 3A4D to 3A9D (81 bytes)
DATA_3A31:
	.db $00, $5C, $28, $00, $53, $38, $02, $6A, $38, $02, $61, $48

LABEL_3A57:	
	ld a, ($C340)
	ld ($C60C), a
	ld hl, ($C442)
	ld de, $003C
	xor a
	and a
	sbc hl, de
	jr nc, LABEL_3A6A
	inc a
LABEL_3A6A:	
	ld ($C446), a
	call LABEL_3A81	
	call LABEL_3AC5
	call LABEL_2DA4	
	xor a
	ld ($C60C), a
	ld hl, LABEL_399E
	ld ($C440), hl
	jp (hl)
	
LABEL_3A81:	
	ld a, ($C446)
	and a
	jr z, LABEL_3A90
	ld a, ($C331)
	and $08
	ld a, $0F
	jr nz, LABEL_3A92
	
LABEL_3A90:	
	ld a, $04
	
LABEL_3A92:	
	ld (iy+3), a
	ld a, ($C331)
	and $04
	add a, $48
LABEL_3A9E:
	ld (iy+2), a
	ret

LABEL_3AA2:
	call LABEL_3CAA
	call LABEL_3C54
	ld a, ($C446)
	and a
	jr z, LABEL_3AD7
	ld a, ($C339)
	cp $01
	ret z
	ld hl, LABEL_3B8C
	jr c, LABEL_3ABC
	ld hl, LABEL_3B70
LABEL_3ABC:
	ld ($C37A), hl
	ld hl, LABEL_3AF0
	jp LABEL_356D

LABEL_3AC5:	
	ld hl, LABEL_3B67
	ld ($C37A), hl
	call LABEL_3CCB
	call LABEL_3C7F
	ld hl, LABEL_3AF0
	jp LABEL_356D

LABEL_3AD7:
	ld hl, LABEL_3B61
	ld ($C37A), hl
	ld hl, $0000
	ld hl, LABEL_3AF0
	call LABEL_356D
	ld hl, $3AC5
	ld ($C308), hl
	ret

LABEL_3AF0:
	ld a, (iy+1)
	and $0F
	ret nz
	ld a, (iy+0)
	sub $08
	and $0F
	ret nz
	call LABEL_3715
	call LABEL_3B2E
	call LABEL_3B59
	call LABEL_3C09
	ld a, ($C449)
	xor $02
	ld c, a
	ld b, $04
LABEL_3B12:
	ld a, ($C448)
	and $03
	cp c
	jr z, LABEL_3B23
	ld ($C449), a
	push bc
	call LABEL_3708
	pop bc
	ret nc
LABEL_3B23:
	ld a, ($C448)
	rrca
	rrca
	ld ($C448), a
	djnz LABEL_3B12
	ld a, c
	ld ($C449), a
	ret

LABEL_3B2E:
	ld a, ($C339)
	and a
	ret nz
	ld hl, $C379
	ld a, (iy+0)
	cp $58
	jr nz, LABEL_3B4A
	ld a, (iy+1)
	cp $60
	ret nz
	set 3, (hl)
	ret

LABEL_3B4A:
	cp $98
	ret nz
	ld a, (iy+1)
	cp $30
	jr nz, LABEL_3B57
	set 2, (hl)
	ret

LABEL_3B57:
	cp $90
	ret nz
	set 0, (hl)
	ret

LABEL_3B59:
	ld hl, ($C37A)
	jp (hl)

LABEL_3B61:
	ld hl, $4860
	ld c, $00
	ret

LABEL_3B67:
	ld hl, ($CF00)
	ld a, l
	ld l, h
	ld h, l
	ld c, $04
	ret

LABEL_3B70:
	ld c, $00
	ld a, ($C447)
	add a, a
	ld hl, DATA_3B84
	add a, l
	ld l, a
	jr nc, LABEL_3B7E
	inc h
LABEL_3B7E:
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jr LABEL_3BE9

; Data from 3B84 to 3B9E (27 bytes)
DATA_3B84:
	.db $08, $B0, $08, $10, $A8, $B0, $A8, $10

LABEL_3B8C:	
	ld c, $00
	ld hl, DATA_3B9F
	ld a, ($C447)
	add a, a
	add a, l
	ld l, a
	jr nc, LABEL_3B96
	inc h
LABEL_3B96:	
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

; Jump Table from 3B9F to 3BA6 (4 entries, indexed by $C447)
DATA_3B9F:
	.dw LABEL_3BE6, LABEL_3BA7, LABEL_3BC9, LABEL_3BDA

; 2nd entry of Jump Table from 3B9F (indexed by $C447)
LABEL_3BA7:
	ld a, ($C459)
	add a, a
	ld hl, DATA_3BA5
	add a, l
	ld l, a
	jr nc, LABEL_3BB3
	inc h
LABEL_3BB3:
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, ($CF00)
	ld a, l
	add a, e
	ld l, a
	ld a, h
	add a, d
	ld h, a
	jr LABEL_3BE9

; Data from 3BC1 to 3BC7 (7 bytes)
DATA_3BA5:
	.db $00, $20, $E0, $00, $00, $E0, $20, $00
; Jump Table from 3B9F (indexed by $C447)
LABEL_3BC9:
	ld hl, ($CF04)
	ld a, ($CF00)
	add a, a
	sub l
	ld l, a
	ld a, ($CF01)
	add a, a
	sub h
	ld h, a
	jr LABEL_3BE9

; 4th entry of Jump Table from 3B9F (indexed by $C447)
LABEL_3BDA:
	call LABEL_3D5D	
	cp $21
	jr nc, LABEL_3BE6
	call LABEL_20A4
	jr LABEL_3BE9

; 1st entry of Jump Table from 3B9F (indexed by $C447)
LABEL_3BE6:
	ld hl, ($CF00)
LABEL_3BE9:
	ld a, l
	ld l, h
	ld h, a
	call LABEL_3C00
	ld a, h
	cp $58
	ret nz
	ld a, l
	cp $28
	jr c, LABEL_3BFE
	cp $A0
	ret c
	ld l, $00
	ret

LABEL_3BFE:
	ld a, $C0
	ld l, a
	ret

LABEL_3C00:
	ld a, (iy+0)
	cp $38
	ret nz

	ld a, (iy+1)
	cp $60
	ret nz
	ld a, ($C449)
	rrca
	ret c
	ld hl, DATA_2860
	ret

LABEL_3C09:	
	ld a, h
	sub (iy+0)
	rr e
	jp p, LABEL_3C12	
	neg
LABEL_3C12:	
	ld d, a
	ld a, l
	sub (iy+1)
	rr e
	jp p, LABEL_3C13
	neg
LABEL_3C13:
	cp d
	ld a, $00
	rla
	rl e
	jr nc, LABEL_3C2A
	xor $03
LABEL_3C2A:	
	rl e
	jr nc, LABEL_3C30
	xor $07
LABEL_3C30:	
	xor c
	ld hl, DATA_3C3F
	add a, l
	ld l, a
	jr nc, LABEL_3C39
	inc h
LABEL_3C39:	
	ld a, (hl)
	ld ($C448), a
	ret

DATA_3C3F:
	.db $9C, $63, $4B, $1E, $36, $C9, $E1, $B4

LABEL_3C54:
	call LABEL_3C96
	jr nc, LABEL_3C8F
	ld a, ($C447)
	ld hl, $C39D
	cp (hl)
	jr nc, LABEL_3C7C
	ld hl, ($C39E)
	ld a, ($C392)
	cp l
	jr nc, LABEL_3C7C
	cp h
	jr nc, LABEL_3C75
	ld hl, ($C3AA)
	ld ($C44A), hl
	ret

LABEL_3C75:
	ld hl, ($C3A8)
	ld ($C44A), hl
	ret

LABEL_3C7C:
	ld hl, ($C3A6)
	ld ($C44A), hl
	ret

LABEL_3C7F:
	call LABEL_3C96
	jr nc, LABEL_3C8F
	ld hl, ($C3AE)
	ld ($C44A), hl
	ret

LABEL_3C8F:
	ld hl, ($C3AC)
	ld ($C44A), hl
	ret

LABEL_3C96:
	ld a, (iy+0)
	cp $58
	scf
	ret nz
	ld a, (iy+1)
	sub $11
	cp $3F
	ret c
	sub $60
	cp $3F
	ret

LABEL_3CAA:
	ld a, ($C456)
	and a
	ret nz
	call LABEL_3D5D
	cp $05
	ret nc
	call LABEL_2CF6	
	ld hl, ($C500)
	ld ($C400), hl
	ld hl, ($CF80)
	ld ($CF00), hl
	ld hl, LABEL_3654
	ld ($C450), hl
	ret

LABEL_3CCB:
	call LABEL_3D5D
	cp $09
	ret nc
	call LABEL_368B
	ld a, ($C340)
	ld ($C605), a
	call LABEL_2CF6	
	push iy
	pop de
	ld a, e
	add a, $80
	ld l, a
	ld h, d
	ld bc, $0004
	ldir
	ld a, ($C33A)
	add a, a
	add a, a
	add a, $B0
	ld (iy+2), a
	ld a, $0F
	ld (iy+3), a
	ld a, ($C33A)
	call LABEL_3D7A
	ld hl, $C33A
	inc (hl)
	ld hl, $003C
	call LABEL_2D93
	call LABEL_2DA4
	ld hl, $CF80
	ld de, $CF00
	ld bc, $0080
	ldir
	ld hl, $C500
	ld de, $C400
	ld bc, $0100
	ldir
	ld hl, $0300
	ld ($C44A), hl
	call LABEL_2D88
	ld a, ($C449)
	add a, a
	add a, a
	add a, $90
	ld c, a
	ld a, ($C456)
	and a
	ld a, c
	jr z, LABEL_3D3C
	add a, $10
LABEL_3D3C:
	ld (iy+2), a
	ld a, $04
	ld (iy+3), a
	call LABEL_3AD7
	ld a, (iy+0)
	cp $48
	ret nz
	ld a, (iy+1)
	sub $5C
	cp $09
	ret nc
	ld a, $01
	ld ($C446), a
	ld hl, LABEL_399E
	ld ($C440), hl
	ret

LABEL_3D5D:
	ld hl, ($CF00)
	ld a, (iy+0)
	sub l
	jr nc, LABEL_3D6C
	neg
LABEL_3D6C:
	ld l, a
	ld a, (iy+1)
	sub h
	jr nc, LABEL_3D75
	neg
LABEL_3D75:
	add a, l
	ret nc
	xor a
	dec a
	ret

LABEL_3D7A:
	ld hl, DATA_3D8B
	add a, l
	ld l, a
	jr nc, LABEL_3D82
	inc h
LABEL_3D82:
	ld d, (hl)
	ld e, $00
LABEL_3D81:
	ld a, ($C340)
	and a
	ret z
	ld ($C338), a
	ld a, ($C390)
	add a, e
	daa
	ld ($C390), a
	ld a, ($C38F)
	adc a, d
	daa
	ld ($C38F), a
	ld a, ($C38E)
	adc a, $00
	daa
	ld ($C38E), a
	ret

; Data from 3DA7 to 3DAC (6 bytes)
DATA_3D8B:
	.db $02, $04, $08, $16, $20, $50

LABEL_3DAD:
	ld a, ($C338)
	dec a
	ret nz
	ld ($C338), a
	call LABEL_3E6B
	ld de, $C335
	ld hl, $0059
	call LABEL_3E1B
	call LABEL_3DFD
	ld a, ($C399)
	ld hl, $C33D
	cp (hl)
	ret z
	ld a, ($C38E)
	ld hl, $C39A
	cp (hl)
	ret c
	ld a, ($C399)
	and a
	jr nz, LABEL_3DDB
	ld (hl), a
LABEL_3DDB:
	inc a
	cp $FF
	jr z, LABEL_3DE3
	ld ($C399), a
LABEL_3DE3:
	ld a, ($C33F)
	add a, (hl)
	daa
	ld (hl), a
	jr nc, LABEL_3DED
	ld (hl), $FF
LABEL_3DED:
	ld a, ($C391)
	inc a
	ret z
	ld ($C391), a
	ld a, $01
	ld ($C604), a
	jp LABEL_30B7

LABEL_3DFD:
	ld de, $C38E
	ld hl, $C3CE
	ld a, ($C332)
	and a
	jr z, LABEL_3E0A
	ex de, hl
LABEL_3E0A:
	push hl
	ld hl, $00B9
	call LABEL_3E1B
	pop de
	ld hl, $0119
	ld a, ($C333)
	and a
	jr z, LABEL_3E61
LABEL_3E1B:
	ld bc, $0304
LABEL_3E1E:
	ld a, (de)
	call LABEL_3E30
	call LABEL_3E3E
	ld a, (de)
	inc e
	call LABEL_3E34
	call LABEL_3E3E
	djnz LABEL_3E1E
	ret

LABEL_3E30:
	rrca
	rrca
	rrca
	rrca
LABEL_3E34:
	and $0F
	add a, $30
	cp $3A
	ret c
	add a, $07
	ret

LABEL_3E3E:
	cp $30
	jr nz, LABEL_3E5D
	dec c
	jp m, LABEL_3E5D
LABEL_3E46:
	ld a, $20
LABEL_3E48:
	push bc
	ld c, a
	ld a, h
	add a, $CC
	ld h, a
	ld (hl), c
	sub $90
	ld h, a

	push hl
	push de
	ld.lil de, SegaVRAM
	add.lil hl, de
	ld.lil (hl), c
	pop de
	pop hl

	sub $3C
	ld h, a
	inc hl

	ld a, $01
	ld (DrawTilemapTrig), a

	ld a, c
	pop bc
	ret

LABEL_3E5D:
	ld c, $00
	jr LABEL_3E48

LABEL_3E61:
	ld b, $06
	ld a, $20
LABEL_3E65:
	call LABEL_3E48
	djnz LABEL_3E65
	ret

LABEL_3E6B:
	ld de, $C38E
	ld hl, $C335
	ld b, $03
LABEL_3E73:
	ld a, (de)
	cp (hl)
	ret c
	jr nz, LABEL_3E7D
	inc e
	inc l
	djnz LABEL_3E73
	ret

LABEL_3E7D:
	ld a, (de)
	ld (hl), a
	inc e
	inc l
	djnz LABEL_3E7D
	ret

LABEL_3E84:
	ld a, ($C334)
	and a
	ret m
	ld a, ($C331)
	ld c, a
	and $0F
	ret nz
	ld a, c
	rrca
	rrca
	rrca
	rrca
	ld c, a
	ld hl, $0099
	ld de, $00F9
	ld a, ($C332)
	and a
	jr z, LABEL_3EA3
	ex de, hl
LABEL_3EA3:
	push de
	ld a, ($C334)
	and c
	ld a, ($C332)
	jr z, LABEL_3EAF
	ld a, $02
LABEL_3EAF:
	call LABEL_3EC2
	pop hl
	ld a, ($C333)
	and a
	jr z, LABEL_3EC0
	ld a, ($C332)
	xor $01
	jr LABEL_3EC2

LABEL_3EC0:
	ld a, $02
LABEL_3EC2:
	add a, a
	add a, a
	ld de, DATA_3ED5
	add a, e
	ld e, a
	jr nc, LABEL_3ECC
	inc d
LABEL_3ECC:
	ld a, (de)
	inc de
	and a
	ret z
	call LABEL_3E48
	jr LABEL_3ECC

; Data from 3ED5 to 3EE0 (12 bytes)
DATA_3ED5:
	.db $31, $55, $50, $00, $32, $55, $50, $00, $20, $20, $20, $00

LABEL_3EE1:
	ld a, $01
	ld ($C398), a
	ld bc, $0500
	ld hl, $C393
LABEL_3EEC:
	ld (hl), c
	inc l
	djnz LABEL_3EEC
	jr LABEL_3F1C

LABEL_3EF2:
	ld hl, $C393
	ld a, (hl)
	inc a
	cp $08
	jr c, LABEL_3EFD
	ld a, $05
LABEL_3EFD:
	ld (hl), a
	inc l
	ld a, (hl)
	inc a
	and $07
	ld (hl), a
	inc l

	inc (hl)
	ld a, (hl)
	and $18
	call.lil nz, ClearTilemapCache + romStart

	inc l
	ld a, (hl)
	inc a
	cp $10
	jr nc, LABEL_3F0E
	ld (hl), a
LABEL_3F0E:
	inc l
	ld a, (hl)
	inc a
	cp $09
	jr nc, LABEL_3F16
	ld (hl), a
LABEL_3F16:
	inc l
	ld a, (hl)
	add a, $01
	daa
	ld (hl), a
LABEL_3F1C:
	call LABEL_3F6D
LABEL_3F1F:
	ld a, ($C395)	
	and $18
	rrca
	rrca
	rrca
	ld hl, DATA_3F69
	ld c, a
	ld b, 0
	add hl, bc
	ld a, (hl)
	ld c, a
	ld hl, $C32A
	cp (hl)
	jr z, +_

	push af
	push bc

	ld a, (hl)
	rrca \ rrca \ rrca

	ld hl, MSXPalette
	ld c, a
	ld b, 0
	add hl, bc

	ld hl, (hl)
	ex de, hl
	ld.lil hl, CRAM
	add.lil hl, bc
	ld.lil (hl), e
	inc l
	ld.lil (hl), d
	pop bc
	pop af
	
_:	ld hl, MSXPalette
	add hl, bc
	add hl, bc
	ld hl, (hl)
	ex de, hl
	ld.lil hl, CRAM
	add a, a
	ld l, a	
LABEL_3F30:
	rlca
	rlca
	rlca
	ld ($C32A), a
	ld ($C32B), a
	ld ($C32D), a
	ld ($C32E), a
	ld ($C32F), a

	ld.lil (hl), e
	inc l
	ld.lil (hl), d
LABEL_3F3F:
	ld.lil hl, $C310 + romStart
	ld.lil de, SegaVRAM + $3F80
	ld bc, $0020
LABEL_3F48:
	ldir.lil
	ret

LABEL_3F58:
	ld a, ($C331)
	and $07
	ret nz
	ld a, ($C331)
	and $08
	jr nz, LABEL_3F1F
	ld.lil hl, CRAM
	ld de, $FFFF
	ld a, ($C395)
ResetWhiteColor:
	and $18
	rrca
	rrca
	rrca
	ld c, a
	ld b, 0
	push ix
	ld ix, DATA_3F69
	add ix, bc
	ld a, (ix)
	add a, a
	ld l, a
	pop ix
	jr LABEL_3F30

; Data from 3F69 to 3F6C (4 bytes)
DATA_3F69:
	.db $05, $03, $0E, $0B

MSXPalette:
	.dw $0000, $0000, $A2C9, $BB2F, $AD5B, $C1DD, $D96A, $337D
	.dw $ED8B, $7E2F, $670B, $EF30, $1E88, $D996, $6739, $FFFF

ClearTilemapCache:
	.ASSUME ADL=1
	exx
	ld hl, TilemapCache
	ld de, TilemapCache + 1
	ld bc, $0300
	ld (hl), $20
	ldir
	exx
	ret.sis

LABEL_3F6D:
	ld hl, $C393
	ld a, (hl)
	add a, a
	add a, a
	add a, a
	add a, (hl)
	ld hl, DATA_3F82
	add a, l
	ld l, a
	jr nc, LABEL_3F7D
	inc h
LABEL_3F7D:
	ld de, $C39B
	ld bc, $0009
	ldir
	ld hl, $C39B
	ld a, (hl)
	add a, a
	add a, (hl)
	add a, a
	add a, a
	ld hl, DATA_3FCA
	add a, l
	ld l, a
	jr nc, LABEL_3F95
	inc h
LABEL_3F95:
	ld de, $C3A4
	ld bc, $000C
	ldir
	ret

StoreRegisters:
	ld (SaveSP), sp
	ld sp, $D012
	push	af
	push	bc
	push	de
	push	hl
	exx
	push	bc
	push	de
	push	hl
	push	ix
	push	iy
	ld sp, (SaveSP)
	ret

RestoreRegisters:
	ld	(SaveSP), sp
	ld	sp, $D000
	pop	iy
	pop	ix
	pop	hl
	pop	de
	pop	bc
	exx
	pop	hl
	pop	de
	pop	bc
	pop	af
	ld	sp, (SaveSP)
	ret

SaveSP:
	.dw 0

; Data from 3F9E to 3FFF (98 bytes)
DATA_3F82:
	.db $00, $00, $01, $09, $05, $E0, $01, $68, $01, $00, $01, $02, $0B, $05, $90, $01
	.db $68, $01, $01, $00, $02, $0B, $05, $68, $01, $2C, $01, $01, $01, $03, $0D, $07
	.db $2C, $01, $F0, $00, $02, $02, $03, $0B, $05, $F0, $00, $B4, $00, $01, $02, $04
	.db $11, $09, $F0, $00, $78, $00, $02, $03, $03, $0D, $07, $78, $00, $01, $00, $03
	.db $03, $04, $11, $09, $3C, $00, $3C, $00
DATA_3FCA:
	.db $F0, $00, $E0, $00, $F0, $00, $00, $01
	.db $80, $00, $80, $00, $F0, $00, $F0, $00, $00, $01, $10, $01, $90, $00, $90, $00
	.db $00, $01

; Data from 4000 to 401B (28 bytes)
	.db $00, $01, $10, $01, $20, $01, $A0, $00, $A0, $00, $10, $01, $00, $01, $20, $01
	.db $40, $01, $B0, $00, $B0, $00, $FF, $FF, $FF, $FF, $FF, $FF

; Data from 401C to 4473 (1112 bytes)
DATA_401C:
	#import "src/PowerPac/font.bin"

; Data from 4474 to 483F (972 bytes)
DATA_4474:
	#import "src/PowerPac/colors.bin"

HandleInterrupt:
	jp LABEL_2089

#include "src/includes/renderer_MSX.asm"
#include "src/includes/ti_equates.asm"
#undef ScreenMap
#undef SAT

#define ScreenMap	SegaVRAM + $3C00
#define SAT		SegaVRAM + $3F00