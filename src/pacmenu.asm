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
	; somehow, modifying IY crashes calcs
	push	iy
	ld	(appData), sp

	call	boot_InitializeHardware
	call	CheckDate_ToggleAnniversary
	call	EasterEgg_CheckAns
JumpToLauncher:
	di

	; make 14K of RAM safe to use
	xor	a
	ld	(usbInited), a

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
	call	LoadPalette

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

	jp	MenuLoop
	
MenuLoop:
	call	WaitAFrame

	ld	a, (CurrentBTNs)
	and	BTN_ArrowKeys
	call	nz, SwitchGame

	; if 2nd is pressed, load the selected game
	ld	a, (CurrentBTNs)
	bit	BIT_SELECTGAME, a
	jp	nz, LoadGame

	jr	MenuLoop

LoadGame:
	ld	a, (GameMissing)
	or	a
	jp	nz, MenuLoop

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
	ld	bc, ExitGameSIS_End - ExitGameSIS
	ldir

	call	LocateGameHeader

	ld	a, romStart >> 16
	ld	mb, a
	ld	sp, $D1A745
	ld.sis	sp, $DFF0

	call	LoadAppvarVectors

	cp	$80
	jr	z, LoadGame_Arcade
	cp	$81
	jr	z, LoadGame_ArcadePatch
	cp	$83
	jr	z, LoadGame_MSX
	cp	$84
	jr	z, LoadGame_TI
	cp	$85
	jr	z, LoadGame_Sega

LoadGame_Arcade:	; load Pac-Man (Arcade)
	ld	de, romStart
	ldir
	
	call	SetArcadeSPI

	jp.sis	$0000

LoadGame_ArcadePatch:	; overlay game over Pac-Man (Arcade)
	; copy the patches to hex range $8000
	ld	de, romStart + $8000
	ldir

	; load Pac-Man (Arcade) into RAM
	ld	hl, PacManArcadeHeader
	call	LoadAppvar
	call	LoadAppvarVectors
	ld	de, romStart
	ldir

	call	SetArcadeSPI
	jp.sis	$8000

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

LocateGameHeader:
	ld	hl, Headers
	ld	a, (GameNo)
	ld	c, a
	ld	b, 3
	mlt	bc
	add	hl, bc
	ld	hl, (hl)
LoadAppvar:
	call	Mov9ToOP1
	call	ChkFindSym
	ex	de, hl
	jr	c, GameNotFound

	xor	a
	ld	(GameMissing), a

	ld	bc, $20
	ld	a, $FF
	cpir
	ret

GameNo:
	.db $00

LoadAppvarVectors:
	; go back to the length of the appvar
	ld	bc, 3
	or	a
	sbc	hl, bc

	; load the total appvar length
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	inc	hl

	; load the appvar ptr into IX
	push	hl
	pop	ix

	push	bc
	; get the game platform from the header
	ld	bc, (ix)
	add	hl, bc
	ld	a, (hl)
	pop	hl

	; calculate the true program length
	; using the header's length as an offset
	ld	bc, (ix + 6)
	sbc	hl, bc
	push	hl

	; use that same offset to go to the program's entry point
	lea	hl, ix
	add	hl, bc
	pop	bc
	ret

GameNotFound:
	DrawText(0, 150, BlankTitleText)
	DrawText(0, 158, BlankTitleText)
	DrawText(0, 140, MissingAppvarText)

	; get the name of the missing appvar
	ld	a, (GameNo)
	ld	c, a
	ld	b, 3
	mlt	bc
	ld	ix, Headers
	add	ix, bc
	ld	ix, (ix)
	inc	ix

	; draw the appvar name, along with ".8XV"
	ld	de, VRAM + (lcdWidth*156/2) + 60
	call	DrawString
	ld	ix, AppvarExtensionText
	call	DrawString

	DrawText(0, 172, TryAgainText)

	ld	a, 1
	ld	(GameMissing), a
	ret

GameMissing:
	.db 0

TitleLoop:
	; handle every sprite
	ld	iy, SpriteTable
SpriteCount = $+1
	ld	b, 0

_:	push	bc
	call	AnimStep
	pop	bc
	lea	iy, iy + ObjectSize
	djnz	-_

	call	CheckAnimFinished

	; toggle the "PRESS MODE KEY" text every second
	ld	a, (FrameCounter)
	and	63
	call	z, ToggleText

	; if mode was pressed, go to the selection screen
	ld	iy, CurrentBTNs
	ld	a, (iy)

	; this checks if mode was pressed during the title screen
	xor	(iy + 1)
	and	(iy)

	bit	BIT_START, a
	jr	z, TitleLoop

	jp	WhiteOutPalette

CheckAnimFinished:
	call	WaitAFrame

	; get the # of sprites
	ld	iy, SpriteTable
	ld	a, (SpriteCount)
	ld	b, a

	; check to see if every sprite is finished
	ld	a, $FF
_:	and	(iy + LastCmd)
	lea	iy, iy + ObjectSize
	djnz	-_

	; are they? if not, bail out
	cp	$FF
	ret	nz

	; wait for 30 frames, then reset the animation
	ld	b, 30
_:	call	WaitAFrame

	; toggle the "PRESS MODE KEY" text every second
	ld	a, (FrameCounter)
	and	63
	push	bc
	call	z, ToggleText
	pop	bc

	; if mode is pressed, bail out
	ld	ix, CurrentBTNs
	ld	a, (ix)

	; check if the mode key was just pressed
	xor	(ix + 1)
	and	(ix)

	bit	BIT_START, a
	ret	nz

	djnz	-_

	; reset the animation
	call	SetupAnims
	pop	af
	jp	TitleLoop

#include "src/animate_sprites.asm"

#include "src/parse_os_vars.asm"

EraseSprite:	; draws a blank sprite
	push	hl
	ld	hl, plotSScreen
	ld	(TempSpritePTR), hl
	pop	hl
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

TempSpritePTR:
	.dl 0

ScrollTitleLogo:		; scrolls the title logo across the screen, Pac-Man NES style
	call	WaitAFrame
	ld	a, (TitleY)
	ld	hl, CurrentBTNs
	bit	BIT_START, (hl)	; if MODE is pressed, end the animation early
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

TitleY:
	.db LcdHeight		; the logo scrolls across the whole screen, so we're looping 240 times

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
	rra	
	rra
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

SwitchGame:
	; if no buttons have been pressed, bail out
	ld	hl, LastBTNs
	xor	(hl)
	ret	z

	ld	hl, GameNo
	inc	(hl)

	; C = input flags
	ld	c, a

	; if we've gone past the final game, go back to the first one
	ld	a, (hl)
	cp	CurrentGameCount + 1
	jr	nz, +_

	xor	a
	ld	(hl), a

	; check if the next game has been selected
_:	ld	a, c
	and	a, BTN_DOWN | BTN_RIGHT
	jr	nz, ScrollLogoUp

	; if not, the previous one has been selected
	dec	(hl)
	dec	(hl)

	; if we're still in the range of games, skip
	ld	a, (hl)
	cp	CurrentGameCount
	jr	c, ScrollLogoUp

	; if we underflowed the game #, set it to the final one
	cp	$FE
	ld	a, CurrentGameCount
	jr	nz, +_

	dec	a

_:	ld	(hl), a

ScrollLogoUp:			; scrolls generic logo up
	ld	b, 35

	; scroll logo offscreen for 35 frames
_:	push	bc
	ld	de, VRAM
	ld	hl, VRAM + (LcdWidth*4/2)
	ld	bc, lcdWidth*98/2
	ldir
	pop	bc
	call	WaitAFrame
	djnz	-_

	; get the selected game
	call	LocateGameHeader

	; load the game's logo from the vector table
	push	hl
	pop	ix
	ld	bc, (ix + 3)
	add	hl, bc

	; if the game's missing, bail out
	ld	a, (GameMissing)
	or	a
	ret	nz

	; draw the logo onto SafeRAM
	ld	de, pixelShadow
	push	de
	call	DecompressZX0
	pop	hl
	ld	de, plotSScreen + (LcdWidth*44/2) + 80
	call	DrawLogo

ScrollLogoDown:
	ld	ix, ScrollLogoY

	; scroll logo down
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

	; clear error message
	DrawText(0, 140, BlankTitleText)
	DrawText(0, 156, BlankTitleText)
	DrawText(0, 164, BlankTitleText)
	DrawText(0, 172, BlankTitleText)

	; draw "PRESS 2ND TO PLAY" text
	Drawtext(52, 150, Press2ndText)

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
	ret

StartButtonToggle:
	.db $00

ToggleText:	; toggle text on title screen
	ld	hl, StartButtonToggle
	ld	de, VRAM + (173*lcdWidth/2) + 52

	ld	a, (hl)
	cpl
	ld	(hl), a

	ld	ix, StartButtonText
	or	a
	jr	nz, DrawString

	ld	ix, BlankButtonText

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

CopyrightText:
	.db "1980-2025 NAMCO LTD.",0
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
	.db "                                        ",0

ExitGame:
	ld	sp, (appData)
	pop	iy

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
	call	ResetStatusBar
	ei
	ret

ExitGameSIS:	; return to launcher from selected game
	ld	a, (KbdG6)
	bit	kbitClear, a
	jp	z, ExitGame_Bailout

	; make the player hold clear for 1.5 seconds before exiting
	push	hl
	ld	hl, ExitGame_FrameCounter
	inc	(hl)
	ld	a, (hl)
	cp	30
	pop	hl
	ret.sis	nz

	ld	sp, (appData)
	jp	SoftReset
ExitGameSIS_End:

ExitGame_Bailout:
	xor	a
	ld	(ExitGame_FrameCounter), a
	ret.sis

ExitGame_FrameCounter:
	.db 0

SoftReset:
	ld	ix, CurrentBTNS

	; cancel out the clear key
	set	BIT_EXIT, (ix)
	set	BIT_EXIT, (ix + 1)

	jp	JumpToLauncher

WaitAFrame:
	; if clear was pressed, exit the launcher
	ld	ix, CurrentBTNS
	ld	a, (ix)

	; this checks if clear was pressed inside the launcher
	xor	(ix + 1)
	and	(ix)

	bit	BIT_EXIT, a
	jp	nz, ExitGame

	ld	hl, mpLcdRis
	bit	3, (hl)
	jr	z, WaitAFrame

	ld	hl, mpLcdIcr
	set	3, (hl)
	ld	hl, FrameCounter
	inc	(hl)

HandleInputs:
	; save old input map
	ld	a, (CurrentBTNS)
	ld	(LastBTNS), a

	push	bc

	ld	ix, BTN_Maps
	ld	hl, 1
	ld	de, KbdG1
	ld	bc, $0800

HandleInputs_Loop:
	ld	e, (ix)
	ld	a, (de)
	and	(ix + 1)
	jr	z, +_

	ld	a, c
	or	l
	ld	c, a

_:	add	hl, hl
	lea	ix, ix + 2
	djnz	HandleInputs_Loop

	ld	a, c
	ld	(CurrentBTNS), a

	pop	bc
	ret
	
#macro keyMap(column, key)
	.db column & $FF, key
#endmacro

BTN_Maps:
	#define BTN_DOWN	$01
	#define BIT_DOWN	0
	keyMap(KbdG7, kbdDown)

	#define BTN_UP		$02
	#define BIT_UP		1
	keyMap(KbdG7, kbdUp)

	#define BTN_LEFT	$04
	#define BIT_LEFT	2
	keyMap(KbdG7, kbdLeft)

	#define BTN_RIGHT	$08
	#define BIT_RIGHT	3
	keyMap(KbdG7, kbdRight)

	#define BTN_START	$10
	#define BIT_START	4
	keyMap(KbdG1, kbdMode)

	#define BTN_SELECTGAME	$20
	#define BIT_SELECTGAME	5
	keyMap(KbdG1, kbd2nd)

	#define BTN_EXIT	$40
	#define BIT_EXIT	6
	keyMap(KbdG6, kbdClear)

	; unused (for now)
	keyMap(KbdG2, kbdAlpha)

	#define BTN_ARROWKEYS	$0F

CurrentBTNS:
	.db $00
LastBTNS:
	.db $00

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
	.dl PacManArcadeHeader
	.dl PacManGGHeader
	.dl MSXHeader
	.dl AtariPacHeader
	.dl MsPacArcHeader
	.dl MsPacMSHeader
	.dl SuperPacHeader

#if PacPlus = 1
	; Pac-Man Plus was ported via hex editing,
	; so a Pac-Man Plus ROM is needed to build it.
	.dl PacPlusHeader
#endif

#if PacPlus = 1
#define CurrentGameCount 7
#else
#define CurrentGameCount 6
#endif

PacManArcadeHeader:
	.db $15, "PacArc",0
PacManGGHeader:
	.db $15, "PacGG",0
MSXHeader:
	.db $15, "PacMSX",0
AtariPacHeader:
	.db $15, "AtariPac",0
MsPacArcHeader:
	.db $15, "MsPacArc",0
MsPacMSHeader:
	.db $15, "MsPacMan",0
SuperPacHeader:
	.db $15, "SuperPac",0
PacPlusHeader:
	.db $15, "PacPlus",0

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