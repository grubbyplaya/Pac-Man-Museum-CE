#define SpriteTable 	PixelShadow	; 20 byte chunks

; animation structure:
; IY+0 - IY+2:		PTR to current sprite animation
; IY+3:			current cutscene CMD
; IY+4:			cutscene register
; IY+5 - IY+6:  	current coords  (X, Y)
; IY+7 - IY+9:	 	PTR to sprite anim timer
; IY+10 - IY+12:	PTR to sprite image table
; IY+13 - IY+15:	PTR to sprite image
; IY+16:		sprite anim timer
; IY+17:        	sprite size boolean

#define ObjectSize	20

#define SpriteAnim	0
#define LastCmd		3
#define SetNParam	4
#define CurrentX	5
#define CurrentY	6
#define AnimTiming	7
#define AnimPTR		10
#define SpritePTR	13
#define AnimTimer	16
#define DoubleSprite	17
#define LastX		18
#define LastY		19

SetupAnims:
	; calc current animation to use
	ld	a, (CurrentAnim)
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	de, TotalAnimations
	add	hl, de

	; IX = animation table ptr
	ld	ix, (hl)
	ld	iy, SpriteTable

	ld	b, 6
SetupAnimLoop:
	push	bc
	push	ix

	; IX = sprite to init
	ld	ix, (ix)
	ld	de, -1
	add	ix, de
	jr	nc, SetupAnims_Bailout
	inc	ix

	; get the sprite anim
	ld	hl, (ix)
	ld	(iy + SpriteAnim), hl

	; get the anim timing
	ld	hl, (ix + 3)
	ld	(iy + AnimTiming), hl

	; save ptr to animation
	lea	ix, ix + 6
	ld	(iy + AnimPTR), ix

	; load anim timers
	ld	a, (hl)
	ld	(iy + AnimTimer), a
	inc	hl

	; calc initial sprite based off of charcode
	ld	e, (hl)
	dec	e
	ld	d, 3
	mlt	de
	add	ix, de
	ld	hl, (ix)
	ld	(iy + SpritePTR), hl

	; set the default Y coords
	ld	(iy + CurrentY), 153

	; set the default X coords
	ld	a, 6
	sub	b
	ld	c, a
	ld	b, 24/2
	mlt	bc
	ld	a, c
	add	a, 304/2
	ld	(iy + CurrentX), a

	; go to next sprite
	pop	ix
	lea	ix, ix + 3
	lea	iy, iy + ObjectSize
	pop	bc
	djnz	SetupAnimLoop

_:	ld	a, 6
	sub	b
	ld	(SpriteCount), a
	ret

SetupAnims_Bailout:
	pop	ix
	pop	bc
	jr	-_

CheckSpriteBounds:
	; erase old sprite
	ld	e, (iy + LastY)
	ld	a, (iy + LastX)
	call	GetSpritePos
	call	EraseSprite

	; get sprite screen position
	ld	e, (iy + CurrentY)
	ld	a, (iy + CurrentX)
	call	GetSpritePos

	ld	a, (iy + CurrentX)
	cp	c			; is the sprite out of bounds?
	ret	nc
	
	push	hl
	ld	hl, (iy + SpritePTR)
	ld	(TempSpritePTR), hl
	pop	hl

	cp	2
	jp	nc, DrawSprite
	ret

GetSpritePos:	; set DE to the sprite position
	; calc the Y position
	ld	d, lcdWidth/2
	mlt	de

	; clear HL
	or	a
	sbc	hl, hl

	; calc the X position
	ld	l, a
	add	hl, de

	; offset into VRAM
	ld	de, VRAM
	add	hl, de
	ex	de, hl

	SpriteDim(16, 16)

	; if DoubleSprite is set, double the size of the sprite
	ld	a, (iy + DoubleSprite)
	or	a
	ret	z

AdjustSpriteOffset:	; adjust 32x32 sprite
	ex	de, hl
	ld	bc, (lcdWidth*16)/2
	or	a
	sbc	hl, bc
	ex	de, hl
	SpriteDim(32, 32)
	ret

AnimStep:	; IN: IY = sprite object
	; save old coords
	ld	a, (iy + CurrentY)
	ld	(iy + LastY), a

	ld	a, (iy + CurrentX)
	ld	(iy + LastX), a

	ld	hl, (iy + SpriteAnim)

	; get the cmd
	ld	a, (hl)
	and	$0F

	; bail out if the animation's done
	cp	$0F
	jr	nz, +_

	ld	(iy + LastCmd), $FF
	ret

	; save the cmd for later
_:	push	af

	; set the return addr to FinishAnimStep
	ld	hl, FinishAnimStep
	push	hl

	; handle the other bytecode ops
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	de, BytecodeTable
	add	hl, de
	ld	hl, (hl)
	jp	(hl)

BytecodeTable:
	; re-implemented from Ms. Pac-Man
	.dl Anim_LOOP		; F0 - LOOP(OffsetX, OffsetY)
	.dl Anim_SETPOS		; F1 - SETPOS(X, Y)
	.dl Anim_SETN		; F2 - SETN(value)
	.dl Anim_QuickRet	; unused (for now)
	.dl Anim_SetSize	; F4 - SETSIZE(bool)
	.dl Anim_QuickRet	; unused (for now)
	.dl Anim_PAUSE		; F6 - PAUSE

Anim_LOOP:	; F0 - offset the sprite's X and Y coords in a loop
	ld	ix, (iy + SpriteAnim)
	dec	(iy + SetNParam)
	jr	z, Anim_LOOPEnd

	; handle the loop

	; offset the sprite's X and Y coords
	ld	a, (ix + 1)
	add	a, (iy + CurrentX)
	ld	(iy + CurrentX), a

	ld	a, (ix + 2)
	add	a, (iy + CurrentY)
	ld	(iy + CurrentY), a
	ret

Anim_LOOPEnd:
	lea	ix, ix + 3
	ld	(iy + SpriteAnim), ix
	ret

Anim_SETPOS:	; F1 - set sprite pos
	ld	hl, (iy + SpriteAnim)

	; set sprite's x pos
	inc	hl
	ld	a, (hl)
	ld	(iy + CurrentX), a

	; set sprite's y pos
	inc	hl
	ld	a, (hl)
	ld	(iy + CurrentY), a

	; go to next cmd
	inc	hl
	ld	(iy + SpriteAnim), hl
	ret

Anim_SETN:	; F2 - set anim register
	ld	hl, (iy + SpriteAnim)
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	(iy + SpriteAnim), hl
	ld	(iy + SetNParam), a
Anim_QuickRet:
	ret

Anim_SetSize:	; F4 - select sprite size
	ld	hl, (iy + SpriteAnim)
	inc	hl

	; get the sprite size bool
	; if 0, it's 16x16. 32x32 otherwise
	ld	a, (hl)
	ld	(iy + DoubleSprite), a
	inc	hl
	ld	(iy + SpriteAnim), hl
	ret

Anim_PAUSE:	; F6 - pause
	; keep on waiting
	dec	(iy + SetNParam)
	ret	nz

	ld	hl, (iy + SpriteAnim)
	inc	hl
	ld	(iy + SpriteAnim), hl
	ret

FinishAnimStep:
	; save the last cmd
	pop	af
	or	$F0
	ld	(iy + LastCmd), a

	; change the sprite
	dec	(iy + AnimTimer)
	call	z, UpdateSpriteImage

	jp	CheckSpriteBounds

UpdateSpriteImage:
	ld	hl, (iy + AnimTiming)

LoadTiming:
	; reset anim timer
	ld	a, (hl)
	cp	$FE
	; if loop cmd, loop back to the anim start
	jr	z, ResetAnim
	ld	(iy + AnimTimer), a

	; calc the sprite to change to based on charcode
	inc	hl
	ld	c, (hl)
	dec	c
	ld	b, 3
	mlt	bc
	ld	ix, (iy + AnimPTR)
	add	ix, bc
	ld	ix, (ix)
	ld	(iy + SpritePTR), ix

	inc	hl
	ld	(iy + AnimTiming), hl
	ret

ResetAnim:
	inc	hl
	ld	a, (hl)
	mlt	bc
	add	a, a
	dec	a
	ld	c, a
	ld	b, 0
	sbc	hl, bc
	jp	LoadTiming

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
	.dl PacManLeftSprites
	.dl MsPacManLeftSprites
	.dl BlinkyLeftSprites
	.dl PinkyLeftSprites
	.dl InkyLeftSprites
	.dl ClydeLeftSprites

Anim_PacMan:
	.dl ScaredGhostSprites
	.dl ScaredGhostSprites
	.dl ScaredGhostSprites
	.dl ScaredGhostSprites
	.dl PacManLeftSprites
	.dl 0

Anim_MsPacMan:
	.dl ScaredGhostSprites
	.dl ScaredGhostSprites
	.dl ScaredGhostSprites
	.dl ScaredGhostSprites
	.dl MsPacManLeftSprites
	.dl 0

Anim_SuperPacMan:
	.dl ClydeLeftSprites
	.dl InkyLeftSprites
	.dl PinkyLeftSprites
	.dl BlinkyLeftSprites
	.dl SuperPacManLeftSprites
	.dl 0

Anim_NamcoArcade:
	.dl PacManLeftSprites
	.dl PookaSprites
	.dl GalaxSprites
	.dl MappySprites
	.dl 0

Anim_Sonic:
	.dl SonicSprites
	.dl BlinkyLeftSprites
	.dl PinkyLeftSprites
	.dl InkyLeftSprites
	.dl ClydeLeftSprites
	.dl 0