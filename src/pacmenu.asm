#include "ti_equates.asm"

.db $EF, $7B
.ASSUME ADL=1
.ORG $D1A881

Icon:
	jp	START
	.db	1
	.db	16, 16
	.db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $00, $00, $00, $00, $E7, $E7, $E7, $E7, $E7, $00, $00, $00, $00, $00
	.db	$00, $00, $00, $00, $E7, $E7, $00, $00, $00, $00, $00, $E7, $E7, $00, $00, $00
	.db	$00, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E7, $00, $00
	.db	$00, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $E7, $E7, $00, $00
	.db	$00, $00, $E7, $00, $00, $00, $00, $00, $00, $E7, $E7, $E7, $00, $00, $00, $00
	.db	$00, $00, $E7, $00, $00, $00, $E7, $E7, $E7, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $E7, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $E7, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $E7, $00, $00, $00, $E7, $E7, $E7, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $E7, $00, $00, $00, $00, $00, $00, $E7, $E7, $E7, $00, $00, $00, $00
	.db	$00, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $E7, $E7, $00, $00
	.db	$00, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E7, $00, $00
	.db	$00, $00, $00, $00, $E7, $E7, $00, $00, $00, $00, $00, $E7, $E7, $00, $00, $00
	.db	$00, $00, $00, $00, $00, $00, $E7, $E7, $E7, $E7, $E7, $00, $00, $00, $00, $00
	.db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.db "Pac-Man Museum CE",0

START:
	di
	;clear palette
	ld	hl, mpLcdPalette
	ld	de, mpLcdPalette+1
	ld	bc, $0100
	ld	(hl), $00
	ldir

	;clear VRAM
	ld	hl, VRAM
	ld	de, VRAM+1
	ld	bc, VRAMEnd-VRAM
	ld	(hl), $00
	ldir

	;set up 4bpp mode with Vcomp interrupts
	ld	hl, mpLcdCtrl
	ld	(hl), $25
	inc	hl
	ld	(hl), %00011101
	ld	hl, $E30004
	ld	(hl), $3F

	;set up front porch interrupt
	ld	hl, mpLcdImsc
	set	3, (hl)
	ld	hl, mpLcdIcr
	set	3, (hl)

	ld	hl, $F50000
	ld	(hl), 3

	xor	a
	ld	hl, CursorPos
	ld	(hl), a

	;load menu palette
	ld	hl, MenuPalette
	ld	de, mpLcdPalette
	ld	bc, $0012
	ldir

	;decompress the menu art and load it into VRAM
	ld	hl, MenuArt
	ld	de, VRAM
	call	DecompressZX0
	call	CheckCursorDirection
	xor	a
_:	call	LoadText
	or	a
	jr	z, MenuLoop
	jr	-_
	
MenuLoop:
	call	WaitAFrame
	;if 2nd is pressed, load the selected game
	ld	a, (KbdG1)
	bit	Kbit2nd, a
	jp	nz, LoadGame

	;if clear is pressed, exit the game
	ld	a, (KbdG6)
	bit	kbitClear, a
	jp	nz, ExitGame

	;update the cursor
	ld	a, (hl)		;HL = FrameCounter
	and	$07
	call	z, UpdateCursor
	jr	MenuLoop
	
LoadText:
	ld	de, $D450B8
	;load game headers (titles)
	ld	hl, Headers
	ld	c, a
	ld	b, 3
	mlt	bc
	add	hl, bc

	ex	af, af'	;save A
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	;exit early if pointer == $0000
	or	h
	or	a
	ret	z

	;locate game in flash memory
	push	de
	call	Mov9ToOP1
	call	ChkFindSym
	jp	c, GameNotFound
	ex	de, hl

	ld	bc, $20
	ld	a, $FF
	cpir

	inc	hl
	pop	de

	;convert ASCII to graphics
	push	hl
	pop	ix

	ex	af, af'
	ld	l, a
	ld	h, 160
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl

	add	hl, de
	ex	de, hl
	ex	af, af'

_:	ld	a, (ix)
	sub	$41
	jp	c, LoadNonLetter

	push	de
	ld	l, a
	ld	h, 32
	mlt	hl
	ld	de, MenuFont	;locate specific letter
	add	hl, de
	pop	de

DrawLetter:
	push	de
	ld	a, 8
_:	ld	bc, 4
	ldir
	push	hl
	ld	hl, 156
	add	hl, de
	ex	de, hl
	pop	hl
	dec	a
	jr	nz, -_

	pop	de
	ld	hl, 4
	add	hl, de
	ex	de, hl
	inc	ix
	ld	a, (ix)
	or	a
	jp	nz, --_
	ex	af, af'
	inc	a	
	ret

LoadNonLetter:
	add	a, $41
	cp	$20
	jr	nz, +_
	ld	hl, Space
_:	cp	$28
	jr	nz, +_
	ld	hl, LeftBracket
_:	cp	$29
	jr	nz, +_
	ld	hl, RightBracket
_:	cp	$2D
	jr	nz, +_
	ld	hl, Hyphen
_:	cp	$2E
	jr	nz, +_
	ld	hl, Period
_:	jp	DrawLetter

UpdateCursor:
	ld	hl, CursorPos
	ld	a, (KbdG7)
	and	$09
	ret	z

CheckCursorDirection:
	ld	a, (KbdG7)
	bit	kbitDown, a
	jr	z, +_
	inc	(hl)
_:	bit	kbitUp, a
	jr	z, +_
	dec	(hl)
	jp	p, +_
	ld	(hl), $00
_:	ld	a, 8
	cp	(hl)
	jr	nc, +_
	ld	(hl), a
_:	ld	l, (hl)

CalcCursorPosition:
	ld	h, 160
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl

	ld	de, $D450B0
	add	hl, de
	ex	de, hl
	ld	a, 8
DrawCursor:
	ld	hl, PacCursor
_:	ld	bc, 4
	ldir
	push	hl
	ld	hl, 156
	add	hl, de
	ex	de, hl
	pop	hl
	dec	a
	jr	nz, -_
	ex	de, hl

	call	PreventOverwrite

	ld	a, (KbdG7)
	bit	kbitDown, a
	jr	z, +_

AltCursorErase:
	ld	de, 160*16
	or	a
	sbc	hl, de

_:	ex	de, hl
	ld	a, 8
	ld	hl, Space
_:	ld	bc, 4
	ldir

	push	hl
	ld	hl, 156
	add	hl, de
	ex	de, hl
	pop	hl

	dec	a
	jr	nz, -_
	ret

PreventOverwrite:	;stop the cursor from overwriting the BG
	ld	a, (CursorPos)
	or	a
	ret	z
	cp	8
	ret	nz
	pop	de
	ld	de, AltCursorErase
	push	de
	ret

LoadGame:
	;set up 8bpp mode with Vcomp interrupts
	ld	hl, mpLcdCtrl
	ld	(hl), $27
	inc	hl
	ld	(hl), %00011001

	;clear emulated memory map location
	ld	hl, romStart
	ld	de, romStart+1
	ld	bc, $FFFF
	ld	(hl), $00
	ldir

	;set up LCD interrupts
	ld	hl, $F00004
	ld	(hl), $00
	inc	hl
	ld	(hl), $08

	ld	hl, ExitGameSIS
	ld	de, $D2F000
	ld	bc, 11
	ldir

	ld	hl, Headers
	ld	a, (CursorPos)
	ld	c, a
	ld	b, 3
	mlt	bc
	add	hl, bc
	ld	hl, (hl)
	call	Mov9ToOP1
	call	ChkFindSym
	jp	c, START

	ld	a, $D2
	ld	mb, a
	ld	($D2FFF0), sp
	ld	sp, $D1A745
	ld.sis	sp, $DFF0

	ex	de, hl
	ld	bc, $20
	ld	a, $FF
	cpir

	ld	bc, 3
	or	a
	sbc	hl, bc

	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	inc	hl

	cp	$80
	jr	z, LoadGame_GG
	cp	$83
	jr	z, LoadGame_MSX

LoadGame_GG:
	xor	a
	push	bc
	ld	bc, 32
	cpir
	;load engine into RAM
	ld	de, romStart
	pop	bc
	ldir

	;clear VRAM again
	ld	hl, VRAM
	ld	de, VRAM+1
	ld	bc, VRAMEnd-VRAM
	ld	(hl), $00
	ldir

	;load DrawScreen
	ld	hl, DrawScreen
	ld	de, $D2E000
	ld	bc, $0600
	ldir

	ld	hl, $E30004
	ld	(hl), $27
	jp.sis	$0000	;start of program

LoadGame_MSX:
	xor	a
	push	bc
	ld	bc, 32
	cpir

	ld	de, romStart + $4018
	pop	bc
	ldir

	ld	hl, MSXPalette
	ld	de, mpLcdPalette
	ld	bc, 32
	ldir

	ld	hl, pixelShadow
	ld	de, pixelShadow+1
	ld	bc, $4800
	ld	(hl), $00
	ldir

	;clear VRAM again
	ld	hl, VRAM
	ld	de, VRAM+1
	ld	bc, VRAMEnd-VRAM
	ld	(hl), $00
	ldir

	jp.sis	$4018	;start of program

ExitGame:
	ld	a, $D0
	ld	mb, a
	ld	hl, $F00004
	ld	(hl), $11
	inc	hl
	ld	(hl), $30
	ld	hl, lcdNormalMode
	ld	(mpLcdCtrl), hl
	ld	hl, mpLcdPalette
	ld	de, mpLcdPalette+1
	ld	bc, $0040
	ld	(hl), $00
	ldir
	call	ClrLCDFull
	ei
	ret

ExitGameSIS:
	ld.lil	sp, ($D2FFF0)
	jp.lil	START

GameNotFound:
	pop	de
	;increment A and try again
	ex	af, af'
	inc	a
	jp	LoadText

WaitAFrame:
	ld	hl, mpLcdRis
	bit	3, (hl)
	jr	z, WaitAFrame
	ld	hl, mpLcdIcr
	set	3, (hl)
	ld	hl, FrameCounter
	inc	(hl)
	ret

Headers:
	.dl PacManGGHeader
	.dl MSXHeader
	.dl $0000
	.dl $0000
	.dl $0000
	.dl $0000
	.dl $0000
	.dl $0000

PacManGGHeader:
	.db $15, "PacGG",0
MSXHeader:
	.db $15, "PacMSX",0

MenuPalette:
	.dw $0000, $109F, $200F, $DEF7, $7800, $7AF5, $FE20, $FF40, $FFFF
MSXPalette:
	.dw $0000, $0000, $A2C9, $BB2F, $AD5B, $C1DD, $D96A, $337D
	.dw $ED8B, $7E2F, $670B, $EF30, $1E88, $D996, $6739, $FFFF
MenuArt:
#import "menu.bin"

MenuFont:
#include "font.asm"

PacCursor:
#import "font/PacCursor.bin"

CursorPos:
 .db $00

FrameCounter:
.db $00

#include "dzx0_fast.asm"

#include "PacGG\screen_drawing_routines.asm"