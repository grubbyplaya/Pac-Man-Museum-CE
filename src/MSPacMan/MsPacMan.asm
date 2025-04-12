#define DrawScreenPTR $E000

.db $FF
.ORG 0

.dl MuseumHeader
.dl MuseumIcon
.dl HeaderEnd

MuseumHeader:
	.db $85, "Ms.Pac-Man (SMS Ver.)",0

MuseumIcon:
#import "src/includes/gfx/logos/mspac.bin"
HeaderEnd:

.ASSUME ADL=0
.ORG $0000

LABEL_0:
	di
	jp LABEL_EC

; 2nd entry of Pointer Table from 3AF (indexed by $DA13)
; Data from 4 to 7 (4 bytes)
DATA_4:
	.db $00, $00, $00, $00

LABEL_8:
	pop hl
	add a, a
	add a, l
	ld l, a
	jr nc, LABEL_F
	inc h
LABEL_F:
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

; Data from 14 to 1F (12 bytes)
	.fill 12, $00

LABEL_20:
	nop
	inc l
	inc a
	ld (hl), a
	inc l
	inc a
	ld (hl), a
	ei
	jp LABEL_200

; Data from 2B to 37 (13 bytes)
	.fill 13, $00

LABEL_38:
	; ld a, (UsbIntSts)
	; xor a
	; jp nz, HandleUSBInterrupt
	jp LABEL_74

; Data from 3B to 3F (5 bytes)
	.db $17, $38, $39, $3A, $9F

; Data from 40 to 65 (38 bytes)
DATA_40:
	.db $DE, $A7, $28, $08
	.fill 30, $00

LABEL_66:
	jp LABEL_D5

LABEL_74:
	push af
	ld a, 8
	ld.lil (mpLcdIcr), a
	push bc
	ld a, $01
	ld ($D839), a
	ld bc, ($D76E)
	inc bc
	ld ($D76E), bc
	ld a, ($D770)
	inc a
	ld ($D770), a
	xor a
	ld ($D905), a
	pop bc
	pop af
	ei
	reti

FrameCounter:
	.db $00

HandleUSBInterrupt:
	; ld a, (USB_TransferDirection)	; are we the host or the slave?
	; bit USBSlave, a
	; jr nz, TransferInputFlags	; if we're the slave, transfer the input flags to the other calc

	; otherwise, retrieve slave's input flags
	; call USB_RecieveByte
	; ld (P2_Input), a
	; clear USB interrupt here
	; reti

TransferInputFlags:
	ld a, ($D800)		; retrieve our input flags
	; call USB_TransferByte	; send it over to the host
	; clear USB interrupt here
	reti

LABEL_D5:
	push af
	push hl
	ld hl, PausedGame
	xor (hl)
	jr z, LABEL_E9
	ld a, ($D755)
	and a
	jr z, LABEL_E9
	ld a, ($DF06)
	and a
	jr nz, LABEL_E9
	ld a, ($D83A)
	cpl
	ld ($D83A), a
LABEL_E9:
	ld.lil a, (KbdG1)
	ld (hl), a
	pop hl
	pop af
	retn

PausedGame:
	.db $00

LABEL_EC:
	im 1
	ld sp, $DED0

	ld hl, DrawScreen
	ld de, $E000
	ld bc, $0600
	ldir
LABEL_FA:
	call.lil GetBankAddresses
	ld hl, $FFFC
	ld (hl), $80
	inc l
	ld (hl), $00
	inc l
	ld (hl), $01
	inc l
	ld (hl), $02
	ld hl, $C000
	ld de, $C000 + 1
	ld bc, $1E5F
	ld (hl), l
	ldir
	call LABEL_44A6
	ld iy, $0206
	ld ix, $DED2
	ld b, $25
LABEL_127:
	ld a, (ix+0)
	cp (iy+0)
	jr nz, LABEL_137
	inc iy
	inc ix
	djnz LABEL_127
	jr LABEL_19C

LABEL_137:
	ld hl, $C000
	ld bc, $1FEF
LABEL_13D:
	xor a
	ld (hl), a
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, LABEL_13D
	ld iy, DATA_206
	ld ix, $DED2
	ld b, $25
LABEL_14F:
	ld a, (iy+0)
	ld (ix+0), a
	inc iy
	inc ix
	djnz LABEL_14F
	ld ix, $DEF7
	ld (ix+0), $01
	ld a, $07
	ld ($DEFC), a
	xor a
	ld (ix+1), a
	ld (ix+2), a
	ld (ix+3), a
	ld ($DEFD), a
	ld ($DEFE), a
	ld ($DEFF), a
	ld ($DF00), a
	ld ($DF01), a
	ld ($DF02), a
	ld ($DF03), a
	ld ($DF07), a
	ld ($DF08), a
	ld ($DF09), a
	ld ($DF0A), a
	ld ($DF0B), a
	jr LABEL_1C9

LABEL_19C:
	ld a, ($DF06)
	and a
	jr z, LABEL_1C7
	xor a
	ld ($DF06), a
	ld ($DF05), a
	ld a, ($DF07)
	ld ($DEFD), a
	ld a, ($DF08)
	ld ($DEFE), a
	ld a, ($DF09)
	ld ($DEFF), a
	ld a, ($DF0A)
	ld ($DF00), a
	ld a, ($DF0B)
	ld ($DF01), a
LABEL_1C7:
	ld a, $FF
LABEL_1C9:
	ld ($D764), a
	ei
	call LABEL_4B03
	call LABEL_4349
	ld a, $01
	ld ($D904), a
	ld a, $38
	ld ($D70B), a
	di
	ld a, ($DF0F)
	ld ($DF10), a
	call LABEL_178B
	xor a
	ld ($D904), a
	ei
	ld a, ($D764)
	and a
	jr nz, LABEL_1F5
	call LABEL_519F
LABEL_1F5:
	ld a, $FF
	ld ($D702), a
	call LABEL_4DE6
LABEL_1FD:
	call LABEL_2247
LABEL_200:
	call LABEL_4848
	jp LABEL_1DE7

; Data from 206 to 22A (37 bytes)
DATA_206:
	.db $54, $65, $6C, $20, $64, $61, $27, $20, $44, $4A, $20, $74, $61, $20, $70, $75
	.db $74, $20, $64, $61, $20, $42, $52, $41, $53, $53, $20, $44, $49, $53, $43, $20
	.db $4F, $4E, $21, $21, $21

; Data from 22B to 22F (5 bytes)
DATA_22B:
	.db $20, $24, $24, $28, $27

; 1st entry of Pointer Table from 14001 (indexed by $D741)
; Data from 230 to 238 (9 bytes)
DATA_230:
	.db $26, $25, $24, $23, $22, $20, $1F, $1E, $1C

; Data from 239 to 23F (7 bytes)
DATA_239:
	.db $18, $18, $18, $18, $20, $21, $22

; Data from 240 to 258 (25 bytes)
DATA_240:
	.db $23, $24, $25, $26
	.fill 21, $27

; Data from 259 to 260 (8 bytes)
DATA_259:
	.db $00, $00, $C0, $FF, $C0, $00, $80, $01

; Data from 261 to 268 (8 bytes)
DATA_261:
	.db $00, $00, $80, $FF, $00, $01, $00, $02

LABEL_269:
	ld l, (ix+48)
	ld h, $00
	add hl, hl
	ld de, DATA_2A9
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld a, (ix+46)
	and $1F
	sub (hl)
	jr c, LABEL_284
	and $0F
	add a, (hl)
	jr LABEL_289

LABEL_284:
	ld a, (ix+46)
	and $1F
LABEL_289:
	inc a
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld (ix+47), a
	ld a, ($DEFD)
	bit 1, a
	ret z
	ld iy, $DA53
	ld a, (ix+47)
	ld (iy+47), a
	ld a, (ix+46)
	ld (iy+46), a
	ret

; Pointer Table from 2A9 to 2B0 (4 entries, indexed by $DA3E)
DATA_2A9:
	.dw DATA_2B1, DATA_2C7, DATA_2E8, DATA_309

; 1st entry of Pointer Table from 2A9 (indexed by $DA3E)
; Data from 2B1 to 2C6 (22 bytes)
DATA_2B1:
	.db $05, $00, $00, $01, $01, $01, $02, $02, $02, $02, $03, $03, $03, $03, $02, $02
	.db $02, $02, $03, $03, $03, $03

; 2nd entry of Pointer Table from 2A9 (indexed by $DA3E)
; Data from 2C7 to 2E7 (33 bytes)
DATA_2C7:
	.db $10, $04, $05, $04, $05, $06, $04, $05, $06, $07, $04, $05, $06, $07, $04, $05
	.db $06, $07, $1E, $1E, $07, $06, $05, $04, $1F, $04, $05, $06, $07, $1E, $05, $06
	.db $1F

; 3rd entry of Pointer Table from 2A9 (indexed by $DA3E)
; Data from 2E8 to 303 (28 bytes)
DATA_2E8:
	.db $10, $0A, $0B, $0C, $0A, $0B, $0C, $0D, $0E, $08, $09, $0E, $0C, $0D, $0F, $0B
	.db $0A, $09, $08, $09, $0A, $1D, $0C, $0D, $0E, $0F, $1C, $0F

; 5th entry of Pointer Table from 4AE6 (indexed by $DA43)
; Data from 304 to 308 (5 bytes)
DATA_304:
	.db $0E, $1D, $0B, $1C, $0E

; 4th entry of Pointer Table from 2A9 (indexed by $DA3E)
; Data from 309 to 329 (33 bytes)
DATA_309:
	.db $0A, $19, $11, $12, $16, $15, $11, $1A, $13, $1B, $09, $10, $18, $11, $0F, $14
	.db $1E, $08, $13, $0A, $0B, $0C, $0D, $0E, $16, $1C, $1D, $17, $1E, $0E, $07, $18
	.db $1F

LABEL_32A:
	ld a, ($DEFD)
	ld b, a
	ld ix, $DA0E
	ld c, $F8
	call LABEL_341
	ld ix, $DA53
	ld c, $08
	call LABEL_341
	ret

LABEL_341:
	ld a, (ix+47)
	add a, a
	ld l, a
	ld h, $00
	ld de, DATA_36D
	add hl, de
	ld a, (hl)
	add a, $18
	ld (ix+2), a
	inc hl
	ld a, (hl)
	adc a, $00
	ld (ix+3), a
	set 2, (ix+2)
	ld a, $78
	bit 1, b
	jr z, LABEL_364
	add a, c
LABEL_364:
	ld (ix+0), a
	ld a, $01
	ld (ix+1), a
	ret

; Data from 36D to 3AE (66 bytes)
DATA_36D:
	.db $B8, $00, $B8, $00, $B8, $00, $D0, $00, $B8, $00, $B8, $00, $A0, $00, $B8, $00
	.db $E8, $00, $00, $01, $18, $01, $E8, $00, $F0, $00, $B8, $00, $E8, $00, $E8, $00
	.db $B8, $00, $B8, $00, $B8, $00, $B8, $00, $B8, $00, $B8, $00, $B8, $00, $B8, $00
	.db $E0, $00, $E8, $00, $B8, $00, $B8, $00, $E8, $00, $E8, $00, $B8, $00, $B8, $00
	.db $B8, $00

; Pointer Table from 3AF to 3B2 (2 entries, indexed by $DA13)
DATA_3AF:
	.db $E7, $09, $04, $00
; Data from 3B3 to 403 (81 bytes)
	.db $08, $00, $08, $00, $F7, $09, $04, $00, $08, $00, $08, $00, $07, $0A, $04, $00
	.db $08, $00, $08, $00, $17, $0A, $04, $00, $08, $00, $08, $00, $27, $0A, $04, $00
	.db $08, $00, $08, $00, $37, $0A, $04, $00, $08, $00, $08, $00, $47, $0A, $04, $00
	.db $08, $00, $08, $00, $57, $0A, $04, $00, $08, $00, $08, $00, $67, $0A, $04, $00
	.db $08, $00, $08, $00, $77, $0A, $04, $00, $08, $00, $08, $00, $87, $0A, $04, $00
	.db $08

; 6th entry of Pointer Table from 4AE6 (indexed by $DA43)
; Data from 404 to 40B (8 bytes)
DATA_404:
	.db $00, $08, $00, $97, $0A, $04, $00, $08

; 1st entry of Jump Table from 528 (indexed by unknown)
LABEL_40C:
	nop
	ex af, af'
	nop
	and a
	ld a, (bc)
	inc b
	nop
	ex af, af'
	nop
	ex af, af'
	nop
	or a
	ld a, (bc)
	inc b
	nop
	ex af, af'
	nop
	ex af, af'
	nop
	rst $00	; Possibly invalid
; Data from 420 to 527 (264 bytes)
	.db $0A, $04, $00, $08, $00, $08, $00, $D7, $0A, $04, $00, $08, $00, $08, $00, $E7
	.db $0A, $04, $00, $08, $00, $08, $00, $F7, $0A, $04, $00, $08, $00, $08, $00, $07
	.db $0B, $04, $00, $08, $00, $08, $00, $17, $0B, $04, $00, $08, $00, $08, $00, $27
	.db $0B, $04, $00, $08, $00, $08, $00, $37, $0B, $04, $00, $08, $00, $08, $00, $47
	.db $0B, $04, $00, $08, $00, $08, $00, $57, $0B, $04, $00, $08, $00, $08, $00, $67
	.db $0B, $04, $00, $08, $00, $08, $00, $77, $0B, $04, $00, $08, $00, $08, $00, $87
	.db $0B, $04, $00, $08, $00, $08, $00, $97, $0B, $04, $00, $08, $00, $08, $00, $A7
	.db $0B, $04, $00, $08, $00, $08, $00, $B7, $0B, $03, $00, $08, $00, $08, $00, $C3
	.db $0B, $03, $00, $08, $00, $08, $00, $CF, $0B, $04, $00, $08, $00, $08, $00, $DF
	.db $0B, $04, $00, $08, $00, $08, $00, $EF, $0B, $04, $00, $08, $00, $08, $00, $FF
	.db $0B, $04, $00, $08, $00, $08, $00, $0F, $0C, $04, $00, $08, $00, $08, $00, $1F
	.db $0C, $04, $00, $08, $00, $08, $00, $2F, $0C, $04, $00, $08, $00, $08, $00, $3F
	.db $0C, $04, $00, $08, $00, $08, $00, $4F, $0C, $04, $00, $08, $00, $08, $00, $5F
	.db $0C, $04, $00, $08, $00, $08, $00, $6F, $0C, $04, $00, $08, $00, $08, $00, $7F
	.db $0C, $04, $00, $08, $00, $08, $00, $8F, $0C, $04, $00, $08, $00, $08, $00, $9F
	.db $0C, $04, $00, $08, $00, $08, $00, $AF, $0C, $04, $00, $08, $00, $08, $00, $BF
	.db $0C, $04, $00, $08, $00, $08, $00, $CF

; Jump Table from 528 to 52D (3 entries, indexed by unknown)
DATA_528:
	.db $0C, $04, $00, $08, $00, $08

; Data from 52E to 7FF (722 bytes)
	.db $00, $DF, $0C, $04, $00, $08, $00, $08, $00, $EF, $0C, $04, $00, $08, $00, $08
	.db $00, $FF, $0C, $04, $00, $08, $00, $08, $00, $0F, $0D, $04, $00, $08, $00, $08
	.db $00, $1F, $0D, $04, $00, $08, $00, $08, $00, $2F, $0D, $04, $00, $08, $00, $08
	.db $00, $3F, $0D, $04, $00, $08, $00, $08, $00, $4F, $0D, $04, $00, $08, $00, $08
	.db $00, $5F, $0D, $04, $00, $08, $00, $08, $00, $6F, $0D, $04, $00, $08, $00, $08
	.db $00, $7F, $0D, $04, $00, $08, $00, $08, $00, $8F, $0D, $04, $00, $08, $00, $08
	.db $00, $9F, $0D, $04, $00, $08, $00, $08, $00, $AF, $0D, $04, $00, $08, $00, $08
	.db $00, $BF, $0D, $04, $00, $08, $00, $08, $00, $CF, $0D, $04, $00, $08, $00, $08
	.db $00, $DF, $0D, $04, $00, $08, $00, $08, $00, $EF, $0D, $04, $00, $08, $00, $08
	.db $00, $FF, $0D, $04, $00, $08, $00, $08, $00, $0F, $0E, $04, $00, $08, $00, $08
	.db $00, $1F, $0E, $04, $00, $08, $00, $08, $00, $2F, $0E, $04, $00, $08, $00, $08
	.db $00, $3F, $0E, $04, $00, $08, $00, $08, $00, $4F, $0E, $04, $00, $08, $00, $08
	.db $00, $5F, $0E, $04, $00, $08, $00, $08, $00, $6F, $0E, $04, $00, $08, $00, $08
	.db $00, $7F, $0E, $02, $00, $08, $00, $08, $00, $87, $0E, $02, $00, $08, $00, $08
	.db $00, $8F, $0E, $04, $00, $08, $00, $08, $00, $9F, $0E, $04, $00, $08, $00, $08
	.db $00, $AF, $0E, $04, $00, $08, $00, $08, $00, $BF, $0E, $04, $00, $08, $00, $08
	.db $00, $CF, $0E, $03, $00, $08, $00, $08, $00, $DB, $0E, $02, $00, $08, $00, $08
	.db $00, $E3, $0E, $02, $00, $08, $00, $08, $00, $EB, $0E, $03, $00, $08, $00, $08
	.db $00, $F7, $0E, $04, $00, $08, $00, $08, $00, $07, $0F, $04, $00, $08, $00, $08
	.db $00, $17, $0F, $05, $00, $08, $00, $08, $00, $2B, $0F, $05, $00, $08, $00, $08
	.db $00, $3F, $0F, $05, $00, $08, $00, $08, $00, $53, $0F, $06, $00, $08, $00, $0C
	.db $00, $6B, $0F, $06, $00, $08, $00, $0C, $00, $83, $0F, $06, $00, $08, $00, $0C
	.db $00, $9B, $0F, $05, $00, $08, $00, $08, $00, $AF, $0F, $05, $00, $08, $00, $08
	.db $00, $C3, $0F, $05, $00, $08, $00, $08, $00, $D7, $0F, $05, $00, $0C, $00, $08
	.db $00, $EB, $0F, $05, $00, $0C, $00, $08, $00, $FF, $0F, $05, $00, $0C, $00, $08
	.db $00, $13, $10, $05, $00, $08, $00, $08, $00, $27, $10, $05, $00, $08, $00, $08
	.db $00, $3B, $10, $05, $00, $08, $00, $08, $00, $4F, $10, $06, $00, $08, $00, $0C
	.db $00, $67, $10, $06, $00, $08, $00, $0C, $00, $7F, $10, $06, $00, $08, $00, $0C
	.db $00, $97, $10, $05, $00, $08, $00, $08, $00, $AB, $10, $05, $00, $08, $00, $08
	.db $00, $BF, $10, $05, $00, $08, $00, $08, $00, $D3, $10, $05, $00, $0C, $00, $08
	.db $00, $E7, $10, $05, $00, $0C, $00, $08, $00, $FB, $10, $05, $00, $0C, $00, $08
	.db $00, $0F, $11, $04, $00, $08, $00, $08, $00, $1F, $11, $04, $00, $08, $00, $08
	.db $00, $2F, $11, $04, $00, $08, $00, $08, $00, $3F, $11, $04, $00, $08, $00, $08
	.db $00, $4F, $11, $04, $00, $08, $00, $08, $00, $5F, $11, $04, $00, $08, $00, $08
	.db $00, $6F, $11, $04, $00, $08, $00, $08, $00, $7F, $11, $04, $00, $08, $00, $08
	.db $00, $8F, $11, $04, $00, $08, $00, $08, $00, $9F, $11, $04, $00, $08, $00, $08
	.db $00, $AF, $11, $04, $00, $08, $00, $08, $00, $BF, $11, $04, $00, $08, $00, $08
	.db $00, $CF, $11, $04, $00, $08, $00, $08, $00, $DF, $11, $04, $00, $08, $00, $08
	.db $00, $EF, $11, $04, $00, $08, $00, $08, $00, $FF, $11, $04, $00, $08, $00, $08
	.db $00, $0F, $12, $04, $00, $08, $00, $08, $00, $1F, $12, $04, $00, $08, $00, $08
	.db $00, $2F, $12, $04, $00, $08, $00, $08, $00, $3F, $12, $04, $00, $08, $00, $08
	.db $00, $4F, $12, $08, $00, $13, $00, $04, $00, $6F, $12, $05, $00, $06, $00, $0D
	.db $00, $83, $12, $06, $00, $06, $00, $0D, $00, $9B, $12, $03, $00, $08, $00, $00
	.db $00, $A7, $12, $03, $00, $07, $00, $00, $00, $B3, $12, $03, $00, $07, $00, $00
	.db $00, $BF, $12, $02, $00, $09, $00, $00, $00, $C7, $12, $03, $00, $08, $00, $00
	.db $00, $D3

; 2nd entry of Jump Table from 528 (indexed by unknown)
LABEL_800:
	ld (de), a
	inc b
	nop
	ld a, (bc)
	nop
	nop
	nop
	ex (sp), hl
	ld (de), a
	ld bc, $0500
	nop
	nop
	nop
	rst $20	; LABEL_20
; Data from 810 to 9E6 (471 bytes)
	.db $12, $0D, $00, $00, $00, $00, $00, $1B, $13, $0D, $00, $00, $00, $00, $00, $4F
	.db $13, $0C, $00, $00, $00, $00, $00, $7F, $13, $0B, $00, $00, $00, $00, $00, $AB
	.db $13, $0B, $00, $00, $00, $00, $00, $D7, $13, $0C, $00, $00, $00, $00, $00, $07
	.db $14, $0D, $00, $00, $00, $00, $00, $3B, $14, $0C, $00, $00, $00, $00, $00, $6B
	.db $14, $04, $00, $08, $00, $08, $00, $7B, $14, $04, $00, $08, $00, $08, $00, $8B
	.db $14, $04, $00, $08, $00, $08, $00, $9B, $14, $04, $00, $08, $00, $08, $00, $AB
	.db $14, $04, $00, $08, $00, $08, $00, $BB, $14, $04, $00, $08, $00, $08, $00, $CB
	.db $14, $04, $00, $08, $00, $08, $00, $DB, $14, $04, $00, $08, $00, $08, $00, $EB
	.db $14, $04, $00, $08, $00, $08, $00, $FB, $14, $04, $00, $08, $00, $08, $00, $0B
	.db $15, $05, $00, $10, $00, $08, $00, $1F, $15, $05, $00, $10, $00, $08, $00, $33
	.db $15, $05, $00, $10, $00, $08, $00, $47, $15, $06, $00, $10, $00, $08, $00, $5F
	.db $15, $04, $00, $08, $00, $08, $00, $6F, $15, $05, $00, $08, $00, $08, $00, $83
	.db $15, $05, $00, $08, $00, $08, $00, $97, $15, $06, $00, $08, $00, $08, $00, $AF
	.db $15, $04, $00, $08, $00, $08, $00, $BF, $15, $04, $00, $08, $00, $08, $00, $CF
	.db $15, $04, $00, $08, $00, $08, $00, $DF, $15, $04, $00, $08, $00, $08, $00, $EF
	.db $15, $04, $00, $08, $00, $08, $00, $FF, $15, $04, $00, $08, $00, $08, $00, $0F
	.db $16, $04, $00, $08, $00, $08, $00, $1F, $16, $02, $00, $08, $00, $08, $00, $27
	.db $16, $02, $00, $08, $00, $08, $00, $2F, $16, $02, $00, $08, $00, $08, $00, $37
	.db $16, $02, $00, $08, $00, $08, $00, $3F, $16, $02, $00, $08, $00, $08, $00, $47
	.db $16, $04, $00, $08, $00, $08, $00, $57, $16, $04, $00, $08, $00, $08, $00, $67
	.db $16, $04, $00, $08, $00, $08, $00, $77, $16, $02, $00, $08, $00, $08, $00, $7F
	.db $16, $02, $00, $08, $00, $08, $00, $87, $16, $02, $00, $08, $00, $08, $00, $8F
	.db $16, $02, $00, $08, $00, $08, $00, $97, $16, $02, $00, $08, $00, $08, $00, $9F
	.db $16, $06, $00, $00, $00, $00, $00, $B7, $16, $06, $00, $00, $00, $00, $00, $CF
	.db $16, $06, $00, $00, $00, $00, $00, $E7, $16, $06, $00, $00, $00, $00, $00, $FF
	.db $16, $06, $00, $00, $00, $00, $00, $17, $17, $03, $00, $08, $00, $08, $00, $23
	.db $17, $04, $00, $08, $00, $08, $00, $33, $17, $04, $00, $08, $00, $08, $00, $43
	.db $17, $03, $00, $08, $00, $08, $00, $4F, $17, $03, $00, $08, $00, $08, $00, $5B
	.db $17, $04, $00, $08, $00, $08, $00, $6B, $17, $04, $00, $08, $00, $08, $00, $7B
	.db $17, $04, $00, $08, $00, $08, $00

; 1st entry of Pointer Table from 3AF (indexed by $DA13)
; Data from 9E7 to 178A (3492 bytes)
DATA_9E7:
	#import "src/MSPacMan/Ms. Pac-Man (Europe, Brazil) (En)DATA_9E7.inc"

LABEL_178B:
	ld hl, $D9E7
	ld de, $D9E7 + 1
	ld (hl), $00
	ld bc, $0106
	ldir
	ld ix, $D907
	ld de, $001C
	ld (ix+0), $00
	add ix, de
	ld (ix+0), $01
	add ix, de
	ld (ix+0), $02
	add ix, de
	ld (ix+0), $03
	add ix, de
	ld (ix+0), $00
	add ix, de
	ld (ix+0), $01
	add ix, de
	ld (ix+0), $02
	add ix, de
	ld (ix+0), $03
	ret

LABEL_17CE:
	ld a, $14
	call LABEL_18F9
	ret

LABEL_17D4:
	ld c, $00
	ld b, $04
LABEL_17D8:
	push bc
	ld a, $14
	call LABEL_18F9
	pop bc
	inc c
	djnz LABEL_17D8
	xor a
	ld ix, $D907
	ld de, $001C
	ld b, $08
LABEL_17EC:
	ld (ix+5), a
	add ix, de
	djnz LABEL_17EC
	ret

LABEL_17F4:
	lea hl, iy
	ld e, $08
	ld d, $00
	add hl, de
LABEL_17FC:
	exx
LABEL_17FD:
	ld a, (ix+5)
	and a
	jr z, LABEL_182F
	inc a
	jr nz, LABEL_180C
	ld a, (ix-107)
	and a
	jr nz, LABEL_182F
LABEL_180C:
	ld l, (ix+3)
	ld h, (ix+4)
	ld a, (ix+6)
	add a, $05
	add a, l
	ld l, a
	jr nc, LABEL_181C
	inc h
LABEL_181C:
	ld a, (hl)
	and a
	jp m, LABEL_1826
LABEL_1821:
	call LABEL_188E
	jr LABEL_182F

LABEL_1826:
	cp $80
	jr z, LABEL_1821
	call LABEL_183D
	jr c, LABEL_17FD
LABEL_182F:
	inc iy
	inc iy
	exx
	inc hl
	ld de, $001C
	add ix, de
	djnz LABEL_17FC
	ret

LABEL_183D:
	neg
	dec a
	add a, a
	add a, $51
	ld e, a
	ld a, $18
	adc a, $00
	ld d, a
	ld a, (de)
	ld c, a
	inc de
	ld a, (de)
	ld d, a
	ld e, c
	push de
	ret

; Data from 1851 to 1856 (6 bytes)
	.db $57, $18, $5D, $18, $73, $18

LABEL_1857:
	ld (ix+6), $00
	scf
	ret

LABEL_185D:
	inc (ix+6)
	inc (ix+6)
	inc hl
	ld a, (hl)
	ld c, (ix+0)
	push ix
	push bc
	call LABEL_18F9
	pop bc
	pop ix
	scf
	ret

LABEL_1873:
	ld a, $03
	add a, (ix+6)
	ld (ix+6), a
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+1)
	ld h, (ix+2)
	add hl, de
	ld (ix+1), l
	ld (ix+2), h
	scf
	ret

LABEL_188E:
	ld c, a
	and $0F
	exx
	ld (hl), a
	exx
	ld a, c
	and a
	jr z, LABEL_18F4
	bit 5, (ix+7)
	jr nz, LABEL_18D0
	ld e, (ix+8)
	ld d, $00
	add hl, de
	ld a, (ix+0)
	cp $03
	jr nz, LABEL_18B3
	ld a, (hl)
	ld (iy+0), a
	inc (ix+6)
	ret

LABEL_18B3:
	ld e, (hl)
	bit 7, e
	jr z, LABEL_18B9
	dec d
LABEL_18B9:
	ld l, (ix+1)
	ld h, (ix+2)
	add hl, de
	ld (ix+1), l
	ld (ix+2), h
	ld (iy+0), l
	ld (iy+1), h
	inc (ix+6)
	ret

LABEL_18D0:
	ld a, (ix+8)
	add a, (ix+6)
	ld e, a
	ld d, $00
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+1)
	ld h, (ix+2)
	add hl, de
	ld (ix+1), l
	ld (ix+2), h
	ld (iy+0), l
	ld (iy+1), h
	inc (ix+6)
	ret

LABEL_18F4:
	ld (ix+5), $00
	ret

LABEL_18F9:
	push af
	ld a, ($D74A)
	and a
	jr z, LABEL_1902
	pop af
	ret

LABEL_1902:
	pop af
	push bc
	push de
	push hl
	push ix
	call LABEL_1911
	pop ix
	pop hl
	pop de
	pop bc
	ret

LABEL_1911:
	ld ($D9EA), a
	dec a
	bit 7, a
	jp nz, LABEL_19E0
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_737E + 7
	add hl, de
	ex de, hl
	ld hl, DATA_737E + $2E
	sbc hl, de
	ret c
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, (de)
	bit 3, a
	jr z, LABEL_1934
	ld c, $03
LABEL_1934:
	sla c
	ld l, c
	ld h, $00
	ld bc, DATA_1948
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	pop ix
	ex de, hl
	jp LABEL_19FE

; Data from 1948 to 194F (8 bytes)
DATA_1948:
	.db $77, $D9, $93, $D9, $AF, $D9, $CB, $D9

LABEL_1950:
	push de
	push bc
	push hl
	push ix
	push iy
	call LABEL_1962
	pop iy
	pop ix
	pop hl
	pop bc
	pop de
	ret

LABEL_1962:
	ld ($D9E8), a
	ld iy, $D9FE
	cp $FF
	jp z, LABEL_1A27
	dec a
	jp m, LABEL_19AE
	call LABEL_19AE
	ld a, $01
	ld ($D9E7), a
	ld a, ($D9E8)
	dec a
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_6F39
	add hl, de
	ex de, hl
	ld hl, DATA_6F39 + $26
	sbc hl, de
	jp c, LABEL_19AE
	ex de, hl
	ld ix, $D907
	ld b, $04
LABEL_1998:
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld (ix+12), e
	ld (ix+13), d
	ld (ix+10), $01
	ld de, $001C
	add ix, de
	djnz LABEL_1998
	ret

LABEL_19AE:
	ld ix, $D907
	ld b, $04
	ld hl, $DA06
	ld de, $001C
	xor a
LABEL_19BB:
	ld (hl), a
	inc hl
	ld (ix+5), a
	ld (ix+14), a
	ld (ix+18), a
	ld (ix+15), a
	ld (ix+21), a
	ld (ix+22), a
	ld (ix+26), a
	ld (ix+6), a
	add ix, de
	djnz LABEL_19BB
	ld ($D9EB), a
	ld ($D9E7), a
	ret

LABEL_19E0:
	ld b, $04
	ld ix, $D977
	ld hl, $D9F6
	ld de, $001C
LABEL_19EC:
	ld (hl), $00
	inc hl
	ld a, (ix+5)
	inc a
	jr z, LABEL_19F9
	ld (ix+5), $00
LABEL_19F9:
	add ix, de
	djnz LABEL_19EC
	ret

LABEL_19FE:
	ld (ix+6), $00
	ld (ix+3), l
	ld (ix+4), h
	ld a, (hl)
	inc hl
	ld (ix+7), a
	ld a, (hl)
	inc hl
	ld (ix+8), a
	ld a, (hl)
	inc hl
	ld (ix+1), a
	ld a, (hl)
	inc hl
	ld (ix+2), a
	ld a, (hl)
	ld (ix+5), a
	ld a, ($D9EA)
	ld (ix+9), a
	ret

LABEL_1A27:
	ld a, $10
	ld ($D9EB), a
	ld a, c
	ld ($D9EE), a
	xor a
	ld ($D9EC), a
	ret

LABEL_1A36:
	ld a, ($D9EB)
	and a
	ret z
	ld a, ($D9EC)
	dec a
	ld ($D9EC), a
	jp p, LABEL_1A59
	ld a, ($D9EE)
	ld ($D9EC), a
	ld a, ($D9EB)
	dec a
	ld ($D9EB), a
	jr nz, LABEL_1A59
	xor a
	ld c, a
	jp LABEL_1950

LABEL_1A59:
	ld hl, $DA06
	ld b, $03
LABEL_1A5E:
	ld d, (hl)
	ld a, ($D9EB)
	ld e, a
	xor a
	dec e
	jp m, LABEL_1A6D
LABEL_1A68:
	add a, d
	dec e
	jp p, LABEL_1A68
LABEL_1A6D:
	srl a
	srl a
	srl a
	srl a
	ld (hl), a
	inc hl
	djnz LABEL_1A5E
	ret

LABEL_1A7A:
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	exx
	push hl
	push de
	push bc
	exx
	ld a, ($DF10)
	and a
	jr z, LABEL_1A9A
	ld hl, $D906
	inc (hl)
	ld a, (hl)
	cp $06
	jr nz, LABEL_1A9A
	ld (hl), $00
	jr LABEL_1ABD

LABEL_1A9A:
	call LABEL_1C81
	ld iy, $D9FE
	ld ix, $D907
	ld b, $04
	call LABEL_17F4
	ld ix, $D977
	ld b, $04
	ld iy, $D9EE
	call LABEL_17F4
	call LABEL_1A36
	call LABEL_1ACB
LABEL_1ABD:
	exx
	pop bc
	pop de
	pop hl
	exx
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret

LABEL_1ACB:
	ld ix, $D907
	call LABEL_1B3D
	ld e, $80
	ld d, (iy+8)
	ld l, (iy+0)
	ld h, (iy+1)
	call LABEL_1B23
	ld ix, $D923
	call LABEL_1B3D
	ld e, $A0
	ld d, (iy+9)
	ld l, (iy+2)
	ld h, (iy+3)
	call LABEL_1B23
	ld ix, $D93F
	call LABEL_1B3D
	ld e, $C0
	ld d, (iy+10)
	ld l, (iy+4)
	ld h, (iy+5)
	call LABEL_1B23
	ld ix, $D95B
	call LABEL_1B3D
	ret

LABEL_1B23:
	ret

LABEL_1B3D:
	ld a, (ix+117)
	and a
	jr z, LABEL_1B4C
	inc a
	jr z, LABEL_1B51
	ld a, (ix+5)
	and a
	jr z, LABEL_1B51
LABEL_1B4C:
	ld iy, $D9FE
	ret

LABEL_1B51:
	ld iy, $D9EE
	ld de, $0070
	add ix, de
	ret

LABEL_1B5B:
	lea iy, ix
	ld a, (ix+21)
	and a
	jr z, LABEL_1B6A
	lea iy, iy+8
LABEL_1B6A:
	ld l, (iy+12)
	ld h, (iy+13)
	ld e, (iy+14)
	ld d, (iy+18)
	add hl, de
	bit 7, (hl)
	jr nz, LABEL_1B84
	inc de
	inc de
	ld (iy+14), e
	ld (iy+18), d
	ret

LABEL_1B84:
	ld a, (hl)
	cp $94
	jp z, LABEL_1BDF
	cp $95
	jp z, LABEL_1BF4
	cp $9D
	jp z, LABEL_1C23
	cp $9E
	jp z, LABEL_1C4A
	cp $FF
	jp z, LABEL_1C6E
	cp $FE
	jp z, LABEL_1C79
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_736C
	add hl, de
	ex de, hl
	ld hl, DATA_737E - 4
	sbc hl, de
	jr nc, LABEL_1BB6
	ld de, DATA_736C
LABEL_1BB6:
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	push bc
	push iy
	ld iy, $D9FE
	call LABEL_19FE
	ld (ix+9), $FF
	pop iy
	pop bc
	ld a, (iy+14)
	add a, $01
	ld (iy+14), a
	ld a, (iy+18)
	adc a, $00
	ld (iy+18), a
	jp LABEL_1B5B

LABEL_1BDF:
	ld (iy+14), $00
	ld (iy+18), $00
	dec (ix+11)
	jp nz, LABEL_1B5B
	ld (ix+21), $00
	jp LABEL_1B5B

LABEL_1BF4:
	inc hl
	ld a, (hl)
	ld (ix+11), a
	inc hl
	ld a, (hl)
	ld (ix+25), a
	inc hl
	ld a, (hl)
	ld (ix+20), a
	inc hl
	ld a, (hl)
	ld (ix+21), a
	ld a, (ix+14)
	add a, $05
	ld (ix+14), a
	ld a, (ix+18)
	adc a, $00
	ld (ix+18), a
	ld (ix+22), $00
	ld (ix+26), $00
	jp LABEL_1B5B

LABEL_1C23:
	dec (iy+15)
	jr nz, LABEL_1C3B
	ld a, (iy+14)
	add a, $01
	ld (iy+14), a
	ld a, (iy+18)
	adc a, $00
	ld (iy+18), a
	jp LABEL_1B5B

LABEL_1C3B:
	ld a, (iy+16)
	ld (iy+14), a
	ld a, (iy+19)
	ld (iy+18), a
	jp LABEL_1B5B

LABEL_1C4A:
	ld a, (iy+14)
	add a, $02
	ld (iy+14), a
	ld a, (iy+18)
	adc a, $00
	ld (iy+18), a
	ld a, (iy+14)
	ld (iy+16), a
	ld a, (iy+18)
	ld (iy+19), a
	inc hl
	ld a, (hl)
	ld (iy+15), a
	jp LABEL_1B5B

LABEL_1C6E:
	pop bc
	pop bc
	ld a, ($D9E8)
	call LABEL_1950
	jp LABEL_1A9A

LABEL_1C79:
	pop bc
	pop bc
	call LABEL_19AE
	jp LABEL_1A9A

LABEL_1C81:
	ld a, ($D9E7)
	and a
	ret z
	ld ix, $D907
	ld b, $04
LABEL_1C8C:
	dec (ix+10)
	jr nz, LABEL_1CC7
LABEL_1C91:
	call LABEL_1B5B
	ld a, (hl)
	and a
	jr z, LABEL_1CA1
	cp $7F
	jr z, LABEL_1CCF
	add a, (iy+17)
	sub $12
LABEL_1CA1:
	add a, a
	ld e, a
	ld d, $00
	ld iy, DATA_6F91
	add iy, de
	ld e, (iy+0)
	ld d, (iy+1)
	ld (ix+2), d
	ld (ix+1), e
	inc hl
	ld a, (hl)
	and a
	jr z, LABEL_1C91
	ld (ix+10), a
	ld (ix+6), $00
	ld (ix+5), $01
LABEL_1CC7:
	ld de, $001C
	add ix, de
	djnz LABEL_1C8C
	ret

LABEL_1CCF:
	inc hl
	ld a, (hl)
	and a
	jr z, LABEL_1C91
	ld (ix+10), a
	jr LABEL_1CC7

; 3rd entry of Jump Table from 4DFD (indexed by unknown)
LABEL_1CD9:
	di
	xor a
	ld ($DF04), a
	ld ($DF05), a
	ld a, ($DEFD)
	ld ($DF07), a
	ld a, ($DEFE)
	ld ($DF08), a
	ld a, ($DEFF)
	ld ($DF09), a
	ld a, ($DF00)
	ld ($DF0A), a
	ld a, ($DF01)
	ld ($DF0B), a
	xor a
	ld hl, $D772
	ld de, $D772 + 1
	ld bc, $06EB
	ld (hl), a
	ldir
	ld a, ($DF0F)
	ld ($DF10), a
	call LABEL_178B
	xor a
	ld ($D904), a
	ld a, $81
	ld ($DF06), a
	xor a
	ld ($DEFD), a
	ld a, $02
	ld ($DEFE), a
	xor a
	ld ($DF00), a
	ld a, $02
	ld ($DF01), a
	xor a
	ld ($DEFF), a
	ld hl, $0000
	ld ($D73E), hl
	call LABEL_2247
	ld ($D76E), hl
	xor a
	ld ($D771), a
	ld ($D770), hl
	ld ($DF0C), sp
	jp LABEL_1DE7

LABEL_1D4F:
	call LABEL_4384
	xor a
	ld ($D708), a
	ld ($D707), a
	ld ($DF05), a
	ld sp, ($DF0C)
	ld a, ($DF07)
	ld ($DEFD), a
	ld a, ($DF08)
	ld ($DEFE), a
	ld a, ($DF09)
	ld ($DEFF), a
	ld a, ($DF0A)
	ld ($DF00), a
	ld a, ($DF0B)
	ld ($DF01), a
	xor a
	ld ($DF06), a
	call LABEL_19E0
	call LABEL_19AE
	ld a, ($D800)
	ld c, a
	ld a, ($D802)
	or c
	and $3F
	jp nz, LABEL_1FD
	xor a
	jp LABEL_4DE7

; Data from 1D99 to 1D99 (1 bytes)
	.db $C9

LABEL_1D9A:
	di
	ld a, $07
	call LABEL_417B
	xor a
	ld ($FFFC), a
	ld de, ($D73E)
	ld hl, $A000
	add hl, de
	ld a, ($DA28)
	ld (hl), a
	inc hl
	ld a, ($DA29)
	ld (hl), a
	inc de
	inc de
	ld ($D73E), de
	ld a, $80
	ld ($FFFC), a
	call LABEL_4168
	ei
	ret

LABEL_1DC5:
	di
	ld a, $07
	call LABEL_417B
	ld.lil hl, (Bank7_Address)
	ld de, $2000
	add.lil hl, de
	ld de, ($D73E)
	add.lil hl, de
	ld.lil a, (hl)
	ld ($DA28), a
	inc.lil hl
	ld.lil a, (hl)
	ld ($DA29), a
	inc de
	inc de
	ld ($D73E), de
	call LABEL_4168
	ei
	ret

LABEL_1DE7:
	xor a
	ld ($D747), a
	ld l, a
	ld h, $00
	ld ($D748), hl
	call LABEL_2AA6
LABEL_1DF4:
	xor a
	ld ($D755), a
	call LABEL_2902
	jr LABEL_1E43

LABEL_1DFD:
	xor a
	ld ($D755), a
	push ix
	call LABEL_3A9E
	pop ix
	xor a
	ld ($D755), a
	ld a, ($DEFD)
	and a
	jp z, LABEL_20EC
	ld iy, $DA0E
	bit 7, (iy+64)
	jr z, LABEL_1E2D
	ld iy, $DA53
	bit 7, (iy+64)
	jr z, LABEL_1E2D
	ld a, ($DA4E)
	jp LABEL_20EC

LABEL_1E2D:
	ld a, ($DEFD)
	cp $01
	jr z, LABEL_1E34
LABEL_1E34:
	ld a, ($DEFD)
	cp $01
	jr z, LABEL_1E40
	call LABEL_29FD
	jr LABEL_1E43

LABEL_1E40:
	call LABEL_2E10
LABEL_1E43:
	xor a
	ld ($D70D), a
	ld ($D75F), a
	ld ($D75B), a
	ld ($D752), a
	cpl
	ld ($D755), a
	ld sp, $DED0
	call LABEL_19E0
	call LABEL_19AE
	ld a, $0A
	ld c, $01
	call LABEL_18F9
	ld a, $FF
	ld ($DF05), a
	ld hl, $0000
	ld ($D76E), hl
LABEL_1E6F:
	ld de, ($D76A)
	ld a, e
	or d
	jp z, LABEL_2145
	call LABEL_1E7D
	jr LABEL_1E6F

LABEL_1E7D:
	call LABEL_1E98
	ld a, ($D76E)
	and a
	jr nz, LABEL_1E94
	ld a, ($D76F)
	cp $03
	jr z, LABEL_1E91
	cp $0A
	jr nz, LABEL_1E94
LABEL_1E91:
	call LABEL_3AD2
LABEL_1E94:
	call LABEL_2035
	ret

LABEL_1E98:
	ld a, ($D76C)
	ld e, a
	inc a
	cp $04
	jr nz, LABEL_1EA2
	xor a
LABEL_1EA2:
	ld ($D76C), a
	ld a, e
	ld ($D76D), a
	rst $08	; LABEL_8
; Jump Table from 1EAA to 1EB1 (4 entries, indexed by $D76C)
DATA_1EAA:
	.dw LABEL_1EB2, LABEL_1EEE, LABEL_1EFD, LABEL_1F1A

; 1st entry of Jump Table from 1EAA (indexed by $D76C)
LABEL_1EB2:
	ld a, ($D83A)
	and a
	jr z, LABEL_1EC0
	call LABEL_4320
	call LABEL_2556
	jr LABEL_1ED7

LABEL_1EC0:
	ld a, $FF
	ld ($D74D), a
	xor a
	ld ($D761), a
	ld a, ($D70D)
	and a
	jr z, LABEL_1ED4
	call LABEL_2556
	jr LABEL_1ED7

LABEL_1ED4:
	call LABEL_2EC6
LABEL_1ED7:
	ld ix, $DA0E
	ld b, $08
	ld de, $0045
LABEL_1EE0:
	ld a, (ix+8)
	ld (ix+5), a
	add ix, de
	djnz LABEL_1EE0
	call LABEL_257C
	ret

; 2nd entry of Jump Table from 1EAA (indexed by $D76C)
LABEL_1EEE:
	call LABEL_27D6
	call LABEL_4064
	ld b, $10
	call LABEL_242C
	call LABEL_22DA
	ret

; 3rd entry of Jump Table from 1EAA (indexed by $D76C)
LABEL_1EFD:
	ld a, ($D83A)
	and a
	jr z, LABEL_1F0B
	call LABEL_4320
	call LABEL_2556
	jr LABEL_1F19

LABEL_1F0B:
	ld a, ($D70D)
	and a
	jr z, LABEL_1F16
	call LABEL_2556
	jr LABEL_1F19

LABEL_1F16:
	call LABEL_2EC6
LABEL_1F19:
	ret

; 4th entry of Jump Table from 1EAA (indexed by $D76C)
LABEL_1F1A:
	ld ix, $DA0E
	call LABEL_1FDD
	ld ix, $DA53
	ld a, (ix+9)
	and a
	jr z, LABEL_1F2E
	call LABEL_1FDD
LABEL_1F2E:
	ld a, ($D83A)
	and a
	jr z, LABEL_1F39
	call LABEL_4320
	jr LABEL_1F68

LABEL_1F39:
	xor a
	ld ($D75C), a
	ld a, ($D768)
	and a
	jr z, LABEL_1F68
	dec a
	ld ($D768), a
	jr nz, LABEL_1F68
	ld a, ($D780)
	and a
	jr z, LABEL_1F5A
	call LABEL_4320
	call LABEL_19E0
	call LABEL_19AE
	jr LABEL_1F68

LABEL_1F5A:
	ld a, $0A
	ld c, $01
	call LABEL_18F9
	xor a
	ld ($DA4F), a
	ld ($DA94), a
LABEL_1F68:
	call LABEL_27D6
	call LABEL_300B
	ld a, ($D755)
	and a
	jr z, LABEL_1FA5
	ld a, ($D83A)
	and a
	jr z, LABEL_1F91
	ld h, $0D
	ld l, $14
	ld a, $05
	call LABEL_55B6
	ld ($D74E), de
	ld ($D750), hl
	ld a, $FF
	ld ($D752), a
	jr LABEL_1FA5

LABEL_1F91:
	ld a, ($D752)
	and a
	jr z, LABEL_1FA5
	ld de, ($D74E)
	ld hl, ($D750)
	call LABEL_562E
	xor a
	ld ($D752), a
LABEL_1FA5:
	call LABEL_4064
	call LABEL_22D4
	call LABEL_53B7
	ld a, ($D747)
	cp $22
	jr nz, LABEL_1FDC
	ld hl, ($D748)
	ld de, $012C
	and a
	sbc hl, de
	jr nz, LABEL_1FD5
	ld a, ($D800)
	and $30
	jr z, LABEL_1FDC
	ld a, ($DEFB)
	cpl
	ld ($DEFB), a
	ld a, $0F
	ld c, $02
	call LABEL_18F9
LABEL_1FD5:
	ld hl, ($D748)
	inc hl
	ld ($D748), hl
LABEL_1FDC:
	ret

LABEL_1FDD:
	ld a, ($DF00)
	and a
	jr nz, LABEL_1FEB
	ld a, (ix+41)
	cp $01
	ret z
	jr LABEL_1FF1

LABEL_1FEB:
	ld a, (ix+41)
	cp $04
	ret z
LABEL_1FF1:
	add a, a
	add a, (ix+41)
	ld e, a
	ld d, $00
	ld iy, DATA_2029
	add iy, de
	ld a, (ix+58)
	sub (iy+2)
	daa
	ld a, (ix+59)
	sbc a, (iy+1)
	daa
	ld a, (ix+56)
	sbc a, (iy+0)
	daa
	ld a, (ix+57)
	sbc a, $00
	daa
	jr c, LABEL_2028
	inc (ix+41)
	inc (ix+64)
	ld a, $0F
	ld c, $02
	call LABEL_18F9
LABEL_2028:
	ret

; Data from 2029 to 2034 (12 bytes)
DATA_2029:
	.db $01, $00, $00, $05, $00, $00, $10, $00, $00, $30, $00, $00

LABEL_2035:
	ld a, ($D76D)
	and $01
	add a, a
	ld l, a
	ld h, $00
	ld de, DATA_282C
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld ($D855), hl
	call LABEL_28B8
	call LABEL_2634
	ld a, ($D832)
	ld ($D833), a
	ld a, ($D834)
	ld ($D835), a
	call LABEL_42E8
	call LABEL_2472
	call LABEL_7B5E
	ld a, ($D76D)
	rst $08	; LABEL_8
; Jump Table from 2068 to 206F (4 entries, indexed by $D76D)
DATA_2068:
	.dw LABEL_2071, LABEL_2070, LABEL_20AA, LABEL_2076

; 2nd entry of Jump Table from 2068 (indexed by $D76D)
LABEL_2070:
	ret

; 1st entry of Jump Table from 2068 (indexed by $D76D)
LABEL_2071:
	ld b, $12
	jp LABEL_239F

; 4th entry of Jump Table from 2068 (indexed by $D76D)
LABEL_2076:
	ld a, ($D758)
	and a
	ret z
	ld ix, $D87F
	ld a, ($D76E)
	and $08
	jr nz, LABEL_2092
	xor a
	ld (ix+8), a
	ld (ix+9), a
	ld (ix+10), a
	jr LABEL_20DE

LABEL_2092:
	ld iy, $D89F
	ld a, (iy+8)
	ld (ix+8), a
	ld a, (iy+9)
	ld (ix+9), a
	ld a, (iy+10)
	ld (ix+10), a
	jr LABEL_20DE

; 3rd entry of Jump Table from 2068 (indexed by $D76D)
LABEL_20AA:
	ld a, ($D762)
	and a
	ret z
	ld ix, $D87F
	ld a, ($D76E)
	and $10
	jr z, LABEL_20D2
	ld iy, $D8BF
	ld a, (iy+2)
	ld (ix+2), a
	ld a, (iy+3)
	ld (ix+3), a
	ld a, (iy+4)
	ld (ix+4), a
	jr LABEL_20DE

LABEL_20D2:
	ld (ix+2), $3F
	ld (ix+3), $3F
	ld (ix+4), $3F
LABEL_20DE:
	ld a, ($DF0F)
	and a
	jr nz, LABEL_20E8
	ld b, $E6
LABEL_20E6:
	djnz LABEL_20E6
LABEL_20E8:
	call LABEL_436B
	ret

LABEL_20EC:
	xor a
	ld ($D755), a
	ld a, ($DA3C)
	ld c, a
	ld a, ($DA81)
	cp c
	jr c, LABEL_20FB
	ld c, a
LABEL_20FB:
	ld a, c
	cp $07
	jr c, LABEL_2133
	ld c, a
	and $1F
	ld ($DF01), a
	bit 5, c
	jr z, LABEL_210C
	ld a, $1F
LABEL_210C:
	inc a
	ld ($DEFC), a
	ld a, ($DA52)
	and a
	jr z, LABEL_2124
	ld a, ($DA3C)
	ld c, a
	ld a, ($DA81)
	ld ($DA3C), a
	ld a, c
	ld ($DA81), a
LABEL_2124:
	ld a, ($DF02)
	and a
	jp nz, LABEL_213A
	ld a, $05
	ld ($DF02), a
	jp LABEL_1FD

LABEL_2133:
	xor a
	ld ($DF02), a
	jp LABEL_FA

LABEL_213A:
	dec a
	ld ($DF02), a
	and a
	jp z, LABEL_FA
	jp LABEL_1FD

LABEL_2145:
	ld a, $FF
	ld ($D70D), a
	ld ($D75F), a
	ld ($D74A), a
	cpl
	ld ($D755), a
	xor a
	ld ($D83A), a
	call LABEL_19E0
	ld b, $28
	call LABEL_2A86
	ld iy, $DA98
	ld de, $0045
	ld b, $06
	ld hl, $00FF
LABEL_216C:
	ld (iy+8), l
	ld (iy+9), h
	add iy, de
	djnz LABEL_216C
	ld b, $28
	call LABEL_2A86
	ld a, $FF
	ld ($D762), a
	ld de, $0000
	ld ($D77E), de
	ld a, $01
	ld ($D780), a
	ld b, $64
LABEL_218E:
	push bc
	call LABEL_1E7D
	pop bc
	ld a, b
	and a
	jr z, LABEL_2198
	dec b
LABEL_2198:
	ld de, ($D82F)
	ld a, e
	or d
	jr nz, LABEL_218E
	ld a, b
	and a
	jr nz, LABEL_218E
	ld ix, $D87F
	ld a, (ix+2)
	add a, (ix+3)
	add a, (ix+4)
	cp $BD
	jr z, LABEL_218E
	xor a
	ld ($D762), a
	ld ix, $DA0E
	ld iy, $DA53
	ld a, (ix+46)
	inc a
	cp $40
	jr nz, LABEL_21CB
	ld a, $20
LABEL_21CB:
	and $3F
	ld (ix+46), a
	inc (ix+64)
	ld c, (ix+46)
	ld a, ($DEFD)
	and $02
	jr z, LABEL_21F2
	ld a, (iy+46)
	inc a
	cp $40
	jr nz, LABEL_21E7
	ld a, $20
LABEL_21E7:
	and $3F
	ld (iy+46), a
	inc (iy+64)
	ld c, (iy+46)
LABEL_21F2:
	xor a
	ld ($D780), a
	call LABEL_4384
	xor a
	ld ($D74A), a
	ld c, $00
	ld a, ($DA3C)
	cp $02
	jr z, LABEL_2240
	inc c
	cp $05
	jr z, LABEL_2240
	inc c
	cp $09
	jr z, LABEL_2240
	inc c
	cp $20
	jr nz, LABEL_2244
	ld a, c
	call LABEL_5CAA
	call LABEL_47B4
	jp c, LABEL_1DF4
	ld a, ($DEFD)
	and a
	jr nz, LABEL_222A
	ld a, $FF
	ld ($DA93), a
LABEL_222A:
	ld ix, $DA0E
	ld a, $FF
	ld ($DA4E), a
	ld a, ($DA93)
	bit 7, a
	jr z, LABEL_223D
	jp LABEL_20EC

LABEL_223D:
	jp LABEL_1E34

LABEL_2240:
	ld a, c
	call LABEL_5CAA
LABEL_2244:
	jp LABEL_1DF4

LABEL_2247:
	ld hl, (DATA_2254)
	ld ($D8FF), hl
	ld hl, (DATA_2254 + 2)
	ld ($D901), hl
	ret

; Data from 2254 to 2257 (4 bytes)
DATA_2254:
	.db $43, $41, $4D, $53

LABEL_2258:
	xor a
	ld ($D707), a
	ld ($D708), a
	ld hl, $0000
	ld ($D82F), hl
	ld ($D82F), hl
	inc h
	ld ($D82D), hl
	ld ($D82D), hl
	call LABEL_2394
	call LABEL_257C
	call LABEL_22DA
	call LABEL_257C
	call LABEL_22DA
	call LABEL_2295
	ret

LABEL_2282:
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
	xor a
LABEL_228C:
	ld (ix+68), a
	inc a
	add ix, de
	djnz LABEL_228C
	ret

LABEL_2295:
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
	xor a
LABEL_229F:
	ld (ix+9), a
	add ix, de
	djnz LABEL_229F
	ret

; Data from 22A7 to 22D3 (45 bytes)
	.db $32, $4F, $D8, $21, $55, $25, $22, $53, $D8, $21, $00, $C0, $11, $01, $C0, $01
	.db $FF, $00, $36, $D0, $ED, $B0, $21, $00, $00, $22, $31, $D8, $21, $0E, $DA, $11
	.db $0F, $DA, $01, $27, $02, $36, $00, $ED, $B0, $CD, $DA, $22, $C9

LABEL_22D4:
	ld a, ($D84F)
	and a
	jr LABEL_22E4

LABEL_22DA:
	ld a, ($D84F)
	add a, $DE
	neg
	ld ($D84F), a
LABEL_22E4:
	ld de, $0000
	ld hl, $C000
	ld bc, $C000
	jr z, LABEL_22F8
	ld de, $0440
	ld hl, $C000
	ld bc, $C000
LABEL_22F8:
	ld ($D84D), de
	ld hl, $DA0E
	ld de, $DC36
	ld bc, $0A28
LABEL_2305:
	ld a, 69
_:	ldi
	dec a
	jr nz, -_
	djnz LABEL_2305
	ret

LABEL_2394:
	xor a
	ld ($D84F), a
	ld a, $D0
	ld ($C000), a
	ret

LABEL_239F:
	ld hl, $C100
	ld ($D851), hl
	ld hl, ($D84D)
	ld de, $0020
	ld ix, ($D851)
LABEL_23BB:
	push bc
	ld a, (ix)
	cp $AA
	jp z, LABEL_241E

	inc ix
	ld a, (ix)
	inc ix
	add a, $03
	call.lil SwitchBank + romStart

	ld e, (ix)
	inc ix
	ld d, (ix)
	inc ix

	push hl
	ld.lil bc, SegaVRAM
	add.lil hl, bc
	ex.lil de, hl
	call.lil UpdateBankAddress
	ld bc, 32
	ldir.lil
	ex de, hl
	pop hl

	ld bc, 32
	add hl, bc
	pop bc
	dec b
	jp nz, LABEL_23BB

	ld ($D84D), hl
	ld ($D851), ix
	ret

LABEL_241E:
	pop bc
	ld ($D851), ix
	ld ($D84D), hl
	ret

LABEL_2426:
	ld hl, $C100
	ld ($D851), hl
LABEL_242C:
	ld hl, ($D84D)
	ld de, $0020
	ld ix, ($D851)
LABEL_2444:
	push bc
	ld a, (ix)
	cp $AA
	jr z, LABEL_241E

	inc ix
	ld a, (ix)
	inc ix
	add a, $03
	call.lil SwitchBank + romStart
	ld e, (ix)
	inc ix
	ld d, (ix)
	inc ix

	push hl
	ld.lil bc, SegaVRAM
	add.lil hl, bc
	ex.lil de, hl
	call.lil UpdateBankAddress
	ld bc, 32
	ldir.lil
	ex de, hl
	pop hl

	ld bc, 32
	add hl, bc
	pop bc
	djnz LABEL_2444
	ld ($D84D), hl
	ld ($D851), ix
	ret

LABEL_2472:
	xor a
	ld.lil hl, romStart + $C000
	ld.lil de, SAT
	ld bc, 34
	ldir.lil
	ld e, (SAT + $80) & $F0
	ld l, $80
	ld bc, 68
	ldir.lil
	ld a, 1
	ld (DrawSATTrig), a
	ret

; Data from 2555 to 2555 (1 bytes)
	.db $00

LABEL_2556:
	ld b, $08
	ld de, $0045
	ld ix, $DA0E
LABEL_255F:
	ld a, (ix+0)
	ld (ix+14), a
	ld a, (ix+1)
	ld (ix+15), a
	ld a, (ix+2)
	ld (ix+16), a
	ld a, (ix+3)
	ld (ix+17), a
	add ix, de
	djnz LABEL_255F
	ret

LABEL_257C:
	ld hl, $C100
	ld a, ($D84F)
	ld c, a
	ld ix, $DA0E
	ld b, $08
LABEL_2589:
	exx
	call LABEL_2598
	exx
	ld de, $0045
	add ix, de
	djnz LABEL_2589
	ld (hl), $AA
	ret

LABEL_2598:
	ld a, (ix+9)
	and a
	ret z
	ld a, (ix+5)
	ld l, a
	inc a
	ret z
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, DATA_3AF
	add hl, de
	ex de, hl
	ld hl, DATA_9E7 - 6
	sbc hl, de
	ret c
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld b, (hl)
	inc hl
	ld (ix+10), b

	ex de, hl
	push bc
	ld bc, DATA_9E7 - $09E7
	add hl, bc
	pop bc
	ex de, hl

	ld (ix+12), e
	ld (ix+13), d
	inc hl
	ld a, (hl)
	inc hl
	ld (ix+18), a
	inc hl
	ld a, (hl)
	ld (ix+19), a

	push de
	pop iy
	exx
	ld a, c
	ld (ix+11), a
	add a, (ix+10)
	ld c, a
	push bc
	ld b, (ix+10)
LABEL_25DE:
	ld a, (iy+0)
	and $E0
	ld e, a
	ld d, (iy+1)
	ld (hl), $00
	inc l
	ld a, (iy+0)
	and $1F
	ld (hl), a
	inc l
	ld (hl), e
	inc l
	ld (hl), d
	inc l
	ld de, 4
	add iy, de
	djnz LABEL_25DE
	pop bc
	exx
	ret

LABEL_25FF:
	ld hl, $C000
	ld (hl), $D0
	ld e, l
	ld d, h
	set 7, e
	ld a, ($D84F)
	add a, $DE
	neg
	ld c, a
	exx
	ld a, ($D75E)
	and a
	ret nz
	ld ix, $DC36
	ld de, $0045
	ld b, $08
LABEL_261F:
	ld a, (ix+9)
	and a
	jr z, LABEL_262C
	push de
	push bc
	call LABEL_26DE
	pop bc
	pop de
LABEL_262C:
	add ix, de
	djnz LABEL_261F
	exx
	ld (hl), $D0
	ret

LABEL_2634:
	ld a, ($D704)
	bit 6, a
	jr z, LABEL_2648
	ld a, ($D757)
	xor $01
	ld ($D757), a
	ld a, $FF
	ld ($D74B), a
LABEL_2648:
	ld hl, $C000
	ld (hl), $D0
	ld e, l
	ld d, h
	set 7, e
	exx
	ld a, ($D75E)
	and a
	ret nz
	ld a, ($D74B)
	and a
	jr z, LABEL_269E
	ld a, ($D757)
	and $01
	jr nz, LABEL_269E
	ld ix, $DC7B
	call LABEL_26ED
	ld ix, $DC36
	call LABEL_26ED
	ld ix, $DE19
	call LABEL_26ED
	ld ix, $DDD4
	call LABEL_26ED
	ld ix, $DD8F
	call LABEL_26ED
	ld ix, $DD4A
	call LABEL_26ED
	ld ix, $DD05
	call LABEL_26ED
	ld ix, $DCC0
	call LABEL_26ED
	jr LABEL_26D6

LABEL_269E:
	ld ix, $DCC0
	call LABEL_26ED
	ld ix, $DD05
	call LABEL_26ED
	ld ix, $DD4A
	call LABEL_26ED
	ld ix, $DD8F
	call LABEL_26ED
	ld ix, $DC36
	call LABEL_26ED
	ld ix, $DC7B
	call LABEL_26ED
	ld ix, $DDD4
	call LABEL_26ED
	ld ix, $DE19
	call LABEL_26ED
LABEL_26D6:
	exx
	ld (hl), $D0
	xor a
	ld ($D74B), a
	ret

LABEL_26DE:
	ld l, (ix+0)
	ld h, (ix+1)
	push hl
	ld l, (ix+2)
	ld h, (ix+3)
	jr LABEL_2715

LABEL_26ED:
	ld a, (ix+9)
	and a
	ret z
	res 0, (ix+61)
	ld l, (ix+14)
	ld h, (ix+15)
	push hl
	ld l, (ix+16)
	ld h, (ix+17)
	ld a, (ix+68)
	cp $06
	jr nz, LABEL_2715
	ld d, $00
	ld e, (ix+65)
	bit 7, e
	jr z, LABEL_2714
	dec d
LABEL_2714:
	add hl, de
LABEL_2715:
	ld a, (ix+5)
	inc a
	jr nz, LABEL_271D
	pop hl
	ret

LABEL_271D:
	ld d, $00
	ld e, (ix+19)
	and a
	sbc hl, de
	ld de, ($D82F)
	and a
	sbc hl, de
	ld a, h
	and a
	jr z, LABEL_2735
	inc a
	jr nz, LABEL_2768
	jr LABEL_273A

LABEL_2735:
	ld a, l
	cp $C0
	jr nc, LABEL_2768
LABEL_273A:
	ex de, hl
	pop hl
	ld b, $00
	ld c, (ix+18)
	and a
	sbc hl, bc
	ld bc, ($D82D)
	and a
	sbc hl, bc
	ld bc, $0008
	add hl, bc
	ld c, l
	ld a, h
	ld l, (ix+12)
	ld h, (ix+13)
	exx
	ld c, (ix+11)
	exx
	and a
	jr z, LABEL_276A
	inc a
	jr z, LABEL_27A0
	sub $01
	jr z, LABEL_276A
	jr LABEL_2769

LABEL_2768:
	pop hl
LABEL_2769:
	ret

LABEL_276A:
	set 0, (ix+61)
	ld b, (ix+10)
LABEL_2771:
	inc hl
	inc hl
	ld a, c
	add a, (hl)
	jr c, LABEL_2798
	ex af, af'
	inc hl
	ld a, e
	add a, (hl)
	bit 7, d
	jr nz, LABEL_2783
	jr nc, LABEL_2789
	jr LABEL_2799

LABEL_2783:
	jr c, LABEL_2789
	cp $F8
	jr c, LABEL_2799
LABEL_2789:
	inc hl
	exx
	ld (hl), a
	inc l
	ex af, af'
	ld (de), a
	inc e
	ld a, c
	inc c
	ld (de), a
	inc e
	exx
	djnz LABEL_2771
	ret

LABEL_2798:
	inc hl
LABEL_2799:
	inc hl
	exx
	inc c
	exx
	djnz LABEL_2771
	ret

LABEL_27A0:
	set 0, (ix+61)
	ld b, (ix+10)
LABEL_27A7:
	inc hl
	inc hl
	ld a, c
	add a, (hl)
	jr nc, LABEL_27CE
	ex af, af'
	inc hl
	ld a, e
	add a, (hl)
	bit 7, d
	jr nz, LABEL_27B9
	jr nc, LABEL_27BF
	jr LABEL_27CF

LABEL_27B9:
	jr c, LABEL_27BF
	cp $F8
	jr c, LABEL_27CF
LABEL_27BF:
	inc hl
	exx
	ld (hl), a
	inc l
	ex af, af'
	ld (de), a
	inc e
	ld a, c
	inc c
	ld (de), a
	inc e
	exx
	djnz LABEL_27A7
	ret

LABEL_27CE:
	inc hl
LABEL_27CF:
	inc hl
	exx
	inc c
	exx
	djnz LABEL_27A7
	ret

LABEL_27D6:
	ld ix, $DA0E
	ld b, $08
LABEL_27DC:
	ld a, (ix+9)
	and a
	jr z, LABEL_2824
	ld h, (ix+1)
	ld l, (ix+0)
	ld d, (ix+15)
	ld e, (ix+14)
	ld c, $00
	and a
	sbc hl, de
	jr nc, LABEL_27FC
	ld d, c
	ld e, c
	inc c
	ex de, hl
	and a
	sbc hl, de
LABEL_27FC:
	ld a, l
	add a, a
	or c
	add a, a
	ld (ix+20), a
	ld h, (ix+3)
	ld l, (ix+2)
	ld d, (ix+17)
	ld e, (ix+16)
	ld c, $00
	and a
	sbc hl, de
	jr nc, LABEL_281D
	ld d, c
	ld e, c
	inc c
	ex de, hl
	and a
	sbc hl, de
LABEL_281D:
	ld a, l
	add a, a
	or c
	add a, a
	ld (ix+21), a
LABEL_2824:
	ld de, $0045
	add ix, de
	djnz LABEL_27DC
	ret

; Pointer Table from 282C to 282F (2 entries, indexed by $D76D)
DATA_282C:
	.dw DATA_2830, DATA_2874

; 1st entry of Pointer Table from 282C (indexed by $D76D)
; Data from 2830 to 2873 (68 bytes)
DATA_2830:
	.db $00, $00, $00, $00, $01, $00, $FF, $FF, $01, $00, $FF, $FF, $02, $00, $FE, $FF
	.db $02, $00, $FE, $FF, $03, $00, $FD, $FF, $03, $00, $FD, $FF, $04, $00, $FC, $FF
	.db $04, $00, $FC, $FF, $05, $00, $FB, $FF, $05, $00, $FB, $FF, $06, $00, $FA, $FF
	.db $06, $00, $FA, $FF, $07, $00, $F9, $FF, $07, $00, $F9, $FF, $08, $00, $F8, $FF
	.db $08, $00, $F8, $FF

; 2nd entry of Pointer Table from 282C (indexed by $D76D)
; Data from 2874 to 28B7 (68 bytes)
DATA_2874:
	.db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $FF, $FF, $01, $00, $FF, $FF
	.db $02, $00, $FE, $FF, $02, $00, $FE, $FF, $03, $00, $FD, $FF, $03, $00, $FD, $FF
	.db $04, $00, $FC, $FF, $04, $00, $FC, $FF, $05, $00, $FB, $FF, $05, $00, $FB, $FF
	.db $06, $00, $FA, $FF, $06, $00, $FA, $FF, $07, $00, $F9, $FF, $07, $00, $F9, $FF
	.db $08, $00, $F8, $FF

LABEL_28B8:
	exx
	ld d, $00
	ld bc, ($D855)
	exx
	ld ix, $DC36
	ld b, $08
	ld de, $0045
LABEL_28C9:
	ld a, (ix+9)
	and a
	jr z, LABEL_28FD
	exx
	ld l, (ix+20)
	ld h, $00
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+14)
	ld h, (ix+15)
	add hl, de
	ld (ix+14), l
	ld (ix+15), h
	ld l, (ix+21)
	ld h, $00
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+16)
	ld h, (ix+17)
	add hl, de
	ld (ix+16), l
	ld (ix+17), h
	exx
LABEL_28FD:
	add ix, de
	djnz LABEL_28C9
	ret

LABEL_2902:
	di
	call ClearTileCache
	xor a
	ld ($DA50), a
	ld a, ($DEFD)
	and $02
	jr z, LABEL_2912
	xor a
	ld ($DA95), a
LABEL_2912:
	ld ix, $DA0E
	ld a, (ix+62)
	and a
	jr nz, LABEL_2923
	ld a, $01
	ld c, $03
	call LABEL_1950
LABEL_2923:
	inc (ix+62)
	call LABEL_269
	ld ix, $DA0E
	ld a, (ix+47)
	call LABEL_46BE
LABEL_2933:
	call LABEL_2B18
	call LABEL_2BAD
	ld hl, $C100
	ld (hl), $AA
	xor a
	ld ($D76C), a
	ld ($D780), a
	ld a, $01
	ld ($D70D), a
	ld ($D781), a
	xor a
	ld ($D800), a
	ld ($D801), a
	ld ($D802), a
	ld ($D803), a
	xor a
	ld ($D755), a
	ei
	halt
	halt
	ld a, $01
	ld ($D75E), a
	call LABEL_1E7D
	call LABEL_1E7D
	call LABEL_1E7D
	call LABEL_1E7D
	ld h, $0D
	ld l, $14
	xor a
	call LABEL_55B6
	push hl
	push de
	ld h, $0C
	ld l, $0E
	ld a, ($D75D)
	add a, $02
	call LABEL_55B6
	push hl
	push de
	ld hl, $D8BF
	call LABEL_43B9
	ld a, $FF
	ld ($D758), a
	ld l, $32
	ld h, $00
	call LABEL_4B2D
	ld b, l
	call LABEL_2A86
	pop de
	pop hl
	call LABEL_562E
	xor a
	ld ($D75E), a
	xor a
	ld ($D781), a
	ld ($D782), a
LABEL_29B1:
	call LABEL_1E7D
	ld a, ($D782)
	and a
	jr z, LABEL_29B1
	ld b, $58
	call LABEL_2A86
	ld a, ($DA4E)
	dec a
	ld ($DA4E), a
	ld a, ($D75D)
	and $02
	jr z, LABEL_29D4
	ld a, ($DA93)
	dec a
	ld ($DA93), a
LABEL_29D4:
	call LABEL_1E7D
	ld a, ($D76C)
	and a
	jr nz, LABEL_29D4
	pop de
	pop hl
	call LABEL_562E
	ld a, ($DF06)
	and a
	ret z
	ld h, $0C
	ld l, $14
	ld a, $01
	call LABEL_55B6
	ret

LABEL_29FD:
	ld ($D700), ix
	ld hl, $C100
	ld (hl), $AA
	xor a
	ld ($D76C), a
	ld a, $01
	ld ($D70D), a
	xor a
	ld ($D755), a
	xor a
	ld ($D800), a
	ld ($D801), a
	ld ($D802), a
	ld ($D803), a
	di
	call LABEL_470D
	ei
	xor a
	ld ($D781), a
	call LABEL_2A8E
	ld a, $FF
	ld ($D75E), a
	call LABEL_2BAD
	ld h, $0D
	ld l, $14
	xor a
	call LABEL_55B6
	push hl
	push de
	ld h, $0C
	ld l, $0E
	ld a, ($D75D)
	add a, $02
	call LABEL_55B6
	push hl
	push de
	ld b, $23
	call LABEL_2A86
	xor a
	ld ($D75E), a
	pop de
	pop hl
	call LABEL_562E
	xor a
	ld ($D780), a
	ld ($D782), a
LABEL_2A62:
	call LABEL_1E7D
	ld a, ($D782)
	and a
	jr z, LABEL_2A62
	ld b, $19
	call LABEL_2A86
	ld ix, ($D700)
	dec (ix+64)
LABEL_2A77:
	call LABEL_1E7D
	ld a, ($D76C)
	and a
	jr nz, LABEL_2A77
	pop de
	pop hl
	call LABEL_562E
	ret

LABEL_2A86:
	push bc
	call LABEL_1E7D
	pop bc
	djnz LABEL_2A86
	ret

LABEL_2A8E:
	ld de, $0000
	ld ($D77E), de
	ld a, $01
	ld ($D780), a
LABEL_2A9A:
	call LABEL_1E7D
	ld de, ($D82F)
	ld a, e
	or d
	jr nz, LABEL_2A9A
	ret

LABEL_2AA6:
	ld a, ($DEFD)
	cp $03
	jr nz, LABEL_2AAF
	ld a, $02
LABEL_2AAF:
	cp $01
	jr nz, LABEL_2AB4
	xor a
LABEL_2AB4:
	ld ($D75D), a
	ld de, $C200
	ld bc, $0A80
	sla c
	rl b
	ld a, $72
	call LABEL_4361
	ld hl, LABEL_2B17	; Overriding return address
	push hl
	ld ix, $DA0E
	ld (ix+68), $00
	call LABEL_2ADD
	ld ix, $DA53
	ld (ix+68), $01
LABEL_2ADD:
	xor a
	ld (ix+56), a
	ld (ix+57), a
	ld (ix+58), a
	ld (ix+59), a
	ld a, ($DF01)
	and $1F
	ld c, a
	ld a, (ix+46)
	and $20
	or c
	ld (ix+46), a
	ld a, ($DF00)
	ld (ix+48), a
	ld (ix+64), $03
	ld a, (ix+46)
	and $1F
	srl a
	add a, $04
	ld (ix+45), a
	ld (ix+62), $00
	ld (ix+66), $00
LABEL_2B17:
	ret

LABEL_2B18:
	call LABEL_2258
	call LABEL_7A36
	di
	call LABEL_51D4
	call LABEL_4693
	call LABEL_4574
	xor a
LABEL_2B29:
	push af
	call LABEL_53CD
	pop af
	inc a
	cp $04
	jr nz, LABEL_2B29
	xor a
	ld ($D768), a
	call LABEL_2B88
	ld hl, DATA_5B88
	ld de, $D8BF
	ld bc, $0020
	ldir
	ld hl, $D8BF
	ld de, $D8DF
	ld bc, $0020
	ldir
	ld a, ($DF00)
	ld l, a
	ld a, ($DA3C)
	and $1F
	add a, l
	ld l, a
	ld h, $00
	ld de, DATA_5C59
	add hl, de
	ld a, (hl)
	add a, a
	add a, (hl)
	ld l, a
	ld h, $00
	ex de, hl
	ld iy, DATA_5C7D
	add iy, de
	ld a, (iy+0)
	ld ($D8C1), a
	ld a, (iy+1)
	ld ($D8C2), a
	ld a, (iy+2)
	ld ($D8C3), a
	xor a
	ld ($D758), a
	ld ($D76C), a
	ret

LABEL_2B88:
	ld ix, $D793
	ld b, $08
LABEL_2B8E:
	push bc
	ld a, ($D7CC)
	cp $01
	jr nz, LABEL_2B99
	xor a
	jr LABEL_2B9F

LABEL_2B99:
	ld b, a
	ld c, $07
	call LABEL_41B3
LABEL_2B9F:
	ld (ix+0), a
	inc ix
	pop bc
	djnz LABEL_2B8E
	xor a
	ld ($D79B), a
	ret

; Data from 2BAC to 2BAC (1 bytes)
	.db $C9

LABEL_2BAD:
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
	xor a
LABEL_2BB7:
	cp $02
	jr c, LABEL_2BBE
	ld (ix+68), a
LABEL_2BBE:
	inc a
	ld (ix+9), $00
	add ix, de
	djnz LABEL_2BB7
	ld ix, $DA0E
	ld ($D773), ix
	call LABEL_2BE1
	call LABEL_2C98
	call LABEL_2D9A
	ld a, $FF
	ld ($D767), a
	ld ($D766), a
	ret

LABEL_2BE1:
	call LABEL_32A
	ld a, $FF
	ld ($D766), a
	ld ix, $DA0E
	call LABEL_2C2A
	ld a, $01
	ld (ix+22), a
	ld a, $02
	ld (ix+23), a
	call LABEL_2F7C
	ld (ix+24), a
	ld (ix+25), a
	call LABEL_3723
	ld a, ($DEFD)
	and $02
	ret z
	ld ix, $DA53
	call LABEL_2C2A
	xor a
	ld (ix+22), a
	ld a, $02
	ld (ix+23), a
	call LABEL_2F7C
	ld (ix+24), a
	ld (ix+25), a
	call LABEL_3723
	ret

LABEL_2C2A:
	ld a, (ix+64)
	bit 7, a
	jr z, LABEL_2C36
	ld (ix+9), $00
	ret

LABEL_2C36:
	ld (ix+9), $01
	ld l, $1F
	bit 5, (ix+46)
	jr nz, LABEL_2C47
	ld l, (ix+46)
	res 5, l
LABEL_2C47:
	srl l
	srl l
	ld h, $00
	ld de, DATA_22B
	add hl, de
	ld e, (hl)
	ld a, $10
	call LABEL_4BFA
	push hl
	ld a, ($DEFF)
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_259
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	pop hl
	add hl, de
	call LABEL_4B39
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+35), l
	ld (ix+36), h
	ld (ix+37), l
	ld (ix+38), h
	ld (ix+60), $00
	ld (ix+44), $00
	ld (ix+63), $00
	ld (ix+65), $00
	ld (ix+6), $00
	ret

LABEL_2C98:
	ld ix, $DA98
	ld iy, DATA_2D0B
	ld b, $04
	ld a, ($DA3C)
	and $1F
	sub $28
	neg
	ld c, a
	ld e, $00
LABEL_2CAE:
	push bc
	ld a, c
	add a, e
	ld (ix+44), a
	ld a, c
	srl a
	add a, e
	ld e, a
	push de
	ld a, (iy+0)
	ld (ix+0), a
	ld (ix+1), $01
	ld a, (iy+1)
	ld (ix+2), a
	ld (ix+3), $00
	ld a, (iy+2)
	ld (ix+9), a
	ld a, (iy+3)
	ld (ix+42), a
	ld a, (iy+4)
	ld (ix+8), a
	call LABEL_2D1F
	ld a, $03
	ld (ix+24), a
	ld (ix+25), a
	ld a, $01
	ld (ix+22), a
	ld a, $02
	ld (ix+23), a
	xor a
	ld (ix+42), a
	ld (ix+41), a
	ld de, $0005
	add iy, de
	ld de, $0045
	add ix, de
	pop de
	pop bc
	djnz LABEL_2CAE
	ret

; Data from 2D0B to 2D1E (20 bytes)
DATA_2D0B:
	.db $78, $74, $02, $00, $26, $68, $8C, $06, $00, $28, $78, $8C, $06, $00, $2A, $88
	.db $8C, $06, $00, $2C

LABEL_2D1F:
	ld a, ($DA3C)
	bit 5, a
	jr z, LABEL_2D28
	ld a, $1F
LABEL_2D28:
	and $1F
	ld l, a
	ld h, $00
	ld de, DATA_239
	add hl, de
	ld e, (hl)
	ld a, $10
	call LABEL_4BFA
	push hl
	ld a, ($DEFF)
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_261
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	pop hl
	add hl, de
	ld a, (ix+68)
	sub $02
	neg
	add a, $03
	add a, a
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	call LABEL_4B39
	ld (ix+35), l
	ld (ix+36), h
	ld (ix+37), l
	ld (ix+38), h
LABEL_2D68:
	ld a, (ix+35)
	ld (ix+30), a
	ld a, (ix+36)
	ld (ix+31), a
	ld a, (ix+37)
	ld (ix+32), a
	ld a, (ix+38)
	ld (ix+33), a
	res 0, (ix+34)
	ret

LABEL_2D85:
	push hl
	ld l, (ix+35)
	ld h, (ix+36)
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	pop hl
	ret

LABEL_2D9A:
	ld ix, $DBAC
	ld a, ($DA3C)
	and $1F
	cp $07
	jr c, LABEL_2DB2
	call LABEL_41C3
	and $07
	cp $07
	jr nz, LABEL_2DB2
	ld a, $06
LABEL_2DB2:
	ld c, a
	ld a, ($DF00)
	cp $03
	jr nz, LABEL_2DCB
	ld a, ($DA3C)
	and $1F
	cp $0E
	jr c, LABEL_2DCB
	call LABEL_41C3
	and $07
	add a, $06
	ld c, a
LABEL_2DCB:
	ld (ix+53), c
	ret

; Data from 2DCF to 2E0F (65 bytes)
	.db $DD, $21, $80, $CC, $FD, $21, $00, $C2, $01, $80, $0A, $FD, $5E, $00, $DD, $56
	.db $00, $DD, $73, $00, $FD, $72, $00, $DD, $23, $FD, $23, $0B, $78, $B1, $20, $EB
	.db $C9, $06, $45, $DD, $21, $0E, $DA, $FD, $21, $53, $DA, $CD, $DC, $44, $DD, $5E
	.db $00, $FD, $56, $00, $DD, $72, $00, $FD, $73, $00, $DD, $23, $FD, $23, $10, $EE
	.db $C9

LABEL_2E10:
	ld a, ($DA93)
	bit 7, a
	jp nz, LABEL_29FD
	and a
	jp z, LABEL_29FD
	call LABEL_2A8E
	call LABEL_4384
	di
	call LABEL_470D
	ld a, ($D75D)
	xor $01
	ld ($D75D), a
	ld ix, $C200
	ld iy, $CC80
	ld bc, $0A80
	call LABEL_44DC
	ld ix, $DA0E
	ld iy, $DA53
	ld bc, $0045
	call LABEL_44DC
	ld ix, $D79C
	ld iy, $D7CD
	ld bc, $0010
	call LABEL_44DC
	ld ix, $D7BC
	ld iy, $D7ED
	ld bc, $0011
	call LABEL_44DC
	ld ix, $DA0E
	ld a, ($DA39)
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld ($D78C), hl
	ld a, (ix+62)
	and a
	jp z, LABEL_2902
	call LABEL_269
	jp LABEL_2933

LABEL_2E83:
	rst $08	; LABEL_8
; Jump Table from 2E84 to 2EC5 (33 entries, indexed by $DA5C)
DATA_2E84:
	.dw LABEL_5729, LABEL_33F4, LABEL_3B06, LABEL_3A2D, LABEL_3F95, LABEL_31DA, LABEL_3DD8, LABEL_382F
	.dw LABEL_403C, LABEL_3F21, LABEL_390F, LABEL_6222, LABEL_6218, LABEL_61DF, LABEL_61D5, LABEL_6368
	.dw LABEL_636F, LABEL_6565, LABEL_6587, LABEL_6588, LABEL_6727, LABEL_679B, LABEL_6783, LABEL_67DC
	.dw LABEL_6804, LABEL_6855, LABEL_686D, LABEL_68A6, LABEL_68C6, LABEL_6936, LABEL_4A18, LABEL_4ECF
	.dw LABEL_510A

LABEL_2EC6:
	ld a, ($D765)
	and a
	jr z, LABEL_2EDA
	dec a
	ld ($D765), a
	jr nz, LABEL_2EDA
	ld a, $FF
	ld ($D766), a
	ld ($D767), a
LABEL_2EDA:
	ld a, ($D776)
	and a
	ld a, ($D775)
	jr nz, LABEL_2EED
	dec a
	ld ($D775), a
	cp $FA
	jr z, LABEL_2EF7
	jr LABEL_2F01

LABEL_2EED:
	inc a
	ld ($D775), a
	cp $06
	jr z, LABEL_2EF7
	jr LABEL_2F01

LABEL_2EF7:
	ld a, ($D776)
	xor $01
	ld ($D776), a
	jr LABEL_2EDA

LABEL_2F01:
	ld ix, $DA0E
	ld b, $08
LABEL_2F07:
	ld a, (ix+9)
	and a
	jr z, LABEL_2F2A
	ld c, (ix+0)
	ld (ix+14), c
	ld c, (ix+1)
	ld (ix+15), c
	ld c, (ix+2)
	ld (ix+16), c
	ld c, (ix+3)
	ld (ix+17), c
	push bc
	call LABEL_2E83
	pop bc
LABEL_2F2A:
	ld de, $0045
	add ix, de
	djnz LABEL_2F07
	ret

LABEL_2F32:
	call LABEL_2F7C
	ld b, a
	add a, a
	add a, a
	add a, b
	add a, (ix+24)
	ld l, a
	ld h, $00
	ld de, DATA_2F63
	add hl, de
	ld a, (hl)
	and a
	ret z
	ld a, (ix+0)
	and $F8
	or $04
	ld (ix+0), a
	ld a, (ix+2)
	and $F8
	or $04
	ld (ix+2), a
	xor a
	ld (ix+28), a
	ld (ix+29), a
	scf
	ret

; Data from 2F63 to 2F7B (25 bytes)
DATA_2F63:
	.db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $01, $01, $00
	.db $01, $01, $00, $00, $00, $01, $01, $00, $00

LABEL_2F7C:
	ld a, (ix+23)
	bit 1, a
	jr nz, LABEL_2F87
	xor $01
	inc a
	ret

LABEL_2F87:
	ld a, (ix+22)
	bit 1, a
	jr nz, LABEL_2F93
	xor $01
	add a, $03
	ret

LABEL_2F93:
	xor a
	ret

; Data from 2F95 to 2FBB (39 bytes)
	.db $C9, $0E, $00, $DD, $7E, $16, $DD, $A6, $17, $E6, $02, $20, $18, $DD, $7E, $16
	.db $CB, $4F, $20, $05, $EE, $01, $C6, $03, $4F, $DD, $7E, $17, $CB, $4F, $20, $05
	.db $EE, $01, $3C, $81, $4F, $79, $C9

LABEL_2FBC:
	sub (ix+0)
	jr nc, LABEL_2FC3
	neg
LABEL_2FC3:
	cp b
	ret nc
	ld l, (ix+2)
	ld h, (ix+3)
	and a
	sbc hl, de
	jr nc, LABEL_2FD7
	ex de, hl
	ld hl, $0000
	and a
	sbc hl, de
LABEL_2FD7:
	ld b, $00
	and a
	sbc hl, bc
	ret

LABEL_2FDD:
	ld a, (ix+0)
	sub (iy+0)
	jr nc, LABEL_2FE7
	neg
LABEL_2FE7:
	cp $06
	jr nc, LABEL_3009
	ld l, (ix+2)
	ld h, (ix+3)
	ld e, (iy+2)
	ld d, (iy+3)
	and a
	sbc hl, de
	jr nc, LABEL_3003
	ex de, hl
	ld hl, $0000
	and a
	sbc hl, de
LABEL_3003:
	ld de, $0006
	and a
	sbc hl, de
LABEL_3009:
	ret

; Data from 300A to 300A (1 bytes)
	.db $C9

LABEL_300B:
	ld a, ($D75F)
	and a
	ret nz
	ld ix, $DBAC
	ld a, (ix+9)
	and a
	ret nz
	ld hl, ($D76A)
	ld a, h
	and a
	ret nz
	ld a, ($DA50)
	cp $02
	ret z
	and a
	ld a, l
	jr nz, LABEL_302E
	cp $A1
	ret nc
	jr LABEL_3031

LABEL_302E:
	cp $32
	ret nc
LABEL_3031:
	ld a, ($DA50)
	inc a
	ld ($DA50), a
	ld c, a
	ld a, ($DEFD)
	and $02
	jr z, LABEL_3044
	ld a, c
	ld ($DA95), a
LABEL_3044:
	ld hl, DATA_30AC
	ld e, (ix+53)
	ld d, $00
	add hl, de
	ld a, (hl)
	ld (ix+8), a
	ld (ix+5), $FF
	ld a, ($D79B)
	inc a
	and $07
	ld ($D79B), a
	ld l, a
	ld h, $00
	ld de, $D793
	add hl, de
	ld l, (hl)
	ld h, $00
	add hl, hl
	ld de, $D7BC
	add hl, de
	ld a, (hl)
	ld (ix+2), a
	inc hl
	ld a, (hl)
	ld (ix+3), a
	ld (ix+0), $01
	ld (ix+1), $01
	ld a, $05
	ld (ix+9), a
	ld (ix+24), $00
	ld (ix+25), $00
	ld hl, $00C0
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	ld a, $02
	ld (ix+23), a
	ld a, ($D76E)
	srl a
	srl a
	and $01
	ld (ix+22), a
	ret

; Data from 30AC to 30BA (15 bytes)
DATA_30AC:
	.db $18, $19, $1A, $1B, $1C, $1D, $1E, $BF, $C0, $C1, $C2, $C3, $C4, $C5, $C6

LABEL_30BB:
	call LABEL_2F7C
	ld (ix+24), a
	call LABEL_4554
	call LABEL_3122
	call LABEL_314A
	call LABEL_3172
	call LABEL_319A
	exx
	call LABEL_2F32
	jr c, LABEL_3118
	exx
	ld a, (hl)
	exx
	cp $6F
	jr nz, LABEL_3111
	ld a, (ix+68)
	sub $02
	jr c, LABEL_3111
	sub $04
	jr nc, LABEL_3111
	ld l, (ix+30)
	ld h, (ix+31)
	push hl
	srl h
	rr l
	ld (ix+30), l
	ld (ix+32), l
	ld (ix+31), h
	ld (ix+33), h
	call LABEL_3248
	pop hl
	ld (ix+30), l
	ld (ix+32), l
	ld (ix+31), h
	ld (ix+33), h
	jr LABEL_3114

LABEL_3111:
	call LABEL_3248
LABEL_3114:
	exx
	call LABEL_3350
LABEL_3118:
	ld a, (ix+24)
	and a
	jr z, LABEL_3121
	ld (ix+25), a
LABEL_3121:
	ret

LABEL_3122:
	ld a, (ix+26)
	and $04
	ret z
	ld a, (ix+23)
	xor (ix+22)
	and $02
	jr z, LABEL_313D
	push hl
	ld a, $02
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	ret c
LABEL_313D:
	set 0, (ix+22)
	res 1, (ix+22)
	set 1, (ix+23)
	ret

LABEL_314A:
	ld a, (ix+26)
	and $08
	ret z
	ld a, (ix+23)
	xor (ix+22)
	and $02
	jr z, LABEL_3165
	push hl
	ld a, $03
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	ret c
LABEL_3165:
	res 0, (ix+22)
	res 1, (ix+22)
	set 1, (ix+23)
	ret

LABEL_3172:
	ld a, (ix+26)
	and $01
	ret z
	ld a, (ix+23)
	xor (ix+22)
	and $02
	jr z, LABEL_318D
	push hl
	xor a
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	ret c
LABEL_318D:
	set 0, (ix+23)
	res 1, (ix+23)
	set 1, (ix+22)
	ret

LABEL_319A:
	ld a, (ix+26)
	and $02
	ret z
	ld a, (ix+23)
	xor (ix+22)
	and $02
	jr z, LABEL_31B5
	push hl
	ld a, $01
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	ret c
LABEL_31B5:
	res 0, (ix+23)
	res 1, (ix+23)
	set 1, (ix+22)
	ret

LABEL_31C2:
	ex de, hl
	add a, a
	ld l, a
	ld h, $00
	ld bc, DATA_31D2
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	ex de, hl
	ret

; Jump Table from 31D2 to 31D3 (1 entries, indexed by unknown)
DATA_31D2:
	.dw LABEL_478A

; Jump Table from 31D4 to 31D5 (1 entries, indexed by unknown)
	.dw LABEL_478F

; Jump Table from 31D6 to 31D7 (1 entries, indexed by unknown)
	.dw LABEL_4794

; Jump Table from 31D8 to 31D9 (1 entries, indexed by unknown)
	.dw LABEL_47A4

; 6th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_31DA:
	ld a, (ix+55)
	push af
	add a, $0C
	and $7F
	ld (ix+55), a
	or $80
	call LABEL_4D00
	sra a
	sra a
	sra a
	sra a
	ld (ix+65), a
	pop af
	sub (ix+55)
	jr c, LABEL_3206
	xor a
	ld (ix+55), a
	ld c, $02
	ld a, $02
	call LABEL_18F9
LABEL_3206:
	call LABEL_30BB
	call LABEL_4554
	ld a, l
	cp (ix+39)
	jr nz, LABEL_3217
	ld a, h
	cp (ix+40)
	ret z
LABEL_3217:
	ld (ix+39), l
	ld (ix+40), h
	call LABEL_3E82
	ld a, ($D77B)
	and a
	jr nz, LABEL_3229
	jp LABEL_5729

LABEL_3229:
	cp $01
	jr nz, LABEL_3234
	ld a, ($D777)
	ld b, a
	jp LABEL_3E5A

LABEL_3234:
	ld a, ($D77B)
	ld b, a
	ld c, $03
	call LABEL_41B3
	ld l, a
	ld h, $00
	ld de, $D777
	add hl, de
	ld b, (hl)
	jp LABEL_3E5A

LABEL_3248:
	ld a, ($D765)
	and a
	ret nz
	bit 1, (ix+22)
	jr nz, LABEL_3293
	ld a, (ix+2)
	and $F8
	or $04
	ld (ix+2), a
	bit 0, (ix+22)
	jr nz, LABEL_327C
	ld a, (ix+28)
	add a, (ix+30)
	ld (ix+28), a
	ld a, (ix+0)
	adc a, (ix+31)
	ld (ix+0), a
	jr nc, LABEL_3293
	ld (ix+14), a
	jr LABEL_3293

LABEL_327C:
	ld a, (ix+28)
	sub (ix+30)
	ld (ix+28), a
	ld a, (ix+0)
	sbc a, (ix+31)
	ld (ix+0), a
	jr nc, LABEL_3293
	ld (ix+14), a
LABEL_3293:
	ld a, $01
	ld (ix+1), a
	bit 1, (ix+23)
	ret nz
	ld a, (ix+0)
	and $F8
	or $04
	ld (ix+0), a
	bit 0, (ix+23)
	jr nz, LABEL_32C8
	ld a, (ix+29)
	add a, (ix+32)
	ld (ix+29), a
	ld a, (ix+2)
	adc a, (ix+33)
	ld (ix+2), a
	ld a, (ix+3)
	adc a, $00
	ld (ix+3), a
	ret

LABEL_32C8:
	ld a, (ix+29)
	sub (ix+32)
	ld (ix+29), a
	ld a, (ix+2)
	sbc a, (ix+33)
	ld (ix+2), a
	ld a, (ix+3)
	sbc a, $00
	ld (ix+3), a
	ret

LABEL_32E3:
	bit 0, (ix+22)
	jr nz, LABEL_3302
	ld a, (ix+28)
	add a, (ix+30)
	ld (ix+28), a
	ld a, (ix+0)
	adc a, (ix+31)
	ld (ix+0), a
	jr nc, LABEL_3319
	inc (ix+1)
	jr LABEL_3319

LABEL_3302:
	ld a, (ix+28)
	sub (ix+30)
	ld (ix+28), a
	ld a, (ix+0)
	sbc a, (ix+31)
	ld (ix+0), a
	jr nc, LABEL_3319
	dec (ix+1)
LABEL_3319:
	bit 0, (ix+23)
	jr nz, LABEL_3338
	ld a, (ix+29)
	add a, (ix+32)
	ld (ix+29), a
	ld a, (ix+2)
	adc a, (ix+33)
	ld (ix+2), a
	jr nc, LABEL_334F
	inc (ix+3)
	jr LABEL_334F

LABEL_3338:
	ld a, (ix+29)
	sub (ix+32)
	ld (ix+29), a
	ld a, (ix+2)
	sbc a, (ix+33)
	ld (ix+2), a
	jr nc, LABEL_334F
	dec (ix+3)
LABEL_334F:
	ret

LABEL_3350:
	xor a
	ex af, af'
	ld a, (ix+22)
	and (ix+23)
	and $02
	jp nz, LABEL_33F3
	bit 1, (ix+22)
	jr nz, LABEL_33A9
	ld a, (ix+2)
	and $F8
	or $04
	ld (ix+2), a
	ld a, (ix+22)
	and $01
	xor $03
	push hl
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	jr nc, LABEL_33A9
	bit 0, (ix+22)
	jr z, LABEL_338F
	ld a, (ix+0)
	and $07
	sub $04
	jr c, LABEL_3398
	jr LABEL_33A9

LABEL_338F:
	ld a, (ix+0)
	and $07
	sub $05
	jr c, LABEL_33A9
LABEL_3398:
	ld a, (ix+0)
	and $F8
	or $04
	ld (ix+0), a
	set 1, (ix+22)
	ex af, af'
	inc a
	ex af, af'
LABEL_33A9:
	bit 1, (ix+23)
	jr nz, LABEL_33F3
	ld a, (ix+0)
	and $F8
	or $04
	ld (ix+0), a
	ld a, (ix+23)
	and $01
	xor $01
	call LABEL_31C2
	ld a, (hl)
	cp $6E
	jr nc, LABEL_33F3
	bit 0, (ix+23)
	jr z, LABEL_33D9
	ld a, (ix+2)
	and $07
	sub $04
	jr c, LABEL_33E2
	jr LABEL_33F3

LABEL_33D9:
	ld a, (ix+2)
	and $07
	sub $05
	jr c, LABEL_33F3
LABEL_33E2:
	ld a, (ix+2)
	and $F8
	or $04
	ld (ix+2), a
	set 1, (ix+23)
	ex af, af'
	inc a
	ex af, af'
LABEL_33F3:
	ret

; 2nd entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_33F4:
	ld a, ($D75B)
	and a
	ret nz
	ld a, (ix+22)
	and (ix+23)
	and $02
	jr z, LABEL_3407
	xor a
	ld (ix+63), a
LABEL_3407:
	bit 0, (ix+63)
	jp nz, LABEL_34B4
	bit 7, (ix+65)
	jr z, LABEL_341A
	call LABEL_2D85
	jp LABEL_358A

LABEL_341A:
	ld a, ($DEFE)
	and a
	jr z, LABEL_348F
	dec a
	jr z, LABEL_3429
	ld (ix+44), $01
	jr LABEL_3469

LABEL_3429:
	bit 0, (ix+67)
	jr nz, LABEL_3440
	ld a, (ix+26)
	and $20
	jr z, LABEL_3451
	ld (ix+44), $01
	ld (ix+67), $01
	jr LABEL_3469

LABEL_3440:
	ld a, (ix+26)
	and $20
	jr nz, LABEL_3451
	ld (ix+44), $00
	ld (ix+67), $00
	jr LABEL_3460

LABEL_3451:
	ld a, (ix+27)
	and $10
	jr z, LABEL_3460
	ld a, (ix+44)
	xor $01
	ld (ix+44), a
LABEL_3460:
	ld hl, $0000
	ld a, (ix+44)
	and a
	jr z, LABEL_3477
LABEL_3469:
	ld l, (ix+30)
	ld h, (ix+31)
	srl h
	rr l
	srl h
	rr l
LABEL_3477:
	call LABEL_2D85
	ld e, (ix+30)
	ld d, (ix+31)
	add hl, de
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	jr LABEL_3492

LABEL_348F:
	call LABEL_2D85
LABEL_3492:
	bit 0, (ix+34)
	jr z, LABEL_34B2
	res 0, (ix+34)
	ld l, (ix+30)
	ld h, (ix+31)
	srl h
	rr l
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
LABEL_34B2:
	jr LABEL_34C5

LABEL_34B4:
	ld a, (ix+22)
	and (ix+23)
	and $02
	jr z, LABEL_34E1
	xor a
	ld (ix+63), a
	jp LABEL_33F4

LABEL_34C5:
	ld a, ($D768)
	and a
	jr z, LABEL_34E1
	ld l, (ix+30)
	ld h, (ix+31)
	ld de, $0040
	add hl, de
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
LABEL_34E1:
	bit 0, (ix+61)
	jr z, LABEL_34EF
	ld a, ($D704)
	bit 5, a
	jp z, LABEL_361F
LABEL_34EF:
	ld a, ($DEFD)
	and $02
	jp z, LABEL_358A
	ld a, (ix+68)
	and a
	jp nz, LABEL_358A
	ld a, ($DA92)
	or (ix+63)
	jp nz, LABEL_358A
	ld a, ($DA94)
	and a
	jp nz, LABEL_358A
	ld a, ($DA5C)
	and a
	jp z, LABEL_358A
	ld iy, $DA53
	call LABEL_2FDD
	jr nc, LABEL_358A
	ld a, $13
	ld c, $02
	call LABEL_18F9
	ld a, $01
	ld (ix+63), a
	ld (iy+63), a
	ld a, ($DA3F)
	ld c, a
	ld a, ($DA84)
	sub c
	jr z, LABEL_354E
	xor a
	jr c, LABEL_353B
	jr LABEL_353C

LABEL_353B:
	inc a
LABEL_353C:
	ld ($DA69), a
	xor $01
	ld ($DA24), a
	ld a, $02
	ld ($DA25), a
	ld ($DA6A), a
	jr LABEL_356F

LABEL_354E:
	ld de, ($DA41)
	ld hl, ($DA86)
	and a
	sbc hl, de
	xor a
	jr c, LABEL_355E
	jr LABEL_355F

LABEL_355E:
	inc a
LABEL_355F:
	ld ($DA6A), a
	xor $01
	ld ($DA25), a
	ld a, $02
	ld ($DA24), a
	ld ($DA69), a
LABEL_356F:
	ld hl, $0400
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	ld (iy+30), l
	ld (iy+31), h
	ld (iy+32), l
	ld (iy+33), h
LABEL_358A:
	ld iy, $DA98
	ld b, $04
LABEL_3590:
	push bc
	push iy
	ld a, (iy+9)
	cp $02
	jr nz, LABEL_35E5
	call LABEL_2FDD
	jr nc, LABEL_35E5
	ld a, (iy+42)
	cp $03
	jp nz, LABEL_3936
	bit 7, (ix+65)
	jr nz, LABEL_35E5
	xor a
	ld (iy+42), a
	ld a, $70
	ld (iy+41), a
	ld a, $04
	ld (iy+9), a
	ld de, $0400
	ld (iy+30), e
	ld (iy+31), d
	ld (iy+32), e
	ld (iy+33), d
	ld a, $11
	ld c, $01
	call LABEL_18F9
	ld a, (ix+68)
	ld ($D766), a
	ld a, $10
	ld ($D765), a
	ld a, (iy+68)
	ld ($D767), a
	call LABEL_3838
LABEL_35E5:
	pop iy
	pop bc
	ld de, $0045
	add iy, de
	djnz LABEL_3590
	bit 7, (ix+65)
	jp nz, LABEL_361F
	ld iy, $DBAC
	ld a, (iy+9)
	cp $05
	jr nz, LABEL_361F
	call LABEL_2FDD
	jr nc, LABEL_361F
	xor a
	ld (iy+9), a
	ld a, ($DBE1)
	ld e, a
	ld d, $00
	ld hl, DATA_3715
	add hl, de
	ld a, (hl)
	call LABEL_37EE
	ld c, $02
	ld a, $0E
	call LABEL_18F9
LABEL_361F:
	ld a, (ix+0)
	ld (ix+49), a
	ld a, (ix+1)
	ld (ix+50), a
	ld a, (ix+2)
	ld (ix+51), a
	ld a, (ix+3)
	ld (ix+52), a
	call LABEL_4554
	ld a, l
	cp (ix+39)
	jr nz, LABEL_3665
	ld a, h
	cp (ix+40)
	jr nz, LABEL_3665
	ld a, (ix+24)
	and a
	jr z, LABEL_3665
	ld l, (ix+24)
	ld h, $00
	ld de, DATA_3710
	add hl, de
	ld a, (hl)
	cpl
	and (ix+26)
	ld (ix+26), a
	ld l, (ix+39)
	ld h, (ix+40)
	jr LABEL_366B

LABEL_3665:
	ld (ix+39), l
	ld (ix+40), h
LABEL_366B:
	bit 0, (ix+63)
	jr z, LABEL_3674
	exx
	jr LABEL_3687

LABEL_3674:
	call LABEL_2F7C
	ld (ix+24), a
	call LABEL_3122
	call LABEL_314A
	call LABEL_3172
	call LABEL_319A
	exx
LABEL_3687:
	call LABEL_3248
	exx
	call LABEL_3350
	ex af, af'
	jr z, LABEL_3695
	ld (ix+63), $00
LABEL_3695:
	ld a, (ix+24)
	and a
	jr z, LABEL_369E
	ld (ix+25), a
LABEL_369E:
	call LABEL_3723
LABEL_36A1:
	call LABEL_4531
	cp $72
	ret z
	cp $70
	jr nz, LABEL_36C5
	bit 7, (ix+65)
	ret nz
	call LABEL_399C
	ld bc, $0010
	call LABEL_3919
	set 0, (ix+34)
	ld a, $05
	ld c, $00
	call LABEL_18F9
	ret

LABEL_36C5:
	cp $6F
	ret z
	cp $71
	jr nz, LABEL_36EF
	ld a, ($DEFB)
	and a
	jr nz, LABEL_36D7
	ld a, $0C
	ld ($D765), a
LABEL_36D7:
	call LABEL_399C
	call LABEL_3776
	ld bc, $0050
	call LABEL_3919
	xor a
	ld ($D769), a
	ld a, $0B
	ld c, $01
	call LABEL_18F9
	ret

LABEL_36EF:
	set 1, (ix+22)
	set 1, (ix+23)
	ld a, (ix+49)
	ld (ix+0), a
	ld a, (ix+50)
	ld (ix+1), a
	ld a, (ix+51)
	ld (ix+2), a
	ld a, (ix+52)
	ld (ix+3), a
	ret

; Data from 3710 to 3714 (5 bytes)
DATA_3710:
	.db $00, $0C, $0C, $03, $03

; Data from 3715 to 3722 (14 bytes)
DATA_3715:
	.db $00, $01, $04, $06, $09, $0A, $0D, $0B, $0C, $0E, $0F, $10, $11, $12

LABEL_3723:
	ld a, ($D766)
	cp (ix+68)
	jr nz, LABEL_3730
	ld (ix+8), $FF
	ret

LABEL_3730:
	bit 7, (ix+65)
	jr z, LABEL_3741
	ld a, (ix+68)
	xor $01
	add a, $83
	ld (ix+8), a
	ret

LABEL_3741:
	ld a, (ix+25)
	dec a
	and $03
	ld c, a
	add a, a
	add a, c
	add a, (ix+6)
	ld c, a
	bit 0, (ix+44)
	jr z, LABEL_3756
	add a, $56
LABEL_3756:
	ld c, a
	ld a, (ix+68)
	add a, a
	add a, a
	ld b, a
	add a, a
	add a, b
	add a, c
	ld (ix+8), a
	ld a, (ix+24)
	and a
	jr z, LABEL_3775
	ld a, (ix+6)
	inc a
	cp $03
	jr nz, LABEL_3772
	xor a
LABEL_3772:
	ld (ix+6), a
LABEL_3775:
	ret

LABEL_3776:
	push ix
	ld a, ($DEFD)
	cp $02
	jr nz, LABEL_3799
	xor a
	ld ($DA4F), a
	ld ($DA94), a
	ld iy, $DA0E
	ld a, (ix+68)
	cp $01
	jr z, LABEL_3795
	ld iy, $DA53
LABEL_3795:
	ld (iy+65), $FF
LABEL_3799:
	ld a, ($DA3C)
	bit 5, a
	jr z, LABEL_37A4
	ld a, $1F
	jr LABEL_37A9

LABEL_37A4:
	ld a, ($DA3C)
	and $1F
LABEL_37A9:
	add a, a
	add a, a
	ld b, a
	ld a, $82
	sub b
	ld ($D768), a
	ld a, $FF
	ld ($D75C), a
	ld iy, $DA98
	ld b, $06
LABEL_37BD:
	ld a, (iy+9)
	cp $04
	jr z, LABEL_37E3
	cp $02
	jr z, LABEL_37CE
	ld (iy+42), $03
	jr LABEL_37E3

LABEL_37CE:
	bit 0, (iy+34)
	jr nz, LABEL_37E3
	push ix
	lea ix, iy
	call LABEL_3AEF
	pop ix
	xor a
	ld (iy+42), a
LABEL_37E3:
	ld de, $0045
	add iy, de
	djnz LABEL_37BD
	pop ix
	ret

; Data from 37ED to 37ED (1 bytes)
	.db $C9

LABEL_37EE:
	push af
	call LABEL_38A3
	pop af
	ld iy, $DBF1
	add a, $6E
	ld (iy+8), a
	ld (iy+5), $FF
	ld a, $1E
	ld (iy+53), a
	ld e, (ix+0)
	ld d, (ix+1)
	ld (iy+0), e
	ld (iy+1), d
	ld (iy+14), e
	ld (iy+15), d
	ld e, (ix+2)
	ld d, (ix+3)
	ld (iy+2), e
	ld (iy+3), d
	ld (iy+16), e
	ld (iy+17), d
	ld a, $07
	ld (iy+9), a
	ret

; 8th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_382F:
	dec (ix+53)
	ret nz
	xor a
	ld (ix+9), a
	ret

LABEL_3838:
	push iy
	ld iy, $DBF1
	ld a, ($D769)
	ld c, a
	ld l, a
	ld h, $00
	ld de, DATA_3897
	add hl, de
	ld a, (hl)
	add a, $6E
	ld (iy+8), a
	ld (iy+5), $FF
	ld a, c
	inc a
	ld ($D769), a
	push iy
	sla c
	ld b, $00
	ld hl, DATA_389B
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	xor a
	call LABEL_391A
	pop iy
	ld e, (ix+0)
	ld d, (ix+1)
	ld (iy+0), e
	ld (iy+1), d
	ld (iy+14), e
	ld (iy+15), d
	ld e, (ix+2)
	ld d, (ix+3)
	ld (iy+2), e
	ld (iy+3), d
	ld (iy+16), e
	ld (iy+17), d
	ld a, $0A
	ld (iy+9), a
	pop iy
	ret

; Data from 3897 to 389A (4 bytes)
DATA_3897:
	.db $01, $03, $07, $13

; Data from 389B to 38A2 (8 bytes)
DATA_389B:
	.db $00, $02, $00, $04, $00, $08, $00, $16

LABEL_38A3:
	push iy
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld iy, DATA_38BF
	add iy, de
	ld a, (iy+0)
	ld c, (iy+2)
	ld b, (iy+3)
	call LABEL_391A
	pop iy
	ret

; Data from 38BF to 390E (80 bytes)
DATA_38BF:
	.db $00, $00, $00, $01, $00, $00, $00, $02, $00, $00, $00, $03, $00, $00, $00, $04
	.db $00, $00, $00, $05, $00, $00, $00, $06, $00, $00, $00, $07, $00, $00, $00, $08
	.db $00, $00, $00, $09, $00, $00, $00, $10, $00, $00, $00, $20, $00, $00, $00, $30
	.db $00, $00, $00, $40, $00, $00, $00, $50, $00, $00, $00, $60, $00, $00, $00, $70
	.db $00, $00, $00, $80, $00, $00, $00, $90, $01, $00, $00, $00, $00, $00, $00, $16

; 11th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_390F:
	ld a, ($D765)
	and a
	ret nz
	ld (ix+9), $00
	ret

LABEL_3919:
	xor a
LABEL_391A:
	ld l, (ix+56)
	ld h, (ix+57)
	ld e, (ix+58)
	ld d, (ix+59)
	call LABEL_4CE7
	ld (ix+56), l
	ld (ix+57), h
	ld (ix+58), e
	ld (ix+59), d
	ret

LABEL_3936:
	pop af
	pop af
	ld a, $FF
	ld ($D70D), a
	ld ($D75F), a
	ld ($D75B), a
	push ix
	call LABEL_42E8
	ld b, $28
LABEL_394A:
	push bc
	call LABEL_1E7D
	pop bc
	djnz LABEL_394A
	pop ix
	xor a
	ld ($D70D), a
	ld iy, $DA98
	xor a
	ld b, $06
	ld de, $0045
LABEL_3961:
	ld (iy+8), $FF
	ld (iy+5), $FF
	ld (iy+9), a
	add iy, de
	djnz LABEL_3961
	ld a, $03
	ld (ix+9), a
	xor a
	ld (ix+30), a
	ld (ix+32), a
	ld (ix+31), a
	ld (ix+33), a
	xor a
	ld (ix+60), a
	ld a, $0A
	ld (ix+53), a
	push ix
	call LABEL_17D4
	ld a, $06
	ld c, $00
	call LABEL_18F9
	pop ix
	jp LABEL_36A1

LABEL_399C:
	ld (hl), $72
	ld bc, $0000
	ld l, (ix+2)
	ld h, (ix+3)
	and a
	sbc hl, bc
	ld bc, ($D82F)
	and a
	sbc hl, bc
	jr nc, LABEL_39BD
	push hl
	ld bc, $FFE8
	add hl, bc
	bit 7, h
	pop hl
	jr nz, LABEL_39F2
LABEL_39BD:
	ld de, $00C8
	ex de, hl
	and a
	sbc hl, de
	jr c, LABEL_39F2
	ld l, (ix+2)
	ld h, (ix+3)
	ld de, ($D82F)
	and a
	sbc hl, de
	ld c, l
	ld a, (ix+0)
	add a, $08
	ld b, a
	ld ($D808), bc
	call LABEL_7C6A
	ld a, h
	add a, $38
	ld h, a
	call LABEL_428C
	ld a, $72
	ld.lil (hl), a
	inc.lil hl
	xor a
	ld.lil (hl), a
LABEL_39F2:
	ld a, ($D747)
	inc a
	ld ($D747), a
	ld de, ($D76A)
	dec de
	ld ($D76A), de
	ld a, ($D759)
	dec a
	ld ($D759), a
	bit 7, a
	jr z, LABEL_3A2B
	ld a, $0A
	ld ($D759), a
	push ix
	ld a, ($D75D)
	cp $02
	jr nz, LABEL_3A22
	ld ix, $DA53
	inc (ix+45)
LABEL_3A22:
	ld ix, $DA0E
	inc (ix+45)
	pop ix
LABEL_3A2B:
	ret
	ret

; 4th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_3A2D:
	ld a, (ix+53)
	and a
	jr z, LABEL_3A47
	dec a
	ld (ix+53), a
	ret nz
	ld a, (ix+68)
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld (ix+8), a
	ld (ix+54), $40
LABEL_3A47:
	ld a, (ix+8)
	inc a
	jr nz, LABEL_3A54
	dec (ix+55)
	jp z, LABEL_3A8D
	ret

LABEL_3A54:
	ld a, (ix+54)
	dec a
	ld (ix+54), a
	jr nz, LABEL_3A66
	ld (ix+55), $28
	ld (ix+8), $FF
	ret

LABEL_3A66:
	and $03
	jr nz, LABEL_3A88
	ld a, (ix+68)
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, (ix+54)
	srl a
	srl a
	and $03
	ld e, a
	ld d, $00
	ld hl, DATA_3A89
	add hl, de
	ld a, (hl)
	add a, c
	ld (ix+8), a
LABEL_3A88:
	ret

; Data from 3A89 to 3A8C (4 bytes)
DATA_3A89:
	.db $00, $06, $03, $09

LABEL_3A8D:
	ld a, ($DF06)
	and a
	jp nz, LABEL_1D4F
	ld a, (ix+64)
	and a
	jp z, LABEL_1DFD
	jp LABEL_1E34

LABEL_3A9E:
	ld (ix+64), $FF
	push ix
	call LABEL_2A8E
	pop ix
	ld h, $0C
	ld l, $0E
	ld a, (ix+68)
	add a, $02
	call LABEL_55B6
	push hl
	push de
	ld h, $0C
	ld l, $14
	ld a, $01
	call LABEL_55B6
	push hl
	push de
	ld b, $78
	call LABEL_2A86
	pop de
	pop hl
	call LABEL_562E
	pop de
	pop hl
	call LABEL_562E
	ret

LABEL_3AD2:
	ld ix, $DA98
	call LABEL_3AEF
	ld ix, $DADD
	call LABEL_3AEF
	ld ix, $DB22
	call LABEL_3AEF
	ld ix, $DB67
	call LABEL_3AEF
	ret

LABEL_3AEF:
	ld a, (ix+24)
	cp (ix+25)
	ret nz
	ld a, (ix+9)
	cp $02
	ret nz
	ld a, (ix+42)
	and a
	ret z
	ld (ix+54), $FF
	ret

; 3rd entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_3B06:
	ld a, ($D75C)
	and a
	jr z, LABEL_3B2C
	bit 0, (ix+34)
	jr nz, LABEL_3B74
	ld hl, $0100
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+34)
	ld a, $03
	ld (ix+42), a
	jr LABEL_3B74

LABEL_3B2C:
	ld a, (ix+68)
	cp $02
	jr nz, LABEL_3B74
	ld a, ($DA3C)
	cp $04
	jr c, LABEL_3B74
	ld a, (ix+42)
	cp $03
	jr z, LABEL_3B74
	ld de, ($D76A)
	ld hl, $FFE0
	add hl, de
	bit 7, h
	jr z, LABEL_3B74
	ld a, e
	and $1F
	neg
	add a, $1F
	srl a
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld e, (ix+35)
	ld d, (ix+36)
	add hl, de
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
LABEL_3B74:
	ld a, (ix+42)
	rst $08	; LABEL_8
; Jump Table from 3B78 to 3B81 (5 entries, indexed by $DA7D)
DATA_3B78:
	.dw LABEL_3B82, LABEL_3C9B, LABEL_3CC2, LABEL_3C3C, LABEL_3C95

; 1st entry of Jump Table from 3B78 (indexed by $DA7D)
LABEL_3B82:
	ld a, ($D75D)
	cp $02
	jr nz, LABEL_3BA1
	ld a, ($D75A)
	xor $01
	ld ($D75A), a
	jr nz, LABEL_3B99
	call LABEL_3BEC
	call LABEL_3C14
LABEL_3B99:
	call LABEL_3C14
	call LABEL_3BEC
	jr LABEL_3BA4

LABEL_3BA1:
	call LABEL_3BEC
LABEL_3BA4:
	ld (ix+53), $00
	call LABEL_41C3
	and $1C
	cp (ix+43)
	jr nz, LABEL_3BB6
	add a, $04
	and $1C
LABEL_3BB6:
	ld (ix+43), a
	ld e, a
	ld d, $00
	ld iy, $D79C
	add iy, de
	ld a, (iy+0)
	ld (ix+45), a
	ld a, (iy+1)
	ld (ix+46), a
	ld a, (iy+2)
	ld (ix+47), a
	ld a, (iy+3)
	ld (ix+48), a
	call LABEL_41C3
	and $1F
	add a, $08
	ld (ix+41), a
	ld a, $02
	ld (ix+42), a
	jp LABEL_3B06

LABEL_3BEC:
	ld a, (ix+53)
	cp $0F
	ret nc
	ld iy, $DA0E
	call LABEL_4D59
	ld a, l
	cp (iy+45)
	ret nc
	call LABEL_41C3
	and $1F
	add a, $22
	ld (ix+41), a
	ld a, $01
	ld (ix+42), a
	inc (ix+53)
	pop af
	jp LABEL_3B06

LABEL_3C14:
	ld a, (ix+53)
	cp $10
	ret nc
	ld iy, $DA53
	call LABEL_4D59
	ld a, l
	cp (iy+45)
	ret nc
	call LABEL_41C3
	and $1F
	add a, $1E
	ld (ix+41), a
	ld a, $04
	ld (ix+42), a
	inc (ix+53)
	pop af
	jp LABEL_3B06

; 4th entry of Jump Table from 3B78 (indexed by $DA7D)
LABEL_3C3C:
	ld a, ($D768)
	and a
	jr nz, LABEL_3C48
	call LABEL_2D68
	jp LABEL_3B82

LABEL_3C48:
	ld iy, $DA0E
	ld a, (iy+0)
	ld ($D78F), a
	ld l, (iy+2)
	ld h, (iy+3)
	ld ($D791), hl
	call LABEL_3D2C
	call LABEL_3CE8
	xor a
	ld (ix+30), a
	ld (ix+32), a
	inc a
	ld (ix+31), a
	ld (ix+33), a
	ret

LABEL_3C70:
	ld a, ($D76E)
	srl a
	srl a
	srl a
	and $03
	ld c, a
	ld a, (ix+68)
	sub $02
	cp c
	ret nz
	ld e, $20
	call LABEL_41C5
	ld e, (iy+46)
	res 5, e
	sub e
	jr nc, LABEL_3C94
	ld (ix+41), $00
LABEL_3C94:
	ret

; 5th entry of Jump Table from 3B78 (indexed by $DA7D)
LABEL_3C95:
	ld iy, $DA53
	jr LABEL_3C9F

; 2nd entry of Jump Table from 3B78 (indexed by $DA7D)
LABEL_3C9B:
	ld iy, $DA0E
LABEL_3C9F:
	call LABEL_3C70
	ld a, (ix+41)
	and a
	jp z, LABEL_3B82
	dec (ix+41)
	ld a, (iy+0)
	ld ($D78F), a
	ld l, (iy+2)
	ld h, (iy+3)
	ld ($D791), hl
	call LABEL_3D2C
	call LABEL_3CE8
	ret

; 3rd entry of Jump Table from 3B78 (indexed by $DA7D)
LABEL_3CC2:
	ld a, (ix+41)
	dec a
	ld (ix+41), a
	and a
	jr nz, LABEL_3CCF
	ld (ix+42), a
LABEL_3CCF:
	ld l, (ix+45)
	ld h, (ix+46)
	ld ($D78F), hl
	ld l, (ix+47)
	ld h, (ix+48)
	ld ($D791), hl
	call LABEL_3D2C
	call LABEL_3CE8
	ret

LABEL_3CE8:
	ld a, (ix+42)
	cp $03
	jr z, LABEL_3D10
	ld a, (ix+68)
	sub $02
	add a, a
	ld c, a
	ld a, (ix+25)
	dec a
	and $03
	add a, a
	add a, a
	add a, a
	add a, $26
	add a, c
	ld c, a
	ld a, ($D76E)
	rra
	rra
	rra
	and $01
	add a, c
	ld (ix+8), a
	ret

LABEL_3D10:
	ld a, ($D768)
	rra
	rra
	rra
	and $01
	ld c, a
	ld a, ($D768)
	cp $40
	jr nc, LABEL_3D25
	and $04
	rra
	add a, c
	ld c, a
LABEL_3D25:
	ld a, c
	add a, $46
	ld (ix+8), a
	ret

LABEL_3D2C:
	call LABEL_30BB
	call LABEL_4554
	ld a, l
	cp (ix+39)
	jr nz, LABEL_3D59
	ld a, h
	cp (ix+40)
	jr nz, LABEL_3D59
	ld a, (ix+54)
	and a
	jr z, LABEL_3D58
	ld a, (ix+25)
	dec a
	xor $01
	inc a
	ld (ix+25), a
	ld (ix+24), a
	ld (ix+54), $00
	call LABEL_3E0B
LABEL_3D58:
	ret

LABEL_3D59:
	call LABEL_3E0B
	ret

LABEL_3D5D:
	ld l, (ix+2)
	ld h, (ix+3)
	ex de, hl
	and a
	sbc hl, de
	jr nc, LABEL_3D72
	ld de, $0000
	ex de, hl
	ccf
	sbc hl, de
	set 1, h
LABEL_3D72:
	srl h
	rr l
	srl h
	rr l
	ld b, l
	ld e, (ix+0)
	ld d, (ix+1)
	ld l, c
	ld h, $01
	and a
	sbc hl, de
	jr nc, LABEL_3D92
	ld de, $0000
	ex de, hl
	ccf
	sbc hl, de
	set 1, h
LABEL_3D92:
	srl h
	rr l
	srl h
	rr l
	ld a, b
	ld b, l
	ld c, a
	ld de, $0200
	ld a, b
	and $7F
	ld l, c
	res 7, l
	cp l
	jr c, LABEL_3DAF
	ld de, $0002
	ld a, c
	ld c, b
	ld b, a
LABEL_3DAF:
	bit 7, b
	jr nz, LABEL_3DB4
	inc d
LABEL_3DB4:
	bit 7, c
	jr nz, LABEL_3DB9
	inc e
LABEL_3DB9:
	ret

; Data from 3DBA to 3DD7 (30 bytes)
	.db $3A, $39, $DA, $87, $87, $6F, $DD, $7E, $02, $95, $DD, $7E, $03, $DE, $00, $3F
	.db $17, $87, $E6, $02, $6F, $DD, $7E, $00, $87, $17, $E6, $01, $B5, $C9

; 7th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_3DD8:
	ld a, ($D765)
	and a
	ret nz
	ld a, ($D775)
	add a, $8B
	ld (ix+2), a
	ld (ix+3), $00
	ld a, ($D776)
	inc a
	ld (ix+25), a
	call LABEL_3CE8
	ld a, (ix+44)
	and a
	jr nz, LABEL_3E03
	ld a, ($D775)
	and a
	ret nz
	ld (ix+9), $09
	ret

LABEL_3E03:
	ld a, (ix+44)
	dec a
	ld (ix+44), a
	ret

LABEL_3E0B:
	ld (ix+39), l
	ld (ix+40), h
	call LABEL_3E82
	ld a, ($D77B)
	and a
	jp z, LABEL_5729
	cp $01
	jr nz, LABEL_3E2D
	ld a, ($D777)
	ld c, a
	ld a, (ix+25)
	dec a
	and $03
	ld b, a
	cp c
	jr z, LABEL_3E5A
LABEL_3E2D:
	push hl
	ld de, ($D791)
	ld a, ($D78F)
	ld c, a
	call LABEL_3D5D
	pop hl
	ld a, (ix+42)
	cp $03
	jr nz, LABEL_3E4A
	ld a, e
	xor $01
	ld e, a
	ld a, d
	xor $01
	ld d, e
	ld e, a
LABEL_3E4A:
	ld a, e
	call LABEL_3E6A
	jr c, LABEL_3E5A
	ld a, d
	call LABEL_3E6A
	jr c, LABEL_3E5A
	ld a, ($D777)
	ld b, a
LABEL_3E5A:
	ld e, b
	ld d, $00
	ld hl, DATA_3E66
	add hl, de
	ld a, (hl)
	ld (ix+26), a
	ret

; Data from 3E66 to 3E69 (4 bytes)
DATA_3E66:
	.db $01, $02, $04, $08

LABEL_3E6A:
	ld b, a
	ld a, ($D77B)
	and a
	jp z, LABEL_5729
	ld c, a
	ld hl, $D777
	ld a, b
LABEL_3E77:
	cp (hl)
	jr z, LABEL_3E80
	inc hl
	dec c
	jr nz, LABEL_3E77
	and a
	ret

LABEL_3E80:
	scf
	ret

LABEL_3E82:
	exx
	ld iy, $D777
	ld hl, $D777
	ld a, $FF
	ld (iy+0), a
	ld (iy+1), a
	ld (iy+2), a
	ld c, $00
	exx
	ld a, (ix+25)
	dec a
	ld ($D77D), a
	ld ($D77C), a
	ld a, ($D77C)
	push hl
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	jr c, LABEL_3EB7
	exx
	ld a, ($D77C)
	ld (hl), a
	inc hl
	inc c
	exx
LABEL_3EB7:
	ld a, ($D77D)
	call LABEL_3F03
	ld ($D77C), a
	push hl
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	jr c, LABEL_3ED2
	exx
	ld a, ($D77C)
	ld (hl), a
	inc hl
	inc c
	exx
LABEL_3ED2:
	ld a, ($D77D)
	call LABEL_3F12
	ld ($D77C), a
	push hl
	call LABEL_31C2
	ld a, (hl)
	pop hl
	cp $6E
	jr c, LABEL_3EED
	exx
	ld a, ($D77C)
	ld (hl), a
	inc hl
	inc c
	exx
LABEL_3EED:
	exx
	ld a, c
	and a
	jr nz, LABEL_3EFE
	ld a, (ix+25)
	dec a
	xor $01
	inc a
	ld ($D777), a
	ld a, $01
LABEL_3EFE:
	ld ($D77B), a
	exx
	ret

LABEL_3F03:
	ex de, hl
	ld c, a
	ld b, $00
	ld hl, DATA_3F0E
	add hl, bc
	ld a, (hl)
	ex de, hl
	ret

; Data from 3F0E to 3F11 (4 bytes)
DATA_3F0E:
	.db $03, $02, $00, $01

LABEL_3F12:
	ex de, hl
	ld c, a
	ld b, $00
	ld hl, DATA_3F1D
	add hl, bc
	ld a, (hl)
	ex de, hl
	ret

; Data from 3F1D to 3F20 (4 bytes)
DATA_3F1D:
	.db $02, $03, $01, $00

; 10th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_3F21:
	ld a, ($D765)
	and a
	jr nz, LABEL_3F4D
	ld a, (ix+0)
	sub $78
	jr z, LABEL_3F4E
	jr c, LABEL_3F37
	dec (ix+0)
	ld a, $03
	jr LABEL_3F3C

LABEL_3F37:
	inc (ix+0)
	ld a, $04
LABEL_3F3C:
	ld (ix+24), a
	ld (ix+25), a
	call LABEL_3CE8
	ld a, (ix+2)
	and $FE
	ld (ix+2), a
LABEL_3F4D:
	ret

LABEL_3F4E:
	ld a, $01
	ld (ix+24), a
	ld (ix+25), a
	call LABEL_3CE8
	ld a, (ix+2)
	sub $02
	ld (ix+2), a
	ld de, $0074
	ld a, $78
	ld b, $02
	ld c, $02
	call LABEL_2FBC
	ret nc
	ld (ix+9), $02
	ld a, (ix+42)
	cp $03
	jr nz, LABEL_3F8D
	ld hl, $0100
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	set 7, (ix+34)
	ret

LABEL_3F8D:
	ld (ix+42), $00
	call LABEL_2D68
	ret

; 5th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_3F95:
	ld a, ($D767)
	cp (ix+68)
	jr nz, LABEL_3FA3
	ld (ix+8), $FF
	jr LABEL_3FAF

LABEL_3FA3:
	ld a, (ix+25)
	add a, $01
	and $03
	add a, $4A
	ld (ix+8), a
LABEL_3FAF:
	dec (ix+41)
	ld a, (ix+42)
	and a
	jr nz, LABEL_4017
	ld a, (ix+41)
	and a
	jr z, LABEL_3FE3
	ld iy, $DA0E
	ld a, $78
	ld ($D78F), a
	ld hl, $0074
	ld ($D791), hl
	call LABEL_3D2C
	ld de, $0074
	ld a, $78
	ld b, $01
	ld c, $01
	call LABEL_2FBC
	jr nc, LABEL_3FE2
	ld (ix+9), $08
LABEL_3FE2:
	ret

LABEL_3FE3:
	call LABEL_41C3
	and $0F
	add a, $14
	ld (ix+41), a
	ld (ix+42), $01
	call LABEL_41C3
	and $1C
	ld e, a
	ld d, $00
	ld iy, $D79C
	add iy, de
	ld a, (iy+0)
	ld (ix+45), a
	ld a, (iy+1)
	ld (ix+46), a
	ld a, (iy+2)
	ld (ix+47), a
	ld a, (iy+3)
	ld (ix+48), a
LABEL_4017:
	ld a, (ix+41)
	and a
	jr z, LABEL_4033
	ld l, (ix+45)
	ld h, (ix+46)
	ld ($D78F), hl
	ld l, (ix+47)
	ld h, (ix+48)
	ld ($D791), hl
	call LABEL_3D2C
	ret

LABEL_4033:
	ld (ix+41), $30
	ld (ix+42), $00
	ret

; 9th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_403C:
	ld a, ($D765)
	and a
	ret nz
	ld (ix+8), $4D
	ld a, (ix+2)
	add a, $02
	ld (ix+2), a
	ld de, $008C
	ld a, $78
	ld b, $01
	ld c, $01
	call LABEL_2FBC
	ret nc
	ld c, $02
	call LABEL_17CE
	ld (ix+9), $09
	ret

LABEL_4064:
	ld hl, $DA0E
	ld de, $DA53
	ld a, ($DEFD)
	cp $01
	jr nz, LABEL_4078
	ld a, ($D75D)
	and a
	jr z, LABEL_4078
	ex de, hl
LABEL_4078:
	push de
	push hl
	ld a, ($D800)
	ld e, a
	call ReadInput
	ld b, a
	and $3F
	pop ix
	call LABEL_40E5
	ld c, a
	ld ($D800), a
	ld (ix+26), a
	ld a, e
	xor c
	and c
	ld ($D801), a
	ld (ix+27), a
	ld a, ($D802)
	ld e, a
	; read player 2 input
	ld a, (P2_Input)
	ld b, a
	and $3F
	pop ix
	call LABEL_40E5
	ld c, a
	ld ($D802), a
	ld (ix+26), a
	ld a, e
	and c
	xor c
	ld ($D803), a
	ld (ix+27), a
	ld a, ($DF05)
	and a
	ret z
	ld a, ($DF06)
	and a
	ret z
	cp $80
	jr nz, LABEL_40D4
	call LABEL_1D9A
	ret

ReadInput:
	or a
	push	de
	ld.lil	a, (kbdG7)		; check arrow keys
	rla				; adjust bitmask
	bit	4, a			; is the up key pressed?
	jr	z, +_			; jump if it isn't
	xor	$11			; move the flag to bit 0			
_:	ld	d, a

	ld	e, $80
	ld.lil	a, (kbdG1)
	and	kbd2nd		; check button 1
	rra
	or	d
	ld	d, a

	ld.lil	a, (kbdG2)
	and	kbdAlpha	; check button 2
	rra
	rra
	or	d
	pop	de
	ret

P2_Input:
	.db $00

LABEL_40D4:
	ld a, ($D800)
	ld c, a
	ld a, ($D802)
	or c
	and $3F
	jp nz, LABEL_1D4F
	call LABEL_1DC5
	ret

LABEL_40E5:
	push de
	push bc
	push af
	ld e, a
	ld l, (ix+24)
	ld h, $00
	ld bc, DATA_4133
	add hl, bc
	ld a, (hl)
	cpl
	and e
	ld e, a
	pop af
	and $30
	ld d, a
	ld a, (ix+22)
	and (ix+23)
	and $02
	jr z, LABEL_410B
	ld a, ($D76E)
	and $04
	jr LABEL_410F

LABEL_410B:
	bit 1, (ix+22)
LABEL_410F:
	jr nz, LABEL_411B
	ld a, e
	and $04
	jr nz, LABEL_412F
	ld a, e
	and $08
	jr nz, LABEL_412F
LABEL_411B:
	ld a, e
	and $01
	jr nz, LABEL_412F
	ld a, e
	and $02
	jr nz, LABEL_412F
	ld a, e
	and $04
	jr nz, LABEL_412F
	ld a, e
	and $08
	jr nz, LABEL_412F
LABEL_412F:
	or d
	pop bc
	pop de
	ret

; Data from 4133 to 4137 (5 bytes)
DATA_4133:
	.db $00, $01, $02, $04, $08

LABEL_4138:
	ld a, ($D800)
	ld e, a
	call ReadInput
	ld b, a
	and $3F
	ld c, a
	ld ($D800), a
	ld a, e
	xor c
	and c
	ld ($D801), a
	ld a, ($D802)
	ld e, a
	xor a
	; in a, (Port_IOPort2)
	rlc b
	rla
	rlc b
	rla
	ld b, a
	ld ($D802), a
	ld a, e
	and b
	xor b
	ld ($D803), a
	ret

LABEL_4168:
	pop hl
	ex (sp), hl
	ld a, r
	push af
	jp po, LABEL_4171
	di
LABEL_4171:
	ld a, h
	call.lil SwitchBank + romStart
	pop af
	jp po, LABEL_417A
	ei
LABEL_417A:
	ret

LABEL_417B:
	ld c, a
	ld a, ($FFFF)
	ld h, a
	ex (sp), hl
	push hl
	ld a, r
	push af
	jp po, LABEL_4189
	di
LABEL_4189:
	ld a, c
	call.lil SwitchBank + romStart
	pop af
	jp po, LABEL_4192
	ei
LABEL_4192:
	ret

LABEL_4193:
	ld a, r
	push af
	jp po, LABEL_419A
	di
LABEL_419A:
	ld a, ($FFFF)
	push af
	call LABEL_8000
	pop af
	call.lil SwitchBank + romStart
	pop af
	jp po, LABEL_41B1
	ei
LABEL_41B1:
	ret

LABEL_41B2:
	jp (hl)

LABEL_41B3:
	ld e, b
	call LABEL_41C5
	ret

; Data from 41B8 to 41C2 (11 bytes)
	.db $C5, $CD, $C3, $41, $C1, $A1, $90, $30, $FD, $80, $C9

LABEL_41C3:
	ld e, $FF
LABEL_41C5:
	ld c, e
	ld b, $08
	ld de, ($D8FF)
	ld hl, ($D901)
LABEL_41CF:
	ld a, e
	and $48
	add a, $38
	rla
	rla
	rl h
	rl l
	rl d
	rl e
	djnz LABEL_41CF
	ld ($D8FF), de
	ld ($D901), hl
	ld a, e
	ld e, c
	ld d, $00
	ld hl, $0000
	ld b, $08
LABEL_41F0:
	add hl, hl
	rlca
	jr nc, LABEL_41F5
	add hl, de
LABEL_41F5:
	djnz LABEL_41F0
	ld a, h
	ret

LABEL_41F9:
	ld a, ($D771)
	srl a
	jr nc, LABEL_4202
	xor $B8
LABEL_4202:	
	jr nz, LABEL_4207
	ld a, ($D770)
LABEL_4207:	
	ld ($D771), a
	ret

LABEL_420B:
	ret

LABEL_4211:
	ex de, hl
	ld bc, $0380
	ld hl, $0000
LABEL_4218:
	ex de, hl
	call LABEL_428C
LABEL_421C:
	ld a, e
	ld.lil (hl), a
	inc.lil hl
	ld a, d
	ld.lil (hl), a
	inc.lil hl
	dec bc
	ld a, b
	or c
	jr nz, LABEL_421C
	ret

LABEL_422C:	
	ex de, hl
	call LABEL_428C
LABEL_4230:	
	ld a, (de)
	ld.lil (hl), a
	inc.lil hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, LABEL_4230
	ret
	
LABEL_423A:	
	ld hl, $0000
	ld de, $8000
	ld bc, $4000
	xor a
	ld ($FFFC), a
	ld a, $07
	call.lil SwitchBank + romStart
	call LABEL_4251
LABEL_424F:	
	jr LABEL_424F
	
LABEL_4251:	
	call LABEL_428E
LABEL_4254:	
	ld.lil a, (hl)
	ld (de), a
	inc.lil hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, LABEL_4254
	ret

LABEL_428C:
LABEL_428E:
	res 6, h
	ld (VRAMPointer), hl
	push.lil de
	ld.lil de, SegaVRAM
	add.lil hl, de
	pop.lil de
	ret

VRAMPointer:
	.dw 0

LABEL_425E:
	push hl
	push de
	ld hl, ($D8FF)
	dec hl
	ld a, l
	sub h
	ld d, a
	dec l
	ld a, h
	add a, l
	ld e, a
	sbc hl, de
	ld ($D8FF), hl
	xor a
	sub l
	and a
	ld hl, ($D901)
	ld de, ($D8FF)
	sbc hl, de
	jr nz, LABEL_4282
	ld de, $D431
LABEL_4282:	
	ld ($D901), de
	pop de
	pop hl
	ld ($D903), a
	ret

LABEL_42E8:
	di

	ld hl, FrameCounter
	ld a, (hl)
	inc (hl)
	rra
	call c, DrawScreenPTR

	ei
	xor a
	ld ($D839), a
LABEL_42ED:
	ld a, ($D839)
	and a
	jr z, LABEL_42ED
	ld a, ($D702)
	and a
	ret z
	ld.lil a, (KbdG1)
	bit kbitDel, a
	jr nz, LABEL_4303
	bit kbitMode, a
	jp nz, LABEL_66
	ld (PausedGame), a
	ld.lil a, (KbdG6)
	bit kbitClear, a
	jp nz, $F000
	xor a
	ld ($DF03), a
	ret

LABEL_4303:
	ld a, ($DF03)
	and a
	ret nz
	call ClearTileCache

	ld.lil hl, SegaVRAM
	ld.lil de, SegaVRAM + 1
	ld bc, $4100
	ld.lil (hl), $00
	ldir.lil

	ld a, $FF
	ld ($DF03), a
	xor a
	ld ($D83A), a
	call LABEL_4320
	call LABEL_44A6

	ld sp, $DED0
	im 1
	jp LABEL_FA

LABEL_4320:
	ld hl, DATA_4329
	ld bc, $0004
	add hl, bc
	ret

; Data from 4329 to 432C (4 bytes)
DATA_4329:
	.db $9F, $BF, $DF, $FF

SetTilemapPTR:
	ld a, b
	push bc
	ld bc, ScreenMap & $FFFF
	cp $FD
	jr nz, +_
	ld b, ((SegaVRAM + $3000) & $FF00) >> 8
_:	ld ((TilemapPTR + 1) - romStart), bc
	pop bc
	ret

LABEL_4349:
	ld a, $D0
	ld.lil (SAT), a
	ret

LABEL_4360:
	xor a
LABEL_4361:
	ld l, a
LABEL_4362:
	ld a, l
	ld (de), a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, LABEL_4362
	ret

LABEL_436B:
	ld.lil de, CRAM
	exx
	ld b, $20
	ld de, $D87F

_:	push	bc
	ld	a, (de)	
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld.lil	bc, SMS_Palette+romStart
	add.lil	hl, bc
	push.lil hl
	exx
	pop.lil	hl
	ld	bc, $0002
	ldir.lil
	exx
	inc.lil	de
	pop	bc
	djnz	-_
	ret

SMS_Palette:
#include "src/MSPacMan/sms_palette.asm"

LABEL_4384:
	call LABEL_7EA1
	call LABEL_44A6
	ret
LABEL_438B:	
	ld e, $01
LABEL_438D:	
	push de
	ld b, $20
	ld ix, $D87F
LABEL_4394:	
	push de
	push bc
	ld a, (ix+32)
	call LABEL_4473
	ld (ix+0), a
	inc ix
	pop bc
	pop de
	djnz LABEL_4394
	call LABEL_43F7
	call LABEL_436B
	call LABEL_43F7
	call LABEL_43F7
	pop de
	inc e
	ld a, e
	cp $04
	jr nz, LABEL_438D
	ret

LABEL_43B9:
	ld b, $20
	ld ix, $D89F
LABEL_43BF:
	ld a, (hl)
	ld (ix+0), a
	ld (ix-32), $00
	inc hl
	inc ix
	djnz LABEL_43BF

	call ClearTileCache
	call SetTilemapTrig

	ld b, $03
LABEL_43CE:
	push bc
	ld ix, $D87F
	ld b, $20
LABEL_43D5:
	push bc
	ld e, (ix+32)
	ld a, (ix+0)
	call LABEL_4403
	ld (ix+0), a
	inc ix
	pop bc
	djnz LABEL_43D5
	call LABEL_43F7
	call LABEL_436B
	call LABEL_43F7
	call LABEL_43F7
	pop bc
	djnz LABEL_43CE
	ret

LABEL_43F7:
	call LABEL_42E8
	ld bc, $0190
LABEL_43FD:
	dec bc
	ld a, b
	or c
	jr nz, LABEL_43FD
	ret

LABEL_4403:
	ld b, a
	ld a, e
	and $03
	ld c, a
	ld a, b
	and $03
	cp c
	jr z, LABEL_4410
	add a, $01
LABEL_4410:
	res 0, b
	res 1, b
	or b
	ld b, a
	ld a, e
	and $0C
	ld c, a
	ld a, b
	and $0C
	cp c
	jr z, LABEL_4422
	add a, $04
LABEL_4422:
	res 2, b
	res 3, b
	or b
	ld b, a
	ld a, e
	and $30
	ld c, a
	ld a, b
	and $30
	cp c
	jr z, LABEL_4434
	add a, $10
LABEL_4434:
	res 4, b
	res 5, b
	or b
	ret

LABEL_443A:
	ld ix, $D87F
	ld e, a
	ld d, $00
	add ix, de
LABEL_4443:
	push bc
	ld e, (ix+32)
	ld a, (ix+0)
	call LABEL_4403
	ld (ix+0), a
	pop bc
	inc ix
	djnz LABEL_4443
	ret

LABEL_4456:
	push de
	ld ix, $D87F
	ld e, a
	ld d, $00
	add ix, de
	pop de
LABEL_4461:
	push de
	push bc
	ld a, (ix+32)
	call LABEL_4473
	ld (ix+0), a
	pop bc
	pop de
	inc ix
	djnz LABEL_4461
	ret

LABEL_4473:
	ld b, a
	and $3C
	ld c, a
	ld a, b
	and $03
	sub e
	jr nc, LABEL_447E
	xor a
LABEL_447E:
	and $03
	or c
	ld c, a
	sla e
	sla e
	and $33
	ld c, a
	ld a, b
	and $0C
	sub e
	jr nc, LABEL_4490
	xor a
LABEL_4490:
	and $0C
	or c
	ld c, a
	sla e
	sla e
	and $0F
	ld c, a
	ld a, b
	and $30
	sub e
	jr nc, LABEL_44A2
	xor a
LABEL_44A2:
	and $30
	or c
	ret

LABEL_44A6:
	ld a, r
	push af
	jp po, LABEL_44AD
	di
LABEL_44AD:
	ld.lil hl, CRAM
	ld.lil de, CRAM+1
	ld.lil bc, $0040
	ld.lil (hl), $00
	ldir.lil
	pop af
	jp po, LABEL_44C9
	ei
LABEL_44C9:
	ret

LABEL_44CA:
	ld ($D712), a
	ld ($D714), bc
	call LABEL_4CB5
	ld iy, $D718
	call LABEL_7DA4
	ret

LABEL_44DC:
	ld l, (ix+0)
	ld h, (iy+0)
	ld (iy+0), l
	ld (ix+0), h
	inc ix
	inc iy
	dec bc
	ld a, c
	or b
	jr nz, LABEL_44DC
	ret

LABEL_44F2:	
	add a, a
	ld e, a
	ld d, $00
	ld hl, DATA_44FF
	add hl, de
	ld b, (hl)
	inc hl
	ld c, (hl)
	jr LABEL_4507
	
DATA_44FF:
	.db $00, $F8, $00, $08, $F8, $00, $08, $00
	
LABEL_4507:	
	ld a, (ix+2)
	and $F8
	or $04
	add a, c
	ld l, a
	ld a, (ix+3)
	bit 7, c
	jr z, LABEL_4524
	adc a, $FF
	ld h, a
	ld a, (ix+0)
	and $F8
	or $04
	add a, b
	jr LABEL_453A
	
LABEL_4524:	
	adc a, $00
	ld h, a
	ld a, (ix+0)
	and $F8
	or $04
	add a, b
	jr LABEL_453A

LABEL_4531:
	ld a, (ix+0)
	ld l, (ix+2)
	ld h, (ix+3)
LABEL_453A:
	push af
	ld a, l
	and $F8
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	add a, $C2
	ld h, a
	pop af
	and $F8
	add a, $08
	rrca
	rrca
	add a, l
	ld l, a
	jr nc, LABEL_4552
	inc h
LABEL_4552:
	ld a, (hl)
	ret

LABEL_4554:
	ld a, (ix+2)
	and $F8
	ld h, (ix+3)
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	add a, $C2
	ld h, a
	ld a, (ix+0)
	add a, $08
	and $F8
	rrca
	rrca
	add a, l
	ld l, a
	jr nc, LABEL_4572
	inc h
LABEL_4572:
	ld a, (hl)
	ret

LABEL_4574:
	ld hl, $3800
	call LABEL_428C
	ld de, $C200
	ld c, $1C
LABEL_457F:
	call LABEL_45A3
	inc de
	inc de
	inc de
	inc de
	ld b, $1C
LABEL_4588:
	ld a, (de)
	inc de
	ld.lil (hl), a
	inc.lil hl
	ld a, (de)
	inc de
	ld.lil (hl), a
	inc.lil hl
	djnz LABEL_4588
	inc de
	inc de
	inc de
	inc de
	call LABEL_45A3
	dec c
	jr nz, LABEL_457F
	call SetTilemapTrig
	ret

SetTilemapTrig:
	ld a, 3
	ld (DrawTilemapTrig), a
	ret

LABEL_45A3:
	call LABEL_45A6
LABEL_45A6:
	ld.lil (hl), $6E
	inc.lil hl
	ld.lil (hl), $10
	inc.lil hl
	ret

LABEL_45B5:
	ld ix, $DA0E
	ld a, (ix+47)
	ld l, a
	ld h, $00
	add hl, hl
	ld de, DATA_5675
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	pop iy
	ld ix, $D7BC
	ld c, $00
LABEL_45D1:
	ld a, (iy+0)
	and $7F
	add a, $03
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld (ix+0), l
	ld (ix+1), h
	inc ix
	inc ix
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C200
	add hl, de
	push iy
	ld de, $FFC0
	add hl, de
	push hl
	pop iy
	ld a, $44
	ld (iy+0), a
	ld (iy+1), $00
	ld (iy+2), a
	ld (iy+3), $00
	ld (iy+60), a
	ld (iy+61), $00
	ld (iy+62), a
	ld (iy+63), $00
	ld de, $0080
	add iy, de
	ld a, $47
	ld (iy+0), a
	ld (iy+1), $00
	ld (iy+2), a
	ld (iy+3), $00
	ld (iy+60), a
	ld (iy+61), $00
	ld (iy+62), a
	ld (iy+63), $00
	ld de, $FFC0
	add iy, de
	call LABEL_4651
	inc c
	pop iy
	inc iy
	bit 7, (iy-1)
	jr z, LABEL_45D1
	ld a, c
	ld ($D7CC), a
	ret

LABEL_4651:
	push bc
	push iy
	push iy
	pop hl
LABEL_4657:
	push hl
	call LABEL_478A
	ld a, (hl)
	cp $6E
	pop hl
	jr nc, LABEL_4672
	push hl
	call LABEL_478F
	ld a, (hl)
	cp $6E
	pop hl
	jr nc, LABEL_4672
	ld (hl), $6F
	call LABEL_47A4
	jr LABEL_4657

LABEL_4672:
	pop hl
	call LABEL_4794
LABEL_4676:
	push hl
	call LABEL_478A
	ld a, (hl)
	cp $6E
	pop hl
	jr nc, LABEL_4691
	push hl
	call LABEL_478F
	ld a, (hl)
	cp $6E
	pop hl
	jr nc, LABEL_4691
	ld (hl), $6F
	call LABEL_4794
	jr LABEL_4676

LABEL_4691:
	pop bc
	ret

LABEL_4693:
	ld hl, $C2C0
	ld de, $0000
	ld a, ($DA39)
LABEL_469C:
	push af
	ld b, $20
LABEL_469F:
	ld a, (hl)
	cp $70
	jr z, LABEL_46A8
	cp $71
	jr nz, LABEL_46B1
LABEL_46A8:
	inc de
	ld a, ($DEFB)
	and a
	jr z, LABEL_46B1
	ld (hl), $71
LABEL_46B1:
	inc hl
	inc hl
	djnz LABEL_469F
	pop af
	dec a
	jr nz, LABEL_469C
	ld ($D76A), de
	ret

LABEL_46BE:
	ld iy, $C200
	ld ($D78E), a
	push iy
	ld bc, $0A80
	srl b
	rr c
LABEL_46CE:
	ld (iy+0), $72
	ld (iy+1), $00
	inc iy
	inc iy
	dec bc
	ld a, b
	or c
	jr nz, LABEL_46CE
	pop iy
	ld e, (ix+47)
	ld d, $00
	ld hl, DATA_5650
	add hl, de
	ld a, (hl)
	add a, $03
	ld (ix+43), a
	ld b, $00
	ld c, $02
	ld iy, $C200
	call LABEL_4193
	ld a, ($DA39)
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld ($D78C), hl
	call LABEL_472B
	call LABEL_45B5
LABEL_470D:
	ld a, ($DEFD)
	add a, a
	ld l, a
	ld h, $00
	ld de, DATA_4723
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	pop iy
	call LABEL_7D8D
	ret

; Pointer Table from 4723 to 472A (4 entries, indexed by $DEFD)
DATA_4723:
	.dw DATA_586B, DATA_586B, DATA_5986, DATA_5991

LABEL_472B:
	ld iy, $D79C
	ld bc, $0010
	ld hl, $0038
	call LABEL_4778
	ld bc, $0080
	ld hl, $0038
	call LABEL_4778
	ld bc, $00F0
	ld hl, $0038
	call LABEL_4778
	ld a, (ix+43)
	add a, $03
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $0010
	call LABEL_4778
	ld bc, $00F0
	call LABEL_4778
	srl h
	rr l
	ld bc, $0080
	call LABEL_4778
	ld bc, $0010
	call LABEL_4778
	ld bc, $00F0
	call LABEL_4778
	ret

LABEL_4778:
	ld (iy+0), c
	ld (iy+1), b
	ld (iy+2), l
	ld (iy+3), h
	ld de, $0004
	add iy, de
	ret

; 1st entry of Jump Table from 31D2 (indexed by unknown)
LABEL_478A:
	ld bc, $FFC0
	add hl, bc
	ret

; 1st entry of Jump Table from 31D4 (indexed by unknown)
LABEL_478F:
	ld bc, $0040
	add hl, bc
	ret

; 1st entry of Jump Table from 31D6 (indexed by unknown)
LABEL_4794:
	ld a, l
	and $C0
	ld c, a
	dec hl
	dec hl
	ld a, l
	and $C0
	cp c
	ret z
	ld bc, $0040
	add hl, bc
	ret

; 1st entry of Jump Table from 31D8 (indexed by unknown)
LABEL_47A4:
	ld a, l
	and $C0
	ld c, a
	inc hl
	inc hl
	ld a, l
	and $C0
	cp c
	ret z
	ld bc, $FFC0
	add hl, bc
	ret

LABEL_47B4:
	di
	ld hl, $3800
	call LABEL_4211
	ld hl, $0000
	ld a, $23
	call LABEL_76E3
	ld hl, $3800
	ld a, $22
	call LABEL_76E3
	ld hl, $2E40
	ld a, $24
	call LABEL_76E3
	ld hl, $0172
	ld de, $38C0
	ld bc, $0020
	call LABEL_4218
	ld a, $01
	ld hl, $0E60
	call LABEL_76E3
	ld iy, DATA_5B02
	call LABEL_7CEE
	call LABEL_4349
	call SetTilemapTrig
	ei
	ld hl, DATA_5C19
	call LABEL_43B9
LABEL_47F8:
	call LABEL_42E8
	call LABEL_4138
	ld a, ($D800)
	ld c, a
	ld a, ($DEFD)
	and $02
	jr nz, LABEL_4813
	ld a, ($DA52)
	and a
	jr z, LABEL_4813
	ld a, ($D802)
	ld c, a
LABEL_4813:
	ld a, c
	and $30
	jr z, LABEL_47F8
	push bc
	call LABEL_4384
	pop bc
	di
	ld a, c
	and $10
	jr nz, LABEL_4828
	ld a, c
	and $20
	jr nz, LABEL_482F
LABEL_4828:
	ld a, $20
	ld ($DA3C), a
	scf
	ret

LABEL_482F:
	xor a
	ld ($DA3C), a
	dec a
	ld ($DA4E), a
	ld a, ($DEFD)
	and $02
	jr z, LABEL_4846
	xor a
	ld ($DA81), a
	dec a
	ld ($DA93), a
LABEL_4846:
	and a
	ret

LABEL_4848:
	di
	xor a
	ld ($D755), a
	ld hl, $0000
	ld ($D800), hl
	ld ($D802), hl
	ld a, $01
	ld ($D703), a
	ld a, ($DF02)
	and a
	jr nz, LABEL_4878
	ld a, ($DF01)
	cp $07
	jr c, LABEL_486C
	xor a
	ld ($DF01), a
LABEL_486C:
	ld a, $07
	ld ($DEFC), a
	xor a
	ld ($DA3C), a
	ld ($DA81), a
LABEL_4878:
	ld a, (DATA_7D52)
	ld de, $0073
	ld l, a
	ld h, $00
	add hl, de
	ld de, $3800
	ld bc, $0380
	call LABEL_4218
	ld a, $01
	ld hl, $0E60
	call LABEL_76E3
	ld a, $02
	ld hl, $1D60
	call LABEL_76E3
	call LABEL_2258
	call LABEL_496D
	call LABEL_17D4
	ld a, ($DF02)
	and a
	jr z, LABEL_48CC
	ld ix, $DBAC
	add a, $B9
	ld (ix+5), a
	ld (ix+8), a
	ld hl, $01A0
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0090
	ld (ix+2), l
	ld (ix+3), h
	ld (ix+9), $1E
LABEL_48CC:
	call ClearTileCache
	ld iy, DATA_5912
	call LABEL_7CEE
	call LABEL_4A19
	call LABEL_4992
	ld hl, $C100
	ld (hl), $AA
	call SetTilemapTrig
	ei
	ld hl, DATA_5BF9
	call LABEL_43B9
	xor a
	ld ($D760), a
LABEL_48E9:
	push ix
	call LABEL_4985
	pop ix
	call LABEL_4992
	call LABEL_257C
	ld b, $0E
	call LABEL_2426
	call LABEL_22DA
	call LABEL_4138
	call LABEL_492A
	call LABEL_25FF
	call LABEL_42E8
	call LABEL_2472
	ld bc, $012C
	ld a, ($DF0F)
	and a
	jr z, LABEL_4919
	ld bc, $00C8
LABEL_4919:
	call LABEL_43FD
	call LABEL_436B
	ld a, ($D800)
	and $10
	jr z, LABEL_48E9
	call LABEL_4384
	ret

LABEL_492A:
	ld a, ($D717)
	add a, $40
	ld ($D717), a
	ret nc
	ld a, ($D760)
	add a, a
	jr c, LABEL_4950
	ld a, ($D760)
	ld e, a
	ld a, $08
	ld b, $08
	call LABEL_4456
	ld a, ($D760)
	inc a
	cp $04
	jr nz, LABEL_4961
	set 7, a
	jr LABEL_4961

LABEL_4950:
	ld a, $08
	ld b, $08
	call LABEL_443A
	ld a, ($D760)
	res 7, a
	dec a
	jr z, LABEL_4961
	set 7, a
LABEL_4961:
	ld ($D760), a
	ret

; Data from 4965 to 496C (8 bytes)
	.db $FD, $21, $C2, $59, $CD, $EE, $7C, $C9

LABEL_496D:
	ld ix, $DA0E
	ld (ix+2), $30
	ld (ix+3), $00
	ld (ix+0), $20
	ld (ix+1), $01
	xor a
	ld (ix+53), a
LABEL_4985:
	ld ix, $DA0E
	ld (ix+9), $01
	ld (ix+5), $82
	ret

LABEL_4992:
	ld ix, $DA0E
	ld c, (ix+53)
	ld a, ($D801)
	and $03
	jr z, LABEL_49C5
	and $02
	jr nz, LABEL_49AD
	dec c
	bit 7, c
	jr z, LABEL_49B5
	ld c, $00
	jr LABEL_49B5

LABEL_49AD:
	inc c
	ld a, c
	cp $05
	jr nz, LABEL_49B5
	ld c, $04
LABEL_49B5:
	ld a, c
	cp (ix+53)
	jr z, LABEL_49C5
	ld (ix+53), c
	ld c, $01
	ld a, $03
	call LABEL_18F9
LABEL_49C5:
	ld a, (ix+53)
	add a, a
	ld l, a
	ld h, $00
	ld de, DATA_4A0E
	add hl, de
	ld a, (hl)
	ld (ix+0), a
	ld (ix+1), $01
	inc hl
	ld a, (hl)
	ld (ix+2), a
	ld (ix+3), $00
	ld a, (ix+54)
	add a, $0B
	ld (ix+54), a
	call LABEL_4D00
	sra a
	sra a
	sra a
	sra a
	sra a
	ld c, a
	add a, (ix+0)
	ld (ix+0), a
	ld a, (ix+2)
	sub c
	ld (ix+2), a
	ld a, ($D801)
	and $20
	ret z
	call LABEL_4AA2
	ret

; Data from 4A0E to 4A17 (10 bytes)
DATA_4A0E:
	.db $48, $37, $10, $4F, $18, $67, $10, $7F, $10, $97

; 31st entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_4A18:
	ret

LABEL_4A19:
	xor a
LABEL_4A1A:
	push af
	call LABEL_4A25
	pop af
	inc a
	cp $05
	jr nz, LABEL_4A1A
	ret

LABEL_4A25:
	rst $08	; LABEL_8
; Jump Table from 4A26 to 4A2F (5 entries, indexed by unknown)
DATA_4A26:
	.dw LABEL_4A30, LABEL_4A41, LABEL_4A50, LABEL_4A61, LABEL_4A72

; 1st entry of Jump Table from 4A26 (indexed by unknown)
LABEL_4A30:
	ld a, ($DEFD)
	ld de, DATA_4A39
	jp LABEL_4A92

; Pointer Table from 4A39 to 4A40 (4 entries, indexed by $DEFD)
DATA_4A39:
	.dw DATA_59EA, DATA_59F5, DATA_5A0E, DATA_5A27

; 2nd entry of Jump Table from 4A26 (indexed by unknown)
LABEL_4A41:
	ld a, ($DEFE)
	ld de, DATA_4A4A
	jp LABEL_4A92

; Pointer Table from 4A4A to 4A4F (3 entries, indexed by $DEFE)
DATA_4A4A:
	.dw DATA_5A40, DATA_5A46, DATA_5A54

; 3rd entry of Jump Table from 4A26 (indexed by unknown)
LABEL_4A50:
	ld a, ($DEFF)
	ld de, DATA_4A59
	jp LABEL_4A92

; Pointer Table from 4A59 to 4A60 (4 entries, indexed by $DEFF)
DATA_4A59:
	.dw DATA_5A60, DATA_5A69, DATA_5A70, DATA_5A77

; 4th entry of Jump Table from 4A26 (indexed by unknown)
LABEL_4A61:
	ld a, ($DF00)
	ld de, DATA_4A6A
	jp LABEL_4A92

; Pointer Table from 4A6A to 4A71 (4 entries, indexed by $DF00)
DATA_4A6A:
	.dw DATA_5A80, DATA_5A89, DATA_5A90, DATA_5A96

; 5th entry of Jump Table from 4A26 (indexed by unknown)
LABEL_4A72:
	ld a, ($DF01)
	inc a
	ld l, a
	ld h, $00
	ld e, h
	ld d, h
	call LABEL_4C3A
	ld iy, $D718
LABEL_4A82:
	ld a, (iy+1)
	inc iy
	cp $30
	jr z, LABEL_4A82
	ld bc, $1112
	call LABEL_7C95
	ret

LABEL_4A92:
	add a, a
	ld l, a
	ld h, $00
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	pop iy
	call LABEL_7CEE
	ret

LABEL_4AA2:
	di
	ld ix, $DA0E
	ld a, (ix+53)
	cp $04
	jr z, LABEL_4AF2
	ld l, a
	ld h, $00
	push hl
	add hl, hl
	ld de, DATA_4AE6
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	pop hl
	ld bc, DATA_4AE6 + 8
	add hl, bc
	ld a, (de)
	inc a
	cp (hl)
	jr nz, LABEL_4AC4
	xor a
LABEL_4AC4:
	ld (de), a
LABEL_4AC5:
	ld b, $11
	ld a, (ix+53)
	add a, a
	add a, (ix+53)
	add a, $06
	ld c, a
	ld iy, DATA_59C2
	call LABEL_7C95
	ld a, (ix+53)
	call LABEL_4A25
	ld c, $00
	ld a, $04
	call LABEL_18F9
	ei
	ret

; Pointer Table from 4AE6 to 4AF1 (6 entries, indexed by $DA43)
DATA_4AE6:
	.dw $DEFD, $DEFE, $DEFF, $DF00
DATA_4AEE:	; 2 player stuff
	.dw $0304, $0404

LABEL_4AF2:
	ld a, ($DEFC)
	ld c, a
	ld a, ($DF01)
	inc a
	cp c
	jr nz, LABEL_4AFE
	xor a
LABEL_4AFE:
	ld ($DF01), a
	jr LABEL_4AC5

LABEL_4B03:
	ld b, $0A
LABEL_4B05:
	halt
	djnz LABEL_4B05
	ld a, ($D76E)
	ld c, a
LABEL_4B0C:
	ld a, ($D76E)
	cp c
	jr z, LABEL_4B0C
	ld hl, $0000
	ld a, ($D76E)
	ld c, a
LABEL_4B19:
	inc hl
	ld a, ($D76E)
	cp c
	jr z, LABEL_4B19
	xor a
	ld bc, $0708
	sbc hl, bc
	jr nc, LABEL_4B29
	inc a
LABEL_4B29:
	ld ($DF0F), a
	ret

LABEL_4B2D:
	ld a, $3C
	ld ($D705), a
	ld a, $32
	ld ($D706), a
	jr LABEL_4B44

LABEL_4B39:
	ret

; Data from 4B3A to 4B43 (10 bytes)
	.db $3E, $32, $32, $05, $D7, $3E, $3C, $32, $06, $D7

LABEL_4B44:
	push bc
	push de
	push ix
	push iy
	exx
	push hl
	push bc
	push de
	exx
	ex af, af'
	push af
	ex af, af'
	ld a, ($DF0F)
	and a
	jr z, LABEL_4B78
	ex de, hl
	ld bc, ($D705)
	ld b, $00
	call LABEL_4DA3
	ld ($D738), hl
	ld ($D73A), a
	ld hl, ($D706)
	ld h, $00
	ld ($D73B), hl
	xor a
	ld ($D73D), a
	call LABEL_4B9E
LABEL_4B78:
	ex af, af'
	pop af
	ex af, af'
	exx
	pop de
	pop bc
	pop hl
	exx
	pop iy
	pop ix
	pop de
	pop bc
	ret

; Data from 4B87 to 4B9D (23 bytes)
	.db $11, $00, $00, $32, $3A, $D7, $79, $32, $3D, $D7, $ED, $53, $3B, $D7, $ED, $53
	.db $38, $D7, $CD, $9E, $4B, $79, $C9

LABEL_4B9E:
	ld bc, ($D73B)
	ld a, ($D73D)
	ld d, a
	xor a
	ld h, a
	ld l, a
	exx
	ld b, $18
	ld hl, ($D738)
	ld a, ($D73A)
	ld e, a
	xor a
LABEL_4BB4:
	adc hl, hl
	rl e
	exx
	adc hl, hl
	rla
	sbc hl, bc
	sbc a, d
	jr nc, LABEL_4BC3
	add hl, bc
	adc a, d
LABEL_4BC3:
	ccf
	exx
	djnz LABEL_4BB4
	adc hl, hl
	rl e
	ld c, a
	ld a, e
	ret

; Data from 4BCE to 4BF9 (44 bytes)
	.db $78, $D5, $DD, $E1, $16, $00, $5A, $62, $6A, $06, $10, $D6, $40, $ED, $52, $30
	.db $04, $C6, $40, $ED, $5A, $3F, $CB, $13, $CB, $12, $DD, $29, $CB, $11, $17, $ED
	.db $6A, $DD, $29, $CB, $11, $17, $ED, $6A, $10, $E1, $C9, $C9

LABEL_4BFA:
	ld hl, $0000
	ld d, l
	rra
	jr nc, LABEL_4C02
	add hl, de
LABEL_4C02:
	rl e
	rl d
	rra
	jr nc, LABEL_4C0A
	add hl, de
LABEL_4C0A:
	rl e
	rl d
	rra
	jr nc, LABEL_4C12
	add hl, de
LABEL_4C12:
	rl e
	rl d
	rra
	jr nc, LABEL_4C1A
	add hl, de
LABEL_4C1A:
	rl e
	rl d
	rra
	jr nc, LABEL_4C22
	add hl, de
LABEL_4C22:
	rl e
	rl d
	rra
	jr nc, LABEL_4C2A
	add hl, de
LABEL_4C2A:
	rl e
	rl d
	rra
	jr nc, LABEL_4C32
	add hl, de
LABEL_4C32:
	rl e
	rl d
	rra
	ret nc
	add hl, de
	ret

LABEL_4C3A:
	ld iy, $D718
	ld ix, DATA_4CA1
	ld a, $0A
LABEL_4C44:
	ex af, af'
	ld a, $FF
	jr LABEL_4C4B

LABEL_4C49:
	pop bc
	pop bc
LABEL_4C4B:
	inc a
	ld c, (ix+3)
	ld b, (ix+2)
	push hl
	push de
	and a
	sbc hl, bc
	ex de, hl
	ld c, (ix+1)
	ld b, (ix+0)
	sbc hl, bc
	ex de, hl
	jr nc, LABEL_4C49
	pop de
	pop hl
	add a, $30
	ld (iy+0), a
	inc iy
	dec ix
	dec ix
	dec ix
	dec ix
	ex af, af'
	dec a
	jr nz, LABEL_4C44
	ld (iy+0), $23
	ret

; Data from 4C7D to 4CA0 (36 bytes)
	.db $00, $00, $00, $01, $00, $00, $00, $0A, $00, $00, $00, $64, $00, $00, $03, $E8
	.db $00, $00, $27, $10, $00, $01, $86, $A0, $00, $0F, $42, $40, $00, $98, $96, $80
	.db $05, $F5, $E1, $00

; Data from 4CA1 to 4CA4 (4 bytes)
DATA_4CA1:
	.db $3B, $9A, $CA, $00

LABEL_4CA5:
	ld a, (iy+1)
	cp $23
	ret z
	ld a, (iy+0)
	cp $30
	ret nz
	inc iy
	jr LABEL_4CA5

LABEL_4CB5:
	ld iy, $D718
	ld a, h
	call LABEL_4CDD
	ld a, l
	call LABEL_4CCE
	ld a, d
	call LABEL_4CCE
	ld a, e
	call LABEL_4CCE
	ld (iy+0), $23
	ret

LABEL_4CCE:
	ld c, a
	and $F0
	rra
	rra
	rra
	rra
	add a, $30
	ld (iy+0), a
	inc iy
	ld a, c
LABEL_4CDD:
	and $0F
	add a, $30
	ld (iy+0), a
	inc iy
	ret

LABEL_4CE7:
	ld ($D807), a
	ld a, e
	add a, c
	daa
	ld e, a
	ld a, d
	adc a, b
	daa
	ld d, a
	ld a, ($D807)
	adc a, l
	daa
	ld l, a
	ld a, h
	adc a, $00
	daa
	ld h, a
	ret

; Data from 4CFE to 4CFF (2 bytes)
	.db $C6, $40

LABEL_4D00:
	ld c, a
	and $3F
	bit 6, c
	jr z, LABEL_4D0B
	sub $3F
	neg
LABEL_4D0B:
	ld l, a
	ld h, $00
	ld de, DATA_4D19
	add hl, de
	ld a, (hl)
	bit 7, c
	ret z
	neg
	ret

; Data from 4D19 to 4D58 (64 bytes)
DATA_4D19:
	.db $00, $03, $06, $09, $0C, $0F, $12, $15, $18, $1B, $1E, $21, $24, $27, $2A, $2D
	.db $30, $33, $36, $39, $3B, $3E, $41, $43, $46, $49, $4B, $4E, $50, $52, $55, $57
	.db $59, $5B, $5E, $60, $62, $64, $66, $67, $69, $6B, $6C, $6E, $70, $71, $72, $74
	.db $75, $76, $77, $78, $79, $7A, $7B, $7B, $7C, $7D, $7D, $7E, $7E, $7E, $7E, $7F

LABEL_4D59:
	ld e, (ix+0)
	ld d, (ix+1)
	ld l, (iy+0)
	ld h, (iy+1)
	and a
	sbc hl, de
	jr nc, LABEL_4D71
	ld de, $0000
	ex de, hl
	and a
	sbc hl, de
LABEL_4D71:
	ex de, hl
	srl d
	rr e
	ld a, e
	call LABEL_4BFA
	push hl
	ld e, (ix+2)
	ld d, (ix+3)
	ld l, (iy+2)
	ld h, (iy+3)
	and a
	sbc hl, de
	jr nc, LABEL_4D93
	ld de, $0000
	ex de, hl
	and a
	sbc hl, de
LABEL_4D93:
	ex de, hl
	srl d
	rr e
	ld a, e
	call LABEL_4BFA
	pop de
	add hl, de
	add hl, hl
	ld l, h
	ld h, $00
	ret

LABEL_4DA3:
	xor a
	ld l, a
	ld h, a
	ex af, af'
	ld a, $10
LABEL_4DA9:
	ex af, af'
	add hl, hl
	rla
	rl c
	rl b
	jr nc, LABEL_4DB5
	add hl, de
	adc a, $00
LABEL_4DB5:
	ex af, af'
	dec a
	jr nz, LABEL_4DA9
	ex af, af'
	ret

; Data from 4DBB to 4DE5 (43 bytes)
	.db $78, $D5, $DD, $E1, $16, $00, $5A, $62, $6A, $06, $08, $D6, $40, $ED, $52, $30
	.db $04, $C6, $40, $ED, $5A, $3F, $CB, $13, $CB, $12, $DD, $29, $CB, $11, $17, $ED
	.db $6A, $DD, $29, $CB, $11, $17, $ED, $6A, $10, $E1, $C9

LABEL_4DE6:
	xor a
LABEL_4DE7:
	call LABEL_17D4
	ld sp, $DF51
LABEL_4DED:
	push af
	ld ($DF0E), a
	call LABEL_4DFC
	pop af
	inc a
	cp $03
	jr nz, LABEL_4DED
	jr LABEL_4DE6

LABEL_4DFC:
	rst $08	; LABEL_8
; Jump Table from 4DFD to 4E02 (3 entries, indexed by unknown)
DATA_4DFD:
	.dw LABEL_5152, LABEL_4E03, LABEL_1CD9

; 2nd entry of Jump Table from 4DFD (indexed by unknown)
LABEL_4E03:
	call LABEL_4E87
LABEL_4E06:
	ld a, ($D743)
	dec a
	ld ($D743), a
	call LABEL_4ED6
	call LABEL_2EC6
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
LABEL_4E1C:
	ld a, (ix+8)
	ld (ix+5), a
	add ix, de
	djnz LABEL_4E1C
	call LABEL_257C
	call LABEL_27D6
	xor a
	call LABEL_5E09
	call LABEL_22DA
	ld a, $01
	call LABEL_5E09
	call LABEL_4138
	ld a, ($D800)
	ld c, a
	ld a, ($D802)
	or c
	and $3F
	jr z, LABEL_4E55
	call LABEL_4384
	ld sp, $DED0
	xor a
	ld ($D74C), a
	jp LABEL_1FD

LABEL_4E55:
	jp LABEL_4E06

LABEL_4E58:
	ld a, ($D74C)
	cp $80
	ret nz
	ld hl, $D884
	ld de, $D885
	ld a, ($D884)
	ld c, a
	ld b, $0A
LABEL_4E6A:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	djnz LABEL_4E6A
	ld a, c
	ld ($D88D), a
	ld bc, $008C
	ld a, ($DF0F)
	and a
	jr nz, LABEL_4E80
	ld bc, $00E6
LABEL_4E80:
	call LABEL_43FD
	call LABEL_436B
	ret

LABEL_4E87:
	di
	ld hl, $3800
	ld a, $1D
	call LABEL_76E3
	ld hl, $1FE0
	ld a, $1C
	call LABEL_76E3
	ld hl, $0E60
	ld a, $1E
	call LABEL_76E3
	call LABEL_2258
	call LABEL_2282
	ld iy, DATA_5ABB
	call LABEL_7CEE
	call SetTilemapTrig
	ei
	ld hl, DATA_5C39
	call LABEL_43B9
	xor a
	ld ($D744), a
	ld ($D743), a
	ld ix, $DA98
	call LABEL_50D2
	ld iy, DATA_5AC3
	call LABEL_7CEE
	ld a, $80
	ld ($D74C), a
	ret

; 32nd entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_4ECF:
	call LABEL_5DE8
	call LABEL_32E3
	ret

LABEL_4ED6:
	ld a, ($D743)
	ld c, a
	ld a, ($D744)
	rst $08	; LABEL_8
; Jump Table from 4EDE to 4EF5 (12 entries, indexed by $D744)
DATA_4EDE:
	.dw LABEL_4EF7, LABEL_4F1B, LABEL_4F47, LABEL_4F6B, LABEL_4F90, LABEL_4FB8, LABEL_4FDD, LABEL_5001
	.dw LABEL_505A, LABEL_50B6, LABEL_50C5, LABEL_4EF6

; 12th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4EF6:
	ret

; 1st entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4EF7:
	ld a, c
	cp $A0
	ret nz
	ld ix, $DA98
	ld (ix+30), $00
	ld (ix+31), $00
	ld hl, $0300
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+23), $01
	ld (ix+24), $01
	jp LABEL_5E7B

; 2nd entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4F1B:
	ld a, c
	cp $DD
	ret nz
	ld ix, $DA98
	ld (ix+24), $04
	ld (ix+32), $00
	ld (ix+33), $00
	ld ix, $DADD
	call LABEL_50D2
	ld iy, DATA_5AA0
	call LABEL_7CEE
	ld iy, DATA_5ACC
	call LABEL_7CEE
	jp LABEL_5E7B

; 3rd entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4F47:
	ld a, c
	cp $A1
	ret nz
	ld ix, $DADD
	ld (ix+30), $00
	ld (ix+31), $00
	ld hl, $0300
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+23), $01
	ld (ix+24), $01
	jp LABEL_5E7B

; 4th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4F6B:
	ld a, c
	cp $E3
	ret nz
	ld ix, $DADD
	ld (ix+24), $04
	ld (ix+32), $00
	ld (ix+33), $00
	ld ix, $DB22
	call LABEL_50D2
	ld iy, DATA_5AD3
	call LABEL_7CEE
	jp LABEL_5E7B

; 5th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4F90:
	ld a, c
	cp $A1
	ret nz
	ld ix, $DB22
	ld (ix+24), $04
	ld (ix+30), $00
	ld (ix+31), $00
	ld hl, $0300
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+23), $01
	ld (ix+24), $01
	jp LABEL_5E7B

; 6th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4FB8:
	ld a, c
	cp $E9
	ret nz
	ld ix, $DB22
	ld (ix+24), $04
	ld (ix+32), $00
	ld (ix+33), $00
	ld ix, $DB67
	call LABEL_50D2
	ld iy, DATA_5ADB
	call LABEL_7CEE
	jp LABEL_5E7B

; 7th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_4FDD:
	ld a, c
	cp $A1
	ret nz
	ld ix, $DB67
	ld (ix+30), $00
	ld (ix+31), $00
	ld hl, $0300
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+23), $01
	ld (ix+24), $01
	jp LABEL_5E7B

; 8th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_5001:
	ld a, c
	cp $EF
	ret nz
	ld ix, $DB67
	ld (ix+24), $04
	ld (ix+32), $00
	ld (ix+33), $00
	ld ix, $DA53
	ld (ix+9), $20
	ld hl, DATA_240
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0090
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0300
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+22), $01
	ld (ix+24), $03
	ld iy, DATA_5AAC
	call LABEL_7CEE
	ld iy, DATA_5AE1
	call LABEL_7CEE
	jp LABEL_5E7B

; 9th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_505A:
	ld a, c
	cp $B8
	ret nz
	ld ix, $DA53
	ld (ix+31), $00
	ld (ix+24), $04
	ld ix, $DA0E
	ld (ix+9), $20
	ld hl, $0240
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0090
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0300
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+22), $01
	ld (ix+24), $03
	ld iy, DATA_5AAC
	call LABEL_7CEE
	ld iy, DATA_5AEA
	call LABEL_7CEE
	ld iy, DATA_5AF6
	call LABEL_7CEE
	jp LABEL_5E7B

; 10th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_50B6:
	ld a, c
	cp $C0
	ret nz
	ld ix, $DA0E
	ld (ix+31), $00
	jp LABEL_5E7B

; 11th entry of Jump Table from 4EDE (indexed by $D744)
LABEL_50C5:
	ld a, c
	cp $A0
	ret nz
	call LABEL_4384
	pop bc
	xor a
	ld ($D74C), a
	ret

LABEL_50D2:
	ld (ix+9), $1F
	ld hl, $0240
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0090
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0300
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+22), $01
	ld (ix+24), $03
	ld iy, DATA_5AAC
	call LABEL_7CEE
	ret

; 33rd entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_510A:
	call LABEL_32E3
	call LABEL_5111
	ret

LABEL_5111:
	call LABEL_2F7C
	ld a, (ix+24)
	dec a
	and $03
	ld c, a
	add a, a
	add a, c
	add a, (ix+6)
	ld c, a
	ld a, (ix+68)
	add a, a
	add a, a
	ld b, a
	add a, a
	add a, b
	add a, c
	ld (ix+8), a
	ld a, (ix+24)
	and a
	jr z, LABEL_5151
	ld a, (ix+6)
	inc a
	cp $03
	jr nz, LABEL_513C
	xor a
LABEL_513C:
	ld (ix+6), a
	ld a, (ix+30)
	or (ix+31)
	or (ix+32)
	or (ix+33)
	jr nz, LABEL_5151
	ld (ix+6), $00
LABEL_5151:
	ret

ClearTileCache:
	ld.lil hl, SegaTileFlags
	ld.lil de, SegaTileFlags+1
	ld bc, $01C0
	ld.lil (hl), $00
	ldir.lil
	ret

; 1st entry of Jump Table from 4DFD (indexed by unknown)
LABEL_5152:
	di
	call ClearTileCache
	ld hl, $3800
	call LABEL_4211
	ld a, $03
	ld hl, $0000
	call LABEL_76E3
	; call.lil SetTitleRows + romStart
	ld a, $04
	ld hl, $3800
	call LABEL_76E3
	call LABEL_4349
	call SetTilemapTrig
	ei
	ld hl, DATA_5BE8
	call LABEL_43B9
	ld hl, $00FA
	call LABEL_4B2D
LABEL_5179:
	push hl
	call LABEL_4138
	call LABEL_42E8
	pop hl
	ld a, ($D800)
	ld c, a
	ld a, ($D802)
	or c
	and $3F
	jr z, LABEL_5196
	call LABEL_4384
	ld sp, $DED0
	jp LABEL_1FD

LABEL_5196:
	dec hl
	ld a, l
	or h
	jr nz, LABEL_5179
	call LABEL_4384
	ret

.assume ADL=1
SetTitleRows:
	di
	ld hl, LeftTitleRow + romStart
	ld de, ScreenMap
	ld bc, RightTitleRow - LeftTitleRow
	ldir

	ld hl, RightTitleRow + romStart
	ld de, ScreenMap + $0030
	ld bc, LABEL_519F - RightTitleRow
	ldir
	
	ld hl, ScreenMap
	ld de, ScreenMap + $0040
	ld bc, 64*29
	ldir
	ret.sis
.assume ADL=0

LeftTitleRow:
.db $00, $00, $00, $00, $01, $00, $02, $00, $48, $00, $48, $00, $8E, $01, $00, $00
RightTitleRow:
.db $54, $00, $55, $00, $48, $00, $19, $00, $1A, $00, $1B, $00, $00, $00, $00, $00

LABEL_519F:
	di
	ld hl, $3800
	call LABEL_4211
	ld a, $20
	ld hl, $0000
	call LABEL_76E3
	ld a, $21
	ld hl, $3800
	call LABEL_76E3
	call LABEL_4349
	call SetTilemapTrig
	ei
	ld hl, DATA_5BC8
	call LABEL_43B9
	ld hl, $00FA
	call LABEL_4B2D
LABEL_51C6:
	push hl
	call LABEL_42E8
	pop hl
	dec hl
	ld a, h
	or l
	jr nz, LABEL_51C6
	call LABEL_4384
	ret

LABEL_51D4:
	ld a, ($DEFD)
	cp $01
	jr z, LABEL_51F5
	ld e, $02
	ld ix, $DA0E
	ld iy, $C200
	call LABEL_52BE
	ld e, $1C
	ld ix, $DA53
	ld iy, $CC80
	call LABEL_52BE
LABEL_51F5:
	ld iy, $C200
	ld a, ($DA3C)
	and $20
	call nz, LABEL_525F
	ld iy, $CC80
	ld a, ($DA81)
	and $20
	call nz, LABEL_525F
	ld iy, $C280
	ld c, $06
	push iy
	ld a, c
	inc a
	add a, a
	sub $20
	neg
	ld e, a
	ld d, $00
	add iy, de
	ld de, $0917
	ld (iy+0), e
	ld (iy+1), d
	inc de
	ld b, c
	sla b
LABEL_522E:
	ld (iy+2), e
	ld (iy+3), d
	inc iy
	inc iy
	djnz LABEL_522E
	inc de
	ld (iy+2), e
	ld (iy+3), d
	pop iy
	ld a, ($DEFE)
	and a
	jr z, LABEL_524E
	ld c, $08
	call LABEL_5276
LABEL_524E:
	ld a, ($DEFF)
	ld c, a
	call LABEL_5276
	ld a, ($DF00)
	add a, $04
	ld c, a
	call LABEL_5276
	ret

LABEL_525F:
	ld bc, $0080
	add iy, bc
	ld b, $20
	ld hl, $0972
LABEL_5269:
	ld (iy+0), l
	ld (iy+1), h
	inc iy
	inc iy
	djnz LABEL_5269
	ret

LABEL_5276:
	push iy
	ld a, c
	add a, a
	add a, c
	ld c, a
	ld b, $00
	ld hl, DATA_52A3
	add hl, bc
	ld a, (hl)
	inc hl
	add a, a
	ld e, a
	ld d, $00
	add iy, de
	ld e, (hl)
	inc hl
	ld b, (hl)
	ld d, $08
	ld hl, $0117
	add hl, de
LABEL_5293:
	ld (iy+0), l
	ld (iy+1), h
	inc hl
	inc iy
	inc iy
	djnz LABEL_5293
	pop iy
	ret

; Data from 52A3 to 52BD (27 bytes)
DATA_52A3:
	.db $0A, $05, $04, $0B, $03, $02, $0B, $09, $02, $0A, $0B, $03, $13, $10, $03, $14
	.db $0E, $02, $14, $17, $02, $12, $13, $04, $0F, $19, $02

LABEL_52BE:
	push iy
	push de
	ld a, $03
	call LABEL_5301
	ld a, ($DA3C)
	and $1F
	ld l, a
	inc l
	ld h, $00
	ld d, h
	ld e, h
	call LABEL_4C3A
	ld iy, $D718
	call LABEL_4CA5
	ld hl, ($D78C)
	ld de, $0008
	add hl, de
	ld ($D714), hl
	pop de
	ld a, (iy+1)
	cp $23
	jr nz, LABEL_52F3
	dec iy
	ld (iy+0), $20
LABEL_52F3:
	ld a, e
	dec a
	add a, a
	add a, a
	add a, a
	ld ($D712), a
	call LABEL_7DA4
	pop iy
	ret

LABEL_5301:
	push af
	ld a, e
	ld ($D806), a
	ld hl, ($D78C)
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $C200
	add hl, bc
	ex de, hl
	ld h, $00
	add hl, hl
	add hl, de
	push hl
	pop iy
	pop af
	add a, a
	ld l, a
	ld h, $00
	ld bc, $00EB
	add hl, bc
	push hl
	set 3, h
	ld (iy+0), l
	ld (iy+1), h
	inc hl
	ld (iy+2), l
	ld (iy+3), h
	ld bc, $0016
	add hl, bc
	dec hl
	push hl
	ld (iy+64), l
	ld (iy+65), h
	inc hl
	ld (iy+66), l
	ld (iy+67), h
	ld bc, ($D82F)
	ld hl, ($D78C)
	and a
	sbc hl, bc
	ld de, $00B8
	ex de, hl
	and a
	sbc hl, de
	jr c, LABEL_53B4
	ld hl, ($D78C)
	ld de, ($D82F)
	and a
	sbc hl, de
	ld a, l
	ld c, a
	ld a, ($D806)
	add a, a
	add a, a
	add a, a
	ld b, a
	ld ($D808), bc
	call LABEL_7C6A
	ld a, h
	add a, $38
	ld h, a
	di
	pop bc
	push hl
	push bc
	ld bc, ($D808)
	ld a, c
	add a, $08
	ld c, a
	call LABEL_7C6A
	ld a, h
	add a, $38
	ld h, a
	pop bc
	call LABEL_428C
	call LABEL_5399
	pop hl
	call LABEL_428C
	pop bc
	call LABEL_5399
	ei
	ret

LABEL_5399:
	ld.lil (hl), c
	inc.lil hl
	ld a, b
	or $08
	ld.lil (hl), a
	inc.lil hl
	inc bc
	ld.lil (hl), c
	inc.lil hl
	ld a, b
	or $08
	ld.lil (hl), a
	inc.lil hl
	ret

LABEL_53B4:
	pop af
	pop af
	ret

LABEL_53B7:
	ld a, ($D76E)
	and $04
	ld c, a
	ld a, $03
LABEL_53BF:
	push af
	add a, c
	push bc
	call LABEL_53CD
	pop bc
	pop af
	dec a
	bit 7, a
	jr z, LABEL_53BF
	ret

LABEL_53CD:
	rst $08	; LABEL_8
; Jump Table from 53CE to 53D3 (3 entries, indexed by unknown)
DATA_53CE:
	.dw LABEL_540B, LABEL_5524, LABEL_54AC

; Jump Table from 53D4 to 53DD (5 entries, indexed by $D76E)
DATA_53D4:
	.dw LABEL_54D7, LABEL_5589, LABEL_555F, LABEL_53DF, LABEL_54AC

; Data from 53DE to 53DE (1 bytes)
	.db $C9

; 4th entry of Jump Table from 53D4 (indexed by $D76E)
LABEL_53DF:
	ld a, ($DEFD)
	and $02
	ret nz
	ld a, ($DA3C)
	cp $07
	jr c, LABEL_53F0
	ld a, $06
	jr LABEL_53F3

LABEL_53F0:
	ld a, ($DBE1)
LABEL_53F3:
	inc a
	ld b, a
	and a
	jr z, LABEL_540A
	ld e, $1A
	ld a, $04
LABEL_53FC:
	push af
	push de
	push bc
	call LABEL_5301
	pop bc
	pop de
	pop af
	dec e
	dec e
	inc a
	djnz LABEL_53FC
LABEL_540A:
	ret

; 1st entry of Jump Table from 53CE (indexed by unknown)
LABEL_540B:
	ld a, ($DEFD)
	rst $08	; LABEL_8
; Jump Table from 540F to 5416 (4 entries, indexed by $DEFD)
DATA_540F:
	.dw LABEL_549C, LABEL_549C, LABEL_5417, LABEL_546B

; 3rd entry of Jump Table from 540F (indexed by $DEFD)
LABEL_5417:
	ld iy, $DA53
	ld ix, $DA0E
	ld e, (iy+58)
	ld d, (iy+59)
	ld l, (iy+56)
	ld h, (iy+57)
	ld a, e
	cp (ix+58)
	jr nz, LABEL_5449
	ld a, d
	cp (ix+59)
	jr nz, LABEL_5449
	ld a, l
	cp (ix+56)
	jr nz, LABEL_5449
	ld a, h
	cp (ix+57)
	jr nz, LABEL_5449
	ld iy, DATA_59B5
	jr LABEL_5467

LABEL_5449:
	ld iy, DATA_599B
	ld a, (ix+58)
	sub e
	daa
	ld a, (ix+59)
	sbc a, d
	daa
	ld a, (ix+56)
	sbc a, l
	daa
	ld a, (ix+57)
	sbc a, h
	daa
	jr nc, LABEL_5467
	ld iy, DATA_59A8
LABEL_5467:
	call LABEL_7D8D
	ret

; 4th entry of Jump Table from 540F (indexed by $DEFD)
LABEL_546B:
	ld ix, $DA0E
	ld iy, $DA53
	ld a, (ix+58)
	add a, (iy+58)
	daa
	ld e, a
	ld a, (ix+59)
	adc a, (iy+59)
	daa
	ld d, a
	ld a, (ix+56)
	adc a, (iy+56)
	daa
	ld l, a
	ld a, (ix+57)
	adc a, (iy+57)
	daa
	ld h, a
	ld bc, $0008
	ld a, $60
	call LABEL_44CA
	ret

; 1st entry of Jump Table from 540F (indexed by $DEFD)
LABEL_549C:
	ld hl, ($DEF7)
	ld de, ($DEF9)
	ld bc, $0008
	ld a, $60
	call LABEL_44CA
	ret

; 5th entry of Jump Table from 53D4 (indexed by $D76E)
LABEL_54AC:
	ld ix, $DA0E
	ld l, (ix+56)
	ld h, (ix+57)
	ld e, (ix+58)
	ld d, (ix+59)
	call LABEL_5507
	ld a, ($DEFD)
	cp $01
	jr nz, LABEL_54CE
	ld a, ($D75D)
	and a
	ld a, $A8
	jr nz, LABEL_54D0
LABEL_54CE:
	ld a, $10
LABEL_54D0:
	ld bc, $0008
	call LABEL_44CA
	ret

; 1st entry of Jump Table from 53D4 (indexed by $D76E)
LABEL_54D7:
	ld a, ($DEFD)
	and a
	ret z
	ld ix, $DA53
	ld l, (ix+56)
	ld h, (ix+57)
	ld e, (ix+58)
	ld d, (ix+59)
	call LABEL_5507
	ld a, ($DEFD)
	cp $01
	jr nz, LABEL_54FE
	ld a, ($D75D)
	and a
	ld a, $10
	jr nz, LABEL_5500
LABEL_54FE:
	ld a, $A8
LABEL_5500:
	ld bc, $0008
	call LABEL_44CA
	ret

LABEL_5507:
	ld bc, ($DEF9)
	ld a, c
	sub e
	daa
	ld a, b
	sbc a, d
	daa
	ld bc, ($DEF7)
	ld a, c
	sbc a, l
	daa
	ld a, b
	sbc a, h
	daa
	ret nc
	ld ($DEF7), hl
	ld ($DEF9), de
	ret

; 2nd entry of Jump Table from 53CE (indexed by unknown)
LABEL_5524:
	ld a, ($D76E)
	and $20
	jr z, LABEL_552D
	ld a, $03
LABEL_552D:
	ld b, a
	ld a, ($DEFD)
	and a
	jr z, LABEL_554F
	cp $01
	jr nz, LABEL_553E
	ld a, ($D75D)
	inc a
	and b
	ld b, a
LABEL_553E:
	ld iy, DATA_588B
	bit 1, b
	jr nz, LABEL_554A
	ld iy, DATA_587B
LABEL_554A:
	push bc
	call LABEL_7D8D
	pop bc
LABEL_554F:
	ld iy, DATA_5883
	bit 0, b
	jr nz, LABEL_555B
	ld iy, DATA_5873
LABEL_555B:
	call LABEL_7D8D
	ret

; 3rd entry of Jump Table from 53D4 (indexed by $D76E)
LABEL_555F:
	ld a, ($DEFD)
	and $02
	ret z
	ld ix, $DA53
	ld c, $00
	bit 7, (ix+64)
	jr nz, LABEL_557D
	ld a, (ix+60)
	cp (ix+64)
	jr nc, LABEL_557D
	ld c, (ix+68)
	inc c
LABEL_557D:
	add a, a
	neg
	add a, $1A
	ld e, a
	ld a, c
	call LABEL_5301
	jr LABEL_55A9

; 2nd entry of Jump Table from 53D4 (indexed by $D76E)
LABEL_5589:
	ld ix, $DA0E
	ld c, $00
	bit 7, (ix+64)
	jr nz, LABEL_55A1
	ld a, (ix+60)
	cp (ix+64)
	jr nc, LABEL_55A1
	ld c, (ix+68)
	inc c
LABEL_55A1:
	add a, a
	add a, $04
	ld e, a
	ld a, c
	call LABEL_5301
LABEL_55A9:
	ld a, (ix+60)
	inc a
	cp $05
	jr nz, LABEL_55B2
	xor a
LABEL_55B2:
	ld (ix+60), a
	ret

LABEL_55B6:
	push af
	push hl
	ld e, h
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ex de, hl
	ld h, $00
	add hl, hl
	add hl, de
	ld de, $C200
	add hl, de
	push hl
	pop iy
	pop hl
	ld b, h
	sla b
	sla b
	sla b
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, ($D82F)
	and a
	sbc hl, de
	ld c, l
	ld a, r
	push af
	ex af, af'
	pop af
	jp po, LABEL_55EB
	di
LABEL_55EB:
	call LABEL_7C6A
	ld a, h
	or $38
	ld h, a
	call LABEL_428C
	pop af
	push.lil hl
	ld hl, DATA_5622
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, (hl)
	inc hl
	ld b, (hl)
	ld d, $00
	ld hl, $1932
	add hl, de
	pop.lil de
LABEL_5608:
	ld a, l
	ld.lil (de), a
	inc.lil de
	ld a, h
	ld.lil (de), a
	inc.lil de
	inc hl
	djnz LABEL_5608
	push iy
	pop de
	ex af, af'
	jp po, LABEL_5621
	ei
LABEL_5621:
	ret

; Data from 5622 to 562D (12 bytes)
DATA_5622:
	.db $00, $06, $06, $09, $0F, $08, $17, $08, $1F, $08, $27, $06

LABEL_562E:
	ld a, r
	push af
	jp po, LABEL_5635
	di
LABEL_5635:
	call LABEL_428C
	ex.lil de, hl
	ld.lil bc, romStart
	add.lil hl, bc
	ld bc, $10
	ldir.lil
	pop af
	jp po, LABEL_564F
	ei
LABEL_564F:
	ret

; Data from 5650 to 5674 (37 bytes)
DATA_5650:
	.db $1F, $1F, $1F, $1F, $19, $19, $19, $19, $25, $25, $25, $25, $25, $25, $25, $25
	.fill 10, $1F
	.db $1E, $1F, $25, $25, $19, $19, $1F, $1F, $1F, $25, $1F

; Pointer Table from 5675 to 56B6 (33 entries, indexed by $DA3D)
DATA_5675:
	.dw DATA_56B7, DATA_56BD, DATA_56BF, DATA_56C0, DATA_56C2, DATA_56BD, DATA_56BF, DATA_56C0
	.dw DATA_56B9, DATA_56C4, DATA_56BF, DATA_56C0, DATA_56C6, DATA_56BD, DATA_56C8, DATA_56E2
	.dw DATA_56CA, DATA_56CB, DATA_56CC, DATA_56CE, DATA_56D0, DATA_56D1, DATA_56B7, DATA_56D3
	.dw DATA_56D6, DATA_56D8, DATA_56DB, DATA_56DC, DATA_56DF, DATA_56E1, DATA_56BF, DATA_56C0
	.dw DATA_56CB

; 1st entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56B7 to 56B8 (2 bytes)
DATA_56B7:
	.db $11, $88

; 9th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56B9 to 56BC (4 bytes)
DATA_56B9:
	.db $08, $11, $1D, $A3

; 2nd entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56BD to 56BE (2 bytes)
DATA_56BD:
	.db $01, $97

; 3rd entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56BF to 56BF (1 bytes)
DATA_56BF:
	.db $89

; 4th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56C0 to 56C1 (2 bytes)
DATA_56C0:
	.db $0D, $90

; 5th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56C2 to 56C3 (2 bytes)
DATA_56C2:
	.db $08, $91

; 10th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56C4 to 56C5 (2 bytes)
DATA_56C4:
	.db $0E, $97

; 13th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56C6 to 56C7 (2 bytes)
DATA_56C6:
	.db $04, $9E

; 15th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56C8 to 56C9 (2 bytes)
DATA_56C8:
	.db $09, $94

; 17th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56CA to 56CA (1 bytes)
DATA_56CA:
	.db $91

; 18th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56CB to 56CB (1 bytes)
DATA_56CB:
	.db $97

; 19th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56CC to 56CD (2 bytes)
DATA_56CC:
	.db $01, $9D

; 20th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56CE to 56CF (2 bytes)
DATA_56CE:
	.db $0B, $8F

; 21st entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56D0 to 56D0 (1 bytes)
DATA_56D0:
	.db $90

; 22nd entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56D1 to 56D2 (2 bytes)
DATA_56D1:
	.db $0B, $9D

; 24th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56D3 to 56D5 (3 bytes)
DATA_56D3:
	.db $08, $11, $94

; 25th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56D6 to 56D7 (2 bytes)
DATA_56D6:
	.db $0A, $8D

; 26th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56D8 to 56DA (3 bytes)
DATA_56D8:
	.db $01, $0D, $97

; 27th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56DB to 56DB (1 bytes)
DATA_56DB:
	.db $81

; 28th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56DC to 56DE (3 bytes)
DATA_56DC:
	.db $01, $09, $97

; 29th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56DF to 56E0 (2 bytes)
DATA_56DF:
	.db $01, $9D

; 30th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56E1 to 56E1 (1 bytes)
DATA_56E1:
	.db $8E

; 16th entry of Pointer Table from 5675 (indexed by $DA3D)
; Data from 56E2 to 5728 (71 bytes)
DATA_56E2:
	.db $0D, $10, $A3, $AF, $32, $07, $D7, $32, $08, $D7, $21, $00, $38, $CD, $11, $42
	.db $21, $00, $38, $CD, $8C, $42, $11, $00, $00, $01, $00, $02, $7B, $D3, $BE, $DD
	.db $7E, $00, $7A, $CB, $DF, $D3, $BE, $1C, $0B, $78, $B1, $20, $EF, $18, $FE, $CD
	.db $8C, $42, $C5, $0E, $08, $06, $04, $DD, $7E, $00, $1A, $D3, $BE, $10, $F8, $13
	.db $0D, $20, $F2, $C1, $10, $EC, $C9

; 1st entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_5729:
	call LABEL_5749
	jr LABEL_5729

; Data from 572E to 5748 (27 bytes)
	.db $CD, $49, $57, $3A, $24, $D8, $ED, $44, $E6, $1F, $CD, $42, $57, $18, $F1, $3E
	.db $30, $18, $01, $AF, $0E, $00, $47, $CD, $D6, $42, $C9

LABEL_5749:
	ld a, ($D824)
	inc a
	and $0F
	ld ($D824), a
	ret

; Data from 5756 to 586A (277 bytes)
	.db $3A, $24, $D8, $3D, $E6, $0F, $32, $24, $D8, $CD, $0B, $42, $C9, $F5, $CD, $4B
	.db $7C, $7C, $F6, $38, $67, $CD, $8C, $42, $F1, $F5, $CD, $B4, $57, $F1, $CD, $B8
	.db $57, $C9, $D5, $CD, $4B, $7C, $7C, $F6, $38, $67, $CD, $8C, $42, $D1, $7A, $CD
	.db $B4, $57, $7A, $CD, $B8, $57, $7B, $CD, $B4, $57, $7B, $CD, $B8, $57, $C9, $D5
	.db $CD, $4B, $7C, $7C, $F6, $38, $67, $CD, $8C, $42, $D1, $06, $08, $C5, $D5, $7B
	.db $87, $8F, $E6, $01, $CD, $B8, $57, $D1, $CB, $13, $C1, $10, $F0, $C9, $1F, $1F
	.db $1F, $1F, $E6, $0F, $C6, $73, $D3, $BE, $DD, $7E, $00, $3E, $10, $D3, $BE, $C9
	.db $F5, $FD, $E5, $FD, $22, $15, $D8, $DD, $E5, $DD, $22, $13, $D8, $E5, $22, $11
	.db $D8, $C5, $ED, $43, $0D, $D8, $D5, $ED, $53, $0F, $D8, $F5, $D1, $06, $04, $0E
	.db $00, $CD, $78, $57, $06, $04, $0E, $01, $ED, $5B, $0D, $D8, $CD, $78, $57, $06
	.db $04, $0E, $02, $ED, $5B, $0F, $D8, $CD, $78, $57, $06, $04, $0E, $03, $ED, $5B
	.db $11, $D8, $CD, $78, $57, $06, $04, $0E, $04, $ED, $5B, $13, $D8, $CD, $78, $57
	.db $06, $04, $0E, $05, $ED, $5B, $15, $D8, $CD, $78, $57, $D9, $08, $F5, $C5, $ED
	.db $43, $0D, $D8, $D5, $ED, $53, $0F, $D8, $E5, $22, $11, $D8, $06, $0A, $0E, $00
	.db $F5, $D1, $CD, $78, $57, $06, $0A, $0E, $01, $ED, $5B, $0D, $D8, $CD, $78, $57
	.db $06, $0A, $0E, $02, $ED, $5B, $0F, $D8, $CD, $78, $57, $06, $0A, $0E, $03, $ED
	.db $5B, $11, $D8, $CD, $78, $57, $E1, $D1, $C1, $F1, $08, $D9, $D1, $C1, $E1, $DD
	.db $E1, $FD, $E1, $F1, $C9

; 1st entry of Pointer Table from 4723 (indexed by $DEFD)
; Data from 586B to 5872 (8 bytes)
DATA_586B:
	.db $70, $00, $00, $00, $48, $49, $21, $23

; Data from 5873 to 587A (8 bytes)
DATA_5873:
	.db $20, $00, $00, $00, $31, $55, $50, $23

; Data from 587B to 5882 (8 bytes)
DATA_587B:
	.db $B8, $00, $00, $00, $32, $55, $50, $23

; Data from 5883 to 588A (8 bytes)
DATA_5883:
	.db $20, $00, $00, $00, $20, $20, $20, $23

; Data from 588B to 5911 (135 bytes)
DATA_588B:
	.db $B8, $00, $00, $00, $20, $20, $20, $23, $08, $01, $5E, $00, $54, $45, $4E, $47
	.db $45, $4E, $20, $50, $52, $45, $53, $45, $4E, $54, $53, $40, $0B, $03, $5E, $FF
	.db $4D, $53, $20, $50, $41, $43, $4D, $41, $4E, $40, $04, $09, $4D, $53, $20, $50
	.db $41, $43, $4D, $41, $4E, $20, $54, $4D, $2E, $20, $4E, $41, $4D, $43, $4F, $20
	.db $4C, $54, $44, $2E, $40, $08, $0C, $43, $4F, $50, $59, $52, $49, $47, $48, $54
	.db $20, $20, $31, $39, $39, $31, $40, $06, $0F, $54, $45, $4E, $47, $45, $4E, $20
	.db $49, $4E, $43, $4F, $52, $50, $4F, $52, $41, $54, $45, $44, $2E, $40, $06, $16
	.db $41, $4C, $4C, $20, $52, $49, $47, $48, $54, $53, $20, $52, $45, $53, $45, $52
	.db $56, $45, $44, $2E, $5E, $00, $23

; Data from 5912 to 5985 (116 bytes)
DATA_5912:
	.db $08, $01, $5E, $FF, $4D, $53, $20, $50, $41, $43, $4D, $41, $4E, $20, $4F, $50
	.db $54, $49, $4F, $4E, $53, $40, $0B, $06, $5E, $00, $54, $59, $50, $45, $3A, $40
	.db $04, $09, $50, $41, $43, $20, $42, $4F, $4F, $53, $54, $45, $52, $3A, $40, $05
	.db $0C, $44, $49, $46, $46, $49, $43, $55, $4C, $54, $59, $3A, $40, $04, $0F, $4D
	.db $41, $5A, $45, $20, $53, $45, $4C, $45, $43, $54, $3A, $40, $04, $12, $53, $54
	.db $41, $52, $54, $20, $4C, $45, $56, $45, $4C, $3A, $2A, $78, $40, $08, $17, $46
	.db $49, $52, $45, $20, $4F, $4E, $45, $20, $54, $4F, $20, $53, $54, $41, $52, $54
	.db $2E, $2A, $00, $23

; 3rd entry of Pointer Table from 4723 (indexed by $DEFD)
; Data from 5986 to 5990 (11 bytes)
DATA_5986:
	.db $60, $00, $00, $00, $4C, $45, $41, $44, $45, $52, $23

; 4th entry of Pointer Table from 4723 (indexed by $DEFD)
; Data from 5991 to 599A (10 bytes)
DATA_5991:
	.db $68, $00, $00, $00, $54, $4F, $54, $41, $4C, $23

; Data from 599B to 59A7 (13 bytes)
DATA_599B:
	.db $58, $00, $08, $00, $50, $4C, $41, $59, $45, $52, $20, $31, $23

; Data from 59A8 to 59B4 (13 bytes)
DATA_59A8:
	.db $58, $00, $08, $00, $50, $4C, $41, $59, $45, $52, $20, $32, $23

; Data from 59B5 to 59C1 (13 bytes)
DATA_59B5:
	.db $58, $00, $08, $00, $20, $4E, $4F, $20, $4F, $4E, $45, $20, $23

; Data from 59C2 to 59E9 (40 bytes)
DATA_59C2:
	.fill 18, $20
	.db $25, $00, $01
	.fill 18, $20
	.db $23

; 1st entry of Pointer Table from 4A39 (indexed by $DEFD)
; Data from 59EA to 59F4 (11 bytes)
DATA_59EA:
	.db $11, $06, $31, $20, $50, $4C, $41, $59, $45, $52, $23

; 2nd entry of Pointer Table from 4A39 (indexed by $DEFD)
; Data from 59F5 to 5A0D (25 bytes)
DATA_59F5:
	.db $11, $06, $32, $20, $50, $4C, $41, $59, $45, $52, $40, $13, $07, $41, $4C, $54
	.db $45, $52, $4E, $41, $54, $49, $4E, $47, $23

; 3rd entry of Pointer Table from 4A39 (indexed by $DEFD)
; Data from 5A0E to 5A26 (25 bytes)
DATA_5A0E:
	.db $11, $06, $32, $20, $50, $4C, $41, $59, $45, $52, $40, $13, $07, $43, $4F, $4D
	.db $50, $45, $54, $49, $54, $49, $56, $45, $23

; 4th entry of Pointer Table from 4A39 (indexed by $DEFD)
; Data from 5A27 to 5A3F (25 bytes)
DATA_5A27:
	.db $11, $06, $32, $20, $50, $4C, $41, $59, $45, $52, $40, $13, $07, $43, $4F, $4F
	.db $50, $45, $52, $41, $54, $49, $56, $45, $23

; 1st entry of Pointer Table from 4A4A (indexed by $DEFE)
; Data from 5A40 to 5A45 (6 bytes)
DATA_5A40:
	.db $11, $09, $4F, $46, $46, $23

; 2nd entry of Pointer Table from 4A4A (indexed by $DEFE)
; Data from 5A46 to 5A53 (14 bytes)
DATA_5A46:
	.db $11, $09, $46, $49, $52, $45, $20, $31, $20, $4F, $52, $20, $32, $23

; 3rd entry of Pointer Table from 4A4A (indexed by $DEFE)
; Data from 5A54 to 5A5F (12 bytes)
DATA_5A54:
	.db $11, $09, $41, $4C, $57, $41, $59, $53, $20, $4F, $4E, $23

; 1st entry of Pointer Table from 4A59 (indexed by $DEFF)
; Data from 5A60 to 5A68 (9 bytes)
DATA_5A60:
	.db $11, $0C, $4E, $4F, $52, $4D, $41, $4C, $23

; 2nd entry of Pointer Table from 4A59 (indexed by $DEFF)
; Data from 5A69 to 5A6F (7 bytes)
DATA_5A69:
	.db $11, $0C, $45, $41, $53, $59, $23

; 3rd entry of Pointer Table from 4A59 (indexed by $DEFF)
; Data from 5A70 to 5A76 (7 bytes)
DATA_5A70:
	.db $11, $0C, $48, $41, $52, $44, $23

; 4th entry of Pointer Table from 4A59 (indexed by $DEFF)
; Data from 5A77 to 5A7F (9 bytes)
DATA_5A77:
	.db $11, $0C, $43, $52, $41, $5A, $59, $21, $23

; 1st entry of Pointer Table from 4A6A (indexed by $DF00)
; Data from 5A80 to 5A88 (9 bytes)
DATA_5A80:
	.db $11, $0F, $41, $52, $43, $41, $44, $45, $23

; 2nd entry of Pointer Table from 4A6A (indexed by $DF00)
; Data from 5A89 to 5A8F (7 bytes)
DATA_5A89:
	.db $11, $0F, $4D, $49, $4E, $49, $23

; 3rd entry of Pointer Table from 4A6A (indexed by $DF00)
; Data from 5A90 to 5A95 (6 bytes)
DATA_5A90:
	.db $11, $0F, $42, $49, $47, $23

; 4th entry of Pointer Table from 4A6A (indexed by $DF00)
; Data from 5A96 to 5A9F (10 bytes)
DATA_5A96:
	.db $11, $0F, $53, $54, $52, $41, $4E, $47, $45, $23

; Data from 5AA0 to 5AAB (12 bytes)
DATA_5AA0:
	.db $0A, $05
	.fill 9, $20
	.db $23

; Data from 5AAC to 5ABA (15 bytes)
DATA_5AAC:
	.db $0B, $08
	.fill 12, $20
	.db $23

; Data from 5ABB to 5AC2 (8 bytes)
DATA_5ABB:
	.db $0A, $05, $57, $49, $54, $48, $3A, $23

; Data from 5AC3 to 5ACB (9 bytes)
DATA_5AC3:
	.db $0D, $08, $42, $4C, $49, $4E, $4B, $59, $23

; Data from 5ACC to 5AD2 (7 bytes)
DATA_5ACC:
	.db $0E, $08, $49, $4E, $4B, $59, $23

; Data from 5AD3 to 5ADA (8 bytes)
DATA_5AD3:
	.db $0D, $08, $50, $49, $4E, $4B, $59, $23

; Data from 5ADB to 5AE0 (6 bytes)
DATA_5ADB:
	.db $0E, $08, $53, $55, $45, $23

; Data from 5AE1 to 5AE9 (9 bytes)
DATA_5AE1:
	.db $0D, $08, $50, $41, $43, $4D, $41, $4E, $23

; Data from 5AEA to 5AF5 (12 bytes)
DATA_5AEA:
	.db $0A, $05, $53, $54, $41, $52, $52, $49, $4E, $47, $3A, $23

; Data from 5AF6 to 5B01 (12 bytes)
DATA_5AF6:
	.db $0C, $08, $4D, $53, $20, $50, $41, $43, $4D, $41, $4E, $23

; Data from 5B02 to 5B87 (134 bytes)
DATA_5B02:
	.db $01, $06, $57, $4F, $57, $21, $20, $59, $4F, $55, $20, $43, $4F, $4D, $50, $4C
	.db $45, $54, $45, $44, $20, $4D, $53, $20, $50, $41, $43, $4D, $41, $4E, $2E, $40
	.db $01, $08, $47, $45, $45, $20, $59, $41, $20, $4F, $4E, $45, $20, $53, $57, $45
	.db $4C, $4C, $20, $50, $4C, $41, $59, $45, $52, $21, $40, $01, $0D, $46, $49, $52
	.db $45, $20, $31, $40, $05, $0E, $54, $4F, $20, $48, $41, $56, $45, $20, $41, $4E
	.db $4F, $54, $48, $45, $52, $20, $47, $41, $4D, $45, $20, $4F, $4E, $20, $4D, $45
	.db $21, $40, $01, $10, $46, $49, $52, $45, $20, $32, $40, $05, $11, $54, $4F, $20
	.db $43, $41, $4C, $4C, $20, $49, $54, $20, $41, $20, $44, $41, $59, $21, $20, $50
	.db $48, $45, $57, $57, $21, $23

; Data from 5B88 to 5BA7 (32 bytes)
DATA_5B88:
	.db $00, $3F, $02, $17, $2B, $06, $0B, $1F, $08, $0C, $2E, $20, $30, $39, $33, $00
	.db $00, $0F, $02, $35, $33, $17, $3F, $0B, $24, $1D, $08, $2B, $2A, $39, $3B, $01

; Data from 5BA8 to 5BC7 (32 bytes)
DATA_5BA8:
	.db $00, $0F, $02, $35, $33, $17, $3F, $0B, $24, $1D, $08, $2B, $2A, $39, $2F, $30
	.db $00, $0F, $02, $35, $33, $17, $3F, $0B, $24, $1D, $08, $2B, $2A, $39, $3B, $01

; Data from 5BC8 to 5BE7 (32 bytes)
DATA_5BC8:
	.db $00, $01, $02, $03, $07, $0B, $0F, $2F, $3F, $2A, $30, $04, $09, $23, $39, $06
	.fill 16, $00

; Data from 5BE8 to 5BF8 (17 bytes)
DATA_5BE8:
	.db $00, $01, $02, $03, $07, $0B, $0F, $2F, $3F, $2A, $30, $04, $09, $23, $39, $06
	.db $00

; Data from 5BF9 to 5C18 (32 bytes)
DATA_5BF9:
	.db $00, $3F, $06, $0B, $1F, $06, $0B, $1F, $00, $3F, $06, $0B, $1F, $06, $0B, $1F
	.db $00, $3F, $01, $06, $1B, $2B, $3F, $15, $00, $03, $03, $03, $03, $03, $03, $03

; Data from 5C19 to 5C28 (16 bytes)
DATA_5C19:
	.db $00, $3F, $06, $0B, $1F, $06, $0B, $1F, $23, $1F, $2E, $20, $30, $36, $3B, $3F

; Data from 5C29 to 5C38 (16 bytes)
DATA_5C29:
	.db $00, $0F, $02, $35, $33, $17, $3F, $0B, $24, $1D, $08, $2B, $2A, $39, $2F, $30

; Data from 5C39 to 5C58 (32 bytes)
DATA_5C39:
	.db $00, $3F, $06, $0B, $1F, $03, $07, $0F, $0E, $0C, $2C, $3C, $3C, $34, $30, $3F
	.db $00, $0F, $02, $35, $33, $17, $3F, $0B, $24, $1D, $08, $2B, $2A, $39, $3B, $01

; Data from 5C59 to 5C7C (36 bytes)
DATA_5C59:
	.db $00, $01, $02, $03, $00, $01, $02, $03, $04, $05, $06, $07, $04, $05, $06, $07
	.db $08, $00, $01, $02, $09, $00, $01, $02, $07, $00, $01, $02, $06, $00, $01, $0A
	.db $0B, $0C, $0D, $0E

; Data from 5C7D to 5CA9 (45 bytes)
DATA_5C7D:
	.db $04, $08, $1D, $01, $02, $17, $11, $22, $37, $05, $0A, $1F, $14, $28, $3D, $20
	.db $30, $35, $05, $06, $1B, $06, $0B, $1F, $11, $12, $17, $04, $18, $3C, $30, $36
	.db $3B, $15, $2A, $3F, $11, $0A, $1F, $00, $00, $10, $00, $00, $00

LABEL_5CAA:
	ld ($D741), a
	ld a, ($DA52)
	ld ($D745), a
	ld a, ($DA97)
	ld ($D746), a
	ld ($D709), sp
	xor a
	ld ($D742), a
	ld ($D755), a
	di
	ld hl, $3000
	call LABEL_4211
	ld hl, $3800
	call LABEL_4211
	ld a, $08
	ld hl, $0000
	call LABEL_76E3
	ld a, ($D741)
	add a, a
	add a, a
	add a, $09
	ld hl, $3000
	call LABEL_76E3
	call LABEL_4349
	call SetTilemapTrig
	ei
	call LABEL_42E8
	ld a, $FF
	ld ($D740), a
	xor 2
	ld b, a
	call SetTilemapPTR
	ld hl, DATA_5C29
	call LABEL_43B9
	ld b, $78
LABEL_5D05:
	push bc
	call LABEL_42E8
	call LABEL_5E3C
	pop bc
	djnz LABEL_5D05
LABEL_5D0F:
	ld a, ($D741)
	add a, a
	add a, a
	add a, $09
	ld c, a
	ld a, ($D742)
	add a, c
	ld hl, $C200
	call LABEL_791B
	ld a, ($D740)
	and $02
	xor $02
	add a, a
	add a, a
	or $30
	inc hl
	ld h, a
	ld l, $00
	ld bc, $0600
	call SetTilemapTrig
	ld.lil de, romStart + $C200
LABEL_5D35:
	di
	call LABEL_428C
	ex.lil de, hl
	ldir.lil
	ei
	call LABEL_42E8
	call LABEL_5E3C
	ld a, ($D740)
	xor $02
	ld ($D740), a
	ld b, a
	ld c, $02
	call SetTilemapPTR
	ld a, ($D742)
	inc a
	and $03
	ld ($D742), a
	jr nz, LABEL_5D0F
	ld a, $0D
	call LABEL_18F9
	ld a, ($D741)
	add a, $02
	ld c, $03
	call LABEL_1950
	ld b, $3C
LABEL_5D77:
	push bc
	call SetTilemapTrig
	call LABEL_42E8
	call LABEL_5E3C
	pop bc
	djnz LABEL_5D77
	call LABEL_4384
	ld b, $FD
	ld c, $02
	call SetTilemapPTR
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
	xor a
LABEL_5D95:
	ld (ix+68), a
	inc a
	add ix, de
	djnz LABEL_5D95
	call LABEL_5DAD
	ld a, ($D745)
	ld ($DA52), a
	ld a, ($D746)
	ld ($DA97), a
	ret

ToggleSpriteBG:
	ld hl, (TransPixelIndex + 1) - romStart
	ld a, $40
	xor (hl)
	ld (hl), a
	ret

LABEL_5DAD:
	ld a, ($D741)
	rst $08	; LABEL_8
; Jump Table from 5DB1 to 5DB8 (4 entries, indexed by $D741)
DATA_5DB1:
	.dw LABEL_5EB0, LABEL_6283, LABEL_643E, LABEL_6654

LABEL_5DB9:
	call LABEL_2F7C
	ld a, (ix+24)
	dec a
	and $03
	ld c, a
	add a, a
	add a, c
	add a, (ix+6)
	ld c, a
	ld a, (ix+68)
	add a, a
	add a, a
	ld b, a
	add a, a
	add a, b
	add a, c
	ld (ix+8), a
	ld a, (ix+24)
	and a
	jr z, LABEL_5DE7
	ld a, (ix+6)
	inc a
	cp $03
	jr c, LABEL_5DE4
	xor a
LABEL_5DE4:
	ld (ix+6), a
LABEL_5DE7:
	ret

LABEL_5DE8:
	ld a, (ix+68)
	sub $02
	add a, a
	ld c, a
	ld a, (ix+24)
	dec a
	and $03
	add a, a
	add a, a
	add a, a
	add a, $26
	add a, c
	ld c, a
	ld a, ($D76E)
	rra
	rra
	rra
	and $01
	add a, c
	ld (ix+8), a
	ret

LABEL_5E09:
	ld ($D80C), a
	and $01
	add a, a
	ld l, a
	ld h, $00
	ld de, DATA_282C
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld ($D855), hl
	call LABEL_28B8
	call LABEL_2634
	call LABEL_42E8
	call LABEL_2472
	call LABEL_4E58
	ld a, ($D80C)
	and $01
	ret nz
	ld b, $0A
	call LABEL_239F
	ld b, $16
	call LABEL_242C
LABEL_5E3C:
	ld a, ($D74C)
	cp $80
	ret z
	ld a, ($D741)
	cp $03
	ret z
	call LABEL_4138
	ld a, ($D800)
	ld c, a
	ld a, ($D802)
	or c
	and $3F
	jr z, LABEL_5E7A
	ld sp, ($D709)
	call LABEL_19AE
	call LABEL_19E0
	call LABEL_42E8
	call LABEL_44A6
	ld b, $FF
	ld c, $02
	call SetTilemapPTR
	ld a, ($D745)
	ld ($DA52), a
	ld a, ($D746)
	ld ($DA97), a
LABEL_5E7A:
	ret

LABEL_5E7B:
	ld a, ($D744)
	inc a
	ld ($D744), a
	xor a
	ld ($D743), a
	ret

LABEL_5E87:
	ld a, $19
	ld hl, $1000
	di
	call LABEL_76E3
	ei
	ld.lil hl, SegaVRAM+$3800
	ld bc, $0300
	ld de, $0080
LABEL_5E9A:
	di
	ld.lil (hl), e
	inc.lil hl
	ld.lil (hl), d
	inc.lil hl
	ei
	dec bc
	ld a, b
	or c
	jr nz, LABEL_5E9A
	ret

; 1st entry of Jump Table from 5DB1 (indexed by $D741)
LABEL_5EB0:
	call LABEL_5F3F
LABEL_5EB3:
	ld a, ($D743)
	dec a
	ld ($D743), a
	cp $4B
	call z, LABEL_60B0
	ld a, ($D744)
	cp $04
	jr nz, LABEL_5F01
	ld a, ($D743)
	cp $12
	jr nz, LABEL_5F01
	ld hl, $0080
	ld iy, $DA98
	set 0, (iy+22)
	ld (iy+30), l
	ld (iy+31), h
	ld iy, $DADD
	res 0, (iy+22)
	ld (iy+30), l
	ld (iy+31), h
	ld c, $02
	ld a, $13
	call LABEL_18F9
	ld a, ($D744)
	inc a
	ld ($D744), a
	ld b, $FF
	ld c, $02
	call SetTilemapPTR
	call SetTilemapTrig
LABEL_5F01:
	call LABEL_2EC6
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
LABEL_5F0D:
	ld a, (ix+8)
	ld (ix+5), a
	add ix, de
	djnz LABEL_5F0D
	call LABEL_257C
	call LABEL_27D6
	xor a
	call LABEL_5E09
	call LABEL_22DA
	ld a, $01
	call LABEL_5E09
	ld a, ($D744)
	cp $06
	jr nz, LABEL_5F3C
	ld a, ($D743)
	cp $A0
	jr nz, LABEL_5F3C
	call LABEL_4384
	ret

LABEL_5F3C:
	jp LABEL_5EB3

LABEL_5F3F:
	ld b, $FD
	ld c, $02
	call SetTilemapPTR
	ld a, $1B
	ld hl, $C200
	call LABEL_791B
	ld b, $18
	ld hl, $3800
	ld ix, $C200
LABEL_5F57:
	di
	call LABEL_428C
	ld c, $20
LABEL_5F5D:
	ld a, (ix+0)
	ld.lil (hl), a
	inc.lil hl
	ld a, (ix+1)
	ld.lil (hl), a
	inc.lil hl
	lea ix, ix+2
	dec c
	jr nz, LABEL_5F5D
	ei
	ld hl, (VRAMPointer)
	ld de, $0040
	add hl, de
	djnz LABEL_5F57
	ld a, $1A
	ld hl, $C200
	call LABEL_791B
	ld hl, $1000
	ld.lil de, romStart + $C200
	ld bc, $0940
	call LABEL_428C
	di
	ex.lil de, hl
	ldir.lil
	ei
	ld hl, $3000
	ld bc, $0300
	ld de, $0080
	call LABEL_428C
LABEL_5FAE:
	di
	ld.lil (hl), e
	inc.lil hl
	ld.lil (hl), d
	inc.lil hl
	ei
	dec bc
	ld a, b
	or c
	jr nz, LABEL_5FAE
	di
	call LABEL_2258
	ei
	xor a
	ld ($D80C), a
	ld ix, $DA53
	ld a, $0B
	ld (ix+9), a
	ld hl, $0080
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0060
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld ix, $DA98
	ld a, $0C
	ld (ix+9), a
	ld hl, $0060
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0060
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld ix, $DA0E
	ld a, $0D
	ld (ix+9), a
	ld hl, $0280
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+22)
	ld (ix+24), $03
	ld ix, $DADD
	ld a, $0E
	ld (ix+9), a
	ld hl, $02A0
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+22)
	ld (ix+24), $03
	ld hl, DATA_5BA8
	call LABEL_43B9
	ld a, $C8
	ld ($D743), a
	xor a
	ld ($D744), a
	ret

LABEL_60B0:
	ld a, ($D744)
	and a
	ret nz
	ld ix, $DA53
	ld a, $0B
	ld (ix+9), a
	ld hl, $0080
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld ix, $DA98
	ld a, $0C
	ld (ix+9), a
	ld hl, $0024
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld ix, $DA0E
	ld a, $0D
	ld (ix+9), a
	ld hl, $027C
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+22)
	ld (ix+24), $03
	ld ix, $DADD
	ld a, $0E
	ld (ix+9), a
	ld hl, $02D8
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0600
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+22)
	ld (ix+24), $03
	ld a, $01
	ld ($D744), a
	ret

LABEL_618F:
	ld a, ($D744)
	cp $05
	jr nz, LABEL_61D4
	ld a, ($D743)
	cp $D0
	jr nz, LABEL_61B9
	ld a, ($D744)
	inc a
	ld ($D744), a
	xor a
	ld iy, $DA98
	ld (iy+30), a
	ld (iy+31), a
	ld iy, $DADD
	ld (iy+30), a
	ld (iy+31), a
LABEL_61B9:
	ld a, ($D76E)
	add a, a
	add a, a
	add a, a
	add a, a
	call LABEL_4D00
	sra a
	sra a
	sra a
	sra a
	sra a
	sra a
	add a, $A0
	ld (ix+2), a
LABEL_61D4:
	ret

; 15th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_61D5:
	call LABEL_618F
	call LABEL_5DE8
	call LABEL_32E3
	ret

; 14th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_61DF:
	ld a, ($D744)
	cp $04
	jr c, LABEL_61ED
	ld a, $07
	ld (ix+8), a
	jr LABEL_61F0

LABEL_61ED:
	call LABEL_5DB9
LABEL_61F0:
	call LABEL_32E3
	call LABEL_624F
	ld a, ($D744)
	cp $03
	ret nz
	call LABEL_6205
	ret nc
	ld (ix+24), $03
	ret

LABEL_6205:
	ld a, ($D743)
	cp $14
	jr nz, LABEL_6216
	ld (ix+32), $00
	ld (ix+33), $00
	scf
	ret

LABEL_6216:
	and a
	ret

; 13th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6218:
	call LABEL_618F
	call LABEL_5DE8
	call LABEL_32E3
	ret

; 12th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6222:
	ld a, ($D744)
	cp $04
	jr c, LABEL_6230
	ld a, $16
	ld (ix+8), a
	jr LABEL_6233

LABEL_6230:
	call LABEL_5DB9
LABEL_6233:
	call LABEL_32E3
	call LABEL_624F
	ld a, ($D744)
	cp $03
	ret nz
	call LABEL_6205
	ret nc
	ld (ix+24), $04
	ld a, ($D744)
	inc a
	ld ($D744), a
	ret

LABEL_624F:
	ld a, ($D744)
	cp $01
	jr z, LABEL_6259
	cp $02
	ret nz
LABEL_6259:
	ld a, ($D743)
	cp $23
	ret nz
	ld l, (ix+30)
	ld h, (ix+31)
	ld (ix+30), $00
	ld (ix+31), $00
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+23)
	ld (ix+24), $01
	ld a, ($D744)
	inc a
	ld ($D744), a
	ret

; 2nd entry of Jump Table from 5DB1 (indexed by $D741)
LABEL_6283:
	call LABEL_62BC
LABEL_6286:
	call LABEL_6376
	call LABEL_2EC6
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
LABEL_6295:
	ld a, (ix+8)
	ld (ix+5), a
	add ix, de
	djnz LABEL_6295
	call LABEL_257C
	call LABEL_27D6
	ld a, ($D743)
	dec a
	ld ($D743), a
	xor a
	call LABEL_5E09
	call LABEL_22DA
	ld a, $01
	call LABEL_5E09
	jp LABEL_6286

LABEL_62BC:
	ld b, $FF
	ld c, $02
	call SetTilemapPTR
	ld a, $19
	ld hl, $1000
	di
	call LABEL_76E3
	ei
	ld hl, $3800
	ld bc, $0300
	ld de, $0080
	call LABEL_428C
LABEL_62D6:
	di
	ld.lil (hl), e	
	inc.lil hl
	ld.lil (hl), d
	inc.lil hl
	ei
	dec bc
	ld a, b
	or c
	jr nz, LABEL_62D6
	di
	call LABEL_2258
	ei
	ld ix, $DA0E
	ld a, $10
	ld (ix+9), a
	ld hl, $0080
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0020
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0300
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld ix, $DA53
	ld a, $0F
	ld (ix+9), a
	ld hl, $0040
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0020
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0300
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld hl, DATA_5BA8
	call LABEL_43B9
	xor a
	ld ($D744), a
	ld ($D743), a
	ret

; 16th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6368:
	call LABEL_5DB9
	call LABEL_32E3
	ret

; 17th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_636F:
	call LABEL_5DB9
	call LABEL_32E3
	ret

LABEL_6376:
	ld a, ($D744)
	rst $08	; LABEL_8
; Jump Table from 637A to 6385 (6 entries, indexed by $D744)
DATA_637A:
	.dw LABEL_6387, LABEL_63B0, LABEL_63D9, LABEL_640A, LABEL_6433, LABEL_6386

; 6th entry of Jump Table from 637A (indexed by $D744)
LABEL_6386:
	ret

; 1st entry of Jump Table from 637A (indexed by $D744)
LABEL_6387:
	ld a, ($D743)
	cp $57
	ret nz
	ld ix, $DA0E
	set 0, (ix+22)
	ld (ix+24), $03
	ld (ix+2), $A0
	ld ix, $DA53
	set 0, (ix+22)
	ld (ix+24), $03
	ld (ix+2), $A0
	jp LABEL_5E7B

; 2nd entry of Jump Table from 637A (indexed by $D744)
LABEL_63B0:
	ld a, ($D743)
	cp $7B
	ret nz
	ld ix, $DA0E
	res 0, (ix+22)
	ld (ix+24), $04
	ld (ix+2), $70
	ld ix, $DA53
	res 0, (ix+22)
	ld (ix+24), $04
	ld (ix+2), $70
	jp LABEL_5E7B

; 3rd entry of Jump Table from 637A (indexed by $D744)
LABEL_63D9:
	ld a, ($D743)
	cp $8E
	ret nz
	ld ix, $DA0E
	set 0, (ix+22)
	ld (ix+24), $03
	ld (ix+2), $20
	ld (ix+31), $10
	ld ix, $DA53
	set 0, (ix+22)
	ld (ix+24), $03
	ld (ix+2), $20
	ld (ix+31), $10
	jp LABEL_5E7B

; 4th entry of Jump Table from 637A (indexed by $D744)
LABEL_640A:
	ld a, ($D743)
	cp $E6
	ret nz
	ld ix, $DA0E
	res 0, (ix+22)
	ld (ix+24), $04
	ld (ix+2), $A0
	ld ix, $DA53
	res 0, (ix+22)
	ld (ix+24), $04
	ld (ix+2), $A0
	jp LABEL_5E7B

; 5th entry of Jump Table from 637A (indexed by $D744)
LABEL_6433:
	ld a, ($D743)
	cp $78
	ret nz
	pop bc
	call LABEL_4384
	ret

; 3rd entry of Jump Table from 5DB1 (indexed by $D741)
LABEL_643E:
	call LABEL_6477
LABEL_6441:
	call LABEL_658C
	call LABEL_2EC6
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
LABEL_6450:
	ld a, (ix+8)
	ld (ix+5), a
	add ix, de
	djnz LABEL_6450
	call LABEL_257C
	call LABEL_27D6
	ld a, ($D743)
	dec a
	ld ($D743), a
	xor a
	call LABEL_5E09
	call LABEL_22DA
	ld a, $01
	call LABEL_5E09
	jp LABEL_6441

LABEL_6477:
	ld b, $FF
	ld c, $02
	call SetTilemapPTR
	call LABEL_5E87
	di
	call LABEL_2258
	ei
	ld ix, $DA98
	ld a, $11
	ld (ix+9), a
	ld hl, $0240
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $0008
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0200
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+22)
	res 0, (ix+23)
	ld ix, $DADD
	ld a, $13
	ld (ix+9), a
	ld hl, $0200
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	ld hl, $024A
	ld (ix+0), l
	ld (ix+1), h
	ld (ix+3), $00
	set 0, (ix+22)
	res 0, (ix+23)
	call LABEL_6588
	ld (ix+8), $85
	ld hl, $0030
	ld (ix+53), l
	ld (ix+54), h
	ld ix, $DB22
	ld a, $12
	ld (ix+9), a
	ld hl, $0130
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00B0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0000
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+8), $09
	ld ix, $DB67
	ld a, $12
	ld (ix+9), a
	ld hl, $0118
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00B0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0000
	ld (ix+30), l
	ld (ix+31), h
	ld (ix+32), l
	ld (ix+33), h
	ld (ix+8), $15
	ld hl, DATA_5BA8
	call LABEL_43B9
	xor a
	ld ($D744), a
	ld ($D743), a
	ret

; 18th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6565:
	call LABEL_32E3
	ld a, (ix+6)
	dec a
	ld (ix+6), a
	bit 7, a
	ret z
	ld (ix+6), $05
	ld a, (ix+7)
	inc a
	and $07
	ld (ix+7), a
	and $07
	add a, $8C
	ld (ix+8), a
	ret

; 19th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6587:
	ret

; 20th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6588:
	call LABEL_32E3
	ret

LABEL_658C:
	ld a, ($D744)
	rst $08	; LABEL_8
; Jump Table from 6590 to 6599 (5 entries, indexed by $D744)
DATA_6590:
	.dw LABEL_659B, LABEL_65AC, LABEL_662D, LABEL_6649, LABEL_659A

; 5th entry of Jump Table from 6590 (indexed by $D744)
LABEL_659A:
	ret

; 1st entry of Jump Table from 6590 (indexed by $D744)
LABEL_659B:
	ld a, ($DA9A)
	add a, $0C
	ld ($DADF), a
	ld a, ($D743)
	cp $B9
	ret nz
	jp LABEL_5E7B

; 2nd entry of Jump Table from 6590 (indexed by $D744)
LABEL_65AC:
	ld ix, $DADD
	ld l, (ix+32)
	ld h, (ix+33)
	ld e, (ix+53)
	ld d, (ix+54)
	bit 0, (ix+23)
	jr z, LABEL_65D6
	and a
	sbc hl, de
	bit 7, h
	jr z, LABEL_65D4
	ld de, $0000
	and a
	ex de, hl
	sbc hl, de
	res 0, (ix+23)
LABEL_65D4:
	jr LABEL_65D7

LABEL_65D6:
	add hl, de
LABEL_65D7:
	ld (ix+33), h
	ld (ix+32), l
	call LABEL_65E1
	ret

LABEL_65E1:
	ld a, (ix+2)
	cp $A6
	ret c
	set 0, (ix+23)
	srl (ix+33)
	rr (ix+32)
	srl (ix+33)
	rr (ix+32)
	srl (ix+31)
	rr (ix+30)
	ld (ix+2), $A5
	ld l, (ix+32)
	ld h, (ix+33)
	ld e, (ix+53)
	ld d, (ix+54)
	and a
	sbc hl, de
	jr nc, LABEL_662C
	xor a
	ld (ix+30), a
	ld (ix+31), a
	ld (ix+32), a
	ld (ix+33), a
	xor a
	ld (ix+6), a
	jp LABEL_5E7B

LABEL_662C:
	ret

; 3rd entry of Jump Table from 6590 (indexed by $D744)
LABEL_662D:
	ld ix, $DADD
	ld a, (ix+6)
	inc a
	cp $04
	jr nz, LABEL_6645
	ld a, (ix+8)
	cp $8B
	jp z, LABEL_5E7B
	inc (ix+8)
	xor a
LABEL_6645:
	ld (ix+6), a
	ret

; 4th entry of Jump Table from 6590 (indexed by $D744)
LABEL_6649:
	ld a, ($D743)
	cp $78
	ret nz
	pop bc
	call LABEL_4384
	ret

; 4th entry of Jump Table from 5DB1 (indexed by $D741)
LABEL_6654:
	call LABEL_668D
LABEL_6657:
	call LABEL_6712
	call LABEL_2EC6
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
LABEL_6666:
	ld a, (ix+8)
	ld (ix+5), a
	add ix, de
	djnz LABEL_6666
	call LABEL_257C
	call LABEL_27D6
	ld a, ($D743)
	dec a
	ld ($D743), a
	xor a
	call LABEL_5E09
	call LABEL_22DA
	ld a, $01
	call LABEL_5E09
	jp LABEL_6657



LABEL_668D:
	ld b, $FF
	ld c, $02
	call SetTilemapPTR
	call LABEL_5E87
	di
	call LABEL_2258
	ei
	ld ix, $DA0E
	ld (ix+9), $14
	ld hl, $0240
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0200
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	set 0, (ix+22)
	ld (ix+24), $03
	ld ix, $DA53
	ld (ix+9), $14
	ld hl, $00C0
	ld (ix+0), l
	ld (ix+1), h
	ld hl, $00A0
	ld (ix+2), l
	ld (ix+3), h
	ld hl, $0200
	ld (ix+30), l
	ld (ix+31), h
	ld hl, $0000
	ld (ix+32), l
	ld (ix+33), h
	res 0, (ix+22)
	ld (ix+24), $04
	ld hl, DATA_5BA8
	call LABEL_43B9
	xor a
	ld ($D744), a
	ld ($D743), a
	ret

LABEL_6712:
	ld a, ($D744)
	rst $08	; LABEL_8
; Jump Table from 6716 to 6725 (8 entries, indexed by $D744)
DATA_6716:
	.dw LABEL_672E, LABEL_674C, LABEL_67B3, LABEL_682C, LABEL_6885, LABEL_68E6, LABEL_69B0, LABEL_6726

; 8th entry of Jump Table from 6716 (indexed by $D744)
LABEL_6726:
	ret

; 21st entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6727:
	call LABEL_5DB9
	call LABEL_32E3
	ret

; 1st entry of Jump Table from 6716 (indexed by $D744)
LABEL_672E:
	ld a, ($D743)
	cp $A5
	ret nz
	ld ix, $DA0E
	xor a
	ld (ix+30), a
	ld (ix+31), a
	ld ix, $DA53
	ld (ix+30), a
	ld (ix+31), a
	jp LABEL_5E7B

; 2nd entry of Jump Table from 6716 (indexed by $D744)
LABEL_674C:
	ld ix, $DA0E
	call LABEL_5DB9
	ld ix, $DA53
	call LABEL_5DB9
	ld a, ($D743)
	cp $D6
	ret nz
	ld ix, $DA0E
	ld (ix+6), $00
	ld (ix+8), $9C
	ld (ix+9), $15
	ld ix, $DA53
	ld (ix+6), $00
	ld (ix+8), $97
	ld (ix+9), $16
	jp LABEL_5E7B

; 23rd entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6783:
	ld a, (ix+6)
	inc a
	cp $04
	jr nz, LABEL_6797
	ld a, (ix+8)
	cp $94
	jr z, LABEL_6796
	dec a
	ld (ix+8), a
LABEL_6796:
	xor a
LABEL_6797:
	ld (ix+6), a
	ret

; 22nd entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_679B:
	ld a, (ix+6)
	inc a
	cp $04
	jr nz, LABEL_67AF
	ld a, (ix+8)
	cp $99
	jr z, LABEL_67AE
	dec a
	ld (ix+8), a
LABEL_67AE:
	xor a
LABEL_67AF:
	ld (ix+6), a
	ret

; 3rd entry of Jump Table from 6716 (indexed by $D744)
LABEL_67B3:
	ld a, ($D743)
	cp $C0
	ret nz
	ld ix, $DA0E
	ld (ix+9), $17
	ld (ix+6), $00
	ld (ix+7), $00
	ld ix, $DA53
	ld (ix+9), $18
	ld (ix+6), $00
	ld (ix+7), $00
	jp LABEL_5E7B

; 24th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_67DC:
	ld a, (ix+7)
	inc a
	cp $03
	jr nz, LABEL_67EE
	ld a, (ix+6)
	inc a
	and $07
	ld (ix+6), a
	xor a
LABEL_67EE:
	ld (ix+7), a
	ld a, (ix+6)
	bit 2, a
	jr z, LABEL_67FC
	sub $07
	neg
LABEL_67FC:
	and $03
	add a, $A2
	ld (ix+8), a
	ret

; 25th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6804:
	ld a, (ix+7)
	inc a
	cp $03
	jr nz, LABEL_6816
	ld a, (ix+6)
	inc a
	and $07
	ld (ix+6), a
	xor a
LABEL_6816:
	ld (ix+7), a
	ld a, (ix+6)
	bit 2, a
	jr z, LABEL_6824
	sub $07
	neg
LABEL_6824:
	and $03
	add a, $9E
	ld (ix+8), a
	ret

; 4th entry of Jump Table from 6716 (indexed by $D744)
LABEL_682C:
	ld a, ($D743)
	cp $86
	ret nz
	ld ix, $DA0E
	ld (ix+9), $19
	ld (ix+6), $00
	ld (ix+8), $99
	ld ix, $DA53
	ld (ix+9), $1A
	ld (ix+6), $00
	ld (ix+8), $94
	jp LABEL_5E7B

; 26th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6855:
	ld a, (ix+6)
	inc a
	cp $03
	jr nz, LABEL_6869
	ld a, (ix+8)
	cp $9D
	jr z, LABEL_6865
	inc a
LABEL_6865:
	ld (ix+8), a
	xor a
LABEL_6869:
	ld (ix+6), a
	ret

; 27th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_686D:
	ld a, (ix+6)
	inc a
	cp $03
	jr nz, LABEL_6881
	ld a, (ix+8)
	cp $98
	jr z, LABEL_687D
	inc a
LABEL_687D:
	ld (ix+8), a
	xor a
LABEL_6881:
	ld (ix+6), a
	ret

; 5th entry of Jump Table from 6716 (indexed by $D744)
LABEL_6885:
	ld a, ($D743)
	cp $D0
	ret nz
	ld ix, $DA0E
	ld (ix+8), $AA
	ld (ix+9), $1B
	ld ix, $DA53
	ld (ix+8), $B2
	ld (ix+9), $1C
	jp LABEL_5E7B

; 28th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_68A6:
	dec (ix+2)
	ld a, ($D76E)
	and $06
	ret nz
	ld a, (ix+8)
	inc a
	jr z, LABEL_68C5
	cp $B2
	jr nz, LABEL_68BF
	ld (ix+9), $00
	ld a, $FF
LABEL_68BF:
	ld (ix+8), a
	dec (ix+0)
LABEL_68C5:
	ret

; 29th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_68C6:
	dec (ix+2)
	ld a, ($D76E)
	and $06
	ret nz
	ld a, (ix+8)
	inc a
	jr z, LABEL_68E5
	cp $BA
	jr nz, LABEL_68DF
	ld (ix+9), $00
	ld a, $FF
LABEL_68DF:
	ld (ix+8), a
	inc (ix+0)
LABEL_68E5:
	ret

; 6th entry of Jump Table from 6716 (indexed by $D744)
LABEL_68E6:
	ld a, ($D743)
	cp $D5
	ret nz
	ld ix, $DA0E
	ld de, $0045
	ld b, $08
LABEL_68F5:
	push bc
	push de
	ld (ix+9), $1D
	call LABEL_41C3
	ld (ix+0), a
	ld (ix+1), $01
	call LABEL_41C3
	ld (ix+2), a
	ld (ix+3), $01
	call LABEL_41C3
	and $03
	inc a
	ld (ix+24), a
	ld (ix+8), $FF
	call LABEL_41C3
	and $3F
	add a, $0A
	ld (ix+6), a
	pop de
	pop bc
	add ix, de
	djnz LABEL_68F5
	ld a, $04
	ld c, $03
	call LABEL_1950
	jp LABEL_5E7B

; 30th entry of Jump Table from 2E84 (indexed by $DA5C)
LABEL_6936:
	call LABEL_32E3
	ld (ix+3), $00
	ld (ix+1), $01
	dec (ix+6)
	ld a, (ix+6)
	and a
	ret nz
	call LABEL_41C3
	and $1F
	add a, $0A
	ld (ix+6), a
	call LABEL_41C3
	and $03
	inc a
	ld (ix+24), a
	add a, $A5
	ld (ix+8), a
	ld a, (ix+24)
	dec a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld e, a
	ld d, $00
	ld hl, DATA_6998
	add hl, de
	push hl
	pop iy
	ld a, (iy+0)
	ld (ix+30), a
	ld a, (iy+1)
	ld (ix+31), a
	ld a, (iy+2)
	ld (ix+32), a
	ld a, (iy+3)
	ld (ix+33), a
	ld a, (iy+4)
	ld (ix+22), a
	ld a, (iy+5)
	ld (ix+23), a
	ret

; Data from 6998 to 69AF (24 bytes)
DATA_6998:
	.db $00, $00, $00, $02, $00, $01, $00, $00, $00, $02, $00, $00, $00, $02, $00, $00
	.db $01, $00, $00, $02, $00, $00, $00, $00

; 7th entry of Jump Table from 6716 (indexed by $D744)
LABEL_69B0:
	ld a, ($D9E7)
	and a
	ret nz
	pop bc
	call LABEL_4384
	ret

; Data from 69BA to 69F1 (56 bytes)
DATA_69BA:
	.db $82, $00, $09, $24, $17, $00, $01, $2B, $15, $00, $03, $24, $15, $00, $04, $26
	.db $05, $28, $06, $29, $06, $26, $05, $00, $01, $2B, $04, $00, $02, $29, $05, $00
	.db $01, $28, $06, $2B, $06, $29, $05, $00, $01, $28, $06, $26, $07, $2B, $05, $28
	.db $0C, $2B, $0A, $00, $02, $30, $19, $FE

; 1st entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 69F2 to 6A2F (62 bytes)
DATA_69F2:
	.db $86, $2B, $02, $2D, $03, $2F, $04, $30, $0D, $34, $0B, $00, $01, $32, $0B, $35
	.db $0C, $00, $01, $34, $06, $35, $05, $37, $06, $34, $05, $00, $01, $32, $0D, $35
	.db $0B, $34, $06, $35, $06, $37, $05, $00, $01, $34, $06, $35, $06, $37, $04, $00
	.db $02, $39, $06, $3B, $06, $3C, $0C, $3B, $0A, $00, $02, $3C, $13, $FE

; 4th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6A30 to 6A93 (100 bytes)
DATA_6A30:
	.db $82, $34, $09, $00, $02, $34, $04, $00, $02, $34, $0C, $00, $18, $34, $08, $00
	.db $04, $34, $05, $00, $01, $34, $12, $00, $07, $34, $07, $00, $04, $34, $04, $00
	.db $03, $34, $15, $00, $0E, $2F, $07, $00, $05, $2F, $03, $00, $03, $2F, $15, $00
	.db $04, $34, $15, $00, $03, $32, $14, $00, $03, $30, $15, $00, $03, $2F, $13, $00
	.db $05, $34, $0A, $00, $02, $37, $08, $00, $04, $39, $0A, $00, $02, $39, $05, $00
	.db $01, $37, $06, $34, $0B, $00, $02, $39, $05, $00, $01, $37, $05, $00, $01, $34
	.db $09, $00, $57, $FE

; 5th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6A94 to 6B3B (168 bytes)
DATA_6A94:
	.db $86, $43, $04, $00, $01, $45, $06, $43, $05, $00, $01, $40, $09, $00, $04, $3B
	.db $05, $3E, $06, $3F, $04, $00, $02, $40, $0C, $00, $0C, $3E, $06, $40, $06, $00
	.db $01, $3E, $06, $3B, $05, $00, $01, $43, $05, $00, $01, $45, $05, $43, $06, $00
	.db $01, $40, $06, $00, $05, $3B, $06, $00, $01, $3E, $08, $00, $03, $3B, $11, $00
	.db $0C, $47, $05, $00, $01, $4A, $05, $00, $01, $4B, $03, $00, $04, $4C, $07, $00
	.db $04, $4C, $04, $00, $04, $4A, $02, $4B, $03, $4A, $07, $47, $05, $00, $01, $45
	.db $06, $43, $05, $45, $06, $43, $06, $00, $01, $45, $05, $00, $01, $47, $09, $00
	.db $02, $45, $06, $00, $01, $43, $03, $00, $02, $40, $05, $00, $01, $3E, $06, $40
	.db $06, $3E, $05, $00, $01, $3B, $05, $00, $01, $3E, $05, $00, $01, $3B, $04, $00
	.db $02, $3B, $04, $00, $02, $3B, $05, $00, $01, $3E, $06, $3B, $06, $00, $01, $39
	.db $06, $37, $06, $34, $0F, $00, $51, $FE

; 8th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6B3C to 6C4B (272 bytes)
DATA_6B3C:
	.db $82, $00, $0B, $3B, $06, $3A, $07, $39, $04, $00, $01, $37, $0C, $00, $01, $36
	.db $04, $00, $01, $37, $09, $00, $03, $35, $07, $34, $04, $00, $02, $33, $03, $00
	.db $02, $32, $0C, $00, $01, $31, $05, $00, $01, $32, $09, $00, $02, $2B, $13, $00
	.db $05, $2B, $0D, $00, $02, $2B, $03, $2D, $03, $2F, $03, $30, $0C, $00, $01, $34
	.db $0A, $00, $01, $2B, $0B, $00, $01, $34, $0A, $00, $02, $30, $0B, $00, $02, $34
	.db $08, $00, $03, $2B, $0C, $00, $01, $34, $0B, $30, $0B, $00, $01, $34, $0A, $00
	.db $02, $2B, $0D, $34, $0B, $00, $01, $30, $0B, $34, $0C, $00, $01, $2B, $0B, $00
	.db $01, $33, $0B, $00, $01, $32, $0B, $35, $0C, $00, $01, $37, $0A, $00, $01, $35
	.db $08, $00, $04, $32, $0C, $00, $01, $35, $0B, $00, $01, $2F, $0B, $35, $0C, $32
	.db $0C, $35, $0C, $00, $01, $2F, $0B, $00, $01, $35, $0A, $00, $02, $2F, $0B, $00
	.db $01, $31, $0C, $32, $0B, $00, $01, $33, $07, $00, $04, $34, $06, $35, $05, $00
	.db $02, $36, $05, $00, $01, $37, $02, $00, $04, $37, $04, $00, $01, $35, $05, $00
	.db $01, $34, $04, $00, $03, $32, $04, $00, $01, $30, $0C, $34, $0B, $00, $01, $2B
	.db $0C, $34, $0C, $30, $0D, $34, $0A, $00, $01, $2B, $0D, $34, $0B, $32, $0C, $35
	.db $0D, $34, $0B, $31, $0C, $32, $0C, $2F, $0C, $2D, $0C, $2B, $0B, $00, $01, $32
	.db $0E, $00, $16, $32, $0B, $00, $01, $30, $0D, $00, $17, $30, $0C, $2F, $0C, $35
	.db $0C, $32, $0D, $35, $0C, $30, $0B, $00, $01, $2B, $0A, $00, $01, $30, $10, $FE

; 9th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6C4C to 6D9B (336 bytes)
DATA_6C4C:
	.db $86, $37, $0A, $00, $01, $3B, $06, $3C, $06, $00, $01, $3D, $03, $00, $02, $3E
	.db $0B, $00, $02, $3D, $04, $00, $01, $3E, $06, $00, $06, $3B, $06, $00, $01, $3E
	.db $05, $00, $01, $40, $05, $41, $0D, $40, $06, $41, $08, $00, $03, $47, $06, $45
	.db $07, $43, $06, $41, $04, $00, $01, $40, $06, $41, $05, $00, $01, $39, $05, $00
	.db $01, $3B, $05, $00, $01, $3C, $12, $00, $12, $37, $09, $00, $03, $40, $05, $00
	.db $01, $41, $06, $00, $01, $42, $03, $00, $02, $43, $04, $00, $03, $3C, $04, $00
	.db $01, $3E, $05, $00, $02, $3F, $04, $00, $01, $40, $05, $00, $01, $3C, $06, $00
	.db $01, $40, $05, $3C, $06, $00, $01, $37, $0B, $34, $07, $35, $05, $36, $05, $00
	.db $02, $37, $13, $00, $05, $3A, $13, $00, $05, $3B, $18, $00, $17, $41, $06, $3E
	.db $07, $39, $05, $3A, $06, $00, $01, $40, $05, $3E, $06, $3A, $06, $00, $01, $3B
	.db $03, $00, $02, $3E, $06, $41, $06, $45, $06, $00, $01, $43, $0B, $00, $01, $41
	.db $06, $3E, $05, $00, $01, $3B, $05, $00, $01, $39, $17, $00, $01, $37, $0F, $00
	.db $08, $3C, $06, $3E, $06, $00, $01, $3F, $04, $00, $02, $40, $05, $00, $01, $3B
	.db $05, $3C, $06, $3D, $05, $00, $02, $3E, $04, $00, $01, $40, $06, $41, $06, $42
	.db $06, $00, $01, $43, $05, $3C, $06, $3E, $06, $3F, $06, $40, $06, $3C, $06, $00
	.db $01, $40, $05, $00, $01, $3C, $05, $37, $08, $00, $04, $37, $06, $00, $01, $36
	.db $05, $00, $01, $37, $04, $00, $01, $39, $18, $00, $01, $38, $14, $00, $03, $39
	.db $1D, $00, $13, $41, $06, $00, $01, $40, $05, $00, $01, $3E, $05, $00, $01, $3C
	.db $0B, $3E, $06, $40, $08, $00, $04, $40, $06, $3E, $06, $00, $01, $3C, $05, $00
	.db $01, $37, $06, $00, $05, $34, $06, $35, $06, $36, $05, $00, $01, $37, $13, $00
	.db $05, $3B, $06, $41, $06, $00, $01, $39, $05, $00, $01, $3B, $05, $3C, $14, $FE

; 16th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6D9C to 6DDD (66 bytes)
DATA_6D9C:
	.db $82, $24, $17, $2B, $17, $00, $01, $29, $16, $00, $02, $2C, $18, $2B, $0C, $2C
	.db $0B, $00, $01, $2E, $0C, $2B, $0C, $29, $16, $00, $02, $2C, $14, $00, $04, $2B
	.db $0B, $00, $01, $27, $0C, $29, $0C, $2B, $0A, $00, $02, $26, $0C, $2B, $0C, $2A
	.db $0B, $00, $01, $2B, $0C, $27, $17, $00, $01, $2B, $18, $30, $17, $00, $19, $24
	.db $01, $FE

; 17th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6DDE to 6E1B (62 bytes)
DATA_6DDE:
	.db $86, $30, $17, $33, $16, $00, $02, $32, $18, $35, $16, $00, $03, $33, $0B, $35
	.db $0C, $37, $0C, $00, $01, $33, $0B, $32, $18, $35, $18, $37, $0A, $00, $02, $33
	.db $0C, $35, $0C, $37, $0C, $39, $0C, $37, $0C, $39, $0C, $3B, $0A, $00, $02, $3C
	.db $17, $00, $01, $3B, $16, $00, $02, $3C, $1A, $00, $16, $30, $01, $FE

; 12th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6E1C to 6EA5 (138 bytes)
DATA_6E1C:
	.db $82, $3C, $03, $3B, $04, $3C, $04, $40, $05, $3F, $04, $00, $01, $40, $22, $00
	.db $0D, $35, $03, $34, $05, $35, $04, $32, $04, $2D, $05, $2F, $04, $00, $01, $34
	.db $23, $00, $11, $3C, $03, $00, $01, $3B, $03, $3C, $04, $40, $04, $3F, $04, $00
	.db $01, $40, $1F, $00, $0B, $3C, $04, $3B, $04, $3C, $04, $40, $05, $3F, $04, $40
	.db $1E, $00, $0B, $3C, $04, $3B, $05, $3C, $03, $40, $05, $3F, $04, $40, $1A, $00
	.db $09, $35, $04, $00, $01, $34, $03, $35, $04, $00, $01, $32, $04, $2D, $04, $2F
	.db $05, $34, $21, $00, $0C, $3C, $04, $3B, $03, $3C, $04, $40, $04, $3F, $04, $00
	.db $01, $40, $18, $00, $07, $35, $04, $00, $01, $34, $03, $35, $05, $32, $04, $2D
	.db $04, $2F, $04, $00, $01, $34, $26, $00, $40, $FE

; 13th entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 6EA6 to 6F38 (147 bytes)
DATA_6EA6:
	.db $86, $40, $03, $3F, $04, $40, $04, $43, $05, $42, $04, $00, $01, $43, $22, $00
	.db $0D, $39, $03, $38, $05, $39, $04, $3B, $04, $40, $05, $3E, $04, $00, $01, $3C
	.db $23, $00, $11, $40, $03, $00, $01, $3F, $03, $40, $04, $43, $04, $42, $04, $00
	.db $01, $43, $1F, $00, $0B, $40, $04, $3F, $04, $40, $04, $43, $05, $42, $04, $43
	.db $1E, $00, $0B, $40, $04, $3F, $04, $40, $04, $43, $05, $42, $04, $43, $1A, $00
	.db $0A, $39, $03, $00, $01, $38, $03, $39, $04, $00, $01, $3B, $04, $40, $04, $3E
	.db $05, $3C, $21, $00, $0C, $40, $04, $3F, $03, $40, $04, $43, $04, $42, $04, $00
	.db $01, $43, $18, $00, $07, $39, $04, $00, $01, $38, $03, $39, $05, $3B, $04, $40
	.db $04, $3E, $04, $00, $01, $3C, $26, $00, $3F, $40, $01, $FE, $00, $FF, $7F, $FF
	.db $7F, $42, $FF

; Data from 6F39 to 6F3A (2 bytes)
DATA_6F39:
	.dw DATA_69BA, DATA_69F2, DATA_737E, DATA_737E, DATA_6A30, DATA_6A94, DATA_737E, DATA_737E
	.dw DATA_6B3C, DATA_6C4C, DATA_737E, DATA_737E, DATA_6E1C, DATA_6EA6, DATA_737E, DATA_737E
	.dw DATA_6D9C, DATA_6DDE, DATA_737E, DATA_737E

; Data from 6F61 to 6F62 (2 bytes)
	.db $00, $00

; 3rd entry of Pointer Table from 736C (indexed by unknown)
; Data from 6F63 to 6F79 (23 bytes)
DATA_6F63:
	.db $13, $09, $01, $00, $01, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $FF, $00, $02
	.db $02, $FE, $FE, $FE, $02, $00, $00

; 7th entry of Pointer Table from 736C (indexed by unknown)
; Data from 6F7A to 6F90 (23 bytes)
DATA_6F7A:
	.db $13, $09, $01, $00, $01, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $FF, $00, $02
	.db $02, $FE, $FE, $FE, $02, $00, $00

; Data from 6F91 to 7076 (230 bytes)
DATA_6F91:
	.fill 34, $00
	.db $E4, $0F, $00, $0F, $29, $0E, $5D, $0D, $9C, $0C, $E7, $0B, $3C, $0B, $9B, $0A
	.db $02, $0A, $73, $09, $EB, $08, $6B, $08, $F2, $07, $80, $07, $14, $07, $AE, $06
	.db $4E, $06, $F4, $05, $9E, $05, $4D, $05, $01, $05, $B9, $04, $75, $04, $35, $04
	.db $F9, $03, $C0, $03, $8A, $03, $57, $03, $27, $03, $FA, $02, $CF, $02, $A7, $02
	.db $81, $02, $5D, $02, $3B, $02, $1B, $02, $FC, $01, $E0, $01, $C5, $01, $AC, $01
	.db $94, $01, $7D, $01, $68, $01, $53, $01, $40, $01, $2E, $01, $1D, $01, $0D, $01
	.db $FE, $00, $F0, $00, $E2, $00, $D6, $00, $CA, $00, $BE, $00, $B4, $00, $AA, $00
	.db $A0, $00, $97, $00, $8F, $00, $87, $00, $7F, $00, $78, $00, $71, $00, $6B, $00
	.db $65, $00, $5F, $00, $5A, $00, $55, $00, $50, $00, $4C, $00, $47, $00, $43, $00
	.db $40, $00, $3C, $00, $39, $00, $35, $00, $32, $00, $30, $00, $2D, $00, $2A, $00
	.db $28, $00, $26, $00, $24, $00, $22, $00, $20, $00, $1E, $00, $1C, $00, $1B, $00
	.db $19, $00, $18, $00, $16, $00, $15, $00, $14, $00, $13, $00, $12, $00, $11, $00
	.db $10, $00, $0F, $00

; 2nd entry of Pointer Table from 736C (indexed by unknown)
; Data from 7077 to 70FB (133 bytes)
DATA_7077:
	.db $13, $40, $01, $00, $01, $0E, $0E, $0E, $0E, $0D, $0D, $0D, $0D, $0C, $0C, $0C
	.db $0C, $0B, $0B, $0B, $0B, $0A, $0A, $0A, $0A, $09, $09, $09, $09, $08, $08, $08
	.db $08, $07, $07, $07, $07, $06, $06, $06, $06, $05, $05, $05, $05, $04, $04, $04
	.db $04, $03, $03, $03, $03, $02, $02, $02, $02, $01, $01, $01, $01, $00, $00, $00
	.db $00, $00, $00, $00, $00, $01, $64, $9D, $00, $FF, $00, $FF, $00, $FF, $00, $FF
	.db $00, $01, $00, $01, $00, $02, $00, $02, $00, $FE, $00, $FE, $00, $FE, $00, $FE
	.db $00, $02, $00, $02
	.fill 33, $00

; 8th entry of Pointer Table from 736C (indexed by unknown)
; Data from 70FC to 7112 (23 bytes)
DATA_70FC:
	.db $13, $09, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $28, $28
	.db $28, $28, $28, $28, $28, $28, $00

; 1st entry of Pointer Table from 736C (indexed by unknown)
; Data from 7113 to 719C (138 bytes)
DATA_7113:
	.db $13, $20, $01, $00, $01, $06, $07, $08
	.fill 26, $09
	.db $08, $07, $06, $00, $64, $9C, $00, $01, $01, $FF, $FF, $FF, $FF, $01, $01, $01
	.db $01, $FF, $FF, $FF, $FF, $01, $01, $01, $01, $FF, $FF, $FF, $FF, $01, $01, $01
	.db $01, $00, $00, $0D, $20, $01, $00, $01, $08, $09, $0A
	.fill 26, $0B
	.db $0A, $09, $08
	.fill 32, $07

; 5th entry of Pointer Table from 736C (indexed by unknown)
; Data from 719D to 71C1 (37 bytes)
DATA_719D:
	.db $13, $10, $01, $00, $01, $0E, $0C, $0A, $08, $0C, $0A, $08, $06, $0A, $08, $06
	.db $04, $08, $06, $04, $00, $00, $28, $28, $28, $88, $28, $28, $28, $88, $28, $28
	.db $28, $88, $28, $28, $28

; 6th entry of Pointer Table from 736C (indexed by unknown)
; Data from 71C2 to 71E6 (37 bytes)
DATA_71C2:
	.db $13, $10, $01, $00, $01, $0E, $0C, $0A, $08, $06, $04, $02
	.fill 10, $00
	.fill 14, $3C
	.db $1E

; 4th entry of Pointer Table from 736C (indexed by unknown)
; Data from 71E7 to 736B (389 bytes)
DATA_71E7:
	.db $13, $C0, $01, $00, $01, $0F, $0F, $0E, $0E, $0E, $0E, $0E, $0E
	.fill 12, $0D
	.fill 24, $0C
	.fill 48, $0B
	.fill 100, $0A
	.fill 192, $00

; Pointer Table from 736C to 737B (8 entries, indexed by unknown)
DATA_736C:
	.dw DATA_7113, DATA_7077, DATA_6F63, DATA_71E7, DATA_719D, DATA_71C2, DATA_6F7A, DATA_70FC

; Data from 737C to 737D (2 bytes)
	.db $00, $00

; 2nd entry of Pointer Table from 6F3B (indexed by $D9E8)
; Data from 737E to 76E2 (869 bytes)
DATA_737E:
	.db $87, $9E, $FE, $00, $FE, $9D, $FE 
DATA_7385:
	.dw LABEL_76E3, DATA_76D0, DATA_76BD, DATA_76AA, DATA_7695, DATA_75D0, DATA_75F5, DATA_761A
	.dw DATA_763F, DATA_75AF, DATA_759B, DATA_756A, DATA_746A, DATA_74F6, DATA_747D, DATA_7426
	.dw DATA_73E2, DATA_7404, DATA_73AF, DATA_70FC

DATA_73AF:
	.db $33, $10, $40, $07, $01, $0E, $0B, $0B, $0B, $0B, $0B, $0E, $0E, $0C, $0A
	.db $09, $08, $08, $08, $08, $00, $00, $00, $FC, $FF, $F8, $FF, $4A, $FF, $99, $00
	.db $40, $FF, $91, $00, $38, $FF, $85, $00, $2A, $FF, $75, $00, $18, $FF, $64, $00
	.db $06, $FF, $53, $00
DATA_73E2:
	.db $13, $0F, $30, $03, $01, $0F, $0F
	.fill 11, $0D
	.db $FE, $12, $00, $FD, $FC, $FB, $FB, $FA, $FA, $F8, $F8, $F6, $F6, $F6, $F6, $F5
DATA_7404:
	.db $13, $0F, $00, $03, $01, $0F, $0F
	.fill 11, $0D
	.db $FE, $10, $00, $FD, $FC, $FB, $FB, $FA, $FA, $F8, $F8, $F6, $F6, $F6, $F6, $F5
DATA_7426:
	.db $13, $20, $D0, $02, $01, $0F, $0F, $0F, $0F
	.fill 26, $0D
	.db $FE, $0C, $00, $FD, $FC, $FB, $FB, $FA, $FA, $F8, $F8, $F6, $F6, $F6, $F6, $F5
	.db $F5, $F1, $F1, $F0, $F0, $EC, $EC, $E2, $E2, $E2, $E2, $D3, $D3, $D3, $D3, $D3
	.db $D3
DATA_746A:
	.db $0D, $07, $00, $0A, $01, $0F, $0A, $0A, $07, $05, $03, $00, $04, $04, $04
	.db $04, $04, $04, $04
DATA_747D:
	.db $13, $3C, $40, $02, $01, $0D, $0C, $0B, $0B, $0A, $0A, $05
	.db $05, $05, $80, $0D, $0C, $0B, $0B, $0A, $0A, $05, $05, $05, $80, $0D, $0C, $0B
	.db $0B, $0A, $0A, $05, $05, $05, $80, $0D, $0C, $0B, $0B, $0A, $0A, $05, $05, $05
	.db $80, $0D, $0C, $0B, $0B, $0A, $0A, $05, $05, $05, $80, $0D, $0C, $0B, $0B, $0A
	.db $0A, $05, $05, $05
	.fill 57, $00
DATA_74F6:
	.db $13, $38, $B0, $03, $01
	.fill 9, $0F
	.db $FD, $2C, $01, $0F, $FD, $F4, $01, $0F, $FD, $C2, $01, $0F, $FD, $90, $01
	.fill 20, $0F
	.db $0E, $0C, $0A, $FD, $A2, $FE, $08, $FD, $38, $FF, $06, $00, $00, $28, $50, $5A
	.db $78, $78, $78, $7D, $7D
	.fill 16, $00
	.db $64, $32, $E2, $D8, $C4, $B0
	.fill 16, $88
	.db $00, $00, $00, $00, $00, $00, $00, $00
DATA_756A:
	.db $13, $18, $D0, $01, $01, $FD, $00, $01
	.db $0E, $07, $FD, $1E, $FF, $0C, $01, $0C, $01, $0C, $01, $0C, $80, $0C, $0C, $80
	.db $80, $FD, $68, $01, $FF, $00, $00, $00, $00, $E2, $00, $00, $00, $00, $C4, $CE
	.db $00, $BA, $00, $9C, $00, $B0, $00, $00, $00
DATA_759B:
	.db $13, $08, $80, $02, $01, $0E, $0E
	.db $0C, $0C, $0C, $0C, $80, $FF, $00, $E4, $EA, $E4, $EA, $E4, $76
DATA_75AF:
	.db $13, $0F, $50
	.db $01, $01, $07, $03, $08, $03, $09, $03, $09, $03, $07, $03, $07, $03, $06, $FE
	.db $0A, $00, $00, $3B, $00, $3B, $00, $3B, $00, $3B, $00, $3B, $00, $3B
DATA_75D0:
	.db $13, $11
	.db $00, $02, $01
	.fill 15, $0F
	.db $FE, $07
	.fill 15, $20
DATA_75F5:
	.db $13, $11, $58, $02, $01
	.fill 15, $0F
	.db $FE, $08
	.fill 15, $20
DATA_761A:
	.db $13, $11, $BC, $02, $01
	.fill 15, $0F
	.db $FE, $09
	.fill 15, $20
DATA_763F:
	.db $13, $29, $20, $03, $01
	.fill 40, $0F
	.db $00
	.fill 40, $32
DATA_7695:
	.db $13, $08, $F0, $01, $01, $0D, $0A, $0A, $08, $08, $0A, $0A, $00, $00, $FA, $7F
	.db $A7, $57, $A7, $57, $A7
DATA_76AA:
	.db $13, $07, $00, $02, $01, $0C, $07, $03, $03, $02, $02
	.db $00, $00, $00, $00, $00, $00, $00, $00
DATA_76BD:
	.db $13, $07, $80, $03, $01, $0C, $07, $03
	.db $03, $02, $02, $00, $00, $00, $00, $00, $00, $00, $00
DATA_76D0:
	.db $13, $07, $FF, $0F, $01
	.db $0F, $0A, $0A, $05, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00

LABEL_76E3:
	push af
	call LABEL_428C
	pop af
	ld l, a
	ld a, ($FFFF)
	push af
	call LABEL_76F5
	pop af
	call.lil SwitchBank + romStart
	ret

LABEL_76F5:
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld.lil de, (Bank5_Address)
	add.lil hl, de
	ld.lil de, romStart + $D877
	ld bc, $0008
	ldir.lil
	ld ix, $D877
	inc hl
	ld h, (ix+0)
	ld l, (ix+1)
	ld b, (ix+2)
	ld c, (ix+3)
	dec bc
	ld e, $20
	ld iy, $D857
	ld a, (ix+6)
	add a, $05
	call.lil SwitchBank + romStart
	cp $20
	jp nc, LABEL_7A32
	call.lil UpdateBankAddress
	ld.lil a, (hl)
	ld ($D70F), a
	inc.lil hl
	dec bc
	ld a, (ix+7)
	cp $02
	jp z, LABEL_78F2
	cp $03
	jp z, LABEL_7839
	and a
	jp nz, LABEL_7749
	jp LABEL_78B0

LABEL_7749:
	ld.lil d, (hl)
	inc.lil hl
	dec bc
	ld a, ($D70F)
	cp d
	jr z, LABEL_7786
	ld (iy+0), d
	inc iy
	dec e
	call z, LABEL_7799
LABEL_775B:
	ld a, b
	inc a
	jr nz, LABEL_7749
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	dec bc
	ld a, (ix+6)
	add a, $05
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de
	jp LABEL_7749

LABEL_7780:
	inc.lil hl
	dec bc
	inc.lil hl
	dec bc
	jr LABEL_775B

LABEL_7786:
	inc.lil hl
	ld.lil d, (hl)
	inc d
	dec.lil hl
LABEL_778A:
	dec d
	jr z, LABEL_7780
	ld.lil a, (hl)
	ld (iy+0), a
	inc iy
	dec e
	call z, LABEL_7799
	jr LABEL_778A

LABEL_7799:
	push bc
	push.lil hl
	ld iy, $D857
	ld hl, (VRAMPointer)
	ld.lil bc, SegaVRAM
	add.lil hl, bc
	ld b, $08
LABEL_77A0:
	ld a, (iy+0)
	ld.lil (hl), a
	inc.lil hl
	ld a, (iy+8)
	ld.lil (hl), a
	inc.lil hl
	ld a, (iy+16)
	ld.lil (hl), a
	inc.lil hl
	ld a, (iy+24)
	ld.lil (hl), a
	inc.lil hl
	inc iy
	djnz LABEL_77A0

	ld hl, (VRAMPointer)
	ld bc, $0020
	add hl, bc
	ld (VRAMPointer), hl

	pop.lil hl
	pop bc
	ld e, $20
	ld iy, $D857
	ret

LABEL_77C0:
	ld e, $03
LABEL_77C2:
	ld.lil d, (hl)
	inc.lil hl
	dec bc
	ld a, ($D70F)
	cp d
	jr z, LABEL_77FF
	ld (iy+0), d
	inc iy
	dec e
	call z, LABEL_7812
LABEL_77D4:
	ld a, b
	inc a
	jr nz, LABEL_77C2
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	dec bc
	ld a, (ix+6)
	add a, $05
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de
	jp LABEL_77C2

LABEL_77F9:
	inc.lil hl
	dec bc
	inc.lil hl
	dec bc
	jr LABEL_77D4

LABEL_77FF:
	inc.lil hl
	ld.lil d, (hl)
	inc d
	dec.lil hl
LABEL_7803:
	dec d
	jr z, LABEL_77F9
	ld.lil a, (hl)
	ld (iy+0), a
	inc iy
	dec e
	call z, LABEL_7812
	jr LABEL_7803

LABEL_7812:
	exx
	ld iy, $D857
	ld a, (iy+0)
	ld (hl), a
	inc hl
	ld a, (iy+2)
	and $0F
	ld (hl), a
	inc hl
	ld a, (iy+1)
	ld (hl), a
	inc hl
	ld a, (iy+2)
	srl a
	srl a
	srl a
	srl a
	ld (hl), a
	inc hl
	exx
	ld e, $03
	ret

LABEL_7839:
	ld e, $03
LABEL_783B:
	ld.lil d, (hl)
	inc.lil hl
	dec bc
	ld a, ($D70F)
	cp d
	jr z, LABEL_7878
	ld (iy+0), d
	inc iy
	dec e
	call z, LABEL_788B
LABEL_784D:
	ld a, b
	inc a
	jr nz, LABEL_783B
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	dec bc
	ld a, (ix+6)
	add a, $05
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de
	jp LABEL_783B

LABEL_7872:
	inc.lil hl
	dec bc
	inc.lil hl
	dec bc
	jr LABEL_784D

LABEL_7878:
	inc.lil hl
	ld.lil d, (hl)
	inc d
	dec.lil hl
LABEL_787C:
	dec d
	jr z, LABEL_7872
	ld.lil a, (hl)
	ld (iy+0), a
	inc iy
	dec e
	call z, LABEL_788B
	jr LABEL_787C

LABEL_788B:
	push.lil hl
	push bc
	ld hl, (VRAMPointer)
	ld.lil bc, SegaVRAM
	add.lil hl, bc

	ld iy, $D857
	ld a, (iy+0)
	ld.lil (hl), a
	inc.lil hl
	ld a, (iy+2)
	and $0F
	ld.lil (hl), a
	inc.lil hl
	ld a, (iy+1)
	ld.lil (hl), a
	inc.lil hl

	ld a, (iy+2)
	srl a
	srl a
	srl a
	srl a
	ld.lil (hl), a
	ld e, $03

	ld hl, (VRAMPointer)
	ld bc, 4
	add hl, bc
	ld (VRAMPointer), hl

	pop bc
	pop.lil hl
	ret

LABEL_78B0:
	ld iy, (VRAMPointer)
	ld.lil de, SegaVRAM
	add.lil iy, de
_:	ld d, (hl)
	inc hl
	dec bc
	ld a, ($D70F)
	cp d
	jr z, LABEL_78E6
	ld a, d
	ld.lil (iy), a
	inc.lil iy
LABEL_78BC:
	ld a, b
	inc a
	jr nz, -_
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	ld a, (ix+6)
	add a, $05
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de
	jp LABEL_78B0

LABEL_78E0:
	inc.lil hl
	dec bc
	inc.lil hl
	dec bc
	jr LABEL_78BC

LABEL_78E6:
	inc.lil hl
	ld.lil d, (hl)
	inc d
	dec.lil hl
LABEL_78EA:
	dec d
	jr z, LABEL_78E0
	ld.lil a, (hl)
	ld.lil (iy), a
	inc.lil iy
	jr LABEL_78EA

LABEL_78F2:
	push bc
	ld iy, (VRAMPointer)
	ld.lil bc, SegaVRAM
	add.lil iy, bc
	pop bc

_:	ld.lil a, (hl)
	inc.lil hl
	dec bc
	ld.lil (iy), a
	inc.lil iy
	ld a, b
	inc a
	jr nz, -_
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	ld a, (ix+6)
	add a, $05
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de

	jp -_

LABEL_791B:
	exx
	ld l, a
	ld a, ($FFFF)
	push af
	call LABEL_7929
	pop af
	call.lil SwitchBank + romStart
	ret

LABEL_7929:
	ld a, $05
	call.lil SwitchBank + romStart
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld.lil de, (Bank5_Address)
	add.lil hl, de
	ld.lil de, romStart + $D877
	ld bc, $0008
	ldir.lil
	ld ix, $D877
	inc hl
	ld h, (ix+0)
	ld l, (ix+1)
	ld b, (ix+2)
	ld c, (ix+3)
	dec bc
	ld e, $20
	ld iy, $D857
	ld a, (ix+6)
	add a, $05
	call.lil SwitchBank + romStart
	cp $20
	jp nc, LABEL_7A32
	call.lil UpdateBankAddress
	ld.lil a, (hl)
	ld ($D70F), a
	inc.lil hl
	dec bc
	ld a, (ix+7)
	cp $03
	jp z, LABEL_77C0
	and a
	jp nz, LABEL_79BB
	jp LABEL_7978

LABEL_7978:
	ld.lil d, (hl)
	inc.lil hl
	dec bc
	ld a, ($D70F)
	cp d
	jr z, LABEL_79AD
	exx
	ld.lil (hl), d
	inc.lil hl
	exx
LABEL_7985:
	ld a, b
	inc a
	jr nz, LABEL_7978
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	ld a, ($FFFF)
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de

	jp LABEL_7978

LABEL_79A7:
	inc.lil hl
	dec bc
	inc.lil hl
	dec bc
	jr LABEL_7985

LABEL_79AD:
	inc.lil hl
	ld.lil d, (hl)
	inc.lil d
	dec hl
LABEL_79B1:
	dec d
	jr z, LABEL_79A7
	ld.lil a, (hl)
	exx
	ld (hl), a
	inc hl
	exx
	jr LABEL_79B1

LABEL_79BB:
	ld.lil d, (hl)
	inc.lil hl
	dec bc
	ld a, ($D70F)
	cp d
	jr z, LABEL_79F6
	ld (iy+0), d
	inc iy
	dec e
	call z, LABEL_7A09
LABEL_79CD:
	ld a, b
	inc a
	jr nz, LABEL_79BB
	ld b, (ix+4)
	ld c, (ix+5)
	ld a, b
	or c
	ret z
	dec bc
	ld a, ($FFFF)
	inc a
	call.lil SwitchBank + romStart
	ld (ix+4), $00
	ld (ix+5), $00
	ld.lil hl, (CurrentBankAddress)
	push de
	ld de, $8000
	add.lil hl, de
	pop de

	jp LABEL_79BB

LABEL_79F0:
	inc.lil hl
	dec bc
	inc.lil hl
	dec bc
	jr LABEL_79CD

LABEL_79F6:
	inc.lil hl
	ld.lil d, (hl)
	inc d
	dec.lil hl
LABEL_79FA:
	dec d
	jr z, LABEL_79F0
	ld.lil a, (hl)
	ld (iy+0), a
	inc iy
	dec e
	call z, LABEL_7A09
	jr LABEL_79FA

LABEL_7A09:
	ld iy, $D857
	push bc
	exx
	ld b, $08
LABEL_7A11:
	ld a, (iy+0)
	ld (hl), a
	inc hl
	ld a, (iy+8)
	ld (hl), a
	inc hl
	ld a, (iy+16)
	ld (hl), a
	inc hl
	ld a, (iy+24)
	ld (hl), a
	inc hl
	inc iy
	djnz LABEL_7A11
	exx
	pop bc
	ld e, $20
	ld iy, $D857
	ret

LABEL_7A32:
	jp LABEL_5729

; Data from 7A35 to 7A35 (1 bytes)
	.db $C9

LABEL_7A36:
	xor a
	ld hl, $0860
	call LABEL_76E3
	ld a, $01
	ld hl, $0E60
	call LABEL_76E3
	ld a, $05
	ld hl, $1D60
	call LABEL_76E3
	ld a, $06
	ld hl, $22E0
	call LABEL_76E3
	ld a, $07
	ld hl, $2640
	call LABEL_76E3
	ld hl, $2E40
	ld a, $25
	call LABEL_76E3
	ret

LABEL_7A67:
	ld a, ($D781)
	and a
	ret nz
	ld hl, ($D82F)
	ld de, $0060
	add hl, de
	ld a, ($D83A)
	and a
	jr z, LABEL_7AC3
	ld a, ($D74D)
	cp $FF
	jr nz, LABEL_7A9A
	ld c, $FF
	ld a, ($DA29)
	and $03
	jr z, LABEL_7A8A
	inc c
LABEL_7A8A:
	ld a, ($DA6E)
	and $03
	jr z, LABEL_7A93
	ld c, $01
LABEL_7A93:
	ld a, c
	ld ($D74D), a
	cp $FF
	ret z
LABEL_7A9A:
	ld iy, $DA0E
	and a
	jr z, LABEL_7AA5
	ld iy, $DA53
LABEL_7AA5:
	ld de, ($D753)
	ld a, (iy+26)
	and $01
	jr z, LABEL_7AB3
	ld de, $0000
LABEL_7AB3:
	ld a, (iy+26)
	and $02
	jr z, LABEL_7ABD
	ld de, $00E0
LABEL_7ABD:
	ld ($D753), de
	jr LABEL_7B02

LABEL_7AC3:
	ld a, ($D780)
	and a
	jr z, LABEL_7ACF
	ld de, ($D77E)
	jr LABEL_7B02

LABEL_7ACF:
	ld a, ($D75D)
	cp $02
	jr nz, LABEL_7AFC
	push hl
	ld ix, $DA53
	ld a, ($DA17)
	and a
	jr z, LABEL_7AFB
	ld ix, $DA0E
	ld a, ($DA5C)
	and a
	jr z, LABEL_7AFB
	ld de, ($DA10)
	ld hl, ($DA55)
	add hl, de
	srl h
	rr l
	ex de, hl
	pop hl
	jr LABEL_7B02

LABEL_7AFB:
	pop hl
LABEL_7AFC:
	ld e, (ix+2)
	ld d, (ix+3)
LABEL_7B02:
	xor a
	sbc hl, de
	jr z, LABEL_7B58
	push af
	ex af, af'
	pop af
	jp p, LABEL_7B14
	ld de, $0000
	ex de, hl
	and a
	sbc hl, de
LABEL_7B14:
	push hl
	pop bc
	ld a, h
	and a
	jr nz, LABEL_7B1F
	ld a, l
	and $F8
	jr z, LABEL_7B22
LABEL_7B1F:
	ld bc, $0001
LABEL_7B22:
	ld bc, $0001
	ld hl, ($D82F)
	ex af, af'
	jr nc, LABEL_7B2E
	add hl, bc
	jr LABEL_7B31

LABEL_7B2E:
	and a
	sbc hl, bc
LABEL_7B31:
	bit 7, h
	jr z, LABEL_7B3B
	ld hl, $0000
	call LABEL_7B58
LABEL_7B3B:
	ld a, ($DA39)
	add a, $02
	sub $18
	add a, a
	add a, a
	add a, a
	ld c, a
	ld b, $00
	and a
	sbc hl, bc
	jr c, LABEL_7B53
	ld hl, $0000
	call LABEL_7B58
LABEL_7B53:
	add hl, bc
	ld ($D82F), hl
	ret

LABEL_7B58:
	ld a, $FF
	ld ($D782), a
	ret

LABEL_7B5E:
	ld ix, $DA0E
	call LABEL_7A67
	ld hl, ($D82F)
	ld de, $00E0
	and a
	sbc hl, de
	jr nc, LABEL_7B71
	add hl, de
LABEL_7B71:
	ld a, l
	ld ($D707), a
	ld a, ($D76D)
	and $02
	ret z
	ld hl, ($D82F)
	ld de, $00C0
	add hl, de
	ld a, l
	and $F8
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	add a, $C2
	ld h, a
	ex de, hl
	ld b, $02
	ld c, $18
	call LABEL_7C4B
	ld a, h
	add a, $38
	ld h, a
	call LABEL_7BBE
	ld hl, ($D82F)
	ld de, $0000
	add hl, de
	ld a, l
	and $F8
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	add a, $C2
	ld h, a
	ex de, hl
	ld b, $02
	ld c, $1C
	call LABEL_7C4B
	ld a, h
	add a, $38
	ld h, a
	call LABEL_7BBE
	call SetTilemapTrig
	ret

LABEL_7BBE:
	ex de, hl
	ld.lil bc, romStart + 4
	add.lil hl, bc
	ex.lil de, hl
	call LABEL_428C
	ex.lil de, hl
	ld bc, 56
	ldir.lil
	ret

; Data from 7C3A to 7C4A (17 bytes)
	.db $11, $00, $00, $87, $87, $87, $67, $2E, $00, $EB, $01, $80, $03, $CD, $18, $42
	.db $C9

LABEL_7C4B:
	ld a, ($D707)
	and $F8
	rra
	rra
	rra
	add a, c
	sub $1C
	jr nc, LABEL_7C5A
	add a, $1C
LABEL_7C5A:
	ld l, a
	ld h, $40
	mlt hl
	ld a, b
	and $1F
	add a, a
	or l
	ld l, a
	ret

LABEL_7C6A:
	ld a, ($D707)
	add a, c
	rra
	and $FC
	rra
	rra
	sub $1C
	jr nc, LABEL_7C79
	add a, $1C
LABEL_7C79:
	add a, a
	add a, a
	add a, a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, b
	rra
	and $FC
	rra
	rra
	and $1F
	add a, a
	or l
	ld l, a
	ret

; Data from 7C8E to 7C90 (3 bytes)
	.db $CF, $78, $57

LABEL_7C91:
	ld d, $00
	add iy, de
LABEL_7C95:
	call SetTilemapTrig
	ld ($D710), bc
	call LABEL_7C4B
LABEL_7C9C:
	ld a, ($D70B)
	add a, h
	ld h, a
	push hl
	call LABEL_428C
	pop hl
LABEL_7CA4:
	ld a, (iy+0)
	cp $23
	jp z, LABEL_7D51
	cp $5E
	jr z, LABEL_7CCA
	cp $40
	jr z, LABEL_7CEC
	cp $25
	jr z, LABEL_7CD6
	cp $2A
	jr z, LABEL_7CBE
	jr LABEL_7CF8

LABEL_7CBE:
	ld a, (iy+1)
	ld ($D716), a
	inc iy
	inc iy
	jr LABEL_7CA4

LABEL_7CCA:
	ld a, (iy+1)
	ld ($D70E), a
	inc iy
	inc iy
	jr LABEL_7CA4

LABEL_7CD6:
	ld a, ($D710)
	add a, (iy+2)
	ld c, a
	ld a, ($D711)
	add a, (iy+1)
	ld b, a
	ld ($D710), bc
	ld e, $03
	jr LABEL_7C91

LABEL_7CEC:
	inc iy
LABEL_7CEE:
	ld b, (iy+0)
	ld c, (iy+1)
	ld e, $02
	jr LABEL_7C91

LABEL_7CF8:
	exx
	ld e, a
	ld d, $00
	ld hl, DATA_7D52 - $20
	add hl, de
	ld a, ($D716)
	add a, (hl)
	ld e, a
	xor a
	adc a, $00
	ld d, a
	ld a, ($D70E)
	and a
	jr nz, LABEL_7D1F
	ld hl, $0073
	add hl, de
	ex de, hl
	ld hl, (VRAMPointer)
	ld.lil bc, SegaVRAM 
	add.lil hl, bc
	ex.lil de, hl
	ld a, l
	ld.lil (de), a
	inc.lil de
	ld a, h
	ld.lil (de), a
	inc.lil de
	jr LABEL_7D49

LABEL_7D1F:
	exx
	push hl
	call LABEL_428C
	pop hl
	exx
	ld hl, $009B
	add hl, de
	ex de, hl
	ld hl, (VRAMPointer)
	ld.lil bc, SegaVRAM
	add.lil hl, bc
	ex.lil de, hl
	ld a, l
	ld.lil (de), a
	inc.lil de
	ld a, h
	ld.lil (de), a
	inc.lil de
	exx
	push hl
	ld de, $0040
	add hl, de
	call LABEL_428C
	pop hl
	exx
	ld de, $0028
	add hl, de
	ex de, hl
	ld hl, (VRAMPointer)
	ld.lil bc, SegaVRAM
	add.lil hl, bc
	ex.lil de, hl
	ld a, l
	ld.lil (de), a
	inc.lil de
	ld a, h
	ld.lil (de), a
	inc.lil de
LABEL_7D49:
	exx
	inc hl
	inc hl
	ld (VRAMPointer), hl
	inc iy
	jp LABEL_7CA4

LABEL_7D51:
	ret

; Data from 7D52 to 7D8C (59 bytes)
DATA_7D52:
	.db $27, $24
	.fill 12, $FF
	.db $25, $FF, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $26, $FF, $FF, $FF
	.db $FF, $FF, $FF, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16
	.db $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23

LABEL_7D8D:
	ld a, (iy+0)
	ld ($D712), a
	ld l, (iy+2)
	ld h, (iy+3)
	ld ($D714), hl
	lea iy, iy+4
LABEL_7DA4:
	push iy
	ld hl, ($D714)
	ld a, l
	and $F8
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	add a, $C2
	ld h, a
	ld a, ($D712)
	and $F8
	add a, $08
	rrca
	rrca
	add a, l
	ld l, a
	jr nc, LABEL_7DC2
	inc h
LABEL_7DC2:
	push hl
	pop bc
LABEL_7DC4:
	ld a, (iy+0)
	cp $23
	jr z, LABEL_7DDE
	ld e, a
	ld d, $00
	ld hl, DATA_7D52 - $0020
	add hl, de
	ld a, (hl)
	add a, $73
	ld (bc), a
	inc bc
	xor a
	ld (bc), a
	inc bc
	inc iy
	jr LABEL_7DC4

LABEL_7DDE:
	pop iy
	ld bc, ($D82F)
	ld hl, ($D714)
	and a
	sbc hl, bc
	jr c, LABEL_7E0C
	ld de, $00C8
	ex de, hl
	and a
	sbc hl, de
	jr c, LABEL_7E0C
	ld hl, ($D714)
	ld de, ($D82F)
	and a
	sbc hl, de
	ld c, l
	ld a, ($D712)
	add a, $08
	ld b, a
	call LABEL_7C6A
	call LABEL_7C9C
LABEL_7E0C:
	ret

; Data from 7E0D to 7EA0 (148 bytes)
	.db $FD, $7E, $00, $32, $12, $D7, $FD, $6E, $02, $FD, $66, $03, $22, $14, $D7, $FD
	.db $23, $FD, $23, $FD, $23, $FD, $23, $FD, $E5, $2A, $14, $D7, $7D, $E6, $F8, $6F
	.db $29, $29, $7C, $C6, $C2, $67, $3A, $12, $D7, $E6, $F8, $C6, $08, $0F, $0F, $0F
	.db $85, $6F, $30, $01, $24, $E5, $C1, $FD, $7E, $00, $3E, $6E, $18, $0E, $FE, $23
	.db $28, $22, $5F, $16, $00, $21, $32, $7D, $19, $7E, $C6, $9B, $02, $C5, $F5, $79
	.db $C6, $20, $4F, $30, $01, $04, $F1, $FE, $6E, $28, $02, $C6, $9B, $02, $C1, $03
	.db $FD, $23, $18, $D3, $FD, $E1, $C9, $ED, $4B, $2F, $D8, $2A, $14, $D7, $A7, $ED
	.db $42, $38, $20, $11, $C8, $00, $EB, $A7, $ED, $52, $38, $17, $2A, $14, $D7, $ED
	.db $5B, $2F, $D8, $A7, $ED, $52, $4D, $3A, $12, $D7, $C6, $08, $47, $CD, $6A, $7C
	.db $CD, $9C, $7C, $C9

LABEL_7EA1:
	di
	xor a
	ld d, a

LABEL_7EA5:
	ld b, 192/8	; height of SMS screen (in tiles)
	push af
	ei
	halt
	ld l, a
	ld h, 256/2
	mlt hl
	add hl, hl

	di
	ld.lil de, ScreenPTR
	add.lil hl, de
_:	push.lil hl
	pop.lil de
	inc e
	push bc
	ld bc, 256
	ld.lil (hl), c
	ldir.lil
	ld bc, 256*7
	add.lil hl, bc
	pop bc
	djnz -_
	
	pop af
	inc a
	cp $09
	jr nz, LABEL_7EA5
	call.lil ClearVRAM
	ei
	ret

; Data from 7EDF to 7FEF (273 bytes)
DATA_7EDF:
	.db $00, $04, $08, $0C, $10, $14, $18, $1C

LABEL_7EE7:	
	ret
	
LABEL_7EE8:	
	ld ($DEF1), a
	ld ($DE54), a
	ld ($DEF4), a
	ld ($DEF3), a
	ld ($DEF2), a
	ld ($DEF0), a
	ld ($DE71), a
	inc a
	ld ($DEBB), a
	ld a, ($DE6D)
	ld ($DE6C), a
	xor a
	ld ($DE6D), a
	ld a, $FF
	ld ($DEE6), a
	ld ($DEE8), a
	ld hl, $DE7A
	ld de, $DE7A + 1
	ld bc, $0015
	ld (hl), $00
	ldir
	ld hl, $DCF2
	ld de, $DCF2 + 1
	ld bc, $001F
	ld (hl), $00
	ldir
	ld hl, $0064
	ld ($DEEC), hl
	add hl, hl
	ld ($DEEA), hl
	ret

DATA_7F38:
	.fill 72, $FF
	.fill 61, $00
	.db $0F
	.fill 32, $00
	.db $F0
	.fill 17, $00

; Data from 7FF0 to 7FFF (16 bytes)
	.db $54, $4D, $52, $20, $53, $45, $47, $41, $20, $20, $A6, $D7, $11, $50, $20, $4F

LABEL_8000:
	jp LABEL_8003

LABEL_8003:
	ld l, (ix+47)
	ld h, $00
	add hl, hl
	ld de, DATA_8054
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld bc, $00C0
	add iy, bc
	ld a, (ix+43)
	sub $03
	ld b, a
	ld d, $00
LABEL_801E:
	push bc
	ld b, $0E
LABEL_8021:
	ld a, (hl)
	ld (iy+4), a
	ld (iy+5), $00
	inc iy
	inc iy
	inc hl
	djnz LABEL_8021
	push hl
	ld b, $0E
LABEL_8033:
	dec hl
	push de
	push hl
	ld e, (hl)
	ld hl, DATA_8054 - 2
	add hl, de
	ld a, (hl)
	pop hl
	pop de
	ld (iy+4), a
	ld (iy+5), $00
	inc iy
	inc iy
	djnz LABEL_8033
	pop hl
	ld e, $08
	add iy, de
	pop bc
	djnz LABEL_801E
	ret

; Pointer Table from 8054 to 8095 (33 entries, indexed by $DA3D)
DATA_8054:
	.dw DATA_80C5, DATA_8277, DATA_8429, DATA_85DB, DATA_878D, DATA_88EB, DATA_8A49, DATA_8BA7
	.dw DATA_8D05, DATA_8F0B, DATA_9111, DATA_9317, DATA_951D, DATA_9723, DATA_9929, DATA_9B2F
	.dw DATA_9D35, DATA_9EE7, DATA_A099, DATA_A24B, DATA_A3FD, DATA_A5AF, DATA_A761, DATA_A913
	.dw DATA_AAC5, DATA_AC77, DATA_AE29, DATA_AFCD, DATA_B17F, DATA_B385, DATA_B58B, DATA_B6E9
	.dw DATA_B847

; Data from 8096 to 80C4 (47 bytes)
	.db $44, $46, $45, $47, $49, $48, $4B, $4A, $4C, $4E, $4D, $4F, $51, $50, $53, $52
	.db $55, $54, $57, $56, $59, $58, $5B, $5A, $5C, $5D, $5E, $60, $5F, $61, $6D, $6C
	.db $65, $64, $68, $69, $66, $67, $6B, $6A, $63, $62, $6E, $6F, $70, $71, $72

; 1st entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 80C5 to 8276 (434 bytes)
DATA_80C5:
	.db $45, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $44, $4A, $70
	.db $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $4A, $71, $4D, $4C
	.db $4C, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4A, $70, $50, $4F, $4F, $51
	.db $70, $50, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48, $47, $4E, $70, $4D, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $72, $72
	.db $4A, $70, $52, $53, $70, $52, $5C, $5C, $5C, $53, $70, $52, $44, $44, $51, $70
	.db $52, $53, $70, $50, $4F, $4F, $4F, $51, $70, $52, $72, $72, $72, $70, $52, $53
	.db $70, $70, $70, $70, $70, $70, $70, $52, $47, $47, $4E, $70, $52, $55, $4C, $4C
	.db $4E, $72, $4D, $4C, $4C, $54, $72, $72, $4A, $70, $50, $4F, $4F, $4F, $51, $72
	.db $50, $4F, $4F, $4F, $72, $72, $4A, $70
	.fill 12, $72
	.db $4A, $70, $4D, $4C, $4C, $4C, $4E, $72, $58, $47, $5D, $5E, $72, $72, $4A, $70
	.db $52, $57, $4F, $4F, $51, $72, $4B, $72, $72, $72, $72, $72, $4A, $70, $52, $53
	.db $72, $72, $72, $72, $4B, $72, $72, $72, $72, $72, $4A, $70, $52, $53, $72, $4D
	.db $4E, $72, $4B, $72, $72, $72, $44, $44, $51, $70, $50, $51, $72, $52, $53, $72
	.db $5A, $44, $44, $44, $72, $72, $72, $70, $72, $72, $72, $52, $53, $72, $72, $72
	.db $72, $72, $47, $47, $4E, $70, $4D, $4C, $4C, $54, $55, $4C, $4C, $4E, $72, $4D
	.db $72, $72, $4A, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $51, $72, $52, $72, $72
	.db $4A, $70, $70, $70, $70, $70, $70, $70, $72, $72, $72, $52, $72, $72, $4A, $70
	.db $4D, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $54, $45, $44, $51, $70, $50, $4F
	.db $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 12, $70
	.db $72, $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4A
	.db $70, $52, $5C, $5C, $53, $70, $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $52
	.db $5C, $5C, $53, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $71, $52, $5C, $5C
	.db $53, $70, $52, $53, $70, $4D, $4C, $4C, $54, $4A, $70, $50, $4F, $4F, $51, $70
	.db $50, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 2nd entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 8277 to 8428 (434 bytes)
DATA_8277:
	.db $44, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $44, $72, $72
	.db $72, $72, $72, $72, $72, $52, $53, $70, $70, $70, $70, $70, $61, $4C, $4C, $4C
	.db $4C, $4E, $72, $52, $53, $70, $4D, $4C, $4C, $4C, $62, $4F, $4F, $4F, $4F, $51
	.db $72, $50, $51, $70, $50, $4F, $4F, $56, $4A, $71
	.fill 11, $70
	.db $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4E, $70, $52, $4A
	.db $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $52, $53, $70, $52, $4A, $70, $52
	.db $53, $70, $70, $70, $70, $70, $70, $52, $53, $70, $50, $4A, $70, $52, $53, $70
	.db $4D, $4C, $4C, $4E, $72, $52, $53, $70, $70, $4A, $70, $50, $51, $70, $50, $4F
	.db $56, $53, $72, $52, $55, $4C, $4C, $4A, $70, $70, $70, $70, $70, $70, $52, $53
	.db $72, $50, $4F, $4F, $4F, $63, $4C, $4C, $4C, $4C, $4E, $70, $52, $53, $72, $72
	.db $72, $72, $72, $62, $4F, $4F, $4F, $4F, $51, $70, $52, $53, $72, $58, $47, $5D
	.db $5E, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A
	.db $70, $4D, $4C, $4C, $4E, $70, $50, $51, $72, $4B, $72, $72, $72, $4A, $70, $50
	.db $4F, $56, $53, $70, $72, $72, $72, $4B, $72, $72, $72, $4A, $70, $70, $70, $52
	.db $53, $70, $4D, $4E, $72, $5A, $44, $44, $44, $48, $47, $4E, $70, $52, $53, $70
	.db $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $53, $70, $52, $55
	.db $4C, $4E, $72, $4D, $4C, $72, $72, $4A, $70, $50, $51, $70, $50, $4F, $4F, $51
	.db $72, $52, $5C, $72, $72, $4A
	.fill 9, $70
	.db $52, $5C, $72, $72, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $5C
	.db $44, $44, $51, $70, $50, $4F, $4F, $56, $57, $4F, $51, $70, $50, $4F, $72, $72
	.db $72, $70, $70, $70, $70, $52, $53, $70, $70, $70, $72, $72, $61, $4C, $4E, $70
	.db $4D, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $62, $4F, $51, $70, $52, $53
	.db $70, $50, $51, $70, $50, $4F, $4F, $56, $4A, $71, $70, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $54, $53, $70, $4D, $4C, $4C
	.db $4C, $4E, $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $51
	.db $70, $50, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 3rd entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 8429 to 85DA (434 bytes)
DATA_8429:
	.db $45
	.fill 9, $44
	.db $60, $5F, $44, $44, $4A
	.fill 9, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $53
	.db $70, $4D, $4A, $71, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $51, $70, $52
	.db $4A, $70, $52, $53
	.fill 9, $70
	.db $52, $4A, $70, $50, $51, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $52, $4A
	.db $70, $70, $70, $70, $52, $53, $70, $52, $5C, $5C, $53, $70, $52, $63, $4C, $4C
	.db $4E, $70, $52, $53, $70, $50, $4F, $4F, $51, $70, $50, $6A, $4F, $4F, $51, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $70, $72, $70, $70, $70, $70, $52, $55
	.db $4C, $4E, $72, $4D, $4C, $4C, $4C, $68, $70, $4D, $4E, $70, $50, $4F, $4F, $51
	.db $72, $50, $4F, $4F, $4F, $4A, $70, $52, $53, $70, $70, $70, $72, $72, $72, $72
	.db $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $72, $58, $47, $5D
	.db $5E, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $72, $4B, $72, $72, $72, $4A
	.db $70, $70, $70, $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A, $70, $4D
	.db $4E, $70, $4D, $4C, $54, $53, $72, $4B, $72, $72, $72, $4A, $70, $52, $53, $70
	.db $50, $4F, $4F, $51, $72, $5A, $44, $44, $44, $4A, $70, $52, $53, $70, $70, $70
	.db $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4C
	.db $4C, $4C, $4E, $72, $4D, $4A, $70, $50, $4F, $4F, $51, $70, $52, $57, $4F, $4F
	.db $51, $72, $52, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70
	.db $52, $63, $4C, $4E, $70, $4D, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $54, $62
	.db $4F, $51, $70, $52, $53, $70, $50, $51, $70, $50, $4F, $4F, $4F, $4A, $71, $70
	.db $70, $52, $53, $70, $70, $70, $70, $70, $70, $70, $72, $4A, $70, $4D, $4C, $54
	.db $53, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4A, $70, $50, $4F, $4F, $51, $70
	.db $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $70, $70, $70, $70, $70, $52, $53
	.db $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $70, $4D
	.db $4C, $4C, $54, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F
	.db $4F, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $48
	.db $47, $47, $47, $47, $47, $47, $64, $65, $47, $47, $47, $47, $47

; 4th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 85DB to 878C (434 bytes)
DATA_85DB:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4A, $71
	.db $52, $53, $70, $52, $5C, $5C, $53, $70, $52, $57, $4F, $4F, $4A, $70, $52, $53
	.db $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $70, $4A, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $52, $53, $70, $4D, $4A, $70, $52, $55, $4C, $4E, $70, $4D
	.db $4E, $70, $52, $53, $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $70
	.db $50, $51, $70, $52, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70
	.db $70, $52, $48, $47, $4E, $70, $4D, $4C, $4C, $54, $55, $4C, $4C, $4E, $72, $52
	.db $72, $72, $4A, $70, $50, $4F, $4F, $56, $57, $4F, $4F, $51, $72, $50, $72, $72
	.db $4A, $70, $70, $70, $70, $52, $53, $72, $72, $72, $72, $72, $44, $44, $51, $72
	.db $4D, $4E, $70, $52, $53, $72, $58, $47, $5D, $5E, $72, $72, $72, $72, $52, $53
	.db $70, $50, $51, $72, $4B, $72, $72, $72, $4C, $4C, $4C, $4C, $54, $53, $70, $72
	.db $72, $72, $4B, $72, $72, $72, $4F, $4F, $4F, $4F, $56, $53, $70, $4D, $4E, $72
	.db $4B, $72, $72, $72, $72, $72, $72, $72, $52, $53, $70, $52, $53, $72, $5A, $44
	.db $44, $44, $47, $47, $4E, $72, $50, $51, $70, $52, $53, $72, $72, $72, $72, $72
	.db $72, $72, $4A, $70, $70, $70, $70, $52, $55, $4C, $4C, $4E, $72, $4D, $72, $72
	.db $4A, $70, $4D, $4E, $70, $50, $4F, $4F, $4F, $51, $72, $52, $72, $72, $4A, $70
	.db $52, $53, $70, $70, $70, $70, $72, $72, $72, $52, $72, $72, $4A, $70, $52, $55
	.db $4C, $4C, $4E, $70, $4D, $4E, $72, $52, $45, $44, $51, $70, $50, $4F, $4F, $4F
	.db $51, $70, $52, $53, $72, $50, $4A
	.fill 9, $70
	.db $52, $53, $72, $72, $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4E, $70, $52, $55
	.db $4C, $4C, $4A, $70, $52, $57, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F, $4F
	.db $4A, $70, $52, $53, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $4A, $71
	.db $52, $53, $70, $4D, $4C, $54, $55, $4C, $4C, $4E, $70, $4D, $4A, $70, $50, $51
	.db $70, $50, $4F, $4F, $4F, $4F, $4F, $51, $70, $52, $4A
	.fill 12, $70
	.db $52, $48
	.fill 12, $47
	.db $64

; 5th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 878D to 88EA (350 bytes)
DATA_878D:
	.db $45, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $44, $4A, $70
	.db $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $4A, $71, $4D, $4C
	.db $4C, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4A, $70, $50, $4F, $4F, $51
	.db $70, $50, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48, $47, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $72, $72
	.db $4A, $70, $52, $53, $70, $52, $53, $70, $52, $53, $70, $52, $44, $44, $51, $70
	.db $52, $53, $70, $50, $51, $70, $50, $51, $70, $52, $72, $72, $72, $70, $52, $53
	.db $70, $70, $70, $70, $70, $70, $70, $52, $61, $4C, $4E, $70, $52, $55, $4C, $4C
	.db $4E, $72, $4D, $4C, $4C, $54, $62, $4F, $51, $70, $50, $4F, $4F, $4F, $51, $72
	.db $50, $4F, $4F, $4F, $4A, $70, $70, $70
	.fill 10, $72
	.db $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $72, $58, $47, $5D, $5E, $4A, $70
	.db $50, $4F, $56, $57, $4F, $4F, $51, $72, $4B, $72, $72, $72, $4A, $70, $70, $70
	.db $52, $53, $72, $72, $72, $72, $4B, $72, $72, $72, $63, $4C, $4E, $70, $52, $53
	.db $72, $4D, $4E, $72, $4B, $72, $72, $72, $6A, $4F, $51, $70, $50, $51, $72, $52
	.db $53, $72, $5A, $44, $44, $44, $72, $72, $72, $70, $72, $72, $72, $52, $53, $72
	.db $72, $72, $72, $72, $61, $4C, $4E, $70, $4D, $4C, $4C, $54, $55, $4C, $4C, $4E
	.db $72, $4D, $62, $4F, $51, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $51, $72, $52
	.db $4A
	.fill 9, $70
	.db $72, $72, $72, $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C
	.db $4C, $54, $4A, $71, $50, $4F, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $4F
	.db $4A
	.fill 12, $70
	.db $72, $48
	.fill 13, $47

; 6th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 88EB to 8A48 (350 bytes)
DATA_88EB:
	.db $44, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $60, $72, $72
	.db $72, $72, $72, $72, $72, $52, $53, $70, $70, $70, $70, $52, $61, $4C, $4C, $4C
	.db $4C, $4E, $72, $52, $53, $70, $4D, $4E, $70, $52, $62, $4F, $4F, $4F, $4F, $51
	.db $72, $50, $51, $70, $52, $53, $70, $52, $4A, $71, $70, $70, $70, $70, $70, $70
	.db $70, $70, $52, $53, $70, $50, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70
	.db $52, $53, $70, $70, $4A, $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $52, $53
	.db $70, $4D, $4A, $70, $52, $53, $70, $70, $70, $70, $70, $70, $52, $53, $70, $50
	.db $4A, $70, $52, $53, $70, $4D, $4C, $4C, $4E, $72, $52, $53, $70, $70, $4A, $70
	.db $50, $51, $70, $50, $4F, $56, $53, $72, $52, $55, $4C, $4C, $4A, $70, $70, $70
	.db $70, $70, $70, $52, $53, $72, $50, $4F, $4F, $4F, $63, $4C, $4C, $4C, $4C, $4E
	.db $70, $52, $53, $72, $72, $72, $72, $72, $62, $4F, $4F, $4F, $4F, $51, $70, $52
	.db $53, $72, $58, $47, $5D, $5E, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $72
	.db $4B, $72, $72, $72, $4A, $70, $4D, $4C, $4C, $4E, $70, $50, $51, $72, $4B, $72
	.db $72, $72, $4A, $70, $50, $4F, $56, $53, $70, $72, $72, $72, $4B, $72, $72, $72
	.db $4A, $71, $70, $70, $52, $53, $70, $4D, $4E, $72, $5A, $44, $44, $44, $48, $47
	.db $4E, $70, $52, $53, $70, $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70
	.db $52, $53, $70, $52, $55, $4C, $4E, $72, $4D, $4C, $72, $72, $4A, $70, $50, $51
	.db $70, $50, $4F, $4F, $51, $72, $50, $4F, $72, $72, $4A
	.fill 11, $70
	.db $72, $72, $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $44, $44
	.db $51, $70, $52, $53, $70, $50, $4F, $4F, $51, $70, $50, $4F, $72, $72, $72, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $72, $72, $47, $47, $47, $47, $64, $65
	.db $47, $47, $47, $47, $47, $47, $47, $47

; 7th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 8A49 to 8BA6 (350 bytes)
DATA_8A49:
	.db $45
	.fill 9, $44
	.db $60, $5F, $44, $44, $4A
	.fill 9, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $53
	.db $70, $4D, $4A, $71, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $51, $70, $52
	.db $4A, $70, $52, $53
	.fill 9, $70
	.db $52, $4A, $70, $50, $51, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $52, $4A
	.db $70, $70, $70, $70, $52, $53, $70, $52, $5C, $5C, $53, $70, $52, $63, $4C, $4C
	.db $4E, $70, $52, $53, $70, $50, $4F, $4F, $51, $70, $50, $6A, $4F, $4F, $51, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $70, $72, $70, $70, $70, $70, $52, $55
	.db $4C, $4E, $72, $4D, $4C, $4C, $4C, $68, $70, $4D, $4E, $70, $50, $4F, $4F, $51
	.db $72, $50, $4F, $4F, $4F, $4A, $70, $52, $53, $70, $70, $70, $72, $72, $72, $72
	.db $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $72, $58, $47, $5D
	.db $5E, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $72, $4B, $72, $72, $72, $4A
	.db $70, $70, $70, $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A, $70, $4D
	.db $4E, $70, $4D, $4C, $54, $53, $72, $4B, $72, $72, $72, $4A, $70, $52, $53, $70
	.db $50, $4F, $4F, $51, $72, $5A, $44, $44, $44, $4A, $70, $52, $53, $70, $70, $70
	.db $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4C
	.db $4C, $4C, $4E, $72, $4D, $4A, $70, $50, $4F, $4F, $51, $70, $52, $57, $4F, $4F
	.db $51, $72, $50, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $72
	.db $72, $4A, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4A
	.db $71, $50, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F, $4F, $4A, $70, $70
	.db $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $48, $47, $47, $47, $47
	.db $47, $47, $64, $65, $47, $47, $47, $47, $47

; 8th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 8BA7 to 8D04 (350 bytes)
DATA_8BA7:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4A, $71
	.db $52, $53, $70, $52, $5C, $5C, $53, $70, $52, $57, $4F, $4F, $4A, $70, $52, $53
	.db $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $70, $4A, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $52, $53, $70, $4D, $4A, $70, $52, $55, $4C, $4E, $70, $4D
	.db $4E, $70, $52, $53, $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $70
	.db $50, $51, $70, $52, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70
	.db $70, $52, $48, $47, $4E, $70, $4D, $4C, $4C, $54, $55, $4C, $4C, $4E, $72, $52
	.db $72, $72, $4A, $70, $50, $4F, $4F, $56, $57, $4F, $4F, $51, $72, $50, $72, $72
	.db $4A, $70, $70, $70, $70, $52, $53, $72, $72, $72, $72, $72, $44, $44, $51, $72
	.db $4D, $4E, $70, $52, $53, $72, $58, $47, $5D, $5E, $72, $72, $72, $72, $52, $53
	.db $70, $50, $51, $72, $4B, $72, $72, $72, $4C, $4C, $4C, $4C, $54, $53, $70, $72
	.db $72, $72, $4B, $72, $72, $72, $4F, $4F, $4F, $4F, $4F, $51, $70, $4D, $4E, $72
	.db $4B, $72, $72, $72, $72, $70, $70, $70, $70, $70, $70, $52, $53, $72, $5A, $44
	.db $44, $44, $68, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $72, $72, $72, $72, $72
	.db $4A, $70, $52, $5C, $5C, $53, $70, $52, $55, $4C, $4C, $4E, $72, $4D, $4A, $70
	.db $50, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $51, $72, $52, $4A
	.fill 9, $70
	.db $72, $72, $72, $52, $4A, $71, $4D, $4C, $4C, $4E, $70, $4D, $4E, $70, $4D, $4E
	.db $72, $52, $4A, $70, $50, $4F, $4F, $51, $70, $50, $51, $70, $52, $53, $72, $50
	.db $4A
	.fill 9, $70
	.db $52, $53, $72, $72, $48
	.fill 9, $47
	.db $64, $65, $47, $47

; 9th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 8D05 to 8F0A (518 bytes)
DATA_8D05:
	.db $45, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $44, $4A, $70
	.db $70, $70, $70, $70, $70, $52, $53, $71, $70, $70, $70, $70, $4A, $70, $4D, $4C
	.db $4C, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4A, $70, $50, $4F, $4F, $51
	.db $70, $52, $53, $70, $50, $4F, $4F, $4F, $4A, $70, $70, $70, $70, $70, $70, $52
	.db $53, $70, $70, $70, $70, $70, $48, $47, $4E, $70, $4D, $4E, $70, $52, $55, $4C
	.db $4C, $4E, $70, $4D, $72, $72, $4A, $70, $52, $53, $70, $52, $5C, $5C, $5C, $53
	.db $70, $52, $44, $44, $51, $70, $52, $53, $70, $50, $4F, $4F, $4F, $51, $70, $52
	.db $72, $72, $72, $70, $52, $53, $70, $70, $70, $70, $70, $70, $70, $52, $47, $47
	.db $4E, $70, $52, $55, $4C, $4C, $4E, $72, $4D, $4C, $4C, $54, $72, $72, $4A, $70
	.db $52, $57, $4F, $56, $53, $72, $50, $4F, $4F, $4F, $72, $72, $4A, $70, $52, $53
	.db $72, $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $55, $4C, $54
	.db $53, $72, $58, $47, $5D, $5E, $72, $72, $4A, $70, $52, $57, $4F, $4F, $51, $72
	.db $4B, $72, $72, $72, $72, $72, $4A, $70, $52, $53, $72, $72, $72, $72, $4B, $72
	.db $72, $72, $72, $72, $4A, $70, $52, $53, $72, $4D, $4E, $72, $4B, $72, $72, $72
	.db $44, $44, $51, $70, $50, $51, $72, $52, $53, $72, $5A, $44, $44, $44, $72, $72
	.db $72, $70, $72, $72, $72, $52, $53, $72, $72, $72, $72, $72, $47, $47, $4E, $70
	.db $4D, $4C, $4C, $54, $55, $4C, $4C, $4E, $72, $4D, $72, $72, $4A, $70, $50, $4F
	.db $4F, $4F, $4F, $4F, $4F, $51, $72, $52, $72, $72, $4A, $70, $70, $70, $70, $70
	.db $70, $70, $72, $72, $72, $52, $72, $72, $4A, $70, $4D, $4C, $4C, $4C, $4E, $70
	.db $4D, $4C, $4C, $54, $45, $44, $51, $70, $50, $4F, $4F, $4F, $51, $70, $50, $4F
	.db $4F, $4F, $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4A, $70
	.db $52, $5C, $5C, $53, $70, $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $52, $5C
	.db $5C, $53, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $70, $52, $5C, $5C, $53
	.db $70, $52, $53, $70, $4D, $4C, $4C, $54, $69, $70, $50, $4F, $4F, $51, $70, $52
	.db $53, $70, $50, $4F, $4F, $4F, $72, $70, $70, $70, $70, $70, $70, $52, $53, $70
	.db $70, $70, $70, $72, $68, $70, $4D, $4E, $70, $4D, $4C, $54, $53, $70, $4D, $4E
	.db $70, $4D, $4A, $70, $52, $53, $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $52
	.db $4A, $71, $52, $53, $70, $70, $70, $70, $70, $70, $52, $53, $70, $52, $4A, $70
	.db $52, $53, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $70, $52, $69, $70, $52, $53
	.db $70, $50, $4F, $4F, $51, $70, $50, $51, $70, $50, $72, $70, $52, $53
	.fill 10, $70
	.db $47, $47, $64, $65
	.fill 10, $47

; 10th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 8F0B to 9110 (518 bytes)
DATA_8F0B:
	.db $45
	.fill 12, $44
	.db $60, $4A
	.fill 12, $70
	.db $52, $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $52, $4A
	.db $71, $52, $5C, $5C, $53, $70, $52, $5C, $5C, $5C, $53, $70, $52, $4A, $70, $50
	.db $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $51, $70, $50, $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4E, $70, $4D, $4C, $4C, $4C, $4A, $70
	.db $50, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F, $56, $4A, $70, $70, $70
	.db $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $4C, $4E
	.db $70, $52, $55, $4C, $4C, $4E, $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $52
	.db $57, $4F, $4F, $51, $70, $50, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $72
	.db $72, $72, $72, $72, $48, $47, $47, $47, $47, $4E, $70, $52, $53, $72, $58, $47
	.db $5D, $5E, $44, $44, $44, $44, $44, $51, $70, $50, $51, $72, $4B
	.fill 9, $72
	.db $70, $72, $72, $72, $4B, $72, $72, $72, $47, $47, $47, $47, $47, $4E, $70, $4D
	.db $4E, $72, $4B, $72, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $50, $51, $72
	.db $5A, $44, $44, $44, $72, $72, $72, $72, $72, $4A, $70
	.fill 12, $72
	.db $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4C, $72, $72, $45, $44, $44, $51, $70
	.db $52, $53, $70, $50, $4F, $4F, $56, $72, $72, $4A, $70, $70, $70, $70, $52, $53
	.db $70, $70, $70, $70, $52, $72, $72, $4A, $70, $4D, $4C, $4C, $54, $55, $4C, $4C
	.db $4E, $70, $52, $44, $44, $51, $70, $50, $4F, $4F, $56, $57, $4F, $4F, $51, $70
	.db $50, $72, $72, $72, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $47
	.db $47, $47, $47, $47, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $45, $44, $44
	.db $44, $44, $51, $70, $50, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4A, $70
	.db $50, $4F, $56, $53, $70, $52, $57, $4F, $4F, $51, $70, $52, $4A, $71, $70, $70
	.db $52, $53, $70, $52, $53, $70, $70, $70, $70, $52, $48, $47, $4E, $70, $52, $53
	.db $70, $52, $53, $70, $4D, $4C, $4C, $54, $45, $44, $51, $70, $50, $51, $70, $50
	.db $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 9, $70
	.db $72, $72, $72, $72, $4A, $70, $4D, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4C, $4C
	.db $4C, $4C, $4A, $70, $50, $4F, $51, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $4F
	.db $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 11th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9111 to 9316 (518 bytes)
DATA_9111:
	.db $45
	.fill 9, $44
	.db $60, $5F, $44, $44, $4A
	.fill 9, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $53
	.db $70, $4D, $4A, $71, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $51, $70, $52
	.db $4A, $70, $52, $53
	.fill 9, $70
	.db $52, $4A, $70, $50, $51, $70, $4D, $4E, $70, $4D, $4C, $4C, $4C, $4C, $54, $4A
	.db $70, $70, $70, $70, $52, $53, $70, $52, $5C, $5C, $5C, $5C, $5C, $63, $4C, $4C
	.db $4C, $4C, $54, $53, $70, $50, $4F, $4F, $4F, $4F, $4F, $6A, $4F, $4F, $4F, $4F
	.db $56, $53, $70, $70, $70, $70, $70, $70, $70, $72, $70, $70, $70, $70, $52, $55
	.db $4C, $4E, $72, $4D, $4C, $4C, $4C, $68, $70, $4D, $4E, $70, $50, $4F, $4F, $51
	.db $72, $50, $4F, $4F, $4F, $4A, $70, $52, $53, $70, $70, $70, $72, $72, $72, $72
	.db $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $72, $58, $47, $5D
	.db $5E, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $72, $4B, $72, $72, $72, $4A
	.db $70, $70, $70, $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A, $70, $4D
	.db $4E, $70, $4D, $4C, $54, $53, $72, $4B, $72, $72, $72, $4A, $70, $52, $53, $70
	.db $50, $4F, $4F, $51, $72, $5A, $44, $44, $44, $4A, $70, $52, $53, $70, $70, $70
	.db $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4C
	.db $4C, $4C, $4E, $72, $4D, $4A, $70, $50, $4F, $4F, $51, $70, $52, $57, $4F, $4F
	.db $51, $72, $52, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70
	.db $52, $63, $4C, $4E, $70, $4D, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $54, $62
	.db $4F, $51, $70, $52, $53, $70, $50, $51, $70, $50, $4F, $4F, $4F, $4A, $70, $70
	.db $70, $52, $53, $70, $70, $70, $70, $70, $70, $70, $70, $4A, $70, $4D, $4C, $54
	.db $53, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4A, $70, $50, $4F, $4F, $51, $70
	.db $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $70, $70, $70, $70, $70, $52, $53
	.db $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $70, $4D
	.db $4C, $4C, $54, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F
	.db $4F, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $72, $4A
	.db $70, $4D, $4C, $4C, $4E, $70, $52, $55, $4C, $4C, $4E, $70, $4D, $4A, $70, $52
	.db $5C, $5C, $53, $70, $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $52, $5C, $5C
	.db $53, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $71, $52, $5C, $5C, $53, $70
	.db $52, $53, $70, $4D, $4C, $4C, $54, $4A, $70, $50, $4F, $4F, $51, $70, $50, $51
	.db $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 12th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9317 to 951C (518 bytes)
DATA_9317:
	.db $45, $44, $44, $44, $44, $46, $72, $72, $45, $44, $44, $44, $44, $44, $4A, $70
	.db $70, $70, $70, $4B, $72, $72, $4A, $70, $70, $70, $70, $70, $4A, $70, $4D, $4E
	.db $70, $4B, $72, $72, $4A, $70, $4D, $4C, $4C, $4C, $4A, $71, $52, $53, $70, $4B
	.db $72, $72, $4A, $70, $52, $57, $4F, $4F, $4A, $70, $52, $53, $70, $50, $44, $44
	.db $51, $70, $52, $53, $70, $70, $4A, $70, $52, $53, $70, $70, $70, $70, $70, $70
	.db $52, $53, $70, $4D, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $70, $52, $53
	.db $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $50, $51, $70, $52
	.db $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $48, $47
	.db $4E, $70, $4D, $4C, $4C, $54, $53, $72, $4D, $4C, $4C, $54, $72, $72, $4A, $70
	.db $50, $4F, $4F, $56, $53, $72, $50, $4F, $4F, $4F, $72, $72, $4A, $70, $70, $70
	.db $70, $52, $53, $72, $72, $72, $72, $72, $44, $44, $51, $72, $4D, $4E, $70, $52
	.db $53, $72, $58, $47, $5D, $5E, $72, $72, $72, $72, $52, $53, $70, $50, $51, $72
	.db $4B, $72, $72, $72, $4C, $4C, $4C, $4C, $54, $53, $70, $72, $72, $72, $4B, $72
	.db $72, $72, $4F, $4F, $4F, $4F, $56, $53, $70, $4D, $4E, $72, $4B, $72, $72, $72
	.db $72, $72, $72, $72, $52, $53, $70, $52, $53, $72, $5A, $44, $44, $44, $47, $47
	.db $4E, $72, $50, $51, $70, $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70
	.db $70, $70, $70, $52, $55, $4C, $4C, $4E, $72, $4D, $72, $72, $4A, $70, $4D, $4E
	.db $70, $50, $4F, $4F, $4F, $51, $72, $52, $72, $72, $4A, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $70, $52, $72, $72, $4A, $70, $52, $55, $4C, $4C, $4E, $70
	.db $4D, $4E, $70, $52, $45, $44, $51, $70, $50, $4F, $4F, $4F, $51, $70, $52, $53
	.db $70, $50, $4A
	.fill 9, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $55
	.db $4C, $4C, $4A, $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $4F
	.db $4A, $70, $52, $53
	.fill 10, $70
	.db $4A, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4A, $70
	.db $50, $51, $70, $50, $4F, $56, $57, $4F, $4F, $4F, $4F, $4F, $4A, $70, $70, $70
	.db $70, $70, $70, $52, $53, $70, $70, $70, $72, $72, $4A, $70, $4D, $4C, $4C, $4E
	.db $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4A, $70, $52, $5C, $5C, $53, $70, $52
	.db $53, $70, $50, $4F, $4F, $4F, $4A, $70, $52, $5C, $5C, $53, $70, $52, $53, $70
	.db $70, $70, $70, $70, $4A, $71, $52, $5C, $5C, $53, $70, $52, $55, $4C, $4C, $4C
	.db $4E, $72, $4A, $70, $50, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4F, $51, $72
	.db $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 13th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 951D to 9722 (518 bytes)
DATA_951D:
	.db $72, $45
	.fill 12, $44
	.db $72, $4A, $70, $70, $71
	.fill 9, $70
	.db $72, $4A, $72, $4D, $47, $4E, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $44, $51
	.db $72, $4B, $72, $4A, $70, $52, $5C, $5C, $5C, $5C, $5C, $5C, $72, $72, $72, $4B
	.db $72, $4A, $70, $50, $4F, $4F, $56, $57, $4F, $4F, $47, $47, $47, $49, $72, $4A
	.db $70, $70, $70, $70, $52, $53, $70, $70, $72, $72, $72, $72, $72, $4A, $70, $4D
	.db $4E, $70, $52, $53, $70, $4D, $72, $72, $45, $44, $44, $51, $70, $52, $53, $70
	.db $50, $51, $70, $52, $72, $72, $4A, $70, $70, $70, $70, $52, $53, $70, $70, $70
	.db $70, $52, $72, $72, $4A, $70, $4D, $4C, $4C, $54, $55, $4C, $4C, $4E, $70, $52
	.db $45, $44, $51, $70, $50, $4F, $4F, $56, $57, $4F, $4F, $51, $70, $50, $4A, $70
	.db $70, $70, $70, $70, $70, $52, $53, $72, $72, $72, $72, $72, $4A, $70, $4D, $4C
	.db $4C, $4E, $70, $52, $53, $72, $58, $47, $5D, $5E, $4A, $70, $50, $4F, $56, $53
	.db $70, $50, $51, $72, $4B, $72, $72, $72, $4A, $70, $70, $70, $52, $53, $70, $70
	.db $70, $72, $4B, $72, $72, $72, $48, $47, $4E, $70, $52, $53, $70, $4D, $4E, $72
	.db $4B, $72, $72, $72, $72, $72, $4A, $70, $50, $51, $70, $52, $53, $72, $5A, $44
	.db $44, $44, $72, $72, $4A, $70, $70, $70, $70, $52, $53, $72, $72, $72, $72, $72
	.db $72, $72, $4A, $70, $4D, $4E, $70, $52, $55, $4C, $4C, $4E, $70, $4D, $72, $72
	.db $4A, $70, $52, $53, $70, $50, $4F, $4F, $4F, $51, $70, $52, $72, $72, $4A, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $70, $52, $72, $72, $4A, $70, $52, $55
	.db $4C, $4C, $4E, $70, $4D, $4C, $4C, $54, $45, $44, $51, $70, $50, $4F, $4F, $4F
	.db $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4A, $70
	.db $52, $5C, $5C, $5C, $5C, $5C, $5C, $5C, $53, $70, $52, $5C, $4A, $70, $50, $4F
	.db $4F, $4F, $56, $57, $4F, $4F, $51, $70, $52, $5C, $4A, $70, $70, $70, $70, $70
	.db $52, $53, $70, $70, $70, $70, $52, $5C, $48, $47, $47, $47, $4E, $70, $52, $53
	.db $70, $4D, $4E, $72, $52, $5C, $44, $44, $44, $46, $4A, $70, $50, $51, $70, $52
	.db $53, $72, $50, $4F, $72, $72, $72, $4B, $4A, $70, $70, $70, $70, $52, $53, $72
	.db $72, $72, $47, $4E, $72, $50, $51, $70, $4D, $4C, $4C, $54, $55, $4C, $4E, $72
	.db $72, $4A, $70, $70, $70, $70, $50, $4F, $4F, $56, $57, $4F, $51, $72, $72, $4A
	.db $70, $4D, $4E, $70, $70, $70, $70, $52, $53, $70, $70, $70, $72, $4A, $70, $50
	.db $51, $70, $4D, $4E, $70, $50, $51, $70, $4D, $47, $72, $4A, $71, $70, $70, $70
	.db $52, $53, $70, $70, $70, $70, $4B, $72, $72, $48, $47, $47, $47, $47, $64, $65
	.db $47, $47, $47, $47, $49, $72

; 14th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9723 to 9928 (518 bytes)
DATA_9723:
	.db $44, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $60, $72, $72
	.db $72, $72, $72, $72, $72, $52, $53, $70, $70, $70, $70, $52, $61, $4C, $4C, $4C
	.db $4C, $4E, $72, $52, $53, $70, $4D, $4E, $70, $52, $62, $4F, $4F, $4F, $4F, $51
	.db $72, $50, $51, $70, $50, $51, $70, $52, $4A, $71
	.fill 11, $70
	.db $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4E, $70, $52, $4A
	.db $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $52, $53, $70, $52, $4A, $70, $52
	.db $53, $70, $70, $70, $70, $70, $70, $52, $53, $70, $50, $4A, $70, $52, $53, $70
	.db $4D, $4C, $4C, $4E, $72, $52, $53, $70, $70, $4A, $70, $50, $51, $70, $50, $4F
	.db $56, $53, $72, $52, $55, $4C, $4C, $4A, $70, $70, $70, $70, $70, $70, $52, $53
	.db $72, $50, $4F, $4F, $4F, $63, $4C, $4C, $4C, $4C, $4E, $70, $52, $53, $72, $72
	.db $72, $72, $72, $62, $4F, $4F, $4F, $4F, $51, $70, $52, $53, $72, $58, $47, $5D
	.db $5E, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A
	.db $70, $4D, $4C, $4C, $4E, $70, $50, $51, $72, $4B, $72, $72, $72, $4A, $70, $50
	.db $4F, $56, $53, $70, $72, $72, $72, $4B, $72, $72, $72, $4A, $70, $70, $70, $52
	.db $53, $70, $4D, $4E, $72, $5A, $44, $44, $44, $48, $47, $4E, $70, $52, $53, $70
	.db $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $53, $70, $52, $55
	.db $4C, $4E, $72, $4D, $4C, $72, $72, $4A, $70, $50, $51, $70, $50, $4F, $4F, $51
	.db $72, $52, $5C, $72, $72, $4A
	.fill 9, $70
	.db $52, $5C, $72, $72, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $5C
	.db $44, $44, $51, $70, $50, $4F, $4F, $56, $57, $4F, $51, $70, $50, $4F, $72, $72
	.db $72, $70, $70, $70, $70, $52, $53, $70, $70, $70, $72, $72, $61, $4C, $4E, $70
	.db $4D, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $62, $4F, $51, $70, $52, $53
	.db $70, $50, $51, $70, $50, $4F, $4F, $56, $4A, $70, $70, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $54, $55, $4C, $4C, $4C, $4C
	.db $4C, $4E, $70, $52, $4A, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $51
	.db $70, $52, $4A
	.fill 12, $70
	.db $52, $4A, $70, $4D
	.fill 10, $4C
	.db $54, $4A, $70, $50, $4F, $4F, $4F, $4F, $56, $57, $4F, $4F, $4F, $4F, $56, $4A
	.db $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $71, $4D
	.db $4C, $4C, $4E, $70, $52, $53, $70, $4D, $4E, $70, $52, $4A, $70, $50, $4F, $4F
	.db $51, $70, $50, $51, $70, $50, $51, $70, $52, $4A
	.fill 12, $70
	.db $52, $48
	.fill 12, $47
	.db $64

; 15th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9929 to 9B2E (518 bytes)
DATA_9929:
	.db $45
	.fill 9, $44
	.db $60, $5F, $44, $44, $4A
	.fill 9, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $53
	.db $70, $4D, $4A, $71, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $51, $70, $52
	.db $4A, $70, $52, $53
	.fill 9, $70
	.db $52, $4A, $70, $50, $51, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $52, $4A
	.db $70, $70, $70, $70, $52, $53, $70, $52, $5C, $5C, $53, $70, $52, $63, $4C, $4C
	.db $4E, $70, $52, $53, $70, $50, $4F, $56, $53, $70, $50, $6A, $4F, $4F, $51, $70
	.db $52, $53, $70, $70, $70, $52, $53, $70, $70, $72, $70, $70, $70, $70, $52, $55
	.db $4C, $4E, $72, $52, $55, $4C, $4C, $68, $70, $4D, $4E, $70, $50, $4F, $4F, $51
	.db $72, $50, $4F, $4F, $4F, $4A, $70, $52, $53, $70, $70, $70, $72, $72, $72, $72
	.db $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $72, $58, $47, $5D
	.db $5E, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $72, $4B, $72, $72, $72, $4A
	.db $70, $70, $70, $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A, $70, $4D
	.db $4E, $70, $4D, $4C, $54, $53, $72, $4B, $72, $72, $72, $4A, $70, $50, $51, $70
	.db $50, $4F, $4F, $51, $72, $5A, $44, $44, $44, $4A, $70, $70, $70, $70, $70, $70
	.db $72, $72, $72, $72, $72, $72, $72, $63, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C
	.db $4C, $4C, $4E, $72, $4D, $6A, $4F, $4F, $4F, $4F, $51, $70, $52, $57, $4F, $4F
	.db $51, $72, $52, $72, $72, $72, $72, $72, $72, $70, $52, $53, $70, $70, $70, $70
	.db $52, $61, $4C, $4C, $4C, $4C, $4E, $70, $52, $53, $70, $4D, $4C, $4C, $54, $62
	.db $4F, $4F, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F, $56, $4A, $70, $70
	.db $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $4C
	.db $4E, $70, $52, $55, $4C, $4C, $4E, $70, $52, $4A, $70, $52, $57, $56, $53, $70
	.db $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $52, $53, $52, $53, $70, $52, $53
	.db $70, $70, $70, $70, $52, $4A, $70, $52, $55, $54, $53, $70, $52, $53, $70, $4D
	.db $4C, $4C, $54, $4A, $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F
	.db $4F, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $72, $4A
	.db $70, $4D, $4C, $4C, $4E, $70, $52, $55, $4C, $4C, $4E, $70, $4D, $4A, $70, $52
	.db $57, $56, $53, $70, $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $52, $53, $52
	.db $53, $70, $52, $53, $70, $70, $70, $70, $52, $4A, $71, $52, $55, $54, $53, $70
	.db $52, $53, $70, $4D, $47, $47, $64, $4A, $70, $50, $4F, $4F, $51, $70, $50, $51
	.db $70, $4B, $72, $72, $72, $4A
	.fill 9, $70
	.db $4B, $72, $72, $72, $48
	.fill 9, $47
	.db $49, $72, $72, $72

; 16th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9B2F to 9D34 (518 bytes)
DATA_9B2F:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4A, $71
	.db $52, $57, $56, $5C, $5C, $5C, $53, $70, $52, $57, $4F, $4F, $4A, $70, $52, $55
	.db $54, $57, $4F, $4F, $51, $70, $52, $53, $70, $72, $4A, $70, $52, $57, $56, $53
	.db $70, $70, $70, $70, $52, $53, $72, $4D, $4A, $70, $52, $55, $54, $53, $70, $4D
	.db $4E, $70, $52, $53, $70, $52, $4A, $70, $50, $4F, $56, $53, $70, $50, $51, $70
	.db $52, $53, $72, $52, $4A, $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $53
	.db $70, $52, $48, $47, $4E, $70, $52, $55, $4C, $4C, $4C, $4C, $54, $53, $72, $52
	.db $72, $72, $4A, $70, $50, $4F, $4F, $56, $57, $4F, $4F, $51, $70, $50, $72, $72
	.db $4A, $70, $70, $70, $70, $52, $53, $72, $72, $72, $72, $72, $44, $44, $51, $72
	.db $4D, $4E, $70, $52, $53, $72, $58, $47, $5D, $5E, $72, $72, $72, $72, $52, $53
	.db $70, $50, $51, $72, $4B, $72, $72, $72, $4C, $4C, $4C, $4C, $54, $53, $70, $72
	.db $72, $72, $4B, $72, $72, $72, $4F, $4F, $4F, $4F, $56, $53, $70, $4D, $4E, $72
	.db $4B, $72, $72, $72, $72, $72, $72, $72, $52, $53, $70, $52, $53, $72, $5A, $44
	.db $44, $44, $47, $47, $4E, $72, $50, $51, $70, $52, $53, $72, $72, $72, $72, $72
	.db $72, $72, $4A, $70, $70, $70, $70, $52, $55, $4C, $4C, $4E, $72, $4D, $72, $72
	.db $4A, $70, $4D, $4E, $70, $50, $4F, $4F, $4F, $51, $72, $52, $72, $72, $4A, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $70, $52, $72, $72, $4A, $70, $52, $55
	.db $4C, $4C, $4E, $70, $4D, $4E, $70, $52, $45, $44, $51, $70, $50, $4F, $4F, $56
	.db $53, $70, $50, $51, $70, $50, $4A, $70, $70, $70, $70, $70, $70, $52, $53, $70
	.db $70, $70, $70, $70, $4A, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $70, $4D, $4E
	.db $70, $4D, $4A, $70, $52, $57, $56, $53, $70, $52, $53, $70, $50, $51, $70, $50
	.db $4A, $71, $52, $55, $54, $53, $70, $52, $53, $70, $70, $70, $70, $70, $4A, $70
	.db $52, $5C, $5C, $53, $70, $52, $55, $4C, $4C, $4C, $4C, $4C, $4A, $70, $52, $57
	.db $4F, $51, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $4A, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $70, $72, $72, $72, $4A, $70, $52, $53, $70, $4D, $4E, $70
	.db $4D, $4E, $70, $4D, $4E, $4D, $4A, $70, $52, $53, $70, $50, $51, $70, $50, $51
	.db $70, $50, $51, $50, $4A, $70, $52, $53
	.fill 10, $70
	.db $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4C, $4E, $70, $4D, $47, $47, $69, $70
	.db $50, $4F, $4F, $51, $70, $50, $4F, $51, $70, $4B, $72, $72, $72
	.fill 10, $70
	.db $4B, $72, $72
	.fill 11, $47
	.db $49, $72, $72

; 17th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9D35 to 9EE6 (434 bytes)
DATA_9D35:
	.db $45, $44, $44, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $4A, $71
	.db $70, $70, $70, $70, $70, $70, $70, $52, $53, $70, $70, $70, $4A, $70, $4D, $4E
	.db $70, $4D, $4C, $4E, $70, $50, $51, $70, $4D, $4C, $4A, $70, $52, $53, $70, $52
	.db $5C, $53, $70, $70, $70, $70, $52, $5C, $4A, $70, $52, $53, $70, $50, $56, $55
	.db $4E, $70, $4D, $4C, $54, $5C, $4A, $70, $52, $53, $70, $72, $50, $56, $53, $70
	.db $52, $5C, $5C, $5C, $4A, $70, $52, $53, $70, $72, $72, $50, $51, $70, $50, $4F
	.db $4F, $56, $4A, $70, $52, $53
	.fill 9, $70
	.db $52, $4A, $70, $52, $55, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4E, $72, $52, $4A
	.db $70, $50, $4F, $4F, $4F, $51, $70, $50, $4F, $56, $53, $72, $52, $4A, $70, $70
	.db $70, $70, $70, $70, $70, $72, $72, $50, $51, $72, $50, $48, $47, $47, $47, $4E
	.db $70, $4D, $4C, $4E
	.fill 9, $72
	.db $4A, $70, $52, $5C, $53, $72, $58, $47, $5D, $5E, $45, $44, $44, $44, $51, $70
	.db $52, $5C, $53, $72, $4B, $72, $72, $72, $4A, $70, $70, $70, $70, $70, $52, $5C
	.db $53, $72, $4B, $72, $72, $72, $4A, $70, $4D, $4C, $4C, $4C, $54, $5C, $53, $72
	.db $4B, $72, $72, $72, $69, $70, $50, $4F, $4F, $4F, $56, $57, $51, $72, $5A, $44
	.db $44, $44, $72, $70, $70, $70, $70, $70, $52, $53, $72, $72, $72, $72, $72, $72
	.db $68, $70, $4D, $4C, $4E, $70, $52, $53, $72, $72, $4D, $4C, $4C, $4C, $4A, $70
	.db $50, $4F, $51, $70, $52, $53, $72, $4D, $54, $5C, $5C, $5C, $4A, $70, $70, $70
	.db $70, $70, $50, $51, $72, $50, $4F, $4F, $4F, $56, $4A, $70, $4D, $4C, $4E, $70
	.db $70, $70, $70, $70, $70, $70, $70, $52, $4A, $70, $52, $5C, $53, $70, $4D, $4C
	.db $4C, $4C, $4E, $72, $70, $50, $4A, $70, $50, $4F, $51, $70, $50, $4F, $4F, $56
	.db $55, $4E, $70, $72, $4A, $70, $70, $70, $70, $70, $70, $70, $70, $52, $5C, $53
	.db $70, $4D, $4A, $70, $4D, $4C, $4E, $70, $4D, $4E, $70, $50, $4F, $51, $70, $50
	.db $4A, $71, $52, $5C, $53, $70, $52, $53, $70, $70, $70, $70, $70, $70, $4A, $70
	.db $52, $5C, $53, $70, $52, $55, $4C, $4C, $4C, $4E, $70, $4D, $4A, $70, $50, $4F
	.db $51, $70, $50, $4F, $4F, $4F, $4F, $51, $70, $50, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 18th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from 9EE7 to A098 (434 bytes)
DATA_9EE7:
	.db $45
	.fill 12, $44
	.db $60, $4A, $70, $70, $70, $70, $70, $70, $71, $70, $70, $70, $70, $70, $52, $4A
	.db $70, $4D, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4C, $4E, $70, $52, $4A, $70, $50
	.db $4F, $51, $70, $50, $4F, $4F, $4F, $56, $53, $70, $52, $4A
	.fill 9, $70
	.db $52, $53, $70, $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $53
	.db $70, $52, $4A, $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $52, $53, $70, $52
	.db $4A, $70, $52, $53, $70, $70, $70, $70, $70, $70, $52, $53, $70, $50, $4A, $70
	.db $52, $53, $70, $4D, $4C, $4C, $4E, $72, $52, $53, $70, $70, $4A, $70, $52, $53
	.db $70, $50, $4F, $56, $53, $72, $52, $55, $4C, $4C, $4A, $70, $52, $53, $70, $70
	.db $70, $52, $53, $72, $50, $4F, $4F, $4F, $4A, $70, $52, $55, $4C, $4E, $70, $52
	.db $53, $72, $72, $72, $72, $72, $4A, $70, $52, $5C, $5C, $53, $70, $52, $53, $72
	.db $58, $47, $5D, $5E, $4A, $70, $52, $5C, $5C, $53, $70, $52, $53, $72, $4B, $72
	.db $72, $72, $4A, $70, $52, $5C, $5C, $53, $70, $50, $51, $72, $4B, $72, $72, $72
	.db $4A, $70, $50, $4F, $56, $53, $70, $72, $72, $72, $4B, $72, $72, $72, $4A, $70
	.db $70, $70, $52, $53, $70, $4D, $4E, $72, $5A, $44, $44, $44, $48, $47, $4E, $70
	.db $52, $53, $70, $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $52, $53
	.db $70, $52, $55, $4C, $4C, $4C, $4C, $4C, $72, $72, $4A, $70, $50, $51, $70, $50
	.db $4F, $4F, $4F, $4F, $4F, $4F, $72, $72, $4A
	.fill 11, $70
	.db $72, $72, $4A, $70, $4D, $4E, $70, $4D, $4C, $4E, $70, $4D, $4C, $4C, $44, $44
	.db $51, $70, $52, $53, $70, $50, $4F, $51, $70, $50, $4F, $4F, $72, $72, $72, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $72, $72, $61, $4C, $4E, $70, $52, $53
	.db $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $62, $4F, $51, $70, $52, $53, $70, $50
	.db $4F, $4F, $4F, $51, $70, $52, $4A, $71, $70, $70, $52, $53, $70, $70, $70, $70
	.db $70, $70, $70, $52, $4A, $70, $4D, $4C, $54, $53, $70, $4D, $4C, $4C, $4C, $4E
	.db $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $51, $70, $52
	.db $4A
	.fill 12, $70
	.db $52, $48
	.fill 12, $47
	.db $64

; 19th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from A099 to A24A (434 bytes)
DATA_A099:
	.db $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $44, $44, $44, $44, $72, $72
	.db $72, $72, $52, $53, $70, $70, $70, $70, $70, $70, $70, $70, $61, $4C, $4E, $72
	.db $52, $53, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $62, $4F, $51, $72, $50, $51
	.db $70, $52, $5C, $5C, $53, $70, $50, $4F, $4A, $70, $70, $70, $70, $70, $70, $50
	.db $4F, $4F, $51, $70, $70, $70, $4A, $70, $4D, $4C, $4C, $4E, $70, $70, $70, $70
	.db $70, $70, $4D, $4C, $4A, $71, $52, $5C, $5C, $53, $70, $4D, $4C, $4C, $4C, $4C
	.db $54, $5C, $4A, $70, $50, $4F, $4F, $51, $70, $52, $5C, $57, $4F, $4F, $4F, $4F
	.db $4A, $70, $70, $70, $70, $70, $70, $52, $5C, $53, $70, $70, $70, $70, $4A, $70
	.db $4D, $4C, $4C, $4C, $4C, $54, $5C, $53, $72, $4D, $4C, $4C, $4A, $70, $52, $57
	.db $4F, $4F, $4F, $4F, $4F, $51, $72, $50, $4F, $4F, $4A, $70, $50, $51, $70, $70
	.db $70, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $70, $70, $70, $4D, $4C, $4C
	.db $4E, $72, $58, $47, $5D, $5E, $4A, $70, $4D, $4E, $70, $52, $5C, $5C, $53, $72
	.db $4B, $72, $72, $72, $4A, $70, $50, $51, $70, $50, $4F, $4F, $51, $72, $4B, $72
	.db $72, $72, $4A, $70, $70, $70, $70, $72, $72, $72, $72, $72, $4B, $72, $72, $72
	.db $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $72, $5A, $44, $44, $44, $4A, $70
	.db $52, $53, $70, $50, $4F, $4F, $51, $72, $72, $72, $72, $72, $4A, $70, $52, $53
	.db $70, $70, $70, $70, $70, $70, $4D, $4C, $4C, $4C, $4A, $71, $52, $53, $70, $4D
	.db $4C, $4C, $4E, $70, $52, $5C, $5C, $5C, $4A, $70, $52, $53, $70, $50, $4F, $4F
	.db $51, $70, $50, $4F, $56, $5C, $4A, $70, $50, $51, $70, $70, $70, $70, $70, $70
	.db $70, $70, $52, $5C, $4A, $70, $70, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70
	.db $50, $4F, $48, $47, $4E, $70, $52, $5C, $5C, $5C, $5C, $5C, $53, $70, $70, $72
	.db $72, $72, $4A, $70, $52, $5C, $5C, $5C, $5C, $5C, $55, $4C, $4C, $4C, $45, $44
	.db $51, $70, $50
	.fill 9, $4F
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4E, $70, $4D, $4C, $4C, $69, $70
	.db $50, $4F, $4F, $4F, $51, $70, $52, $53, $70, $50, $4F, $4F, $72, $70, $70, $70
	.db $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $47, $47, $47, $47, $47, $47
	.db $47, $47, $64, $65, $47, $47, $47, $47

; 20th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from A24B to A3FC (434 bytes)
DATA_A24B:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4A, $70
	.db $50, $4F, $51, $70, $50, $4F, $4F, $4F, $51, $70, $50, $4F, $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4C, $4A, $70
	.db $50, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48, $47, $4E, $70, $4D, $4E, $70, $4D, $47, $47, $4E, $72, $4D, $47, $72, $72
	.db $4A, $70, $4B, $4A, $70, $4B, $72, $72, $4A, $72, $4B, $72, $44, $44, $51, $70
	.db $4B, $4A, $70, $50, $44, $44, $51, $72, $50, $44, $72, $72, $72, $70, $4B, $4A
	.db $70, $72, $72, $72, $72, $72, $72, $72, $47, $47, $4E, $70, $4B, $4A, $70, $4D
	.db $4E, $72, $58, $47, $5D, $5E, $72, $72, $4A, $70, $4B, $4A, $70, $52, $53, $70
	.db $4B, $72, $72, $72, $44, $44, $51, $70, $50, $51, $70, $52, $53, $70, $4B, $72
	.db $72, $72, $72, $72, $72, $70, $70, $70, $70, $52, $53, $70, $4B, $72, $72, $72
	.db $47, $47, $4E, $70, $4D, $4E, $70, $52, $53, $72, $5A, $44, $44, $44, $72, $72
	.db $4A, $70, $4B, $4A, $70, $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A, $70
	.db $4B, $4A, $70, $52, $55, $4C, $4C, $4C, $4C, $4C, $45, $44, $51, $70, $50, $51
	.db $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4A, $70
	.db $50, $4F, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 12, $70
	.db $72, $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4E, $70, $4D, $4C, $4A
	.db $70, $50, $4F, $4F, $51, $70, $50, $4F, $4F, $51, $70, $50, $4F, $4A
	.fill 13, $70
	.db $4A, $71, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4A, $70
	.db $50, $4F, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 21st entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from A3FD to A5AE (434 bytes)
DATA_A3FD:
	.db $45
	.fill 9, $44
	.db $60, $5F, $44, $44, $4A, $70, $70, $70, $70, $70, $70, $72, $72, $70, $52, $53
	.db $70, $70, $4A, $71, $4D, $4C, $4C, $4E, $70, $4D, $4E, $70, $52, $53, $70, $4D
	.db $4A, $70, $52, $57, $4F, $51, $70, $52, $53, $70, $50, $51, $70, $50, $4A, $70
	.db $52, $53, $70, $70, $70, $52, $53, $70, $70, $70, $70, $70, $4A, $70, $52, $53
	.db $70, $4D, $4E, $52, $53, $70, $4D, $4C, $4C, $4C, $4A, $70, $52, $53, $70, $50
	.db $51, $52, $53, $70, $52, $5C, $5C, $5C, $4A, $70, $52, $53, $70, $70, $70, $52
	.db $53, $70, $50, $4F, $4F, $4F, $4A, $70, $52, $55, $4C, $4E, $70, $52, $53, $70
	.db $72, $72, $72, $4D, $4A, $70, $52, $57, $4F, $51, $70, $52, $55, $4C, $4C, $4E
	.db $72, $52, $4A, $70, $52, $53, $70, $70, $70, $50, $4F, $4F, $4F, $51, $72, $50
	.db $4A, $70, $52, $53, $70, $4D, $4E, $4D, $4E, $72, $72, $72, $72, $72, $4A, $70
	.db $52, $53, $70, $50, $51, $50, $51, $72, $58, $47, $5D, $5E, $4A, $70, $52, $53
	.db $70, $72, $72, $72, $72, $72, $4B, $72, $72, $72, $4A, $70, $52, $53, $70, $4D
	.db $4E, $4D, $4E, $72, $4B, $72, $72, $72, $69, $70, $50, $51, $70, $50, $51, $50
	.db $51, $72, $4B, $72, $72, $72, $72, $70, $70, $70, $70, $4D, $4E, $4D, $4E, $72
	.db $5A, $44, $44, $44, $68, $72, $4D, $4C, $4E, $50, $51, $50, $51, $72, $72, $72
	.db $72, $72, $4A, $72, $52, $5C, $55, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4E, $72
	.db $4A, $72, $50, $4F, $4F, $56, $57, $4F, $4F, $4F, $4F, $56, $53, $72, $4A, $70
	.db $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $53, $72, $4A, $70, $4D, $4E
	.db $70, $52, $53, $70, $4D, $4E, $70, $52, $53, $72, $4A, $70, $50, $51, $70, $50
	.db $51, $70, $50, $51, $70, $50, $51, $72, $4A
	.fill 10, $70
	.db $72, $72, $72, $63, $47, $47, $4E, $70, $4D, $4E, $70, $4D, $4C, $4C, $4C, $4E
	.db $72, $62, $44, $44, $51, $70, $50, $51, $70, $50, $4F, $4F, $56, $53, $72, $4A
	.fill 10, $70
	.db $52, $53, $72, $4A, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $52, $53
	.db $72, $4A, $70, $50, $51, $70, $4B, $4A, $70, $50, $51, $70, $52, $53, $72, $4A
	.db $70, $70, $70, $70, $4B, $4A, $70, $70, $70, $70, $52, $53, $71, $48, $47, $47
	.db $47, $47, $64, $65, $47, $47, $47, $47, $64, $65, $47

; 22nd entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from A5AF to A760 (434 bytes)
DATA_A5AF:
	.db $45, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $60, $5F, $44, $4A, $70
	.db $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $53, $72, $4A, $71, $4D, $4E
	.db $70, $52, $53, $70, $4D, $4E, $70, $52, $55, $4C, $4A, $70, $52, $53, $70, $52
	.db $53, $70, $52, $53, $70, $50, $4F, $4F, $4A, $70, $52, $53, $70, $52, $53, $70
	.db $52, $53, $70, $70, $70, $70, $4A, $70, $52, $53, $70, $52, $53, $70, $52, $53
	.db $70, $4D, $4C, $4C, $4A, $70, $52, $53, $70, $52, $53, $70, $52, $53, $70, $52
	.db $5C, $5C, $4A, $70, $52, $53, $70, $52, $53, $70, $52, $53, $70, $50, $4F, $4F
	.db $4A, $70, $52, $53, $70, $52, $53, $70, $52, $53, $70, $70, $70, $70, $4A, $70
	.db $52, $53, $70, $52, $53, $70, $52, $55, $4C, $4C, $4C, $4C, $69, $70, $50, $51
	.db $70, $52, $53, $70, $50, $4F, $4F, $4F, $4F, $4F, $72, $70, $70, $70, $70, $52
	.db $53, $70, $72, $72, $72, $72, $72, $72, $68, $70, $4D, $4E, $70, $52, $55, $4C
	.db $4E, $72, $58, $47, $5D, $5E, $4A, $70, $52, $53, $70, $50, $4F, $4F, $51, $72
	.db $4B, $72, $72, $72, $4A, $71, $52, $53, $70, $72, $72, $72, $72, $72, $4B, $72
	.db $72, $72, $4A, $70, $52, $53, $70, $4D, $4C, $4C, $4E, $72, $4B, $72, $72, $72
	.db $4A, $70, $50, $51, $70, $50, $4F, $4F, $51, $72, $5A, $44, $44, $44, $4A, $70
	.db $70, $70, $70, $70, $70, $70, $72, $72, $72, $72, $72, $72, $4A, $70, $4D, $4E
	.db $70, $4D, $4C, $4C, $4C, $4E, $72, $4D, $4C, $4C, $4A, $70, $52, $53, $70, $50
	.db $4F, $4F, $56, $53, $72, $50, $4F, $4F, $4A, $70, $52, $53, $70, $70, $70, $70
	.db $52, $53, $70, $70, $70, $70, $4A, $70, $52, $53, $70, $4D, $4E, $70, $52, $55
	.db $4C, $4E, $70, $4D, $4A, $70, $52, $53, $70, $50, $51, $70, $50, $4F, $4F, $51
	.db $70, $50, $4A, $70, $52, $53
	.fill 9, $70
	.db $72, $4A, $70, $52, $53, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4C, $4C, $4A
	.db $70, $50, $51, $70, $52, $53, $70, $50, $51, $70, $50, $4F, $4F, $4A, $70, $70
	.db $70, $70, $52, $53, $70, $70, $70, $70, $70, $70, $70, $4A, $70, $4D, $4E, $70
	.db $52, $53, $70, $4D, $4E, $70, $4D, $4C, $4C, $69, $70, $52, $53, $70, $50, $51
	.db $70, $50, $51, $70, $50, $4F, $4F, $72, $70, $52, $53
	.fill 10, $70
	.db $47, $47, $64, $65
	.fill 10, $47

; 23rd entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from A761 to A912 (434 bytes)
DATA_A761:
	.db $45
	.fill 12, $44
	.db $60, $4A
	.fill 12, $70
	.db $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $4A
	.db $70, $50, $4F, $56, $57, $4F, $4F, $4F, $4F, $4F, $51, $70, $52, $4A, $70, $70
	.db $70, $52, $53, $70, $70, $70, $70, $70, $70, $70, $52, $48, $47, $4E, $70, $52
	.db $53, $70, $4D, $4C, $4C, $4C, $4E, $70, $52, $72, $72, $4A, $70, $52, $53, $71
	.db $52, $5C, $5C, $5C, $53, $70, $52, $44, $44, $51, $70, $52, $53, $70, $50, $4F
	.db $4F, $4F, $51, $70, $52, $72, $72, $72, $70, $52, $53, $70, $70, $70, $70, $70
	.db $70, $70, $52, $47, $47, $4E, $70, $52, $53, $70, $4D, $4E, $72, $4D, $4C, $4C
	.db $54, $72, $72, $4A, $70, $52, $53, $70, $52, $53, $72, $50, $4F, $4F, $4F, $72
	.db $72, $4A, $70, $52, $53, $70, $52, $53, $72, $72, $72, $72, $72, $72, $72, $4A
	.db $70, $52, $53, $70, $52, $53, $72, $58, $47, $5D, $5E, $72, $72, $4A, $70, $52
	.db $53, $70, $52, $53, $72, $4B, $72, $72, $72, $72, $72, $4A, $70, $52, $53, $70
	.db $52, $53, $72, $4B, $72, $72, $72, $72, $72, $4A, $70, $52, $53, $70, $52, $53
	.db $72, $4B, $72, $72, $72, $44, $44, $51, $70, $52, $53, $70, $50, $51, $72, $5A
	.db $44, $44, $60, $72, $72, $72, $70, $52, $53, $70, $70, $70, $70, $70, $70, $70
	.db $52, $47, $47, $4E, $70, $52, $53, $70, $4D, $4E, $70, $4D, $4E, $70, $52, $72
	.db $72, $4A, $70, $52, $53, $70, $52, $53, $70, $50, $51, $70, $52, $72, $72, $4A
	.db $70, $52, $53, $70, $52, $53, $70, $70, $70, $70, $52, $72, $72, $4A, $70, $52
	.db $53, $70, $52, $53, $70, $4D, $4C, $4C, $54, $45, $44, $51, $70, $52, $53, $70
	.db $52, $53, $70, $52, $57, $4F, $4F, $4A, $70, $70, $70, $52, $53, $70, $52, $53
	.db $70, $52, $53, $70, $72, $4A, $70, $4D, $4C, $54, $53, $70, $52, $53, $70, $52
	.db $53, $70, $4D, $4A, $70, $52, $5C, $5C, $53, $71, $50, $51, $70, $52, $53, $70
	.db $52, $4A, $70, $52, $5C, $5C, $53, $70, $70, $70, $70, $52, $53, $70, $52, $4A
	.db $70, $52, $5C, $5C, $55, $4C, $4C, $4C, $4C, $54, $53, $70, $52, $4A, $70, $50
	.db $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $51, $70, $50, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 24th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from A913 to AAC4 (434 bytes)
DATA_A913:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $71, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4E, $70, $4D, $4C, $4C, $4A, $70
	.db $52, $5C, $5C, $5C, $53, $70, $52, $53, $70, $50, $4F, $4F, $4A, $70, $52, $5C
	.db $57, $4F, $51, $70, $52, $53, $70, $70, $70, $70, $4A, $70, $52, $5C, $53, $70
	.db $70, $70, $52, $55, $4C, $4E, $70, $4D, $4A, $70, $52, $5C, $53, $70, $4D, $4C
	.db $54, $57, $4F, $51, $70, $50, $69, $70, $50, $4F, $51, $70, $50, $4F, $56, $53
	.db $72, $72, $70, $70, $72, $70, $70, $70, $70, $70, $70, $70, $52, $53, $72, $4D
	.db $4C, $4C, $47, $4E, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $72, $52, $5C, $5C
	.db $72, $4A, $70, $50, $4F, $4F, $51, $70, $50, $51, $72, $50, $4F, $4F, $72, $4A
	.db $70, $70, $70, $70, $70, $70, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $4D
	.db $47, $47, $47, $47, $4E, $72, $58, $47, $5D, $5E, $72, $4A, $70, $4B, $45, $44
	.db $44, $44, $51, $72, $4B, $72, $72, $72, $72, $4A, $70, $4B, $4A, $72, $72, $72
	.db $72, $72, $4B, $72, $72, $72, $72, $4A, $70, $4B, $4A, $72, $4D, $4C, $4E, $72
	.db $4B, $72, $72, $72, $44, $51, $70, $4B, $4A, $72, $50, $4F, $51, $72, $5A, $44
	.db $44, $44, $72, $72, $70, $4B, $4A, $70, $70, $70, $70, $72, $72, $72, $72, $72
	.db $47, $47, $47, $49, $4A, $70, $4D, $4E, $70, $4D, $4E, $72, $4D, $4C, $44, $44
	.db $44, $46, $4A, $70, $50, $51, $70, $50, $51, $72, $50, $4F, $72, $72, $72, $4B
	.db $4A
	.fill 9, $70
	.db $47, $4E, $72, $4B, $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4C, $4C, $45, $51
	.db $72, $50, $51, $70, $52, $53, $70, $50, $4F, $4F, $4F, $4F, $4A, $70, $70, $70
	.db $70, $70, $52, $53, $70, $70, $70, $70, $70, $72, $4A, $70, $4D, $4C, $4E, $70
	.db $52, $55, $4C, $4E, $70, $4D, $4C, $4C, $4A, $70, $52, $5C, $53, $70, $50, $4F
	.db $56, $53, $70, $50, $4F, $4F, $4A, $70, $52, $5C, $53, $70, $70, $70, $52, $53
	.db $70, $70, $70, $70, $4A, $71, $52, $5C, $55, $4C, $4E, $70, $52, $55, $4C, $4E
	.db $70, $4D, $4A, $70, $50, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $51, $70, $50
	.db $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 25th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from AAC5 to AC76 (434 bytes)
DATA_AAC5:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $71, $4D, $4E, $70, $4D, $4E, $4D, $4E, $70, $4D, $4E, $70, $4D, $4A, $70
	.db $50, $51, $70, $50, $51, $50, $51, $70, $50, $51, $70, $50, $4A
	.fill 12, $70
	.db $4D, $4A, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $4D, $4E, $70, $50, $4A
	.db $70, $50, $51, $70, $50, $51, $70, $50, $51, $50, $51, $70, $4D, $4A
	.fill 9, $70
	.db $4D, $4E, $70, $50, $4A, $70, $4D, $4E, $70, $4D, $4E, $4D, $4E, $72, $50, $51
	.db $70, $70, $69, $70, $50, $51, $70, $50, $51, $50, $51, $72, $4D, $4E, $72, $4D
	.db $72, $70, $70, $70, $70, $70, $70, $72, $72, $72, $50, $51, $72, $50, $68, $70
	.db $4D, $4E, $70, $4D, $4E, $4D, $4E, $72, $72, $72, $72, $72, $69, $70, $50, $51
	.db $70, $50, $51, $50, $51, $72, $58, $47, $5D, $5E, $72, $70, $70, $70, $70, $70
	.db $70, $72, $72, $72, $4B, $72, $72, $72, $68, $70, $4D, $4E, $4D, $4E, $70, $4D
	.db $4E, $72, $4B, $72, $72, $72, $4A, $70, $50, $51, $50, $51, $70, $50, $51, $72
	.db $4B, $72, $72, $72, $4A, $70, $70, $70, $70, $70, $70, $72, $72, $72, $5A, $44
	.db $44, $44, $4A, $70, $4D, $4E, $70, $4D, $4E, $4D, $4E, $72, $72, $72, $72, $72
	.db $4A, $70, $50, $51, $70, $50, $51, $50, $51, $72, $4D, $4E, $72, $4D, $4A
	.fill 9, $70
	.db $50, $51, $72, $50, $4A, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $70
	.db $70, $70, $4A, $70, $50, $51, $70, $50, $51, $70, $50, $51, $70, $4D, $4E, $4D
	.db $4A, $70, $70, $70, $71, $70, $70, $70, $70, $70, $70, $50, $51, $50, $4A, $70
	.db $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $72, $72, $72, $4A, $70, $50, $51
	.db $70, $50, $51, $70, $50, $51, $70, $4D, $4E, $72, $4A
	.fill 10, $70
	.db $50, $51, $72, $4A, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E
	.db $72, $4A, $70, $50, $51, $70, $50, $51, $70, $50, $51, $70, $50, $51, $72, $4A
	.fill 10, $70
	.db $72, $72, $72, $4A, $4D, $4E, $4D, $4E, $4D, $4E, $4D, $4E, $4D, $4E, $4D, $4E
	.db $4D, $48, $49, $48, $49, $48, $49, $48, $49, $48, $49, $48, $49, $48, $49

; 26th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from AC77 to AE28 (434 bytes)
DATA_AC77:
	.fill 10, $44
	.db $60, $5F, $44, $44
	.fill 10, $72
	.db $52, $53, $70, $70, $61, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4E, $72, $52, $53
	.db $70, $4D, $62, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $51, $72, $52, $53, $70, $52
	.db $4A, $71, $70, $70, $70, $70, $70, $70, $70, $70, $52, $53, $70, $52, $4A, $70
	.db $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $52, $53, $70, $52, $4A, $70, $52, $57
	.db $4F, $4F, $4F, $4F, $51, $70, $50, $51, $70, $50, $4A, $70, $52, $53
	.fill 10, $70
	.db $4A, $70, $52, $53, $70, $4D, $4C, $4C, $4E, $72, $4D, $4C, $4C, $4C, $4A, $70
	.db $50, $51, $70, $50, $4F, $56, $53, $72, $52, $5C, $5C, $5C, $4A, $70, $70, $70
	.db $70, $70, $70, $52, $53, $72, $50, $4F, $4F, $4F, $63, $4C, $4C, $4C, $4C, $4E
	.db $70, $52, $53, $72, $72, $72, $72, $72, $6A, $4F, $4F, $4F, $56, $53, $70, $52
	.db $53, $72, $58, $47, $5D, $5E, $72, $70, $70, $70, $52, $53, $70, $52, $53, $72
	.db $4B, $72, $72, $72, $61, $4C, $4E, $70, $52, $53, $70, $52, $53, $72, $4B, $72
	.db $72, $72, $62, $4F, $51, $70, $52, $53, $70, $52, $53, $72, $4B, $72, $72, $72
	.db $4A, $70, $70, $70, $52, $53, $70, $52, $53, $72, $5A, $44, $44, $44, $4A, $70
	.db $4D, $4C, $54, $53, $70, $52, $53, $72, $72, $72, $72, $72, $4A, $70, $50, $4F
	.db $4F, $51, $70, $52, $55, $4C, $4E, $72, $4D, $4C, $4A, $70, $70, $70, $70, $70
	.db $70, $50, $4F, $4F, $51, $72, $50, $4F, $48, $47, $4E, $70, $4D, $4E, $70, $70
	.db $70, $70, $70, $70, $70, $70, $72, $72, $4A, $70, $52, $53, $70, $4D, $4C, $4C
	.db $4E, $70, $4D, $4C, $44, $44, $51, $70, $52, $53, $70, $50, $4F, $56, $53, $70
	.db $50, $4F, $72, $72, $72, $70, $52, $53, $70, $70, $70, $52, $53, $70, $70, $72
	.db $61, $4C, $4E, $70, $52, $55, $4C, $4E, $70, $52, $55, $4C, $4C, $4C, $62, $4F
	.db $51, $70, $52, $57, $4F, $51, $70, $50, $4F, $4F, $4F, $56, $4A, $70, $70, $70
	.db $52, $53, $70, $70, $70, $70, $70, $70, $70, $52, $4A, $71, $4D, $4C, $54, $53
	.db $70, $4D, $4C, $4C, $4C, $4E, $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $50
	.db $4F, $4F, $4F, $51, $70, $50, $4A
	.fill 12, $70
	.db $72, $48
	.fill 13, $47

; 27th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from AE29 to AFCC (420 bytes)
DATA_AE29:
	.db $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $44, $44, $44, $44, $72, $72
	.db $72, $72, $52, $53, $70, $70, $70, $70, $70, $70, $70, $70, $61, $4C, $4E, $72
	.db $52, $53, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $62, $4F, $51, $72, $50, $51
	.db $70, $52, $57, $4F, $4F, $51, $70, $52, $4A, $70, $70, $70, $70, $70, $70, $52
	.db $53, $70, $70, $70, $70, $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $54, $53, $70
	.db $4D, $4C, $4C, $54, $4A, $70, $50, $4F, $4F, $56, $5C, $5C, $53, $70, $50, $4F
	.db $4F, $4F, $4A, $70, $70, $70, $70, $52, $5C, $5C, $53, $70, $70, $70, $70, $70
	.db $4A, $70, $4D, $4E, $70, $50, $4F, $56, $53, $72, $4D, $4E, $72, $4D, $4A, $70
	.db $52, $53, $70, $70, $70, $52, $53, $72, $52, $53, $72, $52, $4A, $70, $52, $55
	.db $4C, $4E, $70, $52, $53, $72, $50, $51, $72, $50, $4A, $70, $50, $4F, $4F, $51
	.db $70, $52, $53, $72, $72, $72, $72, $72, $4A, $70, $70, $70, $70, $70, $71, $52
	.db $53, $72, $58, $47, $5D, $5E, $4A, $70, $4D, $4E, $70, $4D, $4C, $54, $53, $72
	.db $4B, $72, $72, $72, $4A, $70, $52, $53, $70, $50, $4F, $4F, $51, $72, $4B, $72
	.db $72, $72, $4A, $70, $52, $53, $70, $70, $70, $70, $70, $72, $4B, $72, $72, $72
	.db $4A, $70, $52, $55, $4C, $4C, $4C, $4C, $4E, $72, $5A, $44, $44, $44, $4A, $70
	.db $52, $57, $4F, $4F, $4F, $4F, $51, $72, $72, $72, $72, $72, $4A, $71, $52, $53
	.db $70, $70, $70, $70, $4D, $4C, $4E, $72, $4D, $4C, $4A, $70, $52, $53, $70, $4D
	.db $4E, $70, $52, $5C, $53, $72, $50, $4F, $4A, $70, $52, $53, $70, $50, $51, $70
	.db $52, $5C, $53, $70, $70, $70, $4A, $70, $52, $53, $70, $70, $70, $70, $52, $5C
	.db $55, $4C, $4C, $4C, $4A, $70, $52, $53, $70, $4D, $4C, $4E, $50, $4F, $4F, $4F
	.db $4F, $4F, $4A, $70, $52, $53, $70, $52, $5C, $53, $70, $70, $70, $70, $70, $72
	.db $4A, $70, $50, $51, $70, $52, $5C, $53, $70, $4D, $4C, $4E, $70, $4D, $4A, $70
	.db $70, $70, $70, $52, $5C, $53, $70, $52, $5C, $53, $70, $52, $4A, $70, $4D, $4C
	.db $4C, $54, $5C, $53, $70, $52, $5C, $53, $70, $52, $4A, $70, $50, $4F, $4F, $4F
	.db $4F, $51, $70, $50, $4F, $51, $70, $52, $4A
	.fill 12, $70
	.db $52, $48
	.fill 12, $47
	.db $64

; 28th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from AFCD to B17E (434 bytes)
DATA_AFCD:
	.fill 12, $44
	.db $46, $72
	.fill 12, $70
	.db $4B, $72
	.fill 10, $47
	.db $4E, $70, $4B
	.fill 11, $72
	.db $4A, $70, $4B, $72, $72, $72, $45, $44, $44, $44, $44, $44, $44, $44, $51, $70
	.db $50, $44, $72, $72, $4A, $71
	.fill 10, $70
	.db $72, $72, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $72, $72
	.db $4A, $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $44, $44, $51, $70
	.db $52, $53
	.fill 12, $70
	.db $52, $53, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $68, $70, $4D, $4C, $54, $53
	.db $70, $52, $57, $4F, $4F, $4F, $4F, $4F, $4A, $70, $50, $4F, $56, $53, $70, $52
	.db $53, $72, $72, $72, $72, $72, $4A, $70, $70, $70, $52, $53, $70, $52, $53, $72
	.db $58, $47, $5D, $5E, $48, $47, $4E, $70, $52, $53, $70, $50, $51, $72, $4B, $72
	.db $72, $72, $72, $72, $4A, $70, $52, $53, $70, $72, $72, $72, $4B, $72, $72, $72
	.db $72, $72, $4A, $70, $52, $53, $70, $4D, $4E, $72, $4B, $72, $72, $72, $45, $44
	.db $51, $70, $52, $53, $70, $52, $53, $72, $5A, $44, $44, $44, $4A, $70, $70, $70
	.db $52, $53, $70, $52, $53, $72, $72, $72, $72, $72, $4A, $70, $4D, $4C, $54, $53
	.db $70, $52, $55, $4C, $4C, $4C, $4C, $4C, $4A, $70, $50, $4F, $56, $53, $70, $50
	.db $4F, $4F, $4F, $4F, $4F, $4F, $4A, $70, $70, $70, $52, $53, $70, $70, $70, $70
	.db $70, $70, $70, $70, $48, $47, $4E, $70, $52, $55, $4C, $4C, $4C, $4C, $4E, $70
	.db $4D, $4C, $44, $44, $51, $70, $52, $57, $4F, $4F, $4F, $4F, $51, $70, $50, $4F
	.db $72, $72, $72, $70, $52, $53, $70, $70, $70, $70, $70, $70, $72, $72, $47, $47
	.db $4E, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $45, $44, $51, $70
	.db $52, $53, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $4A, $70, $70, $70, $52, $53
	.db $70, $70, $70, $70, $70, $70, $70, $70, $4A, $70, $4D, $4C, $54, $55, $4C, $4C
	.db $4C, $4E, $70, $4D, $4C, $4C, $4A, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F, $51
	.db $70, $50, $4F, $4F, $4A, $70, $70, $70, $70, $70, $71, $70, $70, $70, $70, $70
	.db $70, $70, $48
	.fill 13, $47

; 29th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from B17F to B384 (518 bytes)
DATA_B17F:
	.db $44, $44, $44, $44, $44, $44, $44, $60, $5F, $44, $44, $44, $44, $60, $72, $72
	.db $72, $70, $70, $70, $70, $52, $53, $70, $70, $70, $70, $52, $47, $47, $4E, $70
	.db $4D, $4E, $70, $52, $53, $70, $4D, $4E, $70, $52, $72, $72, $4A, $70, $52, $53
	.db $70, $52, $53, $70, $52, $53, $70, $52, $45, $44, $51, $70, $52, $53, $70, $50
	.db $51, $70, $52, $53, $70, $50, $4A, $71, $70, $70, $52, $53, $70, $70, $70, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4C, $54, $53, $70, $4D, $4C, $4C, $54, $55
	.db $4C, $4C, $4A, $70, $50, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4F, $4F, $4F
	.db $4A
	.fill 13, $70
	.db $48, $47, $47, $47, $47, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $45, $44
	.db $44, $44, $44, $51, $70, $50, $51, $70, $50, $51, $70, $50, $4A, $70, $70, $70
	.db $70, $70, $70, $70, $70, $72, $72, $72, $72, $72, $4A, $70, $4D, $4C, $4C, $4E
	.db $70, $4D, $4E, $72, $58, $47, $5D, $5E, $4A, $70, $50, $4F, $56, $53, $70, $50
	.db $51, $72, $4B, $72, $72, $72, $4A, $70, $70, $70, $52, $53, $70, $70, $70, $72
	.db $4B, $72, $72, $72, $48, $47, $4E, $70, $52, $53, $70, $4D, $4E, $72, $4B, $72
	.db $72, $72, $45, $44, $51, $70, $52, $53, $70, $50, $51, $72, $5A, $44, $44, $44
	.db $4A, $70, $70, $70, $52, $53, $70, $70, $70, $72, $72, $72, $72, $72, $4A, $70
	.db $4D, $4C, $54, $53, $70, $4D, $4C, $4C, $4C, $4E, $70, $4D, $4A, $70, $50, $4F
	.db $4F, $51, $70, $50, $4F, $4F, $56, $53, $70, $52, $4A
	.fill 9, $70
	.db $52, $53, $70, $52, $48, $47, $4E, $70, $4D, $4C, $4C, $4C, $4E, $70, $52, $53
	.db $70, $52, $72, $72, $4A, $70, $52, $57, $4F, $4F, $51, $70, $50, $51, $70, $52
	.db $72, $72, $4A, $70, $52, $53, $70, $70, $70, $70, $70, $70, $70, $52, $72, $72
	.db $4A, $70, $52, $53, $70, $4D, $4C, $4C, $4C, $4E, $70, $52, $72, $72, $4A, $70
	.db $50, $51, $70, $52, $57, $4F, $4F, $51, $70, $52, $72, $72, $4A, $70, $70, $70
	.db $70, $52, $53, $70, $70, $70, $70, $52, $72, $72, $48, $47, $47, $4E, $70, $52
	.db $53, $70, $4D, $4E, $70, $52, $44, $44, $44, $44, $44, $51, $70, $50, $51, $70
	.db $52, $53, $70, $50, $72, $72, $72, $72, $72, $72, $70, $70, $70, $70, $52, $53
	.db $72, $72, $47, $47, $47, $47, $47, $4E, $70, $4D, $4E, $70, $52, $55, $4C, $4C
	.db $45, $44, $44, $44, $44, $51, $70, $50, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $4A, $71, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4C, $4A, $70
	.db $50, $4F, $4F, $4F, $4F, $4F, $51, $70, $50, $4F, $4F, $4F, $4A
	.fill 13, $70
	.db $48
	.fill 13, $47

; 30th entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from B385 to B58A (518 bytes)
DATA_B385:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4C, $4C, $4A, $70
	.db $50, $4F, $4F, $56, $57, $4F, $4F, $51, $70, $52, $57, $4F, $4A, $70, $70, $70
	.db $70, $52, $53, $70, $70, $70, $70, $52, $53, $72, $48, $47, $47, $4E, $70, $52
	.db $53, $70, $4D, $4E, $70, $50, $51, $72, $72, $72, $72, $4A, $70, $52, $53, $70
	.db $52, $53, $71, $70, $70, $70, $72, $72, $72, $4A, $70, $50, $51, $70, $52, $53
	.db $72, $4D, $4E, $72, $72, $72, $72, $4A, $70, $70, $70, $70, $52, $53, $72, $52
	.db $53, $72, $72, $72, $72, $4A, $70, $4D, $4E, $70, $52, $53, $72, $52, $55, $4C
	.db $72, $72, $72, $4A, $70, $52, $53, $70, $50, $51, $72, $50, $4F, $4F, $72, $72
	.db $72, $4A, $70, $52, $53, $70
	.fill 9, $72
	.db $4A, $70, $52, $55, $4C, $4E, $72, $58, $47, $5D, $5E, $44, $44, $44, $51, $70
	.db $50, $4F, $56, $53, $72, $4B, $72, $72, $72, $72, $72, $70, $70, $70, $70, $70
	.db $52, $53, $72, $4B, $72, $72, $72, $47, $4E, $70, $4D, $4C, $4E, $70, $52, $53
	.db $72, $4B, $72, $72, $72, $72, $4A, $70, $50, $4F, $51, $70, $50, $51, $72, $5A
	.db $44, $44, $44, $72, $4A, $70, $70, $70, $70, $70, $72, $72, $72, $72, $72, $72
	.db $72, $72, $48, $47, $47, $47, $4E, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4C, $45
	.db $44, $44, $44, $44, $51, $70, $50, $4F, $4F, $4F, $4F, $4F, $56, $4A
	.fill 12, $70
	.db $52, $4A, $70, $4D, $4C, $4C, $4C, $4C, $4C, $4E, $70, $4D, $4E, $70, $52, $4A
	.db $70, $52, $57, $4F, $4F, $4F, $56, $53, $70, $52, $53, $70, $52, $4A, $70, $52
	.db $53, $70, $70, $70, $52, $53, $70, $52, $53, $70, $52, $4A, $70, $52, $53, $70
	.db $72, $70, $52, $53, $70, $50, $51, $70, $52, $4A, $70, $52, $53, $70, $72, $70
	.db $52, $53, $70, $70, $70, $70, $52, $4A, $70, $52, $53, $70, $71, $70, $52, $53
	.db $70, $4D, $4E, $70, $52, $4A, $70, $52, $53, $70, $72, $70, $52, $53, $70, $52
	.db $53, $70, $52, $4A, $70, $52, $53, $70, $72, $70, $52, $53, $70, $52, $53, $70
	.db $50, $4A, $70, $52, $53, $70, $70, $70, $52, $53, $70, $52, $53, $72, $72, $4A
	.db $70, $52, $53, $70, $4D, $4C, $54, $53, $70, $52, $53, $70, $4D, $4A, $70, $52
	.db $53, $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $52, $4A, $70, $52, $53, $70
	.db $70, $70, $70, $70, $70, $52, $53, $70, $52, $4A, $71, $52, $55, $4C, $4C, $4E
	.db $70, $4D, $4C, $54, $53, $70, $52, $4A, $70, $50, $4F, $4F, $4F, $51, $70, $50
	.db $4F, $4F, $51, $70, $52, $4A
	.fill 12, $70
	.db $52, $48
	.fill 12, $47
	.db $64

; 31st entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from B58B to B6E8 (350 bytes)
DATA_B58B:
	.db $45
	.fill 9, $44
	.db $60, $5F, $44, $44, $4A
	.fill 9, $70
	.db $52, $53, $70, $70, $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $52, $53
	.db $70, $4D, $4A, $71, $52, $53, $70, $52, $57, $4F, $51, $70, $50, $51, $70, $52
	.db $4A, $70, $52, $53, $70, $52, $53, $70, $70, $70, $70, $70, $70, $52, $4A, $70
	.db $50, $51, $70, $50, $51, $70, $4D, $4C, $4C, $4E, $70, $52, $4A, $70, $70, $70
	.db $70, $70, $70, $70, $52, $5C, $5C, $53, $70, $52, $63, $4C, $4C, $4E, $70, $4D
	.db $4E, $70, $50, $4F, $4F, $51, $70, $50, $6A, $4F, $4F, $51, $70, $52, $53, $70
	.db $70, $70, $70, $70, $70, $70, $72, $70, $70, $70, $70, $52, $55, $4C, $4C, $4C
	.db $4C, $4E, $72, $4D, $68, $70, $4D, $4E, $70, $50, $4F, $4F, $4F, $4F, $4F, $51
	.db $72, $50, $4A, $70, $52, $53, $70, $70, $70, $72, $72, $72, $72, $72, $72, $72
	.db $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $72, $58, $47, $5D, $5E, $4A, $70
	.db $50, $4F, $4F, $51, $70, $52, $53, $72, $4B, $72, $72, $72, $4A, $70, $70, $70
	.db $70, $70, $70, $52, $53, $72, $4B, $72, $72, $72, $4A, $70, $4D, $4E, $70, $4D
	.db $4C, $54, $53, $72, $4B, $72, $72, $72, $4A, $70, $52, $53, $70, $50, $4F, $4F
	.db $51, $72, $5A, $44, $44, $44, $4A, $70, $52, $53, $70, $70, $70, $72, $72, $72
	.db $72, $72, $72, $72, $4A, $70, $52, $55, $4C, $4E, $70, $4D, $4E, $72, $4D, $4E
	.db $72, $4D, $4A, $70, $50, $4F, $4F, $51, $70, $50, $51, $72, $50, $51, $72, $50
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4C, $4C, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4A, $71
	.db $50, $4F, $4F, $51, $70, $50, $51, $70, $50, $51, $70, $50, $4A
	.fill 12, $70
	.db $72, $48
	.fill 13, $47

; 32nd entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from B6E9 to B846 (350 bytes)
DATA_B6E9:
	.db $45
	.fill 13, $44
	.db $4A
	.fill 13, $70
	.db $4A, $70, $4D, $4E, $70, $4D, $4C, $4C, $4E, $70, $4D, $4E, $70, $4D, $4A, $71
	.db $52, $53, $70, $52, $5C, $5C, $53, $70, $52, $53, $70, $50, $4A, $70, $52, $53
	.db $70, $50, $4F, $4F, $51, $70, $52, $53, $70, $70, $4A, $70, $52, $53, $70, $70
	.db $70, $70, $70, $70, $52, $53, $70, $4D, $4A, $70, $52, $55, $4C, $4E, $70, $4D
	.db $4E, $70, $52, $53, $70, $52, $4A, $70, $50, $4F, $4F, $51, $70, $50, $51, $70
	.db $50, $51, $70, $52, $4A
	.fill 12, $70
	.db $52, $48, $47, $4E, $70, $4D, $4E, $70, $4D, $4E, $70, $4D, $4E, $72, $52, $72
	.db $72, $4A, $70, $50, $51, $70, $50, $51, $70, $50, $51, $72, $50, $72, $72, $4A
	.db $70, $70, $70, $70, $72, $72, $72, $72, $72, $72, $72, $44, $44, $51, $72, $4D
	.db $4E, $70, $4D, $4E, $72, $58, $47, $5D, $5E, $72, $72, $72, $72, $52, $53, $70
	.db $50, $51, $72, $4B, $72, $72, $72, $4C, $4C, $4C, $4C, $54, $53, $70, $72, $72
	.db $72, $4B, $72, $72, $72, $4F, $4F, $4F, $4F, $4F, $51, $70, $4D, $4E, $72, $4B
	.db $72, $72, $72, $72, $70, $70, $70, $70, $70, $70, $52, $53, $72, $5A, $44, $44
	.db $44, $68, $70, $4D, $4C, $4C, $4E, $70, $52, $53, $72, $72, $72, $72, $72, $4A
	.db $70, $50, $4F, $56, $53, $70, $52, $55, $4C, $4C, $4C, $4C, $4C, $4A, $70, $70
	.db $70, $52, $53, $70, $50, $4F, $4F, $4F, $4F, $4F, $56, $48, $47, $4E, $70, $52
	.db $53, $70, $70, $70, $70, $72, $72, $72, $52, $72, $72, $4A, $71, $52, $55, $4C
	.db $4C, $4E, $70, $4D, $4E, $72, $52, $72, $72, $4A, $70, $50, $4F, $4F, $4F, $51
	.db $70, $52, $53, $72, $50, $72, $72, $4A, $70, $70, $70, $70, $70, $70, $70, $52
	.db $53, $72, $72, $72, $72, $48, $47, $47, $47, $47, $47, $47, $47, $64, $65, $47
	.db $47

; 33rd entry of Pointer Table from 8054 (indexed by $DA3D)
; Data from B847 to BFFF (1977 bytes)
DATA_B847:
	.db $45
	.fill 13, $44
	.db $4A, $71
	.fill 12, $70
	.db $4A, $70, $72, $72, $72, $72, $72, $72, $72, $70, $4D, $47, $47, $47, $4A, $70
	.db $72, $72, $72, $72, $72, $72, $72, $70, $4B, $72, $72, $72, $4A
	.fill 9, $70
	.db $4B, $72, $72, $72, $4A, $70, $72, $72, $72, $70, $4D, $47, $4E, $70, $50, $44
	.db $44, $44, $4A, $70, $70, $70, $70, $70, $4B, $72, $4A, $70, $70, $70, $70, $70
	.db $48, $47, $4E, $70, $4D, $47, $49, $72, $4A, $72, $4D, $47, $47, $47, $72, $72
	.db $4A, $70, $4B, $72, $72, $72, $4A, $72, $4B, $72, $72, $72, $45, $44, $51, $70
	.db $50, $44, $46, $72, $4A, $72, $4B, $72, $72, $72, $4A, $70, $70, $70, $70, $70
	.db $4B, $72, $4A, $72, $50, $44, $44, $44, $4A, $70, $72, $72, $72, $70, $4B, $72
	.db $4A, $72, $72, $72, $72, $72, $4A, $70, $72, $72, $72, $70, $4B, $72, $4A, $72
	.db $4D, $47, $5D, $5E, $4A, $70, $72, $71, $72, $70, $4B, $72, $4A, $72, $4B, $72
	.db $72, $72, $4A, $70, $72, $72, $72, $70, $4B, $72, $4A, $72, $4B, $72, $72, $72
	.db $4A, $70, $70, $70, $70, $70, $4B, $72, $4A, $72, $4B, $72, $72, $72, $48, $47
	.db $4E, $70, $4D, $47, $49, $72, $4A, $72, $50, $44, $44, $44, $72, $72, $4A, $70
	.db $4B, $72, $72, $72, $4A, $72, $72, $72, $72, $72, $72, $72, $4A, $70, $50, $44
	.db $44, $44, $51, $72, $72, $72, $72, $72, $72, $72, $4A
	.fill 11, $70
	.db $72, $72, $4A, $70, $72, $72, $72, $72, $72, $72, $72, $70, $72, $72, $72, $72
	.db $4A, $70, $72, $72, $72, $70, $70, $70, $70, $70, $72, $72, $44, $44, $51, $70
	.db $72, $72, $72, $70, $4D, $47, $4E, $70, $72, $72, $72, $72, $72, $70, $72, $72
	.db $72, $70, $4B, $72, $4A, $70, $72, $72, $61, $4C, $4E, $70, $72, $72, $72, $70
	.db $4B, $72, $4A, $70, $72, $72, $62, $4F, $51, $70, $72, $72, $72, $70, $4B, $72
	.db $4A, $70, $70, $70, $4A, $70, $70, $70, $70, $71, $70, $70, $4B, $72, $48, $47
	.db $47, $47, $4A, $70, $72, $72, $72, $72, $72, $70, $4B, $72, $72, $72, $72, $72
	.db $4A, $70, $72, $72, $72, $72, $72, $70, $4B, $72, $4D, $47, $47, $47, $4A, $70
	.db $70, $70, $70, $70, $70, $70, $4B, $72, $4B, $72, $72, $72, $48, $47, $47, $47
	.db $47, $47, $47, $47, $49, $72, $50, $44, $44, $44
	.fill 135, $FF
	.fill 128, $00
	.fill 128, $FF
	.fill 61, $00
	.db $0F
	.fill 32, $00
	.db $F0
	.fill 161, $00
	.fill 128, $FF
	.fill 128, $00
	.fill 61, $FF
	.db $F0
	.fill 32, $FF
	.db $0F
	.fill 161, $FF
	.fill 128, $00
	.fill 128, $FF
	.fill 61, $00
	.db $0F
	.fill 32, $00
	.db $F0
	.fill 33, $00

#include "src/includes/ti_equates.asm"
#undef lcdWidth
#define lcdWidth 256
#include "src/MSPacMan/screen_drawing_routines.asm"
#include "src/MSPacMan/appvars.asm"

Appvar_End:
.ORG Appvar_End - romStart
