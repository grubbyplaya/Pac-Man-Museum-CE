PacManLeftSprites:
	.dl RegularAnim
	.dl PacAnimTiming	; animation to loop
PacManLeftSpriteLoop:
	.dl PacManLeft1
	.dl PacManClosed
	.dl PacManLeft2
	.dl PacManLeftSpriteLoop

MsPacManLeftSprites:
	.dl RegularAnim
	.dl PacAnimTiming
MsPacManLeftSpriteLoop:
	.dl MsPacManLeft1
	.dl MsPacManClosed
	.dl MsPacManLeft2
	.dl MsPacManLeftSpriteLoop

SuperPacManLeftSprites:
	.dl SuperPacAnim
	.dl PacAnimTiming
SuperPacManLeftSpriteLoop:
	.dl SuperPacLeft1
	.dl SuperPacClosed
	.dl SuperPacLeft2
	.dl SuperPacManLeftSpriteLoop

BlinkyLeftSprites:
	.dl RegularAnim
	.dl GhostAnimTiming
BlinkyLeftSpriteLoop:
	.dl BlinkyLeft1
	.dl BlinkyLeft2
	.dl BlinkyLeftSpriteLoop

PinkyLeftSprites:
	.dl RegularAnim
	.dl GhostAnimTiming
PinkyLeftSpriteLoop:
	.dl PinkyLeft1
	.dl PinkyLeft2
	.dl PinkyLeftSpriteLoop

InkyLeftSprites:
	.dl RegularAnim
	.dl GhostAnimTiming
InkyLeftSpriteLoop:
	.dl InkyLeft1
	.dl InkyLeft2
	.dl InkyLeftSpriteLoop

ClydeLeftSprites:
	.dl RegularAnim
	.dl GhostAnimTiming
ClydeLeftSpriteLoop:
	.dl ClydeLeft1
	.dl ClydeLeft2
	.dl ClydeLeftSpriteLoop

ScaredGhostSprites:
	.dl RegularAnim
	.dl GhostAnimTiming
ScaredGhostSpriteLoop:
	.dl ScaredGhost1
	.dl ScaredGhost2
	.dl ScaredGhostSpriteLoop

PookaSprites:
	.dl RegularAnim
	.dl PookaAnimTiming
PookaSpriteLoop:
	.dl Pooka1
	.dl Pooka2
	.dl PookaSpriteLoop

GalaxSprites:
	.dl RegularAnim
	.dl GalaxAnimTiming
GalaxSpriteLoop:
	.dl Galax1
	.dl Galax2
	.dl GalaxSpriteLoop

MappySprites:
	.dl RegularAnim
	.dl MappyAnimTiming
MappySpriteLoop:
	.dl Mappy1
	.dl Mappy2
	.dl Mappy3
	.dl MappySpriteLoop

SonicSprites:
	.dl SonicAnim
	.dl SonicAnimTiming
SonicSpriteLoop:
	.dl Sonic1
	.dl Sonic2
	.dl Sonic3
	.dl SonicSpriteLoop

BlankSprites:
	.dl RegularAnim
	.dl BlankAnimTiming
BlankSpriteLoop:
	.dl BlankImg
	.dl BlankSpriteLoop

#macro LOOP(OffsetX, OffsetY)
	.db $F0, OffsetX, OffsetY
#endmacro

#macro SETN(value)
	.db $F2, value
#endmacro

#macro SETSIZE(size)
	.db $F4, size
#endmacro

#macro END
	.db $FF
#endmacro

SuperPacAnim:
	SETSIZE(2)
RegularAnim:
	SETN($D4)
	LOOP(-1, 0)
	END

SonicAnim:
	SETN($6A)
	LOOP(-2, 0)
	END

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

#define BlankImg plotSScreen

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