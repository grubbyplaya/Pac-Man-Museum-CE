.ASSUME ADL=1

DrawMainTilemap:
	ld	bc, $0040
	call	SetMainCoords
	jr	DrawTiles

DrawHUDTilemap:
	ld	bc, $03C2
	call	SetHUDCoords
	jr	DrawTiles

DrawLivesTilemap:
	ld	bc, $0002
	call	SetLivesCoords
	jr	DrawTiles

DrawTiles:
	ld	ix, Tilemap
	add	ix, bc
	ld	iy, ColorTable
	add	iy, bc
	ld	hl, PrevTilemap
	add	hl, bc

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
	ld	a, (iy)
	; palette mirroring makes level 256 look "right"
	and	$1F
	ld	c, a
	sla	c
	sla	c
	exx
	call	DrawTile

	; inc tile pointers
TileCoordsPTR = $+1
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
TileOffset = $+1
	ld	hl, ScreenPTR + 16 + (16*256)
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

	; are we done?
	ld	a, (hl)
	cp	$FF
	ret	nz

	; bail out
	inc	b
	ret

IncHUDCoords:
	ld	b, 0
	ld	hl, TileCoords

	; dec X coordinate
	dec	(hl)
	ld	a, (hl)
	cp	$FF
	ret	nz

	ld	bc, 4
	add	ix, bc
	add	iy, bc

	; inc Y coordinate, go to next row
	ld	(hl), 27
	inc	hl
	inc	(hl)

	; are we done?
	ld	a, (hl)
	cp	3
	ret	nz

	; bail out
	inc	b
	ret

SetMainCoords:
	ld	hl, TileCoords
	ld	(hl), 27
	inc	hl
	ld	(hl), 0

	ld	hl, IncTileCoords
	ld	(TileCoordsPTR), hl

	ld	hl, ScreenPTR + 16 + (16*256)
	ld	(TileOffset), hl
	ret

SetHUDCoords:
	ld	hl, ScreenPTR + 16
	ld	(TileOffset), hl

SetHUDCoords_Merge:
	ld	hl, IncHUDCoords
	ld	(TileCoordsPTR), hl

	ld	hl, TileCoords
	ld	(hl), 27
	inc	hl
	ld	(hl), 0
	ret

SetLivesCoords:
	ld	hl, ScreenPTR + 16 + (272*256)
	ld	(TileOffset), hl
	jr	SetHUDCoords_Merge

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
	ld	ix, CoordsTable + 2
	ld	iy, SpriteTable + 2
	ld	b, 6

DrawSprites_Loop:
	push	bc

	call	GetSpriteCoords

	; if the sprite's not visible, go to the next one
	dec	c
	jr	nz, +_

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

_:	lea	ix, ix + 2
	lea	iy, iy + 2
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
	ld	bc, $0D1323
	ld	(SetPixelOrder), bc

	ex	de, hl
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
	jr	DrawSprite

DrawSprite_XFlip:
	ld	bc, 256 + 16
	ld	(SetSpriteGap), bc

	; LD BC, DEC HL \ INC DE \ DEC C
	ld	bc, $0D132B
	ld	(SetPixelOrder), bc

	ex	de, hl
	ld	bc, 15
	add	hl, bc
	jr	DrawSprite

DrawSprite_XYFlip:
	ld	bc, -256 + 16
	ld	(SetSpriteGap), bc

	; LD BC, DEC HL \ INC DE \ DEC C
	ld	bc, $0D132B
	ld	(SetPixelOrder), bc

	ex	de, hl
	ld	bc, (256 * 15) + 15
	add	hl, bc
	jr	DrawSprite

DrawSprite:
	push	af
	ld	b, 16

	; one row loop
_:	ld	c, 16

	; get sprite pixel
_:	ld	a, (de)
	or	a

	; skip if it's transparent (0)
	jr	z, +_

	; add color offset
	exx
	or	c
	exx

	; write to screen
	ld	(hl), a

	; go to next pixel
SetPixelOrder = $
_:	inc	hl
	inc	de
	dec	c
	jr	nz, --_

	; go to next line
	push	bc
SetSpriteGap = $+1
	ld	bc, 256 - 16
	add	hl, bc
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
	cp	7
	jr	nz, --_
	ret

SaveSpriteBG:
	; calc where we should save the BG
	ld	b, 7
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