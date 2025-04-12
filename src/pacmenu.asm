#include "src/includes/ti_equates.asm"


.db $EF, $7B
.ASSUME ADL=1
.ORG $D1A881

Icon:
	jp	START
	.db	1
	.db	16, 16
	.db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$00, $00, $00, $00, $00, $00, $E7, $E7, $E7, $E7, $E7, $00, $00, $00, $00, $00
	.db	$00, $00, $00, $00, $E7, $E7, $00, $00, $00, $00, $00, $E7, $E7, $00, $00, $00
	.db	$00, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E7, $00, $00
	.db	$00, $00, $00, $E7, $00, $00, $00, $00, $00, $00, $00, $00, $E7, $E7, $00, $00
	.db	$00, $00, $E7, $00, $00, $00, $00, $00, $00, $E7, $E7, $E7, $00, $00, $00, $00
	.db	$00, $00, $E7, $00, $00, $00, $E7, $E7, $E7, $00, $00, $00, $00, $00, $00, $00
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
	ld	(cursorImage), sp
	call	EasterEgg_CheckAns
JumpToLauncher:
	di
	; clear palette
	ld	hl, mpLcdPalette
	ld	de, mpLcdPalette+1
	ld	bc, $0100
	ld	(hl), $00
	ldir

	call	ClearVRAM
	call	ClearSafeRAM
	call	SetDefaultSPI

	; set up 4bpp mode with Vcomp interrupts
	ld	hl, lcdBpp4 | lcdIntFront | lcdBgr | lcdBepo
	ld	(mpLcdCtrl), hl
	ld	hl, $E30004
	ld	(hl), $3F

	; set up front porch interrupt
	ld	hl, mpLcdImsc
	set	3, (hl)
	ld	hl, mpLcdIcr
	set	3, (hl)

	; set framebuffer PTR to VRAM
	ld	hl, VRAM
	ld	(mpLcdMBASE), hl

	ld	hl, $F50000
	ld	(hl), 3

	; if the date is November 16th, set the palette to black and white
	call	CheckDate
	ld	bc, $0B10
	sbc	hl, bc
	call	z, LoadGreyPalette
	call	nz, LoadPalette

	; decompress the menu art and load it into VRAM
	ld	hl, TitleBG
	ld	de, plotSScreen
	call	DecompressZX0
	call	ScrollTitleLogo
	call	WhiteOutPalette
	DrawText(80, 208, CopyrightText)

	call	CheckDate_SwitchAnim
	call	SetupAnims
	call	TitleLoop
	DrawText(80, 208, BlankCopyText)

	call	ClearSafeRAM
	call	ScrollLogoUp
	Drawtext(52, 150, Press2ndText)

	jp	MenuLoop
	
MenuLoop:
	call	WaitAFrame
	ld	a, (KbdG7)
	push	af
	or	a
	call	nz, SwitchGame
	pop	af
	ld	(LastPress), a
	; if 2nd is pressed, load the selected game
	ld	a, (KbdG1)
	bit	Kbit2nd, a
	jp	nz, LoadGame

	; if clear is pressed, exit the game
	ld	a, (KbdG6)
	bit	kbitClear, a
	jp	nz, ExitGame

	jr	MenuLoop

LoadGame:
	call	ClearVRAM
	call	ClearSafeRAM

	; set up 8bpp mode with Vcomp interrupts
	ld	hl, lcdBpp8 | lcdIntFront | lcdBgr
	ld	(mpLcdCtrl), hl

	; set up LCD interrupts
	ld	hl, $F00004
	ld	(hl), $00
	inc	hl
	ld	(hl), $08

	; set framebuffer PTR to ScreenPTR
	ld	hl, ScreenPTR
	ld	(mpLcdMBASE), hl

	ld	hl, ExitGameSIS
	ld	de, romStart + $F000
	ld	bc, 11
	ldir

	call	LocateGameHeader

	ld	a, romStart >> 16
	ld	mb, a
	ld	sp, $D1A745
	ld.sis	sp, $DFF0

	ld	bc, 3
	or	a
	sbc	hl, bc

	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	inc	hl

	push	hl
	pop	ix

	push	bc
	ld	bc, (ix)
	add	hl, bc
	ld	a, (hl)
	pop	hl
	ld	bc, (ix+6)
	sbc	hl, bc
	push	hl
	lea	hl, ix
	add	hl, bc
	pop	bc

	cp	$83
	jr	z, LoadGame_MSX
	cp	$84
	jr	z, LoadGame_TI
	cp	$85
	jr	z, LoadGame_Sega

LoadGame_Sega:	; load Game Gear or Master System game
	; load game into RAM
	ld	de, romStart
	ldir

	call	SetGameSPI

	jp.sis	$0000	; start of program

LoadGame_MSX:	; load MSX game
	; load game into RAM
	ld	de, romStart + $4018
	ldir

	; load TMS9918 palette into LCD palette RAM
	ld	hl, MSXPalette
	ld	de, mpLcdPalette
	ld	bc, 32
	ldir

	call	SetGameSPI

	jp.sis	$4018	; start of program

LoadGame_TI:	; load native 84+ CE program


SwitchGame:
	ld	hl, LastPress
	xor	(hl)
	ret	z
	ld	hl, GameNo
	inc	(hl)

	ex	af, af'
	ld	a, (hl)
	cp	CurrentGameCount + 1
	jr	nz, +_
	xor	a
	ld	(hl), a
_:	ex	af, af'

	ld	c, a
	and	a, kbdDown | kbdRight
	ld	a, c
	jr	nz, +_
	dec	(hl)
	dec	(hl)
	ld	a, (hl)
	cp	CurrentGameCount
	jr	c, +_
	cp	$FE
	jr	z, ++_
	ld	a, CurrentGameCount
	ld	(hl), a
_:	jp	ScrollLogoUp

_:	ld	(hl), CurrentGameCount - 1
	jr	--_

GameNo:
	.db $00

LastPress:
	.db $00

LocateGameHeader:
	ld	hl, Headers
	ld	a, (GameNo)
	ld	c, a
	ld	b, 3
	mlt	bc
	add	hl, bc
	ld	hl, (hl)
	call	Mov9ToOP1
	call	ChkFindSym
	ex	de, hl
	jr	c, GameNotFound
	ld	bc, $20
	ld	a, $FF
	cpir
	ret

GameNotFound:
	DrawText(0, 140, MissingAppvarText)
	ld	a, (GameNo)
	ld	c, a
	ld	b, 3
	mlt	bc
	ld	ix, Headers
	add	ix, bc
	ld	ix, (ix)
	inc	ix

	ld	de, VRAM + (lcdWidth*156/2) + 60
	call	DrawString
	ld	ix, AppvarExtensionText
	call	DrawString

	DrawText(0, 172, TryAgainText)

	ld	bc, 600
_:	call	WaitAFrame
	dec	bc
	ld	a, b
	or	c
	jr	nz, -_
	jp	ExitGame

TitleLoop:
	ld	b, 6
	ld	iy, AnimParams	
_:	push	bc
	call	CheckAnimFinished
	call	AnimStep
	pop	bc
	lea	iy, iy+12
	djnz	-_
	ld	a, (FrameCounter)
	and	63
	call	z, ToggleText
	call	WaitAFrame
	ld	hl, kbdG6
	bit	kbitClear, (hl)
	jp	nz, ExitGame
	ld	hl, kbdG1
	bit	kbitMode, (hl)
	jr	z, TitleLoop
	jp	WhiteOutPalette

CopyrightText:
	.db "1980-2024 NAMCO LTD.",0
BlankCopyText:
	.db "                    ",0
Press2ndText:
	.db "PRESS 2ND TO START THE GAME.",0
StartButtonText:
	.db "PRESS MODE KEY",0
BlankButtonText:
	.db "              ",0

MissingAppvarText:
	.db "      MISSING THE FOLLOWING APPVAR",0
AppvarExtensionText:
	.db ".8XV",0
TryAgainText:
	.db "  UPLOAD IT TO YOUR CALC AND TRY AGAIN.",0
BlankTitleText:
	.fill 40, $20
	.db $00


CheckAnimFinished:
	ld	a, b
	dec	a
	ret	nz
	ld	a, (iy)
	or	a
	ret	nz

	pop	af
	ld	b, 30
_:	call	WaitAFrame
	ld	a, (FrameCounter)
	and	63
	push	bc
	call	z, ToggleText
	pop	bc
	ld	hl, kbdG6
	bit	kbitClear, (hl)
	jp	nz, ExitGame
	ld	hl, kbdG1
	bit	kbitMode, (hl)
	jp	nz, WhiteOutPalette
	djnz	-_
	call	SetupAnims
	pop	af
	jp	TitleLoop

#include "src/animate_sprites.asm"

#include "src/parse_os_vars.asm"


DrawSprite:	; draws a 16x16 sprite
	; init sprite
	ld	a, l
	ld	(SpriteWidth), a
	ld	(NewLineGap), bc

	ld	a, h
	ld	hl, (TempSpritePTR)
_:	ld	bc, (SpriteWidth)
	ldir
	ex	de, hl
	ld	(hl), $00
	ld	bc, (NewLineGap)
	add	hl, bc
	ex	de, hl
	dec	a
	jr	nz, -_
	ret

SpriteWidth:
	.dl 0

NewLineGap:
	.dl 0

EraseSprite:	; draws a blank sprite
	ld	hl, plotSScreen
	ld	(TempSpritePTR), hl
	SpriteDim(16, 16)
	; if DoubleSprite is set, double the size of the sprite
	ld	a, (iy+DoubleSprite)
	or	a
	jr	z, +_
	SpriteDim(32, 32)
_:	jr	DrawSprite

AdjustSpriteOffset:	; adjust 32x32 sprite
	ex	de, hl
	ld	bc, (lcdWidth*16)/2
	or	a
	sbc	hl, bc
	ex	de, hl
	SpriteDim(32, 32)
	ret

TitleY:
	.db LcdHeight		; the logo scrolls across the whole screen, so we're looping 240 times

ScrollTitleLogo:		; scrolls the title logo across the screen, Pac-Man NES style
	call	WaitAFrame
	ld	a, (TitleY)
	ld	hl, kbdG1
	bit	kbitMode, (hl)	; if MODE is pressed, end the animation early
	jr	z, +_
	xor	a
_:	ld	hl, VRAM
	ld	c, a
	ld	b, LcdWidth/2		; BC = VRAM offset
	mlt	bc
	add	hl, bc
	ex	de, hl			; DE = where the logo will be drawn
	ld	hl, plotSScreen	; title art
	ld	bc, (LcdWidth*lcdHeight)/2
	ldir
	dec	a
	ld	(TitleY), a
	cp	$FF			; was A zero just now?
	jr	nz, ScrollTitleLogo
	ld	a, 240
	ld	(TitleY), a
	ret

DrawLogo:
	exx
	ld	hl, plotSScreen
	ld	de, plotSScreen+1
	ld	bc, lcdWidth*100/2
	ld	(hl), $00
	ldir
	exx
	ld	bc, 0
	ld	a, (hl)

	; offset DE to center the selected game's logo on the screen
	ex	de, hl
	and	$FC
	rra \ rra
	ld	c, a
	sbc	hl, bc
	ex	de, hl

	ld	a, (hl)
	rra
	ld	c, a
	inc	hl
	ld	a, (hl)
	inc	hl
_:	push	bc
	ldir
	pop	bc

	push	hl
	ld	hl, lcdWidth/2
	or	a
	sbc	hl, bc
	add	hl, de
	ex	de, hl
	pop	hl

	dec	a
	jr	nz, -_
	ret

ScrollLogoUp:			; scrolls generic logo up
	ld	b, 35
_:	push	bc
	ld	de, VRAM
	ld	hl, VRAM + (LcdWidth*4/2)
	ld	bc, lcdWidth*98/2
	ldir
	pop	bc
	call	WaitAFrame
	djnz	-_
	call	LocateGameHeader

	push	hl
	pop	ix
	ld	bc, (ix+3)
	add	hl, bc

	ld	de, pixelShadow
	push	de
	call	DecompressZX0
	pop	hl
	ld	de, plotSScreen + (LcdWidth*44/2) + 80
	call	DrawLogo

ScrollLogoDown:
	ld	ix, ScrollLogoY
_:	ld	c, (ix)
	ld	b, lcdWidth/2
	mlt	bc
	ld	hl, plotSScreen
	add	hl, bc
	ld	de, VRAM
	ld	bc, lcdWidth*98/2
	ldir
	ld	a, (ix)
	sub	$02
	ld	(ix), a
	jr	nz, -_
	ld	(ix), 100

	DrawText(0,158,BlankTitleText)

	; draw text
	call	LocateGameHeader
	ld	bc, (hl)
	inc	bc
	add	hl, bc
	; calc size of string for centering
	push	hl
	ld	de, VRAM + (lcdWidth*158/2)
	call	CenterText
	pop	ix
	
	call	DrawString
	ret

ScrollLogoY:
	.db 100

WhiteOutPalette:
	ld	hl, mpLcdPalette
	ld	de, mpLcdPalette + 1
	ld	bc, 32

	ld	(hl), $FF
	ldir

	ld	b, 10
_:	call	WaitAFrame
	djnz	-_

	ld	hl, VRAM + (132*lcdWidth/2)
	push	hl
	pop	de
	inc	de
	ld	bc, 60*lcdWidth/2
	ld	(hl), $00
	ldir

LoadPalette:
	; load menu palette
	ld	hl, MenuPalette
	ld	de, mpLcdPalette
	ld	bc, GreyPalette - MenuPalette
	ldir
	ret

LoadGreyPalette:
	; load grey palette
	ld	hl, GreyPalette
	ld	de, MenuPalette
	ld	bc, GreyPalette - MenuPalette
	ldir
	xor	a
	ret
	
DrawString:	; IX = string, DE = VRAM address
	ld	a, (ix)
	sub	$41
	jp	c, LoadNonLetter

	cp	$20
	jr	c, +_
	sub	$20
_:	push	de
	ld	l, a
	ld	h, 32
	mlt	hl
	ld	de, MenuFont	; locate specific letter
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
	jp	nz, DrawString
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
_:	cp	$30
	jr	nc, LoadNumber
	jp	DrawLetter

LoadNumber:
	and	$0F
	ld	c, a
	ld	b, 32
	mlt	bc
	ld	hl, Numbers
	add	hl, bc
	jp	DrawLetter

ToggleText:	; toggle text on title screen
	ld	hl, StartButtonToggle
	ld	de, VRAM + (173*lcdWidth/2) + 52
	ld	a, (hl)
	cpl
	ld	(hl), a
	ld	ix, StartButtonText
	or	a
	jr	nz, +_
	ld	ix, BlankButtonText
_:	jp	DrawString
StartButtonToggle:
	.db $00

CenterText:	; DE = text position on screen
	inc	hl
	ld	bc, $FF
	xor	a
	cpir
	ld	a, c
	cpl
	ld	c, a
	ld	b, 2
	mlt	bc
	ld	hl, 80
	or	a
	sbc	hl, bc

	add	hl, de
	ex	de, hl
	ret

ExitGame:
	ld	sp, (CursorImage)
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

ExitGameSIS:	; return to launcher from selected game
	ld.lil	sp, (CursorImage)
	jp.lil	JumpToLauncher

WaitAFrame:
	ld	hl, mpLcdRis
	bit	3, (hl)
	jr	z, WaitAFrame
	ld	hl, mpLcdIcr
	set	3, (hl)
	ld	hl, FrameCounter
	inc	(hl)
	ret

ClearVRAM:
	; clear VRAM
	ld	hl, VRAM
	ld	de, VRAM+1
	ld	bc, VRAMEnd-VRAM
	ld	(hl), $00
	ldir
	ret

ClearSafeRAM:
	; clear SafeRAM
	ld	hl, pixelShadow
	ld	de, pixelShadow+1
	ld	bc, $B800
	ld	(hl), $00
	ldir
	ret

FrameCounter:
	.db $00

Headers:	; headers for each game
	.dl PacManGGHeader
	.dl MSXHeader
	.dl AtariPacHeader
	.dl MsPacMSHeader
	.dl SuperPacHeader

#define CurrentGameCount	4

PacManGGHeader:
	.db $15, "PacGG",0
MSXHeader:
	.db $15, "PacMSX",0
AtariPacHeader:
	.db $15, "AtariPac",0
MsPacMSHeader:
	.db $15, "MsPacMan",0
SuperPacHeader:
	.db $15, "SuperPac",0

MenuPalette:	; palette for main menu
	#import "src/includes/gfx/misc/menupalette.bin"
GreyPalette:	; easter egg grey palette
	#import "src/includes/gfx/misc/greypalette.bin"


MSXPalette:	; TMS9918 colour palette
	.dw $0000, $0000, $A2C9, $BB2F, $AD5B, $C1DD, $D96A, $337D
	.dw $ED8B, $7E2F, $670B, $EF30, $1E88, $D996, $6739, $FFFF

TitleBG:	; Pac-Man Museum CE title screen
#import "src/includes/gfx/misc/titlebg.bin"

MenuFont:	; Namco arcade font for launcher
#include "src/includes/font.asm"

Animations:
#include "src/includes/anim.asm"

; ZX0 art decompressor
#include "src/includes/dzx0_fast.asm"

; SPI routines
#include "src/includes/spi.asm"