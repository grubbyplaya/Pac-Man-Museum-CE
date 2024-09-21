
;These routines take data from VDP RAM and translates them into a usable frame.
.ASSUME ADL=0

#define VDP_HScroll	$D418
#define VDP_VScroll	$D419
#define TilemapCache	pixelShadow
#define PatternGen	SegaVRAM
#define ColorTable	SegaVRAM+$2000

DrawScreen:
 .org	DrawScreen+$D20000
	;do some partial redraw stuff
	call	StoreRegisters
	ld	a, (DrawSATTrig)
	or	a
	call.lil PartialRedraw

	;start drawing the tilemap
	ld	a, (DrawTilemapTrig)
	bit	0, a
	call.lil nz, DrawScreenMap
	
	;start drawing the SAT
	ld	a, (DrawSATTrig)
	or	a
	call.lil DrawSAT

	xor	a
	ld	(DrawSATTrig), a
	ld	(DrawTilemapTrig), a
	call	RestoreRegisters
	ret
.ASSUME ADL=1

DrawScreenMap:
	xor	a
	ld	ixh, a				;x position of tile (in tiles)
	ld	ixl, a				;y position (in tiles)
	ld	hl, ScreenMap
	ld	de, TilemapCache
	ld	bc, 32*24
_:	push	bc
	push	de
	ld	a, (de)
	cp	(hl)
	call	nz, DrawScreenMap_Tiles

_:	inc	ixh				;update counters
	ld	a, 32
	cp	ixh
	jr	nz, +_
	ld	ixh, $00
	inc	ixl

_:	pop	de
	pop	bc
	inc	hl
	inc	de
	dec	bc
	ld	a, b
	or	c
	jr	nz, ---_
	call	CacheScreenMap
	ret.sis

DrawScreenMap_Tiles:
	xor	a
	ld	($D2DE06), a			;reset the SAT drawing flag
	ld	de, DrawBlackPixel
	ld	(DrawPixelJump+1), de

	ld	de, SegaTileFlags
	ld	a, (hl)
	ld	e, a
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

	;get the tile color
	push	iy
	and	$F8
	rrca
	rrca
	rrca
	ld	iy, ColorTable
	ld	bc, 0
	ld	c, a
	add	iy, bc
	ld	a, (iy)
	rrca
	rrca
	rrca
	rrca
	pop	iy
	
	call	ConvertTileTo8bpp
DrawScreenMap_Epilogue:
	;reset self-modifying code
	ld	hl, ($D2DD00)
	ld	de, DontDrawPixel
	ld	(DrawPixelJump+1), de
	ret

GetTilePointer:		;makes HL a pointer to the selected tile
	ld	a, (hl)
	push	hl
	ld	h, 8
	ld	l, a
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
	pop	iy		;IY = BG tile cache
	ex	de, hl
	pop	bc
	ld	($D2DD00), bc
	ret
	
GetTileCoordinates:
	exx
	ld	l, $08
	ld	a, ixl
	ld	h, a
	mlt	hl		;HL has the Y coordinate
	ld	h, 160
	mlt	hl
	add	hl, hl

	ld	e, $08
	ld	a, ixh
	ld	d, a
	mlt	de		;DE has the X coordinate	
	add	hl, de

	ld	de, VRAM+$1E18
	add	hl, de
	push	hl		;DE has the tile's coordinate
	exx
	pop	de
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
	ld	bc, 312
	add	hl, bc
	ex	de, hl
	dec	a
	jr	nz, -_
	jp	DrawScreenMap_Epilogue

DrawSAT:	;draws all the sprites, from most to least significant
	call	SaveSpriteBG	;save the stuff behind the sprite
	ld	a, 1
	ld	($D2DE06), a
	ld	ix, SAT		;y position
	ld	iy, SegaTileCache + $4000
	ld	b, $20		;number of SAT entries

_:	ld	h, (ix)
	ld	a, 208
	cp	h		;is the sprite's Y position 208?
	ret.sis	z		;stop rendering SAT if so

	;is the sprite off-screen?
	ld	a, 175
	cp	h
	jr	c, +_		;skip this sprite
	ld	a, (ix+1)
	cp	8
	jr	c, +_		;check if the same applies to Y coords
	cp	$F8
	jr	nc, +_

	call	SetSpriteCoords	;set sprite coordinates
	ex	de, hl		;HL now points to the tile's top-left corner
	ld	l, (ix+2)
	call	SetSpritePTR

	;draw the bottom-left corner of the sprite
	ld	a, (ix)
	add	a, 8
	ld	h, a
	ld	a, (ix+1)
	call	SetSpriteCoords	;set sprite coordinates
	ex	de, hl		;HL now points to the tile's bottom-left corner
	ld	l, (ix+2)
	inc	l
	call	SetSpritePTR

	;draw the top-right corner of the sprite
	ld	h, (ix)
	ld	a, (ix+1)
	add	a, 8
	call	SetSpriteCoords	;set sprite coordinates
	ex	de, hl		;HL now points to the tile's top-right corner
	ld	l, (ix+2)
	inc	l
	inc	l
	call	SetSpritePTR

	;draw the bottom-right corner of the sprite
	ld	a, (ix)
	add	a, 8
	ld	h, a
	ld	a, (ix+1)
	add	a, 8
	call	SetSpriteCoords	;set sprite coordinates
	ex	de, hl		;HL now points to the tile's bottom-right corner
	ld	l, (ix+2)
	inc	l
	inc	l
	inc	l
	call	SetSpritePTR

_:	lea	ix, ix+4	;point IX to the next entry
	djnz	--_
	ret.sis

SetSpriteCoords:
	ld	l, 160
	mlt	hl
	add	hl, hl		;HL now has the scanline to start on
	ld	de, $0020
	add	hl, de		;move into the letterbox
	ld	e, a
	add	hl, de		;DE has the tile's coordinates
	ld	de, VRAM+$1F38	;first scanline to be updated
	add	hl, de
	ret

SetSpritePTR:
	ld	h, 8		;size of tile
	mlt	hl
	push	de
	ld	de, SegaVRAM + $3800
	add	hl, de		;HL now points to the specified tile
	pop	de		;DE has the tile's coordinates
	ld	a, (ix+3)
	call	ConvertTileTo8bpp
	ret

SaveSpriteBG:
	;calc where we should save the BG
	ld	b, 8
	ld	ix, SAT
_:	exx
	ld	h, (ix)
	ld	a, (ix+1)
	call	SetSpriteCoords
	ld	a, ixl
	rrca
	rrca
	ld	e, a
	ld	d, 129
	mlt	de
	ex	de, hl
	add	hl, hl
	ld	bc, TempSpriteBuffer
	add	hl, bc

	;save the coords
	ld	a, (ix)	
	ld	(hl), a
	inc	hl
	ld	a, (ix+1)
	ld	(hl), a
	inc	hl
	ex	de, hl

	ld	a, 16
_:	ld	bc, 16
	ldir
	ld	bc, 304
	add	hl, bc
	dec	a
	jr	nz, -_
	exx
	lea	ix, ix+4
	djnz	--_
	ret

PartialRedraw:
	xor	a
_:	push	af
	ld	l, a
	ld	h, 129
	mlt	hl
	add	hl, hl
	ld	de, TempSpriteBuffer
	add	hl, de			;HL = location of BG portion in RAM

	push	hl
	ld	a, (hl)
	inc	hl
	ld	l, (hl)
	ld	h, a
	ld	a, l
	or	a
	jr	z, +++_

	call	SetSpriteCoords
	ex	de, hl			;DE = where we're gonna copy the portion to
	pop	hl
	inc	hl
	inc	hl

	ld	a, 16
_:	ld	bc, 16
	ldir
	ex	de, hl
	ld	bc, 304
	add	hl, bc
	ex	de, hl
	dec	a
	jr	nz, -_
_:	pop	af
	inc	a
	cp	8
	jr	nz, ---_
	ret.sis

_:	pop	hl
	jr	--_

; =============================================================================
;	In:
;	HL	- Pointer to pattern.
;	DE	- Position of tile.
;	A	- Tile's color
;	ld:
;	None.
;	Destroys:
;	A, C, DE, HL
; -----------------------------------------------------------------------------

ConvertTileTo8bpp:
	ld	c, $08
_:	push	af
	call	ConvertPixelRow
	push	hl
	ex	de, hl
SetScanlineSkip:
	ld	de, lcdWidth-8
	add	hl, de
	ex	de, hl
	pop	hl
	pop	af
	dec	c
	jr	nz, -_
	ret
	

ConvertPixelRow:		;converts pixels from a 1bpp to a nybble
	push	hl
	exx
	pop	hl
	and	$0F
	ld	e, $08
	ld	b, (hl)

_:	rlc	b
	exx
DrawPixelJump:
	jp	nc, DontDrawPixel
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

Draw8bppTileEnd:
.ORG	Draw8bppTileEnd-romStart
.ASSUME ADL=0