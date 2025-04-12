#define AnimParams 	PixelShadow	; 11 byte chunks

; animation structure:
; IY+0 - IY+1:  current coords  (X, Y)
; IY+2 - IY+3:  endpoint coords (X, Y)
; IY+4:         no. of frames to hold current sprite
; IY+5 - IY+7:  PTR to sprite animation type
; IY+8 - IY+10: PTR to sprite image table
; IY+11:        sprite size boolean

#define CurrentX	0
#define CurrentY	1
#define FinalX		2
#define FinalY		3
#define AnimTiming	4
#define AnimPTR		5
#define SpritePTR	8
#define DoubleSprite	11

SetupAnims:
	ld	a, (CurrentAnim)
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	de, TotalAnimations
	add	hl, de
	ld	ix, (hl)
	ld	iy, AnimParams

	; load sprite X and Y coords
	xor	a
_:	push	af
	push	ix
	ld	ix, (ix)	; IX = sprite animation table

	; copy the start and endpoint into the object
	ld	l, a
	ld	h, 4
	mlt	hl
	ld	de, Sprite1Pos
	add	hl, de		; HL = sprite start and end coords
	lea	de, iy
	ld	bc, 4
	ldir

	inc	a
	ld	(TitleLoop+1), a

	ld	hl, (ix)
	ld	(iy+AnimPTR), hl	; IY+5 = PTR to sprite animation type

	ld	a, (ix+3)
	ld	(iy+DoubleSprite), a	; IY+11 = sprite magnification amount

	lea	ix, ix+4
	ld	(iy+SpritePTR), ix	; IX+8 = PTR to sprite image table

	ld	a, (hl)
	ld	(iy+AnimTiming), a	; IX+4 = animation timing
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

TempSpritePTR:
	.dl 0

CheckSpriteBounds:
	ld	(TempSpritePTR), hl	; save HL while we check params
	SpriteDim(16, 16)
	; if DoubleSprite is set, double the size of the sprite
	ld	a, (iy+DoubleSprite)
	or	a
	jr	z, +_
	call	AdjustSpriteOffset
_:	ld	a, (iy)
	cp	c			; is the sprite out of bounds?
	ret	nc
	cp	2
	jp	c, EraseSprite
	jp	DrawSprite

AnimStep:
	; calc PTR to sprite image
	ld	ix, (iy+AnimPTR)

	ld	a, ixl
	or	ixh
	ret	z

	call	CalcFramePTR
	ld	hl, (hl)
	ex	de, hl

	; calc sprite position
	ld	l, (iy+CurrentY)
	ld	h, lcdWidth/2
	mlt	hl
	ld	bc, 0
	ld	c, (iy+CurrentX)
	add	hl, bc
	ld	bc, VRAM
	add	hl, bc
	ex	de, hl
	call	CheckSpriteBounds
	; FALL THROUGH

AnimTick_CheckTick:
	ld	a, (iy+CurrentX)
	cp	(iy+FinalX)
	ret	z
	jr	c, IncSpriteX
DecSpriteX:
	dec	(iy)
	jr	UpdateAnimTick
IncSpriteX:
	inc	(iy)

UpdateAnimTick:
	dec	(iy+AnimTiming)
	ret	nz

	ld	ix, (iy+AnimPTR)
	lea	ix, ix+2
	ld	(iy+AnimPTR), ix

	ld	a, (ix+CurrentX)
	ld	(iy+AnimTiming), a
	cp	$FE
	ret	nz
AnimTick_LoopBack:
	ld	b, (ix+CurrentY)
	dec	b
	ld	ix, (iy+AnimPTR)
_:	lea	ix, ix-2
	djnz	-_
	ld	(iy+AnimPTR), ix
	ld	a, (ix+CurrentX)
	ld	(iy+AnimTiming), a
	inc	a
	ret


CalcFramePTR:
	ld	l, (ix+CurrentY)
	dec	l
	ld	h, 3
	mlt	hl
	ld	de, (iy+SpritePTR)
	add	hl, de
	ret

CurrentAnim:
	.db $00

TotalAnimations:
	.dl Anim_Default
	.dl Anim_PacMan
	.dl Anim_MsPacMan
	.dl Anim_SuperPacMan
	.dl Anim_Sonic
	.dl Anim_NamcoArcade

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

Anim_NamcoArcade:
	.dl PacManLeftAnim
	.dl PookaAnim
	.dl GalaxAnim
	.dl MappyAnim
	.dl 0

Anim_Sonic:
	.dl SonicAnim
	.dl BlankAnim
	.dl BlinkyLeftAnim
	.dl PinkyLeftAnim
	.dl InkyLeftAnim
	.dl ClydeLeftAnim
	.dl 0