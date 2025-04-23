; These routines take data from VDP RAM and translates them into a usable frame.
.ASSUME ADL=0

#undef SegaTileFlags

#define TilemapCache		RenderedScreenMap
#define TempSpriteBuffer	TilemapCache + $0300
#define SegaTileFlags		TempSpriteBuffer + $0810
#define SegaTileCache		SegaTileFlags + $0100

DrawScreen:

 .org	$D40000 + DrawScreen

	; do some partial redraw stuff
	call.lil PartialRedraw

	; start drawing the tilemap
	ld	a, (DrawTilemapTrig)
	bit	0, a
	call.lil nz, DrawScreenMap
	
	; start drawing the SAT
	call.lil DrawSAT

	xor	a
	ld	(DrawSATTrig), a
	ld	(DrawTilemapTrig), a
	ret
.ASSUME ADL=1

DrawScreenMap:
	ld	hl, ScreenMap
	ld	de, TilemapCache
	ld	bc, 32*24

_:	push	bc
	push	de
	push	hl

	ld	a, (de)
	cp	(hl)
	call	nz, DrawScreenMap_Tiles
	call	IncTileCoords

	pop	hl
	pop	de
	pop	bc

	inc	hl
	inc	de
	dec	bc
	ld	a, b
	or	c
	jr	nz, -_

	; clear tile coords
	ld	hl, 0
	ld	(TileCoords), hl

	call	CacheScreenMap
	ret.sis

IncTileCoords:
	; inc the tile column
	ld	hl, TileCoords
	inc	(hl)

	; if we're haven't finished the row, bail out
	ld	a, 32
	cp	(hl)
	ret	nz

	; go to next tile row
	ld	(hl), 0
	inc	hl
	inc	(hl)
	ret

TileCoords:
	;   X, Y
	.db 0, 0

TileColor:
	.db 0

DrawScreenMap_Tiles:
	ld	de, DrawBlackPixel
	ld	(DrawPixelJump+1), de

	ld	de, SegaTileFlags
	ld	e, (hl)
	ld	a, (de)
	or	a
	jp	nz, DrawCachedTile

	inc	a
	ld	(de), a

	ld	a, (hl)
	push	af
	call	GetTilePointer
	call	GetTileCoordinates
	pop	af

	; get the tile color
	push	hl
	and	$F8
	rrca
	rrca
	rrca
	ld	hl, ColorTable
	ld	bc, 0
	ld	c, a
	add	hl, bc
	ld	a, (hl)
	rrca
	rrca
	rrca
	rrca
	ld	ix, TileColor
	ld	(ix), a
	pop	hl
	
	call	ConvertTileTo8bpp

DrawScreenMap_Epilogue:
	; reset self-modifying code
	ld	de, DontDrawPixel
	ld	(DrawPixelJump+1), de
	ret

GetTilePointer:		; makes HL a pointer to the selected tile
	ld	l, (hl)
	ld	h, 8
	mlt	hl

	ld	de, PatternGen
	ex	de, hl
	add	hl, de
	ex	de, hl

	add	hl, hl
	add	hl, hl
	add	hl, hl

	ld	bc, SegaTileCache
	add	hl, bc
	push	hl
	pop	iy		; IY = BG tile cache
	ex	de, hl
	ret
	
GetTileCoordinates:
	ld	ix, TileCoords
	push	hl

	; set L to the Y position
	ld	l, $08
	ld	h, (ix + 1)
	mlt	hl

	; set E to the X position
	ld	e, $08
	ld	d, (ix)
	mlt	de
	
	; convert to a 16-bit offset
	ld	h, l
	ld	l, e

	; set DE to the tile's screen position
	ld	de, ScreenPTR
	add	hl, de
	ex	de, hl

	; restore HL, exit
	pop	hl
	ret

CacheScreenMap:
	ld	hl, ScreenMap
	ld	de, TilemapCache
	ld	bc, $0300
	ldir
	ret

DrawCachedTile:
	call	GetTilePointer
	call	GetTileCoordinates
	ld	a, 8
	lea	hl, iy
_:	ld	bc, 8
	ldir
	ex	de, hl
	ld	bc, 256 - 8
	add	hl, bc
	ex	de, hl
	dec	a
	jr	nz, -_
	jp	DrawScreenMap_Epilogue

DrawSAT:	; draws all the sprites, from most to least significant
	call	SaveSpriteBG	; save the pixels behind the sprites

	; set the sprite length to 16
	ld	a, 16
	ld	(SpriteLength), a

	; point IX to the SAT table
	ld	ix, SAT
	ld	iy, SegaTileCache + $4000

	; set B to the # of SAT entries (32)
	ld	b, 32

DrawSAT_Loop:
	ld	h, (ix)
	ld	a, 208
	cp	h		; is the sprite's Y position 208?
	ret.sis	z		; stop rendering SAT if so

	push	bc

	; skip if the Y coords are out of bounds
	ld	a, 175
	cp	h
	jr	c, +_

	; skip if the same applies to the X coords
	ld	a, (ix + 1)
	cp	9
	jr	c, +_

	; draw the left half of the sprite
	xor	a
	ld	bc, 0
	call	DrawSpriteStrip

	; draw the right half of the sprite
	ld	a, 8
	ld	bc, 2
	call	DrawSpriteStrip

	; loop to next sprite
_:	lea	ix, ix + 4
	pop	bc
	djnz	DrawSAT_Loop

	ld	a, 8
	ld	(SpriteLength), a
	ret.sis

DrawSpriteStrip:	; IN: A = strip offset, BC = tile offset
	; A = sprite's X coords
	add	a, (ix + 1)
	call	SetSpriteCoords
	ex	de, hl

	; L = sprite tile
	ld	l, (ix + 2)
	add	hl, bc
	call	SetSpritePTR
	ret

SetSpriteCoords:
	ld	h, (ix)
CalcSpriteCoords:
	; clear HLU
	ld	de, 0
	add.sis	hl, de

	; HL = sprite's screen position
	ld	l, a
	ld	de, ScreenPTR
	add	hl, de
	ret

SetSpritePTR:
	ld	h, 8		; size of tile
	mlt	hl
	push	de
	ld	de, SpritePTR
	add	hl, de		; HL now points to the specified tile
	pop	de		; DE has the tile's coordinates

	; IX now points to the sprite color
	lea	ix, ix + 3
	call	ConvertTileTo8bpp
	lea	ix, ix - 3
	ret

SaveSpriteBG:
	; calc where we should save the BG
	ld	b, 8
	ld	ix, SAT

SaveSpriteBG_Loop:
	ld	a, (ix)
	cp	$D0
	ret	z

	push	bc
	ld	a, (ix + 1)
	call	SetSpriteCoords
	ex	de, hl

	ld	a, ixl
	rrca
	rrca
	ld	l, a
	ld	h, 129
	mlt	hl
	add	hl, hl
	ld	bc, TempSpriteBuffer
	add	hl, bc

	; save the coords
	ld	a, (ix)	
	ld	(hl), a
	inc	hl
	ld	a, (ix + 1)
	ld	(hl), a
	inc	hl
	ex	de, hl

	ld	a, 16
_:	ld	bc, 16
	ldir
	ld	bc, 256 - 16
	add	hl, bc
	dec	a
	jr	nz, -_

	pop	bc
	lea	ix, ix + 4
	djnz	SaveSpriteBG_Loop
	ret

PartialRedraw:
	xor	a
PartialRedrawLoop:
	push	af

	; point HL to the BG portion
	ld	l, a
	ld	h, 129
	mlt	hl
	add	hl, hl
	ld	de, TempSpriteBuffer
	add	hl, de

	; get the BG portion's screen position
	push	hl
	; A = Y coord
	ld	a, (hl)
	cp	192
	jr	nc, PartialRedraw_LoopBack

	inc	hl
	; L = X coord
	ld	l, (hl)
	ld	h, a
	ld	a, l

	call	CalcSpriteCoords
	; DE = BG portion screen position
	ex	de, hl

	pop	hl
	inc	hl
	inc	hl

	; draw the cached BG portion
	ld	a, 16
_:	ld	bc, 16
	ldir
	ex	de, hl
	ld	bc, 256 - 16
	add	hl, bc
	ex	de, hl
	dec	a
	jr	nz, -_

_:	pop	af
	inc	a
	cp	8
	jr	nz, PartialRedrawLoop
	ret.sis

PartialRedraw_LoopBack:
	pop	hl
	jr	-_

; =============================================================================
; 	In:
; 	HL	- Pointer to pattern.
; 	DE	- Position of tile.
; 	(IX)	- Tile's color.
; 	ld:
; 	None.
; 	Destroys:
; 	A, C, DE, HL
; -----------------------------------------------------------------------------

ConvertTileTo8bpp:
SpriteLength = $+1
	ld	c, $08
_:	call	ConvertPixelRow
	push	hl
	ex	de, hl
	ld	de, 256 - 8
	add	hl, de
	ex	de, hl
	pop	hl
	dec	c
	jr	nz, -_
	ret

ConvertPixelRow:		; converts pixels from a 1bpp to a nybble
	push	hl
	exx
	pop	hl
	ld	e, $08
	ld	b, (hl)

_:	rlc	b
	exx
DrawPixelJump:
	jp	nc, DontDrawPixel
	ld	a, (ix)
	ld	(de), a
	ld	(iy), a
DontDrawPixel:
	inc	de
	inc	iy
	exx
	dec	e
	jr	nz, -_
	exx
	inc	hl
	ret

DrawBlackPixel:
	push	af
	xor	a
	ld	(de), a
	ld	(iy), a
	pop	af
	jp	DontDrawPixel

ClearTileFlags:
	ld	hl, SegaTileFlags
	ld	de, SegaTileFlags + 1
	ld	bc, $0100
	ld	(hl), $00
	ldir
	ret.sis

Draw8bppTileEnd:
.ORG	Draw8bppTileEnd-romStart
.ASSUME ADL=0