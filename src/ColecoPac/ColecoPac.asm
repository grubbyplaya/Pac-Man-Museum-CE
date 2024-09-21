.db $FF
.ORG 0

.dl MuseumHeader
.dl MuseumIcon
.dl HeaderEnd

MuseumHeader:
	.db $83, "Pac-Man (COLECO VER.)", 0
MuseumIcon:
#import "src/includes/art/logos/coleco.bin"
HeaderEnd:

.ASSUME ADL = 0

.ORG $4018

SetupGame:
	ld hl, $C000
	ld de, $C000 + 1
	ld bc, $1FFF
	ld (hl), l
	ldir

	ld hl, HandleInterrupt
	ld de, $0038
	ld bc, HandleInterrupt_End-HandleInterrupt
	ldir

	ei
	jp LABEL_8024

;up = left
;down = right
;left = up
;right = down
;SMS = CV

GetDPADInput:
	push bc
	ld.lil a, (KbdG7)
	ld c, a
	xor a
	bit kbitUp, c
	jr z, +_
	set 0, a
_:	bit kbitDown, c
	jr z, +_
	set 2, a
_:	bit kbitLeft, c
	jr z, +_
	set 3, a
_:	bit kbitRight, c
	jr z, +_
	set 1, a
_:	cpl
	res 7, a
	pop bc
	ret

Header:
	; Data from 8000 to 8023 (36 bytes)
	.db $55, $AA, $00, $00, $00, $00, $00, $00, $00, $00, $24, $80
	.fill 18, $00
	.db $C3, $00, $00, $C3, $5A, $A9

LABEL_8024:
	call LABEL_8B41
	call LABEL_810E
	call LABEL_8B5F
	call LABEL_A96A
	call LABEL_8513

	ld a, $FF
	ld.lil hl, CRAM + $1E
	ld.lil (hl), a
	inc l
	ld.lil (hl), a

	call LABEL_8C02
	call LABEL_8C0D
	jr LABEL_8044

LABEL_803B:
	call LABEL_BB11
	call LABEL_8C02
	call LABEL_8C0D
LABEL_8044:
	call LABEL_8B0E
	call LABEL_8A01
	call ClearTileCache
	call LABEL_8B1D
	ld a, 1
	ld (DrawTilemapTrig), a
	ld hl, $8000
LABEL_8050:
	call LABEL_A96A
	call GetNumberKey
LABEL_8061:
	cp $7D
	jr z, LABEL_807E
	cp $77
	jr z, LABEL_8081
	cp $7C
	jr z, LABEL_8085
	cp $72
	jr z, LABEL_8090
	cp $73
	jr z, LABEL_8093
	cp $7E
	jr z, LABEL_8097

	dec hl
	ld a, l
	or h
	jr nz, LABEL_8050
LABEL_807E:
	sub a
	jr LABEL_8087

LABEL_8081:
	ld a, $01
	jr LABEL_8087

LABEL_8085:
	ld a, $02
LABEL_8087:
	ld ($C19F), a
	sub a
	ld ($C0CC), a
	jr LABEL_80A4

LABEL_8090:
	sub a
	jr LABEL_8099

LABEL_8093:
	ld a, $01
	jr LABEL_8099

LABEL_8097:
	ld a, $02
LABEL_8099:
	ld ($C19F), a
	sub a
	set 1, a
	ld ($C0CC), a
	jr LABEL_80A4

LABEL_80A4:
	ld sp, $C300
	sub a
	ld b, $06
	ld hl, $C0C3
LABEL_80AD:
	ld (hl), a
	inc hl
	djnz LABEL_80AD
	ld ($C0CD), a
	ld ($C0CE), a
	call LABEL_AD0D
	ld hl, $C0CC
	set 0, (hl)
	push hl
	call LABEL_AD0D
	pop hl
	res 0, (hl)
	ld a, ($C19F)
	ld b, $04
	and a
	jr z, LABEL_80D3
	dec b
	dec a
	jr z, LABEL_80D3
	dec b
LABEL_80D3:
	ld a, b
	ld ($C141), a
	ld ($C142), a
	call LABEL_8B5F
	call LABEL_8B0E
	ld hl, $192B
	ld de, DATA_8AF6
	call LABEL_A539
	ld a, $0A
	call LABEL_BB2C
	ld a, $0B
	call LABEL_BB2C
	ld bc, $0122
	call LABEL_8AA1
	call LABEL_8B1D
	jp LABEL_A93E

LABEL_80FF:
	ld a, ($C1A2)
	set 6, a
	ld ($C1A2), a
	ret

LABEL_810E:
	ld a, ($C1A2)
	res 6, a
	ld ($C1A2), a
	ret

LABEL_811D:
	ld a, c
	rrca
	rrca
	rrca
	ld l, a
	ld h, $00
	ld de, MSXPalette
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)

	ld.lil hl, CRAM + $1E
	ld.lil (hl), e
	inc l
	ld.lil (hl), d
	ret

MSXPalette:
	.dw $0000, $0000, $A2C9, $BB2F, $AD5B, $C1DD, $D96A, $337D
	.dw $ED8B, $7E2F, $670B, $EF30, $1E88, $D996, $6739, $FFFF

LABEL_8133:
	ld hl, $2000
	ld de, DATA_84C9
	ld bc, $0020
	call LABEL_AC38
	call LABEL_A127
	ld hl, $01FF
	ld ($C1A0), hl
	ld de, DATA_81E7
	ld bc, $00D0
	ld hl, $0540
	call LABEL_AC38
	ld de, DATA_82B7
	ld bc, $01A0
	ld hl, $0640
	call LABEL_AC38
	ld hl, $180C
	ld de, DATA_8457
	exx
	ld b, $0B
LABEL_8169:
	exx
	ld bc, $000A
	call LABEL_81C2
	ld bc, $0020
	add hl, bc
	exx
	djnz LABEL_8169
	ld hl, $1936
	ld de, DATA_84C5
	ld bc, $0002
	call LABEL_81C2
	ld hl, $1956
	ld bc, $0002
	call LABEL_AC38
	ld hl, $1A0D
	ld de, DATA_84F7
	ld bc, $0008
	call LABEL_81C2
	ld hl, $1AE8
	ld bc, $0014
	call LABEL_81C2

	ld a, 1
	ld (DrawTilemapTrig), a

	ld a, $C8
	ld hl, $196B
	call LABEL_81B8
	ld hl, $198B
	call LABEL_81B8
	ld hl, $19AB
	call LABEL_81B8
	ld hl, $19CB
LABEL_81B8:
	ld b, $0C
LABEL_81BA:
	call LABEL_AD6F
	inc a
	inc hl
	djnz LABEL_81BA
	ret

LABEL_81C2:
	call LABEL_AC38
	ex de, hl
	ret

LABEL_81C7:
	ld hl, $C1A1
	dec (hl)
	ret nz
	ld (hl), $03
	dec hl
	ld a, (hl)
	inc a
	cp $0B
	jr c, LABEL_81D6
	sub a
LABEL_81D6:
	ld (hl), a
	ld d, $00
	ld e, a
	ld hl, DATA_84E9
	add hl, de
	ld b, $04
	ld c, (hl)
	ld e, $15
	call LABEL_811D
	ret

; Data from 81E7 to 8201 (27 bytes)
DATA_81E7:
	.db $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.db $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $F0, $F0, $F0

; 1st entry of Pointer Table from 92DD (indexed by unknown)
; Data from 8202 to 82B6 (181 bytes)
DATA_8202:
	.db $F0, $F0, $F0, $F0, $F0, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00, $00
	.db $00, $00, $80, $80, $80, $03, $03, $07, $07, $0F, $0F, $1F, $1F, $FF, $FE, $FE
	.db $FE, $FC, $FC, $FC, $F8, $FF, $7F, $7F, $7F, $3F, $3F, $3F, $1F, $C0, $C0, $E0
	.db $E0, $F0, $F0, $F8, $F8, $00, $00, $00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF
	.db $FF, $FF, $FF, $FF, $FF, $F8, $F0, $F0, $E0, $E0, $C0, $C0, $80, $1F, $0F, $0F
	.db $07, $07, $03, $03, $01, $FC, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00
	.db $80, $C0, $E0, $F0, $F8, $00, $00, $03, $0F, $3F, $FF, $FF, $FF, $7F, $FF, $FF
	.db $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FE, $FC, $F8, $F0, $E0, $C0, $FF, $7F, $7F
	.db $3F, $1F, $0F, $07, $03, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $C0
	.db $F0, $FC
	.fill 9, $FF
	.db $F8, $C0, $FF, $FE, $FC, $F0, $C0, $00, $00, $00, $FF, $7F, $3F, $0F, $03, $00
	.db $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $03

; Data from 82B7 to 8456 (416 bytes)
DATA_82B7:
	.db $00, $00, $00, $00, $00, $00, $00, $00, $07, $0F, $0F, $1F, $1F, $1F, $3F, $3F
	.db $80, $C0, $C0, $E0, $E0, $E0, $F0, $F0, $FF, $FF, $FF, $FF, $FF, $FF, $03, $03
	.db $FF, $FF, $FF, $FF, $FF, $FF, $F0, $F0, $C0, $C0, $C0, $C1, $C1, $C1, $03, $03
	.db $78, $FC, $FC, $FE, $FE, $FE, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
	.db $FF, $FF, $FF, $FF, $FF, $FF, $FC, $FC, $F8, $FE, $FF, $FF, $FF, $FF, $1F, $0F
	.db $03, $03, $03, $83, $C3, $C3, $E3, $E3, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
	.db $00, $00, $00, $00, $00, $00, $00, $00, $3F, $3F, $7C, $7C, $7C, $FC, $F8, $F8
	.db $F0, $F0, $F8, $F8, $F8, $FC, $7C, $7C, $03, $03, $03, $03, $03, $03, $03, $03
	.db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $03, $03, $07, $07, $07, $0F, $0F, $0F
	.db $FF, $FF, $CF, $CF, $CF, $CF, $87, $87, $00, $00, $80, $80, $80, $C0, $C0, $C0
	.db $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $07, $07, $07, $0F, $0F, $1F, $3F, $7F
	.db $E3, $E3, $E3, $C3, $C3, $83, $83, $03, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
	.db $00, $01, $01, $01, $01, $03, $03, $03, $F8, $F8, $FF, $FF, $FF, $FF, $FF, $E0
	.db $7C, $7E, $FE, $FE, $FE, $FF, $FF, $1F, $03, $03, $03, $03, $03, $03, $03, $03
	.db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $0F, $1F, $1F, $1F, $1F, $3F, $3F, $3E
	.db $87, $87, $FF, $FF, $FF, $FF, $FF, $01, $C0, $E0, $E0, $E0, $E0, $F0, $F0, $F0
	.db $FC, $FD, $FD, $FC, $FC, $FC, $FC, $FC, $FE, $FC, $FC, $FC, $FE, $7E, $7F, $3F
	.db $03, $03, $03, $03, $03, $03, $03, $03, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
	.db $03, $07, $07, $07, $07, $0F, $0F, $00, $E0, $E0, $E0, $C0, $C0, $C0, $C0, $00
	.db $1F, $1F, $1F, $0F, $0F, $0F, $0F, $00, $03, $83, $83, $83, $83, $C3, $C3, $00
	.db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $00, $3E, $7E, $7E, $7C, $7C, $FC, $FC, $00
	.db $01, $01, $01, $00, $00, $00, $00, $00, $F0, $F8, $F8, $F8, $F8, $FC, $FC, $00
	.db $FC, $FC, $FC, $FC, $FC, $FC, $FC, $00, $3F, $1F, $1F, $0F, $0F, $07, $07, $00
	.db $83, $83, $C3, $C3, $E3, $E3, $F3, $00, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $00
	.db $07, $18, $20, $4F, $48, $88, $88, $88, $8F, $88, $88, $48, $48, $20, $18, $07
	.db $E0, $18, $04, $F2, $0A, $09, $09, $09, $F1, $41, $21, $12, $0A, $04, $18, $E0

; Data from 8457 to 84C4 (110 bytes)
DATA_8457:
	.db $A8, $A8, $A8, $A9, $AA, $AB, $A9, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AA, $AB
	.db $A9, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AA, $AB, $A9, $A8, $A8, $A8, $A8, $A8
	.db $A8, $A9, $AA, $AB, $A9, $A8, $A8, $A8, $A8, $A8, $A8, $A9, $AA, $AB, $A9, $A8
	.db $A8, $A8, $A8, $A8, $AC, $A9, $AA, $AB, $A9, $AD, $A8, $A8, $A8, $A8, $AE, $AF
	.db $AA, $AB, $B0, $B1, $A8, $A8, $A8, $B2, $B3, $B4, $AA, $AB, $B5, $B6, $B7, $A8
	.db $B8, $B9, $BA, $A8, $AA, $AB, $A8, $BB, $BC, $BD, $BE, $BF, $A8, $A8, $AA, $AB
	.db $A8, $A8, $C0, $C1
	.fill 10, $A8

; Data from 84C5 to 84C8 (4 bytes)
DATA_84C5:
	.db $F8, $FA, $F9, $FB

; Data from 84C9 to 84E8 (32 bytes)
DATA_84C9:
	.db $F0, $F0, $F0, $F0, $F0, $F0, $50, $50, $50, $50, $50, $50
	.fill 9, $A0
	.fill 4, $F0
	.fill 6, $60
	.db $E0

; Data from 84E9 to 84F6 (14 bytes)
DATA_84E9:
	.db $60, $80, $90, $A0, $B0, $30, $20, $C0, $40, $50, $D0, $70, $E0, $F0

; Data from 84F7 to 8512 (28 bytes)
DATA_84F7:
	.db $50, $52, $45, $53, $45, $4E, $54, $53, $43, $4F, $50, $59, $52, $49, $47, $48
	.db $54, $00, $31, $39, $38, $33, $00, $41, $54, $41, $52, $49

LABEL_8513:
	call ClearTileCache
	call LABEL_A127
	call LABEL_8133
	call LABEL_80FF
	call LABEL_8B1D
	ld b, $78
LABEL_8521:
	push bc
	call LABEL_A96A
	call LABEL_81C7
	pop bc
	djnz LABEL_8521
	call LABEL_8B0E
	sub a
	ld hl, $0300
	ld bc, $0228
	call LABEL_AC26
	ld b, $05
	ld hl, DATA_8770
LABEL_853D:
	push bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ex de, hl
LABEL_8543:
	ld a, (de)
	cp $FE
	jr z, LABEL_8558
	inc a
	jr nz, LABEL_854E
	sub a
	jr LABEL_8551

LABEL_854E:
	dec a
	add a, $60
LABEL_8551:
	call LABEL_AD6F
	inc hl
	inc de
	jr LABEL_8543

LABEL_8558:
	inc de
	ex de, hl
	pop bc
	djnz LABEL_853D
	ld hl, DATA_8770
	ld ($C199), hl
	sub a
	ld ($C19C), a
LABEL_8567:
	ld b, $02
LABEL_8569:
	push bc
	call LABEL_81C7
	ld a, $08
	ld ($C19B), a
	ld a, ($C19C)
	push af
	call LABEL_85B4
	pop af
	ld ($C19C), a
	pop bc
	djnz LABEL_8569
	ld a, ($C19C)
	inc a
	ld ($C19C), a
	cp $08
	jr nz, LABEL_8567
	sub a
	ld ($C19C), a
	ld hl, ($C199)
	inc hl
LABEL_8593:
	inc hl
	ld a, (hl)
	cp $FE
	jr nz, LABEL_8593
	inc hl
	ld a, (hl)
	cp $FE
	jr nz, LABEL_85AF
	call LABEL_8B1D
	ld b, $B4
LABEL_85A4:
	push bc
	call LABEL_A96A
	call LABEL_81C7
	pop bc
	djnz LABEL_85A4
	ret

LABEL_85AF:
	ld ($C199), hl
	jr LABEL_8567

LABEL_85B4:
	ei
	halt
	ld hl, ($C199)
	ld ($C19D), hl
	inc hl
	inc hl
LABEL_85BC:
	push hl
	ld a, (hl)
	call LABEL_85FB
	call LABEL_8624
	ld c, a
	ld a, (de)
	and c
	call LABEL_AD6F
	call RefreshTile
	pop hl

	ld a, 1
	ld (DrawTilemapTrig), a

	ei
	inc hl
	ld a, (hl)
	cp $FE
	di
	jr nz, LABEL_85BC

	ld a, ($C19B)
	dec a
	ld ($C19B), a
	ret z
	ld a, ($C19C)
	inc a
	ld ($C19C), a
	cp $08
	jr z, LABEL_85EB
	ld hl, ($C19D)
	inc hl
	inc hl
	jr LABEL_85BC

LABEL_85EB:
	inc hl
	ld ($C19D), hl
	sub a
	ld ($C19C), a
	ld a, (hl)
	cp $FE
	ret z
	inc hl
	inc hl
	jr LABEL_85BC

LABEL_85FB:
	ld hl, DATA_87D9
	push af
	call LABEL_860C
	pop af
	push hl
	ld hl, $0300
	call LABEL_860C
	pop de
	ret

LABEL_860C:
	ld d, $00
	ld e, a
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	add hl, de
	ld a, ($C19C)
	ld e, a
	ld d, $00
	add hl, de
	ret

LABEL_8624:
	ld a, ($C19B)
	and a
	jr nz, LABEL_862D
	inc a
	jr LABEL_8634

LABEL_862D:
	cp $08
	jr nz, LABEL_8634
	ld a, $FF
	ret

LABEL_8634:
	dec a
	push de
	push hl
	call LABEL_863D
	pop hl
	pop de
	ret

LABEL_863D:
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_865D
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld c, (hl)
	inc hl
	call LABEL_8654
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ret

LABEL_8654:
	call LABEL_A350
	inc c
LABEL_8658:
	sub c
	jr nc, LABEL_8658
	add a, c
	ret

; Pointer Table from 865D to 866A (7 entries, indexed by $C19B)
DATA_865D:
	.dw DATA_866B, DATA_8674, DATA_8691, DATA_86CA, DATA_8711, DATA_874A, DATA_8767

; 1st entry of Pointer Table from 865D (indexed by $C19B)
; Data from 866B to 8673 (9 bytes)
DATA_866B:
	.db $07, $01, $02, $04, $08, $10, $20, $40, $80

; 2nd entry of Pointer Table from 865D (indexed by $C19B)
; Data from 8674 to 8690 (29 bytes)
DATA_8674:
	.db $1B, $03, $05, $06, $09, $0A, $0C, $11, $12, $14, $18, $21, $22, $24, $28, $30
	.db $41, $42, $44, $48, $50, $60, $81, $82, $84, $88, $90, $A0, $C0

; 3rd entry of Pointer Table from 865D (indexed by $C19B)
; Data from 8691 to 86C9 (57 bytes)
DATA_8691:
	.db $37, $07, $0B, $0D, $0E, $13, $15, $16, $19, $1A, $1C, $23, $25, $26, $29, $2A
	.db $2C, $31, $32, $34, $38, $43, $45, $46, $49, $4A, $4C, $51, $52, $54, $58, $61
	.db $62, $64, $68, $70, $83, $85, $86, $89, $8A, $8C, $91, $92, $94, $98, $A1, $A2
	.db $A4, $A8, $B0, $C1, $C2, $C4, $C8, $D0, $E0

; 4th entry of Pointer Table from 865D (indexed by $C19B)
; Data from 86CA to 8710 (71 bytes)
DATA_86CA:
	.db $45, $0F, $17, $1B, $1D, $1E, $27, $2B, $2D, $2E, $33, $35, $36, $39, $3A, $3C
	.db $47, $4B, $4D, $4E, $53, $55, $56, $59, $5A, $5C, $63, $65, $66, $69, $6A, $6C
	.db $71, $72, $74, $78, $87, $8B, $8D, $8E, $93, $95, $96, $99, $9A, $9C, $A3, $A5
	.db $A6, $A9, $AA, $AC, $B1, $B2, $B4, $B8, $C3, $C5, $C6, $C9, $CA, $CC, $D1, $D2
	.db $D4, $D8, $E1, $E2, $E4, $E8, $F0

; 5th entry of Pointer Table from 865D (indexed by $C19B)
; Data from 8711 to 8749 (57 bytes)
DATA_8711:
	.db $3F, $1F, $2F, $37, $3B, $3D, $3E, $4F, $57, $5B, $5D, $5E, $67, $6B, $6D, $6E
	.db $73, $75, $76, $79, $7A, $7C, $8F, $97, $9B, $9D, $9E, $A7, $AB, $AD, $AE, $B3
	.db $B5, $B6, $B9, $BA, $BC, $C7, $CB, $CD, $CE, $D3, $D5, $D6, $D9, $DA, $DC, $E3
	.db $E5, $E6, $E9, $EA, $EC, $F1, $F2, $F4, $F8

; 6th entry of Pointer Table from 865D (indexed by $C19B)
; Data from 874A to 8766 (29 bytes)
DATA_874A:
	.db $1B, $3F, $5F, $6F, $77, $7B, $7D, $7E, $9F, $AF, $B7, $BB, $BD, $BE, $CF, $D7
	.db $DB, $DD, $DE, $E7, $EB, $ED, $EE, $F3, $F5, $F6, $F9, $FA, $FC

; 7th entry of Pointer Table from 865D (indexed by $C19B)
; Data from 8767 to 8768 (2 bytes)
DATA_8767:
	.db $07, $7F

; Pointer Table from 8769 to 876E (3 entries, indexed by unknown)
	.dw $DFBF, $2000 | $D7EF, $2000 | $DDFB

; Data from 876F to 876F (1 bytes)
	.db $FE

; Data from 8770 to 87D8 (105 bytes)
DATA_8770:
	.db $4D, $1A, $00, $01, $02, $FF, $FF, $03, $FE, $67, $1A, $04, $05, $06, $07, $08
	.db $FF, $09, $0A, $0B, $FF, $0C, $0D, $0E, $0F, $10, $FF, $11, $44, $FE, $87, $1A
	.db $12, $13, $14, $15, $16, $17, $18, $19, $1A, $FF, $FF, $1B, $1C, $1D, $1E, $1F
	.db $20, $21, $22, $23, $24, $25, $FE, $A7, $1A, $26, $27, $28, $29, $2A, $2B, $2C
	.db $2D, $2E, $FF, $FF, $2F, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $FE
	.db $C7, $1A, $3A, $3B, $3C, $3D, $3E
	.fill 11, $FF
	.db $3F, $40, $41, $42, $43, $FE, $FE

; Data from 87D9 to 8A00 (552 bytes)
DATA_87D9:
	.db $00, $00, $00, $00, $03, $0F, $1F, $3F, $00, $00, $3F, $FF, $FF, $FF, $FF, $FF
	.db $00, $00, $80, $C0, $E0, $F8, $FC, $FE, $00, $00, $00, $00, $00, $04, $06, $07
	.db $00, $00, $00, $00, $00, $01, $1F, $FF, $00, $00, $00, $00, $3F, $FF, $FF, $FF
	.db $00, $00, $00, $00, $F0, $F8, $FC, $FC, $00, $00, $00, $01, $01, $01, $03, $03
	.db $00, $00, $80, $C0, $C0, $E0, $F0, $F8, $7F, $7F, $7F, $7F
	.fill 11, $FF
	.db $FC, $FF, $FE, $F8, $F0, $C0, $80, $00, $00, $00, $00, $00, $00, $FE, $FE, $FE
	.db $FE, $07, $07, $07, $07, $07, $07, $07, $07, $80, $80, $C0, $E0, $F0, $F0, $F8
	.db $FC, $00, $00, $00, $00, $01, $03, $07, $0F, $10, $30, $70, $F0, $F0, $F0, $F0
	.db $F0, $00, $01, $01, $03, $07, $0F, $1F, $3F, $FF, $7F, $7F, $7F, $7F, $7F, $3F
	.db $3F, $FF, $FF, $F3, $F1, $F9, $FF, $FF, $FF, $FE, $FE, $FE, $FE, $FE, $FE, $FE
	.db $FE, $03, $07, $07, $07, $0F, $0F, $0F, $1F, $FC, $FE, $FE, $FF, $FF, $FF, $CF
	.db $C7, $00, $00, $00, $00, $80, $C0, $E0, $E0, $FF, $FF, $FF, $FF, $FF, $FF, $7F
	.db $7F, $F0, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $C0, $F8, $FF, $FF, $FE
	.db $FE, $07, $07, $07, $07, $0F, $0F, $0F, $0F, $FE, $FE, $FF, $FF, $FF, $FF, $FF
	.db $FF, $1F, $3F, $7F, $FF, $FF, $FF, $FF, $FF, $F0, $F0, $F0, $F0, $F0, $E0, $E0
	.db $E0, $00, $00, $00, $01, $03, $07, $0F, $0F, $7F, $7F, $FF, $FF, $FF, $FF, $F9
	.db $F1, $C0, $C0, $C0, $E0, $E0, $E0, $F0, $F0, $00, $01, $01, $01, $01, $03, $03
	.db $03, $80, $C0, $C0, $E0, $E0, $F0, $F0, $F8, $0F, $1F, $1F, $1F, $1F, $3F, $3F
	.db $3F, $F0, $F0, $F0, $F0, $E0, $E0, $E0, $C0, $3F, $3F, $1F, $1F, $1F, $1F, $1F
	.db $1F, $FF, $FF, $FF, $FF, $FE, $FF, $FF, $FF, $FC, $F8, $E0, $80, $00, $00, $00
	.db $00, $1F, $1F, $3F, $3F, $3F, $7F, $7F, $7F, $E7, $FF, $FF, $FF, $FF, $FF, $FF
	.db $FF, $F0, $F8, $FC, $FC, $FE, $FF, $FE, $C0, $3F, $1F, $0F, $07, $01, $00, $00
	.db $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FC, $FC, $F0, $E0, $C0, $00, $00
	.db $00, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $0F, $00, $00
	.db $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $E0, $E0, $E0, $E0, $E1, $61, $00
	.db $00, $1F, $3F, $7F, $FF, $FF, $FF, $7F, $01, $F3, $FF, $FF, $FF, $FF, $FF, $FF
	.db $FF, $F0, $F0, $F8, $F8, $F8, $FC, $FC, $FC, $07, $07, $07, $07, $0F, $0F, $0F
	.db $0F, $F8, $FC, $FC, $FE, $FE, $FF, $FF, $FF, $3F, $3F, $7F, $7F, $7F, $7F, $7F
	.db $FF, $C0, $C0, $C0, $80, $80, $80, $00, $00, $0F, $0F, $0F, $0F, $07, $07, $00
	.db $00, $FF, $FF, $FF, $FF, $FF, $C0, $00, $00, $00, $00, $00, $80, $80, $00, $00
	.db $00, $7F, $FF, $F0, $00, $00, $00, $00, $00, $F8, $80, $00, $00, $00, $00, $00
	.db $00, $0F, $00, $00, $00, $00, $00, $00, $00, $FE, $FE, $06, $00, $00, $00, $00
	.db $00, $1F, $1F, $1F, $3F, $03, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $3F, $01
	.db $00, $FF, $FF, $FE, $FE, $FE, $FC, $FC, $0C, $00, $00, $00, $00, $80, $80, $80
	.db $C0

LABEL_8A01:
	ld a, $70
	ld hl, $2000
	ld bc, $0020
	call LABEL_AC26
	ld de, DATA_8CA8
	ld hl, $1889
	call LABEL_A539
	ld b, $06
	ld hl, $1925
LABEL_8A1A:
	push hl
	exx
	pop hl
	ld de, DATA_8CD0
	call LABEL_A539
	exx
	ld de, $0040
	add hl, de
	djnz LABEL_8A1A
	ld hl, $1965
	ld de, DATA_8CE7
	jp LABEL_A539

LABEL_8A33:
	call LABEL_BB11
	ld a, ($C0CD)
	ld hl, $C0CC
	bit 0, (hl)
	jr z, LABEL_8A43
	ld a, ($C0CE)
LABEL_8A43:
	cp $02
	jr nz, LABEL_8A4C
	call LABEL_9F13
	jr LABEL_8A60

LABEL_8A4C:
	cp $05
	jr nz, LABEL_8A55
	call LABEL_A157
	jr LABEL_8A60

LABEL_8A55:
	cp $09
	jr z, LABEL_8A5D
	cp $0D
	jr nz, LABEL_8A60
LABEL_8A5D:
	call LABEL_A257
LABEL_8A60:
	call LABEL_AD0D
	call LABEL_8B5F
	call LABEL_8A72
	ld bc, $005A
	call LABEL_8AA1
	jp LABEL_A93E

LABEL_8A72:
	ld de, DATA_8A95
LABEL_8A75:
	ld hl, $C0D3
	ld b, $04
LABEL_8A7A:
	ld a, (de)
	ld (hl), a
	inc de
	push de
	ld de, $001C
	add hl, de
	pop de
	djnz LABEL_8A7A
	ret

LABEL_8A86:	
	ld de, DATA_8A99
	ld a, ($C0CD)
	cp $06
	jr c, LABEL_8A75
	ld de, DATA_8A9D
	jr LABEL_8A75
	
; Data from 8A95 to 8A98 (4 bytes)	
DATA_8A95:	
	.db $01, $04, $08, $10
	
; Data from 8A99 to 8A9C (4 bytes)	
DATA_8A99:	
	.db $01, $14, $28, $42
	
; Data from 8A9D to 8AA0 (4 bytes)	
DATA_8A9D:	
	.db $01, $09, $22, $34

LABEL_8AA1:
	push bc
	call LABEL_8B0E
	ld hl, $19AD
	ld de, DATA_8AEE
	call LABEL_A539
	call LABEL_8C7A
	ld b, $12
	ld a, ($C18F)
	cp $4E
	jr z, LABEL_8AC2
	ld b, $0E
	cp $63
	jr z, LABEL_8AC2
	ld b, $0C
LABEL_8AC2:
	push bc
	call LABEL_940C
	pop bc
	djnz LABEL_8AC2
	call LABEL_AA48
	call LABEL_8B1D
	pop bc
LABEL_8AD0:
	push bc
	call LABEL_A978
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, LABEL_8AD0
	ld hl, $192B
	ld bc, $000B
	sub a
	call LABEL_AC26
	ld hl, $19AD
	ld bc, $0007
	sub a
	jp LABEL_AC26

; Data from 8AEE to 8AF5 (8 bytes)	
DATA_8AEE:	
	.db $52, $45, $41, $44, $59, $20, $24, $FF
	
; Data from 8AF6 to 8B01 (12 bytes)	
DATA_8AF6:	
	.db $50, $4C, $41, $59, $45, $52, $20, $20, $4F, $4E, $45, $FF
	
; Data from 8B02 to 8B0D (12 bytes)	
DATA_8B02:	
	.db $50, $4C, $41, $59, $45, $52, $20, $20, $54, $57, $4F, $FF

LABEL_8B0E:
	ld a, ($C1A2)
	res 5, a
	ld ($C1A2), a
	di
	ret

LABEL_8B1D:
	ld a, ($C1A2)
	set 5, a
	ld ($C1A2), a
	ei
	ret

; Data from 8B2C to 8B40 (21 bytes)
DATA_8B2C:
	.db $53, $6C, $2C, $06, $53, $86, $30, $0D, $53, $60, $2C, $07, $53, $96, $30, $09
	.db $83, $7C, $00, $0A, $D0

LABEL_8B41:
	call LABEL_BB11
	ld hl, $C000
	ld bc, $01C5
LABEL_8B4A:
	ld (hl), $00
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, LABEL_8B4A
	ld hl, DATA_AC0F
	ld a, (DATA_AC0F + 1)
	ld ($C1A2), a
	ret

LABEL_8B5F:
	call LABEL_8B0E
	call LABEL_BB11
	sub a
	set 3, a
	ld ($C145), a
	ld a, ($C0CD)
	ld b, a
	rlc b
	ld a, $2C
	sub b
	ld ($C196), a
	ld hl, $0618
	ld ($C194), hl
	sub a
	ld ($C146), a
	set 3, a
	ld ($C082), a
	ld ($C0BC), a
	ld a, $01
	ld ($C083), a
	ld ($C191), a
	ld a, $04
	ld ($C0BF), a
	ld a, $64
	ld ($C14B), a
	ld a, $50
	ld ($C14A), a
	ld hl, DATA_92B1
	ld de, $C0D1
	ld bc, $0070
	ldir
	ld a, ($C18F)
	ld ($C0F5), a
	ld ($C111), a
	ld ($C12D), a
	inc a
	inc a
	inc a
	ld ($C0D9), a
	ld hl, $182C
	ld ($C0CF), hl
	call LABEL_8C02
	call LABEL_8C0D
	ld de, DATA_B8BD
	ld hl, $3800
	ld bc, $01C0
	call LABEL_AC38
	call LABEL_A33D
	ld hl, DATA_8B2C
	ld de, $C000
	ld bc, $0015
	ldir
	call LABEL_AD3B
	ei
	call LABEL_8D4F
	call LABEL_8D18
	call LABEL_8C35
	call LABEL_A55C
	ld bc, $0000
	call LABEL_A460
	call LABEL_A50C
	call LABEL_AAB6
	call LABEL_8B1D
	ret

LABEL_8C02:
	di
	ld hl, $0000
	sub a
	ld bc, $5000
	call LABEL_AC26
	ei
	ret

LABEL_8C0D:
	ld hl, DATA_B3B7
LABEL_8C10:
	ld a, (hl)
	and a
	jr z, LABEL_8C28
	sla a
	sla a
	sla a
	ld c, a
	ld b, $00
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ex de, hl
	call LABEL_AC38
	jr LABEL_8C10

LABEL_8C28:
	ld hl, $2000
	ld de, DATA_BAF8
	ld bc, $0019
	call LABEL_AC38
	ret

LABEL_8C35:
	ld hl, $180B
	ld de, DATA_8C9E
	ld bc, $000A
	call LABEL_AC38
	ld hl, $1828
	ld a, $30
	call LABEL_AD6F
	ld a, $30
	ld hl, $1832
	call LABEL_AD6F
	ld hl, $C0CC
	bit 1, (hl)
	ret z
	push hl
	ld hl, $183D
	ld a, $30
	call LABEL_AD6F
	pop hl
	ld a, (hl)
	push af
	set 0, (hl)
	ld bc, $0000
	push hl
	call LABEL_A460
	pop hl
	push hl
	res 0, (hl)
	ld bc, $0000
	call LABEL_A460
	pop hl
	pop af
	ld (hl), a
	ret

LABEL_8C7A:
	ld hl, $1805
	ld de, DATA_8C98
	ld bc, $0003
	call LABEL_AC38
	ld a, ($C0CC)
	bit 1, a
	ret z
	ld hl, $181A
	ld de, DATA_8C9B
	ld bc, $0003
	jp LABEL_AC38

; Data from 8C98 to 8C9A (3 bytes)
DATA_8C98:
	.db $31, $C0, $C1

; Data from 8C9B to 8C9D (3 bytes)
DATA_8C9B:
	.db $32, $C0, $C1

; Data from 8C9E to 8CA7 (10 bytes)
DATA_8C9E:
	.db $B8, $B9, $BA, $B8, $00, $BB, $BC, $BD, $BE, $BF

; Data from 8CA8 to 8CCF (40 bytes)
DATA_8CA8:
	.db $54, $4F, $20, $53, $45, $4C, $45, $43, $54, $20, $47, $41, $4D, $45, $11, $11
	.db $85, $50, $52, $45, $53, $53, $20, $42, $55, $54, $54, $4F, $4E, $20, $4F, $4E
	.db $20, $4B, $45, $59, $50, $41, $44, $FF

; Data from 8CD0 to 8CE6 (23 bytes)
DATA_8CD0:
	.db $31, $20, $5B, $20, $45, $41, $53, $59, $20, $31, $20, $50, $4C, $41, $59, $45
	.db $52, $20, $47, $41, $4D, $45, $FF

; Data from 8CE7 to 8D17 (49 bytes)
DATA_8CE7:
	.db $32, $89, $4D, $45, $44, $20, $11, $11, $85, $33, $89, $48, $41, $52, $44, $11
	.db $11, $85, $34, $89, $45, $41, $53, $59, $20, $32, $11, $11, $85, $35, $89, $4D
	.db $45, $44, $20, $20, $32, $11, $11, $85, $36, $89, $48, $41, $52, $44, $20, $32
	.db $FF

LABEL_8D18:
	ld a, ($C143)
	ld hl, $C0CC
	bit 0, (hl)
	jr z, LABEL_8D25
	ld a, ($C144)
LABEL_8D25:
	ld c, a
	ld a, $18
	bit 0, c
	jr z, LABEL_8D32
	ld hl, $1882
	call LABEL_AD6F
LABEL_8D32:
	bit 2, c
	jr z, LABEL_8D3C
	ld hl, $1A22
	call LABEL_AD6F
LABEL_8D3C:
	bit 1, c
	jr z, LABEL_8D46
	ld hl, $189E
	call LABEL_AD6F
LABEL_8D46:
	bit 3, c
	ret z
	ld hl, $1A3E
	jp LABEL_AD6F

LABEL_8D4F:
	ld b, $D6
	ld de, $C085
	ld a, ($C0CC)
	bit 0, a
	jr z, LABEL_8D5E
	ld de, $C0A0
LABEL_8D5E:
	ld iy, DATA_AF71
	ld c, $01
LABEL_8D64:
	dec c
	jr nz, LABEL_8D6B
	inc de
	ld a, (de)
	ld c, $08
LABEL_8D6B:
	rlca
	jr nc, LABEL_8D7B
	ld h, (iy+1)
	ld l, (iy+0)
	push af
	ld a, $02
	call LABEL_AD6F
	pop af
LABEL_8D7B:
	inc iy
	inc iy
	djnz LABEL_8D64
	ret

LABEL_8D82:
	ld hl, $C086
	jr LABEL_8D8D
	call LABEL_8D82
LABEL_8D8A:
	ld hl, $C0A1
LABEL_8D8D:
	ld b, $1B
	ld a, $FF
LABEL_8D91:
	ld (hl), a
	inc hl
	djnz LABEL_8D91
	ret

LABEL_8D96:
	ld a, ($C083)
	dec a
	ld ($C083), a
	ret nz
	ld a, $02
	ld ($C083), a
	ld a, ($C0BF)
	inc a
	and $03
	ld ($C0BF), a
	ld hl, DATA_8DCA
	ld e, a
	ld d, $00
	add hl, de
	ld de, $0004
	ld a, ($C0BC)
	rrca
	jr c, LABEL_8DC5
	add hl, de
	rrca
	jr c, LABEL_8DC5
	add hl, de
	rrca
	jr c, LABEL_8DC5
	add hl, de
LABEL_8DC5:
	ld a, (hl)
	ld ($C012), a
	ret

; Data from 8DCA to 8DD9 (16 bytes)
DATA_8DCA:
	.db $00, $0C, $10, $0C, $00, $04, $08, $04, $00, $14, $18, $14, $00, $1C, $20, $1C

LABEL_8DDA:
	ld d, (iy+1)
	ld e, (iy+0)
	ld a, ($C0BC)
	ld b, a
	ld a, ($C082)
	cp b
	ret z
	call LABEL_9929
	bit 0, b
	jr nz, LABEL_8E32
	bit 1, b
	jr nz, LABEL_8E19
	bit 2, b
	jr nz, LABEL_8E53
	inc d
	ld a, d
	and $07
	cp $04
	jr z, LABEL_8E05
	inc d
	inc a
	cp $04
	ret nz
LABEL_8E05:
	ld a, ($C082)
	cp $01
	jr nz, LABEL_8E11
	bit 0, c
	ret nz
	jr LABEL_8E28

LABEL_8E11:
	cp $04
	ret nz
	bit 2, c
	ret nz
	jr LABEL_8E28

LABEL_8E19:
	dec d
	ld a, d
	and $07
	cp $04
	jr z, LABEL_8E05
	dec d
	dec a
	cp $04
	ret nz
	jr LABEL_8E05

LABEL_8E28:
	ld (iy+1), d
	ld (iy+0), e
	pop af
	jp LABEL_8E97

LABEL_8E32:
	inc e
	ld a, e
	and $07
	cp $03
	jr z, LABEL_8E3F
	inc e
	inc a
	cp $03
	ret nz
LABEL_8E3F:
	ld a, ($C082)
	cp $02
	jr nz, LABEL_8E4B
	bit 1, c
	ret nz
	jr LABEL_8E28

LABEL_8E4B:
	cp $08
	ret nz
	bit 3, c
	ret nz
	jr LABEL_8E28

LABEL_8E53:
	dec e
	ld a, e
	and $07
	cp $03
	jr z, LABEL_8E3F
	dec e
	dec a
	cp $03
	ret nz
	jr LABEL_8E3F

LABEL_8E62:
	ld ($C19D), a
	ld e, $00
	ld b, $04
LABEL_8E69:
	rrca
	jr nc, LABEL_8E6D
	inc e
LABEL_8E6D:
	djnz LABEL_8E69
	ld a, $01
	cp e
	jr c, LABEL_8E78
LABEL_8E74:
	ld a, ($C19D)
	ret

LABEL_8E78:
	call LABEL_9923
	ld a, ($C19D)
	and c
	jr nz, LABEL_8E74
	ld a, ($C0BC)
	ld b, a
	ld a, ($C19D)
	and b
	jr nz, LABEL_8E92
	ld a, ($C0BC)
	call LABEL_9061
	ld b, a
LABEL_8E92:
	ld a, ($C19D)
	xor b
	ret

LABEL_8E97:
	ld a, ($C14B)
	ld b, a
	ld a, ($C14A)
	ld hl, $C14C
	add a, (hl)
	ld (hl), a
	cp b
	ret c
	sub b
	ld (hl), a
LABEL_8EA7:
	ld iy, $C010
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, $C145
	bit 0, (hl)
	jr nz, LABEL_8ECF
	ld a, d
	cp $FF
	jr nz, LABEL_8EEB
	set 0, (hl)
	ld c, $00
	ld a, ($C0BC)
	bit 1, a
	jr nz, LABEL_8ECA
	ld c, $10
LABEL_8ECA:
	ld a, c
	ld ($C149), a
	ret

LABEL_8ECF:
	ld a, ($C0BC)
	ld c, $FF
	bit 3, a
	jr nz, LABEL_8EDA
	ld c, $01
LABEL_8EDA:
	ld a, ($C149)
	add a, c
	ld ($C149), a
	jr z, LABEL_8EE6
	cp $10
	ret nz
LABEL_8EE6:
	ld hl, $C145
	res 0, (hl)
LABEL_8EEB:
	ld a, e
	and $07
	cp $03
	jr nz, LABEL_8EF9
	ld a, d
	and $07
	cp $04
	jr z, LABEL_8F49
LABEL_8EF9:
	push de
	pop hl
	ld b, $00
	ld a, ($C0BC)
	ld c, $FC
	bit 0, a
	jr nz, LABEL_8F15
	bit 3, a
	jr nz, LABEL_8F10
	ld c, $04
	bit 2, a
	jr nz, LABEL_8F15
LABEL_8F10:
	ld a, h
	add a, c
	ld h, a
	jr LABEL_8F18

LABEL_8F15:
	ld a, l
	add a, c
	ld l, a
LABEL_8F18:
	ld a, l
	and $07
	cp $03
	jr nz, LABEL_8F28
	ld a, h
	and $07
	cp $04
	ex de, hl
	call z, LABEL_9073
LABEL_8F28:
	call LABEL_8DDA
	ld a, ($C082)
	and $0F
	jr z, LABEL_8F42
	ld c, a
	ld a, ($C0BC)
	cp c
	jp z, LABEL_901E
	call LABEL_9061
	and c
	ld c, a
	jp nz, LABEL_901E
LABEL_8F42:
	ld a, ($C0BC)
	ld c, a
	jp LABEL_901E

LABEL_8F49:
	ld a, ($C082)
	and $0F
	jr nz, LABEL_8F55
	ld a, ($C0BC)
	jr LABEL_8F58

LABEL_8F55:
	call LABEL_8E62
LABEL_8F58:
	ld e, (iy+0)
	ld d, (iy+1)
	ld c, a
	bit 0, c
	jr z, LABEL_8F92
	ld a, d
	add a, $08
	ld d, a
	call LABEL_8FE3
	jr nz, LABEL_8F73
	ld c, $00
	set 0, c
	jp LABEL_901E

LABEL_8F73:
	ld b, c
	res 0, c
LABEL_8F76:
	ld a, c
	and a
	jr nz, LABEL_8F58
	ld a, ($C0BC)
	cp b
	jr nz, LABEL_8F58
	ld a, (iy+3)
	cp $0A
	jr z, LABEL_8F89
	sub a
	ret

LABEL_8F89:
	ld a, (iy+2)
	cp $00
	ret nz
	jp LABEL_8D96

LABEL_8F92:
	bit 1, c
	jr z, LABEL_8FAF
	ld a, $10
	add a, d
	ld d, a
	ld a, $08
	add a, e
	ld e, a
	call LABEL_8FE3
	jr nz, LABEL_8FAA
	ld c, $00
	set 1, c
	jp LABEL_901E

LABEL_8FAA:
	ld b, c
	res 1, c
	jr LABEL_8F76

LABEL_8FAF:
	bit 2, c
	jr z, LABEL_8FCD
	ld a, $08
	add a, d
	ld d, a
	ld a, $10
	add a, e
	ld e, a
	call LABEL_8FE3
	jr nz, LABEL_8FC7
	ld c, $00
	set 2, c
	jp LABEL_901E

LABEL_8FC7:
	ld b, c
	res 2, c
	jp LABEL_8F76

LABEL_8FCD:
	ld a, $08
	add a, e
	ld e, a
	call LABEL_8FE3
	jr nz, LABEL_8FDD
	ld c, $00
	set 3, c
	jp LABEL_901E

LABEL_8FDD:
	ld b, c
	res 3, c
	jp LABEL_8F76

LABEL_8FE3:
	push de
	call LABEL_A51E
	pop de
	ret

LABEL_8FE9:
	call LABEL_9041
	ld b, (ix+7)
	ld a, (ix+9)
	cp b
	jr c, LABEL_9010
	sub b
	ld (ix+9), a
	ld a, (ix+16)
	and a
	jr z, LABEL_9013
	push bc
	call LABEL_9989
	pop bc
	call LABEL_9041
	ld a, (ix+16)
	inc a
	and $07
	ld (ix+16), a
LABEL_9010:
	sub a
	inc a
	ret

LABEL_9013:
	pop af
	pop af
	ld ($C0BC), a
	call LABEL_9989
	jp LABEL_94AE

LABEL_901E:
	ld a, (iy+3)
	cp $0A
	jp nz, LABEL_8FE9
	call LABEL_902D
	jp LABEL_8D96

; Data from 902C to 902C (1 bytes)
	.db $C9

LABEL_902D:
	call LABEL_9041
	ld a, ($C14B)
	ld b, a
	ld a, ($C14C)
	cp b
	ret c
	sub b
	ld ($C14C), a
	pop af
	jp LABEL_8EA7

LABEL_9041:
	ld a, c
	ld ($C0BC), a
	bit 0, c
	jr z, LABEL_904D
	dec (iy+0)
	ret

LABEL_904D:
	bit 2, c
	jr z, LABEL_9055
	inc (iy+0)
	ret

LABEL_9055:
	bit 1, c
	jr z, LABEL_905D
	inc (iy+1)
	ret

LABEL_905D:
	dec (iy+1)
	ret

LABEL_9061:
	srl a
	jr nc, LABEL_9067
	set 3, a
LABEL_9067:
	srl a
	ret nc
	set 3, a
	ret

LABEL_906D:
	ld d, (iy+1)
	ld e, (iy+0)
LABEL_9073:
	ld a, ($C18D)
	ld ($C14A), a
	ld a, $08
	add a, e
	ld e, a
	ld a, $08
	add a, d
	ld d, a
	call LABEL_AD89
	and a
	ret z
	cp $02
	jp z, LABEL_9179
	cp $18
	jr z, LABEL_90BB
	ld b, a
	ld a, ($C189)
	cp b
	jr z, LABEL_909F
	ld a, b
	sub $80
	cp $08
	ret nc
	jp LABEL_9235

LABEL_909F:
	ld a, ($C18C)
	call LABEL_AD6F
	inc a
	inc hl
	call LABEL_AD6F
LABEL_90AA:
	ld a, $00
	call LABEL_BB2C
	ld a, $5A
	ld ($C150), a
	ld bc, ($C18A)
	jp LABEL_A460

LABEL_90BB:
	ld bc, $0005
	push hl
	call LABEL_A460
	ld a, $06
	call LABEL_BB2C
	ld a, ($C190)
	ld h, $00
	sla a
	rl h
	sla a
	rl h
	sla a
	rl h
	ld l, a
	ld ($C192), hl
	ld hl, $C145
	set 2, (hl)
	ld c, $28
	call LABEL_AB0D
	ld a, $E0
	ld hl, $2010
	call LABEL_AD6F
	ld c, $04
	ld hl, $C002
	ld ix, $C0D1
	ld b, $04
	ld de, $001C
LABEL_90FC:
	ld a, (ix+0)
	and $A0
	jr nz, LABEL_9114
	ld (hl), $34
	inc hl
	ld (hl), c
	dec hl
	set 1, (ix+0)
	ld a, ($C18F)
	srl a
	ld (ix+8), a
LABEL_9114:
	inc hl
	inc hl
	inc hl
	inc hl
	add ix, de
	djnz LABEL_90FC
	call LABEL_AA48
	pop hl
	push hl
	sub a
	ld ($C146), a
	ld c, $01
	ld a, $18
	cp h
	jr nz, LABEL_9135
	ld a, $82
	cp l
	jr z, LABEL_913E
	ld c, $02
	jr LABEL_913E

LABEL_9135:
	ld c, $04
	ld a, $22
	cp l
	jr z, LABEL_913E
; Data from 913C to 913D (2 bytes)
	.db $0E, $08

LABEL_913E:
	ld a, ($C0CC)
	bit 0, a
	jr z, LABEL_914E
	ld a, ($C144)
	xor c
	ld ($C144), a
	jr LABEL_9155

LABEL_914E:
	ld a, ($C143)
	xor c
	ld ($C143), a
LABEL_9155:
	jr nz, LABEL_9175
	ld a, ($C0CC)
	bit 0, a
	ld a, ($C0BD)
	jr z, LABEL_9164
	ld a, ($C0BE)
LABEL_9164:
	and a
	jr nz, LABEL_9175
	ld bc, $0005
	call LABEL_A460
	pop hl
	sub a
	call LABEL_AD6F
	jp LABEL_91DD

LABEL_9175:
	pop hl
	jp LABEL_9200

LABEL_9179:
	ld a, ($C18E)
	ld ($C14A), a
	push hl
	ld bc, $0001
	call LABEL_A460
	ld hl, $C0BD
	ld a, ($C0CC)
	bit 0, a
	jr z, LABEL_9193
	ld hl, $C0BE
LABEL_9193:
	ld a, (hl)
	dec a
	ld (hl), a
	cp $8C
	jr z, LABEL_919E
	cp $46
	jr nz, LABEL_91AF
LABEL_919E:
	push af
	ld hl, $19B0
	ld a, ($C189)
	call LABEL_AD6F
	ld hl, $0258
	ld ($C147), hl
	pop af
LABEL_91AF:
	bit 0, a
	ld a, $09
	set 7, a
	jr z, LABEL_91B9
	ld a, $02
LABEL_91B9:
	call LABEL_BB2C
	pop hl
	ld a, ($C0CC)
	bit 0, a
	ld a, ($C0BD)
	jr z, LABEL_91CA
	ld a, ($C0BE)
LABEL_91CA:
	and a
	jr nz, LABEL_9200
	ld a, ($C0CC)
	bit 0, a
	ld a, ($C143)
	jr z, LABEL_91DA
	ld a, ($C144)
LABEL_91DA:
	and a
	jr nz, LABEL_9200
LABEL_91DD:
	call LABEL_BB11
	sub a
	ld ($C012), a
	call LABEL_AA48
	ld b, $3C
	call LABEL_A7FC
	call LABEL_A6CD
	ld b, $08
LABEL_91F1:
	push bc
	call LABEL_9204
	ld b, $0A
	call LABEL_A7FC
	pop bc
	djnz LABEL_91F1
	jp LABEL_8A33

LABEL_9200:
	sub a
	jp LABEL_AD6F

LABEL_9204:
	ld hl, $2012
	call LABEL_AD7C
	cp $40
	ld a, $40
	ld bc, $AD5B
	jr nz, LABEL_9212
	ld a, $F0
	ld bc, $FFFF
LABEL_9212:
	call LABEL_AD6F
	ld.lil hl, CRAM + $08
	ld.lil (hl), c
	inc l
	ld.lil (hl), b
	ret

LABEL_9218:
	push hl
	and $FE
	ld e, a
	ld d, $00
	ld hl, DATA_92A9
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	pop hl
	push de
	pop ix
	ld d, (ix+11)
	ld e, (ix+10)
	and a
	push hl
	sbc hl, de
	pop hl
	ret

LABEL_9235:
	call LABEL_9218
	jr nz, LABEL_9281
	ld a, (ix+15)
	cp $02
	jr nz, LABEL_9248
	ld (ix+15), $00
	jp LABEL_9179

LABEL_9248:
	cp $18
	jr z, LABEL_927A
	ld b, a
	ld a, ($C189)
	cp b
	ret nz
	ld a, ($C18C)
	ld (ix+15), a
LABEL_9258:
	ld b, a
	inc hl
	call LABEL_AD7C
	and a
	jr nz, LABEL_9268
	ld a, b
	inc a
	call LABEL_AD6F
	jp LABEL_90AA

LABEL_9268:
	inc b
	call LABEL_9218
	jr nz, LABEL_9274
	ld (ix+15), b
	jp LABEL_90AA

LABEL_9274:
	ld (ix+14), b
	jp LABEL_90AA

LABEL_927A:
	ld (ix+15), $00
	jp LABEL_90BB

LABEL_9281:
	ld a, (ix+14)
	cp $02
	jr nz, LABEL_928F
	ld (ix+14), $00
	jp LABEL_9179

LABEL_928F:
	cp $18
	jr z, LABEL_92A2
	ld b, a
	ld a, ($C189)
	cp b
	ret nz
	ld a, ($C18C)
	ld (ix+14), a
	jp LABEL_9258

LABEL_92A2:
	ld (ix+14), $00
	jp LABEL_90BB

; Data from 92A9 to 92B0 (8 bytes)
DATA_92A9:
	.db $D1, $C0, $ED, $C0, $09, $C1, $25, $01

; Data from 92B1 to 92DC (44 bytes)
DATA_92B1:
	.db $08, $02, $01, $06, $01, $00, $2C, $64, $50, $5A, $6E, $19, $6E, $19, $00, $00
	.db $00, $80, $81, $00, $04, $08, $04, $38, $C0, $39, $00, $00, $08, $02, $04, $0D
	.db $01, $00, $28, $64, $50, $5A, $72, $19, $71, $19, $00, $00

; Pointer Table from 92DD to 92DE (1 entries, indexed by unknown)
DATA_92DD:
	.dw $8202

; Data from 92DF to 9320 (66 bytes)
	.db $83, $10, $04, $18, $04, $3C, $E0, $39, $00, $00, $08, $08, $08, $07, $01, $00
	.db $28, $64, $50, $5A, $6C, $19, $6D, $19, $00, $00, $04, $84, $85, $20, $04, $28
	.db $04, $40, $00, $3A, $00, $00, $08, $08, $10, $09, $01, $00, $28, $64, $50, $5A
	.db $73, $19, $74, $19, $00, $00, $06, $86, $87, $30, $04, $38, $04, $44, $20, $3A
	.db $00, $00

LABEL_9321:
	ld hl, $C145
	res 2, (hl)
	ld a, $E0
	ld hl, $2010
	call LABEL_AD6F
	ld iy, $C000
	ld ix, $C0D1
	ld b, $04
LABEL_9338:
	push bc
	bit 1, (ix+0)
	jr z, LABEL_9361
	res 1, (ix+0)
	ld a, ($C18F)
	ld b, a
	ld a, (ix+3)
	cp $06
	jr nz, LABEL_9351
	inc b
	inc b
	inc b
LABEL_9351:
	ld (ix+8), b
	sub a
	ld ($C146), a
	ld a, (ix+3)
	ld (iy+3), a
	call LABEL_9DB9
LABEL_9361:
	ld de, $001C
	add ix, de
	ld de, $0004
	add iy, de
	pop bc
	djnz LABEL_9338
	ld a, $05
	set 7, a
	jp LABEL_BB2C

LABEL_9375:
	ld hl, ($C192)
	dec hl
	ld ($C192), hl
	ld a, l
	or h
	jp z, LABEL_9321
	ld a, h
	and a
	ret nz
	ld a, l
	and $1F
	ret nz
	ld hl, $C0D1
	ld iy, $C000
	ld b, $04
LABEL_9391:
	bit 1, (hl)
	jr z, LABEL_93A3
	ld a, $0E
	ld c, (iy+3)
	cp c
	jr nz, LABEL_939F
	ld a, $04
LABEL_939F:
	ld (iy+3), a
	ld c, a
LABEL_93A3:
	ld de, $001C
	add hl, de
	ld de, $0004
	add iy, de
	djnz LABEL_9391
	ld a, c
	cp $0E
	ld a, $E0
	jr nz, LABEL_93B7
	ld a, $60
LABEL_93B7:
	ld hl, $2010
	jp LABEL_AD6F

LABEL_93BD:
	ld a, ($C187)
	and $07
	ret nz
	ld a, ($C151)
	inc a
	and $01
	ld ($C151), a
	ld hl, DATA_9404
	ld de, $0020
	bit 0, a
	jr z, LABEL_93D9
	ld hl, DATA_9408
LABEL_93D9:
	ld a, (hl)
	inc hl
	push hl
	ld hl, $392C
	call LABEL_93FB
	pop hl
	ld a, (hl)
	inc hl
	push hl
	ld hl, $392D
	call LABEL_93FB
	pop hl
	ld a, (hl)
	inc hl
	push hl
	ld hl, $393C
	call LABEL_93FB
	pop hl
	ld a, (hl)
	ld hl, $393D
LABEL_93FB:
	ld b, $05
LABEL_93FD:
	call LABEL_AD6F
	add hl, de
	djnz LABEL_93FD
	ret

; Data from 9404 to 9407 (4 bytes)
DATA_9404:
	.db $3D, $19, $BC, $98

; Data from 9408 to 940B (4 bytes)
DATA_9408:
	.db $36, $22, $6C, $44

LABEL_940C:
	ld hl, $C155
	ld (hl), $FF
	ld ($C153), hl
	ld a, ($C145)
	bit 2, a
	call nz, LABEL_9375
	call LABEL_93BD
	ld iy, $C000
	ld ix, $C0D1
	call LABEL_9451
	ld iy, $C004
	ld ix, $C0ED
	call LABEL_9451
	ld iy, $C008
	ld ix, $C109
	call LABEL_9451
	ld iy, $C00C
	ld ix, $C125
	call LABEL_9451
	call LABEL_9960
	jp LABEL_9D54

LABEL_9451:
	ld b, (ix+7)
	ld a, (ix+8)
	add a, (ix+9)
	ld (ix+9), a
	cp b
	ret c
	sub b
	ld (ix+9), a
	call LABEL_94AE
	bit 0, (ix+0)
	jr nz, LABEL_9496
	ld a, (iy+1)
	cp $FF
	jr nz, LABEL_9496
	set 0, (ix+0)
	sub a
	bit 1, (ix+1)
	jr nz, LABEL_9480
	ld a, $10
LABEL_9480:
	ld (ix+5), a
	ld h, (ix+11)
	ld l, (ix+10)
	sub a
	call LABEL_AD6F
	ld h, (ix+13)
	ld l, (ix+12)
	call LABEL_AD6F
LABEL_9496:
	bit 5, (ix+0)
	ret z
	ld a, (ix+1)
	ld hl, DATA_94AA - 1
LABEL_94A1:
	inc hl
	rrca
	jr nc, LABEL_94A1
	ld a, (hl)
	ld (iy+2), a
	ret

; Data from 94AA to 94AD (4 bytes)
DATA_94AA:
	.db $58, $5C, $60, $64

LABEL_94AE:
	ld a, (ix+1)
	ld ($C188), a
	bit 7, (ix+0)
	jp nz, LABEL_9DDB
	bit 0, (ix+0)
	jr z, LABEL_94DC
	ld c, $01
	ld a, (ix+1)
	bit 1, a
	jr nz, LABEL_94CC
	ld c, $FF
LABEL_94CC:
	ld a, (ix+5)
	add a, c
	ld (ix+5), a
	jr z, LABEL_94D8
	cp $10
	ret nz
LABEL_94D8:
	res 0, (ix+0)
LABEL_94DC:
	ld a, (iy+1)
	and $07
	cp $04
	jr nz, LABEL_94EE
	ld a, (iy+0)
	and $07
	cp $03
	jr z, LABEL_950A
LABEL_94EE:
	ld a, (ix+16)
	inc a
	and $07
	ld (ix+16), a
	ld c, (ix+1)
	ld a, ($C0BC)
	push af
	ld a, c
	ld ($C0BC), a
	call LABEL_8FE9
	pop af
	ld ($C0BC), a
	ret

LABEL_950A:
	bit 6, (ix+0)
	jr z, LABEL_9542
	bit 5, (ix+0)
	jr z, LABEL_952B
	ld a, (iy+0)
	cp $53
	jr nz, _LABEL_9525_
	res 6, (ix+0)
	jp LABEL_97F0	; Possibly invalid
	
_LABEL_9525_:	
	ld (ix+1), $04
	jp LABEL_94EE	; Possibly invalid

LABEL_952B:
	ld a, (iy+0)
	cp $43
	jr nz, LABEL_953C
	res 3, (ix+0)
	res 6, (ix+0)
	jr LABEL_9554

LABEL_953C:
	ld (ix+1), $01
	jr LABEL_9562

LABEL_9542:
	bit 5, (ix+0)
	jp nz, LABEL_97C3
	bit 3, (ix+0)
	jr z, LABEL_9554
	call LABEL_98F5
	jr LABEL_955F

LABEL_9554:
	bit 1, (ix+0)
	jr z, LABEL_955F
	call LABEL_98C7
	jr LABEL_9562

LABEL_955F:
	call LABEL_95EB
LABEL_9562:
	ld hl, $C145
	bit 1, (hl)
	call nz, LABEL_9D94
	bit 6, (ix+0)
	jr nz, LABEL_9588
	ld a, (iy+0)
	cp $43
	jr nz, LABEL_9588
	ld a, (iy+1)
	cp $7C
	jr nz, LABEL_9588
	bit 2, (ix+1)
	jr z, LABEL_9588
	ld (ix+1), $02
LABEL_9588:
	ld a, (iy+0)
	cp $53
	jr nz, LABEL_95C5
	bit 5, (ix+0)
	jr nz, LABEL_95C5
	bit 1, (ix+0)
	jr nz, LABEL_95C5
	ld a, (iy+1)
	cp $2C
	jr c, LABEL_95BD
	jr nz, LABEL_95B7
LABEL_95A4:
	ld a, ($C18F)
	ld b, a
	ld a, (iy+3)
	cp $06
	jr nz, LABEL_95B2
	inc b
	inc b
	inc b
LABEL_95B2:
	ld (ix+8), b
	jr LABEL_95C5

LABEL_95B7:
	cp $CC
	jr z, LABEL_95A4
	jr c, LABEL_95C5
LABEL_95BD:
	ld a, ($C18F)
	sub $1E
	ld (ix+8), a
LABEL_95C5:
	ld (ix+16), $01
	ld a, ($C0BC)
	ld c, a
	push bc
	ld a, (ix+1)
	ld ($C0BC), a
	call LABEL_8F58
	pop bc
	ld a, c
	ld ($C0BC), a
	jr z, LABEL_95EA
	ld a, ($C188)
	ld b, a
	ld a, (ix+1)
	cp b
	ret z
	jp LABEL_9DB9

LABEL_95EA:
	ret

LABEL_95EB:
	bit 6, (ix+0)
	ret nz
	call LABEL_9923
	bit 3, (ix+0)
	jr z, LABEL_9605
	ld a, (ix+1)
	and c
	ret z
	call LABEL_9061
	ld (ix+1), a
	ret

LABEL_9605:
	bit 2, (ix+0)
	jr z, LABEL_9619
	res 2, (ix+0)
	ld a, (ix+1)
	call LABEL_9061
	ld (ix+1), a
	ret

LABEL_9619:
	ld a, (ix+1)
	ld b, a
	call LABEL_9061
	ld e, a
	or b
	cpl
	and $0F
	cp c
	ret z
	ld a, e
	or c
	ld c, a
	ld a, (iy+1)
	cp $6C
	jr nz, LABEL_963E
LABEL_9631:
	ld a, (iy+0)
	cp $83
	jr z, LABEL_9644
	cp $43
	jr z, LABEL_9644
	jr LABEL_9646

LABEL_963E:
	cp $8C
	jr z, LABEL_9631
	jr LABEL_9646

LABEL_9644:
	set 0, c
LABEL_9646:
	ld a, ($C145)
	bit 3, a
	jr z, LABEL_9674
	ld hl, $C196
	dec (hl)
	jr nz, LABEL_965A
	ld hl, $C145
	res 3, (hl)
	jr LABEL_9674

LABEL_965A:
	ld a, (iy+3)
	ld hl, $0000
	cp $0D
	jr z, LABEL_96C5
	ld h, $FF
	cp $06
	jr z, LABEL_96C5
	ld l, $FF
	cp $07
	jr z, LABEL_96C5
	ld h, $00
	jr LABEL_96C5

LABEL_9674:
	ld a, (iy+3)
	cp $06
	jp z, LABEL_96C2
	cp $0D
	jp z, LABEL_973B
	cp $07
	jp z, LABEL_977D
	ld b, (iy+0)
	ld a, ($C010)
	sub b
	jr nc, LABEL_9691
	neg
LABEL_9691:
	cp $50
	jp nc, LABEL_96C2
	ld b, (iy+1)
	ld a, ($C011)
	sub b
	jr nc, LABEL_96A1
	neg
LABEL_96A1:
	cp $50
	jp nc, LABEL_96C2
LABEL_96A6:
	ld a, (ix+1)
	ld hl, DATA_96BA - 1
LABEL_96AC:
	inc hl
	cp (hl)
	jr nz, LABEL_96AC
LABEL_96B0:
	inc hl
	ld a, (hl)
	ld b, a
	and c
	jr nz, LABEL_96B0
LABEL_96B6:
	ld (ix+1), b
	ret

; Data from 96BA to 96C1 (8 bytes)
DATA_96BA:
	.db $01, $02, $04, $08, $01, $02, $04, $08

LABEL_96C2:
	ld hl, ($C010)
LABEL_96C5:
	ld a, (iy+0)
	sub l
	jr nc, LABEL_96CD
	neg
LABEL_96CD:
	ld e, a
	ld a, (iy+1)
	sub h
	jr nc, LABEL_96D6
	neg
LABEL_96D6:
	cp e
	jr nc, LABEL_970B
LABEL_96D9:
	ld a, (iy+0)
	cp l
	jr z, LABEL_96F1
	jr c, LABEL_96EA
	bit 0, c
	ld b, $01
	jp z, LABEL_96B6
	jr LABEL_96F1

LABEL_96EA:
	bit 2, c
	ld b, $04
	jp z, LABEL_96B6
LABEL_96F1:
	ld a, (iy+1)
	cp h
	jr c, LABEL_9700
	bit 3, c
	ld b, $08
	jp z, LABEL_96B6
	jr LABEL_9707

LABEL_9700:
	ld b, $02
	bit 1, c
	jp z, LABEL_96B6
LABEL_9707:
	sub a
	jp LABEL_96A6

LABEL_970B:
	ld a, (iy+1)
	cp h
	jr z, LABEL_9723
	jr c, LABEL_971C
	bit 3, c
	ld b, $08
	jp z, LABEL_96B6
	jr LABEL_9723

LABEL_971C:
	bit 1, c
	ld b, $02
	jp z, LABEL_96B6
LABEL_9723:
	ld a, (iy+0)
	cp l
	jr c, LABEL_9732
	ld b, $01
	bit 0, c
	jp z, LABEL_96B6
	jr LABEL_9707

LABEL_9732:
	ld b, $04
	bit 2, c
	jp z, LABEL_96B6
	jr LABEL_9707

LABEL_973B:
	ld hl, ($C010)
	ld a, ($C0BC)
	bit 0, a
	jr nz, LABEL_9759
	bit 2, a
	jr nz, LABEL_9765
	bit 1, a
	jr nz, LABEL_9771
	ld a, $E8
	add a, h
	ld h, a
	jp c, LABEL_96C5
	ld h, $00
	jp LABEL_96C5

LABEL_9759:
	ld a, $E8
	add a, l
	ld l, a
	jp c, LABEL_96C5
	ld l, $00
	jp LABEL_96C5

LABEL_9765:
	ld a, $18
	add a, l
	ld l, a
	jp nc, LABEL_96C5
	ld l, $FF
	jp LABEL_96C5

LABEL_9771:
	ld a, $18
	add a, h
	ld h, a
	jp nc, LABEL_96C5
	ld h, $FF
	jp LABEL_96C5

LABEL_977D:
	ld hl, ($C010)
	ld a, (iy+1)
	sub h
	jr nc, LABEL_9788
	neg
LABEL_9788:
	add a, a
	jr nc, LABEL_978D
	ld a, $FF
LABEL_978D:
	ld e, a
	ld a, (iy+1)
	cp h
	jr nc, LABEL_979B
	add a, e
	jr nc, LABEL_979F
	ld a, $FF
	jr LABEL_979F

LABEL_979B:
	sub e
	jr nc, LABEL_979F
	sub a
LABEL_979F:
	ld h, a
	ld a, (iy+0)
	sub l
	jr nc, LABEL_97A8
	neg
LABEL_97A8:
	add a, a
	jr nc, LABEL_97AD
	ld a, $FF
LABEL_97AD:
	ld e, a
	ld a, (iy+0)
	cp l
	jr nc, LABEL_97BB
	add a, e
	jr nc, LABEL_97BF
	ld a, $FF
	jr LABEL_97BF

LABEL_97BB:
	sub e
	jr nc, LABEL_97BF
	sub a
LABEL_97BF:
	ld l, a
	jp LABEL_96C5

LABEL_97C3:
	call LABEL_97D7
	jp z, LABEL_9562
	ld a, (ix+1)
	call LABEL_9061
	or c
	ld c, a
	call LABEL_96A6
	jp LABEL_9562

LABEL_97D7:
	ld hl, $CC43
	ld a, (iy+1)
	cp h
	jp nz, LABEL_988D
	ld a, (iy+0)
	cp l
	jp nz, LABEL_988D
	set 6, (ix+0)
	pop af
	jp LABEL_950A

LABEL_97F0:	
	res 5, (ix+0)
	set 7, (ix+0)
	ld a, (ix+17)
	and $07
	srl a
	ld b, a
	inc b
	push bc
	ld hl, DATA_92B1 - $001C
	ld de, $001C
LABEL_9808:	
	add hl, de
	djnz LABEL_9808
	push ix
	pop de
	inc hl
	inc de
	ld bc, $001B
	ldir
	pop bc
	ld hl, DATA_8B2C - 4
	ld de, $0004
LABEL_981C:	
	add hl, de
	djnz LABEL_981C
	push iy
	pop de
	ld bc, $0004
	ldir
	ld (ix+8), $64
	ld a, (ix+23)
	ld (iy+2), a
	ld (ix+2), $70
	ld (ix+26), $01
	ld h, (ix+25)
	ld l, (ix+24)
	ld bc, $0020
	sub a
	call LABEL_AC26
	ld l, (ix+12)
	ld h, (ix+13)
	call LABEL_AD7C
	and a
	jr nz, LABEL_9858
	ld a, (ix+17)
	;call LABEL_AD6F
LABEL_9858:	
	ld l, (ix+10)
	ld h, (ix+11)
	call LABEL_AD7C
	and a
	jr nz, LABEL_986A
	ld a, (ix+18)
	;call LABEL_AD6F
LABEL_986A:	
	ld hl, $C0D1
	ld de, $001C
	ld b, $04
LABEL_9872:	
	bit 5, (hl)
	jp nz, LABEL_9DDB
	add hl, de
	djnz LABEL_9872
	ld hl, $C145
	bit 2, (hl)
	ld a, $06
	jr nz, LABEL_9885
	ld a, $05
LABEL_9885:	
	set 7, a
	call LABEL_BB2C
	jp LABEL_9DDB

LABEL_988D:
	call LABEL_9923
	ld a, (ix+1)
	ld b, a
	call LABEL_9061
	or b
	cpl
	and $0F
	cp c
	ret z
	ld a, b
	call LABEL_9061
	or c
	ld c, a
	ld hl, $CC43
	ld a, (iy+1)
	cp $2C
	jr z, LABEL_98BC
	cp $CC
	jr z, LABEL_98BC
	call LABEL_A350
	bit 0, a
	jp z, LABEL_970B
	jp LABEL_96D9

LABEL_98BC:
	ld a, (iy+0)
	cp $53
	jp z, LABEL_970B
	jp LABEL_96D9

LABEL_98C7:
	call LABEL_9923
	bit 2, (ix+0)
	jr z, LABEL_98E1
	res 2, (ix+0)
	dec (ix+2)
	ld a, (ix+1)
	call LABEL_9061
	ld (ix+1), a
	ret

LABEL_98E1:
	ld a, (ix+1)
	ld b, a
	call LABEL_9061
	ld e, a
	or b
	cpl
	and $0F
	cp c
	ret z
	ld a, e
	or c
	ld c, a
	jp LABEL_96A6

LABEL_98F5:
	ld a, (ix+1)
	dec a
	jr nz, LABEL_9907
	ld a, (iy+0)
	cp $43
	jr nz, LABEL_9917
	res 3, (ix+0)
	ret

LABEL_9907:
	ld a, (ix+2)
	and a
	jr z, LABEL_9911
	dec (ix+2)
	ret

LABEL_9911:
	ld a, (iy+1)
	cp $7C
	ret nz
LABEL_9917:
	ld (ix+1), $01
	pop af
	set 6, (ix+0)
	jp LABEL_94EE

LABEL_9923:
	ld d, (iy+1)
	ld e, (iy+0)
LABEL_9929:
	ld c, $00
	push de
	ld hl, $0800
	call LABEL_995B
	pop de
	jr z, LABEL_9937
	set 0, c
LABEL_9937:
	push de
	ld hl, $1008
	call LABEL_995B
	pop de
	jr z, LABEL_9943
	set 1, c
LABEL_9943:
	push de
	ld hl, $0810
	call LABEL_995B
	pop de
	jr z, LABEL_994F
	set 2, c
LABEL_994F:
	push de
	ld hl, $0008
	call LABEL_995B
	pop de
	ret z
	set 3, c
	ret

LABEL_995B:
	add hl, de
	ex de, hl
	jp LABEL_A51E

LABEL_9960:
	ld iy, $C000
	ld ix, $C0D1
	call LABEL_9989
	ld iy, $C004
	ld ix, $C0ED
	call LABEL_9989
	ld iy, $C008
	ld ix, $C109
	call LABEL_9989
	ld iy, $C00C
	ld ix, $C125
LABEL_9989:
	ld a, (ix+0)
	and $21
	ret nz
	ld a, (ix+16)
	and a
	jp nz, LABEL_9A38
	ld h, (ix+13)
	ld l, (ix+12)
	call LABEL_AD7C
	cp (ix+17)
	jr nz, LABEL_99AE
	ld a, (ix+14)
	inc a
	jr z, LABEL_99AE
	dec a
	call LABEL_AD6F
LABEL_99AE:
	ld l, (ix+10)
	ld h, (ix+11)
	ld (ix+12), l
	ld (ix+13), h
	ld a, (ix+15)
	cp $FF
	jr nz, LABEL_99CE
	call LABEL_AD7C
	ld b, a
	sub $80
	cp $08
	ld a, $FF
	jr c, LABEL_99CE
	ld a, b
LABEL_99CE:
	ld (ix+14), a
	call LABEL_AD7C
	cp a, (ix+18)
	jr z, LABEL_99E6
	ld b, a
	sub $80
	cp $08
	jr nc, LABEL_99E6
	call LABEL_99EC
	jp LABEL_9D37

LABEL_99E6:
	ld a, (ix+17)
	;call LABEL_AD6F
LABEL_99EC:
	call LABEL_9D00
	ld h, (ix+20)
	ld l, (ix+19)
	bit 1, (ix+0)
	jr z, LABEL_9A10
	ld a, $FF
	ld bc, $0008
	call LABEL_AC26
	sub a
	ld bc, $0008
	ld h, (ix+22)
	ld l, (ix+21)
	jp LABEL_AC26

LABEL_9A10:
	sub a
	bit 7, (ix+0)
	jr nz, LABEL_9A1E
	ld a, (iy+2)
	sub $24
	srl a
LABEL_9A1E:
	push hl
	ld e, a
	ld d, $00
	ld hl, DATA_9A30
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	pop hl
	ld bc, $0008
	jp LABEL_AC38

; Pointer Table from 9A30 to 9A37 (4 entries, indexed by $C002)
DATA_9A30:
	.dw DATA_9C86, DATA_9C9C, DATA_9CB2, DATA_9CC8

LABEL_9A38:
	dec a
	jp nz, LABEL_9A99
	ld a, (ix+1)
	ld l, (ix+12)
	ld h, (ix+13)
	call LABEL_9CD7
	ld (ix+10), l
	ld (ix+11), h
	call LABEL_AD7C
	ld c, a
	sub $80
	cp $08
	ld a, c
	jr nc, LABEL_9A8D
	ld a, (ix+17)
	cp c
	ld a, $FF
	jr nc, LABEL_9A8D
	ld a, c
	and $06
	push hl
	push ix
	ld hl, DATA_9E67
	ld e, a
	ld d, $00
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	push de
	pop ix
	ld a, (ix+17)
	cp c
	jr z, LABEL_9A83
	ld a, (ix+15)
	ld (ix+15), $FF
	jr LABEL_9A8A

LABEL_9A83:
	ld a, (ix+14)
	ld (ix+14), $FF
LABEL_9A8A:
	pop ix
	pop hl
LABEL_9A8D:
	ld (ix+15), a
	inc a
	jr z, LABEL_9A99
	ld a, (ix+18)
	;call LABEL_AD6F
LABEL_9A99:
	ld a, (ix+15)
	cp $FF
	jr nz, LABEL_9ABE
	ld h, (ix+11)
	ld l, (ix+10)
	call LABEL_AD7C
	ld b, a
	sub $80
	cp $08
	jr nc, LABEL_9AB5
	call LABEL_9D1A
	jr LABEL_9ABE

LABEL_9AB5:
	ld (ix+15), b
	ld a, (ix+18)
	;call LABEL_AD6F
LABEL_9ABE:
	ld a, (ix+14)
	inc a
	jr nz, LABEL_9AE2
	ld h, (ix+13)
	ld l, (ix+12)
	call LABEL_AD7C
	ld b, a
	sub $80
	cp $08
	jr nc, LABEL_9AD9
	call LABEL_9D37
	jr LABEL_9AE2

LABEL_9AD9:
	ld (ix+14), b
	ld a, (ix+17)
	;call LABEL_AD6F
LABEL_9AE2:
	call LABEL_9D00
	ld c, (ix+1)
	ld a, (ix+16)
	bit 1, (ix+0)
	jp nz, LABEL_9B25
	bit 0, c
	jr z, LABEL_9B01
LABEL_9AF6:
	dec a
	ld d, $00
	ld e, a
	call LABEL_9C3D
	add hl, de
	jp LABEL_9C08

LABEL_9B01:
	bit 2, c
	jr z, LABEL_9B0B
	neg
	and $07
	jr LABEL_9AF6

LABEL_9B0B:
	bit 1, c
	jr z, LABEL_9B1F
LABEL_9B0F:
	call LABEL_9C63
	dec a
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jp LABEL_9C08

LABEL_9B1F:
	neg
	and $07
	jr LABEL_9B0F

LABEL_9B25:
	bit 3, c
	jr z, LABEL_9B53
	neg
	and $07
	ld hl, DATA_9BB8
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ex de, hl
	ld h, (ix+22)
	ld l, (ix+21)
	ld bc, $0008
	push de
	call LABEL_AC26
	pop de
	inc de
	ld a, (de)
	ld h, (ix+20)
	ld l, (ix+19)
	ld bc, $0008
	jp LABEL_AC26

LABEL_9B53:
	bit 1, c
	jr z, LABEL_9B7D
	ld hl, DATA_9BB8
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ex de, hl
	ld h, (ix+20)
	ld l, (ix+19)
	ld bc, $0008
	push de
	call LABEL_AC26
	pop de
	inc de
	ld a, (de)
	ld h, (ix+22)
	ld l, (ix+21)
	ld bc, $0008
	jp LABEL_AC26

LABEL_9B7D:
	bit 0, c
	jr z, LABEL_9B9F
	neg
	and $07
	ld h, (ix+22)
	ld l, (ix+21)
	push af
	add a, l
	ld l, a
	ld a, $FF
	call LABEL_AD6F
	ld de, $FFF8
	add hl, de
	pop af
LABEL_9B98:
	ld c, a
	ld b, $00
	sub a
	jp LABEL_AC26

LABEL_9B9F:
	dec a
	ld h, (ix+20)
	ld l, (ix+19)
	push af
	push hl
	add a, l
	ld l, a
	ld de, $0008
	add hl, de
	ld a, $FF
	call LABEL_AD6F
	pop hl
	pop af
	inc a
	jr LABEL_9B98

; Data from 9BB8 to 9BC7 (16 bytes)
DATA_9BB8:
	.db $00, $00, $7F, $80, $3F, $C0, $1F, $E0, $0F, $F0, $07, $F8, $03, $FC, $01, $FE

; Pointer Table from 9BC8 to 9BCF (4 entries, indexed by $C002)
DATA_9BC8:
	.dw DATA_9BD0, DATA_9BDE, DATA_9BEC, DATA_9BFA

; 1st entry of Pointer Table from 9BC8 (indexed by $C002)
; Pointer Table from 9BD0 to 9BDD (7 entries, indexed by $C0E1)
DATA_9BD0:
	.dw DATA_ADB1, DATA_ADC1, DATA_ADD1, DATA_ADE1, DATA_ADF1, DATA_AE01, DATA_AE11

; 2nd entry of Pointer Table from 9BC8 (indexed by $C002)
; Pointer Table from 9BDE to 9BEB (7 entries, indexed by $C0E1)
DATA_9BDE:
	.dw DATA_AE21, DATA_AE31, DATA_AE41, DATA_AE51, DATA_AE61, DATA_AE71, DATA_AE81

; 3rd entry of Pointer Table from 9BC8 (indexed by $C002)
; Pointer Table from 9BEC to 9BF9 (7 entries, indexed by $C0E1)
DATA_9BEC:
	.dw DATA_AE91, DATA_AEA1, DATA_AEB1, DATA_AEC1, DATA_AED1, DATA_AEE1, DATA_AEF1

; 4th entry of Pointer Table from 9BC8 (indexed by $C002)
; Pointer Table from 9BFA to 9C07 (7 entries, indexed by $C0E1)
DATA_9BFA:
	.dw DATA_AF01, DATA_AF11, DATA_AF21, DATA_AF31, DATA_AF41, DATA_AF51, DATA_AF61

LABEL_9C08:
	bit 2, (ix+1)
	jr nz, LABEL_9C30
	bit 1, (ix+1)
	jr nz, LABEL_9C30
	ld e, (ix+21)
	ld d, (ix+22)
	ex de, hl
	ld bc, $0008
	push de
	push bc
	call LABEL_AC38
	pop bc
	pop hl
	add hl, bc
	ld e, (ix+19)
	ld d, (ix+20)
	ex de, hl
	jp LABEL_AC38

LABEL_9C30:
	ld e, (ix+19)
	ld d, (ix+20)
	ex de, hl
	ld bc, $0010
	jp LABEL_AC38

LABEL_9C3D:
	push de
	push af
	sub a
	bit 7, (ix+0)
	jr nz, LABEL_9C4D
	ld a, (iy+2)
	sub $24
	srl a
LABEL_9C4D:
	ld e, a
	ld d, $00
	ld hl, DATA_9C5B
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	pop af
	pop de
	ret

; Pointer Table from 9C5B to 9C62 (4 entries, indexed by $C002)
DATA_9C5B:
	.dw DATA_9C7F, DATA_9C95, DATA_9CAB, DATA_9CC1

LABEL_9C63:
	push af
	sub a
	bit 7, (ix+0)
	jr nz, LABEL_9C72
	ld a, (iy+2)
	sub $24
	srl a
LABEL_9C72:
	ld e, a
	ld d, $00
	ld hl, DATA_9BC8
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	pop af
	ret

; 1st entry of Pointer Table from 9C5B (indexed by $C002)
; Data from 9C7F to 9C85 (7 bytes)
DATA_9C7F:
	.db $00, $00, $00, $00, $00, $00, $00

; 1st entry of Pointer Table from 9A30 (indexed by $C002)
; Data from 9C86 to 9C94 (15 bytes)
DATA_9C86:
	.db $81, $81, $E7, $C3, $81
	.fill 10, $00

; 2nd entry of Pointer Table from 9C5B (indexed by $C002)
; Data from 9C95 to 9C9B (7 bytes)
DATA_9C95:
	.db $00, $00, $00, $00, $00, $00, $00

; 2nd entry of Pointer Table from 9A30 (indexed by $C002)
; Data from 9C9C to 9CAA (15 bytes)
DATA_9C9C:
	.db $00, $00, $00, $81, $C3, $E7, $81, $81, $00, $00, $00, $00, $00, $00, $00

; 3rd entry of Pointer Table from 9C5B (indexed by $C002)
; Data from 9CAB to 9CB1 (7 bytes)
DATA_9CAB:
	.db $00, $00, $00, $00, $00, $00, $00

; 3rd entry of Pointer Table from 9A30 (indexed by $C002)
; Data from 9CB2 to 9CC0 (15 bytes)
DATA_9CB2:
	.db $00, $77, $77, $44, $44, $77
	.fill 9, $00

; 4th entry of Pointer Table from 9C5B (indexed by $C002)
; Data from 9CC1 to 9CC7 (7 bytes)
DATA_9CC1:
	.db $00, $00, $00, $00, $00, $00, $00

; 4th entry of Pointer Table from 9A30 (indexed by $C002)
; Data from 9CC8 to 9CD6 (15 bytes)
DATA_9CC8:
	.db $00, $EE, $EE, $22, $22, $EE
	.fill 9, $00

LABEL_9CD7:
	ld de, $FFE0
	bit 0, a
	jr nz, LABEL_9CFE
	ld de, $0020
	bit 2, a
	jr nz, LABEL_9CFE
	ld de, $FFFF
	bit 3, a
	jr nz, LABEL_9CEF
	ld de, $0001
LABEL_9CEF:
	add hl, de
	ld a, l
	cp $5F
	jr z, LABEL_9CFB
	cp $80
	ret nz
	ld l, $60
	ret

LABEL_9CFB:
	ld l, $7F
	ret

LABEL_9CFE:
	add hl, de
	ret

LABEL_9D00:
	ld a, (iy+1)
	bit 7, a
	ret z
	neg
	cp $0A
	ret nc
	pop af
LABEL_9D0C:
	sub a
	ld h, (ix+20)
	ld l, (ix+19)
	ld bc, $0010
	call LABEL_AC26
	ret

LABEL_9D1A:
	ld hl, ($C153)
	ld c, (ix+21)
	ld b, (ix+22)
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld c, (ix+10)
	ld b, (ix+11)
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld (hl), $FF
	ld ($C153), hl
	ret

LABEL_9D37:
	ld hl, ($C153)
	ld c, (ix+19)
	ld b, (ix+20)
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld c, (ix+12)
	ld b, (ix+13)
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld (hl), $FF
	ld ($C153), hl
	ret

LABEL_9D54:
	ld hl, $C155
LABEL_9D57:
	ld a, (hl)
	inc a
	ret z
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ex de, hl
	call LABEL_AD7C
	ld l, a
	sub $80
	cp $08
	jr nc, LABEL_9D91
	ld h, $00
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	push bc
	pop de
	ld b, $08
LABEL_9D80:
	call LABEL_AD7C
	ld c, a
	ex de, hl
	call LABEL_AD7C
	ex de, hl
	or c
	call LABEL_AD6F
	inc hl
	inc de
	djnz LABEL_9D80
LABEL_9D91:
	pop hl
	jr LABEL_9D57

LABEL_9D94:
	bit 6, (ix+0)
	ret nz
	bit 5, (ix+0)
	ret nz
	call LABEL_9923
	ld a, ($C010)
	cp (iy+0)
	jr nc, LABEL_9DB1
	bit 2, c
	ret nz
	ld (ix+1), $04
	ret

LABEL_9DB1:
	bit 0, c
	ret nz
	ld (ix+1), $01
	ret

LABEL_9DB9:
	bit 1, (ix+0)
	ret nz
	bit 5, (ix+0)
	ret nz
	ld a, (ix+1)
	ld hl, DATA_9E63
	dec hl
LABEL_9DCA:
	inc hl
	rrca
	jr nc, LABEL_9DCA
	ld a, (hl)
	ld (iy+2), a
	ld a, (ix+8)
	neg
	ld (ix+9), a
	ret

LABEL_9DDB:
	dec (ix+2)
	jr nz, LABEL_9E02
	res 7, (ix+0)
	set 3, (ix+0)
	ld a, ($C18F)
	ld b, a
	ld a, (ix+3)
	cp $06
	jr nz, LABEL_9DF6
; Data from 9DF3 to 9DF5 (3 bytes)
	.db $04, $04, $04

LABEL_9DF6:
	ld (ix+8), b
	ld a, (ix+6)
	ld (iy+2), a
	jp LABEL_94AE

LABEL_9E02:
	ld a, (ix+2)
	and $07
	jr nz, LABEL_9E0C
	inc (ix+26)
LABEL_9E0C:
	ld c, (ix+26)
	ld b, $00
	ld de, DATA_B9DD
	ld h, (ix+25)
	ld l, (ix+24)
	push hl
	push de
	push bc
	ld b, c
LABEL_9E1E:
	push bc
	ld a, (de)
	call LABEL_AD6F
	push hl
	push de
	ld bc, $0010
	add hl, bc
	ex de, hl
	add hl, bc
	ex de, hl
	ld a, (de)
	call LABEL_AD6F
	pop de
	pop hl
	inc hl
	inc de
	pop bc
	djnz LABEL_9E1E
	pop bc
	pop hl
	add hl, bc
	ex de, hl
	pop hl
	add hl, bc
	ld b, $03
LABEL_9E3F:
	push bc
	call LABEL_A350
	ld c, a
	ld a, (de)
	and c
	call LABEL_AD6F
	push hl
	push de
	ld bc, $0010
	add hl, bc
	ex de, hl
	add hl, bc
	ex de, hl
	call LABEL_A350
	ld c, a
	ld a, (de)
	and c
	call LABEL_AD6F
	pop de
	pop hl
	inc hl
	inc de
	pop bc
	djnz LABEL_9E3F
	ret

; Data from 9E63 to 9E66 (4 bytes)
DATA_9E63:
	.db $24, $2C, $28, $30

; Data from 9E67 to 9E6E (8 bytes)
DATA_9E67:
	.db $D1, $C0, $ED, $C0, $09, $C1, $25, $C1

LABEL_9E6F:
	call LABEL_A127
	call LABEL_A55F
	ld a, $E0
	ld hl, $2010
	call LABEL_AD6F
	ld hl, DATA_A3D4
	ld de, $C0D1
	ld bc, $001C
	ldir
	ld hl, DATA_A3B3
	ld de, $C000
	ld bc, $0021
	ldir
	ld a, $D0
	ld ($C014), a
	ld a, $08
	ld ($C0BC), a
	ld a, $78
	ld ($C0D9), a
	ld a, $6E
	ld ($C14A), a
	sub a
	ld ($C1A9), a
LABEL_9EAB:
	ld a, $0C
	call LABEL_BB2C
	ld a, $0D
	jp LABEL_BB2C

LABEL_9EB5:
	push bc
	call LABEL_9EBD
	pop bc
	djnz LABEL_9EB5
	ret

LABEL_9EBD:
	ld hl, ($C1AC)
	ld a, l
	or h
	jp nz, LABEL_A978
	ld a, ($C1A9)
	and a
	jp nz, LABEL_A978
	ld a, $7D
	ld ($C1A9), a
	call LABEL_9EAB
	jp LABEL_A978

LABEL_9ED7:
	push bc
	call LABEL_9EBD
	call LABEL_9FCF
	call LABEL_AA48
	call LABEL_A053
	pop bc
	djnz LABEL_9ED7
	ret

LABEL_9EE8:
	push bc
	call LABEL_9EBD
	call LABEL_9FCF
	call LABEL_A01A
	call LABEL_A053
	call LABEL_AA48
	call LABEL_A00F
	pop bc
	djnz LABEL_9EE8
	ret

LABEL_9EFF:	
	push bc
	call LABEL_9EBD
	call LABEL_9FF0
	call LABEL_A01A
	call LABEL_A053
	call LABEL_AA48
	pop bc
	djnz LABEL_9EFF
	ret

LABEL_9F13:
	call LABEL_9E6F
	ld b, $28
	call LABEL_9EB5
	ld hl, DATA_B20B
	ld ($C1A7), hl
	sub a
	ld ($C1A6), a
	ld b, $1E
	call LABEL_9ED7
	ld b, $FF
	call LABEL_9EE8
	ld a, $58
	ld ($C0D9), a
	ld a, $78
	ld ($C14A), a
	ld a, $04
	ld ($C003), a
	ld a, $34
	ld ($C002), a
	ld a, $02
	ld ($C0D2), a
	ld hl, $C0D1
	set 1, (hl)
	ld a, (ix+14)
	ld b, (ix+15)
	ld (ix+14), b
	ld (ix+15), a
	ld l, (ix+10)
	ld h, (ix+11)
	sub a
	call LABEL_AD6F
	ld h, (ix+13)
	ld l, (ix+12)
	sub a
	call LABEL_AD6F
	ld hl, $39C0
	ld de, DATA_B73D
	ld bc, $0180
	call LABEL_AC38
	ld a, $01
	ld ($C083), a
	sub a
	ld ($C013), a
	ld bc, $015E
LABEL_9F85:
	push bc
	push bc
	call LABEL_9EBD
	pop bc
	ld a, b
	and a
	jr nz, LABEL_9FAD
	ld a, c
	cp $FA
	jr nz, LABEL_9FAD
	ld a, $0A
	ld ($C013), a
	ld hl, DATA_A3C3
	ld de, $C010
	ld bc, $0011
	ldir
	ld hl, $C010
	ld (hl), $4C
	inc hl
	ld (hl), $FF
	scf
LABEL_9FAD:
	call c, LABEL_A091
	call LABEL_A05D
	call LABEL_A0CA
	call LABEL_AA48
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, LABEL_9F85
	ld b, $3C
	call LABEL_9EB5
	ld hl, $C0CC
	bit 7, (hl)
	ret z
	res 7, (hl)
	jp LABEL_A9DD

LABEL_9FCF:
	call LABEL_A13B
	ret c
	sub b
	ld (hl), a
LABEL_9FD5:
	ld a, ($C011)
	cp $FF
	jp z, LABEL_9D0C
	dec a
	ld ($C011), a
	ld a, ($C14B)
	ld b, a
	ld a, ($C14C)
	cp b
	ret c
	sub b
	ld ($C14C), a
	jr LABEL_9FD5

LABEL_9FF0:	
	call LABEL_A13B
	ret c
	sub b
	ld (hl), a
LABEL_9FF6:	
	ld a, ($C011)
	cp $FF
	ret z
	dec a
	ld ($C011), a
	ld a, ($C14B)
	ld b, a
	ld a, ($C14C)
	cp b
	ret c
	sub b
	ld ($C14C), a
	jr LABEL_9FF6

LABEL_A00F:
	ld hl, DATA_8A95
	ld a, (hl)
	ld c, a
	ld a, ($C0CC)
	jp LABEL_AA00

LABEL_A01A:
	ld iy, $C000
	ld ix, $C0D1
	call LABEL_A149
	ret c
	sub b
	ld (ix+9), a
LABEL_A02A:
	ld a, ($C001)
	cp $FF
	ret z
	dec a
	ld ($C001), a
	ld a, (ix+16)
	inc a
	and $07
	ld (ix+16), a
	ld a, (iy+1)
	cp $FB
	call c, LABEL_A11C
	ld b, (ix+7)
	ld a, (ix+9)
	cp b
	ret c
	sub b
	ld (ix+9), a
	jr LABEL_A02A

LABEL_A053:
	ld hl, $C187
	inc (hl)
	call LABEL_93BD
	jp LABEL_8D96

LABEL_A05D:
	ld hl, $C187
	inc (hl)
	call LABEL_93BD
	ld a, ($C083)
	dec a
	ld ($C083), a
	ret nz
	ld a, $04
	ld ($C083), a
	ld a, ($C0BF)
	inc a
	and $03
	ld ($C0BF), a
	ld hl, DATA_A3F0
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld hl, $C012
	ld de, $0004
	ld b, $04
LABEL_A08A:
	ld (hl), a
	add a, $04
	add hl, de
	djnz LABEL_A08A
	ret

LABEL_A091:
	call LABEL_A13B
	ret c
	sub b
	ld (hl), a
LABEL_A097:
	ld hl, $C011
	ld a, (hl)
	cp $FE
	jr nz, LABEL_A0A7
	sub a
	ld ($C013), a
	ld ($C017), a
	ret

LABEL_A0A7:
	cp $EF
	jr nz, LABEL_A0B2
	sub a
	ld ($C01B), a
	ld ($C01F), a
LABEL_A0B2:
	ld b, $04
	ld de, $0004
LABEL_A0B7:
	inc (hl)
	add hl, de
	djnz LABEL_A0B7
	ld a, ($C14B)
	ld b, a
	ld a, ($C14C)
	cp b
	ret c
	sub b
	ld ($C14C), a
	jr LABEL_A097

LABEL_A0CA:
	ld iy, $C000
	ld ix, $C0D1
	call LABEL_A149
	ret c
	sub b
	ld (ix+9), a
LABEL_A0DA:
	ld a, ($C001)
	cp $FE
	ret z
	inc a
	ld ($C001), a
	ld a, (ix+16)
	inc a
	and $07
	ld (ix+16), a
	ld a, (iy+1)
	cp $04
	jr c, LABEL_A10E
	jr nz, LABEL_A103
	ld (ix+16), $00
	ld hl, $1961
	ld (ix+11), h
	ld (ix+10), l
LABEL_A103:
	ld hl, $C155
	ld (hl), $FF
	ld ($C153), hl
	call LABEL_9989
LABEL_A10E:
	ld b, (ix+7)
	ld a, (ix+9)
	cp b
	ret c
	sub b
	ld (ix+9), a
	jr LABEL_A0DA

LABEL_A11C:
	ld hl, $C155
	ld (hl), $FF
	ld ($C153), hl
	jp LABEL_9989

LABEL_A127:
	di
	ld hl, $1800
	ld bc, $0300
	sub a
	call LABEL_AC26
	sub a
	ld hl, $1B00
	ld bc, $0020
	call LABEL_AC26
	ld a, 1
	ld (DrawTilemapTrig), a
	ei
	ret

LABEL_A13B:
	ld a, ($C14B)
	ld b, a
	ld a, ($C14A)
	ld hl, $C14C
	add a, (hl)
	ld (hl), a
	cp b
	ret

LABEL_A149:
	ld b, (ix+7)
	ld a, (ix+8)
	add a, (ix+9)
	ld (ix+9), a
	cp b
	ret

LABEL_A157:	
	call LABEL_9E6F
	ld a, $03
	ld hl, $1970
	call LABEL_AD6F
	ld b, $50
	call LABEL_9EB5
	ld b, $80
	call LABEL_9ED7
	ld b, $6E
	call LABEL_9EFF
	ld hl, $39C0
	ld de, DATA_A3A4
	call LABEL_A343
	ld hl, $C014
	ld (hl), $59
	inc hl
	ld (hl), $7E
	inc hl
	ld (hl), $38
	inc hl
	ld (hl), $06
	inc hl
	ld (hl), $D0
	sub a
	ld ($C0DF), a
	ld a, $0A
	ld ($C0D9), a
	ld b, $28
	call LABEL_9EFF
	ld hl, $39C2
	push hl
	ld a, $80
	call LABEL_AD6F
	pop hl
	inc hl
	ld a, $C0
	call LABEL_AD6F
	ld b, $30
	call LABEL_9EFF
	ld b, $14
	call LABEL_9EB5
	ld b, $05
LABEL_A1B5:	
	push bc
	ld hl, $C001
	dec (hl)
	ld a, (ix+16)
	inc a
	and $07
	ld (ix+16), a
	call LABEL_AA48
	call LABEL_A11C
	pop bc
	djnz LABEL_A1B5
	ld hl, $39C0
	ld de, DATA_A38D
	call LABEL_A343
	call LABEL_A22E
	ld hl, $39E0
	ld de, DATA_A383
	call LABEL_A30F
	ld hl, $C000
	ld de, $C018
	ld bc, $0004
	ldir
	ld a, $D0
	ld (de), a
	dec de
	ld a, $0B
	ld (de), a
	dec de
	ld a, $3C
	ld (de), a
	call LABEL_AA48
	ld iy, $C000
	ld ix, $C0D1
	ld b, $28
	call LABEL_9EB5
	ld a, $01
	ld b, $48
	call LABEL_A21A
	ld a, $02
	ld b, $A0
	call LABEL_A21A
	ld b, $46
	jp LABEL_9EB5
	
LABEL_A21A:	
	push bc
	ld ($C0D2), a
	call LABEL_9DB9
	call LABEL_A22E
	call LABEL_AA48
	call LABEL_A11C
	pop bc
	jp LABEL_9EB5
	
LABEL_A22E:	
	ld l, (iy+2)
	ld h, $00
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	ld de, $3818
	add hl, de
	ld de, DATA_A39C
	ld b, $08
LABEL_A248:	
	call LABEL_AD7C
	ld c, a
	ld a, (de)
	cpl
	and c
	call LABEL_AD6F
	inc hl
	inc de
	djnz LABEL_A248
	ret
	
LABEL_A257:	
	call LABEL_9E6F
	ld b, $40
	call LABEL_9EB5
	ld hl, $39C0
	ld de, DATA_A3F4
	call LABEL_A30F
	ld hl, $C000
	ld de, $C004
	ld bc, $0004
	ldir
	ld hl, $C002
	ld (hl), $38
	inc hl
	ld (hl), $0F
	ld b, $32
	call LABEL_9ED7
	ld b, $FF
	call LABEL_A2EB
	ld hl, DATA_A372
	ld de, $C000
	ld bc, $0011
	ldir
	ld hl, $39C0
	ld de, DATA_A3FE
	call LABEL_A30F
	ld b, $00
LABEL_A29B:	
	push bc
	call LABEL_9EBD
	call LABEL_A2AE
	call LABEL_AA48
	pop bc
	djnz LABEL_A29B
	ld b, $5A
	call LABEL_9EB5
	ret
	
LABEL_A2AE:	
	ld a, ($C001)
	cp $FE
	ret z
	inc a
	ld ($C001), a
	ld ($C005), a
	ld ($C009), a
	ld ($C00D), a
	ld a, ($C083)
	dec a
	ld ($C083), a
	ret nz
	ld a, $09
	ld ($C083), a
	ld hl, $C002
	ld a, (hl)
	cp $38
	ld de, $0004
	ld b, $04
	jr nz, LABEL_A2E3
LABEL_A2DB:	
	ld a, (hl)
	add a, $10
	ld (hl), a
	add hl, de
	djnz LABEL_A2DB
	ret
	
LABEL_A2E3:	
	ld a, (hl)
	sub $10
	ld (hl), a
	add hl, de
	djnz LABEL_A2E3
	ret
	
LABEL_A2EB:	
	push bc
	ld b, $01
	ld iy, $C000
	ld (iy+2), $30
	call LABEL_9EE8
	ld (iy+2), $38
	ld hl, $C000
	ld de, $C004
	ld bc, $0002
	ldir
	call LABEL_AA48
	pop bc
	djnz LABEL_A2EB
	ret
	
LABEL_A30F:	
	call LABEL_A321
	push hl
	ld hl, $0020
	and a
	sbc hl, bc
	push hl
	pop bc
	pop hl
	call LABEL_A334
	jr LABEL_A30F

LABEL_A321:
	ld a, (de)
	and a
	jr nz, LABEL_A327
	pop af
	ret

LABEL_A327:
	ld c, a
	ld b, $00
	sub a
	push de
	push bc
	call LABEL_AC26
	pop bc
	pop de
	add hl, bc
	ret

LABEL_A334:
	inc de
	push bc
	call LABEL_AC38
	ex de, hl
	pop bc
	add hl, bc
	ret

LABEL_A33D:
	ld hl, $39C0
	ld de, DATA_BA7D
LABEL_A343:
	call LABEL_A321
	inc de
	ld a, (de)
	ld c, a
	ld b, $00
	call LABEL_A334
	jr LABEL_A343

LABEL_A350:
	push hl
	push de
	ld hl, ($C084)
	ld a, (hl)
	ld a, ($C080)
	add a, l
	ld a, r
	add a, h
	ld hl, $C010
	add a, (hl)
	inc hl
	add a, (hl)
	ld e, a
	ld hl, $C000
	add a, (hl)
	inc hl
	add a, (hl)
	ld d, a
	ex de, hl
	ld ($C084), hl
	pop de
	pop hl
	ret

; Data from A372 to A382 (17 bytes)	
DATA_A372:	
	.db $53, $FF, $38, $06, $53, $FF, $3C, $0B, $53, $FF, $40, $0F, $53, $FF, $44, $04
	.db $D0
	
; Data from A383 to A38C (10 bytes)	
DATA_A383:	
	.db $18, $04, $0C, $18, $30, $36, $3E, $00, $00, $00
	
; Data from A38D to A39B (15 bytes)	
DATA_A38D:	
	.db $05, $03, $03, $07, $0F, $0C, $04, $80, $80, $80, $80, $07, $01, $00, $00
	
; Data from A39C to A3A3 (8 bytes)	
DATA_A39C:	
	.db $04, $0C, $1C, $3C, $3C, $7C, $00, $00
	
; Data from A3A4 to A3B2 (15 bytes)	
DATA_A3A4:	
	.db $04, $04, $F0, $FF, $FF, $FF, $0D, $03, $80, $80, $80, $07, $01, $00, $00
	
; Data from A3B3 to A3C2 (16 bytes)
DATA_A3B3:
	.db $53, $FE, $30, $06
	.fill 12, $00

; Data from A3C3 to A3D3 (17 bytes)
DATA_A3C3:
	.db $53, $FE, $00, $0A, $5C, $FF, $00, $0A, $4C, $0F, $00, $0A, $5C, $0F, $00, $0A
	.db $D0

; Data from A3D4 to A452 (127 bytes)
DATA_A3D4:	
	.db $00, $08, $00, $00, $00, $00, $00, $64, $50, $5A, $7F, $19, $7F, $19, $00, $00
	.db $06, $80, $81, $00, $04, $08, $04, $00, $00, $00, $00, $00
	
; Data from A3F0 to A3F3 (4 bytes)	
DATA_A3F0:	
	.db $38, $48, $58, $48
	
; Data from A3F4 to A3FD (10 bytes)	
DATA_A3F4:	
	.db $18, $04, $0C, $10, $20, $20, $60, $00, $00, $00
	
; Data from A3FE to A452 (85 bytes)	
DATA_A3FE:	
	.db $0D, $20, $61, $FF
	.fill 14, $00
	.db $80, $80, $1B, $10, $32, $FF, $7F, $03, $19, $0F, $0A, $0A, $0D, $00, $00, $00
	.db $1A, $05, $05, $00, $00, $00, $00, $0D, $19, $3F, $7F
	.fill 13, $00
	.db $80, $C0, $E0, $1B, $62, $FC, $7C, $3C, $04, $18, $1E, $14, $14, $1A, $00, $00
	.db $00, $00, $19, $0A, $0A, $00, $00, $00, $00, $00, $00

LABEL_A453:
	push hl
	ld.lil hl, SegaVRAM
	add.lil hl, bc
	ld.lil (hl), a
	pop hl
	ret

LABEL_A460:
	ld hl, $C0CC
	bit 0, (hl)
	jr nz, LABEL_A476
	ld de, $C0C5
	ld hl, $1822
	call LABEL_A485
	ld hl, $C0C3
	jp LABEL_A4E4

LABEL_A476:
	ld de, $C0C8
	ld hl, $1837
	call LABEL_A485
	ld hl, $C0C6
	jp LABEL_A4E4

LABEL_A485:
	ld a, (de)
	add a, c
	daa
	ld (de), a
	ld ($C0CB), a
	dec de
	ld a, (de)
	adc a, b
	daa
	ld (de), a
	ld ($C0CA), a
	dec de
	ld a, (de)
	adc a, $00
	daa
	ld (de), a
	ld ($C0C9), a
	push hl
	pop bc
LABEL_A49F:
	ld hl, $C0C9
	ld e, $00
	exx
	ld b, $03
LABEL_A4A7:
	exx
	sub a
	rld
	and a
	jr nz, LABEL_A4BA
	bit 0, e
	jr nz, LABEL_A4BA
	ld a, $00
	call LABEL_A453
	sub a
	jr LABEL_A4BF

LABEL_A4BA:
	set 0, e
	call LABEL_ADAC
LABEL_A4BF:
	inc bc
	rld
	and $0F
	jr nz, LABEL_A4D1
	bit 0, e
	jr nz, LABEL_A4D1
	ld a, $00
	call LABEL_A453
	jr LABEL_A4D6

LABEL_A4D1:
	set 0, e
	call LABEL_ADAC
LABEL_A4D6:
	inc bc
	inc hl
	exx
	djnz LABEL_A4A7
	exx
	dec bc
	cp $00
	ret nz
	sub a
	jp LABEL_ADAC

LABEL_A4E4:
	ld a, ($C0C0)
	ld b, a
	ld a, (hl)
	cp b
	jr z, LABEL_A4F0
	ret c
	jp LABEL_A504

LABEL_A4F0:
	inc hl
	ld b, (hl)
	inc hl
	ld c, (hl)
	ex de, hl
	ld a, ($C0C1)
	ld h, a
	ld a, ($C0C2)
	ld l, a
	sub a
	sbc hl, bc
	ret nc
	ex de, hl
	dec hl
	dec hl
LABEL_A504:
	ld de, $C0C0
	ld bc, $0003
	ldir
LABEL_A50C:
	ld hl, $C0C0
	ld de, $C0C9
	ld bc, $0003
	ldir
	ld bc, ($C0CF)
	jp LABEL_A49F

LABEL_A51E:
	call LABEL_AD89
	push hl
	push de
	ld de, $1950
	and a
	sbc hl, de
	pop de
	pop hl
	jr z, LABEL_A536
	sub $90
	cp $1E
	ld a, e
	jr c, LABEL_A536
	cp e
	ret

LABEL_A536:
	inc e
	cp e
	ret

LABEL_A539:
	ld a, (de)
	inc de
	cp $FF
	ret z
	cp $11
	jr nz, LABEL_A548
	ld bc, $0020
	add hl, bc
	jr LABEL_A539

LABEL_A548:
	bit 7, a
	jr z, LABEL_A556
	and $1F
	ld b, a
	ld a, l
	and $E0
	or b
	ld l, a
	jr LABEL_A539

LABEL_A556:
	call LABEL_AD6F
	inc hl
	jr LABEL_A539

LABEL_A55C:
	call LABEL_A582
LABEL_A55F:
	ld a, ($C0CD)
	ld hl, $C0CC
	bit 0, (hl)
	jr z, LABEL_A56C
	ld a, ($C0CE)
LABEL_A56C:
	ld b, a
	ld de, DATA_AC4B
	ld hl, $1AFE
LABEL_A573:
	ld a, (de)
	call LABEL_AD6F
	dec hl
	push hl
	ld hl, $0008
	add hl, de
	ex de, hl
	pop hl
	djnz LABEL_A573
	ret

LABEL_A582:
	ld hl, $1AE1
	ld a, ($C0CC)
	bit 0, a
	ld a, ($C141)
	jr z, LABEL_A592
	ld a, ($C142)
LABEL_A592:
	ld b, a
	and a
	ret z
LABEL_A595:
	ld a, $21
	inc hl
	call LABEL_AD6F
	djnz LABEL_A595
	ret

LABEL_A59E:
	ld l, (ix+12)
	ld h, (ix+13)
	call LABEL_AD7C
	cp (ix+17)
	jr nz, LABEL_A5B2
	ld a, (ix+14)
	call LABEL_AD6F
LABEL_A5B2:
	ld l, (ix+10)
	ld h, (ix+11)
	call LABEL_AD7C
	cp (ix+18)
	ret nz
	ld a, (ix+15)
	call LABEL_AD6F
	ret

LABEL_A5C6:
	bit 1, (ix+0)
	jp z, LABEL_A659
LABEL_A5CD:
	ld a, $01
	call LABEL_BB2C
	call LABEL_A59E
	sub a
	ld (ix+14), a
	ld (ix+15), a
	res 1, (ix+0)
	ld a, ($C146)
	inc a
	cp $05
	jr nz, LABEL_A5EA
	ld a, $01
LABEL_A5EA:
	ld ($C146), a
	dec a
	ld hl, DATA_A78B
	add a, a
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld c, (hl)
	inc hl
	ld b, (hl)
	push hl
	call LABEL_A460
	pop hl
	inc hl
	ld a, (hl)
	ld (iy+2), a
	ld (iy+3), $0F
	ld a, (iy+1)
	and $F8
	or $04
	ld (iy+1), a
	ld a, (iy+0)
	and $F8
	or $03
	ld (iy+0), a
	ld hl, $C0D1
	ld de, $001C
	ld b, $04
LABEL_A624:
	bit 1, (hl)
	jr nz, LABEL_A62F
	add hl, de
	djnz LABEL_A624
	sub a
	ld ($C146), a
LABEL_A62F:
	sub a
	ld ($C013), a
	call LABEL_AA48
	ld b, $14
	call LABEL_A7FC
	set 5, (ix+0)
	ld (ix+8), $C8
	ld (iy+2), $58
	ld (ix+27), $00
	ld (iy+3), $0E
	ld a, $0A
	ld ($C013), a
	ld a, $08
	jp LABEL_BB2C

LABEL_A659:
	push iy
	push ix
	call LABEL_906D
	pop ix
	pop iy
	bit 1, (ix+0)
	jp nz, LABEL_A5CD
	call LABEL_A6F9
	ld a, ($C0CC)
	bit 0, a
	ld hl, $C141
	jr z, LABEL_A67B
	ld hl, $C142
LABEL_A67B:	
	ld a, (hl)
	and a
	jp z, LABEL_A7A5
	dec (hl)
	call LABEL_A804
	ld a, ($C0CC)
	bit 1, a
	jr z, LABEL_A6AC
	bit 0, a
	jr nz, LABEL_A69A
	bit 5, a
	jr nz, LABEL_A69E
LABEL_A693:	
	xor $01
	ld ($C0CC), a
	jr LABEL_A69E
	
LABEL_A69A:	
	bit 4, a
	jr z, LABEL_A693
LABEL_A69E:	
	ld hl, $C0CD
	bit 0, a
	jr z, LABEL_A6A8
	ld hl, $C0CE
LABEL_A6A8:	
	dec (hl)
	call LABEL_ACC3
LABEL_A6AC:	
	call LABEL_8B5F
	call LABEL_8A86
	ld hl, $C0CC
	bit 0, (hl)
	ld a, ($C0BD)
	jr z, LABEL_A6BF
	ld a, ($C0BE)
LABEL_A6BF:	
	cp $D6
	call z, LABEL_8A72
	ld bc, $005A
	call LABEL_8AA1
	jp LABEL_A93E

LABEL_A6CD:
	call LABEL_AAFE
	ld hl, $C003
	ld de, $0004
	ld b, $04
	sub a
LABEL_A6D9:
	ld (hl), a
	add hl, de
	djnz LABEL_A6D9
	sub a
	ld ($C012), a
	call LABEL_AA48
	push ix
	ld ix, $C0D1
	ld de, $001C
	ld b, $04
LABEL_A6EF:
	call LABEL_A59E
	add ix, de
	djnz LABEL_A6EF
	pop ix
	ret

LABEL_A6F9:	
	call LABEL_BB11
	ld b, $50
LABEL_A6FE:	
	push bc
	call LABEL_A978
	call LABEL_AB1F
	call LABEL_93BD
	pop bc
	djnz LABEL_A6FE
	ld a, $03
	call LABEL_BB2C
	call LABEL_A6CD
	sub a
	ld ($C000), a
	call LABEL_AA48
	ld hl, $3800
	ld de, DATA_B11D
	call LABEL_A343
	ld b, $06
	call LABEL_A7FC
	ld b, $0A
	ld hl, DATA_A752
LABEL_A72D:	
	push bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ld hl, $3800
	call LABEL_A343
	ld b, $07
	call LABEL_A7FC
	pop hl
	pop bc
	djnz LABEL_A72D
	ld b, $14
	call LABEL_A7FC
	ld hl, $3800
	ld bc, $0020
	sub a
	call LABEL_AC26
	ret
	
; Data from A752 to A78A (57 bytes)	
DATA_A752:	
	.dw DATA_B11D, DATA_B136, DATA_B14D, DATA_B162, DATA_B175, DATA_B18A, DATA_B19F, DATA_B1B8
	.dw DATA_B1D1, DATA_B1EA

LABEL_A766:	
	ld hl, $C000
	ld ix, $C0D1
	and a
LABEL_A76E:	
	push hl
	sbc hl, de
	pop hl
	ret z
	ld bc, $0004
	add hl, bc
	ld bc, $001C
	add ix, bc
	jr LABEL_A76E
	
LABEL_A77E:	
	push iy
	pop de
	call LABEL_A766
	ld a, (ix+3)
	ld (iy+3), a
	ret
	
; Data from A78B to A79A (16 bytes)	
DATA_A78B:	
	.db $20, $00, $48, $00, $40, $00, $4C, $00, $80, $00, $50, $00, $60, $01, $54, $00
	
; Data from A79B to A7A4 (10 bytes)	
DATA_A79B:	
	.db $47, $41, $4D, $45, $20, $4F, $56, $45, $52, $FF
	
LABEL_A7A5:	
	call LABEL_BB11
	ld hl, $2008
	ld a, $60
	ld bc, $0004
	call LABEL_AC26
	ld de, DATA_A79B
	ld hl, $19AC
	call LABEL_A539
	ld a, ($C0CC)
	bit 1, a
	jp z, LABEL_A7DC
	bit 0, a
	jr nz, LABEL_A7D2
	set 4, a
	bit 5, a
	jp nz, LABEL_A7DC
	jp LABEL_A7E9
	
LABEL_A7D2:	
	set 5, a
	bit 4, a
	jp nz, LABEL_A7DC
	jp LABEL_A7E4
	
LABEL_A7DC:	
	ld b, $00
	call LABEL_A7FC
	jp LABEL_803B
	
LABEL_A7E4:	
	ld de, DATA_8B02
	jr LABEL_A7EC
	
LABEL_A7E9:	
	ld de, DATA_8AF6
LABEL_A7EC:	
	push af
	ld hl, $192B
	call LABEL_A539
	ld b, $C8
	call LABEL_A7FC
	pop af
	jp LABEL_A693
	
LABEL_A7FC:	
	push bc
	call LABEL_A978
	pop bc
	djnz LABEL_A7FC
	ret
	
LABEL_A804:	
	push iy
	ld iy, DATA_AF71
	ld b, $D6
	ld c, $09
	sub a
	ld de, $C086
	ld hl, $C0CC
	bit 0, (hl)
	jr z, LABEL_A81C
	ld de, $C0A1
LABEL_A81C:	
	dec c
	jr nz, LABEL_A824
	ld c, $08
	ld (de), a
	inc de
	sub a
LABEL_A824:	
	ld h, (iy+1)
	ld l, (iy+0)
	push af
	call LABEL_AD7C
	cp $02
	jr nz, LABEL_A838
	pop af
	scf
	rl a
	jr LABEL_A83D
	
LABEL_A838:	
	pop af
	scf
	ccf
	rl a
LABEL_A83D:	
	inc iy
	inc iy
	djnz LABEL_A81C
LABEL_A843:	
	dec c
	jr z, LABEL_A84A
	rl a
	jr LABEL_A843
	
LABEL_A84A:	
	ld (de), a
	pop iy
	ret
LABEL_A84E:
	ld hl, ($C010)
	ld iy, $C000
	ld ix, $C0D1
	ld b, $04
	ld de, $0004
	ld a, ($C145)
	bit 0, a
	jr nz, LABEL_A8E0
LABEL_A865:
	bit 5, (ix+0)
	jr nz, LABEL_A8D4
	bit 6, (ix+0)
	jr nz, LABEL_A8D4
	ld c, $08
	bit 1, (ix+0)
	jr nz, LABEL_A887
	ld c, $05
	ld a, (iy+0)
	cp l
	jr z, LABEL_A887
	ld a, (iy+1)
	cp h
	jr nz, LABEL_A8D4
LABEL_A887:
	ld a, (iy+1)
	sub h
	bit 7, a
	jr z, LABEL_A891
	neg
LABEL_A891:
	cp c
	jr nc, LABEL_A8D4
	ld a, (iy+0)
	sub l
	bit 7, a
	jr z, LABEL_A89E
	neg
LABEL_A89E:
	cp c
	jr nc, LABEL_A8D4
	bit 0, (ix+0)
	jp z, LABEL_A5C6
	push hl
	ld a, ($C011)
	bit 7, a
	jr nz, LABEL_A8C1
	ld a, $10
	ld l, (ix+5)
	sub l
	ld h, a
	ld a, ($C011)
	add a, h
	ld h, a
	ld a, (iy+1)
	jr LABEL_A8C7

LABEL_A8C1:
	ld a, (ix+5)
	add a, (iy+1)
LABEL_A8C7:
	sub h
	bit 7, a
	jr z, LABEL_A8CE
	neg
LABEL_A8CE:
	cp $02
	pop hl
	jp c, LABEL_A5C6
LABEL_A8D4:
	add iy, de
	push de
	ld de, $001C
	add ix, de
	pop de
	djnz LABEL_A865
	ret

LABEL_A8E0:
	bit 5, (ix+0)
	jr nz, LABEL_A932
	bit 6, (ix+0)
	jr nz, LABEL_A932
	ld a, (iy+1)
	sub h
	bit 7, a
	jr z, LABEL_A8F6
	neg
LABEL_A8F6:
	cp $05
	jr nc, LABEL_A932
	push hl
	bit 7, (iy+1)
	ld a, ($C149)
	jr z, LABEL_A91A
	bit 0, (ix+0)
	jr z, LABEL_A913
	ld a, ($C149)
	ld h, a
	ld a, (ix+5)
	jr LABEL_A925

LABEL_A913:
	add a, h
	ld h, a
	ld a, (iy+1)
	jr LABEL_A925

LABEL_A91A:
	ld l, a
	ld a, $10
	sub l
	ld l, a
	ld a, h
	sub l
	ld h, a
	ld a, (iy+1)
LABEL_A925:
	sub h
	bit 7, a
	jr z, LABEL_A92C
	neg
LABEL_A92C:
	cp $02
	pop hl
	jp c, LABEL_A5C6
LABEL_A932:
	add iy, de
	push bc
	ld bc, $001C
	add ix, bc
	pop bc
	djnz LABEL_A8E0
	ret

LABEL_A93E:
	ld sp, $C300
	ld a, $05
	call LABEL_BB2C
LABEL_A946:
	call LABEL_A978
	call LABEL_8E97
	call LABEL_940C
	call LABEL_AA48
	call LABEL_A84E
	call LABEL_AB1F
	jr LABEL_A946

LABEL_A95A:
	push af
	ld a, ($C080)
	inc a
	ld ($C080), a
	ld a, $80
	ld ($C152), a
	pop af
	reti

LABEL_A96A:
	ld a, ($C081)
	ld b, a
LABEL_A96E:
	ld a, ($C080)
	cp b
	jr z, LABEL_A96E
	ld ($C081), a
	ret

LABEL_A978:
	call LABEL_BB6D
	call LABEL_A96A
	call LABEL_A9A5
LABEL_A98D:
	ld a, ($C0CC)
	bit 6, a
	ret z
	ld hl, ($C1AA)
	dec hl
	ld a, l
	or h
	jr z, LABEL_A9A0
	ld ($C1AA), hl
	jr LABEL_A978

LABEL_A9A0:
	call LABEL_810E
	jr LABEL_A978

LABEL_A9A5:
	push af
	call LABEL_80FF
	pop af
	ld hl, $CE90
	ld ($C1AA), hl
	ld.lil a, (KbdG1)
	bit kbitMode, a
	jr z, LABEL_A9BE
	;handle hash key
	ld a, ($C0CC)
	xor $40
	ld ($C0CC), a
	jr LABEL_A98D

LABEL_A9BE:	;check for star key
	ld.lil a, (KbdG6)
	bit kbitClear, a
	jp nz, $F000
	bit kbitMul, a
	jr z, LABEL_A98D
	ld a, ($C0CC)
	bit 6, a
	jp z, LABEL_803B
; Data from A9CA to A9CB (2 bytes)
	.db $18, $AC

LABEL_A9CC:
	ld a, $80
	ld a, ($C0CC)
	call GetDPADInput
	ret

LABEL_A9DD:
	ld hl, ($C1A7)
	inc hl
	ld a, (hl)
	ld de, DATA_AA37
	and a
	jr nz, LABEL_A9EB
	ld de, DATA_AA3F
LABEL_A9EB:
	ld hl, $196D
LABEL_A9EE:
	ld a, (de)
	and a
	jr z, LABEL_A9FB
	sub $13
	call LABEL_AD6F
	inc hl
	inc de
	jr LABEL_A9EE

LABEL_A9FB:
	ld b, $1E
	jp LABEL_A7FC

LABEL_AA00:
	ld a, ($C1A6)
	and a
	ret nz
	call LABEL_A9CC
	cp $7F
	ret z
	ld b, a
	ld hl, ($C1A7)
	ld a, (hl)
	cp $FF
	jr nz, LABEL_AA1D
	inc hl
	ld a, (hl)
	cp b
	jr z, LABEL_AA21
	ld de, $0007
	add hl, de
LABEL_AA1D:
	ld a, (hl)
	cp b
	jr nz, LABEL_AA2D
LABEL_AA21:
	inc hl
	ld ($C1A7), hl
	ld a, (hl)
	and a
	ret nz
	ld hl, $C0CC
	set 7, (hl)
LABEL_AA2D:
	dec hl
	ld a, (hl)
	cp b
	ret z
	ld a, $FF
	ld ($C1A6), a
	ret

; Data from AA37 to AA3E (8 bytes)
DATA_AA37:
	.db $5B, $5C, $33, $60, $5C, $5E, $58, $00

; Data from AA3F to AA47 (9 bytes)
DATA_AA3F:
	.db $5B, $5C, $33, $5B, $62, $5F, $5F, $6C, $00

LABEL_AA48:
	ld hl, $C145
	bit 1, (hl)
	ld hl, $1B00
	ld de, $C000
	jr z, LABEL_AA91
	ld a, ($C1A3)
	dec a
	ld ($C1A3), a
	jr nz, LABEL_AA66
	ld a, ($C145)
	res 1, a
	ld ($C145), a
LABEL_AA66:
	ld bc, $0010
	call LABEL_AC38
	call LABEL_AA97
	dec hl
	dec hl
	push hl
	and a
	ld de, $C000
	sbc hl, de
	ex de, hl
	ld hl, $1B00
	add hl, de
	ld de, $C010
	ld bc, $0004
	call LABEL_AC38
	pop hl
	ex de, hl
	ld hl, $1B10
	ld bc, $0004
	jp LABEL_AC38

LABEL_AA91:
	ld bc, $0020
	jp LABEL_AC38

LABEL_AA97:
	ld hl, $C00E
	ld de, $FFFC
	ld b, $04
LABEL_AA9F:
	ld a, (hl)
	cp $35
	ret nc
	add hl, de
	djnz LABEL_AA9F
	ld hl, $C00E
	ld b, $04
LABEL_AAAB:
	ld a, (hl)
	cp $34
	ret nz
	add hl, de
	djnz LABEL_AAAB
	ld hl, $C00E
	ret

LABEL_AAB6:
	call GetDPADInput
	cpl
	and $0F
	ld ($C082), a
	ret

LABEL_AAD2:
	ld hl, $C191
	dec (hl)
	ret nz
	ld a, $0A
	ld (hl), a
	ld hl, $1805
	ld a, ($C0CC)
	bit 0, a
	jr z, LABEL_AAE7
	ld hl, $181A
LABEL_AAE7:
	call LABEL_AD7C
	and a
	jr z, LABEL_AAFE
	sub a
	ld bc, $0003
	call LABEL_AC26
	call RefreshPelletLoop
	ld bc, $0008
	sub a
	jp LABEL_AC26

LABEL_AAFE:
	call RefreshPelletLoop
	ld de, DATA_B3CD
	ld bc, $0008
	call LABEL_AC38
	jp LABEL_8C7A

RefreshPelletLoop:
	ld b, 4
_:	ld hl, $00C0
	push hl
	call RefreshTile
	pop hl
	djnz -_
	ret

LABEL_AB0D:
	ld hl, $C0D1
	ld de, $001C
	ld b, $04
LABEL_AB15:
	ld a, (hl)
	and c
	jr nz, LABEL_AB1B
	set 2, (hl)
LABEL_AB1B:
	add hl, de
	djnz LABEL_AB15
	ret

LABEL_AB1F:
	call LABEL_AAD2
	ld hl, $C187
	inc (hl)
	ld hl, ($C194)
	dec hl
	ld ($C194), hl
	ld a, l
	or h
	jr nz, LABEL_AB5F
	ld a, ($C0CC)
	ld hl, $C197
	bit 0, a
	jr z, LABEL_AB3E
	ld hl, $C198
LABEL_AB3E:
	ld a, (hl)
	and a
	jr z, LABEL_AB5A
	dec (hl)
	ld hl, $0618
	ld ($C194), hl
	ld a, ($C0CD)
	ld b, a
	rlc b
	ld a, $2C
	sub b
	ld ($C196), a
	ld hl, $C145
	set 3, (hl)
LABEL_AB5A:
	ld c, $2A
	call LABEL_AB0D
LABEL_AB5F:
	ld a, ($C152)
	bit 6, a
	jr z, LABEL_AB70
	ld hl, $C145
	set 1, (hl)
	ld a, $02
	ld ($C1A3), a
LABEL_AB70:
	ld hl, $19B0
	call LABEL_AD7C
	and a
	jr z, LABEL_ABDE
	ld b, a
	ld a, ($C189)
	cp b
	jr z, LABEL_ABCD
	ld a, ($C18C)
	cp b
	jr nz, LABEL_ABDE
	ld a, ($C150)
	dec a
	ld ($C150), a
	jr z, LABEL_ABAE
	ld hl, $19B0
	call LABEL_AD7C
	and a
	jr nz, LABEL_AB9E
	ld a, ($C18C)
	call LABEL_AD6F
LABEL_AB9E:
	inc hl
	call LABEL_AD7C
	and a
	jr nz, LABEL_ABDE
	ld a, ($C18C)
	inc a
	call LABEL_AD6F
	jr LABEL_ABDE

LABEL_ABAE:
	inc a
	ld ($C150), a
	ld hl, $19B1
	call LABEL_AD7C
	ld b, a
	ld a, ($C18C)
	inc a
	cp b
	jr nz, LABEL_ABDE
	ld hl, $19B0
	sub a
	call LABEL_AD6F
	inc hl
	call LABEL_AD6F
	jr LABEL_ABDE

LABEL_ABCD:
	ld hl, ($C147)
	dec hl
	ld ($C147), hl
	ld a, l
	or h
	jr nz, LABEL_ABDE
	ld hl, $19B0
	call LABEL_AD6F
LABEL_ABDE:
	call LABEL_AAB6
	ld hl, $C0CC
	bit 0, (hl)
	jr nz, LABEL_ABF8
	bit 2, (hl)
	ret nz
	ld a, ($C0C4)
	and $F0
	ret z
	set 2, (hl)
	ld hl, $C141
	jr LABEL_AC06

LABEL_ABF8:
	bit 3, (hl)
	ret nz
	ld a, ($C0C7)
	and $F0
	ret z
	set 3, (hl)
	ld hl, $C142
LABEL_AC06:
	inc (hl)
	call LABEL_A55C
	ld a, $04
	jp LABEL_BB2C

; Data from AC0F to AC16 (8 bytes)
DATA_AC0F:
	.db $00, $E2, $06, $80, $00, $36, $07, $70

LABEL_AC26:
	push hl
	ld.lil de, SegaVRAM
	add.lil hl, de
	ld e, a
LABEL_AC2F:
	ld a, e
	ld.lil (hl), a
	inc.lil hl
	dec bc
	ld a, b
	or c
	jr nz, LABEL_AC2F
	pop hl
	ret

LABEL_AC38:
	push hl
	push bc
	ld.lil bc, SegaVRAM
	add.lil hl, bc
	ex.lil de, hl
	ld.lil bc, romStart
	add.lil hl, bc
	pop bc
	ldir.lil
	add hl, bc
	pop de
	ret

; Data from AC4B to ACC2 (120 bytes)
DATA_AC4B:
	.db $28, $10, $00, $70, $56, $4A, $4E, $34, $29, $30, $00, $72, $56, $4A, $4E, $2D
	.db $60, $50, $00, $74, $67, $5F, $63, $25, $60, $50, $00, $74, $67, $5F, $63, $25
	.db $68, $70, $00, $76, $79, $6C, $72, $1E, $68, $70, $00, $76, $79, $6C, $72, $34
	.db $22, $00, $01, $78, $79, $6C, $72, $1E, $22, $00, $01, $78, $79, $6C, $72, $16
	.db $26, $00, $02, $7A, $79, $6C, $72, $0F, $26, $00, $02, $7A, $79, $6C, $72, $34
	.db $25, $00, $03, $7C, $79, $6C, $72, $0F, $25, $00, $03, $7C, $79, $6C, $72, $07
	.db $23, $00, $05, $7E, $79, $6C, $72, $03, $23, $00, $05, $7E, $79, $6C, $72, $0F
	.db $23, $00, $05, $7E, $79, $6C, $72, $01

LABEL_ACC3:
	ld a, ($C0CC)
	bit 0, a
	ld hl, $C0CD
	jr z, LABEL_ACD0
	ld hl, $C0CE
LABEL_ACD0:
	ld a, (hl)
	inc a
	cp $10
	jr z, LABEL_ACD7
	ld (hl), a
LABEL_ACD7:
	ld a, (hl)
	push af
	ld hl, DATA_AC4B - 8
	ld de, $0008
	ld b, a
LABEL_ACE0:
	add hl, de
	djnz LABEL_ACE0
	ld de, $C189
	ld bc, $0008
	ldir
	pop af
	cp $0F
	ret z
	ld a, ($C19F)
	dec a
	ret z
	inc a
	jr nz, LABEL_AD00
	ld a, ($C190)
	add a, $05
	ld ($C190), a
	ret

LABEL_AD00:
	ld a, ($C190)
	sub $08
	jr nc, LABEL_AD09
	ld a, $01
LABEL_AD09:
	ld ($C190), a
	ret

LABEL_AD0D:
	call LABEL_ACC3
	ld a, ($C0CC)
	bit 0, a
	jr z, LABEL_AD29
	ld a, $0F
	ld ($C144), a
	ld a, $D6
	ld ($C0BE), a
	ld a, $02
	ld ($C198), a
	jp LABEL_8D8A

LABEL_AD29:
	ld a, $0F
	ld ($C143), a
	ld a, $D6
	ld ($C0BD), a
	ld a, $02
	ld ($C197), a
	jp LABEL_8D82

LABEL_AD3B:
	di
	ld a, 1
	ld (DrawTilemapTrig), a
	ld de, DATA_B219
	ld hl, $1841
LABEL_AD41:
	ld a, (de)
	cp $FE
	ret z
	cp $FD
	jr nz, LABEL_AD52
	inc de
	ld a, (de)
	ld c, a
	ld b, $00
	add hl, bc
	inc de
	jr LABEL_AD41

LABEL_AD52:
	cp $FF
	jr nz, LABEL_AD68
	inc de
	ld a, (de)
	ld c, a
	inc de
	ld a, (de)
	ld b, $00
	push bc
	push de
	call LABEL_AC26
	pop de
	pop bc
	add hl, bc
	inc de
	jr LABEL_AD41

LABEL_AD68:
	call LABEL_AD6F
	inc hl
	inc de
	jr LABEL_AD41

LABEL_AD6F:
	push hl
	push de
	ld.lil de, SegaVRAM
	add.lil hl, de
	pop de
	ld.lil (hl), a
	pop hl
	ret

LABEL_AD7C:
	push hl
	push de
	ld.lil de, SegaVRAM
	add.lil hl, de
	pop de
	ld.lil a, (hl)
	pop hl
	ret

LABEL_AD89:
	ld a, 1
	ld (DrawTilemapTrig), a
	ld hl, $0000
	ld a, e
	and $F8
	ld l, a
	sla l
	rl h
	sla l
	rl h
	ld a, d
	and $F8
	srl a
	srl a
	srl a
	add a, l
	ld l, a
	push de
	ld de, $1800
	add hl, de
	pop de
	jp LABEL_AD7C

LABEL_ADAC:
	add a, $30
	jp LABEL_A453

; 1st entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from ADB1 to ADC0 (16 bytes)
DATA_ADB1:
	.db $40, $40, $73, $61, $40, $00, $00, $00, $80, $80, $80, $80, $80, $00, $00, $00

; 2nd entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from ADC1 to ADD0 (16 bytes)
DATA_ADC1:
	.db $20, $20, $39, $30, $20, $00, $00, $00, $40, $40, $C0, $C0, $40, $00, $00, $00

; 3rd entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from ADD1 to ADE0 (16 bytes)
DATA_ADD1:
	.db $10, $10, $1C, $18, $10, $00, $00, $00, $20, $20, $E0, $60, $20, $00, $00, $00

; 4th entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from ADE1 to ADF0 (16 bytes)
DATA_ADE1:
	.db $08, $08, $0E, $0C, $08, $00, $00, $00, $10, $10, $70, $30, $10, $00, $00, $00

; 5th entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from ADF1 to AE00 (16 bytes)
DATA_ADF1:
	.db $04, $04, $07, $06, $04, $00, $00, $00, $08, $08, $38, $18, $08, $00, $00, $00

; 6th entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from AE01 to AE10 (16 bytes)
DATA_AE01:
	.db $02, $02, $03, $03, $02, $00, $00, $00, $04, $04, $9C, $0C, $04, $00, $00, $00

; 7th entry of Pointer Table from 9BD0 (indexed by $C0E1)
; Data from AE11 to AE20 (16 bytes)
DATA_AE11:
	.db $01, $01, $01, $01, $01, $00, $00, $00, $02, $02, $CE, $86, $02, $00, $00, $00

; 1st entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE21 to AE30 (16 bytes)
DATA_AE21:
	.db $00, $00, $00, $40, $61, $73, $40, $40, $00, $00, $00, $80, $80, $80, $80, $80

; 2nd entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE31 to AE40 (16 bytes)
DATA_AE31:
	.db $00, $00, $00, $20, $30, $39, $20, $20, $00, $00, $00, $40, $C0, $C0, $40, $40

; 3rd entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE41 to AE50 (16 bytes)
DATA_AE41:
	.db $00, $00, $00, $10, $18, $1C, $10, $10, $00, $00, $00, $20, $60, $E0, $20, $20

; 4th entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE51 to AE60 (16 bytes)
DATA_AE51:
	.db $00, $00, $00, $08, $0C, $0E, $08, $08, $00, $00, $00, $10, $30, $70, $10, $10

; 5th entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE61 to AE70 (16 bytes)
DATA_AE61:
	.db $00, $00, $00, $04, $06, $07, $04, $04, $00, $00, $00, $08, $18, $38, $08, $08

; 6th entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE71 to AE80 (16 bytes)
DATA_AE71:
	.db $00, $00, $00, $02, $03, $03, $02, $02, $00, $00, $00, $04, $0C, $9C, $04, $04

; 7th entry of Pointer Table from 9BDE (indexed by $C0E1)
; Data from AE81 to AE90 (16 bytes)
DATA_AE81:
	.db $00, $00, $00, $01, $01, $01, $01, $01, $00, $00, $00, $02, $86, $CE, $02, $02

; 1st entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AE91 to AEA0 (16 bytes)
DATA_AE91:
	.db $00, $3B, $3B, $22, $22, $3B, $00, $00, $00, $80, $80, $00, $00, $80, $00, $00

; 2nd entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AEA1 to AEB0 (16 bytes)
DATA_AEA1:
	.db $00, $1D, $1D, $11, $11, $1D, $00, $00, $00, $C0, $C0, $00, $00, $C0, $00, $00

; 3rd entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AEB1 to AEC0 (16 bytes)
DATA_AEB1:
	.db $00, $0E, $0E, $08, $08, $0E, $00, $00, $00, $E0, $E0, $80, $80, $E0, $00, $00

; 4th entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AEC1 to AED0 (16 bytes)
DATA_AEC1:
	.db $00, $07, $07, $04, $04, $07, $00, $00, $00, $70, $70, $40, $40, $70, $00, $00

; 5th entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AED1 to AEE0 (16 bytes)
DATA_AED1:
	.db $00, $03, $03, $02, $02, $03, $00, $00, $00, $B8, $B8, $20, $20, $B8, $00, $00

; 6th entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AEE1 to AEF0 (16 bytes)
DATA_AEE1:
	.db $00, $01, $01, $01, $01, $01, $00, $00, $00, $DC, $DC, $10, $10, $DC, $00, $00

; 7th entry of Pointer Table from 9BEC (indexed by $C0E1)
; Data from AEF1 to AF00 (16 bytes)
DATA_AEF1:
	.fill 9, $00
	.db $EE, $EE, $88, $88, $EE, $00, $00

; 1st entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF01 to AF10 (16 bytes)
DATA_AF01:
	.db $00, $77, $77, $11, $11, $77
	.fill 10, $00

; 2nd entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF11 to AF20 (16 bytes)
DATA_AF11:
	.db $00, $3B, $3B, $08, $08, $3B, $00, $00, $00, $80, $80, $80, $80, $80, $00, $00

; 3rd entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF21 to AF30 (16 bytes)
DATA_AF21:
	.db $00, $1D, $1D, $04, $04, $1D, $00, $00, $00, $C0, $C0, $40, $40, $C0, $00, $00

; 4th entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF31 to AF40 (16 bytes)
DATA_AF31:
	.db $00, $0E, $0E, $02, $02, $0E, $00, $00, $00, $E0, $E0, $20, $20, $E0, $00, $00

; 5th entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF41 to AF50 (16 bytes)
DATA_AF41:
	.db $00, $07, $07, $01, $01, $07, $00, $00, $00, $70, $70, $10, $10, $70, $00, $00

; 6th entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF51 to AF60 (16 bytes)
DATA_AF51:
	.db $00, $03, $03, $00, $00, $03, $00, $00, $00, $B8, $B8, $88, $88, $B8, $00, $00

DATA_AF61:	
	.db $00, $01, $01, $00, $00, $01, $00, $00, $00, $DC, $DC, $44, $44, $DC, $00, $00

; 7th entry of Pointer Table from 9BFA (indexed by $C0E1)
; Data from AF61 to AF70 (16 bytes)
DATA_AF71:	
	.db $62, $18, $63, $18, $64, $18, $65, $18, $66, $18, $67, $18, $68, $18, $69, $18
	.db $6A, $18, $6B, $18, $6C, $18, $6D, $18, $6E, $18, $72, $18, $73, $18, $74, $18
	.db $75, $18, $76, $18, $77, $18, $78, $18, $79, $18, $7A, $18, $7B, $18, $7C, $18
	.db $7D, $18, $7E, $18, $86, $18, $8E, $18, $92, $18, $9A, $18, $A2, $18, $A3, $18
	.db $A4, $18, $A5, $18, $A6, $18, $A7, $18, $A8, $18, $A9, $18, $AA, $18, $AB, $18
	.db $AC, $18, $AD, $18, $AE, $18, $AF, $18, $B0, $18, $B1, $18, $B2, $18, $B3, $18
	.db $B4, $18, $B5, $18, $B6, $18, $B7, $18, $B8, $18, $B9, $18, $BA, $18, $BB, $18
	.db $BC, $18, $BD, $18, $BE, $18, $C2, $18, $C6, $18, $CA, $18, $D6, $18, $DA, $18
	.db $DE, $18, $E2, $18, $E3, $18, $E4, $18, $E5, $18, $E6, $18, $EA, $18, $EB, $18
	.db $EC, $18, $ED, $18, $EE, $18, $F2, $18, $F3, $18, $F4, $18, $F5, $18, $F6, $18
	.db $FA, $18, $FB, $18, $FC, $18, $FD, $18, $FE, $18, $06, $19, $1A, $19, $26, $19
	.db $3A, $19, $46, $19, $5A, $19, $66, $19, $7A, $19, $86, $19, $9A, $19, $A6, $19
	.db $BA, $19, $C6, $19, $DA, $19, $E2, $19, $E3, $19, $E4, $19, $E5, $19, $E6, $19
	.db $E7, $19, $E8, $19, $E9, $19, $EA, $19, $EB, $19, $EC, $19, $ED, $19, $EE, $19
	.db $F2, $19, $F3, $19, $F4, $19, $F5, $19, $F6, $19, $F7, $19, $F8, $19, $F9, $19
	.db $FA, $19, $FB, $19, $FC, $19, $FD, $19, $FE, $19, $02, $1A, $06, $1A, $0E, $1A
	.db $12, $1A, $1A, $1A, $1E, $1A, $23, $1A, $24, $1A, $26, $1A, $27, $1A, $28, $1A
	.db $29, $1A, $2A, $1A, $2B, $1A, $2C, $1A, $2D, $1A, $2E, $1A, $2F, $1A, $31, $1A
	.db $32, $1A, $33, $1A, $34, $1A, $35, $1A, $36, $1A, $37, $1A, $38, $1A, $39, $1A
	.db $3A, $1A, $3C, $1A, $3D, $1A, $44, $1A, $46, $1A, $4A, $1A, $56, $1A, $5A, $1A
	.db $5C, $1A, $62, $1A, $63, $1A, $64, $1A, $65, $1A, $66, $1A, $6A, $1A, $6B, $1A
	.db $6C, $1A, $6D, $1A, $6E, $1A, $72, $1A, $73, $1A, $74, $1A, $75, $1A, $76, $1A
	.db $7A, $1A, $7B, $1A, $7C, $1A, $7D, $1A, $7E, $1A, $82, $1A, $8E, $1A, $92, $1A
	.db $9E, $1A, $A2, $1A, $A3, $1A, $A4, $1A, $A5, $1A, $A6, $1A, $A7, $1A, $A8, $1A
	.db $A9, $1A, $AA, $1A, $AB, $1A, $AC, $1A, $AD, $1A, $AE, $1A, $AF, $1A, $B0, $1A
	.db $B1, $1A, $B2, $1A, $B3, $1A, $B4, $1A, $B5, $1A, $B6, $1A, $B7, $1A, $B8, $1A
	.db $B9, $1A, $BA, $1A, $BB, $1A, $BC, $1A, $BD, $1A, $BE, $1A
	
; Data from B11D to B20A (238 bytes)	
DATA_B11D:	
	.db $05, $09, $20, $30, $38, $3C, $3E, $1F, $1F, $0F, $03, $07, $0B, $04, $0C, $1C
	.db $3C, $7C, $F8, $F8, $F0, $C0, $00, $00, $00
DATA_B136:
	.db $06, $08, $30, $38, $3C, $3F, $3F
	.db $1F, $0F, $02, $08, $0A, $0C, $1C, $3C, $FC, $FC, $F8, $F0, $40, $00, $00, $00
DATA_B14D:
	.db $06, $06, $20, $38, $3E, $3F, $3F, $1F, $0A, $0A, $04, $1C, $7C, $FC, $FC, $F8
	.db $00, $00, $00, $00, $00
DATA_B162:
	.db $07, $05, $18, $1F, $1F, $1F, $0E, $0B, $09, $18, $F8
	.db $F8, $F8, $70, $00, $00, $00, $00, $00
DATA_B175:
	.db $07, $07, $03, $0F, $1F, $1F, $1E, $1C
	.db $10, $09, $09, $C0, $F0, $F8, $F8, $78, $38, $08, $00, $00, $00
DATA_B18A:
	.db $07, $07, $01
	.db $03, $07, $0F, $0E, $0C, $08, $09, $09, $80, $C0, $E0, $F0, $70, $30, $10, $00
	.db $00, $00
DATA_B19F:
	.db $05, $09, $01, $03, $03, $07, $07, $06, $06, $04, $04, $07, $0B, $80
	.db $C0, $C0, $E0, $E0, $60, $60, $20, $20, $00, $00, $00
DATA_B1B8:
	.db $04, $08, $01, $01, $01
	.db $03, $03, $02, $02, $02, $08, $0C, $80, $80, $80, $C0, $C0, $40, $40, $40, $00
	.db $00, $00, $00, $00
DATA_B1D1:
	.db $04, $08, $01, $01, $01, $01, $01, $01, $01, $01, $08, $0C
	.db $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00
DATA_B1EA:
	.db $02, $1E, $04
	.db $04, $22, $12, $08, $00, $3C, $00, $08, $12, $22, $04, $04, $00, $00, $00, $20
	.db $20, $44, $48, $10, $00, $3C, $00, $10, $48, $44, $20, $20, $00, $00
	
; Data from B20B to B218 (14 bytes)	
DATA_B20B:	
	.db $FF, $71, $7B, $75, $7C, $00, $FF, $FF, $73, $7D, $7B, $75, $00, $00
; Data from B219 to B3B6 (414 bytes)
DATA_B219:
	.db $90, $FF, $0D, $94, $A6, $A2, $A7, $FF, $0D, $94, $91, $00, $95, $FD, $0D, $A5
	.db $00, $A4, $FD, $0D, $95, $00, $95, $00, $97, $94, $96, $00, $97, $FF, $05, $94
	.db $96, $00, $A0, $A3, $A1, $00, $97, $FF, $05, $94, $96, $00, $97, $94, $96, $00
	.db $95, $00, $95, $FD, $1D, $95, $00, $95, $00, $97, $94, $96, $00, $9E, $A2, $9F
	.db $00, $97, $FF, $03, $94, $A6, $A2, $A7, $FF, $03, $94, $96, $00, $9E, $A2, $9F
	.db $00, $97, $94, $96, $00, $95, $00, $95, $FD, $05, $A5, $00, $A4, $FD, $05, $A5
	.db $00, $A4, $FD, $05, $A5, $00, $A4, $FD, $05, $95, $00, $92, $94, $94, $94, $91
	.db $00, $A5, $00, $AA, $FF, $03, $94, $96, $00, $A0, $A3, $A1, $00, $97, $FF, $03
	.db $94, $AB, $00, $A4, $00, $90, $94, $94, $94, $93, $FD, $05, $95, $00, $A5, $00
	.db $A4, $FD, $0D, $A5, $00, $A4, $00, $95, $FD, $04, $94, $94, $94, $94, $94, $93
	.db $00, $A0, $A3, $A1, $00, $90, $FF, $03, $94, $AC, $B0, $AD, $FF, $03, $94, $91
	.db $00, $A0, $A3, $A1, $00, $92, $94, $94, $94, $94, $FD, $0B, $95, $FD, $09, $95
	.db $FD, $0A, $94, $94, $94, $94, $94, $91, $00, $9E, $A2, $9F, $00, $92, $FF, $09
	.db $94, $93, $00, $9E, $A2, $9F, $00, $90, $94, $94, $94, $94, $FD, $05, $95, $00
	.db $A5, $00, $A4, $FD, $0D, $A5, $00, $A4, $00, $95, $FD, $05, $90, $94, $94, $94
	.db $93, $00, $A0, $A3, $A1, $00, $97, $FF, $03, $94, $A6, $A2, $A7, $FF, $03, $94
	.db $96, $00, $A0, $A3, $A1, $00, $92, $94, $94, $94, $91, $00, $95, $FD, $0D, $A5
	.db $00, $A4, $FD, $0D, $95, $00, $95, $00, $97, $94, $91, $00, $97, $FF, $05, $94
	.db $96, $00, $A0, $A3, $A1, $00, $97, $FF, $05, $94, $96, $00, $90, $94, $96, $00
	.db $95, $00, $95, $00, $00, $00, $95, $FD, $15, $95, $00, $00, $00, $95, $00, $9C
	.db $94, $96, $00, $98, $00, $9E, $A2, $9F, $00, $97, $FF, $03, $94, $A6, $A2, $A7
	.db $FF, $03, $94, $96, $00, $9E, $A2, $9F, $00, $98, $00, $97, $94, $9D, $00, $95
	.db $FD, $05, $A5, $00, $A4, $FD, $05, $A5, $00, $A4, $FD, $05, $A5, $00, $A4, $FD
	.db $05, $95, $00, $95, $00, $97, $94, $94, $94, $A8, $A3, $A9, $FF, $03, $94, $96
	.db $00, $A0, $A3, $A1, $00, $97, $FF, $03, $94, $A8, $A3, $A9, $94, $94, $94, $96
	.db $00, $95, $00, $95, $FD, $1D, $95, $00, $92, $FF, $1D, $94, $93, $FE

; Data from B3B7 to B3CC (22 bytes)
DATA_B3B7:
	.db $02, $10, $00, $00, $00, $00, $18, $18, $00, $00, $00, $00, $00, $00, $00, $01
	.db $01, $01, $01, $01, $C0, $00

; Data from B3CD to B73C (880 bytes)
DATA_B3CD:
	.db $3C, $7E, $FF, $FF, $FF, $FF, $7E, $3C, $06, $08, $01, $3C, $7E, $1F, $07, $07
	.db $1F, $7E, $3C, $DB, $7E, $54, $28, $54, $28, $54, $28, $18, $24, $3C, $3C, $10
	.db $18, $10, $18, $00, $0E, $1E, $1C, $38, $30, $00, $60, $18, $3C, $7E, $7E, $FF
	.db $89, $89, $76, $92, $BA, $FE, $FE, $54, $10, $10, $10, $02, $40, $01, $08, $14
	.db $16, $62, $F6, $FF, $6F, $06, $08, $36, $55, $7F, $2A, $3E, $14, $08, $0A, $80
	.db $01, $00, $3C, $66, $66, $66, $66, $66, $3C, $00, $18, $38, $18, $18, $18, $18
	.db $3C, $00, $3C, $66, $06, $3C, $60, $60, $7E, $00, $3C, $66, $06, $1C, $06, $66
	.db $3C, $00, $1E, $36, $66, $7F, $06, $06, $06, $00, $7E, $60, $60, $7C, $06, $66
	.db $3C, $00, $3C, $66, $60, $7C, $66, $66, $3C, $00, $7E, $46, $04, $0C, $08, $18
	.db $18, $00, $3C, $66, $66, $3C, $66, $66, $3C, $00, $3C, $66, $66, $3E, $06, $66
	.db $3C, $1C, $00, $02
	.fill 9, $00
	.db $3C, $66, $66, $7E, $66, $66, $66, $00, $7C, $66, $66, $7C, $66, $66, $7C, $00
	.db $3C, $76, $62, $60, $62, $76, $3C, $00, $7C, $66, $62, $62, $62, $66, $7C, $00
	.db $7E, $60, $60, $78, $60, $60, $7E, $00, $7E, $60, $60, $78, $60, $60, $60, $00
	.db $3C, $76, $60, $6E, $62, $76, $3C, $00, $66, $66, $66, $7E, $66, $66, $66, $00
	.db $7E, $18, $18, $18, $18, $18, $7E, $00, $1E, $0C, $0C, $0C, $4C, $7C, $38, $00
	.db $66, $6C, $78, $78, $6C, $66, $62, $00, $60, $60, $60, $60, $60, $60, $7E, $00
	.db $62, $76, $7E, $6A, $62, $62, $62, $00, $66, $76, $7E, $6E, $66, $66, $66, $00
	.db $3C, $66, $66, $66, $66, $66, $3C, $00, $7C, $66, $66, $7C, $60, $60, $60, $00
	.db $38, $6C, $44, $44, $5C, $6C, $36, $00, $7C, $66, $66, $7C, $78, $6C, $66, $00
	.db $3C, $66, $60, $3C, $06, $66, $3C, $00, $7E, $18, $18, $18, $18, $18, $18, $00
	.db $66, $66, $66, $66, $66, $66, $3C, $00, $66, $66, $66, $24, $24, $38, $18, $00
	.db $C6, $C6, $C6, $C6, $D6, $7C, $28, $00, $42, $66, $3C, $18, $3C, $66, $42, $00
	.db $42, $66, $3C, $18, $18, $18, $18, $00, $7E, $06, $0C, $18, $30, $60, $7E, $00
	.db $00, $3C, $00, $3C, $00, $00, $00, $01, $00, $03, $18, $66, $FF, $FF, $FF, $FF
	.db $7E, $3C, $01, $40, $03, $20, $10, $76, $FB, $FF, $FF, $7E, $3C, $10, $80, $03
	.db $00, $44, $CA, $4A, $4A, $4A, $4A, $E4, $00, $40, $A0, $A0, $A0, $A0, $A0, $40
	.db $00, $62, $95, $15, $65, $15, $95, $62, $00, $20, $50, $50, $50, $50, $50, $20
	.db $00, $F2, $85, $85, $E5, $15, $15, $E2, $00, $20, $50, $50, $50, $50, $50, $20
	.db $00, $F2, $15, $15, $25, $25, $25, $22, $00, $20, $50, $50, $50, $50, $50, $20
	.db $00, $22, $65, $25, $25, $25, $25, $72, $00, $22, $55, $55, $55, $55, $55, $22
	.db $00, $62, $95, $15, $25, $45, $85, $F2, $00, $22, $55, $55, $55, $55, $55, $22
	.db $00, $62, $95, $15, $25, $15, $95, $62, $00, $22, $55, $55, $55, $55, $55, $22
	.db $00, $F2, $85, $85, $E5, $15, $15, $E2, $00, $22, $55, $55, $55, $55, $55, $22
	.db $1E, $80, $04, $00, $00, $3F, $20, $20, $27, $24, $24, $00, $00, $FC, $04, $04
	.db $E4, $24, $24, $24, $24, $27, $20, $20, $3F, $00, $00, $24, $24, $E4, $04, $04
	.db $FC, $00, $00, $00, $00, $FF, $00, $00, $FF, $00, $00, $24, $24, $24, $24, $24
	.db $24, $24, $24, $00, $00, $F8, $04, $04, $F8, $00, $00, $00, $00, $1F, $20, $20
	.db $1F, $00, $00, $24, $24, $24, $24, $24, $18, $00, $00, $00, $00, $18, $24, $24
	.db $24, $24, $24, $00, $00, $FF, $00, $00, $E7, $24, $24, $24, $24, $E7, $00, $00
	.db $FF, $00, $00, $24, $24, $27, $20, $20, $27, $24, $24, $24, $24, $E4, $04, $04
	.db $E4, $24, $24, $00, $00, $3F, $20, $20, $20, $20, $20, $00, $00, $FC, $04, $04
	.db $04, $04, $04, $20, $20, $20, $20, $20, $3F, $00, $00, $04, $04, $04, $04, $04
	.db $FC, $00, $00, $00, $00, $FF
	.fill 10, $00
	.db $FF, $00, $00, $04, $04, $04, $04, $04, $04, $04, $04, $20, $20, $20, $20, $20
	.db $20, $20, $20, $00, $00, $FF, $00, $00, $E0, $20, $20, $00, $00, $FF, $00, $00
	.db $07, $04, $04, $20, $20, $E0, $00, $00, $FF, $00, $00, $04, $04, $07, $00, $00
	.db $FF, $00, $00, $04, $04, $07, $00, $00, $07, $04, $04, $20, $20, $E0, $00, $00
	.db $E0, $20, $20, $00, $00, $FC, $03, $03, $FC, $00, $00, $00, $00, $3F, $C0, $C0
	.db $3F, $00, $00, $01, $80, $05, $00, $00, $00, $FF, $FF, $00, $00, $00, $0A, $C0
	.db $05, $00, $66, $66, $66, $7E, $66, $66, $66, $00, $7E, $18, $18, $18, $18, $18
	.db $7E, $00, $3C, $76, $60, $6E, $62, $76, $3C, $00, $3C, $66, $60, $3C, $06, $66
	.db $3C, $00, $3C, $76, $62, $60, $62, $76, $3C, $00, $3C, $66, $66, $66, $66, $66
	.db $3C, $00, $7C, $66, $66, $7C, $78, $6C, $66, $00, $7E, $60, $60, $78, $60, $60
	.db $7E, $00, $66, $66, $66, $66, $66, $66, $3C, $00, $7C, $66, $66, $7C, $60, $60
	.db $60, $00, $00

; Data from B73D to B8BC (384 bytes)
DATA_B73D:
	.db $00, $00, $01, $03, $07, $0F, $1F, $3F, $3F, $7F, $7F, $7F, $FF, $FF, $FF, $FF
	.db $0F, $7F
	.fill 18, $FF
	.db $7F, $7F, $7F, $3F, $3F, $1F, $0F, $07, $03, $01, $00, $00
	.fill 14, $FF
	.db $7F, $0F, $F0, $FE
	.fill 14, $FF
	.db $00, $00, $80, $C0, $E0, $F0, $F8, $FC, $FC, $FE, $FE, $FE
	.fill 18, $FF
	.db $FE, $F0, $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FC, $FC, $F8, $F0, $E0, $C0, $80
	.db $00, $00, $00, $00, $01, $03, $07, $0F, $1F, $3F, $3F, $7F, $7F, $7F, $FF, $FF
	.db $FF, $FF, $0F, $7F
	.fill 18, $FF
	.db $7F, $7F, $7F, $3F, $3F, $1F, $0F, $07, $03, $01, $00, $00
	.fill 14, $FF
	.db $7F, $0F, $F0, $FE
	.fill 11, $FF
	.db $FC, $E0, $00, $00, $00, $80, $C0, $E0, $F0, $F8, $FC, $FC, $FE, $FE, $F0, $80
	.db $00, $00, $00, $00, $E0, $FC
	.fill 11, $FF
	.db $FE, $F0, $00, $00, $00, $80, $F0, $FE, $FE, $FC, $FC, $F8, $F0, $E0, $C0, $80
	.db $00, $00, $00, $00, $01, $03, $07, $0F, $1F, $3F, $3F, $7F, $7F, $7F, $FF, $FF
	.db $FF, $FF, $0F, $7F
	.fill 18, $FF
	.db $7F, $7F, $7F, $3F, $3F, $1F, $0F, $07, $03, $01, $00, $00
	.fill 14, $FF
	.db $7F, $0F, $F0, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FC, $F8, $F0, $E0, $C0
	.db $80, $00, $00, $00, $80, $C0, $E0, $C0, $80
	.fill 10, $00
	.db $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $F0
	.fill 9, $00
	.db $80, $C0, $E0, $C0, $80, $00, $00

; Data from B8BD to B9DC (288 bytes)
DATA_B8BD:
	.db $00, $00, $03, $0F, $1F, $1F, $3F, $3F, $3F, $3F, $1F, $1F, $0F, $03, $00, $00
	.db $00, $00, $C0, $F0, $F8, $F8, $FC, $FC, $FC, $FC, $F8, $F8, $F0, $C0, $00, $00
	.db $00, $00, $03, $0F, $1F, $1F, $3F, $3E, $3E, $3F, $1F, $1F, $0F, $03, $00, $00
	.db $00, $00, $C0, $F0, $F8, $E0, $80, $00, $00, $80, $E0, $F8, $F0, $C0, $00, $00
	.db $00, $00, $03, $0F, $1F, $1F, $3F, $3E, $3E, $3F, $1F, $1F, $0F, $03, $00, $00
	.db $00, $00, $C0, $F0, $E0, $80, $00, $00, $00, $00, $80, $E0, $F0, $C0, $00, $00
	.db $00, $00, $00, $08, $18, $1C, $3C, $3E, $3E, $3F, $1F, $1F, $0F, $03, $00, $00
	.db $00, $00, $00, $10, $18, $38, $3C, $7C, $7C, $FC, $F8, $F8, $F0, $C0, $00, $00
	.db $00, $00, $00, $00, $10, $38, $38, $3C, $3E, $3F, $1F, $1F, $0F, $03, $00, $00
	.db $00, $00, $00, $00, $08, $1C, $1C, $3C, $7C, $FC, $F8, $F8, $F0, $C0, $00, $00
	.db $00, $00, $03, $0F, $1F, $1F, $3F, $3E, $3E, $3C, $1C, $18, $08, $00, $00, $00
	.db $00, $00, $C0, $F0, $F8, $F8, $FC, $7C, $7C, $3C, $38, $18, $10, $00, $00, $00
	.db $00, $00, $03, $0F, $1F, $1F, $3F, $3E, $3C, $38, $38, $10, $00, $00, $00, $00
	.db $00, $00, $C0, $F0, $F8, $F8, $FC, $7C, $3C, $1C, $1C, $08, $00, $00, $00, $00
	.db $00, $00, $03, $0F, $1F, $07, $01, $00, $00, $01, $07, $1F, $0F, $03, $00, $00
	.db $00, $00, $C0, $F0, $F8, $F8, $FC, $7C, $7C, $FC, $F8, $F8, $F0, $C0, $00, $00
	.db $00, $00, $07, $0F, $07, $01, $00, $00, $00, $00, $01, $07, $0F, $07, $00, $00
	.db $00, $00, $C0, $F0, $F8, $F8, $FC, $7C, $7C, $FC, $F8, $F8, $F0, $C0, $00, $00

; Data from B9DD to BA7C (160 bytes)
DATA_B9DD:
	.db $00, $00, $07, $0F, $17, $37, $31, $33, $37, $3F, $3F, $3F, $3F, $0C, $00, $00
	.db $00, $00, $E0, $F0, $E8, $EC, $8C, $CC, $EC, $FC, $FC, $FC, $FC, $CC, $00, $00
	.db $00, $00, $07, $0F, $1F, $3F, $3F, $37, $33, $31, $37, $37, $3F, $0C, $00, $00
	.db $00, $00, $E0, $F0, $F8, $FC, $FC, $EC, $CC, $8C, $EC, $EC, $FC, $CC, $00, $00
	.db $00, $00, $07, $0F, $1F, $38, $38, $3B, $3B, $38, $3F, $3F, $3F, $0C, $00, $00
	.db $00, $00, $E0, $F0, $F8, $8C, $8C, $BC, $BC, $8C, $FC, $FC, $FC, $CC, $00, $00
	.db $00, $00, $07, $0F, $1F, $31, $31, $3D, $3D, $31, $3F, $3F, $3F, $0C, $00, $00
	.db $00, $00, $E0, $F0, $F8, $1C, $1C, $DC, $DC, $1C, $FC, $FC, $FC, $CC, $00, $00
	.db $00, $00, $07, $0F, $1F, $39, $39, $3F, $3F, $39, $36, $3F, $36, $22, $00, $00
	.db $00, $00, $E0, $F0, $F8, $9C, $9C, $FC, $FC, $9C, $6C, $FC, $6C, $44, $00, $00

; Data from BA7D to BAF7 (123 bytes)
DATA_BA7D:
	.db $82, $06, $18, $25, $09, $11, $21, $3C, $0A, $06, $88, $54, $54, $54, $54, $88
	.db $10, $06, $28, $29, $29, $3D, $09, $08, $0A, $06, $88, $54, $54, $54, $54, $88
	.db $04, $06, $18, $25, $19, $25, $25, $18, $0A, $06, $88, $54, $54, $54, $54, $88
	.db $10, $06, $2E, $6A, $28, $2E, $2A, $2E, $0A, $06, $48, $B4, $B4, $B4, $B4, $48
	.db $07, $04, $12, $12, $1E, $1E, $0C, $04, $48, $48, $78, $78, $0C, $05, $0E, $0E
	.db $08, $08, $0E, $0B, $05, $70, $70, $40, $40, $70, $0D, $04, $1E, $1E, $12, $12
	.db $0C, $04, $78, $78, $48, $48, $0A, $05, $0E, $0E, $02, $02, $0E, $0B, $0B, $70
	.db $70, $10, $10, $70, $00, $00, $00, $00, $00, $00, $00

; Data from BAF8 to BB10 (25 bytes)
DATA_BAF8:
	.db $F0, $70, $70, $90, $A0, $60, $F0, $F0, $A0, $A0, $A0, $A0, $90, $30, $D0, $D0
	.db $E0, $F0, $40, $40, $40, $40, $D0, $F0, $F0

LABEL_BB11:
	ld a, $9F
	;out (Port_PSG), a
	ld a, $BF
	;out (Port_PSG), a
	ld a, $DF
	;out (Port_PSG), a
	ld a, $FF
	;out (Port_PSG), a
	ld b, $18
	ld hl, $C1AC
	sub a
LABEL_BB27:
	ld (hl), a
	inc hl
	djnz LABEL_BB27
	ret

LABEL_BB2C:
	push af
	res 7, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_BC06
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, (de)
	add a, a
	ld b, a
	add a, a
	add a, b
	ld c, a
	ld b, $00
	ld hl, $C1AC
	add hl, bc
	ld c, (hl)
	inc hl
	pop af
	bit 7, a
	jr nz, LABEL_BB5A
	ld b, (hl)
	ld a, b
	or c
	jr z, LABEL_BB5A
	push de
	ex de, hl
	and a
	sbc hl, bc
	ex de, hl
	pop de
	ret nc
LABEL_BB5A:
	inc de
	ld a, (de)
	inc de
	ld (hl), d
	dec hl
	ld (hl), e
	inc hl
	inc hl
	ld (hl), a
	inc hl
	ld (hl), $01
	inc hl
	ld (hl), $00
	inc hl
	ld (hl), $00
	ret

LABEL_BB6D:
	ld hl, $C1AC
	call LABEL_BB82
	ld hl, $C1B2
	call LABEL_BB82
	ld hl, $C1B8
	call LABEL_BB82
	ld hl, $C1BE
LABEL_BB82:
	push hl
	pop bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, d
	or e
	ret z
	inc hl
	ld a, (hl)
	inc hl
	dec (hl)
	ret nz
	ld (hl), a
	ld a, (de)
	bit 7, a
	jr z, LABEL_BBC4
	inc de
	cp $E8
	jr nz, LABEL_BB9F
	sub a
	ld (bc), a
	inc bc
	ld (bc), a
	ret

LABEL_BB9F:
	;out (Port_PSG), a
	and $70
	jr z, LABEL_BBAD
	cp $20
	jr z, LABEL_BBAD
	cp $40
	jr nz, LABEL_BBBE
LABEL_BBAD:
	ld a, (de)
	bit 6, a
	res 6, a
	;out (Port_PSG), a
	inc de
	jr z, LABEL_BBBE
	call LABEL_BBBE
	ld (hl), $01
	jr LABEL_BBD4

LABEL_BBBE:
	ld a, e
	ld (bc), a
	inc bc
	ld a, d
	ld (bc), a
	ret

LABEL_BBC4:
	bit 6, a
	jr nz, LABEL_BBF3
	and a
	jr nz, LABEL_BBD9
LABEL_BBCB:
	inc de
	ld a, (de)
	ld (bc), a
	inc de
	inc bc
	ld a, (de)
	ld (bc), a
LABEL_BBD2:
	ld (hl), $01
LABEL_BBD4:
	dec bc
	push bc
	pop hl
	jr LABEL_BB82

LABEL_BBD9:
	inc hl
	ex af, af'
	ld a, (hl)
	and a
	jr nz, LABEL_BBE4
	ex af, af'
	ld (hl), a
	dec hl
	jr LABEL_BBCB

LABEL_BBE4:
	dec a
	ld (hl), a
	dec hl
	jr nz, LABEL_BBCB
	inc de
	inc de
LABEL_BBEB:
	inc de
	ld a, e
	ld (bc), a
	inc bc
	ld a, d
	ld (bc), a
	jr LABEL_BBD2

LABEL_BBF3:
	inc hl
	inc hl
	ex af, af'
	ld a, (hl)
	and a
	jr nz, LABEL_BBFF
	ex af, af'
	and $1F
	ld (hl), a
	ret

LABEL_BBFF:
	dec a
	ld (hl), a
	ret nz
	dec hl
	dec hl
	jr LABEL_BBEB

; Data from BC06 to BFFF (1018 bytes)
DATA_BC06:
	.dw DATA_BD2C, DATA_BD2C, DATA_BD2C, DATA_BD2C
	.dw DATA_BD2C, DATA_BD2C, DATA_BD2C, DATA_BD2C
	.dw DATA_BD2C, DATA_BD2C, DATA_BD2C, DATA_BD2C
	.dw DATA_BD2C, DATA_BD2C
DATA_BD2C:
	.db $01, $01, $BF, $E8

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

RefreshTile:
	push bc
	ld a, l
	and $F8
	ld l, a

	;divide the address pointer by the tile size
	srl	h
	rr	l		;hl /= 2
	srl	h
	rr	l		;hl /= 2
	srl	h
	rr	l		;hl /= 2

	ld a, l
	ld.lil hl, SegaTileFlags
	ld l, a
	ld.lil (hl), $00

	ld.lil hl, TilemapCache + $62
	ld bc, $27C
	cpir.lil
	pop bc
	ret nz
	dec.lil hl
	ld.lil (hl), $00
	ret

ClearTileCache:
	ld.lil hl, SegaTileFlags
	ld.lil de, SegaTileFlags + 1
	ld bc, $0100
	ld.lil (hl), l
	ldir.lil
	ret

GetNumberKey:
	ld.lil a, (KbdG3)
	bit kbit1, a
	jr z, +_
	ld a, $7D
	ret

_:	bit kbit4, a
	jr z, +_
	ld a, $72
	ret

_:	ld.lil a, (KbdG4)
	bit kbit2, a
	jr z, +_
	ld a, $77
	ret

_:	bit kbit5, a
	jr z, +_
	ld a, $73
	ret

_:	ld.lil a, (KbdG5)
	bit kbit3, a
	jr z, +_
	ld a, $7C
	ret

_:	bit kbit6, a
	ret z
	ld a, $7E
	ret

SaveSP:
	.dw 0

HandleInterrupt:
	di
	push af
	ld a, 8
	ld.lil (mpLcdIcr), a
	push hl
	ld hl, FrameCounter
	ld a, (hl)
	inc (hl)
	rra
	call nz, DrawScreen
	pop hl
	pop af
	ei
	jp LABEL_A95A

FrameCounter:
.db $00
HandleInterrupt_End:

#include "src/ColecoPac/ti_equates.asm"
#include "src/ColecoPac/screen_drawing_routines.asm"