PacManLeftAnim:
	.dl PacAnim	;animation to loop
	.db $00
PacManLeftAnimLoop:
	.dl PacManLeft1
	.dl PacManClosed
	.dl PacManLeft2
	.dl PacManLeftAnimLoop

MsPacManLeftAnim:
	.dl PacAnim
	.db $00
MsPacManLeftAnimLoop:
	.dl MsPacManLeft1
	.dl MsPacManClosed
	.dl MsPacManLeft2
	.dl MsPacManLeftAnimLoop

SuperPacManLeftAnim:
	.dl PacAnim	;animation to loop
	.db $02
SuperPacManLeftAnimLoop:
	.dl SuperPacLeft1
	.dl SuperPacClosed
	.dl SuperPacLeft2
	.dl SuperPacManLeftAnimLoop

BlinkyLeftAnim:
	.dl GhostAnim
	.db $00
BlinkyLeftAnimLoop:
	.dl BlinkyLeft1
	.dl BlinkyLeft2
	.dl BlinkyLeftAnimLoop

PinkyLeftAnim:
	.dl GhostAnim
	.db $00
PinkyLeftAnimLoop:
	.dl PinkyLeft1
	.dl PinkyLeft2
	.dl PinkyLeftAnimLoop

InkyLeftAnim:
	.dl GhostAnim
	.db $00
InkyLeftAnimLoop:
	.dl InkyLeft1
	.dl InkyLeft2
	.dl InkyLeftAnimLoop

ClydeLeftAnim:
	.dl GhostAnim
	.db $00
ClydeLeftAnimLoop:
	.dl ClydeLeft1
	.dl ClydeLeft2
	.dl ClydeLeftAnimLoop

ScaredGhostAnim:
	.dl GhostAnim
	.db $00
ScaredGhostAnimLoop:
	.dl ScaredGhost1
	.dl ScaredGhost2
	.dl ScaredGhostAnimLoop

Sprite1Pos:
	.db 304/2, 153	 	;start at 304, 153
	.db 0, 153		;end at 0, 153

Sprite2Pos:
	.db 328/2, 153		;start at 328, 153
	.db 0, 153		;end at 0, 153

Sprite3Pos:
	.db 352/2, 153		;start at 352, 153
	.db 0, 153		;end at 0, 153

Sprite4Pos:
	.db 376/2, 153		;start at 376, 153
	.db 0, 153		;end at 0, 153

Sprite5Pos:
	.db 400/2, 153		;start at 400, 153
	.db 0, 153		;end at 0, 153

Sprite6Pos:
	.db 424/2, 153		;start at 424, 153
	.db 0, 153		;end at 0, 153


PacAnim:	;animation for Mr and Ms. Pac-Man
	.db $02, $01	;hold sprite 1 for 2 frames
	.db $03, $03	;hold sprite 3 for 3 frames
	.db $02, $02	;hold sprite 2 for 2 frames
	.db $FE, $04	;loop back to index #4

GhostAnim:	;animation for inky, blinky, pinky, and clyde
	.db $03, $01
	.db $03, $02
	.db $FE, $03

PacManLeftArt:
PacManLeft1:
#import "src/includes/art/PacManLeft1.bin"
PacManLeft2:
#import "src/includes/art/PacManLeft2.bin"
PacManClosed:
#import "src/includes/art/PacManClosed.bin"

MsPacManLeftArt:
MsPacManLeft1:
#import "src/includes/art/MsPacLeft1.bin"
MsPacManLeft2:
#import "src/includes/art/MsPacLeft2.bin"
MsPacManClosed:
#import "src/includes/art/MsPacClosed.bin"

SuperPacLeftArt:
SuperPacLeft1:
#import "src/includes/art/SuperPac1.bin"
SuperPacLeft2:
#import "src/includes/art/SuperPac2.bin"
SuperPacClosed:
#import "src/includes/art/SuperPacClosed.bin"

BlinkyLeftArt:
BlinkyLeft1:
#import "src/includes/art/BlinkyLeft1.bin"
BlinkyLeft2:
#import "src/includes/art/BlinkyLeft2.bin"

PinkyLeftArt:
PinkyLeft1:
#import "src/includes/art/PinkyLeft1.bin"
PinkyLeft2:
#import "src/includes/art/PinkyLeft2.bin"

InkyLeftArt:
InkyLeft1:
#import "src/includes/art/InkyLeft1.bin"
InkyLeft2:
#import "src/includes/art/InkyLeft2.bin"

ClydeLeftArt:
ClydeLeft1:
#import "src/includes/art/ClydeLeft1.bin"
ClydeLeft2:
#import "src/includes/art/ClydeLeft2.bin"

ScaredGhostArt:
ScaredGhost1:
#import "src/includes/art/ScaredGhost1.bin"
ScaredGhost2:
#import "src/includes/art/ScaredGhost2.bin"