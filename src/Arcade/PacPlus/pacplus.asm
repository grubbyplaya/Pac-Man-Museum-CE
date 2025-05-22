#include "src/Arcade/includes/pacdefines.asm"

.ASSUME ADL=0

.db $FF
.ORG 0
.ASSUME ADL=0

.dl MusHeader
.dl MusIcon
.dl HeaderLength

MusHeader:
    .db $81, "Pac-Man Plus (Arcade Ver.)", 0
MusIcon:
#import "src/includes/gfx/logos/arcade.bin"
HeaderLength:

.ORG $8000

PatchGame:
    ; lifted from https://github.com/simonowen/pacemuzx/blob/master/pacemuzx.asm#L234
    ld      hl, PacPlus
    ld      de, $0000
    ld      bc, $4000
    ldir

    ; disable interrupts in Pac-Plus' original int handler
    ld      a, $F3
    ld      ($01D9), a

    ; set dip switches
    ld      a, %11001101
    ld      (DIP), a

    ; set default input
    ld      a, $FF
    ld      (IN0), a
    ld      (IN1), a

    ld      a, $56            ; ED *56*
    ld      ($233C), a        ; change IM 2 to IM 1

    ld      hl, $47ED
    ld      ($233F), hl       ; change OUT ($00), A to LD I, A
    ld      ($3183), hl

    ld      a, $C3            ; JP nn
    ld      ($0038), a
    ld      hl, HandleInterrupt   ; interrupt hook
    ld      ($0039), hl

    ld      a, $01            ; to change $5000 writes to $5001, which is unused
    ld      ($0093), a
    ld      ($01D7), a
    ld      ($2347), a
    ld      ($238A), a
    ld      ($3194), a
    ld      ($3248), a

    ld      a, 1              ; start clearing at $5001, to avoid DIP overwrite
    ld      ($2353), a
    ld      a, 7              ; shorten block clear after start adjustment above
    ld      ($230F), a
    ld      ($2357), a

    ld      a, $41            ; start clearing at $5041, to avoid DIP overwrite
    ld      ($2363), a
    ld      a, $3F            ; shorten block clear after start adjustment above
    ld      ($2366), a

    ; add CE-specific tilemap drawing flags
    call    ApplyTilemapFlags

    ; load in a fix to the self-test
    ld      hl, SelfTestFix
    ld      de, $3000
    ld      bc, 6
    ldir

    ld      a, $B0            ; LSB of address in look-up table
    ld      ($3FFA), a        ; skip memory test (actual code starts at $3000)

    call.lil Setup + romStart
    jp      $0000
    
SelfTestFix:
    ld	sp, $4FC0
    jp	$30C1

ApplyTilemapFlags:
    ld      hl, PATCH_3FE
    ld      ($03CE), hl

    ld      hl, PATCH_A2C
    ld      ($0702), hl

    ld      a, $C3
    ld      ($1A05), a
    ld      hl, PATCH_1A05
    ld      ($1A06), hl

    ld      hl, PATCH_2108
    ld      ($0A72), hl
    ld      hl, PATCH_219E
    ld      ($0A78), hl
    
    ld      ($230B), a
    ld      hl, PATCH_230B
    ld      ($230C), hl
    
    ld      hl, PATCH_23ED
    ld      ($2374), hl
    ld      ($23A8), hl

    ld      hl, PATCH_2448
    ld      ($23AE), hl

    ld      hl, PATCH_24D7
    ld      ($23AA), hl

    ld      ($2C6E), a
    ld      hl, PATCH_2C6E
    ld      ($2C6F), hl

    add     a, 10
    ld      ($241F), a
    ld      hl, PATCH_241F
    ld      ($2420), hl

    ld      ($2297), a
    ld      hl, PATCH_2297
    ld      ($2298), hl
    ret

PATCH_3FE:
    ld      a, (DrawTilemapFlag)
    ex      af, af'
    call    $2BAA
    ex      af, af'
    ld      (DrawTilemapFlag), a
    jp      $0401

PATCH_A2C:
    xor     a
    ld      (CoffeeBreakTrig), a
    jp      $0A57

PATCH_1A05:
    push    af
    call    SetTilemapFlag
    pop     af
    ld      ix, $4E0E
    jp      $1A09

PATCH_2108:
    ld      a, 1
    ld      (CoffeeBreakTrig), a
    jp      $2108

PATCH_219E:
    ld      a, 1
    ld      (CoffeeBreakTrig), a

    call    SetTilemapFlag
    jp      $219E

PATCH_2297:
    ld      a, 1
    ld      (CoffeeBreakTrig), a

    ld      a, ($4E08)
    ret

PATCH_230B:
    call    SetTilemapFlag
    ld      hl, $5001
    jp      $230E

PATCH_23ED:
    push    bc
    call    SetTilemapFlag
    call    ClearTilemapCache
    pop     bc
    jp      $23ED

PATCH_241F:
    ld      a, (bc)
    and     a
    ret     nz

    call    SetTilemapFlag
    pop     af
    ret

PATCH_2448:
    call    SetTilemapFlag
    jp      $2448

PATCH_24D7:
    ld      hl, $24D7
    push    hl

    ld      a, b
    rst     $20

    .dw SetMazeTeal
    .dw SetMazeTeal
    .dw SetMazeWhite
    .dw SetMazeBlack

SetMazeTeal:
    push    bc
    ld      hl, $A2D4
    ld      de, $FED4
    ld.lil  bc, $E0FEDF
    jr      SetMazePal

SetMazeWhite:
    push    bc
    ld      hl, $6B7F
    ld      de, $FED4
    ld.lil  bc, $E0FEDF
    jr      SetMazePal

SetMazeBlack:
    push    bc
    ld      hl, $0000
    ld      de, $0000
    ld.lil  bc, $E00000

SetMazePal:
    ld.lil  (mpLcdPalette + (24*4*2) + 4), bc
    ld.lil  (mpLcdPalette + (16*4*2) + 2), de
    ld.lil  (mpLcdPalette + (26*4*2) + 2), de
    ld.lil  (mpLcdPalette + (27*4*2) + 2), de
    ld.lil  (mpLcdPalette + (16*4*2) + 6), hl
    ld.lil  (mpLcdPalette + (27*4*2) + 6), hl
    pop     bc
    ret

PATCH_2C6E:
    ld      a, d
    and     $03
    ld      d, a

    call    SetTilemapFlag
    
    ld      ix, $4400
    jp      $2C72

SetTilemapFlag:
    ld      a, 1
    ld      (DrawTilemapFlag), a
    ret


HandleInterrupt:
    di
    ; save registers
    push    af
    push    bc
    push    de
    push    hl
    push    ix
    push    iy

    call     SetIntVector

    call.lil HandleCocktailFlip + romStart

    call    HandleScroll

    call.lil DrawScreen + romStart
    
    call.lil HandleInput + romStart

IntVector = $+1
    call    $008D

    ld      a, 8
    ld.lil  (mpLcdIcr), a

    call.lil CheckForExit

    ; restore registers
    pop     iy
    pop     ix
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei
    reti

HandleScroll:
    ; did we just start? if so, bail out
    ld      a, ($4E00)
    or      a
    jr      z, HandleScroll_Cutscene

    ; if we're not in the demo, skip ahead
    cp      1
    jr      nz, +_

    ; if the demo's playing the game, use the regular scrolling.
    ; Otherwise, use the cutscene one
    ld      a, ($4E02)
DemoScrollState = $+1
    cp      $23
    jr      z, HandleScroll_Gameplay
    jr      HandleScroll_Cutscene

_:  cp      3
    jr      z, HandleScroll_Gameplay

HandleScroll_Cutscene:
    ld      a, ($4E03)
    cp      3
    ld      a, 48
    jr      z, UpdateScrollReg

    ; center the screen if no gameplay isn't happening
    ld      a, 24
    jr      UpdateScrollReg

HandleScroll_Gameplay:
    ; if a coffee break is happening, use the cutscene scroll
    ld      a, (CoffeeBreakTrig)
    or      a
    jr      nz, HandleScroll_Cutscene

    ld      a, ($4D08)
    or      a
    ld      a, 48
    jr      z, UpdateScrollReg

    ; check if we hit the highest the screen can go
    ld      a, ($4D08)
    cp      $80 - 24
    jr      nc, +_

    ; set the scroll register to 0 (top of the screen)
    xor     a
    jr      UpdateScrollReg

    ; check if we hit the lowest the screen can go
_:  cp      $80 + 24
    jr      c, +_

    ; set the scroll register to 48 (bottom of the screen)
    ld      a, 48
    jr      UpdateScrollReg

    ; otherwise, scroll based off of Pac-Man's Y position
_:  sub     $80 - 24

UpdateScrollReg:
    ld.lil  (mpLcdMBASE + 1), a
    ret

CoffeeBreakTrig:
    .db 0

SetIntVector:
    push    hl

    ld      a, i

    ; is the int vector $3FFA?
    cp      $FA
    jr      nz, +_

    ld      hl, $30B0
    ld      (IntVector), hl

    ; if the vector's not $3FFC, it's invalid. bail out
_:  cp      $FC
    jr      nz, +_

    ld      hl, $008D
    ld      (IntVector), hl

_:  pop     hl
    ret

ClearTilemapCache:
    ld      hl, PrevTilemap & $FFFF
    push    hl
    pop     de
    inc     de
    ld      bc, $0400
    ld      (hl), $FF
    ldir
    ret

.ASSUME ADL=1
; run in ADL mode
DrawScreen:
    call    PartialRedraw

    ; check if the tilemap should be redrawn
    ld      hl, DrawTilemapFlag + romStart
    ld      a, (hl)
    ld      (hl), 0
    or      a
    call    nz, DrawMainTilemap

    call    SaveSpriteBG
    call    DrawSprites

    call    DrawHUDTilemap
    call    DrawLivesTilemap
    ret.sis

; emulates Pac-Man cocktail flipping
HandleCocktailFlip:
    ; $5003 = Pac-Man screen flip register
    ld      a, ($5003 + romStart)
    bit     0, a
    push    af
    call    nz, FlipScreenSPI
    pop     af
    call    z, UnflipScreenSPI
    ret.sis

Setup:
    ; set LCD framebuffer PTR to the framebuffer
    ld      hl, ScreenPTR
    ld      (mpLCdMBASE), hl

    ; load Pac-Man tile and sprite ROMs
LoadArt = $+1
    ld      hl, ArtHeader + romStart
    call    Mov9ToOP1
    call    ChkFindSym
    jp      c, ErrorQuit

HeaderSize = $+1
    ld      hl, $0014
    add     hl, de
    ld      de, pixelShadow
    ld      bc, $8000
    ldir

    ld      hl, ADLShift + romStart
    ld      de, cursorImage
    ld      bc, CursorCodeEnd - CursorCodeStart
    ldir

    ld      hl, TextShadowShift + romStart
    ld      de, TextShadow
    ld      bc, ShadowCodeEnd - ShadowCodeStart
    ldir
    
    ; load Pac-Man palette ROM
ConvertPaletteLIL:
    call    ConvertPalette 
    ret.sis

ArtHeader:
    .db $15, "PacPlArt", 0

HandleInput:
    ld      ix, IN0_Maps + romStart
    call    UpdateInputLoop + romStart
    ld      (IN0 + romStart), a

    ld      ix, IN1_Maps + romStart
    call    UpdateInputLoop + romStart
    ld      (IN1 + romStart), a
    ret.sis

UpdateInputLoop:
    ld      de, kbdG1
    ld      bc, $08FF
    ld      hl, 1

    ; set DE to the key column to be read
_:  ld      e, (ix)
    ld      a, (de)
    ; skip if the button isn't pressed
    and     (ix + 1)
    jr      z, +_

    ; clear the corresponding bit
    ld      a, c
    xor     l
    ld      c, a

    ; go to next column
_:  add     hl, hl
    lea     ix, ix + 2
    djnz    --_
    ld      a, c
    ret

IN0_Maps:
    .db KbdG7 & $FF, kbdUp
    .db KbdG7 & $FF, kbdLeft
    .db KbdG7 & $FF, kbdRight
    .db KbdG7 & $FF, kbdDown
    .db 0, 0         ; auto advance, unmapped
    .db KbdG4 & $FF, kbd5       ; player 1 coin
    .db KbdG5 & $FF, kbd6       ; player 2 coin
    .db 0, 0         ; credit button, unmapped

IN1_Maps:
    .db KbdG7 & $FF, kbdUp
    .db KbdG7 & $FF, kbdLeft
    .db KbdG7 & $FF, kbdRight
    .db KbdG7 & $FF, kbdDown
    .db KbdG1 & $FF, kbdDel      ; board test. releasing causes reset
    .db KbdG1 & $FF, kbdMode     ; player 1 start
    .db KbdG3 & $FF, kbdGraphVar ; player 2 start
    .db 0, 0                     ; cabinet type, unmapped

#define IN0 $5000
#define IN1 $5040
#define DIP $5080

.ASSUME ADL=0

PacPlus:
#import "src/Arcade/pacplus/pacplus.bin"

#define cursorImage $E30800

ADLShift:
.ORG cursorImage

CursorCodeStart:
#include "src/Arcade/PacRenderer.asm"

; color data

Colors:
.dw $0000, $FFE0, $7C00, $FEDF, $83FF, $FECA, $83E0, $909F, $FED4, $A2D4, $0240, $593F, $FFF4, $D9AA, $DADF, $6B7F

Palette:
 #import "src/Arcade/includes/pluspalette.bin"

CursorCodeEnd:
#include "src/includes/ti_equates.asm"

.ORG ADLShift + (CursorCodeEnd - CursorCodeStart)
TextShadowShift:
.ORG TextShadow
ShadowCodeStart:
#include "src/includes/spi.asm"
ShadowCodeEnd: