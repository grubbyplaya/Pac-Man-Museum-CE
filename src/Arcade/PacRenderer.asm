.ASSUME ADL=1

DrawTilemap:
	ld	ix, Tilemap + $40
	ld	iy, ColorTable + $40
	ld	hl, PrevTilemap + $40

	; if the tile hasn't changed between frames, skip it	
_:	push	hl
	ld	a, (ix)
	cp	(hl)
	jr	z, +_

	ld	(hl), a
	; DE = tile screen coords
	call	GetTileCoords

	; load HL with a pointer to the tile
	ld	c, (ix)
	ld	b, 64
	mlt	bc
	ld	hl, TileROM
	add	hl, bc

	; load C' with the tile palette
	exx
	ld	c, (iy)
	sla	c
	sla	c
	exx
	call	DrawTile

	; inc tile pointers
_:	call	IncTileCoords
	pop	hl
	inc	ix
	inc	iy
	inc	hl
	; loop until B is set to 1
	djnz	--_
	ret

GetTileCoords:
	ld	hl, TileCoords + 1

	; calc Y coords
	ld	e, (hl)
	ld	d, 8
	; E = tile's Y coords
	mlt	de
	; save it for later
	ld	a, e

	; calc X coords
	dec	hl
	ld	e, (hl)
	ld	d, 8
	; E = tile's X coords
	mlt	de
	ld	d, a

	; DE = tile's screen coords
	ld	hl, ScreenPTR + 16 + (256 * 16)
	add	hl, de
	ex	de, hl
	ret

IncTileCoords:
	ld	b, 0
	ld	hl, TileCoords + 1

	; inc Y coordinate
	inc	(hl)
	ld	a, (hl)
	cp	32
	ret	c
	
	ld	(hl), 0
	; dec X coordinate, go to next column
	dec	hl
	dec	(hl)
	ld	a, (hl)
	cp	$FF
	ret	nz

	; bail out
	inc	b

	ld	(hl), 27
	inc	hl
	ld	(hl), 0
	ret

TileCoords:
	.db 27, 0

DrawTile:	; IN: HL = tile data, DE = tile pos, C' = tile palette
	ld	b, 8

	; one row loop
_:	ld	c, 8

	; get sprite pixel
_:	ld	a, (hl)
	; add color offset
	exx
	or	c
	exx
	; write to screen
	ld	(de), a

	; go to next pixel
	inc	hl
	inc	de
	dec	c
	jr	nz, -_

	; go to next line
	push	bc
	ex	de, hl
	ld	bc, 256 - 8
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	--_
	ret

DrawSprites:
	ld	ix, CoordsTable
	ld	iy, SpriteTable
	ld	b, 8

DrawSprites_Loop:
	push	bc

	call	GetSpriteCoords
	; if the sprite's not visible, go to the next one
	ld	a, c
	or	a
	jr	z, +_

	; load sprite art PTR in HL
	ld	hl, SpriteROM
	ld	bc, 0
	ld	b, (iy + 0)
	srl	b
	srl	b
	add	hl, bc

	; store sprite palette offset in C'
	exx
	ld	c, (iy + 1)
	sla	c
	sla	c
	exx

	; figure out how to draw the sprite
	ld	a, (iy + 0)
	and	$03

	; 00 - No Flip
	or	a
	call	z, DrawSprite_Normal

	; 01 - Y Flip
	dec	a
	call	z, DrawSprite_YFlip

	; 10 - X Flip
	dec	a
	call	z, DrawSprite_XFlip

	; 11 - Double Flip
	dec	a
	call	z, DrawSprite_XYFlip

_:	lea	ix, ix+2
	lea	iy, iy+2
	pop	bc
	djnz	DrawSprites_Loop
	ret

GetSpriteCoords:	; also checks sprite bounds
	ld	c, 0

	ld	hl, 0
	; load HL with the sprite coordinates
	ld	a, 256 - 1
	sub	a, (ix + 0)	; A = X pos

	; bail out if the sprite's hidden
	or	a
	ret	z
	cp	240 - 1
	ret	nc
	inc	c

	; L = X pos
	ld	l, a

	xor	a
	sub	a, (ix + 1)
	ld	h, a

	; load DE with the sprite position
	ld	de, ScreenPTR + (256 * 16)
	add	hl, de
	ex	de, hl
	ret

DrawSprite_Normal:
	ld	bc, 256 - 16
	ld	(SetSpriteGap), bc

	;LD BC, INC HL \ INC DE \ DEC C
	ld	bc, $23130D
	ld	(SetPixelOrder), bc
	jr	DrawSprite

DrawSprite_YFlip:
	ld	bc, -256 - 16
	ld	(SetSpriteGap), bc

	; LD BC, INC HL \ INC DE \ DEC C
	ld	bc, $0D1323
	ld	(SetPixelOrder), bc

	ex	de, hl
	ld	bc, 256 * 15
	add	hl, bc
	ex	de, hl
	jr	DrawSprite

DrawSprite_XFlip:
	ld	bc, 256 + 16
	ld	(SetSpriteGap), bc

	; LD BC, INC HL \ DEC DE \ DEC C
	ld	bc, $0D1B23
	ld	(SetPixelOrder), bc

	ex	de, hl
	ld	bc, 15
	add	hl, bc
	ex	de, hl
	jr	DrawSprite

DrawSprite_XYFlip:
	ld	bc, -256 + 16
	ld	(SetSpriteGap), bc

	; LD BC, INC HL \ DEC DE \ DEC C
	ld	bc, $0D1B23
	ld	(SetPixelOrder), bc

	ex	de, hl
	ld	bc, (256 * 15) + 15
	add	hl, bc
	ex	de, hl
	jr	DrawSprite

DrawSprite:
	push	af
	ld	b, 16

	; one row loop
_:	ld	c, 16

	; get sprite pixel
_:	ld	a, (hl)
	or	a

	; skip if it's transparent (0)
	jr	z, +_

	; add color offset
	exx
	or	c
	exx

	; write to screen
	ld	(de), a

	; go to next pixel
SetPixelOrder = $
_:	inc	hl
	inc	de
	dec	c
	jr	nz, --_

	; go to next line
	push	bc
	ex	de, hl
SetSpriteGap = $+1
	ld	bc, 256 - 16
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	---_
	pop 	af
	ret

PartialRedraw:
	xor	a
_:	push	af
	ld	l, a
	ld	h, 129
	mlt	hl
	add	hl, hl
	ld	de, TempSpriteBuffer
	; HL = where the BG will get copied to
	add	hl, de

	; A = Y coord
	ld	a, (hl)
	inc	hl
	; E = X coord
	ld	e, (hl)
	inc	hl

	; save for later
	push	hl
	; clear HLU
	sbc	hl, hl

	ld	l, e
	ld	h, a
	ld	de, ScreenPTR + (256 * 16)
	add	hl, de
	ex	de, hl
	; HL = sprite background position
	; DE = sprite framebuffer destination
	pop	hl

	ld	b, 16
_:	push	bc

	ld	bc, 16
	ldir

	ex	de, hl
	ld	bc, 256 - 16
	add	hl, bc
	ex	de, hl

	pop	bc
	djnz	-_

	pop	af
	inc	a
	cp	8
	jr	nz, --_
	ret

SaveSpriteBG:
	; calc where we should save the BG
	ld	b, 8
	ld	ix, CoordsTable + $0E

_:	push	bc

	; set HL to partial redraw buffer ptr
	ld	l, b
	dec	l
	ld	h, 129
	mlt	hl
	add	hl, hl
	ld	de, TempSpriteBuffer
	add	hl, de

	; calc and store true sprite coords
	ex	de, hl
	sbc	hl, hl

	xor	a
	sub	a, (ix + 1)
	ld	h, a
	ld	(de), a
	inc	de

	ld	a, $FF
	sub	a, (ix)
	ld	l, a
	ld	(de), a
	inc	de

	push	de
	ld	de, ScreenPTR + (256 * 16)
	add	hl, de
	pop	de

	; HL = bg behind sprite
	; DE = partial redraw buffer
	ld	b, 16
_:	push	bc

	ld	bc, 16
	ldir

	ld	bc, 256 - 16
	add	hl, bc

	pop	bc
	djnz	-_

	lea	ix, ix-2
	pop	bc
	djnz	--_
	ret

Colors:
.dw $0000, $7C00, $6A4A, $FEDF, $0000, $83FF, $A2DF, $FECA, $0000, $FFE0, $0000, $909F, $83E0, $A2D4, $FED4, $6B7F

Palette:
 #import "src/Arcade/includes/palette.bin"

ConvertPalette:
	ld	ix, Palette
	ld	iy, mpLcdPalette
	ld	de, 0
	ld	bc, 256

_:	ld	a, (ix)
	add	a, a
	ld	e, a
	ld	hl, Colors
	add	hl, de
	ld	hl, (hl)
	ld	(iy), hl

	inc	ix
	lea	iy, iy+2

	dec	bc
	ld	a, b
	or	c
	jr	nz, -_
	ret

RenderEnd: