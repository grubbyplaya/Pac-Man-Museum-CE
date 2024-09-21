#define AnimParams 	PixelShadow	;11 byte chunks

SetupAnims:
	ld	a, (CurrentAnim)
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	de, TotalAnimations
	add	hl, de
	ld	ix, (hl)
	ld	iy, AnimParams

	;load sprite X and Y coords
	xor	a
_:	push	af
	push	ix
	ld	ix, (ix)	;IX = sprite animation table

	ld	l, a
	ld	h, 4
	mlt	hl
	ld	de, Sprite1Pos
	add	hl, de		;HL = sprite start and end coords
	lea	de, iy
	ld	bc, 4
	ldir

	inc	a
	ld	(TitleLoop+1), a

	ld	hl, (ix)
	ld	(iy+5), hl	;IY+5 = PTR to sprite animation type

	ld	a, (ix+3)
	ld	(iy+11), a	;IY+11 = sprite magnification amount

	lea	ix, ix+4
	ld	(iy+8), ix	;IX+8 = PTR to sprite image table

	ld	a, (hl)
	ld	(iy+4), a
	pop	ix
	lea	ix, ix+3
	lea	iy, iy+12

	ld	a, (ix)
	or	(ix+2)
	jr	z, +_
	pop	af
	inc	a
	cp	6
	jr	nz, -_
	ret

_:	pop	af
	ret


CheckSpriteBounds:
	ld	a, (iy)
	cp	lcdWidth-15/2		;is the sprite out of bounds?
	ret	nc
	cp	2
	jp	c, EraseSprite
	ld	a, (iy+11)
	or	a
	jp	nz, DrawSprite_32
	jp	DrawSprite

AnimStep:
	;calc PTR to sprite image
	ld	ix, (iy+5)

	ld	a, ixl
	or	ixh
	ret	z

	call	CalcFramePTR
	ld	hl, (hl)
	ex	de, hl

	;calc sprite position
	ld	l, (iy+1)
	ld	h, lcdWidth/2
	mlt	hl
	ld	bc, 0
	ld	c, (iy)
	add	hl, bc
	ld	bc, VRAM
	add	hl, bc
	ex	de, hl
	call	CheckSpriteBounds
	;FALL THROUGH

AnimTick_CheckTick:
	ld	a, (iy)
	cp	(iy+2)
	ret	z
	jr	c, IncSpriteX
DecSpriteX:
	dec	(iy)
	jr	UpdateAnimTick
IncSpriteX:
	inc	(iy)

UpdateAnimTick:
	dec	(iy+4)
	ret	nz

	ld	ix, (iy+5)
	lea	ix, ix+2
	ld	(iy+5), ix

	ld	a, (ix)
	ld	(iy+4), a
	cp	$FE
	ret	nz
AnimTick_LoopBack:
	ld	b, (ix+1)
	dec	b
	ld	ix, (iy+5)
_:	lea	ix, ix-2
	djnz	-_
	ld	(iy+5), ix
	ld	a, (ix)
	ld	(iy+4), a
	inc	a
	ret


CalcFramePTR:
	ld	l, (ix+1)
	dec	l
	ld	h, 3
	mlt	hl
	ld	de, (iy+8)
	add	hl, de
	ret

CurrentAnim:
	.db $00

TotalAnimations:
	.dl Anim_Default
	.dl Anim_PacMan
	.dl Anim_MsPacMan
	.dl Anim_SuperPacMan

Anim_Default:
	.dl PacManLeftAnim
	.dl MsPacManLeftAnim
	.dl BlinkyLeftAnim
	.dl PinkyLeftAnim
	.dl InkyLeftAnim
	.dl ClydeLeftAnim

Anim_PacMan:
	.dl ScaredGhostAnim
	.dl ScaredGhostAnim
	.dl ScaredGhostAnim
	.dl ScaredGhostAnim
	.dl PacManLeftAnim
	.dl 0

Anim_MsPacMan:
	.dl ScaredGhostAnim
	.dl ScaredGhostAnim
	.dl ScaredGhostAnim
	.dl ScaredGhostAnim
	.dl MsPacManLeftAnim
	.dl 0

Anim_SuperPacMan:
	.dl ClydeLeftAnim
	.dl InkyLeftAnim
	.dl PinkyLeftAnim
	.dl BlinkyLeftAnim
	.dl SuperPacManLeftAnim
	.dl 0