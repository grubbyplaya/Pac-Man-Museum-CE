.ASSUME ADL=0

#define PatternGen	SegaVRAM + $2000
#define ColorTable	SegaVRAM + $3F80
#define SpritePTR	SegaVRAM + $1800

.db $FF
.ORG 0

.dl MuseumHeader
.dl MuseumIcon
.dl HeaderEnd

MuseumHeader:
	.db $83, "Pac-Man (MSX Ver.)",0
MuseumIcon:
#import "src/includes/gfx/logos/msx.bin"
HeaderEnd:
.ORG	$4018

LABEL_18:
	ld hl, HandleInterrupt
	ld de, $0038
	ld bc, 3
	ldir

	ld hl, $E000
	ld (hl), $00
	ld de, $E000 + 1
	ld bc, $0FFF
	ldir

	ld sp, $F000
	ld a, $07
	ld e, $BF
	; call BIOS_0093
	ld hl, DATA_1E6C
	ld bc, $0800
LABEL_35:
	ld hl, DATA_2A6
	ld de, $E58D
	ld bc, $0003
	ldir
	ld hl, $3F00
	ld b, $20
LABEL_4F:
	push bc
	ld de, DATA_24E9
	ld bc, $0004
	push hl
	call LABEL_1B73
	pop hl
	ld a, l
	add a, $04
	ld l, a
	pop bc
	djnz LABEL_4F
	ld hl, $1800
	ld b, $00
LABEL_65:
	push bc
	ld de, DATA_242B - $0030
	ld bc, $0008
	call LABEL_1B73
	ld a, l
	add a, $08
	ld l, a
	jr nc, LABEL_76
	inc h
LABEL_76:
	pop bc
	djnz LABEL_65
	ld hl, $1800
	ld de, DATA_24ED
	call LABEL_1B6B
	ld hl, $1988
	ld de, DATA_26D7 - $68
	ld b, $0C
LABEL_8A:
	push bc
	ld bc, $0008
	call LABEL_1B73
	ld a, l
	add a, $08
	ld l, a
	jr nc, LABEL_98
	inc h
LABEL_98:
	pop bc
	djnz LABEL_8A
	ld hl, $1A58
	ld de, DATA_26D7 - $0008
	ld bc, $0008
	call LABEL_1B73
	ld hl, $1A80
	ld de, DATA_26D7
	call LABEL_1B6B
	ld hl, $1D80
	ld de, DATA_26D7 + $02C2
	ld b, $08
LABEL_B8:
	push bc
	ld bc, $0008
	call LABEL_1B73
	ld a, l
	add a, $08
	ld l, a
	pop bc
	djnz LABEL_B8

	ld hl, $2100
	ld de, DATA_242B - $0030
	ld bc, $0008
	call LABEL_1B73
	ld hl, $2180
	ld de, DATA_2213
	call LABEL_1B6B
	ld hl, $2200
	ld de, DATA_2337
	call LABEL_1B6B
	ld hl, $2208
	ld de, DATA_2265
	call LABEL_1B6B
	ld hl, $2400
	ld de, DATA_2341
	call LABEL_1B6B
	ld hl, $2500
	ld de, DATA_242B
	call LABEL_1B6B
	ld hl, $2170
	ld de, DATA_249D
	call LABEL_1B6B
	ld hl, $2000
	ld de, DATA_26D7 + $0002
	ld bc, $0040
	call LABEL_1B73
	ld hl, $2080
	ld bc, $0020
	call LABEL_1B73
	ld hl, $2040
	ld bc, $0020
	call LABEL_1B73
	ld hl, $25C0
	ld bc, $0020
	call LABEL_1B73
	ld hl, $20C0
	ld bc, $0040
	call LABEL_1B73
	ld hl, $2580
	ld bc, $0020
	call LABEL_1B73
	ld hl, $25A0
	ld de, DATA_249D - $0010
	ld bc, $0008
	call LABEL_1B73
	ld hl, $2600
	ld de, DATA_24A7
	call LABEL_1B6B
	ld hl, $2300
	ld de, DATA_2BD
	ld b, $0E
	call LABEL_274
	ld hl, $2380
	ld de, DATA_2CB
	ld b, $0E
	call LABEL_274
	ld hl, $3F80
	ld de, DATA_1E74
	call LABEL_1B6B
	ld a, 3
	ld (DrawTilemapTrig), a
	ld sp, $F000
	ld hl, $E000
	ld de, DATA_2A9
LABEL_17E:
	ld a, l
	add a, $1E
	ld (hl), a
	inc hl
	ld (hl), h
	ld l, a
	ex de, hl
	ld a, (hl)
	ld c, a
	inc hl
	or (hl)
	jr z, LABEL_198
	ex de, hl
	ld (hl), c
	ld a, (de)
	inc hl
	ld (hl), a
	inc de
	inc l
	jr nz, LABEL_17E
	inc h
	jr LABEL_17E

LABEL_198:
	xor a
	ld ($E590), a
	ld a, $C3
	ld ($FD9A), a
	ld hl, LABEL_1BE
	ld ($FD9B), hl
	ld a, $07
	ld e, $B8
	; call BIOS_0093
	ld a, $0F
	ld e, $8F
	; call BIOS_0093
LABEL_1B5:
	di
	ld a, (FrameCounter)
	rrca
	call nc, DrawScreen
	ei
LABEL_1BB:
	jp LABEL_1BB

LABEL_1BE:

	ld sp, $F000
	call READVDP
	ld hl, FrameCounter
	inc (hl)
	ld hl, $E5A1
	ld de, $E5A0
	ld bc, $0003
	ldir
	ld a, $07
	call SNSMAT
	ld ($E5A3), a
	ld hl, $E5A2
	or (hl)
	cpl
	dec hl
	and (hl)
	dec hl
	and (hl)
	bit 4, a
	jr z, LABEL_1F1
	ld a, ($E590)
	cpl
	ld ($E590), a
LABEL_1F1:
	ld a, ($E590)
	and a
	jr z, LABEL_206
	ld a, $08
	ld e, $00
	ld b, $03
LABEL_1FD:
	; call BIOS_0093
	inc a
	djnz LABEL_1FD
	ld.lil	hl, mpLcdIcr
	ld.lil	(hl), $08
	jp LABEL_1B5

LABEL_206:
	ld hl, $E580
	inc (hl)
	ld hl, $3F00
	ld de, $E500
	ld bc, $0018
	call LABEL_1B73
	ld a, $01
	ld (DrawSATTrig), a
	ld a, $08
	call SNSMAT
	bit 7, a
	jr z, LABEL_243
	bit 6, a
	jr z, LABEL_247
	bit 5, a
	jr z, LABEL_24B
	bit 4, a
	jr z, LABEL_24F
	xor a
	jr LABEL_251

LABEL_243:
	ld a, $01
	jr LABEL_251

LABEL_247:
	ld a, $08
	jr LABEL_251

LABEL_24B:
	ld a, $02
	jr LABEL_251

LABEL_24F:
	ld a, $04
LABEL_251:
	ld ($E581), a
	xor a
	ld ($E596), a
	ld de, $E000
LABEL_25B:
	push de
	call LABEL_1B22
	pop de
	ld a, e
	add a, $20
	ld e, a
	jr nc, LABEL_267
	inc d
LABEL_267:
	push de
	ld hl, $E120
	and a
	sbc hl, de
	pop de
	jr nz, LABEL_25B
	jp LABEL_1B5

LABEL_274:
	push bc
	ld a, (de)
	push de
	cp $FF
	jr z, LABEL_285
	cp $80
	jr nz, LABEL_28B
	ld de, DATA_2337 - $0008
	jp LABEL_296

LABEL_285:
	ld de, DATA_242B - $0030
	jp LABEL_296

LABEL_28B:
	add a, a
	add a, a
	add a, a
	ld de, DATA_2267
	add a, e
	ld e, a
	jr nc, LABEL_296
	inc d
LABEL_296:
	ld bc, $0008
	call LABEL_1B73
	pop de
	inc de
	pop bc
	djnz LABEL_274
	ret

; Data from 2A6 to 2A8 (3 bytes)
DATA_2A6:
	.db $00, $10, $00

; Data from 2A9 to 2BC (20 bytes)
DATA_2A9:
	.dw LABEL_2D9
	.dw LABEL_B7C
	.dw LABEL_CA8
	.dw LABEL_CF9
	.dw LABEL_D97
	.dw LABEL_E8E
	.dw LABEL_FC8
	.dw LABEL_10D7
	.dw LABEL_11C1
	.dw $0000

; Data from 2BD to 2CA (14 bytes)
DATA_2BD:
	.db $07, $08, $FF, $12, $02, $0E, $11, $04, $11, $04, $00, $03, $18, $80

; Data from 2CB to 2D8 (14 bytes)
DATA_2CB:
	.db $0F, $14, $12, $07, $FF, $12, $0F, $00, $02, $04, $FF, $0A, $04, $18

LABEL_2D9:
	di
	call LABEL_1B4C
	call LABEL_1B5A
	call LABEL_1BC7
	call LABEL_1BBC
	ld hl, $3C26
	ld de, DATA_1FAE
	call LABEL_1B6B
	ld hl, $3C44
	ld de, $E405
	call LABEL_1C8A
	ld hl, $3C4A
	ld a, $30
	call WRITEVRAM
	ld hl, $3C31
	ld de, DATA_1FB5
	call LABEL_1B6B
	ld hl, $3C51
	ld de, $E58D
	call LABEL_1C8A
	ld hl, $3C57
	ld a, $30
	call WRITEVRAM
	ld hl, $3CA5
	ld de, DATA_1F32
	call LABEL_1B6B
	ld hl, $3CC5
	ld de, DATA_1F49
	call LABEL_1B6B
	ld hl, $3CE5
	ld de, DATA_1F60
	call LABEL_1B6B
	ld hl, $3D68
	ld de, DATA_1FBF
	call LABEL_1B6B
	ld hl, $3E64
	ld de, DATA_1F77
	call LABEL_1B6B
	ld hl, $3EA6
	ld de, DATA_1F8F
	call LABEL_1B6B
	ld hl, $3DEB
	ld de, DATA_1FA4
	call LABEL_1B6B
	ld hl, $E200
	ld (hl), $00
	ld de, $E200 + 1
	ld bc, $004F
	ldir
	ld a, 3
	ld (DrawTilemapTrig), a
LABEL_36B:
	call LABEL_1B31
	ld a, $08
	call SNSMAT
	bit 0, a
	jr nz, LABEL_36B
LABEL_384:
	call LABEL_1BBC
	ld hl, DATA_2005
	ld de, $E400
	ld bc, $0080
	ldir
	ld hl, $3C37
	ld de, DATA_1FB5
	call LABEL_1B6B
	call LABEL_1C80
	ld hl, $3C5D
	ld a, $30
	call WRITEVRAM
	ld hl, $3CB9
	ld de, DATA_1FAE
	call LABEL_1B6B
	ld a, $30
	ld hl, $3CDD
	call WRITEVRAM
	call LABEL_1CD2
	call LABEL_1D23
	call LABEL_1B77
	call LABEL_1BDD
	ld a, $01
	ld ($E600), a
	ld ($E601), a
	ld ($E5B5), a
LABEL_3D4:
	call LABEL_1B31
	ld a, ($E600)
	and a
	jr nz, LABEL_3D4
	ld hl, $E400
	dec (hl)
	call LABEL_1CD2
	jr LABEL_3E6

LABEL_3E6:
	ld a, $01
	ld ($E5B5), a
	ld hl, DATA_1E92
	ld de, $E200
	ld bc, $00A0
	ldir
	ld hl, DATA_21ED - $0060
	ld de, $E206
	call LABEL_49B
	ld hl, DATA_21ED - $0040
	ld de, $E226
	call LABEL_49B
	ld hl, DATA_21ED - $0040
	ld de, $E246
	call LABEL_49B
	ld hl, DATA_21ED - $0040
	ld de, $E266
	call LABEL_49B
	ld hl, DATA_21ED - $0040
	ld de, $E286
	call LABEL_49B
	ld hl, $3DA9
	ld de, DATA_1FE0
	call LABEL_1B6B
	ld hl, DATA_55D
	ld de, $E500
	ld bc, $0014
	ldir
	ld b, $5A
LABEL_439:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_439
	ld hl, $3DA9
	ld de, DATA_1FE8
	call LABEL_1B6B
	ld hl, LABEL_D97
	ld ($E09E), hl
	ld hl, $E09E
	ld ($E080), hl
	ld hl, LABEL_E8E
	ld ($E0BE), hl
	ld hl, $E0BE
	ld ($E0A0), hl
	ld hl, LABEL_FC8
	ld ($E0DE), hl
	ld hl, $E0DE
	ld ($E0C0), hl
	call LABEL_1B45
	xor a
	ld ($E580), a
	ld ($E592), a
	ld ($E597), a
	ld ($E59C), a
	ld ($E59A), a
	ld a, $01
	ld ($E593), a
LABEL_485:
	call LABEL_1B31
	call LABEL_4B0
	ld a, ($E403)
	and a
	jp nz, LABEL_585
	ld a, ($E404)
	and a
	jp nz, LABEL_5F9
	jr LABEL_485

LABEL_49B:
	ld a, ($E401)
	cp $0F
	jr c, LABEL_4A4
	ld a, $0F
LABEL_4A4:
	add a, a
	add a, l
	ld l, a
	jr nc, LABEL_4AA
	inc h
LABEL_4AA:
	ld bc, $0002
	ldir
	ret

LABEL_4B0:
	ld a, ($E597)
	and a
	jr z, LABEL_50D
	ld hl, $E580
	dec (hl)
	ld a, ($E59C)
	and a
	jr nz, LABEL_50D
	ld hl, $E598
	inc (hl)
	ld a, (hl)
	cp $3C
	jr z, LABEL_4CC
	inc hl
	jr LABEL_4D0

LABEL_4CC:
	ld (hl), $00
	inc hl
	inc (hl)
LABEL_4D0:
	ld de, DATA_55D + $0014
	ld a, ($E401)
	cp $13
	jr c, LABEL_4DC
	ld a, $13
LABEL_4DC:
	add a, e
	ld e, a
	jr nc, LABEL_4E1
	inc d
LABEL_4E1:
	ld a, (de)
	sub (hl)
	jr nz, LABEL_504
	ld ($E597), a
	ld ($E59A), a
	ld a, ($E22F)
	ld ($E230), a
	ld a, ($E24F)
	ld ($E250), a
	ld a, ($E26F)
	ld ($E270), a
	ld a, ($E28F)
	ld ($E290), a
	ret

LABEL_504:
	cp $03
	ret nc
	ld a, $01
	ld ($E59A), a
	ret

LABEL_50D:
	ld a, ($E580)
	cp $3C
	ret nz
	xor a
	ld ($E580), a
	ld hl, $E592
	inc (hl)
	ld a, (hl)
	cp $03
	jr nz, LABEL_523
	ld ($E273), a
LABEL_523:
	cp $06
	jr nz, LABEL_52A
	ld ($E293), a
LABEL_52A:
	cp $09
	jr z, LABEL_54A
	jr c, LABEL_557
	cp $1D
	jr z, LABEL_552
	jr c, LABEL_54F
	cp $24
	jr z, LABEL_54A
	jr c, LABEL_557
	cp $38
	jr z, LABEL_552
	jr c, LABEL_54F
	cp $3D
	jr z, LABEL_54A
	jr c, LABEL_557
	jr LABEL_54F

LABEL_54A:
	ld a, $01
	ld ($E596), a
LABEL_54F:
	xor a
	jr LABEL_559

LABEL_552:
	ld a, $01
	ld ($E596), a
LABEL_557:
	ld a, $01
LABEL_559:
	ld ($E593), a
	ret

; Data from 55D to 584 (40 bytes)
DATA_55D:
	.db $3C, $54, $80, $06, $54, $54, $88, $0D, $4C, $5C, $88, $07, $4C, $4C, $88, $09
	.db $84, $54, $10, $0A, $08, $07, $06, $05, $08, $04, $04, $04, $08, $03, $03, $02
	.db $02, $02, $01, $01, $00, $01, $00, $00

LABEL_585:
	call LABEL_1B4C
	xor a
	ld ($E408), a
	ld ($E597), a
	ld b, $3C
LABEL_591:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_591
	call LABEL_1BC7
	ld b, $10
LABEL_59D:
	push bc
	call LABEL_1B31
	ld a, ($E580)
	ld c, a
	and $07
	jr z, LABEL_5AC
	pop bc
	jr LABEL_59D

LABEL_5AC:
	pop bc
	push bc
	bit 0, b
	jr nz, LABEL_5B6
	ld.lil hl, White_Color + romStart
	jr LABEL_5B8

Blue_Color:
	.dw $AD5B
White_Color:
	.dw $6739

LABEL_5B6:
	ld.lil hl, Blue_Color + romStart
LABEL_5B8:
	ld.lil de, $E30208
	ld bc, $0002
	ldir.lil
	pop bc
	djnz LABEL_59D
	ld b, $78
LABEL_5C6:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_5C6
	call LABEL_68F
	xor a
	ld ($E59F), a
	ld hl, DATA_2015
	ld de, $E410
	ld bc, $0070
	ldir
	xor a
	ld ($E403), a
	ld ($E404), a
	ld ($E5B0), a
	ld hl, $E401
	inc (hl)
	call LABEL_1B77
	call LABEL_1BDD
	call LABEL_1D23
	jp LABEL_3E6

LABEL_5F9:
	call LABEL_1B4C
	xor a
	ld ($E597), a
	ld b, $3C
LABEL_602:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_602
	ld a, $E0
	ld ($E500), a
	ld ($E504), a
	ld ($E508), a
	ld ($E50C), a
	ld ($E514), a
	ld b, $1E
LABEL_61C:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_61C
	ld a, $01
	ld ($E605), a
	ld bc, $0C08
LABEL_62B:
	push bc
	call LABEL_1B31
	pop bc
	dec c
	jr nz, LABEL_62B
	ld c, $08
	ld hl, DATA_668
	ld a, b
	dec a
	add a, l
	ld l, a
	jr nc, LABEL_63F
	inc h
LABEL_63F:
	ld a, (hl)
	ld ($E512), a
	djnz LABEL_62B
	ld b, $3C
LABEL_647:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_647
	call LABEL_1BC7
	xor a
	ld ($E403), a
	ld ($E404), a
	ld a, ($E400)
	and a
	jr z, LABEL_674
	ld hl, $E400
	dec (hl)
	call LABEL_1CD2
	jp LABEL_3E6

; Data from 668 to 673 (12 bytes)
DATA_668:
	.db $2C, $48, $44, $40, $3C, $38, $34, $30, $28, $24, $0C, $08

LABEL_674:
	call LABEL_1BBC
	call LABEL_1BC7
	ld hl, $3D6C
	ld de, DATA_1FF0
	call LABEL_1B6B
	ld b, $78
LABEL_685:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_685
	jp LABEL_2D9

LABEL_68F:
	ld a, $01
	ld ($E59F), a
	xor a
	ld ($E230), a
	ld ($E250), a
	ld ($E270), a
	ld ($E290), a
	ld a, ($E401)
	cp $01
	jr z, LABEL_6BC
	cp $04
	jr z, LABEL_6B7
	cp $08
	ret c
	and $03
	ret nz
	call LABEL_A3D
	jr LABEL_6BF

LABEL_6B7:
	call LABEL_939
	jr LABEL_6BF

LABEL_6BC:
	call LABEL_6F6
LABEL_6BF:
	ld hl, $3C37
	ld de, DATA_1FB5
	call LABEL_1B6B
	call LABEL_1C80
	ld hl, $3C5D
	ld a, $30
	call WRITEVRAM
	ld hl, $3CB9
	ld de, DATA_1FAE
	call LABEL_1B6B
	ld de, DATA_6F4
	call LABEL_1C23
	ld a, $30
	ld hl, $3CDD
	call WRITEVRAM
	call LABEL_1CD2
	ret

; Data from 6F4 to 6F5 (2 bytes)
DATA_6F4:
	.db $00, $00

LABEL_6F6:
	call LABEL_1BBC
	ld hl, DATA_26D7 + $0302
	ld ($E59D), hl
	ld hl, $1E00
	ld de, DATA_901
	ld b, $30
	call LABEL_7F3
	call LABEL_813
	ld a, $01
	ld ($E609), a
	ld ($E60A), a
	jp LABEL_71B

LABEL_718:
	call LABEL_1B31
LABEL_71B:
	call LABEL_841
	ld a, ($E202)
	cp $C4
	jr nc, LABEL_718
	xor a
	ld ($E230), a
	ld ($E22F), a
	ld ($E593), a
	jp LABEL_735

LABEL_732:
	call LABEL_1B31
LABEL_735:
	call LABEL_841
	call LABEL_863
	ld a, ($E202)
	and a
	jr nz, LABEL_732
	ld a, $E0
	ld ($E510), a
	jp LABEL_74C

LABEL_749:
	call LABEL_1B31
LABEL_74C:
	call LABEL_863
	ld a, ($E222)
	and a
	jp p, LABEL_749
	ld a, $E0
	ld ($E500), a
	jp LABEL_761

LABEL_75E:
	call LABEL_1B31
LABEL_761:
	ld a, ($E609)
	and a
	jr nz, LABEL_75E
	ld b, $04
LABEL_769:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_769
	ld a, $01
	ld ($E609), a
	ld ($E60A), a
	ld ($E230), a
	ld ($E226), a
	xor a
	ld ($E227), a
	jp LABEL_788

LABEL_785:
	call LABEL_1B31
LABEL_788:
	call LABEL_885
	ld a, ($E222)
	cp $40
	jr c, LABEL_785
	ld a, $01
	ld ($E246), a
	ld a, $30
	ld ($E247), a
	xor a
	ld ($E241), a
	ld ($E242), a
	ld ($E243), a
	ld hl, DATA_8F1
	ld de, $E504
	ld bc, $0010
	ldir
	jp LABEL_7B7

LABEL_7B4:
	call LABEL_1B31
LABEL_7B7:
	call LABEL_885
	call LABEL_8A5
	ld a, ($E222)
	cp $F0
	jr nz, LABEL_7B4
	ld a, $E0
	ld ($E500), a
	jp LABEL_7CF

LABEL_7CC:
	call LABEL_1B31
LABEL_7CF:
	call LABEL_8A5
	ld a, ($E242)
	cp $EF
	jr c, LABEL_7CC
	ld hl, $E504
	ld (hl), $E0
	ld de, $E504 + 1
	ld bc, $000F
	ldir
	jp LABEL_7EC

LABEL_7E9:
	call LABEL_1B31
LABEL_7EC:
	ld a, ($E609)
	and a
	jr nz, LABEL_7E9
	ret

LABEL_7F3:
	push bc
	ld a, (de)
	push de
	ld c, a
	ld b, $00
	push hl
	ld hl, ($E59D)
	add hl, bc
	ex de, hl
	pop hl
	ld bc, $0008
	call LABEL_1B73
	jr nc, LABEL_80D
	inc h
LABEL_80D:
	pop de
	inc de
	pop bc
	djnz LABEL_7F3
	ret

LABEL_813:
	ld a, $60
	ld ($E200), a
	ld ($E220), a
	ld a, $F0
	ld ($E202), a
	ld ($E222), a
	ld a, $01
	ld ($E206), a
	ld ($E226), a
	xor a
LABEL_82C:
	ld ($E201), a
	ld ($E203), a
	ld ($E207), a
	ld ($E221), a
	ld ($E223), a
	ld a, $28
	ld ($E227), a
	ret

LABEL_841:
	ld ix, $E200
	ld h, (ix+2)
	ld l, (ix+3)
	ld d, (ix+6)
	ld e, (ix+7)
	and a
	sbc hl, de
	ld (ix+2), h
	ld (ix+3), l
	ld a, $04
	ld (ix+8), a
	call LABEL_C66
	ret

LABEL_863:
	ld ix, $E220
	ld h, (ix+2)
	ld l, (ix+3)
	ld d, (ix+6)
	ld e, (ix+7)
	and a
	sbc hl, de
	ld (ix+2), h
	ld (ix+3), l
	ld a, $04
	ld (ix+8), a
	call LABEL_1692
	ret

LABEL_885:
	ld ix, $E220
	ld h, (ix+2)
	ld l, (ix+3)
	ld d, (ix+6)
	ld e, (ix+7)
	add hl, de
	ld (ix+2), h
	ld (ix+3), l
	ld a, $01
	ld (ix+8), a
	call LABEL_1692
	ret

LABEL_8A5:
	ld ix, $E240
	ld h, (ix+2)
	ld l, (ix+3)
	ld d, (ix+6)
	ld e, (ix+7)
	add hl, de
	ld (ix+2), h
	ld (ix+3), l
	ld a, h
	ld ($E505), a
	ld ($E509), a
	add a, $10
	ld ($E50D), a
	ld ($E511), a
	inc (ix+11)
	ld a, (ix+11)
	srl a
	and $07
	ld hl, DATA_931
	add a, l
	ld l, a
	jr nc, LABEL_8DD
	inc h
LABEL_8DD:
	ld a, (hl)
	ld ($E506), a
	add a, $0C
	ld ($E50A), a
	add a, $0C
	ld ($E50E), a
	add a, $0C
	ld ($E512), a
	ret

; Data from 8F1 to 900 (16 bytes)
DATA_8F1:
	.db $58, $00, $00, $0A, $68, $00, $00, $0A, $58, $00, $00, $0A, $68, $00, $00, $0A

; Data from 901 to 930 (48 bytes)
DATA_901:
	.db $00, $08, $10, $18, $00, $08, $10, $98, $00, $08, $10, $68, $20, $28, $18, $30
	.db $20, $28, $18, $30, $20, $28, $70, $30, $38, $18, $40, $48, $38, $A0, $40, $A8
	.db $78, $80, $C0, $C0, $18, $50, $58, $60, $B0, $50, $B8, $60, $88, $90, $C0, $C0

; Data from 931 to 938 (8 bytes)
DATA_931:
	.db $C4, $C4, $C8, $C8, $C8, $C4, $C0, $C0

LABEL_939:
	call LABEL_1BBC
	ld hl, DATA_26D7 + $03CA
	ld ($E59D), hl
	ld hl, $1E00
	ld de, DATA_A1D
	ld b, $20
	call LABEL_7F3
	ld hl, $3DB1
	ld a, $9C
	call WRITEVRAM
	call LABEL_813
	ld a, $01
	ld ($E609), a
	ld ($E60A), a
	jp LABEL_969

LABEL_966:
	call LABEL_1B31
LABEL_969:
	call LABEL_841
	ld a, ($E202)
	cp $C8
	jr nc, LABEL_966
	xor a
	ld ($E230), a
	ld ($E22F), a
	ld ($E593), a
	jp LABEL_983

LABEL_980:
	call LABEL_1B31
LABEL_983:
	call LABEL_841
	call LABEL_863
	ld a, ($E222)
	cp $80
	jr nc, LABEL_980
	ld hl, $E500
	ld de, $E504
	ld bc, $0004
	ldir
	ld a, $D0
	ld ($E502), a
	ld a, $C0
	ld ($E506), a
	xor a
	ld ($E22B), a
	ld ($E224), a
	jp LABEL_9B2

LABEL_9AF:
	call LABEL_1B31
LABEL_9B2:
	call LABEL_841
	ld hl, $E22B
	inc (hl)
	ld a, (hl)
	cp $10
	jr nz, LABEL_9AF
	ld (hl), $00
	ld hl, $E501
	dec (hl)
	ld hl, $E224
	inc (hl)
	bit 0, (hl)
	jr nz, LABEL_9AF
	ld hl, $E506
	ld a, $04
	add a, (hl)
	ld (hl), a
	cp $CC
	jr nz, LABEL_9AF
	ld hl, $E500
	ld de, $E508
	ld bc, $0004
	ldir
	ld a, $D4
	ld ($E502), a
	ld a, $DC
	ld ($E50A), a
	ld a, $0B
	ld ($E50B), a
	jp LABEL_9F7

LABEL_9F4:
	call LABEL_1B31
LABEL_9F7:
	call LABEL_841
	ld a, ($E202)
	and a
	jr nz, LABEL_9F4
	ld a, $E0
	ld ($E510), a
	ld b, $2D
LABEL_A07:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_A07
	ld a, $D8
	ld ($E502), a
	ld b, $3C
LABEL_A15:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_A15
	ret

; Data from A1D to A3C (32 bytes)
DATA_A1D:
	.db $00, $00, $00, $08, $00, $00, $00, $10, $00, $00, $00, $18, $00, $00, $00, $20
	.db $28, $30, $38, $40, $48, $50, $58, $60, $68, $70, $78, $80, $00, $00, $00, $88

LABEL_A3D:
	call LABEL_1BBC
	ld hl, DATA_26D7 + $045A
	ld ($E59D), hl
	ld hl, $1E00
	ld de, DATA_B60
	ld b, $1C
	call LABEL_7F3
	call LABEL_813
	ld a, $01
	ld ($E609), a
	ld ($E60A), a
	jp LABEL_A62

LABEL_A5F:
	call LABEL_1B31
LABEL_A62:
	call LABEL_841
	ld a, ($E202)
	cp $C4
	jr nc, LABEL_A5F
	xor a
	ld ($E230), a
	ld ($E22F), a
	ld ($E593), a
	jp LABEL_A7C

LABEL_A79:
	call LABEL_1B31
LABEL_A7C:
	call LABEL_841
	call LABEL_863
	ld hl, $E500
	ld de, $E504
	ld bc, $0004
	ldir
	ld a, ($E502)
	add a, $40
	ld ($E502), a
	ld a, $C8
	ld ($E506), a
	ld a, $0F
	ld ($E507), a
	ld a, ($E202)
	and a
	jr nz, LABEL_A79
	ld a, $E0
	ld ($E510), a
	jp LABEL_AB0

LABEL_AAD:
	call LABEL_1B31
LABEL_AB0:
	call LABEL_863
	ld hl, $E500
	ld de, $E504
	ld bc, $0004
	ldir
	ld a, ($E502)
	add a, $40
	ld ($E502), a
	ld a, $C8
	ld ($E506), a
	ld a, $0F
	ld ($E507), a
	ld a, ($E222)
	and a
	jp p, LABEL_AAD
	ld a, $E0
	ld ($E500), a
	jp LABEL_AE2

LABEL_ADF:
	call LABEL_1B31
LABEL_AE2:
	ld a, ($E609)
	and a
	jr nz, LABEL_ADF
	ld b, $04
LABEL_AEA:
	push bc
	call LABEL_1B31
	pop bc
	djnz LABEL_AEA
	ld a, $01
	ld ($E609), a
	ld ($E60A), a
	ld ($E226), a
	xor a
	ld ($E227), a
	ld a, $D4
	ld ($E506), a
	ld a, $D8
	ld ($E50A), a
	ld a, $0A
	ld ($E222), a
	jp LABEL_B15

LABEL_B12:
	call LABEL_1B31
LABEL_B15:
	call LABEL_885
	ld a, ($E502)
	add a, $5C
	ld ($E502), a
	ld a, $0B
	ld ($E503), a
	ld a, ($E500)
	ld ($E504), a
	ld ($E508), a
	ld a, ($E501)
	ld ($E505), a
	sub $0A
	ld ($E509), a
	ld a, $06
	ld ($E507), a
	ld ($E50B), a
	ld a, ($E222)
	cp $F0
	jr c, LABEL_B12
	ld a, $E0
	ld ($E500), a
	ld ($E504), a
	ld ($E508), a
	jp LABEL_B59

LABEL_B56:
	call LABEL_1B31
LABEL_B59:
	ld a, ($E609)
	and a
	jr nz, LABEL_B56
	ret

; Data from B60 to B7B (28 bytes)
DATA_B60:
	.db $08, $10, $18, $20, $28, $30, $38, $40, $00, $00, $00, $48, $50, $58, $60, $68
	.db $50, $70, $60, $78, $00, $00, $80, $00, $00, $88, $00, $90

LABEL_B7C:
	call LABEL_1B31
	ld a, ($E5B0)
	and a
	jr z, LABEL_B7C
	ld a, ($E581)
	and $0F
	ld ($E209), a
	ld ix, $E200
	call LABEL_133A
	ld a, ($E20A)
	cp $02
	jr c, LABEL_BA2
	ld a, $E0
	ld ($E510), a
	jr LABEL_B7C

LABEL_BA2:
	ld a, ($E202)
	ld ($E589), a
	ld a, ($E200)
	ld ($E585), a
	xor a
	ld ($E584), a
	ld ($E588), a
	ld a, ($E208)
	and $05
	jr z, LABEL_BCA
	ld c, $04
	bit 2, a
	jr z, LABEL_BC6
	ld b, $08
	jr LABEL_BD6

LABEL_BC6:
	ld b, $07
	jr LABEL_BD6

LABEL_BCA:
	ld b, $04
	bit 1, a
	jr z, LABEL_BD4
	ld c, $08
	jr LABEL_BD6

LABEL_BD4:
	ld c, $07
LABEL_BD6:
	call LABEL_1946
	cp $95
	jr z, LABEL_C2A
	cp $96
	jr z, LABEL_BE6
	cp $97
	jp nz, LABEL_C5D
LABEL_BE6:
	ld b, $04
	ld de, $E411
LABEL_BEB:
	push bc
	push hl
	ld a, (de)
	ld c, a
	inc de
	ld a, (de)
	ld b, a
	and a
	sbc hl, bc
	jr z, LABEL_BFF
	pop hl
	pop bc
	inc de
	inc de
	djnz LABEL_BEB
LABEL_BFD:
	jr LABEL_BFD

LABEL_BFF:
	pop hl
	pop bc
	dec de
	dec de
	ld a, $01
	ld (de), a
	ld ($E597), a
	ld ($E596), a
	ld ($E230), a
	ld ($E250), a
	ld ($E270), a
	ld ($E290), a
	xor a
	ld ($E598), a
	ld ($E599), a
	ld ($E59A), a
	ld ($E59B), a
	ld de, DATA_21ED + 2
	jr LABEL_C2D

LABEL_C2A:
	ld de, DATA_21ED
LABEL_C2D:
	push hl
	call LABEL_1C23
	pop hl
	ld a, $20
	ld ($E603), a
	call WRITEVRAM
	ld a, $03
	ld (DrawTilemapTrig), a
	ld a, ($E408)
	inc a
	ld ($E408), a
	cp $32
	jr z, LABEL_C4C
	cp $6E
	jr nz, LABEL_C51
LABEL_C4C:
	ld ($E2A6), a
	jr LABEL_C5D

LABEL_C51:
	cp $B2
	jr nz, LABEL_C5D
	ld ($E403), a
	ld a, $06
	ld ($E204), a
LABEL_C5D:
	call LABEL_C66
	call LABEL_196E
	jp LABEL_B7C

LABEL_C66:
	ld hl, $E200
	ld de, $E510
	ld a, (hl)
	ld (de), a
	inc hl
	inc hl
	inc de
	ld a, (hl)
	ld (de), a
	inc hl
	inc hl
	inc de
	inc (hl)
	ld a, (hl)
	and $07
	ld bc, DATA_CA0
	add a, c
	ld c, a
	jr nc, LABEL_C82
	inc b
LABEL_C82:
	ld a, (bc)
	cp $08
	jr nz, LABEL_C8B
	ld a, $20
	jr LABEL_C9A

LABEL_C8B:
	ld c, a
	ld a, ($E208)
	cp $08
	jr nz, LABEL_C94
	dec a
LABEL_C94:
	srl a
	add a, a
	add a, a
	add a, a
	add a, c
LABEL_C9A:
	ld (de), a
	inc hl
	inc de
	ld a, (hl)
	ld (de), a
	ret

; Data from CA0 to CA7 (8 bytes)
DATA_CA0:
	.db $00, $00, $04, $04, $04, $00, $08, $08

LABEL_CA8:
	call LABEL_1B31
	ld a, ($E5B5)
	and a
	jr z, LABEL_CA8
	ld a, ($E41D)
	inc a
	ld ($E41D), a
	ld hl, $E410
	ld b, $04
LABEL_CBD:
	push bc
	ld a, (hl)
	and a
	jr nz, LABEL_CDC
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, $96
	ld c, a
	ld a, ($E41D)
	bit 3, a
	jr nz, LABEL_CD1
	inc c
LABEL_CD1:
	ex de, hl
	ld a, c
	call WRITEVRAM
	ex de, hl
	ld a, 3
	ld (DrawTilemapTrig), a
	jr LABEL_CDE

LABEL_CDC:
	inc hl
	inc hl
LABEL_CDE:
	inc hl
	pop bc
	djnz LABEL_CBD
	jp LABEL_CA8

LABEL_CE5:
	call LABEL_1B31
	ld a, ($E5B1)
	and a
	jr z, LABEL_CE5
	ld a, ($E59C)
	and a
	jr z, $+4
	cp $01
	jr nz, LABEL_CE5
LABEL_CF9:
	ld ix, $E220
	ld a, $01
	ld ($E60B), a
	ld a, ($E596)
	and a
	jr z, LABEL_D19
	ld a, ($E228)
	ld c, a
	and $05
	jr z, LABEL_D13
	ld a, $05
	jr LABEL_D15

LABEL_D13:
	ld a, $0A
LABEL_D15:
	xor c
	ld ($E228), a
LABEL_D19:
	ld a, (ix+16)
	and a
	jr nz, LABEL_D36
	ld a, ($E593)
	and a
	jr z, LABEL_D36
	ld a, $88
	ld ($E594), a
	ld a, $08
	ld ($E595), a
	ld a, $03
	ld ($E20E), a
	jr LABEL_D42

LABEL_D36:
	ld a, ($E202)
	ld ($E594), a
	ld a, ($E200)
	ld ($E595), a
LABEL_D42:
	call LABEL_1709
	ld a, ($E230)
	and a
	jp z, LABEL_D5D
	call LABEL_1ACD
	and a
	jr z, LABEL_D60
	ld a, $01
	ld ($E59C), a
	call LABEL_198E
	jp LABEL_CE5

LABEL_D5D:
	call LABEL_1AFB
LABEL_D60:
	ld a, ($E22A)
	and a
	jr z, LABEL_D7D
	push af
	ld hl, DATA_21ED - $0020
	ld de, $E226
	call LABEL_49B
	pop af
	cp $01
	jr z, LABEL_D91
	ld a, $E0
	ld ($E500), a
	jp LABEL_CE5

LABEL_D7D:
	ld a, ($E230)
	and a
	jr z, LABEL_D88
	ld hl, DATA_21ED - $0020
	jr LABEL_D8B

LABEL_D88:
	ld hl, DATA_21ED - $0040
LABEL_D8B:
	ld de, $E226
	call LABEL_49B
LABEL_D91:
	call LABEL_1692
	jp LABEL_CE5

LABEL_D97:
	call LABEL_1B31
	ld a, ($E5B2)
	and a
	jr z, LABEL_D97
	ld ix, $E240
	call LABEL_1A7F
LABEL_DA7:
	call LABEL_1B31
	ld a, ($E5B2)
	and a
	jr z, LABEL_DA7
	ld a, ($E59C)
	and a
	jr z, LABEL_DBA
	cp $02
	jr nz, LABEL_DA7
LABEL_DBA:
	ld ix, $E240
	ld a, ($E596)
	and a
	jr z, LABEL_DD6
	ld a, ($E248)
	ld c, a
	and $05
	jr z, LABEL_DD0
	ld a, $05
	jr LABEL_DD2

LABEL_DD0:
	ld a, $0A
LABEL_DD2:
	xor c
	ld ($E248), a
LABEL_DD6:
	ld a, ($E250)
	and a
	jr nz, LABEL_DF3
	ld a, ($E593)
	and a
	jr z, LABEL_DF3
	ld a, $20
	ld ($E594), a
	ld a, $08
	ld ($E595), a
	ld a, $06
	ld ($E20E), a
	jr LABEL_E39

LABEL_DF3:
	ld a, ($E202)
	ld b, a
	ld a, ($E200)
	ld c, a
	ld a, ($E208)
	bit 0, a
	jr nz, LABEL_E12
	bit 1, a
	jr nz, LABEL_E2C
	bit 3, a
	jr nz, LABEL_E23
	ld b, a
	sub $18
	jr nc, LABEL_E1A
	xor a
	jr LABEL_E1A

LABEL_E12:
	ld a, $18
	add a, b
	jp nc, LABEL_E1A
	ld a, $F0
LABEL_E1A:
	ld ($E594), a
	ld a, c
	ld ($E595), a
	jr LABEL_E39

LABEL_E23:
	ld a, $18
	add a, c
	jr nc, LABEL_E32
	ld a, $F0
	jr LABEL_E32

LABEL_E2C:
	ld c, a
	sub $18
	jr nc, LABEL_E32
	xor a
LABEL_E32:
	ld ($E595), a
	ld a, b
	ld ($E594), a
LABEL_E39:
	call LABEL_1709
	ld a, ($E250)
	and a
	jp z, LABEL_E54
	call LABEL_1ACD
	and a
	jr z, LABEL_E57
	ld a, $02
	ld ($E59C), a
	call LABEL_198E
	jp LABEL_DA7

LABEL_E54:
	call LABEL_1AFB
LABEL_E57:
	ld a, ($E24A)
	and a
	jr z, LABEL_E74
	push af
	ld hl, DATA_21ED - $0020
	ld de, $E246
	call LABEL_49B
	pop af
	cp $01
	jr z, LABEL_E88
	ld a, $E0
	ld ($E504), a
	jp LABEL_DA7

LABEL_E74:
	ld a, ($E250)
	and a
	jr z, LABEL_E7F
	ld hl, DATA_21ED - $0020
	jr LABEL_E82

LABEL_E7F:
	ld hl, DATA_21ED - $0040
LABEL_E82:
	ld de, $E246
	call LABEL_49B
LABEL_E88:
	call LABEL_1692
	jp LABEL_DA7

LABEL_E8E:
	call LABEL_1B31
	ld a, ($E5B3)
	and a
	jr z, LABEL_E8E
	ld ix, $E260
	ld a, ($E273)
	and a
	jp nz, LABEL_ED7
	ld a, ($E260)
	ld c, a
	ld a, ($E268)
	bit 1, a
	jr nz, LABEL_EBD
	ld a, c
	inc a
	ld ($E260), a
	cp $54
	jr nz, LABEL_ECB
	ld a, $02
	ld ($E268), a
	jr LABEL_ECB

LABEL_EBD:
	ld a, c
	dec a
	ld ($E260), a
	cp $4C
	jr nz, LABEL_ECB
	ld a, $08
	ld ($E268), a
LABEL_ECB:
	call LABEL_1692
	jr LABEL_E8E

LABEL_ED0:
	call LABEL_1B31
	ld ix, $E260
LABEL_ED7:
	ld a, $04
	ld ($E268), a
	call LABEL_1692
	ld a, ($E262)
	dec a
	ld ($E262), a
	cp $54
	jr nz, LABEL_ED0
	call LABEL_1A7F
LABEL_EED:
	call LABEL_1B31
	ld a, ($E5B3)
	and a
	jr z, LABEL_EED
	ld a, ($E59C)
	and a
	jr z, LABEL_F00
	cp $03
	jr nz, LABEL_EED
LABEL_F00:
	ld ix, $E260
	ld a, ($E596)
	and a
	jr z, LABEL_F1C
	ld a, ($E268)
	ld c, a
	and $05
	jr z, LABEL_F16
	ld a, $05
	jr LABEL_F18

LABEL_F16:
	ld a, $0A
LABEL_F18:
	xor c
	ld ($E268), a
LABEL_F1C:
	ld a, ($E270)
	and a
	jr nz, LABEL_F39
	ld a, ($E593)
	and a
	jr z, LABEL_F39
	ld a, $90
	ld ($E594), a
	ld a, $B0
	ld ($E595), a
	ld a, $09
	ld ($E20E), a
	jr LABEL_F73

LABEL_F39:
	ld a, ($E202)
	ld b, a
	ld hl, $E262
	sub (hl)
	jp m, LABEL_F4B
	add a, b
	jr nc, LABEL_F53
	ld a, $F0
	jr LABEL_F53

LABEL_F4B:
	neg
	ld c, a
	ld a, b
	sub c
	jr nc, LABEL_F53
	xor a
LABEL_F53:
	ld ($E594), a
	ld a, ($E200)
	ld b, a
	ld hl, $E260
	sub (hl)
	jp m, LABEL_F68
	add a, b
	jr nc, LABEL_F70
	ld a, $F0
	jr LABEL_F70

LABEL_F68:
	neg
	ld c, a
	ld a, b
	sub c
	jr nc, LABEL_F70
	xor a
LABEL_F70:
	ld ($E595), a
LABEL_F73:
	call LABEL_1709
	ld a, ($E270)
	and a
	jp z, LABEL_F8E
	call LABEL_1ACD
	and a
	jr z, LABEL_F91
	ld a, $03
	ld ($E59C), a
	call LABEL_198E
	jp LABEL_EED

LABEL_F8E:
	call LABEL_1AFB
LABEL_F91:
	ld a, ($E26A)
	and a
	jr z, LABEL_FAE
	push af
	ld hl, DATA_21ED - $0020
	ld de, $E266
	call LABEL_49B
	pop af
	cp $01
	jr z, LABEL_FC2
	ld a, $E0
	ld ($E508), a
	jp LABEL_EED

LABEL_FAE:
	ld a, ($E270)
	and a
	jr z, LABEL_FB9
	ld hl, DATA_21ED - $0020
	jr LABEL_FBC

LABEL_FB9:
	ld hl, DATA_21ED - $0040
LABEL_FBC:
	ld de, $E266
	call LABEL_49B
LABEL_FC2:
	call LABEL_1692
	jp LABEL_EED

LABEL_FC8:
	call LABEL_1B31
	ld a, ($E5B4)
	and a
	jr z, LABEL_FC8
	ld ix, $E280
	ld a, ($E293)
	and a
	jp nz, LABEL_1011
	ld a, ($E280)
	ld c, a
	ld a, ($E288)
	bit 1, a
	jr nz, LABEL_FF7
	ld a, c
	inc a
	ld ($E280), a
	cp $54
	jr nz, LABEL_1005
	ld a, $02
	ld ($E288), a
	jr LABEL_1005

LABEL_FF7:
	ld a, c
	dec a
	ld ($E280), a
	cp $4C
	jr nz, LABEL_1005
	ld a, $08
	ld ($E288), a
LABEL_1005:
	call LABEL_1692
	jr LABEL_FC8

LABEL_100A:
	call LABEL_1B31
	ld ix, $E280
LABEL_1011:
	ld a, $01
	ld ($E288), a
	call LABEL_1692
	ld a, ($E282)
	inc a
	ld ($E282), a
	cp $54
	jr nz, LABEL_100A
	call LABEL_1A7F
LABEL_1027:
	call LABEL_1B31
	ld a, ($E5B4)
	and a
	jr z, LABEL_1027
	ld a, ($E59C)
	and a
	jr z, LABEL_103A
	cp $04
	jr nz, LABEL_1027
LABEL_103A:
	ld ix, $E280
	ld a, ($E596)
	and a
	jr z, LABEL_1056
	ld a, ($E288)
	ld c, a
	and $05
	jr z, LABEL_1050
	ld a, $05
	jr LABEL_1052

LABEL_1050:
	ld a, $0A
LABEL_1052:
	xor c
	ld ($E288), a
LABEL_1056:
	ld a, ($E290)
	and a
	jr nz, LABEL_1073
	ld a, ($E593)
	and a
	jr z, LABEL_1073
	ld a, $20
	ld ($E594), a
	ld a, $B0
	ld ($E595), a
	ld a, $0C
	ld ($E20E), a
	jr LABEL_107F

LABEL_1073:
	ld a, ($E202)
	ld ($E594), a
	ld a, ($E200)
	ld ($E595), a
LABEL_107F:
	call LABEL_1709
	ld a, ($E290)
	and a
	jp z, LABEL_109A
	call LABEL_1ACD
	and a
	jr z, LABEL_109D
	ld a, $04
	ld ($E59C), a
	call LABEL_198E
	jp LABEL_1027

LABEL_109A:
	call LABEL_1AFB
LABEL_109D:
	ld a, ($E28A)
	and a
	jr z, LABEL_10BA
	push af
	ld hl, DATA_21ED - $0020
	ld de, $E286
	call LABEL_49B
	pop af
	cp $01
	jr z, LABEL_10CE
	ld a, $E0
	ld ($E50C), a
	jp LABEL_1027

LABEL_10BA:
	ld a, ($E290)
	and a
	jr z, LABEL_10C5
	ld hl, DATA_21ED - $0020
	jr LABEL_10C8

LABEL_10C5:
	ld hl, DATA_21ED - $0040
LABEL_10C8:
	ld de, $E286
	call LABEL_49B
LABEL_10CE:
	call LABEL_1692
	jp LABEL_1027

LABEL_10D4:
	call LABEL_1B31
LABEL_10D7:
	ld a, ($E2A6)
	and a
	jr nz, LABEL_10E4
LABEL_10DD:
	ld a, $E0
	ld ($E514), a
	jr LABEL_10D4

LABEL_10E4:
	xor a
	ld ($E2A6), a
	ld a, ($E401)
	cp $0C
	jr c, LABEL_10F1
	ld a, $0C
LABEL_10F1:
	add a, a
	ld ($E2A8), a
	ld hl, $E514
	ld (hl), $64
	inc hl
	ld (hl), $54
	ld de, DATA_1186
	add a, e
	ld e, a
	jr nc, LABEL_1105
	inc d
LABEL_1105:
	ld a, (de)
	inc hl
	ld (hl), a
	inc de
	ld a, (de)
	inc hl
	ld (hl), a
	ld bc, $0002
LABEL_110F:
	push bc
	call LABEL_1B31
	ld a, ($E200)
	cp $64
	jr nz, LABEL_1128
	ld a, ($E202)
	sub $54
	jp p, LABEL_1124
	neg
LABEL_1124:
	cp $04
	jr c, LABEL_1130
LABEL_1128:
	pop bc
	djnz LABEL_110F
	dec c
	jr nz, LABEL_110F
	jr LABEL_10DD

LABEL_1130:
	ld a, $01
	ld ($E604), a
	pop bc
	ld de, DATA_21F9
	ld a, ($E2A8)
	add a, e
	ld e, a
	jr nc, LABEL_1141
	inc d
LABEL_1141:
	call LABEL_1C23
	ld a, $E0
	ld ($E514), a
	ld b, $78
LABEL_114B:
	push bc
	call LABEL_1B31
	pop bc
	push bc
	ld a, b
	and $03
	jr nz, LABEL_1180
	ld hl, $3DA9
	ld a, b
	bit 2, a
	jr nz, LABEL_117A
	ld de, DATA_11BA - $1A
	ld a, ($E2A8)
	add a, e
	ld e, a
	jr nc, LABEL_1169
	inc d
LABEL_1169:
	ld bc, $0002
	call LABEL_1B73
	ld hl, $3DAB
	ld de, DATA_11BA
	call LABEL_1B6B
	jr LABEL_1180

LABEL_117A:
	ld de, DATA_1FE8
	call LABEL_1B6B
LABEL_1180:
	pop bc
	djnz LABEL_114B
	jp LABEL_10D4

; Data from 1186 to 11B9 (52 bytes)
DATA_1186:
	.db $50, $06, $54, $09, $58, $09, $58, $09, $5C, $06, $5C, $06, $60, $02, $60, $02
	.db $64, $0A, $64, $0A, $68, $0A, $68, $0A, $6C, $07, $20, $31, $20, $33, $20, $35
	.db $20, $35, $20, $37, $20, $37, $31, $30, $31, $30, $32, $30, $32, $30, $33, $30
	.db $33, $30, $35, $30

; Data from 11BA to 11BD (4 bytes)
DATA_11BA:
	.db $02, $00, $30, $30

LABEL_11BE:
	call LABEL_1B31
LABEL_11C1:
	ld hl, $E620
	xor a
	ld b, $03
LABEL_11C7:
	ld e, (hl)
	; call BIOS_0093
	inc l
	inc a
	ld e, (hl)
	; call BIOS_0093
	inc l
	inc l
	inc a
	djnz LABEL_11C7
	ld hl, $E622
	ld a, $08
	ld b, $03
LABEL_11DD:
	ld e, (hl)
	; call BIOS_0093
	inc l
	inc l
	inc l
	inc a
	djnz LABEL_11DD
	ld hl, $E620
	ld (hl), $00
	ld de, $E620 + 1
	ld bc, $0008
	ldir
	ld a, ($E600)
	and a
	jr z, LABEL_1200
	ld hl, DATA_12B8
	call LABEL_1DB4
LABEL_1200:
	ld a, ($E601)
	and a
	jr z, LABEL_120C
	ld hl, DATA_12C2
	call LABEL_1DB4
LABEL_120C:
	ld a, ($E609)
	and a
	jr z, LABEL_1218
	ld hl, DATA_131C
	call LABEL_1DB4
LABEL_1218:
	ld a, ($E60A)
	and a
	jr z, LABEL_1224
	ld hl, DATA_1326
	call LABEL_1DB4
LABEL_1224:
	ld a, ($E602)
	and a
	jr z, LABEL_1230
	ld hl, DATA_12CC
	call LABEL_1DB4
LABEL_1230:
	ld a, ($E603)
	and a
	jr z, LABEL_1248
	ld a, ($E408)
	bit 0, a
	jr nz, LABEL_1242
	ld hl, DATA_12E0
	jr LABEL_1245

LABEL_1242:
	ld hl, DATA_12D6
LABEL_1245:
	call LABEL_1DB4
LABEL_1248:
	ld a, ($E604)
	and a
	jr z, LABEL_1254
	ld hl, DATA_12EA
	call LABEL_1DB4
LABEL_1254:
	ld a, ($E605)
	and a
	jr z, LABEL_1260
	ld hl, DATA_12F4
	call LABEL_1DB4
LABEL_1260:
	ld a, ($E606)
	and a
	jr z, LABEL_126E
	ld hl, DATA_12FE
	call LABEL_1DB4
	jr LABEL_129F

LABEL_126E:
	ld a, ($E608)
	and a
	jr z, LABEL_127F
	ld hl, DATA_1312
	call LABEL_1DB4
	call LABEL_12AD
	jr LABEL_129F

LABEL_127F:
	ld a, ($E597)
	and a
	jr z, LABEL_1290
	ld hl, DATA_1308
	call LABEL_1DB4
	call LABEL_12AD
	jr LABEL_129F

LABEL_1290:
	ld a, ($E60B)
	and a
	jr z, LABEL_129F
	ld hl, DATA_1330
	call LABEL_1DB4
	call LABEL_12A2
LABEL_129F:
	jp LABEL_11BE

LABEL_12A2:
	ld a, ($E625)
	and a
	ret z
	ld a, $09
	ld ($E625), a
	ret

LABEL_12AD:
	ld a, ($E625)
	and a
	ret z
	ld a, $0B
	ld ($E625), a
	ret

; Data from 12B8 to 12C1 (10 bytes)
DATA_12B8:
	.db $40, $E6, $20, $E6
	.dw DATA_26D7 + $04F2
	.db $00, $E6, $10, $E6

; Data from 12C2 to 12CB (10 bytes)
DATA_12C2:
	.db $48, $E6, $23, $E6
	.dw DATA_26D7 + $0537
	.db $01, $E6, $11, $E6

; Data from 12CC to 12D5 (10 bytes)
DATA_12CC:
	.db $50, $E6, $26, $E6 
	.dw DATA_26D7 + $055E
	.db $02, $E6, $12, $E6

; Data from 12D6 to 12DF (10 bytes)
DATA_12D6:
	.db $58, $E6, $20, $E6
	.dw DATA_26D7 + $056F
	.dw $03, $E6, $13, $E6

; Data from 12E0 to 12E9 (10 bytes)
DATA_12E0:
	.db $58, $E6, $20, $E6
	.dw DATA_26D7 + $057A
	.db $03, $E6, $13, $E6

; Data from 12EA to 12F3 (10 bytes)
DATA_12EA:
	.db $60, $E6, $20, $E6
	.dw DATA_26D7 + $0585
	.db $04, $E6, $14, $E6

; Data from 12F4 to 12FD (10 bytes)
DATA_12F4:
	.db $68, $E6, $20, $E6
	.dw DATA_26D7 + $05AC
	.db $05, $E6, $15, $E6

; Data from 12FE to 1307 (10 bytes)
DATA_12FE:
	.db $70, $E6, $23, $E6
	.dw DATA_26D7 + $0642
	.db $06, $E6, $16, $E6

; Data from 1308 to 1311 (10 bytes)
DATA_1308:
	.db $78, $E6, $23, $E6
	.dw DATA_26D7 + $0631
	.db $07, $E6, $17, $E6

; Data from 1312 to 131B (10 bytes)
DATA_1312:
	.db $80, $E6, $23, $E6
	.dw DATA_26D7 + $0663
	.db $08, $E6, $18, $E6

; Data from 131C to 1325 (10 bytes)
DATA_131C:
	.db $88, $E6, $20, $E6
	.dw DATA_26D7 + $067E
	.db $09, $E6, $19, $E6

; Data from 1326 to 132F (10 bytes)
DATA_1326:
	.db $90, $E6, $23, $E6
	.dw DATA_26D7 + $06ED
	.db $0A, $E6, $1A, $E6

; Data from 1330 to 1339 (10 bytes)
DATA_1330:
	.db $98, $E6, $23, $E6
	.dw DATA_26D7 + $078C
	.db $0B, $E6, $1B, $E6

LABEL_133A:
	xor a
	ld (ix+13), a
	ld h, (ix+0)
	ld l, (ix+1)
	ld d, (ix+2)
	ld e, (ix+3)
	ld b, (ix+6)
	ld c, (ix+7)
	ld a, (ix+8)
	bit 3, a
	jp nz, LABEL_1455
	bit 1, a
	jp nz, LABEL_15EB
	bit 0, a
	jp nz, LABEL_14FA
	ld a, (ix+9)
	bit 0, a
	jr z, LABEL_136F
	ld a, $01
	ld (ix+8), a
	ret

LABEL_136F:
	ld ($E584), hl
	ex de, hl
	and a
	sbc hl, bc
	ld ($E586), hl
	ld a, (ix+10)
	and a
	jp nz, LABEL_141C
	ld a, h
	and $F8
	or $04
	ld b, a
	xor a
	ld c, a
	ld ($E588), bc
	ld a, h
	and $07
	cp $05
	jp nc, LABEL_1419
	ld a, (ix+9)
	and a
	jr z, LABEL_13A7
	bit 2, a
	jr nz, LABEL_13A7
	ld a, (ix+2)
	and $07
	cp $04
	jr nc, LABEL_13B9
LABEL_13A7:
	ld bc, $0304
	call LABEL_1946
	jr c, LABEL_1419
	ld a, (ix+12)
	and a
	jr z, LABEL_1414
	ld (ix+13), a
	ret

LABEL_13B9:
	ld a, (ix+9)
	bit 1, a
	jr nz, LABEL_13DC
	ld bc, $040C
	call LABEL_1946
	jp nc, LABEL_144A
	ld bc, $0B0C
	jr nc, LABEL_144A
	ld a, $08
	ld (ix+8), a
	ld a, (ix+0)
	inc a
	ld (ix+0), a
	jr LABEL_1414

LABEL_13DC:
	ld a, (ix+12)
	and a
	jr z, LABEL_13FB
	ld a, ($E585)
	cp $3C
	jr z, LABEL_13ED
	cp $84
	jr nz, LABEL_13FB
LABEL_13ED:
	ld a, ($E589)
	cp $4C
	jr z, LABEL_13F8
	cp $5C
	jr nz, LABEL_13FB
LABEL_13F8:
	jr LABEL_1419
	ret

LABEL_13FB:
	ld bc, $0403
	call LABEL_1946
	jr nc, LABEL_144A
	ld bc, $0B03
	jr nc, LABEL_144A
	ld a, $02
	ld (ix+8), a
	ld a, (ix+0)
	dec a
	ld (ix+0), a
LABEL_1414:
	ld hl, ($E588)
	jr LABEL_141C

LABEL_1419:
	ld hl, ($E586)
LABEL_141C:
	ld a, (ix+0)
	cp $54
	jr nz, LABEL_143F
	ld a, h
	cp $84
	jr nc, LABEL_142C
	cp $24
	jr nc, LABEL_143F
LABEL_142C:
	cp $C9
	jr nc, LABEL_1438
	cp $A8
	jr nc, LABEL_143B
	ld a, $01
	jr LABEL_1440

LABEL_1438:
	ld hl, $C800
LABEL_143B:
	ld a, $02
	jr LABEL_1440

LABEL_143F:
	xor a
LABEL_1440:
	ld (ix+10), a
	ld (ix+2), h
	ld (ix+3), l
	ret

LABEL_144A:
	ld a, (ix+12)
	and a
	jp z, LABEL_13A7
	ld (ix+13), a
	ret

LABEL_1455:
	ld a, (ix+9)
	bit 1, a
	jr z, LABEL_1462
	ld a, $02
	ld (ix+8), a
	ret

LABEL_1462:
	ld ($E588), de
	add hl, bc
	ld ($E582), hl
	ld a, h
	and $F8
	or $04
	ld b, a
	xor a
	ld c, a
	ld ($E584), bc
	ld a, h
	and $07
	cp $04
	jr c, LABEL_14E2
	ld a, (ix+9)
	and a
	jr z, LABEL_1490
	bit 3, a
	jr nz, LABEL_1490
	ld a, (ix+0)
	and $07
	cp $05
	jr c, LABEL_14A2
LABEL_1490:
	ld bc, $040C
	call LABEL_1946
	jr c, LABEL_14E2
	ld a, (ix+12)
	and a
	jr z, LABEL_14DD
	ld (ix+13), a
	ret

LABEL_14A2:
	ld a, (ix+9)
	bit 2, a
	jr nz, LABEL_14C4
	ld bc, $0C04
	call LABEL_1946
	jr nc, LABEL_14F0
	ld bc, $0C0B
	jr nc, LABEL_14F0
	ld a, $01
	ld (ix+8), a
	ld a, (ix+2)
	inc a
	ld (ix+2), a
	jr LABEL_14DD

LABEL_14C4:
	ld bc, $0304
	call LABEL_1946
	jr nc, LABEL_14F0
	ld bc, $030B
	jr nc, LABEL_14F0
	ld a, $04
	ld (ix+8), a
	ld a, (ix+2)
	dec a
	ld (ix+2), a
LABEL_14DD:
	ld hl, ($E584)
	jr LABEL_14E5

LABEL_14E2:
	ld hl, ($E582)
LABEL_14E5:
	ld (ix+0), h
	ld (ix+1), l
	xor a
	ld (ix+10), a
	ret

LABEL_14F0:
	ld a, (ix+12)
	and a
	jr z, LABEL_1490
	ld (ix+13), a
	ret

LABEL_14FA:
	ld a, (ix+9)
	bit 2, a
	jr z, LABEL_1507
	ld a, $04
	ld (ix+8), a
	ret

LABEL_1507:
	ld ($E584), hl
	ex de, hl
	add hl, bc
	ld ($E586), hl
	ld a, (ix+10)
	and a
	jp nz, LABEL_15B2
	ld a, h
	and $F8
	or $04
	ld b, a
	xor a
	ld c, a
	ld ($E588), bc
	ld a, h
	and $07
	cp $04
	jp c, LABEL_15AF
	ld a, (ix+9)
	and a
	jr z, LABEL_153D
	bit 0, a
	jr nz, LABEL_153D
	ld a, (ix+2)
	and $07
	cp $05
	jr c, LABEL_154F
LABEL_153D:
	ld bc, $0C04
	call LABEL_1946
	jr c, LABEL_15AF
	ld a, (ix+12)
	and a
	jr z, LABEL_15AA
	ld (ix+13), a
	ret

LABEL_154F:
	ld a, (ix+9)
	bit 1, a
	jr nz, LABEL_1572
	ld bc, $040C
	call LABEL_1946
	jp nc, LABEL_15E0
	ld bc, $0B0C
	jr nc, LABEL_15E0
	ld a, $08
	ld (ix+8), a
	ld a, (ix+0)
	inc a
	ld (ix+0), a
	jr LABEL_15AA

LABEL_1572:
	ld a, (ix+12)
	and a
	jr z, LABEL_1591
	ld a, ($E585)
	cp $3C
	jr z, LABEL_1583
	cp $84
	jr nz, LABEL_1591
LABEL_1583:
	ld a, ($E589)
	cp $4C
	jr z, LABEL_158E
	cp $5C
	jr nz, LABEL_1591
LABEL_158E:
	jr LABEL_15AF
	ret

LABEL_1591:
	ld bc, $0403
	call LABEL_1946
	jr nc, LABEL_15E0
	ld bc, $0B03
	jr nc, LABEL_15E0
	ld a, $02
	ld (ix+8), a
	ld a, (ix+0)
	dec a
	ld (ix+0), a
LABEL_15AA:
	ld hl, ($E588)
	jr LABEL_15B2

LABEL_15AF:
	ld hl, ($E586)
LABEL_15B2:
	ld a, (ix+0)
	cp $54
	jr nz, LABEL_15D5
	ld a, h
	cp $84
	jr nc, LABEL_15C2
	cp $24
	jr nc, LABEL_15D5
LABEL_15C2:
	cp $C9
	jr nc, LABEL_15D2
	cp $A8
	jr nc, LABEL_15CE
	ld a, $01
	jr LABEL_15D6

LABEL_15CE:
	ld a, $02
	jr LABEL_15D6

LABEL_15D2:
	ld hl, $0000
LABEL_15D5:
	xor a
LABEL_15D6:
	ld (ix+10), a
	ld (ix+2), h
	ld (ix+3), l
	ret

LABEL_15E0:
	ld a, (ix+12)
	and a
	jp z, LABEL_153D
	ld (ix+13), a
	ret

LABEL_15EB:
	ld a, (ix+9)
	bit 3, a
	jr z, LABEL_15F8
	ld a, $08
	ld (ix+8), a
	ret

LABEL_15F8:
	ld ($E588), de
	and a
	sbc hl, bc
	ld ($E582), hl
	ld a, h
	and $F8
	or $04
	ld b, a
	xor a
	ld c, a
	ld ($E584), bc
	ld a, h
	and $07
	cp $05
	jr nc, LABEL_167A
	ld a, (ix+9)
	and a
	jr z, LABEL_1628
	bit 1, a
	jr nz, LABEL_1628
	ld a, (ix+0)
	and $07
	cp $04
	jr nc, LABEL_163A
LABEL_1628:
	ld bc, $0403
	call LABEL_1946
	jr c, LABEL_167A
	ld a, (ix+12)
	and a
	jr z, LABEL_1675
	ld (ix+13), a
	ret

LABEL_163A:
	ld a, (ix+9)
	bit 2, a
	jr nz, LABEL_165C
	ld bc, $0C04
	call LABEL_1946
	jr nc, LABEL_1688
	ld bc, $0C0B
	jr nc, LABEL_1688
	ld a, $01
	ld (ix+8), a
	ld a, (ix+2)
	inc a
	ld (ix+2), a
	jr LABEL_1675

LABEL_165C:
	ld bc, $0304
	call LABEL_1946
	jr nc, LABEL_1688
	ld bc, $030B
	jr nc, LABEL_1688
	ld a, $04
	ld (ix+8), a
	ld a, (ix+2)
	dec a
	ld (ix+2), a
LABEL_1675:
	ld hl, ($E584)
	jr LABEL_167D

LABEL_167A:
	ld hl, ($E582)
LABEL_167D:
	ld (ix+0), h
	ld (ix+1), l
	xor a
	ld (ix+10), a
	ret

LABEL_1688:
	ld a, (ix+12)
	and a
	jr z, LABEL_1628
	ld (ix+13), a
	ret

LABEL_1692:
	ld l, (ix+17)
	ld h, (ix+18)
	ld a, (ix+0)
	ld (hl), a
	inc hl
	ld a, (ix+2)
	ld (hl), a
	inc hl
	ld a, (ix+15)
	and a
	jr nz, LABEL_16BE
	ld a, (ix+16)
	and a
	jr nz, LABEL_16CE
	ld a, (ix+8)
	cp $08
	jr nz, LABEL_16B6
	dec a
LABEL_16B6:
	srl a
	add a, a
	add a, a
	add a, a
	ld c, a
	jr LABEL_16D1

LABEL_16BE:
	ld a, (ix+8)
	cp $08
	jr nz, LABEL_16C6
	dec a
LABEL_16C6:
	srl a
	add a, a
	add a, a
	add a, $90
	jr LABEL_16DD

LABEL_16CE:
	ld a, $30
	ld c, a
LABEL_16D1:
	ld a, (ix+4)
	inc a
	ld (ix+4), a
	and $04
	add a, c
	add a, $70
LABEL_16DD:
	ld (hl), a
	ld c, a
	inc hl
	ld a, (ix+15)
	and a
	jr nz, LABEL_16FB
	ld a, (ix+16)
	and a
	jr nz, LABEL_16F1
	ld a, (ix+5)
	jr LABEL_1707

LABEL_16F1:
	ld a, ($E59A)
	and a
	jr z, LABEL_1705
	bit 2, c
	jr z, LABEL_1705
LABEL_16FB:
	ld a, ($E59F)
	and a
	jr nz, LABEL_1705
	ld a, $0E
	jr LABEL_1707

LABEL_1705:
	ld a, $04
LABEL_1707:
	ld (hl), a
	ret

LABEL_1709:
	ld a, (ix+16)
	push af
	call LABEL_196E
	ld a, (ix+14)
	ld c, a
	ld a, ($E20E)
	xor c
	jr nz, LABEL_175A
	ld a, (ix+12)
	cp $04
	jr nz, LABEL_172C
	ld a, ($E593)
	and a
	jr nz, LABEL_172C
	ld a, $01
	ld (ix+16), a
LABEL_172C:
	ld a, ($E595)
	sub (ix+0)
	jp p, LABEL_1737
	neg
LABEL_1737:
	ld c, a
	ld a, ($E594)
	sub (ix+2)
	jp p, LABEL_1743
	neg
LABEL_1743:
	sub c
	jr c, LABEL_1750
	ld a, ($E594)
	sub (ix+2)
	jr c, LABEL_1792
	jr LABEL_1784

LABEL_1750:
	ld a, ($E595)
	sub (ix+0)
	jr c, LABEL_1771
	jr LABEL_1762

LABEL_175A:
	and $0A
	jr z, LABEL_1780
	bit 3, c
	jr nz, LABEL_1771
LABEL_1762:
	ld a, (ix+15)
	and a
	jr nz, LABEL_176E
	ld a, (ix+16)
	and a
	jr nz, LABEL_177D
LABEL_176E:
	jp LABEL_1871

LABEL_1771:
	ld a, (ix+15)
	and a
	jr nz, LABEL_177D
	ld a, (ix+16)
	and a
	jr nz, LABEL_176E
LABEL_177D:
	jp LABEL_1892

LABEL_1780:
	bit 0, c
	jr nz, LABEL_1792
LABEL_1784:
	ld a, (ix+15)
	and a
	jr nz, LABEL_1790
	ld a, (ix+16)
	and a
	jr nz, LABEL_179E
LABEL_1790:
	jr LABEL_17BF

LABEL_1792:
	ld a, (ix+15)
	and a
	jr nz, LABEL_179E
	ld a, (ix+16)
	and a
	jr nz, LABEL_1790
LABEL_179E:
	ld a, (ix+8)
	bit 0, a
	jp nz, LABEL_1836
	bit 2, a
	jr z, LABEL_17BB
	ld a, $04
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	jr LABEL_180B

LABEL_17BB:
	ld a, $04
	jr LABEL_17DD

LABEL_17BF:
	ld a, (ix+8)
	bit 2, a
	jr nz, LABEL_1836
	bit 0, a
	jr z, LABEL_17DB
	ld a, $01
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	jr LABEL_180B

LABEL_17DB:
	ld a, $01
LABEL_17DD:
	ld (ix+9), a
	ld ($E591), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+8)
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, ($E591)
	xor $05
	ld (ix+9), a
	call LABEL_133A
	jp LABEL_1941

LABEL_180B:
	ld a, (ix+0)
	ld c, a
	ld a, ($E595)
	sub c
	jr c, LABEL_1819
	ld a, $08
	jr LABEL_181B

LABEL_1819:
	ld a, $02
LABEL_181B:
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+9)
	xor $0A
	ld (ix+9), a
	call LABEL_133A
	jp z, LABEL_1941
LABEL_1836:
	ld a, (ix+0)
	ld c, a
	ld a, ($E595)
	sub c
	jr c, LABEL_1844
	ld a, $08
	jr LABEL_1846

LABEL_1844:
	ld a, $02
LABEL_1846:
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+9)
	xor $0A
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+8)
	ld (ix+9), a
	call LABEL_133A
	jp LABEL_1941

LABEL_1871:
	ld a, (ix+8)
	bit 1, a
	jp nz, LABEL_1909
	bit 3, a
	jr z, LABEL_188E
	ld a, $08
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	jr LABEL_18DE

LABEL_188E:
	ld a, $08
	jr LABEL_18B0

LABEL_1892:
	ld a, (ix+8)
	bit 3, a
	jr nz, LABEL_1909
	bit 1, a
	jr z, LABEL_18AE
	ld a, $02
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	jr LABEL_18DE

LABEL_18AE:
	ld a, $02
LABEL_18B0:
	ld (ix+9), a
	ld ($E591), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+8)
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, ($E591)
	xor $0A
	ld (ix+9), a
	call LABEL_133A
	jp LABEL_1941

LABEL_18DE:
	ld a, (ix+2)
	ld c, a
	ld a, ($E594)
	sub c
	jr c, LABEL_18EC
	ld a, $01
	jr LABEL_18EE

LABEL_18EC:
	ld a, $04
LABEL_18EE:
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+9)
	xor $05
	ld (ix+9), a
	call LABEL_133A
	jp LABEL_1941

LABEL_1909:
	ld a, (ix+2)
	ld c, a
	ld a, ($E594)
	sub c
	jr c, LABEL_1917
	ld a, $01
	jr LABEL_1919

LABEL_1917:
	ld a, $04
LABEL_1919:
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+9)
	xor $05
	ld (ix+9), a
	call LABEL_133A
	ld a, (ix+13)
	and a
	jp z, LABEL_1941
	ld a, (ix+8)
	ld (ix+9), a
	call LABEL_133A
LABEL_1941:
	pop af
	ld (ix+16), a
	ret

LABEL_1946:
	ld hl, ($E584)
	ld a, c
	add a, h
	and $F8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ex de, hl
	ld hl, ($E588)
	ld a, b
	add a, h
	and $F8
	srl a
	srl a
	srl a
	ld l, a
	ld h, $00
	add hl, de
	ld de, $3C00
	add hl, de
	call LABEL_1BB9
	cp $98
	ret

LABEL_196E:
	ld a, (ix+0)
	cp $54
	jr nc, LABEL_1979
	ld a, $02
	jr LABEL_197B

LABEL_1979:
	ld a, $08
LABEL_197B:
	ld c, a
	ld a, (ix+2)
	cp $55
	jr nc, LABEL_1987
	ld a, $04
	jr LABEL_1989

LABEL_1987:
	ld a, $01
LABEL_1989:
	or c
	ld (ix+14), a
	ret

LABEL_198E:
	push ix
	xor a
	ld ($E5B0), a
	ld a, $E0
	ld ($E510), a
	ld de, DATA_21F1
	ld a, ($E59B)
	add a, a
	add a, e
	ld e, a
	jr nc, LABEL_19A5
	inc d
LABEL_19A5:
	call LABEL_1C23
	ld hl, $E59B
	ld a, (hl)
	add a, a
	add a, a
	add a, $B0
	ld c, a
	ld e, (ix+17)
	ld d, (ix+18)
	ld a, e
	add a, $02
	ld e, a
	ld a, c
	ld (de), a
	ld a, $0E
	inc de
	ld (de), a
	inc (hl)
	ld a, (hl)
	cp $04
	jr nz, LABEL_19CB
	xor a
	ld ($E597), a
LABEL_19CB:
	ld b, $3C
LABEL_19CD:
	push bc
	call LABEL_1B31
	pop bc
	ld a, ($E403)
	ld c, a
	ld a, ($E404)
	or c
	jp nz, LABEL_1ACA
	ld a, $01
	ld ($E608), a
	djnz LABEL_19CD
	pop ix
	push ix
	ld a, $01
	ld ($E5B0), a
	ld (ix+15), a
	ld a, $02
	ld (ix+6), a
	xor a
	ld (ix+7), a
	ld ($E59C), a
LABEL_19FC:
	call LABEL_1B31
	ld a, ($E403)
	ld c, a
	ld a, ($E404)
	or c
	jp nz, LABEL_1ACA
	pop ix
	push ix
	ld a, $3C
	ld ($E595), a
	ld a, $54
	ld ($E594), a
	ld a, $06
	ld ($E20E), a
	call LABEL_1709
	ld l, (ix+17)
	ld h, (ix+18)
	call LABEL_1692
	ld a, $01
	ld ($E608), a
	ld a, (ix+0)
	cp $3C
	jr nz, LABEL_19FC
	ld a, (ix+2)
	sub $54
	add a, $02
	cp $05
	jr nc, LABEL_19FC
	ld a, $08
	ld (ix+8), a
LABEL_1A45:
	call LABEL_1B31
	ld a, ($E403)
	ld c, a
	ld a, ($E404)
	or c
	jr nz, LABEL_1ACA
	ld a, ($E59C)
	and a
	jr nz, LABEL_1A45
	pop ix
	push ix
	ld l, (ix+17)
	ld h, (ix+18)
	call LABEL_1692
	ld a, (ix+0)
	add a, $02
	ld (ix+0), a
	cp $54
	jr c, LABEL_1A45
	xor a
	ld (ix+15), a
	ld (ix+16), a
	ld a, $02
	ld (ix+8), a
	jr LABEL_1A86

LABEL_1A7F:
	push ix
	ld a, $02
	ld (ix+8), a
LABEL_1A86:
	call LABEL_1B31
	ld a, ($E403)
	ld c, a
	ld a, ($E404)
	or c
	jr nz, LABEL_1ACA
	ld a, ($E59C)
	and a
	jr nz, LABEL_1A86
	pop ix
	push ix
	ld l, (ix+17)
	ld h, (ix+18)
	call LABEL_1692
	ld a, (ix+0)
	ld h, a
	ld a, (ix+1)
	ld l, a
	ld de, $0080
	and a
	sbc hl, de
	ld a, l
	ld (ix+1), a
	ld a, h
	ld (ix+0), a
	cp $3B
	jr nc, LABEL_1A86
	ld a, $3C
	ld (ix+0), a
	ld a, $04
	ld (ix+8), a
LABEL_1ACA:
	pop ix
	ret

LABEL_1ACD:
	ld a, ($E202)
	sub (ix+2)
	jr nz, LABEL_1AE3
	ld a, ($E200)
	sub (ix+0)
	add a, $08
	cp $11
	jr nc, LABEL_1AF9
	jr LABEL_1AF2

LABEL_1AE3:
	add a, $08
	cp $11
	jp nc, LABEL_1AF9
	ld a, ($E200)
	cp (ix+0)
	jr nz, LABEL_1AF9
LABEL_1AF2:
	ld a, $01
	ld ($E606), a
	jr LABEL_1AFA

LABEL_1AF9:
	xor a
LABEL_1AFA:
	ret

LABEL_1AFB:
	ld a, ($E202)
	sub (ix+2)
	jr nz, LABEL_1B10
	ld a, ($E200)
	sub (ix+0)
	add a, $04
	cp $09
	ret nc
	jr LABEL_1B1C

LABEL_1B10:
	add a, $04
	cp $09
	ret nc
	ld a, ($E200)
	cp (ix+0)
	ret nz
LABEL_1B1C:
	ld a, $01
	ld ($E404), a
	ret

LABEL_1B22:
	ld hl, $0000
	add hl, sp
	ex de, hl
	ld a, (hl)
	ld (hl), e
	ld e, a
	inc hl
	ld a, (hl)
	ld (hl), d
	ld d, a
	ex de, hl
	ld sp, hl
	ret

LABEL_1B31:
	ld hl, $0000
	add hl, sp
	ld e, l
	ld d, h
	ld a, l
	and $E0
	ld l, a
	ld a, (hl)
	ld (hl), e
	ld e, a
	inc hl
	ld a, (hl)
	ld (hl), d
	ld d, a
	ex de, hl
	ld sp, hl
	ret

LABEL_1B45:
	ld hl, $E5B0
	ld (hl), $01
	jr LABEL_1B51

LABEL_1B4C:
	ld hl, $E5B0
	ld (hl), $00
LABEL_1B51:
	ld de, $E5B0 + 1
	ld bc, $000F
	ldir
	ret

LABEL_1B5A:
	ld hl, $E600
	ld (hl), $00
	ld de, $E600 + 1
	ld bc, $001F
	ldir
	ret

LABEL_1B68:
	jp FILLVRAM

LABEL_1B6B:
	ex de, hl
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	jp LDIRVRAM

LABEL_1B73:
	ex de, hl
	call LDIRVRAM
	ex de, hl
	add hl, bc
	ret

LABEL_1B77:
	ld hl, $3C01
	ld de, DATA_2067
LABEL_1B7D:
	ld a, (de)
	cp $FF
	jr z, LABEL_1BAE
	ld c, $15
LABEL_1B84:
	ld a, (de)
	and $0F
	ld b, a
	ld a, (de)
	rrca
	rrca
	rrca
	rrca
	and $0F
	cp $0E
	jr nz, LABEL_1B97
	ld a, $20
	jr LABEL_1B99

LABEL_1B97:
	add a, $A0
LABEL_1B99:
	call WRITEVRAM
	inc hl
	dec c
	djnz LABEL_1B99
	inc de
	ld a, c
	and a
	jr nz, LABEL_1B84
	ld a, l
	add a, $0B
	ld l, a
	jr nc, LABEL_1B7D
	inc h
	jr LABEL_1B7D

LABEL_1BAE:
	ld hl, $3D2A
	ld a, $B4
	ld bc, $0003
	jp LABEL_1B68

LABEL_1BB9:
	jp READVRAM

LABEL_1BBC:
	ld a, 3
	ld (DrawTilemapTrig), a
	call ClearRedrawCaches
	ld hl, $3C00
	ld a, $20
	ld bc, $0300
	jp LABEL_1B68

FrameCounter:
.db $00

ClearRedrawCaches:
	push de
	ld.lil hl, TempSpriteBuffer
	ld.lil de, TempSpriteBuffer+1
	ld.lil bc, $2040
	ld.lil (hl), $00
	ldir.lil

	ld.lil hl, TilemapCache
	ld.lil de, TilemapCache+1
	ld bc, $0300
	; tile 0 isn't blank. it's the cherry's top-left corner.
	; use tile $FF instead
	ld.lil (hl), $FF
	ldir.lil
	pop de
	ret

LABEL_1BC7:
	ld de, $E500
	ld b, $20
LABEL_1BCC:
	ld hl, DATA_1BD9
	push bc
	ld bc, $0004
	ldir
	pop bc
	djnz LABEL_1BCC
	ret

; Data from 1BD9 to 1BDC (4 bytes)
DATA_1BD9:
	.db $E0, $00, $00, $00

LABEL_1BDD:
	ld hl, $3C22
	ld de, DATA_2025
LABEL_1BE3:
	ld c, $15
LABEL_1BE5:
	ld a, (de)
	ld b, $08
LABEL_1BE8:
	rlca
	jr nc, LABEL_1BF7
	push bc
	push af
	ld a, $95
	call WRITEVRAM
	pop af
	pop bc
LABEL_1BF7:
	inc hl
	dec c
	jr z, LABEL_1C00
	djnz LABEL_1BE8
	inc de
	jr LABEL_1BE5

LABEL_1C00:
	inc de
	ld a, l
	add a, $0B
	jr nc, LABEL_1C07
	inc h
LABEL_1C07:
	ld l, a
	push hl
	push de
	ld de, $3EE0
	and a
	sbc hl, de
	jr nc, LABEL_1C16
	pop de
	pop hl
	jr LABEL_1BE3

LABEL_1C16:
	pop de
	pop hl
	ret

LABEL_1C19:
	cp $0A
	jr nc, LABEL_1C20
	add a, $30
	ret

LABEL_1C20:
	add a, $37
	ret

LABEL_1C23:
	ld hl, $E407
	ld a, (de)
	add a, (hl)
	daa
	ld (hl), a
	inc de
	dec hl
	ld a, (de)
	adc a, (hl)
	daa
	ld (hl), a
	dec hl
	ld a, (hl)
	adc a, $00
	daa
	ld (hl), a
	ex de, hl
	ld hl, $3CD7
	call LABEL_1C8A
	ld a, ($E402)
	and a
	jr nz, LABEL_1C59
	ld a, ($E406)
	cp $10
	jr c, LABEL_1C59
	ld hl, $E400
	inc (hl)
	ld a, $01
	ld ($E402), a
	ld ($E602), a
	call LABEL_1CD2
LABEL_1C59:
	ld hl, $E405
	ld a, ($E58D)
	sub (hl)
	jr z, LABEL_1C65
	jr c, LABEL_1C75
	ret

LABEL_1C65:
	inc hl
	ld a, ($E58E)
	sub (hl)
	jr z, LABEL_1C6F
	jr c, LABEL_1C75
	ret

LABEL_1C6F:
	inc hl
	ld a, ($E58F)
	sub (hl)
	ret nc
LABEL_1C75:
	ld hl, $E405
	ld de, $E58D
	ld bc, $0003
	ldir
LABEL_1C80:
	ld hl, $3C57
	ld de, $E58D
	call LABEL_1C8A
	ret

LABEL_1C8A:
	xor a
	ld ($E58C), a
	ld b, $03
LABEL_1C90:
	push bc
	ld a, (de)
	rrca
	rrca
	rrca
	rrca
	and $0F
	ld c, a
	jr nz, LABEL_1CA1
	ld a, ($E58C)
	and a
	jr z, LABEL_1CB0
LABEL_1CA1:
	ld a, c
	call LABEL_1C19
	call WRITEVRAM
	ld a, $01
	ld ($E58C), a
LABEL_1CB0:
	inc hl
	ld a, (de)
	and $0F
	ld c, a
	jr nz, LABEL_1CBD
	ld a, ($E58C)
	and a
	jr z, LABEL_1CCC
LABEL_1CBD:
	ld a, c
	call LABEL_1C19
	call WRITEVRAM
	ld a, $01
	ld ($E58C), a
LABEL_1CCC:
	inc hl
	inc de
	pop bc
	djnz LABEL_1C90
	ret

LABEL_1CD2:
	ld hl, $3D1D
	push hl
	ld bc, $0004
	and a
	sbc hl, bc
	ld a, $20
	ld bc, $0006
	call LABEL_1B68
	ld de, $0020
	add hl, de
	ld bc, $0006
	call LABEL_1B68
	pop hl
	ld a, ($E400)
	and a
	ret z
	ld b, a
LABEL_1CF5:
	push bc
	ld a, $98
	call WRITEVRAM
	inc hl
	inc a
	call WRITEVRAM
	ld de, $001F
	add hl, de
	inc a
	call WRITEVRAM
	inc hl
	inc a
	call WRITEVRAM
	ld de, $0023
	and a
	sbc hl, de
	pop bc
	djnz LABEL_1CF5
	ret

LABEL_1D23:
	ld hl, $3D77
	ld b, $0C
LABEL_1D28:
	push bc
	ld de, DATA_1FFB
	call LABEL_1B6B
	ld de, $0020
	add hl, de
	pop bc
	djnz LABEL_1D28
	ld a, ($E401)
	cp $17
	jr c, LABEL_1D3F
	ld a, $17
LABEL_1D3F:
	ld b, a
	inc b
	ld c, $00
LABEL_1D43:
	push bc
	ld hl, $0000
	ld a, c
	srl a
	srl a
	and a
	jr z, LABEL_1D56
	ld b, a
	ld de, $0040
LABEL_1D53:
	add hl, de
	djnz LABEL_1D53
LABEL_1D56:
	ld de, $3D77
	add hl, de
	ld a, c
	and $03
	add a, a
	add a, l
	ld l, a
	ld de, DATA_1DA4
	ld a, c
	cp $0C
	jr c, LABEL_1D6A
	ld a, $0C
LABEL_1D6A:
	add a, e
	ld e, a
	jr nc, LABEL_1D6F
	inc d
LABEL_1D6F:
	ld a, (de)
	call WRITEVRAM
	ld de, $0020
	add hl, de
	inc a
	call WRITEVRAM
	ld de, $001F
	and a
	sbc hl, de
	inc a
	call WRITEVRAM
	ld de, $0020
	add hl, de
	inc a
	call WRITEVRAM
	ld de, $0021
	and a
	sbc hl, de
	pop bc
	inc c
	djnz LABEL_1D43
	ret

; Data from 1DA4 to 1DB3 (16 bytes)
DATA_1DA4:
	.db $00, $04, $10, $10, $08, $08, $B8, $B8, $18, $18, $1C, $1C, $B0, $B0, $B0, $B0

LABEL_1DB4:
	ld de, $E630
	ld bc, $000A
	ldir
	ld hl, ($E638)
	ld a, (hl)
	and a
	jr nz, LABEL_1DD1
	inc (hl)
	ld hl, ($E630)
	ld de, ($E634)
	ld (hl), e
	inc hl
	ld (hl), d
	call LABEL_1E08
LABEL_1DD1:
	ld hl, ($E630)
	inc hl
	inc hl
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld de, ($E632)
	ex de, hl
	ld (hl), a
	ld a, c
	and $0F
	inc l
	ld (hl), a
	inc de
	inc de
	ld a, (de)
	cp $0F
	jr nc, LABEL_1DED
	inc a
LABEL_1DED:
	ld (de), a
	cpl
	and $0F
	inc hl
	ld (hl), a
	dec de
	ex de, hl
	dec (hl)
	ret nz
	call LABEL_1E08
	cp $FF
	ret nz
	ld hl, ($E636)
	ld (hl), $00
	ld hl, ($E638)
	ld (hl), $00
	ret

LABEL_1E08:
	ld hl, ($E630)
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, DATA_1E54
	ld a, (de)
	cp $FF
	ret z
	push af
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, a
	add a, l
	ld l, a
	jr nc, LABEL_1E22
	inc h
LABEL_1E22:
	ld a, (hl)
	ld c, a
	inc hl
	ld a, (hl)
	ld hl, ($E630)
	inc hl
	inc hl
	ld (hl), a
	inc hl
	ld (hl), c
	ld a, (de)
	and $0F
	jr z, LABEL_1E3C
	ld b, a
LABEL_1E34:
	dec hl
	srl (hl)
	inc hl
	rr (hl)
	djnz LABEL_1E34
LABEL_1E3C:
	inc de
	ld a, (de)
	inc hl
	ld (hl), a
	inc hl
	pop af
	cp $C0
	jr c, LABEL_1E4A
	ld (hl), $0F
	jr LABEL_1E4C

LABEL_1E4A:
	ld (hl), $00
LABEL_1E4C:
	inc de
	ld hl, ($E630)
	ld (hl), e
	inc hl
	ld (hl), d
	ret

HandleInterrupt:
	jp LABEL_1BE

; Data from 1E54 to 1E6B (24 bytes)
DATA_1E54:
	.db $F8, $03, $BF, $03, $8A, $03, $57, $03, $27, $03, $F9, $02, $CF, $02, $A6, $02
	.db $80, $02, $5C, $02, $3A, $02, $1A, $02

; Data from 1E6C to 1E73 (8 bytes)
DATA_1E6C:
	.db $00, $C2, $0F, $FE, $04, $7E, $03, $00

; Data from 1E74 to 1E91 (30 bytes)
DATA_1E74:
	.db $20, $00, $60, $60, $90, $A0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $60, $60
	.db $70, $70, $A0, $A0, $A0, $A0, $40, $40, $70, $C0, $60, $60, $60, $60

; Data from 1E92 to 1F31 (160 bytes)
DATA_1E92:
	.db $84, $00, $54, $00, $00, $0A, $01, $00, $04, $00, $00, $00, $00, $00, $00, $00
	.db $00, $10, $E5
	.fill 13, $00
	.db $3C, $00, $54, $00, $00, $06, $01, $00, $04, $00, $00, $00, $01, $00, $00, $00
	.db $00, $00, $E5
	.fill 13, $00
	.db $54, $00, $54, $00, $00, $0D, $01, $00, $02, $00, $00, $00, $02, $00, $00, $00
	.db $00, $04, $E5
	.fill 13, $00
	.db $4C, $00, $5C, $00, $00, $07, $01, $00, $08, $00, $00, $00, $03, $00, $00, $00
	.db $00, $08, $E5
	.fill 13, $00
	.db $4C, $00, $4C, $00, $00, $09, $01, $00, $08, $00, $00, $00, $04, $00, $00, $00
	.db $00, $0C, $E5
	.fill 13, $00

; Data from 1F32 to 1F48 (23 bytes)
DATA_1F32:
	.db $15, $00, $93, $93, $81, $20, $83, $20, $88, $8A, $8D, $20, $20, $20, $90, $20
	.db $91, $20, $83, $20, $90, $20, $93

; Data from 1F49 to 1F5F (23 bytes)
DATA_1F49:
	.db $15, $00, $93, $93, $82, $84, $94, $85, $93, $8C, $20, $20, $8F, $20, $93, $92
	.db $93, $84, $94, $85, $93, $90, $93

; Data from 1F60 to 1F76 (23 bytes)
DATA_1F60:
	.db $15, $00, $93, $80, $20, $86, $93, $87, $89, $8B, $8E, $20, $20, $20, $93, $93
	.db $93, $86, $93, $87, $93, $93, $93

; Data from 1F77 to 1F8E (24 bytes)
DATA_1F77:
	.db $16, $00, $40, $20, $31, $39, $38, $30, $20, $31, $39, $38, $34, $20, $4E, $41
	.db $4D, $43, $4F, $20, $4C, $54, $44, $2E

; Data from 1F8F to 1FA3 (21 bytes)
DATA_1F8F:
	.db $13, $00, $41, $4C, $4C, $20, $52, $49, $47, $48, $54, $53, $20, $52, $45, $53
	.db $45, $52, $56, $45, $44

; Data from 1FA4 to 1FAD (10 bytes)
DATA_1FA4:
	.db $08, $00, $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7

; Data from 1FAE to 1FB4 (7 bytes)
DATA_1FAE:
	.db $05, $00, $63, $64, $65, $66, $67

; Data from 1FB5 to 1FBE (10 bytes)
DATA_1FB5:
	.db $08, $00, $60, $61, $62, $63, $64, $65, $66, $67

; Data from 1FBF to 1FDF (33 bytes)
DATA_1FBF:
	.db $0E, $00, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D
	.db $08, $00, $48, $49, $20, $53, $43, $4F, $52, $45, $05, $00, $53, $43, $4F, $52
	.db $45

; Data from 1FE0 to 1FE7 (8 bytes)
DATA_1FE0:
	.db $06, $00, $68, $69, $6A, $6B, $6C, $6D

; Data from 1FE8 to 1FEF (8 bytes)
DATA_1FE8:
	.db $06, $00, $20, $20, $20, $20, $20, $20

; Data from 1FF0 to 1FFA (11 bytes)
DATA_1FF0:
	.db $09, $00, $47, $41, $4D, $45, $20, $4F, $56, $45, $52

; Data from 1FFB to 2004 (10 bytes)
DATA_1FFB:
	.db $08, $00, $20, $20, $20, $20, $20, $20, $20, $20

; Data from 2005 to 2014 (16 bytes)
DATA_2005:
	.db $03
	.fill 15, $00

; Data from 2015 to 2024 (16 bytes)
DATA_2015:
	.db $00, $42, $3C, $00, $54, $3C, $00, $22, $3E, $00, $34, $3E, $00, $00, $00, $00

; Data from 2025 to 2066 (66 bytes)
DATA_2025:
	.db $FF, $BF, $E0, $08, $A2, $00, $88, $A2, $20, $FF, $FF, $E0, $8A, $0A, $20, $8B
	.db $BA, $20, $F8, $03, $E0, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.db $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $FF, $BF, $E0, $88, $A2, $20
	.db $6F, $BE, $C0, $2A, $0A, $80, $FB, $BB, $E0, $80, $A0, $20, $80, $A0, $20, $FF
	.db $FF, $E0

; Data from 2067 to 21EC (390 bytes)
DATA_2067:
	.db $01, $C9, $81, $C9, $11, $D1, $E9, $D1, $E9, $D1, $D1, $E1, $01, $C1, $11, $E1
	.db $01, $C1, $11, $E1, $D1, $E1, $01, $C1, $11, $E1, $01, $C1, $11, $E1, $D1, $D1
	.db $E1, $21, $C1, $31, $E1, $21, $C1, $31, $E1, $61, $E1, $21, $C1, $31, $E1, $21
	.db $C1, $31, $E1, $D1, $D1, $EA, $E9, $D1, $D1, $E1, $01, $C1, $11, $E1, $71, $E1
	.db $41, $C1, $81, $C1, $51, $E1, $71, $E1, $01, $C1, $11, $E1, $D1, $D1, $E1, $21
	.db $C1, $31, $E1, $D1, $E3, $D1, $E3, $D1, $E1, $21, $C1, $31, $E1, $D1, $D1, $E5
	.db $A1, $C1, $51, $E1, $61, $E1, $41, $C1, $B1, $E5, $D1, $21, $C3, $11, $E1, $D1
	.db $E7, $D1, $E1, $01, $C3, $31, $E4, $D1, $E1, $D1, $E1, $01, $E3, $11, $E1, $D1
	.db $E1, $D1, $E4, $41, $C3, $31, $E1, $61, $E1, $D1, $E3, $D1, $E1, $61, $E1, $21
	.db $C3, $51, $E8, $D1, $E3, $D1, $E8, $41, $C3, $11, $E1, $71, $E1, $21, $C3, $31
	.db $E1, $71, $E1, $01, $C3, $51, $E4, $D1, $E1, $D1, $E7, $D1, $E1, $D1, $E4, $01
	.db $C3, $31, $E1, $61, $E1, $41, $C1, $81, $C1, $51, $E1, $61, $E1, $21, $C3, $11
	.db $D1, $E9, $D1, $E9, $D1, $D1, $E1, $41, $C1, $11, $E1, $41, $C1, $51, $E1, $61
	.db $E1, $41, $C1, $51, $E1, $01, $C1, $51, $E1, $D1, $D1, $E3, $D1, $EB, $D1, $E3
	.db $D1, $A1, $C1, $51, $E1, $61, $E1, $71, $E1, $41, $C1, $81, $C1, $51, $E1, $71
	.db $E1, $61, $E1, $41, $C1, $B1, $D1, $E5, $D1, $E3, $D1, $E3, $D1, $E5, $D1, $D1
	.db $E1, $01, $C3, $91, $C1, $11, $E1, $D1, $E1, $01, $C1, $91, $C3, $11, $E1, $D1
	.db $D1, $E1, $21, $C5, $31, $E1, $61, $E1, $21, $C5, $31, $E1, $D1, $D1, $EA, $E9
	.db $D1, $21, $CA, $C9, $31, $FF, $00, $C0, $00, $C0, $00, $C8, $00, $C8, $00, $D0
	.db $00, $D8, $00, $D8, $00, $E0, $00, $E0, $00, $E8, $00, $F0, $00, $F0, $00, $F8
	.db $01, $00, $01, $08, $01, $10, $00, $B0, $00, $B0, $00, $B8, $00, $B8, $00, $C0
	.db $00, $C8, $00, $D0, $00, $D8, $00, $E0, $00, $E8, $00, $F0, $00, $F8, $01, $00
	.db $01, $08, $01, $18, $01, $20, $00, $40, $00, $48, $00, $50, $00, $60, $00, $60
	.db $00, $70, $00, $80, $00, $88, $00, $80, $00, $A0, $00, $A8, $00, $B0, $00, $A0
	.db $00, $C0, $00, $D0, $00, $D8

; Data from 21ED to 21F0 (4 bytes)
DATA_21ED:
	.db $01, $00, $05, $00

; Data from 21F1 to 21F8 (8 bytes)
DATA_21F1:
	.db $20, $00, $40, $00, $80, $00, $60, $01

; Data from 21F9 to 2212 (26 bytes)
DATA_21F9:
	.db $10, $00, $30, $00, $50, $00, $50, $00, $70, $00, $70, $00, $00, $01, $00, $01
	.db $00, $02, $00, $02, $00, $03, $00, $03, $00, $05

; Data from 2213 to 2264 (82 bytes)
DATA_2213:
	.db $50, $00, $00, $1C, $26, $63, $63, $63, $33, $1C, $00, $0C, $1C, $0C, $0C, $0C
	.db $0C, $3F, $00, $3E, $63, $07, $1E, $3C, $70, $7F, $00, $7F, $06, $0C, $1E, $03
	.db $63, $3E, $00, $0E, $1E, $36, $66, $7F, $06, $06, $00, $7E, $60, $7E, $03, $03
	.db $63, $3E, $00, $1E, $30, $60, $7E, $63, $63, $3E, $00, $7F, $63, $06, $0C, $18
	.db $18, $18, $00, $3C, $62, $72, $3C, $4F, $43, $3E, $00, $3E, $63, $63, $3F, $03
	.db $06, $3C

; Data from 2265 to 2336 (210 bytes)
DATA_2265:
	.db $D0, $00
DATA_2267:
	.db $00, $1C, $36, $63, $63, $7F, $63, $63, $00, $7E, $63, $63, $7E, $63
	.db $63, $7E, $00, $1E, $33, $60, $60, $60, $33, $1E, $00, $7C, $66, $63, $63, $63
	.db $66, $7C, $00, $3F, $30, $30, $3E, $30, $30, $3F, $00, $7F, $60, $60, $7E, $60
	.db $60, $60, $00, $1F, $30, $60, $67, $63, $33, $1F, $00, $63, $63, $63, $7F, $63
	.db $63, $63, $00, $3F, $0C, $0C, $0C, $0C, $0C, $3F, $00, $0C, $1C, $0C, $0C, $0C
	.db $0C, $3F, $00, $63, $66, $6C, $78, $6C, $66, $63, $00, $30, $30, $30, $30, $30
	.db $30, $3F, $00, $63, $77, $7F, $7F, $6B, $63, $63, $00, $63, $73, $7B, $7F, $6F
	.db $67, $63, $00, $3E, $63, $63, $63, $63, $63, $3E, $00, $7E, $63, $63, $63, $7E
	.db $60, $60, $00, $3E, $63, $07, $1E, $3C, $70, $7F, $00, $7E, $63, $63, $67, $7C
	.db $6E, $67, $00, $3C, $66, $60, $3E, $03, $63, $3E, $00, $3F, $0C, $0C, $0C, $0C
	.db $0C, $0C, $00, $63, $63, $63, $63, $63, $63, $3E, $00, $63, $63, $63, $77, $3E
	.db $1C, $08, $00, $63, $63, $6B, $7F, $7F, $77, $63, $00, $63, $77, $3E, $1C, $3E
	.db $77, $63, $00, $33, $33, $33, $1E, $0C, $0C, $0C, $00, $0E, $0E, $1C, $18, $10
	.db $00, $20

; Data from 2337 to 2340 (10 bytes)
DATA_2337:
	.db $08, $00, $3C, $42, $9D, $A1, $A1, $9D, $42, $3C

; Data from 2341 to 242A (234 bytes)
DATA_2341:
	.db $E8, $00, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $80, $E0, $F8, $FC, $FE, $FE
	.db $9F, $0F, $0F, $9F, $FE, $FE, $FC, $FC, $F0, $C0, $18, $18, $3C, $3C, $7E, $7E
	.db $FF, $FF, $01, $01, $03, $03, $07, $07, $0F, $0F, $80, $80, $C0, $C0, $E0, $E0
	.db $F0, $F0, $1F, $1F, $3F, $3F, $7F, $7F, $FF, $FF, $F8, $F8, $FC, $FC, $FE, $FE
	.db $FF, $FF, $00, $01, $07, $1F, $1F, $3F, $3F, $7F, $7F, $3F, $3F, $1F, $1F, $07
	.db $01, $00, $7E
	.fill 14, $FF
	.db $7E, $FF, $FE, $FC, $F8, $F8, $FC, $FE, $FF, $00, $80, $E0, $F8, $F0, $E0, $C0
	.db $80, $80, $C0, $E0, $F0, $F8, $E0, $80, $00, $00, $00, $FF, $FF, $FF, $FF, $00
	.db $00, $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF, $01, $03, $07, $0F, $1F, $3F, $7F
	.db $FF, $81, $C3, $E7
	.fill 15, $FF
	.db $E7, $C3, $C3, $E7, $FF, $FF, $00, $00, $00, $00, $0C, $0C, $00, $00, $00, $00
	.db $1E, $3F, $3F, $3F, $3F, $1E
	.fill 9, $00
	.db $03, $0F, $1F, $1F, $07, $01, $00, $00, $E0, $F8, $FC, $FC, $FE, $FE, $7E, $01
	.db $07, $1F, $1F, $0F, $03, $00, $00, $FE, $FE, $FC, $FC, $F8, $E0, $00, $00, $00
	.db $00, $06, $06, $06, $06, $06, $00

; Data from 242B to 249C (114 bytes)
DATA_242B:
	.db $70, $00, $00, $00, $00, $0F, $10, $13, $14, $14, $00, $00, $00, $F8, $04, $E4
	.db $14, $14, $14, $14, $14, $13, $10, $0F, $00, $00, $14, $14, $14, $E4, $04, $F8
	.db $00, $00, $00, $00, $00, $0F, $10, $0F, $00, $00, $00, $00, $00, $F8, $04, $F8
	.db $00, $00, $14, $14, $14, $14, $14, $08, $00, $00, $00, $00, $00, $08, $14, $14
	.db $14, $14, $00, $00, $00, $FF, $00, $C1, $22, $14, $14, $14, $22, $C1, $00, $FF
	.db $00, $00, $14, $14, $12, $11, $10, $11, $12, $14, $14, $14, $24, $C4, $04, $C4
	.db $24, $14, $00, $00, $00, $FF, $00, $FF, $00, $00, $14, $14, $14, $14, $14, $14
	.db $14, $14

; Data from 249D to 24A6 (10 bytes)
DATA_249D:
	.db $08, $00, $00, $00, $00, $00, $00, $00, $30, $30

; Data from 24A7 to 24EC (70 bytes)
DATA_24A7:
	.db $40, $00, $7F, $7F, $60, $60, $60, $60, $60, $60, $87, $C7, $C0, $C7, $CF, $CC
	.db $CF, $C7, $F1, $F9, $39, $F9, $F9, $39, $F9, $F9, $FF, $FF, $99, $99, $99, $99
	.db $99, $99, $0F, $9F, $98, $98, $98, $98, $9F, $8F, $E3, $E7, $06, $06, $06, $06
	.db $E7, $E3, $F8, $FC, $0C, $0C, $0C, $0C, $FC, $F8, $FF, $FF, $18, $18, $18, $18
	.db $18, $18
DATA_24E9:
	.db $E0, $00, $00, $0F

; Data from 24ED to 26D6 (490 bytes)
DATA_24ED:
	.db $80, $01, $00, $03, $0F, $1F, $1F, $3F, $3F, $3F, $3F, $3F, $1F, $1F, $0F, $03
	.db $00, $00, $00, $E0, $F8, $FC, $FC, $F0, $C0, $00, $C0, $F0, $FC, $FC, $F8, $E0
	.db $00, $00, $00, $03, $0F, $1F, $1F, $3F, $3E, $3C, $3E, $3F, $1F, $1F, $0F, $03
	.db $00, $00, $00, $E0, $E0, $C0, $80, $00, $00, $00, $00, $00, $80, $C0, $E0, $E0
	.db $00, $00, $00, $00, $0C, $1C, $1E, $3E, $3F, $3F, $3F, $3F, $1F, $1F, $0F, $03
	.db $00, $00, $00, $00, $18, $1C, $3C, $3E, $7E, $7E, $FE, $FE, $FC, $FC, $F8, $E0
	.db $00, $00, $00, $00, $00, $00, $00, $30, $38, $3C, $3E, $3F, $1F, $1F, $0F, $03
	.db $00, $00, $00, $00, $00, $00, $00, $06, $0E, $1E, $3E, $7E, $FC, $FC, $F8, $E0
	.db $00, $00, $00, $03, $0F, $1F, $1F, $07, $01, $00, $01, $07, $1F, $1F, $0F, $03
	.db $00, $00, $00, $E0, $F8, $FC, $FC, $FE, $FE, $7E, $FE, $FE, $FC, $FC, $F8, $E0
	.db $00, $00, $00, $03, $03, $01, $00, $00, $00, $00, $00, $00, $00, $01, $03, $03
	.db $00, $00, $00, $E0, $F8, $FC, $FC, $7E, $3E, $1E, $3E, $7E, $FC, $FC, $F8, $E0
	.db $00, $00, $00, $03, $0F, $1F, $1F, $3F, $3F, $3F, $3F, $3E, $1E, $1C, $0C, $00
	.db $00, $00, $00, $E0, $F8, $FC, $FC, $FE, $FE, $7E, $7E, $3E, $3C, $1C, $18, $00
	.db $00, $00, $00, $03, $0F, $1F, $1F, $3F, $3E, $3C, $38, $30, $00, $00, $00, $00
	.db $00, $00, $00, $E0, $F8, $FC, $FC, $7E, $3E, $1E, $0E, $06, $00, $00, $00, $00
	.db $00, $00, $00, $03, $0F, $1F, $1F, $3F, $3F, $3F, $3F, $3F, $1F, $1F, $0F, $03
	.db $00, $00, $00, $E0, $F8, $FC, $FC, $FE, $FE, $FE, $FE, $FE, $FC, $FC, $F8, $E0
	.db $00, $00, $00, $00, $00, $00, $00, $20, $78, $7C, $7F, $3F, $3F, $1F, $07, $00
	.db $00, $00, $00, $00, $00, $00, $00, $02, $0F, $1F, $7F, $FE, $FE, $FC, $70
	.fill 10, $00
	.db $70, $7E, $7F, $3F, $1F, $07
	.fill 10, $00
	.db $07, $3F, $FF, $FE, $FC, $70
	.fill 9, $00
	.db $02, $01, $08, $04, $00, $18, $00, $04, $09, $02, $00, $00, $00, $00, $00, $00
	.db $20, $48, $10, $00, $0C, $00, $10, $08, $40, $20, $78, $7F, $7F, $3F, $0F, $00
	.db $00, $00, $0F, $FF, $FF, $FE, $78, $00, $00, $00, $00, $07, $7F, $7F, $3F, $0F
	.db $00, $00, $00, $F0, $FF, $FF, $FE, $78, $00, $00, $00, $01, $07, $3F, $7F, $3F
	.db $0E, $00, $00, $C0, $F0, $FE, $FF, $7E, $38, $00, $00, $00, $01, $07, $0F, $3F
	.db $3F, $1E, $00, $80, $C0, $F0, $F8, $FE, $7E, $3C, $00, $00, $01, $03, $03, $07
	.db $0F, $07, $00, $80, $C0, $E0, $E0, $F0, $F8, $70, $00, $00, $00, $01, $01, $01
	.db $03, $01, $00, $80, $80, $C0, $C0, $C0, $E0, $40, $00, $80, $80, $80, $80, $80
	.db $80, $80

; Data from 26D7 to 3FFF (6441 bytes)
DATA_26D7:
	#import "src/PacMSX/Pac-Man (Japan)DATA_26D7.inc"
.db $FF

#include "src/PacMSX/pseudobios.asm"

#define ScreenMap	SegaVRAM + $3C00
#define SAT		SegaVRAM + $3F00

#include "src/includes/renderer_MSX.asm"

#include "src/includes/ti_equates.asm"