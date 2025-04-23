PacManLeftAnim:
	.dl PacAnimTiming	; animation to loop
	.db $00
PacManLeftAnimLoop:
	.dl PacManLeft1
	.dl PacManClosed
	.dl PacManLeft2
	.dl PacManLeftAnimLoop

MsPacManLeftAnim:
	.dl PacAnimTiming	
	.db $00
MsPacManLeftAnimLoop:
	.dl MsPacManLeft1
	.dl MsPacManClosed
	.dl MsPacManLeft2
	.dl MsPacManLeftAnimLoop

SuperPacManLeftAnim:
	.dl PacAnimTiming	; animation to loop
	.db $02
SuperPacManLeftAnimLoop:
	.dl SuperPacLeft1
	.dl SuperPacClosed
	.dl SuperPacLeft2
	.dl SuperPacManLeftAnimLoop

BlinkyLeftAnim:
	.dl GhostAnimTiming
	.db $00
BlinkyLeftAnimLoop:
	.dl BlinkyLeft1
	.dl BlinkyLeft2
	.dl BlinkyLeftAnimLoop

PinkyLeftAnim:
	.dl GhostAnimTiming
	.db $00
PinkyLeftAnimLoop:
	.dl PinkyLeft1
	.dl PinkyLeft2
	.dl PinkyLeftAnimLoop

InkyLeftAnim:
	.dl GhostAnimTiming
	.db $00
InkyLeftAnimLoop:
	.dl InkyLeft1
	.dl InkyLeft2
	.dl InkyLeftAnimLoop

ClydeLeftAnim:
	.dl GhostAnimTiming
	.db $00
ClydeLeftAnimLoop:
	.dl ClydeLeft1
	.dl ClydeLeft2
	.dl ClydeLeftAnimLoop

ScaredGhostAnim:
	.dl GhostAnimTiming
	.db $00
ScaredGhostAnimLoop:
	.dl ScaredGhost1
	.dl ScaredGhost2
	.dl ScaredGhostAnimLoop

PookaAnim:
	.dl PookaAnimTiming
	.db $00
PookaAnimLoop:
	.dl Pooka1
	.dl Pooka2
	.dl PookaAnimLoop

GalaxAnim:
	.dl GalaxAnimTiming
	.db $00
GalaxAnimLoop:
	.dl Galax1
	.dl Galax2
	.dl GalaxAnimLoop

MappyAnim:
	.dl MappyAnimTiming
	.db $00
MappyAnimLoop:
	.dl Mappy1
	.dl Mappy2
	.dl Mappy3
	.dl MappyAnimLoop

SonicAnim:
	.dl SonicAnimTiming
	.db $00
SonicAnimLoop:
	.dl Sonic1
	.dl Sonic2
	.dl Sonic3
	.dl SonicAnimLoop

BlankAnim:
	.dl BlankAnimTiming
	.db $00
BlankAnimLoop:
	.dl BlankSprite
	.dl BlankAnimLoop

Sprite1Pos:
	.db 304/2, 153	 	; start at 304, 153
	.db 0, 153		; end at 0, 153

Sprite2Pos:
	.db 328/2, 153		; start at 328, 153
	.db 0, 153		; end at 0, 153

Sprite3Pos:
	.db 352/2, 153		; start at 352, 153
	.db 0, 153		; end at 0, 153

Sprite4Pos:
	.db 376/2, 153		; start at 376, 153
	.db 0, 153		; end at 0, 153

Sprite5Pos:
	.db 400/2, 153		; start at 400, 153
	.db 0, 153		; end at 0, 153

Sprite6Pos:
	.db 424/2, 153		; start at 424, 153
	.db 0, 153		; end at 0, 153


PacAnimTiming:		; animation for Mr and Ms. Pac-Man
	.db $02, $01	; hold sprite 1 for 2 frames
	.db $03, $03	; hold sprite 3 for 3 frames
	.db $02, $02	; hold sprite 2 for 2 frames
	.db $FE, $04	; jump to the fourth indice

GhostAnimTiming:	; animation for inky, blinky, pinky, and clyde
	.db $08, $01
	.db $08, $02
	.db $FE, $03

PookaAnimTiming:
	.db $06, $01
	.db $10, $02
	.db $FE, $03

GalaxAnimTiming:	; animation for static images
	.db $1F, $01
	.db $1F, $02
	.db $FE, $03

MappyAnimTiming:
	.db $06, $01
	.db $06, $02
	.db $06, $03
	.db $FE, $04

SonicAnimTiming:
	.db $04, $01
	.db $04, $03
	.db $04, $01
	.db $04, $02
	.db $FE, $04

BlankAnimTiming:
	.db $E0, $01
	.db $FE, $02	; do nothing

#define BlankSprite plotSScreen

PacManLeftArt:
PacManLeft1:
#import "src/includes/gfx/sprites/PacManLeft1.bin"
PacManLeft2:
#import "src/includes/gfx/sprites/PacManLeft2.bin"
PacManClosed:
#import "src/includes/gfx/sprites/PacManClosed.bin"

MsPacManLeftArt:
MsPacManLeft1:
#import "src/includes/gfx/sprites/MsPacLeft1.bin"
MsPacManLeft2:
#import "src/includes/gfx/sprites/MsPacLeft2.bin"
MsPacManClosed:
#import "src/includes/gfx/sprites/MsPacClosed.bin"

SuperPacLeftArt:
SuperPacLeft1:
#import "src/includes/gfx/sprites/SuperPac1.bin"
SuperPacLeft2:
#import "src/includes/gfx/sprites/SuperPac2.bin"
SuperPacClosed:
#import "src/includes/gfx/sprites/SuperPacClosed.bin"

BlinkyLeftArt:
BlinkyLeft1:
#import "src/includes/gfx/sprites/BlinkyLeft1.bin"
BlinkyLeft2:
#import "src/includes/gfx/sprites/BlinkyLeft2.bin"

PinkyLeftArt:
PinkyLeft1:
#import "src/includes/gfx/sprites/PinkyLeft1.bin"
PinkyLeft2:
#import "src/includes/gfx/sprites/PinkyLeft2.bin"

InkyLeftArt:
InkyLeft1:
#import "src/includes/gfx/sprites/InkyLeft1.bin"
InkyLeft2:
#import "src/includes/gfx/sprites/InkyLeft2.bin"

ClydeLeftArt:
ClydeLeft1:
#import "src/includes/gfx/sprites/ClydeLeft1.bin"
ClydeLeft2:
#import "src/includes/gfx/sprites/ClydeLeft2.bin"

ScaredGhostArt:
ScaredGhost1:
#import "src/includes/gfx/sprites/ScaredGhost1.bin"
ScaredGhost2:
#import "src/includes/gfx/sprites/ScaredGhost2.bin"

PookaArt:
Pooka1:
#import "src/includes/gfx/sprites/Pooka1.bin"
Pooka2:
#import "src/includes/gfx/sprites/Pooka2.bin"

GalaxArt:
Galax1:
#import "src/includes/gfx/sprites/Galax1.bin"
Galax2:
#import "src/includes/gfx/sprites/Galax2.bin"

MappyArt:
Mappy1:
#import "src/includes/gfx/sprites/Mappy1.bin"
Mappy2:
#import "src/includes/gfx/sprites/Mappy2.bin"
Mappy3:
#import "src/includes/gfx/sprites/Mappy3.bin"

SonicArt:
Sonic1:
#import "src/includes/gfx/sprites/Sonic1.bin"
Sonic2:
#import "src/includes/gfx/sprites/Sonic2.bin"
Sonic3:
#import "src/includes/gfx/sprites/Sonic3.bin"
