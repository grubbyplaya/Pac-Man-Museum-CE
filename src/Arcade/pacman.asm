#include "src/Arcade/includes/pacdefines.asm"

.db $FF
.org 0
.ASSUME ADL=0

.dl MuseumHeader
.dl MuseumIcon
.dl HeaderEnd

MuseumHeader:
	.db $80, "Pac-Man (Arcade Ver.)",0
MuseumIcon:
#import "src/includes/gfx/logos/arcade.bin"
HeaderEnd:

.org 0

EntryPoint:     ; $0000
    call.lil Setup + romStart
    jp      LABEL_230B

RST_8:         ; $0008 - Memset
    ld      (hl), a
    inc     hl
    djnz    RST_8
QuickRet:
    ret

SetDifficulty:  ; $000D
    jp      LABEL_70E

RST_10:         ; $0010 - load byte from a lookup table
    add     a, l
    ld      l, a
    ld      a, 0
    adc     a, h
    ld      h, a
    ld      a, (hl)
    ret

RST_18:         ; $0018 - load word from a lookup table
    ld      a, b
    add     a, a
    rst     $10
    ld      e, a
    inc     hl
    ld      d, (hl)
    ex      de, hl
    ret

RST_20:         ; $0020 - jump table
    pop     hl      ; HL = return address
    add     a, a
    rst     $10
    ld      e, a
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)

RST_28:          ; $0028 - load a generic task (IN: task, parameter)
    pop     hl
    ld      b, (hl)
    inc     hl
    ld      c, (hl)
    inc     hl
    push    hl      ; HL = return address
    jr      LABEL_42

RST_30:         ; $0030 - load a timed task (IN: timer, task, parameter)
    ld      de, $4C90
    ld      b, $10
    jp      LABEL_51

RST_38:         ; $0038 - waitloop
    jp      HandleInterrupt
    nop
    ld      ($5007), a
    jp      RST_38


LABEL_42:
    ; continue from RST_28
    ld      hl, ($4C80)     ; HL = PTR to task list
    ld      (hl), b
    inc     l
    ld      (hl), c
    inc     l
    jr      nz, +_
    ld      l, $C0
_:  ld      ($4C80), hl     ; store new pointer
    ret

LABEL_51:
    ; continue from RST_30
    ld      a, (de)
    and     a
    jr      z, +_
    inc     e
    inc     e
    inc     e
    djnz    LABEL_51
    ret

_:  pop     hl
    ld      b, 3

_:  ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     e
    djnz    -_
    jp      (hl)

LABEL_65:
    jp      LABEL_202D

DifficultyData_Normal:
    .db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20

DifficultyData_Hard:
    .db 1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 20

HandleVBlank:   ; 008D
    ; load channel 1 frequency
    ld      hl, CH1_FREQ0
    ld      de, $5050
    ld      bc, 16
    ldir

    ; load channel 1 waveform
    ld      a, (CH1_W_NUM)
    and     a
    ld      a, (CH1_W_SEL)
    jr      nz, +_
    ld      a, (CH1_E_TABLE0)
_:  ld      ($5045), a

    ; load channel 2 waveform
    ld      a, (CH2_W_NUM)
    and     a
    ld      a, (CH2_W_SEL)
    jr      nz, +_
    ld      a, (CH2_E_TABLE0)
_:  ld      ($504A), a

    ; load channel 3 waveform
    ld      a, (CH3_W_NUM)
    and     a
    ld      a, (CH3_W_SEL)
    jr      nz, +_
    ld      a, (CH3_E_TABLE0)
_:  ld      ($504F), a

    ; copy sprite data
    ld      hl, $4C02
    ld      de, $4C22
    ld      bc, $001C
    ldir


    ; update sprite data
    ld      ix, $4C20

    ; update Blinky's sprite
    ld      a, (ix + 2)
    rlca
    rlca
    ld      (ix + 2), a

    ; update Pinky's sprite
    ld      a, (ix + 4)
    rlca
    rlca
    ld      (ix + 4), a

    ; update Inky's sprite
    ld      a, (ix + 6)
    rlca
    rlca
    ld      (ix + 6), a

    ; update Clyde's sprite
    ld      a, (ix + 8)
    rlca
    rlca
    ld      (ix + 8), a

    ; update Pac-Man's sprite
    ld      a, (ix + 10)
    rlca
    rlca
    ld      (ix + 10), a

    ; update the fruit's sprite
    ld      a, (ix + 12)
    rlca
    rlca
    ld      (ix + 12), a

    ; skip if no ghosts have been eaten
    ld      a, ($4DD1)
    cp      $01
    jr      nz, +_

    ; offset IX into the eaten ghost sprite PTR
    ld      ix, $4C20
    ld      a, ($4DA4)
    add     a, a
    ld      e, a
    ld      d, 0
    add     ix, de

    ; load eaten ghost sprite data
    ld      hl, ($4C24)
    ld      de, ($4C34)
    ld      a, (ix + 0)
    ld      ($4C24), a
    ld      a, (ix + 1)
    ld      ($4C25), a
    ld      a, (ix + 16)
    ld      ($4C34), a
    ld      a, (ix + 17)
    ld      ($4C35), a
    ld      (ix + 0), l
    ld      (ix + 1), h
    ld      (ix + 16), e
    ld      (ix + 17), d

    ; skip if a power pellet isn't active
_:  ld      a, ($4DA6)
    and     a
    jp      z, +_

    ld      bc, ($4C22)
    ld      de, ($4C32)
    ld      hl, ($4C2A)
    ld      ($4C22), hl
    ld      hl, ($4C3A)
    ld      ($4C32), hl
    ld      ($4C2A), bc
    ld      ($4C3A), de

    ; write sprite data to VRAM
_:  ld      hl, $4C22
    ld      de, $4FF2
    ld      bc, 12
    ldir

    ld      hl, $4C32
    ld      de, $5062
    ld      bc, 12
    ldir

    ; main loop
    call    LABEL_1DC
    call    LABEL_221
    call    LABEL_3C8
    
    ; skip if the game's still booting up
    ld      a, ($4E00)
    and     a
    jr      z, +_

    call    LABEL_39D
    call    LABEL_1490
    call    LABEL_141F
    call    LABEL_267
    call    LABEL_2AD
    call    LABEL_2FD

_:  ld      a, ($4E00)
    dec     a
    jr      nz, +_
    ld      ($4EAC), a
    ld      ($4EBC), a

    ; process sound
_:  call    LABEL_2D0C
    call    LABEL_2CC1

    ld      a, ($4E00)
    and     a
    jr      z, +_

    ; check for reset
    ld      a, (IN1)
    and     %10000
    jp      z, Reset

    ; check to enable fast hack
    ld.lil  a, (KbdG1)
    bit     kbitZoom, a
    jp      z, +_

    ld      a, 1
    ld      (FastHackTrig), a
    jp      Reset

_:  ld      a, 1
    ld      ($5000), a
    ret

Reset:
    ; if this reset is caused by pressing DEL, 
    ; reset the fast hack flag. Otherwise,
    ; (ZOOM caused the reset) don't touch it.
    ld      a, (IN1)
    and     %10000
    jp      nz, LABEL_230B

    ld      (FastHackTrig), a
    jp      LABEL_230B

LABEL_1DC:  ; updates timers
    ld      hl, $4C84
    inc     (hl)
    inc     hl
    dec     (hl)
    inc     hl
    ld      de, DATA_219
    ld      bc, $0401

_:  inc     (hl)
    ld      a, (hl)
    and     $0F
    ex      de, hl
    cp      (hl)
    jr      nz, SetupRNG

    inc     c
    ld      a, (de)
    add     a, $10
    and     $F0
    ld      (de), a
    inc     hl
    cp      (hl)
    jr      nz, SetupRNG

    inc     c
    ex      de, hl
    ld      (hl), $00
    inc     hl
    inc     de
    djnz    -_

SetupRNG:
    ld      hl, $4C8A
    ld      (hl), c
    inc     l
    ; A = (A * 5) + 1
    ld      a, (hl)
    add     a, a
    add     a, a
    add     a, (hl)
    inc     a
    ld      (hl), a
    inc     l
    ; A = (A * 13) + 1
    ld      a, (hl)
    add     a, a
    add     a, (hl)
    add     a, a
    add     a, a
    add     a, (hl)
    inc     a
    ld      (hl), a
    ret

DATA_219:
    .db $06, $A0, $0A, $60, $0A, $60, $0A, $A0 

LABEL_221:
    ld      hl, $4C90
    ld      a, ($4C8A)
    ld      c, a
    ld      b, $10

    ; is the task blank? loop back for the next task
_:  ld      a, (hl)
    and     a
    jr      z, +_

    ; not time to tick the timer yet? loop back for the next task
    and     $C0
    rlca
    rlca
    cp      c
    jr      nc, +_

    ; timer's not done yet? loop back for the next task
    dec     (hl)
    ld      a, (hl)
    and     $3F
    jr      nz, +_

    ; load A and B with the task parameters and execute
    ld      (hl), a
    push    bc
    push    hl
    inc     l
    ld      a, (hl)
    inc     l
    ld      b, (hl)

    ld      hl, LABEL_25B
    push    hl
    rst     $20

DATA_247:
    .dw LABEL_894
    .dw LABEL_6A3
    .dw LABEL_58E
    .dw LABEL_1272
    .dw LABEL_1000
    .dw LABEL_100B
    .dw LABEL_263
    .dw LABEL_212B
    .dw LABEL_21F0
    .dw LABEL_22B9

LABEL_25B:
    pop     hl
    pop     bc

_:  inc     l
    inc     l
    inc     l
    djnz    --_
    ret

LABEL_263:
    ; insert task
    rst     $28
    .db $1C, $86 
    ret

LABEL_267:
    ld      a, ($4E6E)
    cp      $99
    rla
    ld      ($5006), a
    rra
    ; exit if 99 coins have been entered
    ret     nc

    ; A = input data
    ld      a, (IN0)
    ld      b, a
    rlc     b
    ld      a, ($4E66)
    rla
    and     $0F
    ld      ($4E66), a
    ; are we in service mode?
    sub     $0C
    call    z, LABEL_2DF

    rlc     b
    ld      a, ($4E67)
    rla
    and     $0F
    ld      ($4E67), a
    ; has a coin been inserted?
    sub     $0C
    jp      nz, +_

    ld      hl, $4E69
    inc     (hl)
_:  rlc     b
    ld      a, ($4E68)
    rla
    and     $0F
    ld      ($4E68), a
    ; has a coin been inserted?
    sub     $0C
    ret     nz

    ld      hl, $4E69
    inc     (hl)
    ret

LABEL_2AD:  ; add credits
    ; bail out if there's no coins
    ld      a, ($4E69)
    and     a
    ret     z

    ld      b, a
    ld      a, ($4E6A)
    ld      e, a
    cp      $00
    jp      nz, +_

    ld      a, 1
    ld      ($5007), a
    call    LABEL_2DF

_:  ld      a, e
    cp      $08
    jp      nz, +_

    xor     a
    ld      ($5007), a

_:  inc     e
    ld      a, e
    ld      ($4E6A), a
    sub     $10
    ret     nz

    ld      ($4E6A), a
    dec     b
    ld      a, b
    ld      ($4E69), a
    ret

LABEL_2DF:  ; coins -> credits routine
    ld      a, ($4E6B)
    ld      hl, $4E6C
    inc     (hl)
    sub     (hl)
    ret     nz

    ld      (hl), a
    ld      a, ($4E6D)
    ld      hl, $4E6E
    add     a, (hl)
    daa
    jp      nc, +_
    ld      a, $99
_:  ld      (hl), a

    ld      hl, $4E9C
    set     1, (hl)
    ret

LABEL_2FD:  ; blink coin lights
    ld      hl, $4DCE
    inc     (hl)
    ld      a, (hl)
    and     $0F
    jr      nz, +++_

    ld      a, (hl)
    rrca
    rrca
    rrca
    rrca
    ld      b, a

    ld      a, ($4DD6)
    cpl
    or      b
    ld      c, a

    ld      a, ($4E6E)
    sub     1
    jr      nc, +_
    xor     a
    ld      c, a
_:  jr      z, +_

    ld      a, c

_:  ld      ($5005), a
    ld      a, c
    ld      ($5004), a

    ; IX = 1UP tilemap position
_:  ld      ix, $43D8
    ; IY = 2UP tilempa position
    ld      iy, $43C5
    ld      a, ($4E00)
    cp      3
    jp      z, LABEL_344

    ld      a, ($4E03)
    cp      2
    jp      nc, LABEL_344

    call    LABEL_369
    call    LABEL_376
    ret

LABEL_344:  ; blink 1UP/2UP
    ld      a, ($4E09)
    and     a
    ld      a, ($4DCE)
    jp      nz, +_

    ; blink "1UP"
    bit     4, a
    call    z, LABEL_369
    call    nz, LABEL_383
    jp      ++_

    ; blink "2UP"
_:  bit     4, a
    call    z, LABEL_376
    call    nz, LABEL_390

_:  ld      a, ($4E70)
    and     a
    call    z, LABEL_390
    ret

LABEL_369:  ; draw '1UP'
    ld      (ix + 0), $50
    ld      (ix + 1), $55
    ld      (ix + 2), $31
    ret

LABEL_376:  ; draw '2UP'
    ld      (iy + 0), $50
    ld      (iy + 1), $55
    ld      (iy + 2), $32
    ret

LABEL_383:  ; clear '1UP'
    ld      (ix + 0), $40
    ld      (ix + 1), $40
    ld      (ix + 2), $40
    ret

LABEL_390:  ; clear '2UP'
    ld      (iy + 0), $40
    ld      (iy + 1), $40
    ld      (iy + 2), $40
    ret

LABEL_39D:  ; draw big Pac-Man sprite (Coffee Break #1)
    ld      a, ($4E06)
    sub     5
    ret     c
    ; FALL THROUGH
LABEL_3A3:
    ld      hl, ($4D08)
    ld      b, $08
    ld      c, $10
    ld      a, l
    ld      ($4D06), a
    ld      ($4DD2), a
    sub     c
    ld      ($4D02), a
    ld      ($4D04), a
    ld      a, h
    add     a, b
    ld      ($4D03), a
    ld      ($4D07), a
    sub     c
    ld      ($4D05), a
    ld      ($4DD3), a
    ret

LABEL_3C8:
    ld      a, ($4E00)
    rst     $20
    ; jump table
    .dw     LABEL_3D4
    .dw     LABEL_3FE
    .dw     LABEL_5E5
    .dw     LABEL_6BE

LABEL_3D4:
    ld      a, ($4E01)
    rst     $20
    ; jump table
    .dw LABEL_3DC
    .dw QuickRet

LABEL_3DC:
    ; clear the screen
    rst     $28
    .db     $00, $00

    ; clear color RAM
    rst     $28
    .db     $06, $00

    ; color the maze
    rst     $28
    .db     $01, $00

    ; check all DIP switches
    rst     $28
    .db     $14, $00

    ; draw scores
    rst     $28
    .db     $18, $00

    ; reset RAM
    rst     $28
    .db     $04, $00

    ; clear VRAM
    rst     $28
    .db     $1E, $00

    ; set to demo mode
    rst     $28
    .db     $07, $00

    ld      hl, $4E01
    inc     (hl)
    ld      hl, $5001
    ld      (hl), $01
    ret

LABEL_3FE:
    ; LABEL_2BA1 updates the tilemap every frame, even when it's unnecessary. 
    ; The tilemap drawing flag is saved and restored to prevent this.
    ld      a, (DrawTilemapFlag)
    ex      af, af'
    call    LABEL_2BA1
    ex      af, af'
    ld      (DrawTilemapFlag), a

    ld      a, ($4E6E)
    and     a
    jr      z, LABEL_413

    xor     a
    ld      ($4E04), a
    ld      ($4E02), a
Patch01 = $+2   ; Ms. Pac - Patch 01
    ld      hl, $4E00
    inc     (hl)
    ret

LABEL_413:
    ld      a, ($4E02)
    rst     $20
    .dw LABEL_45F  ; clear screen, reset memory, clear sprites
    .dw QuickRet      ; returns immediately
    .dw LABEL_471  ; draw Blinky
    .dw QuickRet      ; returns immediately
    .dw LABEL_47F  ; draw -SHADOW
    .dw QuickRet      ; returns immediately
    .dw LABEL_485  ; draw BLINKY
    .dw QuickRet      ; returns immediately
    .dw LABEL_48B  ; draw Pinky
    .dw QuickRet      ; returns immediately
    .dw LABEL_499  ; draw -SPEEDY
    .dw QuickRet      ; returns immediately
    .dw LABEL_49F  ; draw PINKY
    .dw QuickRet      ; returns immediately
    .dw LABEL_4A5  ; draw Inky
    .dw QuickRet      ; returns immediately
    .dw LABEL_4B3  ; draw -BASHFUL
    .dw QuickRet      ; returns immediately
    .dw LABEL_4B9  ; draw INKY
    .dw QuickRet      ; returns immediately
    .dw LABEL_4BF  ; draw Clyde
    .dw QuickRet      ; returns immediately
    .dw LABEL_4CD  ; draw -POKEY
    .dw QuickRet      ; returns immediately
    .dw LABEL_4D3  ; draw CLYDE
    .dw QuickRet      ; returns immediately
    .dw LABEL_4D8  ; draw . 10 Pts and o 50pts
    .dw QuickRet      ; returns immediately
    .dw LABEL_4E0  ; get demo ready and draw invisible maze
    .dw QuickRet      ; returns immediately
    .dw LABEL_51C  ; start and run demo
    .dw LABEL_54B  ; check to release pinky
    .dw LABEL_556  ; check to release inky
    .dw LABEL_561  ; check to release Clyde
    .dw LABEL_56C  ; check for completion of demo
    .dw LABEL_57C  ; end demo and return to program 

LABEL_45F:  ; clear screen, reset memory, clear sprites
    ; insert tasks
    rst     $28
    .db     $00, $01
    rst     $28
    .db     $01, $00
    rst     $28
    .db     $04, $00
    rst     $28
    .db     $1E, $00

    ld      c, $0C
    call    LABEL_585
    ret

LABEL_471:  ; draw Blinky
    ld      hl, $4304
    ld      a, $01
    call    LABEL_5BF
    ld      c, $0C
    call    LABEL_585
    ret

LABEL_47F:  ; draw -SHADOW
    ld      c, $14
    call    LABEL_593
    ret

LABEL_485:  ; draw BLINKY
    ld      c, $0D
    call    LABEL_593
    ret

LABEL_48B:  ; draw pinky
    ld      hl, $4307
    ld      a, $03
    call    LABEL_5BF
    ld      c, $0C
    call    LABEL_585
    ret

LABEL_499:  ; draw -SPEEDY
    ld      c, $16
    call    LABEL_593
    ret

LABEL_49F:  ; draw PINKY
    ld      c, $0F
    call    LABEL_593
    ret

LABEL_4A5:   ; draw blue ghost
    ld      hl, $430A
    ld      a, $05
    call    LABEL_5BF
    ld      c, $0C
    call    LABEL_585
    ret

LABEL_4B3:  ; draw -BASHFUL
    ld      c, $33
    call    LABEL_593
    ret

LABEL_4B9:  ; draw INKY
    ld      c, $2F
    call    LABEL_593
    ret

LABEL_4BF:  ; draw Clyde
    ld      hl, $430D
    ld      a, $07
    call    LABEL_5BF
    ld      c, $0C
    call    LABEL_585
    ret

LABEL_4CD:  ; draw -POKEY
    ld      c, $35
    call    LABEL_593
    ret

LABEL_4D3:  ; draw CLYDE
    ld      c, $31
    jp      LABEL_580

LABEL_4D8:  ; draw pellet point text
    ; insert task
    rst     $28
    .db     $1C, $11

    ld      c, $12
    jp      LABEL_585

LABEL_4E0:  ; draw copyright info
    ld      c, $13
    call    LABEL_585
    call    LABEL_879
    dec     (hl)

    ; insert tasks
    rst     $28
    .db $11, $00
    rst     $28
    .db $05, $01
    rst     $28
    .db $10, $14
    rst     $28
    .db $04, $01

    ld      a, 1
    ld      ($4E14), a
    xor     a
    ld      ($4E70), a
    ld      ($4E15), a

    ld      hl, $4332
    ld      (hl), $14

LABEL_506:
    ld      a, $FC
    ld      de, $0020
    ld      b, $1C
    ld      ix, $4040

_:  ld      (ix + $11), a
    ld      (ix + $13), a
    add     ix, de
    djnz    -_
    ret

LABEL_51C:  ; start and run demo
    ld      hl, $4DA0
    ld      b, $21

    ld      a, ($4D3A)
LABEL_524:
    sub     b
    jr      nz, DemoLoop
    ld      (hl), 1
    jp      LABEL_58E

DemoLoop:   ; $052C
    call    LABEL_1017
    call    LABEL_1017
    call    LABEL_E23
    call    LABEL_C0D
    call    LABEL_BD6
    call    LABEL_5A5
    call    LABEL_1EFE
    call    LABEL_1F25
    call    LABEL_1F4C
    call    LABEL_1F73
    ret

LABEL_54B:  ; release pinky
    ld      hl, $4DA1
    ld      b, $20
    ld      a, ($4D32)
    jp      LABEL_524

LABEL_556:  ; release blue ghost
    ld      hl, $4DA2
    ld      b, $22
    ld      a, ($4D32)
    jp      LABEL_524

LABEL_561:  ; release Clyde
    ld      hl, $4DA3
    ld      b, $24
    ld      a, ($4D32)
    jp      LABEL_524

LABEL_56C:
    ld      a, ($4DD0)
    ld      b, a
    ld      a, ($4DD1)
    add     a, b
    cp      6
    jp      z, LABEL_58E
    jp      DemoLoop

LABEL_57C:
    call    LABEL_6BE
    ret

LABEL_580:
    ld      a, ($4E75)
    add     a, c
    ld      c, a
LABEL_585:
    ld      b, $1C
    call    LABEL_42

    ; insert task
    rst     $30
    .db     $4A, $02, $00

LABEL_58E:
    ld      hl, $4E02
    inc     (hl)
    ret

LABEL_593:
    ld      a, ($4E75)
    add     a, c
    ld      c, a
    ld      b, $1C
    call    LABEL_42

    ; insert task
    rst     $30
    .db     $45, $02, $00

    call    LABEL_58E
    ret

LABEL_5A5:
    ld      a, ($4DB5)
    and     a
    ret     z

    xor     a
    ld      ($4DB5), a
    ld      a, ($4D30)
    xor     %10
    ld      ($4D3C), a
    ld      b, a
    ld      hl, DATA_32FF
    rst     $18
    ld      ($4D26), hl
    ret

LABEL_5BF:
    ld      (hl), $B1
    inc     l
    ld      (hl), $B3
    inc     l
    ld      (hl), $B5
    ld      bc, $001E
    add     hl, bc

    ld      (hl), $B0
    inc     l
    ld      (hl), $B2
    inc     l
    ld      (hl), $B4
    ld      de, $0400
    add     hl, de

    ld      (hl), a
    dec     l
    ld      (hl), a
    dec     l
    ld      (hl), a
    and     a
    sbc     hl, bc

    ld      (hl), a
    dec     l
    ld      (hl), a
    dec     l
    ld      (hl), a
    ret

LABEL_5E5:
    ld      a, ($4E03)
    rst     $20

    ; jump table
    .dw LABEL_5F3
    .dw LABEL_61B
    .dw LABEL_674
    .dw QuickRet
    .dw LABEL_6A8

LABEL_5F3:
    call    LABEL_2BA1

    ; insert tasks
    rst     $28
    .db     $00, $01
    rst     $28
    .db     $01, $00
    rst     $28
    .db     $1C, $07
    rst     $28
    .db     $1C, $0B
    rst     $28
    .db     $1C, $37
    rst     $28
    .db     $1E, $00
    
    ld      hl, $4E03
    inc     (hl)
    ld      a, 1
    ld      ($4DD6), a

    ld      a, ($4E71)
    cp      $FF
    ret     z

    ; insert tasks
    rst     $28
    .db     $1C, $0A
    rst     $28
    .db     $1F, $00
    ret

LABEL_61B:
    call    LABEL_2BA1
    ld      a, ($4E6E)
    cp      $01
    ld      b, $09
    jr      nz, +_
    ld      b, $08
_:  call    LABEL_2C5E

    ld      a, ($4E6E)
    cp      $01
    ld      a, (IN1)
    jr      z, +_
    bit     6, a
    jr      nz, +_
    ld      a, $01
    ld      ($4E70), a
    jp      LABEL_649

_:  bit     5, a
    ret     nz
    ; FALL THROUGH

LABEL_645:
    xor     a
    ld      ($4E70), a
LABEL_649:
    ld      a, ($4E6B)
    and     a
    jr      z, ++_

    ld      a, ($4E70)
    and     a
    ld      a, ($4E6E)
    jr      z, +_

    add     a, $99
    daa

_:  add     a, $99
    daa
    ld      ($4E6E), a
    call    LABEL_2BA1

_:  ld      hl, $4E03
    inc     (hl)
    xor     a
    ld      ($4DD6), a
    inc     a
    ld      ($4ECC), a
    ld      ($4EDC), a
    ret

LABEL_674:
    ; insert tasks
    rst     $28
    .db     $00, $01
    rst     $28
    .db     $01, $01
    rst     $28
    .db     $02, $00
    rst     $28
    .db     $12, $00
    rst     $28
    .db     $03, $00
    rst     $28
    .db     $1C, $03
    rst     $28
    .db     $1C, $06
    rst     $28
    .db     $18, $00
    rst     $28
    .db     $1B, $00

    xor     a
    ld      ($4E13), a
    ld      a, ($4E6F)
    ld      ($4E14), a
    ld      ($4E15), a

    ; insert tasks
    rst     $28
    .db     $1A, $00
    rst     $30
    .db     $57, $01, $00

    ; FALL THROUGH
LABEL_6A3:
    ld      hl, $4E03
    inc     (hl)
    ret

LABEL_6A8:
    ld      hl, $4E15
    dec     (hl)
    call    LABEL_2B6A
    xor     a
    ld      ($4E03), a
    ld      ($4E02), a
    ld      ($4E04), a
    ld      hl, $4E00
    inc     (hl)
    ret

; maze loop
LABEL_6BE:
    ld      a, ($4E04)
    rst     $20

    ; jump table
    .dw LABEL_879 ; set up game initialization
    .dw LABEL_899 ; set up tasks for beginning of game
    .dw QuickRet   ; returns immediately
    .dw LABEL_8CD ; demo mode or player is playing
    .dw LABEL_90D ; when player has collided with hostile ghost (died)
    .dw QuickRet   ; returns immediately
    .dw LABEL_940 ; check for game over, do things if true
    .dw QuickRet   ; returns immediately
    .dw LABEL_972 ; end of demo mode when ms pac dies in demo.  clears a bunch of memories.
    .dw LABEL_988 ; sets a bunch of tasks and displays "ready" or "game over"
    .dw QuickRet   ; returns immediately
    .dw LABEL_9D2 ; begin start of maze demo after marquee
    .dw LABEL_9D8 ; clears sounds and sets a small delay.  run at end of each level
    .dw QuickRet   ; returns immediately
    .dw LABEL_9E8 ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_9FE ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A02 ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A04 ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A06 ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A08 ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A0A ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A0C ; flash screen
    .dw QuickRet   ; returns immediately
    .dw LABEL_A0E ; set a bunch of tasks
    .dw QuickRet   ; returns immediately
    .dw LABEL_A2C ; clears all sounds and runs intermissions when needed
    .dw QuickRet   ; returns immediately
    .dw LABEL_A7C ; clears sounds, increases level, increases difficulty if needed, resets pill maps
    .dw LABEL_AA0 ; get game ready to play and set this sub back to #03
    .dw QuickRet   ; returns immediately
    .dw LABEL_AA3 ; sets sub # back to #03

; sets game difficulty
LABEL_70E:
    ld      a, b
    and     a
    jr      nz, +_

    ld      hl, ($4E0A)
    ld      a, (hl)

_:  ld      ix, DATA_796
    ; IX += A*6
    ld      e, a
    ld      d, 6
    mlt     de
    add     ix, de

    ld      e, (ix)
    ld      d, 42
    mlt     de
    ld      hl, DATA_330F
    add     hl, de
    call    LABEL_814

    ld      a, (ix + 1)
    ld      ($4DB0), a

    ld      e, (ix + 2)
    ld      d, 3
    mlt     de
    ld      hl, DATA_843
    add     hl, de
    call    LABEL_83A

    ld      a, (ix + 3)
    add     a, a
    ld      e, a
    ld      d, 0
    ld      iy, DATA_84F
    add     iy, de
    ld      l, (iy + 0)
    ld      h, (iy + 1)
    ld      ($4DBB), hl

    ld      a, (ix + 4)
    add     a, a
    ld      e, a
    ld      d, 0
    ld      iy, DATA_861
    add     iy, de
    ld      l, (iy + 0)
    ld      h, (iy + 1)
    ld      ($4DBD), hl

    ld      a, (ix + 5)
    add     a, a
    ld      e, a
    ld      d, 0
    ld      iy, DATA_873
    add     iy, de
    ld      l, (iy + 0)
    ld      h, (iy + 1)
    ld      ($4D95), hl
    call    LABEL_2BEA
    ret

DATA_796:
.db 3, 1, 1, 0, 2, 0
.db 4, 1, 2, 1, 3, 0
.db 4, 1, 3, 2, 4, 1
.db 4, 2, 3, 2, 5, 1
.db 5, 0, 3, 2, 6, 2
.db 5, 1, 3, 3, 3, 2
.db 5, 2, 3, 3, 6, 2
.db 5, 2, 3, 3, 6, 2
.db 5, 0, 3, 4, 7, 2
.db 5, 1, 3, 4, 3, 2
.db 5, 2, 3, 4, 6, 2
.db 5, 2, 3, 5, 7, 2
.db 5, 0, 3, 5, 7, 2
.db 5, 2, 3, 5, 5, 2
.db 5, 1, 3, 6, 7, 2
.db 5, 2, 3, 6, 7, 2
.db 5, 2, 3, 6, 8, 2
.db 5, 2, 3, 6, 7, 2
.db 5, 2, 3, 7, 8, 2
.db 5, 2, 3, 7, 8, 2
.db 6, 2, 3, 7, 8, 2

LABEL_814:
    ld      de, $4D46
    ld      bc, $001C
    ldir
    ld      bc, $000C
    and     a
    sbc     hl, bc
    ldir
    ld      bc, $000C
    and     a
    sbc     hl, bc
    ldir
    ld      bc, $000C
    and     a
    sbc     hl, bc
    ldir
    ld      bc, $000E
    ldir
    ret

LABEL_83A:
    ld      de, $4DB8
    ld      bc, 3
    ldir
    ret

; timers for when Pinky, Inky, and Clyde exit the Ghost House
DATA_843:
.db $14, $1E, $46
.db $00, $1E, $3C
.db $00, $00, $32
.db $00, $00, $00

DATA_84F:
.db $14, $0A
.db $1E, $0F
.db $28, $14
.db $32, $19
.db $3C, $1E
.db $50, $28
.db $64, $32
.db $78, $3C
.db $8C, $46

; time the ghosts stay scared when a power pellet is eaten
DATA_861:
.dw 8*120
.dw 7*120
.dw 6*120
.dw 5*120
.dw 4*120
.dw 3*120
.dw 2*120
.dw 1*120
.dw 1

DATA_873:
.dw 240
.dw 240
.dw 180

LABEL_879:
    ld      hl, $4E09
    xor     a
    ld      b, $0B
    rst     $08
    call    LABEL_24C9
    ld      hl, ($4E73)
    ld      ($4E0A), hl
    ld      hl, $4E0A
    ld      de, $4E38
    ld      bc, $002E
    ldir
    ; FALL THROUGH

LABEL_894:
    ld      hl, $4E04
    inc     (hl)
    ret

LABEL_899:
    ld      a, ($4E00)
    dec     a
    jr      nz, +_

    ld      a, 9
    ld      ($4E04), a
    ret

    ; insert tasks
_:  rst     $28
    .db     $11, $00
    rst     $28
    .db     $1C, $83
    rst     $28
    .db     $04, $00
    rst     $28
    .db     $05, $00
    rst     $28
    .db     $10, $00
    rst     $28
    .db     $1A, $00
    rst     $30
    .db     $54, $00, $00
    rst     $30
    .db     $54, $06, $00

    ld      a, ($4E72)
    ld      b, a
    ld      a, ($4E09)
    and     b
    ld      ($5003), a
    jp      LABEL_894

LABEL_8CD:
    ld      a, (IN0)
    bit     4, a
    jp      nz, LABEL_8DE

    ld      hl, $4E04
    ld      (hl), $0E
    rst     $28
    .db     $13, $00
    ret

LABEL_8DE:
Patch02 = $+2   ; Ms. Pac - Patch 2
    ld      a, ($4E0E)
    cp      $F4
    jr      nz, LABEL_8EB

LABEL_8E5:
    ld      hl, $4E04
    ld      (hl), $0C
    ret
    

LABEL_8EB:
    call    LABEL_1017
    call    LABEL_1017
    call    LABEL_13DD
    call    LABEL_C42
    call    LABEL_E23
    call    LABEL_E36
    call    LABEL_AC3
    call    LABEL_BD6
    call    LABEL_C0D
    call    LABEL_E6C
    call    LABEL_EAD
    ret

LABEL_90D:
    ld      a, 1
    ld      ($4E12), a

    call    LABEL_2487
    ld      hl, $4E04
    inc     (hl)
    ld      a, ($4E14)
    and     a
    jr      nz, +_

    ld      a, ($4E70)
    and     a
    jr      z, +_

    ld      a, ($4E42)
    and     a
    jr      z, +_

    ; insert tasks
    ld      a, ($4E09)
    add     a, 3
    ld      c, a
    ld      b, $1C
    call    LABEL_42

    rst     $28
    .db     $1C, $05
    rst     $30
    .db     $54, $00, $00
    ret

_:  inc     (hl)
    ret

LABEL_940:
    ld      a, ($4E70)
    and     a
    jr      z, +_

    ld      a, ($4E42)
    and     a
    jr      nz, LABEL_961

_:  ld      a, ($4E14)
    and     a
    jr      nz, LABEL_96C

    call    LABEL_2BA1

    ; insert task
    rst     $28
    .db     $1C, $05
    rst     $30
    .db     $54, $00, $00
    ld      hl, $4E04
    inc     (hl)
    ret

LABEL_961:
    call    LABEL_AA6
    ld      a, ($4E09)
    xor     $01
    ld      ($4E09), a
LABEL_96C:
    ld      a, 9
    ld      ($4E04), a
    ret

LABEL_972:
    xor     a
    ld      ($4E02), a
    ld      ($4E04), a
    ld      ($4E70), a
    ld      ($4E09), a
    ld      ($5003), a
    ld      a, 1
    ld      ($4E00), a
    ret

LABEL_988:
    ; insert tasks
    rst     $28
    .db     $00, $01
    rst     $28
    .db     $01, $01
    rst     $28
    .db     $02, $00
    rst     $28
    .db     $11, $00
    rst     $28
    .db     $13, $00
    rst     $28
    .db     $03, $00
    rst     $28
    .db     $04, $00
    rst     $28
    .db     $05, $00
    rst     $28
    .db     $10, $00
    rst     $28
    .db     $1A, $00
    rst     $28
    .db     $1C, $06

    ld      a, ($4E00)
    cp      $03
    jr      z, +_

    ; insert tasks
    rst     $28
    .db     $1C, $05
    rst     $28
    .db     $1D, $00
_:  rst     $30
    .db     $54, $00, $00

    ld      a, ($4E00)
    dec     a
    jr      z, +_

    ; insert task
    rst     $30
    .db     $54, $06, $00

_:  ld      a, ($4E72)
    ld      b, a
    ld      a, ($4E09)
    and     b
    ld      ($5003), a
    jp      LABEL_894

LABEL_9D2:
    ld      a, $03
    ld      ($4E04), a
    ret

LABEL_9D8:
    ; insert task
    rst     $30
    .db     $54, $00, $00

    ld      hl, $4E04
    inc     (hl)
    xor     a
    ld      ($4EAC), a
    ld      ($4EBC), a
    ret

LABEL_9E8:
    ld      c, $02
LABEL_9EA:
    ld      b, $01
    call    LABEL_42
    ; insert task
    rst     $30
    .db     $42, $00, $00

    ld      hl, 0
    call    LABEL_267E
    ld      hl, $4E04
    inc     (hl)
    ret

LABEL_9FE:
    ld      c, $00
    jr      LABEL_9EA
LABEL_A02:
    jr      LABEL_9E8
LABEL_A04:
    jr      LABEL_9FE
LABEL_A06:
    jr      LABEL_9E8
LABEL_A08:
    jr      LABEL_9FE
LABEL_A0A:
    jr      LABEL_9E8
LABEL_A0C:
    jr      LABEL_9FE

LABEL_A0E:
    ; insert tasks
    rst     $28
    .db     $00, $01
    rst     $28
    .db     $06, $00
    rst     $28
    .db     $11, $00
    rst     $28
    .db     $13, $00
    rst     $28
    .db     $04, $01
    rst     $28
    .db     $05, $01
    rst     $28
    .db     $10, $13
    rst     $30
    .db     $43, $00, $00

    ld      hl, $4E04
    inc     (hl)
    ret

LABEL_A2C:
    xor     a
    ld      ($4EAC), a
    ld      (CoffeeBreakTrig), a
Patch03:    ; Ms. Pac - Patch 3
    ld      ($4EBC), a
    ld      a, 2
    ld      ($4ECC), a
    ld      ($4EDC), a

LABEL_A3B:
    ld      a, ($4E13)
    cp      $14
    jr      c, +_
    ld      a, $14
_:  rst     $20
    ; jump table
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_2108 ; cut scene 1
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_219E ; cut scene 2
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_2297 ; cut scene 3
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_2297 ; cut scene 3
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_2297 ; cut scene 3
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound
    .dw LABEL_A6F  ; increment level state and stop sound

LABEL_A6F:
    ld      hl, $4E04
    inc     (hl)
    inc     (hl)
    xor     a
    ld      ($4ECC), a
    ld      ($4EDC), a
    ret

LABEL_A7C:
    xor     a
    ld      ($4ECC), a
    ld      ($4EDC), a
    ld      b, $07

    ld      hl, $4E0C
    rst     $08
    call    LABEL_24C9

    ld      hl, $4E04
    inc     (hl)

    ld      hl, $4E13
    inc     (hl)

    ld      hl, ($4E0A)
    ld      a, (hl)
    cp      $14
    ret     z

    inc     hl
    ld      ($4E0A), hl
    ret

LABEL_AA0:
    jp      LABEL_988

LABEL_AA3:
    jp      LABEL_9D2

LABEL_AA6:
    ld      b, $2E

    ld      ix, $4E0A
    ld      iy, $4E38
_:  ld      d, (ix)
    ld      e, (iy)
    ld      (iy), d
    ld      (ix), e
    inc     ix
    inc     iy
    djnz    -_
    ret

LABEL_AC3:
    ld      a, ($4DA4)
    and     a
    ret     nz

    ld      ix, $4C00
    ld      iy, $4DC8
    ld      de, $0100
    cp      (iy)
    jp      nz, SetGhostColors_Finish

    ld      (iy), $0E
    ld      a, ($4DA6)
    and     a
    jr      z, SetBlinkyColor

    ld      hl, ($4DCB)
    and     a
    sbc     hl, de
    jr      nc, SetBlinkyColor

    ld      hl, $4EAC
_:  set     7, (hl)
    ld      a, 9
    cp      (ix + $0B)
    jr      nz, +_

    res     7, (hl)
    ld      a, 9

    ; set Pac-Man's color
_:  ld      ($4C0B), a

SetBlinkyColor:
    ld      a, ($4DA7)
    ; if Blinky isn't edible, skip and set his color to red
    and     a
    jr      z, ++_

    ; if Blinky isn't about to be inedible, skip to the next ghost
    ld      hl, ($4DCB)
    and     a
    sbc     hl, de
    jr      nc, SetPinkyColor

    ; do the flashing colors
    ld      a, $11
    cp      (ix + 3)
    jr      z, +_

    ; make Blinky blue
    ld      (ix + 3), $11
    jp      SetPinkyColor

    ; make Blinky white
_:  ld      (ix + 3), $12
    jp      SetPinkyColor

    ; set Blinky's color to red
_:  ld      (ix + 3), $01
    ; FALL THROUGH
SetPinkyColor:
    ld      a, ($4DA8)
    ; if Pinky isn't edible, skip and set her color to pink
    and     a
    jr      z, ++_

    ; if Pinky isn't about to be inedible, skip to the next ghost
    ld      hl, ($4DCB)
    and     a
    sbc     hl, de
    jr      nc, SetInkyColor

    ; do the flashing colors
    ld      a, $11
    cp      (ix + 5)
    jr      z, +_

    ; make Pinky blue
    ld      (ix + 5), $11
    jp      SetInkyColor

    ; make Pinky white
_:  ld      (ix + 5), $12
    jp      SetInkyColor

    ; set Pinky's color to pink
_:  ld      (ix + 5), $03
    ; FALL THROUGH
SetInkyColor:
    ld      a, ($4DA9)
    ; if Inky isn't edible, skip and set his color to cyan
    and     a
    jr      z, ++_

    ; if Inky isn't about to be inedible, skip to the next ghost
    ld      hl, ($4DCB)
    and     a
    sbc     hl, de
    jr      nc, SetClydeColor

    ; do the flashing colors
    ld      a, $11
    cp      (ix + 7)
    jr      z, +_

    ; make Inky blue
    ld      (ix + 7), $11
    jp      SetClydeColor

    ; make Inky white
_:  ld      (ix + 7), $12
    jp      SetClydeColor

    ; set Inky's color to cyan
_:  ld      (ix + 7), $05
    ; FALL THROUGH
SetClydeColor:
    ld      a, ($4DAA)
    ; if Clyde isn't edible, skip and set his color to orange
    and     a
    jr      z, ++_

    ; if Clyde isn't about to be inedible, skip
    ld      hl, ($4DCB)
    and     a
    sbc     hl, de
    jr      nc, SetGhostColors_Finish

    ; do the flashing colors
    ld      a, $11
    cp      (ix + 9)
    jr      z, +_

    ; make Clyde blue
    ld      (ix + 9), $11
    jp      SetGhostColors_Finish

    ; make Clyde white
_:  ld      (ix + 9), $12
    jp      SetGhostColors_Finish

    ; set Clyde's color to orange
Patch04 = $+2   ; Ms. Pac - Patch 4
_:  ld      (ix + 9), $07
    ;   FALL THROUGH
SetGhostColors_Finish:
    dec     (iy)
    ret

LABEL_BD6:
    ld      b, $19
    ld      a, ($4E02)
    cp      $22
    jp      nz, +_

    ld      b, 0

_:  ld      ix, $4C00

    ld      a, ($4DAC)
    and     a
    jp      z, +_

    ld      (ix + 3), b

_:  ld      a, ($4DAD)
    and     a
    jp      z, +_

    ld      (ix + 5), b

_:  ld      a, ($4DAE)
    and     a
    jp      z, +_

    ld      (ix + 7), b

_:  ld      a, ($4DAF)
    and     a
    ret     z

    ld      (ix + 9), b
    ret

LABEL_C0D:  ; handles power pellet palette cycling
    ld      hl, $4DCF
    inc     (hl)
    ld      a, $0A
    cp      (hl)
    ret     nz

    ld      (hl), $00
    ld      a, ($4E04)
    cp      3
    jr      nz, LABEL_C33

Patch05 = $+2   ; Ms. Pac - Patch 5
    ld      hl, $4464
    ld      a, $10
    cp      (hl)
    jr      nz, +_

    ld      a, 0

_:  call    UpdateTilePalette
    ld      hl, $4478
    call    UpdateTilePalette
    ld      hl, $4784
    call    UpdateTilePalette
    ld      hl, $4798
    call    UpdateTilePalette
    ret

LABEL_C33:  ; handles demo power pellets
    ld      hl, $4732
    ld      a, $10
    cp      (hl)
    jr      nz, +_

    ld      a, 0

_:  call    UpdateTilePalette
    ld      hl, $4678
    call    UpdateTilePalette
    ret

LABEL_C42:
    ld      a, ($4DA4)
    and     a
    ret     nz

    ld      a, ($4D94)
    rlca
    ld      ($4D94), a
    ret     nc

    ; check ghost house collision for Blinky
    ld      a, ($4DA0)
    and     a
    ; skip to Pinky if Blinky's not in the ghoust house
    jp      nz, LABEL_C90

    ; handle exiting the ghost house
    ld      ix, DATA_3305
    ld      iy, $4D00
    call    LABEL_2000
    ld      ($4D00), hl

    ld      a, 3
    ld      ($4D28), a
    ld      ($4D2C), a

    ld      a, ($4D00)
    cp      $64
    jp      nz, LABEL_C90

    ld      hl, $2E2C
    ld      ($4D0A), hl
    ld      hl, $0100
    ld      ($4D14), hl
    ld      ($4D1E), hl
    
    ld      a, 2
    ld      ($4D28), a
    ld      ($4D2C), a
    ld      a, 1
    ld      ($4DA0), a

    ; check ghost house collision for Pinky
LABEL_C90: 
    ld      a, ($4DA1)
    cp      $01
    jp      z, LABEL_CFB
    cp      $00
    jp      nz, LABEL_CC1

    ; Pinky is moving up and down in the ghost house
    ld      a, ($4D02)
    cp      $78
    call    z, LABEL_1F2E
    cp      $80
    call    z, LABEL_1F2E

    ld      a, ($4D2D)
    ld      ($4D29), a
    ld      ix, $4D20
    ld      iy, $4D02
    call    LABEL_2000
    ld      ($4D02), hl
    jp      LABEL_CFB

LABEL_CC1:
    ; handle exiting the ghost house
    ld      ix, DATA_3305
    ld      iy, $4D02
    call    LABEL_2000
    ld      ($4D02), hl

    ld      a, 3
    ld      ($4D2D), a
    ld      ($4D29), a

    ld      a, ($4D02)
    cp      $64
    jp      nz, LABEL_CFB

    ld      hl, $2E2C
    ld      ($4D0C), hl
    ld      hl, $0100
    ld      ($4D16), hl
    ld      ($4D20), hl
    
    ld      a, 2
    ld      ($4D29), a
    ld      ($4D2D), a
    ld      a, 1
    ld      ($4DA1), a

    ; check ghost house collision for Inky
LABEL_CFB: 
    ld      a, ($4DA2)
    cp      $01
    jp      z, LABEL_D93
    cp      $00
    jp      nz, LABEL_D2C

    ; Inky is moving up and down in the ghost house
    ld      a, ($4D04)
    cp      $78
    call    z, LABEL_1F55
    cp      $80
    call    z, LABEL_1F55

    ld      a, ($4D2E)
    ld      ($4D2A), a
    ld      ix, $4D22
    ld      iy, $4D04
    call    LABEL_2000
    ld      ($4D04), hl
    jp      LABEL_D93

LABEL_D2C:
    ld      a, ($4DA2)
    cp      $03
    jp      nz, LABEL_D59

    ; handle moving right on the way out of the ghost house
    ld      ix, DATA_32FF
    ld      iy, $4D04
    call    LABEL_2000
    ld      ($4D04), hl

    xor     a
    ld      ($4D2A), a
    ld      ($4D2E), a

    ld      a, ($4D05)
    cp      $80
    jp      nz, LABEL_D93
    ld      a, 2
    ld      ($4DA2), a
    jp      LABEL_D93

LABEL_D59:
    ; handle exiting the ghost house
    ld      ix, DATA_3305
    ld      iy, $4D04
    call    LABEL_2000
    ld      ($4D04), hl

    ld      a, 3
    ld      ($4D2A), a
    ld      ($4D2E), a

    ld      a, ($4D04)
    cp      $64
    jp      nz, LABEL_D93

    ld      hl, $2E2C
    ld      ($4D0E), hl
    ld      hl, $0100
    ld      ($4D18), hl
    ld      ($4D22), hl
    
    ld      a, 2
    ld      ($4D2A), a
    ld      ($4D2E), a
    ld      a, 1
    ld      ($4DA2), a

    ; check ghost house collision for Clyde
LABEL_D93: 
    ld      a, ($4DA3)
    cp      $01
    ret     z
    cp      $00
    jp      nz, LABEL_DC0

    ; Clyde is moving up and down in the ghost house
    ld      a, ($4D06)
    cp      $78
    call    z, LABEL_1F7C
    cp      $80
    call    z, LABEL_1F7C

    ld      a, ($4D2F)
    ld      ($4D2B), a
    ld      ix, $4D24
    ld      iy, $4D06
    call    LABEL_2000
    ld      ($4D06), hl
    ret

LABEL_DC0:
    ld      a, ($4DA3)
    cp      3
    jp      nz, LABEL_DEA

    ; handle moving left on the way out of the ghost house
    ld      ix, DATA_3303
    ld      iy, $4D06
    call    LABEL_2000
    ld      ($4D06), hl

    ld      a, 2
    ld      ($4D2B), a
    ld      ($4D2F), a

    ld      a, ($4D07)
    cp      $80
    ret     nz

    ld      a, 2
    ld      ($4DA3), a
    ret

LABEL_DEA:
    ; handle exiting the ghost house
    ld      ix, DATA_3305
    ld      iy, $4D06
    call    LABEL_2000
    ld      ($4D06), hl

    ld      a, 3
    ld      ($4D2B), a
    ld      ($4D2F), a

    ld      a, ($4D06)
    cp      $64
    ret     nz

    ; handle making it out of the ghost house
    ld      hl, $2E2C
    ld      ($4D10), hl
    ld      hl, $0100
    ld      ($4D1A), hl
    ld      ($4D24), hl
    
    ld      a, 2
    ld      ($4D2B), a
    ld      ($4D2F), a
    ld      a, 1
    ld      ($4DA3), a
    ret

LABEL_E23:
    ld      hl, $4DC4
    inc     (hl)
    ld      a, 8
    cp      (hl)
    ret     nz

    ld      (hl), 0
    ld      a, ($4DC0)
    xor     $01
    ld      ($4DC0), a
    ret

; reverse the direction of every ghost
LABEL_E36:
    ld      a, ($4DA6)
    and     a
    ret     nz

    ld      a, ($4DC1)
    cp      $07
    ret     z

    add     a, a
    ld      hl, ($4DC2)
    inc     hl
    ld      ($4DC2), hl

    ld      e, a
    ld      d, 0
    ld      ix, $4D86
    add     ix, de

    ld      e, (ix + 0)
    ld      d, (ix + 1)
Patch06:    ; Ms. Pac - Patch 6
    and     a
    sbc     hl, de
    ret     nz

    srl     a

    inc     a
    ld      ($4DC1), a
    ld      hl, $0101
    ld      ($4DB1), hl
    ld      ($4DB3), hl
    ret

LABEL_E6C:  ; changes BG sfx based on number of pills eaten
    ld      a, ($4DA5)
    and     a
    jr      z, +_
    xor     a
    ld      ($4EAC), a
    ret

_:  ld      hl, $4EAC
    ld      b, $E0
    ld      a, ($4E0E)
    cp      $E4
    jr      c, +_

    ld      a, b
    and     (hl)
    set     4, a
    ld      (hl), a
    ret

_:  cp      $D4
    jr      c, +_
    ld      a, b
    and     (hl)
    set     3, a
    ld      (hl), a
    ret

_:  cp      $B4
    jr      c, +_
    ld      a, b
    and     (hl)
    set     2, a
    ld      (hl), a
    ret

_:  cp      $74
    jr      c, +_
    ld      a, b
    and     (hl)
    set     1, a
    ld      (hl), a
    ret

_:  ld      a, b
Patch07:    ; Ms. Pac - Patch 7
    and     (hl)
    set     0, a
    ld      (hl), a
    ret

LABEL_EAD:
    ld      a, ($4DA5)
    and     a
    ret     nz

    ld      a, ($4DD4)
    and     a
    ret     nz

    ld      a, ($4E0E)
    cp      $46
    jr      z, +_
    cp      $AA
    ret     nz

    ld      a, ($4E0D)
    and     a
    ret     nz

    ld      hl, $4E0D
    inc     (hl)
    jr      ++_

_:  ld      a, ($4E0C)
    and     a
    ret     nz

    ld      hl, $4E0C
    inc     (hl)

_:  ld      hl, $8094
    ld      ($4DD2), hl

    ld      hl, DATA_EFD
    ld      a, ($4E13)
    cp      $14
    jr      c, +_

    ld      a, $14

    ; LD A, (HL + A*3)
_:  ld      b, a
    add     a, a
    add     a, b
    rst     $10
    ld      ($4C0C), a
    inc     hl
    ld      a, (hl)
    ld      ($4C0D), a
    inc     hl
    ld      a, (hl)
    ld      ($4DD4), a

    ; insert task
    rst     $30
    .db     $8A, $04, $00
    ret

DATA_EFD:
.db $00, $14, $06                ; cherry
.db $01, $0F, $07                ; strawberry
.db $02, $15, $08                ; 1st peach
.db $02, $15, $08                ; 2nd peach
.db $04, $14, $09                ; 1st apple
.db $04, $14, $09                ; 2nd apple
.db $05, $17, $0A                ; 1st grape
.db $05, $17, $0A                ; 2nd grape
.db $06, $09, $0B                ; 1st galaxian
.db $06, $09, $0B                ; 2nd galaxian
.db $03, $16, $0C                ; 1st bell
.db $03, $16, $0C                ; 2nd bell
.db $07, $16, $0D                ; 1st key
.db $07, $16, $0D                ; 2nd key
.db $07, $16, $0D                ; 3rd key
.db $07, $16, $0D                ; 4th key
.db $07, $16, $0D                ; 5th key
.db $07, $16, $0D                ; 6th key
.db $07, $16, $0D                ; 7th key
.db $07, $16, $0D                ; 8th key
.db $07, $16, $0D                ; 9th key

; ROM CHIP 2 (pacman.6f)

LABEL_1000:
Patch08:        ; Ms. Pac - Patch 08
    xor     a
    ld      ($4DD4), a
LABEL_1004:
    ld      hl, 0
Patch09 = $+1   ; Ms. Pac - Patch 09
    ld      ($4DD2), hl
    ret

LABEL_100B:
    ; insert tasks
    rst     $28
    .db     $1C, $9B

    ld      a, ($4E00)
    dec     a
    ret     z

    ; insert tasks
    rst     $28
    .db     $1C, $A2
    ret

LABEL_1017:
    call    LABEL_1291

    ld      a, ($4DA5)
    and     a
    ret     nz

    call    LABEL_1066
    call    LABEL_1094
    call    LABEL_109E
    call    LABEL_10A8
    call    LABEL_10B4

    ld      a, ($4DA4)
    and     a
    jp      z, +_

    call    LABEL_1235
    ret

_:  call    LABEL_171D
    call    LABEL_1789

    ld      a, ($4DA4)
    and     a
    ret     nz

    call    LABEL_1806
    call    LABEL_1B36
    call    LABEL_1C4B
    call    LABEL_1D22
    call    LABEL_1DF9

    ld      a, ($4E04)
    cp      3
    ret     nz

    call    LABEL_1376
    call    LABEL_2069
    call    LABEL_208C
    call    LABEL_20AF
    ret

LABEL_1066:
    ld      a, ($4DAB)
    and     a
    ret     z

    dec     a
    jr      nz, +_

    ld      ($4DAB), a
    inc     a
    ld      ($4DAC), a
    ret

_:  dec     a
    jr      nz, +_

    ld      ($4DAB), a
    inc     a
    ld      ($4DAD), a
    ret

_:  dec     a
    jr      nz, +_

    ld      ($4DAB), a
    inc     a
    ld      ($4DAE), a
    ret

_:  ld      ($4DAF), a
    dec     a
    ld      ($4DAB), a
    ret

LABEL_1094:
    ld      a, ($4DAC)
    rst     $20
    ; jump table
    .dw QuickRet
    .dw LABEL_10C0
    .dw LABEL_10D2

LABEL_109E:
    ld      a, ($4DAD)
    rst     $20
    ; jump table
    .dw QuickRet
    .dw LABEL_1118
    .dw LABEL_112A

LABEL_10A8:
    ld      a, ($4DAE)
    rst     $20
    ; jump table
    .dw QuickRet
    .dw LABEL_115C
    .dw LABEL_116E
    .dw LABEL_118F

LABEL_10B4:
    ld      a, ($4DAF)
    rst     $20
    ; jump table
    .dw QuickRet
    .dw LABEL_11C9
    .dw LABEL_11DB
    .dw LABEL_11FC

LABEL_10C0:
    call    LABEL_1BD8

    ld      hl, ($4D00)
    ld      de, $8064
    and     a
    sbc     hl, de
    ret     nz

    ld      hl, $4DAC
    inc     (hl)
    ret

LABEL_10D2:
    ld      ix, DATA_3301
    ld      iy, $4D00
    call    LABEL_2000
    ld      ($4D00), hl

    ld      a, 1
    ld      ($4D28), a
    ld      ($4D2C), a

    ld      a, ($4D00)
    cp      $80
    ret     nz

    ld      hl, $2E2F
    ld      ($4D0A), hl
    ld      ($4D31), hl
    xor     a
    ld      ($4DA0), a
    ld      ($4DAC), a
    ld      ($4DA7), a

LABEL_1101:
    ld      ix, $4DAC
    or      (ix + 0)
    or      (ix + 1)
    or      (ix + 2)
    or      (ix + 3)
    ret     nz

    ld      hl, $4EAC
    res     6, (hl)
    ret

LABEL_1118:
    call    LABEL_1CAF

    ld      hl, ($4D02)
    ld      de, $8064
    and     a
    sbc     hl, de
    ret     nz

    ld      hl, $4DAD
    inc     (hl)
    ret

LABEL_112A:
    ld      ix, DATA_3301
    ld      iy, $4D02
    call    LABEL_2000
    ld      ($4D02), hl

    ld      a, 1
    ld      ($4D29), a
    ld      ($4D2D), a

    ld      a, ($4D02)
    cp      $80
    ret     nz

    ld      hl, $2E2F
    ld      ($4D0C), hl
    ld      ($4D33), hl
    xor     a
    ld      ($4DA1), a
    ld      ($4DAD), a
    ld      ($4DA8), a
    jp      LABEL_1101

LABEL_115C:
    call    LABEL_1D86

    ld      hl, ($4D04)
    ld      de, $8064
    and     a
    sbc     hl, de
    ret     nz

    ld      hl, $4DAE
    inc     (hl)
    ret

LABEL_116E:
    ld      ix, DATA_3301
    ld      iy, $4D04
    call    LABEL_2000
    ld      ($4D04), hl

    ld      a, 1
    ld      ($4D2A), a
    ld      ($4D2E), a

    ld      a, ($4D04)
    cp      $80
    ret     nz

    ld      hl, $4DAE
    inc     (hl)
    ret

LABEL_118F:
    ld      ix, DATA_3303
    ld      iy, $4D04
    call    LABEL_2000
    ld      ($4D04), hl

    ld      a, 2
    ld      ($4D2A), a
    ld      ($4D2E), a

    ld      a, ($4D05)
    cp      $90
    ret     nz

    ld      hl, $302F
    ld      ($4D0E), hl
    ld      ($4D35), hl
    ld      a, 1
    ld      ($4D2A), a
    ld      ($4D2E), a
    xor     a
    ld      ($4DA2), a
    ld      ($4DAE), a
    ld      ($4DA9), a
    jp      LABEL_1101

LABEL_11C9:
    call    LABEL_1E5D

    ld      hl, ($4D06)
    ld      de, $8064
    and     a
    sbc     hl, de
    ret     nz

    ld      hl, $4DAF
    inc     (hl)
    ret

LABEL_11DB:
    ld      ix, DATA_3301
    ld      iy, $4D06
    call    LABEL_2000
    ld      ($4D06), hl

    ld      a, 1
    ld      ($4D2B), a
    ld      ($4D2F), a

    ld      a, ($4D06)
    cp      $80
    ret     nz

    ld      hl, $4DAF
    inc     (hl)
    ret

LABEL_11FC:
    ld      ix, DATA_32FF
    ld      iy, $4D06
    call    LABEL_2000
    ld      ($4D06), hl
    xor     a
    ld      ($4D2B), a
    ld      ($4D2F), a

    ld      a, ($4D07)
    cp      $70
    ret     nz

    ld      hl, $2C2F
    ld      ($4D10), hl
    ld      ($4D37), hl
    ld      a, 1
    ld      ($4D2B), a
    ld      ($4D2F), a
    xor     a
    ld      ($4DA3), a
    ld      ($4DAF), a
    ld      ($4DAA), a
    jp      LABEL_1101

LABEL_1235:
    ld      a, ($4DD1)
    rst     $20

    ; jump table
    .dw LABEL_123F  ; a ghost is being eaten
    .dw QuickRet
    .dw LABEL_123F  ; point score is set to vanish

LABEL_123F:
    ld      hl, $4C00
    ld      a, ($4DA4)
    add     a, a
    ld      e, a
    ld      d, 0
    add     hl, de

    ld      a, ($4DD1)
    and     a
    jr      nz, LABEL_1277

    ld      a, ($4DD0)
    ld      b, $27
    add     a, b
    ld      b, a

    ; load sprite and color data into (HL)
    ld      (hl), b
    inc     hl
    ld      (hl), $18

    ; make Pac-Man transparent
    ld      a, 0
    ld      ($4C0B), a

    ; insert task
    rst     $30
    .db $4A, $03, $00
    ; FALL THROUGH
LABEL_1272:
    ld      hl, $4DD1
    inc     (hl)
    ret

LABEL_1277:
    ; set ghost sprite to eyes only
    ld      (hl), $20

    ; make Pac-Man visible again
    ld      a, 9
    ld      ($4C0B), a

    ld      a, ($4DA4)
    ld      ($4DAB), a

    xor     a
    ld      ($4DA4), a
Patch0A:    ; Ms. Pac - Patch 10
    ld      ($4DD1), a

    ld      hl, $4EAC
    set     6, (hl)
    ret

LABEL_1291:
    ld      a, ($4DA5)
    rst     $20

    ; jump table
    .dw QuickRet 	; alive returns immediately
    .dw LABEL_12B7 	; increase counter
    .dw LABEL_12B7 	; increase counter
    .dw LABEL_12B7 	; increase counter
    .dw LABEL_12B7 	; increase counter
    .dw LABEL_12CB 	; animate dead pac
    .dw LABEL_12F9 	; animate dead pac + start dying sound
    .dw LABEL_1306 	; animate dead pac
    .dw LABEL_130E 	; animate dead pac
    .dw LABEL_1316 	; animate dead pac
    .dw LABEL_131E 	; animate dead pac
    .dw LABEL_1326 	; animate dead pac
    .dw LABEL_132E 	; animate dead pac
    .dw LABEL_1336 	; animate dead pac
    .dw LABEL_133E 	; animate dead pac
    .dw LABEL_1346 	; animate dead pac + clear sound
    .dw LABEL_1353 	; animate last time, decrease lives, clear ghosts, increase game state

LABEL_12B7:
    ld      hl, ($4DC5)
    inc     hl
    ld      ($4DC5), hl
    ld      de, $0078
    and     a
    sbc     hl, de
    ret     nz

    ld      a, 5
    ld      ($4DA5), a
    ret

; Set Pac-Man death animation
LABEL_12CB:
    ld      hl, 0
    call    LABEL_267E
    ld      a, $34
    ld      de, $00B4

LABEL_12D6:
    ld      ($4C0A), a

    ld      hl, ($4DC5)
    inc     hl
    ld      ($4DC5), hl
    and     a
    sbc     hl, de
    ret     nz

    ld      hl, $4DA5
    inc     (hl)
    ret

LABEL_12F9:
    ld      hl, $4EBC
    set     4, (hl)
    ld      a, $35
    ld      de, $00C3
    jp      LABEL_12D6

LABEL_1306:
    ld      a, $36
    ld      de, $00D2
    jp      LABEL_12D6

LABEL_130E:
    ld      a, $37
    ld      de, $00E1
    jp      LABEL_12D6

LABEL_1316:
    ld      a, $38
    ld      de, $00F0
    jp      LABEL_12D6

LABEL_131E:
    ld      a, $39
    ld      de, $00FF
    jp      LABEL_12D6

LABEL_1326:
    ld      a, $3A
    ld      de, $010E
    jp      LABEL_12D6

LABEL_132E:
    ld      a, $3B
    ld      de, $011D
    jp      LABEL_12D6

LABEL_1336:
    ld      a, $3C
    ld      de, $012C
    jp      LABEL_12D6

LABEL_133E:
    ld      a, $3D
    ld      de, $013B
    jp      LABEL_12D6

LABEL_1346:
Patch0B = $+2   ; Ms. Pac - Patch 11
    ld      hl, $4EBC
    ld      (hl), $20

    ld      a, $3E
    ld      de, $0159
    jp      LABEL_12D6

LABEL_1353:
    ld      a, $3F
    ld      ($4C0A), a

    ld      hl, ($4DC5)
    inc     hl
    ld      ($4DC5), hl
    ld      de, $01B8
    and     a
    sbc     hl, de
    ret     nz

    ; decrement lives
    ld      hl, $4E14
    dec     (hl)
    ld      hl, $4E15
    dec     (hl)
    call    LABEL_2675

    ld      hl, $4E04
    inc     (hl)
    ret

; controls scaBlinky timers
LABEL_1376:
    ld      a, ($4DA6)
    and     a
    ret     z

    ld      ix, $4DA7
    ld      a, (ix)
    or      (ix + 1)
    or      (ix + 2)
    or      (ix + 3)
    jp      z, LABEL_1398

    ld      hl, ($4DCB)
    dec     hl
    ld      ($4DCB), hl
    ld      a, h
    or      l
    ret     nz
    ; FALL THROUGH

; power pellet ran out, go back to normal
LABEL_1398:
    ; set Pac-Man's color palette to normal
    ld      hl, $4C0B
    ld      (hl), 9

    ; handle Blinky's state
    ld      a, ($4DAC)
    and     a
    ; don't reset if Blinky's been eaten
    jp      nz, +_
    ld      ($4DA7), a

_:  ; handle Pinky's state
    ld      a, ($4DAD)
    and     a
    ; don't reset if Pinky's been eaten
    jp      nz, +_
    ld      ($4DA8), a

    ; handle Inky's state
_:  ld      a, ($4DAE)
    and     a
    ; don't reset if Inky's been eaten
    jp      nz, +_
    ld      ($4DA9), a

_:  ; handle Clyde's state
    ld      a, ($4DAF)
    and     a
    ; don't reset if Clyde's been eaten
    jp      nz, +_
    ld      ($4DAA), a

    ; clear misc variables
_:  xor     a
    ld      ($4DCB), a
    ld      ($4DCC), a
    ld      ($4DA6), a
    ld      ($4DC8), a
    ld      ($4DD0), a

    ; clear sound bits
    ld      hl, $4EAC
    res     5, (hl)
    res     7, (hl)
    ret

LABEL_13DD:
    ld      hl, $4D9E
    ld      a, ($4E0E)
    cp      (hl)
    jp      z, +_

    ld      hl, 0
    ld      ($4D97), hl
    ret

_:  ld      hl, ($4D97)
    inc     hl
    ld      ($4D97), hl
    ld      de, ($4D95)
    and     a
    sbc     hl, de
    ret     nz

    ld      hl, 0
    ld      ($4D97), hl

    ; if Pinky's in the ghost house, bring her out and bail out
    ld      a, ($4DA1)
    and     a
    push    af
    call    z, LABEL_2086
    pop     af
    ret     z

    ; if Inky's in the ghost house, bring him out and bail out
    ld      a, ($4DA2)
    and     a
    push    af
    call    z, LABEL_20A9
    pop     af
    ret     z

    ; If Clyde's in the ghost house, bring him out
    ld      a, ($4DA3)
    and     a
    call    z, LABEL_20D1
    ret

; flip sprites for cocktail mode (2P)
LABEL_141F:
    ld      a, ($4E72)
    ld      b, a
    ld      a, ($4E09)
    and     b
    ret     z
    jp      LABEL_1499

; Also flips sprites in cocktail mode (1P)
LABEL_1490:
    ld      a, ($4E72)
    ld      b, a
    ld      a, ($4E09)
    and     b
    ret     nz

LABEL_1499:
    ld      b, a
    ld      e, 9
    ld      c, 7
    ld      d, 6
    ld      ix, $4C00

    ; flip Blinky's coords
    ld      a, ($4D00)
    cpl
    add     a, e
    ld      (ix + $13), a

    ld      a, ($4D01)
    add     a, d
    ld      (ix + $12), a

    ; flip Pinky's coords
    ld      a, ($4D02)
    cpl
    add     a, e
    ld      (ix + $15), a

    ld      a, ($4D03)
    add     a, d
    ld      (ix + $14), a

    ; flip Inky's coords
    ld      a, ($4D04)
    cpl
    add     a, e
    ld      (ix + $17), a

    ld      a, ($4D05)
    add     a, c
    ld      (ix + $16), a

    ; flip Clyde's coords
    ld      a, ($4D06)
    cpl
    add     a, e
    ld      (ix + $19), a

    ld      a, ($4D07)
    add     a, c
    ld      (ix + $18), a

    ; flip Pac-Man's coords
    ld      a, ($4D08)
    cpl
    add     a, e
    ld      (ix + $1B), a

    ld      a, ($4D09)
    add     a, c
    ld      (ix + $1A), a

    ; flip the fruit's coords
    ld      a, ($4DD2)
    cpl
    add     a, e
    ld      (ix + $1D), a

    ld      a, ($4DD3)
    add     a, c
    ld      (ix + $1C), a
    ; FALL THROUGH

LABEL_14FE:
    ; jump ahead if Pac-Man is dead
    ld      a, ($4DA5)
    and     a
    jp      nz, LABEL_151C

    ; jump ahead if a ghost is being eaten
    ld      a, ($4DA4)
    and     a
    jp      nz, LABEL_15B4

    ld      hl, LABEL_151C
    push    hl

    ld      a, ($4D30)
    rst     $20

    ; jump table
    .dw LABEL_168C	; right
    .dw LABEL_16B1	; down
    .dw LABEL_16D6	; left
    .dw LABEL_16F7	; up

; handles Pac-Man's sprite orientation
LABEL_151C:
    ld      hl, $4DC0
    ld      d, (hl)
    ld      a, $1C
    add     a, d

    ld      (ix + 2), a
    ld      (ix + 4), a
    ld      (ix + 6), a
    ld      (ix + 8), a

    ld      c, $20

    ; handle Blinky's sprite
    ld      a, ($4DAC)
    and     a
    jr      nz, +_

    ld      a, ($4DA7)
    and     a
    jr      nz, LABEL_1575

_:  ld      a, ($4D2C)
    add     a, a
    add     a, d
    add     a, c
    ld      (ix + 2), a

    ; handle Pinky's sprite
LABEL_1575:
    ld      a, ($4DAD)
    and     a
    jr      nz, +_

    ld      a, ($4DA8)
    and     a
    jr      nz, LABEL_158A

_:  ld      a, ($4D2D)
    add     a, a
    add     a, d
    add     a, c
    ld      (ix + 4), a

    ; handle Inky's sprite
LABEL_158A:
    ld      a, ($4DAE)
    and     a
    jr      nz, +_

    ld      a, ($4DA9)
    and     a
    jr      nz, LABEL_159F

_:  ld      a, ($4D2E)
    add     a, a
    add     a, d
    add     a, c
    ld      (ix + 6), a

    ; handle Clyde's sprite
LABEL_159F:
    ld      a, ($4DAF)
    and     a
    jr      nz, +_

    ld      a, ($4DAA)
    and     a
    jr      nz, LABEL_15B4

_:  ld      a, ($4D2F)
    add     a, a
    add     a, d
    add     a, c
    ld      (ix + 8), a

LABEL_15B4:
    call    LABEL_15E6
    call    LABEL_162D
    call    LABEL_1652
    ret

LABEL_15E6:
    ld      a, ($4E06)
    sub     5
    ret     c

    ld      a, ($4D09)
    and     $0F
    cp      $0C
    jr      c, +_

    ld      d, $18
    jr      LABEL_160B

_:  cp      $08
    jr      c, +_

    ld      d, $14
    jr      LABEL_160B

_:  cp      $04
    jr      c, +_

    ld      d, $10
    jr      LABEL_160B
_:  ld      d, $14

LABEL_160B:
    ld      (ix + 4), d
    inc     d
    ld      (ix + 6), d
    inc     d
    ld      (ix + 8), d
    inc     d
    ld      (ix + 12), d
    ld      (ix + 10), $3F

    ld      d, $16
    ld      (ix + 5), d
    ld      (ix + 7), d
    ld      (ix + 9), d
    ld      (ix + 13), d
    ret

LABEL_162D:
    ld      a, ($4E07)
    and     a
    ret     z

    ld      d, a
    ld      a, ($4D3A)
    sub     $3D
    jr      nz, +_

    ld      (ix + 11), 0

_:  ld      a, d
    cp      $0A
    ret     c

    ld      (ix + 2), $32
    ld      (ix + 3), $1D
    cp      $0C
    ret     c

    ld      (ix + 2), $33
    ret

LABEL_1652:
    ld      a, ($4E08)
    and     a
    ret     z

    ld      d, a
    ld      a, ($4D3A)
    sub     $3D
    jr      nz, +_

    ld      (ix + 11), 0

_:  ld      a, d
    cp      1
    ret     c

    ld      a, ($4DC0)
    ld      e, 8
    add     a, e
    ld      (ix + 2), a
    ld      a, d
    cp      3
    ret     c

    ld      a, ($4D01)
    and     $08
    rrca
    rrca
    rrca
    ld      e, $0A
    add     a, e
    ld      (ix + 12), a
    inc     a
    inc     a
    ld      (ix + 2), a
Patch0C = $+1   ; Ms. Pac - Patch 12
    ld      (ix + $0D), $1E
    ret

LABEL_168C:
    ld      a, ($4D09)
    and     $07
    cp      $06
    jr      c, +_

    ld      (ix + 10), $30
    ret

_:  cp      $04
    jr      c, +_

    ld      (ix + 10), $2E
    ret

_:  cp      $02
    jr      c, +_

    ld      (ix + 10), $2C
    ret

_:  ld      (ix + 10), $2E
Patch0D:    ; Ms. Pac - patch 13
    ret

LABEL_16B1:
    ld      a, ($4D08)
    and     $07
    cp      $06
    jr      c, +_

    ld      (ix + 10), $2F
    ret

_:  cp      $04
    jr      c, +_

    ld      (ix + 10), $2D
    ret

_:  cp      $02
    jr      c, +_

    ld      (ix + 10), $2F
    ret

_:  ld      (ix + 10), $30
    ret

LABEL_16D6:
Patch0E = $+2   ; Ms. Pac - Patch 14
    ld      a, ($4D09)
    and     $07
    cp      $06
    jr      c, +_

LABEL_16DF:
    ld      e, $2E
LABEL_16E1:
    set     7, e
    ld      (ix + 10), e
    ret

_:  cp      $04
    jr      c, +_

    ld      e, $2C
    jr      LABEL_16E1

_:  cp      $02
    jr      nc, LABEL_16DF
    
    ld      e, $30
    jr      LABEL_16E1

LABEL_16F7:
Patch0F = $+1   ; Ms. Pac - Patch 15
    ld      a, ($4D08) 
    and     $07
    cp      $06
    jr      c, +_

    ld      (ix + 10), $30
    ret

_:  cp      $04
    jr      c, +_

    ld      e, $2F
LABEL_170B:
    set     6, e
    ld      (ix + 10), e
    ret

_:  cp      $02
    jr      c, +_

    ld      e, $2D
    jr      LABEL_170B

_:  ld      e, $2F
    jr      LABEL_170B

LABEL_171D:
    ; B = # of ghosts that have collided wtih Pac-Man
    ld      b, 4
    
    ; check if Clyde hasn't been eaten
    ld      de, ($4D39)
    ld      a, ($4DAF)
    and     a
    jr      nz, +_

    ; check if Pac-Man collided with Clyde
    ld      hl, ($4D37)
    and     a
    sbc     hl, de
    jp      z, LABEL_1763

    ; Clyde didn't touch Pac-Man, dec B
_:  dec     b

    ; check if Inky hasn't been eaten
    ld      a, ($4DAE)
    and     a
    jr      nz, +_

    ; check if Pac-Man collided with Inky
    ld      hl, ($4D35)
    and     a
    sbc     hl, de
    jp      z, LABEL_1763

    ; Inky didn't touch Pac-Man, dec B
_:  dec     b

    ; check if Pinky hasn't been eaten
    ld      a, ($4DAD)
    and     a
    jr      nz, +_

    ; check if Pac-Man collided with Pinky
    ld      hl, ($4D33)
    and     a
    sbc     hl, de
    jp      z, LABEL_1763

    ; Piky didn't touch Pac-Man, dec B
_:  dec     b

    ; check if Blinky hasn't been eaten
    ld      a, ($4DAC)
    and     a
    jr      nz, +_

    ; check if Pac-Man collided with Blinky
    ld      hl, ($4D31)
    and     a
    sbc     hl, de
    jp      z, LABEL_1763
    
_:  dec     b

LABEL_1763:
    ; save # of ghost collisions
    ld      a, b
    ld      ($4DA4), a
    ld      ($4DA5), a
    and     a
    ret     z

    ld      hl, $4DA6
    ld      e, a
    ld      d, 0
    add     hl, de
    ld      a, (hl)
    and     a
    ret     z

    ; handle eating a ghost
    xor     a
    ld      ($4DA5), a

    ; update score
    ld      hl, $4DD0
    inc     (hl)
    ld      b, (hl)
    inc     b
    call    LABEL_2A5A

    ld      hl, $4EBC
    set     3, (hl)
    ret

; handle scaBlinky colliding with Pac-Man
LABEL_1789:
    ; bail out if Pac-Man already ate a ghost
    ld      a, ($4DA4)
    and     a
    ret     nz

    ; bail out if Pac-Man can't eat the ghosts
    ld      a, ($4DA6)
    and     a
    ret     z

    ; C = max distance that counts as collision
    ld      c, 4

    ; B = # of ghost collisions
    ld      b, 4

    ; IX = Pac-Man coords
    ld      ix, $4D08

    ; skip if Clyde hasn't been eaten
    ld      a, ($4DAF)
    and     a
    jr      nz, +_

    ; check if Clyde is touching Pac-Man
    ld      a, ($4D06)
    sub     (ix + 0)
    cp      c
    jr      nc, +_

    ld      a, ($4D07)
    sub     (ix + 1)
    cp      c
    jp      c, LABEL_1763

    ; no collision, dec B
_:  dec     b

    ; skip if Inky hasn't been eaten
    ld      a, ($4DAE)
    and     a
    jr      nz, +_

    ; check if Inky is touching Pac-Man
    ld      a, ($4D04)
    sub     (ix + 0)
    cp      c
    jr      nc, +_

    ld      a, ($4D05)
    sub     (ix + 1)
    cp      c
    jp      c, LABEL_1763

    ; no collision, dec B
_:  dec     b

    ; skip if Pinky hasn't been eaten
    ld      a, ($4DAD)
    and     a
    jr      nz, +_

    ; check if Inky is touching Pac-Man
    ld      a, ($4D02)
    sub     (ix + 0)
    cp      c
    jr      nc, +_

    ld      a, ($4D03)
    sub     (ix + 1)
    cp      c
    jp      c, LABEL_1763

    ; no collision, dec B
_:  dec     b

    ; skip if Blinky hasn't been eaten
    ld      a, ($4DAC)
    and     a
    jr      nz, +_

    ; check if Blinky is touching Pac-Man
    ld      a, ($4D00)
    sub     (ix + 0)
    cp      c
    jr      nc, +_

    ld      a, ($4D01)
    sub     (ix + 1)
    cp      c
    jp      c, LABEL_1763

_:  dec     b
    jp      LABEL_1763

; handles Pac-Man's speed
LABEL_1806:
    ld      hl, $4D9D
    call    CheckForFastHack
    ld      a, $FF

    cp      (hl)
    jp      z, +_

    dec     (hl)
    ret

_:  ld      a, ($4DA6)
    and     a
    jp      z, +_

    ; handle acceleation w/ power pill
    ld      hl, ($4D4C)
    add     hl, hl
    ld      ($4D4C), hl
    ld      hl, ($4D4A)
    adc     hl, hl
    ld      ($4D4A), hl
    ret     nc

    ld      hl, $4D4C
    inc     (hl)
    jp      LABEL_1843


_:  ; handle normal acceleration
    ld      hl, ($4D48)
    add     hl, hl
    ld      ($4D48), hl
    ld      hl, ($4D46)
    adc     hl, hl
    ld      ($4D46), hl
    ret     nc

    ld      hl, $4D48
    inc     (hl)
    ; FALL THROUGH

; handle Pac-Man movement
LABEL_1843:
    ld      a, ($4E0E)
    ld      ($4D9E), a

    ld      a, ($4E72)
    ld      c, a
    ld      a, ($4E09)
    and     c
    ld      c, a

    ld      hl, $4D3A
    ld      a, (hl)
    ld      b, $21
    sub     b
    jr      c, +_

    ld      a, (hl)
    ld      b, $3B
    sub     b
    jr      nc, +_
    jp      LABEL_18AB

    ; handle tunnel movement
_:  ld      a, 1
    ld      ($4DBF), a

    ld      a, ($4E00)
    cp      $01
    jp      z, LABEL_1A19

    ld      a, ($4E04)
    cp      $10
    jp      nc, LABEL_1A19

    ld      a, c
    and     a
    jr      z, +_

    ; load A with player 2 input
    ld      a, (IN1)
    jp      ++_

    ; load A with player 1 input
_:  ld      a, (IN0)
    ; skip if left isn't pressed
_:  bit     1, a
    jp      nz, +_

    ; move Pac-Man left
    ld      hl, (DATA_3303)
    ld      a, 2
    ld      ($4D30), a
    ld      ($4D1C), hl
    jp      LABEL_1950

_:  bit     2, a
    jp      nz, LABEL_1950

    ld      hl, (DATA_32FF)
    xor     a
    ld      ($4D30), a
    ld      ($4D1C), hl
    jp      LABEL_1950

LABEL_18AB:
    ld      a, ($4E00)
    cp      $01
    jp      z, LABEL_1A19

    ld      a, ($4E04)
    cp      $10
    jp      nc, LABEL_1A19

    ld      a, c
    and     a
    jr      z, +_

    ; load A with player 2 input
    ld      a, (IN1)
    jp      ++_

    ; load A with player 1 input
_:  ld      a, (IN0)

    ; jump based on the joystick direction
_:  bit     1, a    ; left
    jp      z, LABEL_1AC9

    bit     2, a    ; right
    jp      z, LABEL_1AD9

    bit     0, a    ; up
    jp      z, LABEL_1AE8

    bit     3, a    ; down
    jp      z, LABEL_1AF8

    ; handle no joystick input
    ld      hl, ($4D1C)
    ld      ($4D26), hl
    ld      b, 1
    ; FALL THROUGH

LABEL_18E4:
    ld      ix, $4D26
    ld      iy, $4D39
    call    LABEL_200F
    ; check if Pac-Man hit the maze
    and     $C0
    sub     $C0
    jr      nz, LABEL_1940

    dec     b
    jp      nz, LABEL_1916

    ld      a, ($4D30)
    rrca
    jp      c, +_

    ld      a, ($4D09)
    and     $07
    cp      $04
    ret     z
    jp      LABEL_1940

_:  ld      a, ($4D08)
    and     $07
    cp      $04
    ret     z
    jp      LABEL_1940

LABEL_1916:
    ld      ix, $4D1C
    call    LABEL_200F
    and     $C0
    sub     $C0
    jr      nz, LABEL_1950

    ld      a, ($4D30)
    rrca
    jp      c, +_

    ld      a, ($4D09)
    and     $07
    cp      $04
    ret     z
    jp      LABEL_1950

_:  ld      a, ($4D08)
    and     $07
    cp      $04
    ret     z
    jp      LABEL_1950

LABEL_1940:
    ld      hl, ($4D26)
    ld      ($4D1C), hl
    dec     b
    jp      z, LABEL_1950

    ld      a, ($4D3C)
    ld      ($4D30), a

LABEL_1950:
    ld      ix, $4D1C
    ld      iy, $4D08
    call    LABEL_2000
    ld      a, ($4D30)
    rrca
    jp      c, LABEL_1975

    ld      a, l
    and     $07
    cp      $04
    jp      z, LABEL_1985
    jp      c, +_

    dec     l
    jp      LABEL_1985

_:  inc     l
    jp      LABEL_1985

LABEL_1975:
    ld      a, h
    and     $07
    cp      $04
    jp      z, LABEL_1985
    jp      c, +_

    dec     h
    jp      LABEL_1985

_:  inc     h
LABEL_1985:
    ld      ($4D08), hl
    call    LABEL_2018
    ld      ($4D39), hl

    ld      ix, $4DBF
    ld      a, (ix)
    ld      (ix), 0
    and     a
    ret     nz

    ld      a, ($4DD2)
    and     a
    jr      z, LABEL_19CD

    ld      a, ($4DD4)
    and     a
    jr      z, LABEL_19CD

Patch10 = $+1   ; Ms. Pac - Patch 16
    ld      hl, ($4D08)
    ld      de, $8094
    and     a
    sbc     hl, de
    jr      nz, LABEL_19CD

; handle eating a fruit
LABEL_19B2:
    ld      b, $19
    ld      c, a
    call    LABEL_42
Patch11:        ; Ms. Pac - Patch 17
    ld      c, $15 
    add     a, c
    ld      c, a
    ld      b, $1C
    call    LABEL_42
    call    LABEL_1004
LABEL_19C4:
    ; insert task
    rst     $30
    .db $54, $05, $00

    ; play the fruit eating SFX
    ld      hl, $4EBC
    set     2, (hl)

LABEL_19CD:
    ld      a, $FF
    ld      ($4D9D), a

    ld      hl, ($4D39)
    call    LABEL_65
    ld      a, (hl)
    ; did Pac-Man touch a pac-dot?
    cp      $10
    jr      z, +_

    ; did Pac-Man touch a power pellet?
    cp      $14
    ret     nz

    ; handle Pac-Man eating a tile
_:  push    af
    ld      a, 1
    ld      (DrawTilemapFlag), a
    pop     af

    ld      ix, $4E0E
    inc     (ix)
    and     $0F
    ; bit 2 of A = what Pac-Man's eating
    srl     a

    ld      b, $40
    ld      (hl), b

    ld      b, $19
    ld      c, a
    srl     c
    call    LABEL_42

    inc     a
    cp      $01
    jp      z, +_

    add     a, a

_:  ld      ($4D9D), a
    call    LABEL_1B08
    call    LABEL_1A6A
    ld      hl, $4EBC
    ld      a, ($4E0E)
    rrca
    jr      c, +_

    set     0, (hl)
    res     1, (hl)
    ret

_:  res     0, (hl)
    set     1, (hl)
    ret

LABEL_1A19:
    ld      hl, $4D1C
    ld      a, (hl)
    and     a
    jp      z, +_

    ld      a, ($4D08)
    and     $07
    cp      $04
    jp      z, ++_
    jp      LABEL_1A5C

_:  ld      a, ($4D09)
    and     $07
    cp      $04
    jp      nz, LABEL_1A5C

_:  ld      a, $05
    call    LABEL_1ED0
    jr      c, +_

    ; insert task
    rst     $28
    .db     $17, $00

_:  ld      ix, $4D26
    ld      iy, $4D12
    call    LABEL_2000
    ld      ($4D12), hl
    ld      hl, ($4D26)
    ld      ($4D1C), hl
    ld      a, ($4D3C)
    ld      ($4D30), a

LABEL_1A5C:
    ld      ix, $4D1C
    ld      iy, $4D08
    call    LABEL_2000
    jp      LABEL_1985

LABEL_1A6A:
    ; bail out if Pac-Man didn't eat a power-pellet
    ld      a, ($4D9D)
    cp      $06
    ret     nz

; handle eating a power pellet
LABEL_1A70:
    ld      hl, ($4DBD)
    ld      ($4DCB), hl

    ld      a, 1
    ld      ($4DA6), a
    ld      ($4DA7), a
    ld      ($4DA8), a
    ld      ($4DA9), a
    ld      ($4DAA), a
    ld      ($4DB1), a
    ld      ($4DB2), a
    ld      ($4DB3), a
    ld      ($4DB4), a
    ld      ($4DB5), a

    xor     a
    ld      ($4DC8), a
    ld      ($4DD0), a

    ld      ix, $4C00

    ; set ghost sprites to the scared one
    ld      (ix + 2), $1C
    ld      (ix + 4), $1C
    ld      (ix + 6), $1C
    ld      (ix + 8), $1C

    ; set ghost palettes to blue
    ld      (ix + 3), $11
    ld      (ix + 5), $11
    ld      (ix + 7), $11
    ld      (ix + 9), $11

    ; play scaBlinky SFX
    ld      hl, $4EAC
    set     5, (hl)
    res     7, (hl)
    ret

; move player left
LABEL_1AC9:
    ld      hl, (DATA_3303)
    ld      a, 2
    ld      ($4D3C), a
    ld      ($4D26), hl
    ld      b, 0
    jp      LABEL_18E4

; move player right
LABEL_1AD9:
    ld      hl, (DATA_32FF)
    xor     a
    ld      ($4D3C), a
    ld      ($4D26), hl
    ld      b, 0
    jp      LABEL_18E4

; move player up
LABEL_1AE8:
    ld      hl, (DATA_3305)
    ld      a, 3
    ld      ($4D3C), a
    ld      ($4D26), hl
    ld      b, 0
    jp      LABEL_18E4

; move player down
LABEL_1AF8:
    ld      hl, (DATA_3301)
    ld      a, 1
    ld      ($4D3C), a
    ld      ($4D26), hl
    ld      b, 0
    jp      LABEL_18E4

LABEL_1B08:
    ld      a, ($4E12)
    and     a
    jp      z, +_

    ld      hl, $4D9F
    inc     (hl)
    ret

_:  ld      a, ($4DA3)
    and     a
    ret     nz

    ld      a, ($4DA2)
    and     a
    jp      z, +_

    ld      hl, $4E11
    inc     (hl)
    ret

_:  ld      a, ($4DA1)
    and     a
    jp      z, +_

    ld      hl, $4E10
    inc     (hl)
    ret

_:  ld      hl, $4E0F
    inc     (hl)
    ret

LABEL_1B36:
    ; bail out if Blinky's in the ghost house
    ld      a, ($4DA0)
    and     a
    ret     z

    ; bail out if Blinky's been eaten
    ld      a, ($4DAC)
    and     a
    ret     nz

    call    LABEL_20D7

    ; check if Blinky is in a tunnel
    ld      hl, ($4D31)
    ld      bc, $4D99
    call    LABEL_205A
    ld      a, ($4D99)
    and     a
    jp      z, LABEL_1B6A

    ; handle Blinky's tunnel movement
    ld      hl, ($4D60)
    add     hl, hl
    ld      ($4D60), hl

    ld      hl, ($4D5E)
    adc     hl, hl
    ld      ($4D5E), hl
    ret     nc

    ld      hl, $4D60
    inc     (hl)
    jp      LABEL_1BD8

; handle vulnerable Blinky movement
LABEL_1B6A:
    ; skip ahead if Blinky's not vulnerable
    ld      a, ($4DA7)
    and     a
    jp      z, LABEL_1B88

    ld      hl, ($4D5C)
    add     hl, hl
    ld      ($4D5C), hl

    ld      hl, ($4D5A)
    adc     hl, hl
    ld      ($4D5A), hl
    ret     nc

    ; skip ahead
    ld      hl, $4D5C
    inc     (hl)
    jp      LABEL_1BD8

; handle cruise elroy 2 movement
LABEL_1B88:
    ld      a, ($4DB7)
    and     a
    jp      z, LABEL_1BA6

    ld      hl, ($4D50)
    add     hl, hl
    ld      ($4D50), hl

    ld      hl, ($4D4E)
    adc     hl, hl
    ld      ($4D4E), hl
    ret     nc

    ld      hl, $4D50
    inc     (hl)
    jp      LABEL_1BD8

; handle cruise elroy movement
LABEL_1BA6:
    ld      a, ($4DB6)
    and     a
    jp      z, LABEL_1BC4

    ld      hl, ($4D54)
    add     hl, hl
    ld      ($4D54), hl

    ld      hl, ($4D52)
    adc     hl, hl
    ld      ($4D52), hl
    ret     nc

    ld      hl, $4D54
    inc     (hl)
    jp      LABEL_1BD8

; handle normal Blinky movement
LABEL_1BC4:
    ld      hl, ($4D58)
    add     hl, hl
    ld      ($4D58), hl

    ld      hl, ($4D56)
    adc     hl, hl
    ld      ($4D56), hl
    ret     nc

    ld      hl, $4D58
    inc     (hl)
    ; FALL THROUGH
LABEL_1BD8:
    ld      hl, $4D14
LABEL_1BDB:
    ld      a, (hl)
    and     a
    jp      z, +_

    ld      a, ($4D00)
    and     $07
    cp      $04
    jp      z, ++_
    jp      LABEL_1C36

_:  ld      a, ($4D01)
    and     $07
    cp      $04
    jp      nz, LABEL_1C36

_:  ld      a, $01
    call    LABEL_1ED0
    jr      c, LABEL_1C19

    ld      a, ($4DA7)
    and     a
    jp      z, +_

    ; insert task
    rst     $28
    .db     $0C, $00

    jp      LABEL_1C19

_:  ld      hl, ($4D0A)
    call    LABEL_2052
    ld      a, (hl)
    cp      $1A
    jr      z, LABEL_1C19

    ; insert task
    rst     $28
    .db     $08, $00

LABEL_1C19:
    call    LABEL_1EFE
    ld      ix, $4D1E
    ld      iy, $4D0A
    call    LABEL_2000
    ld      ($4D0A), hl

    ld      hl, ($4D1E)
    ld      ($4D14), hl

    ld      a, ($4D2C)
    ld      ($4D28), a

LABEL_1C36:
    ld      ix, $4D14
    ld      iy, $4D00
    call    LABEL_2000
    ld      ($4D00), hl
    call    LABEL_2018
    ld      ($4D31), hl
    ret

LABEL_1C4B:
    ; bail out if Pinky's in the ghost house
    ld      a, ($4DA1)
    cp      $01
    ret     nz

    ; bail out if Pinky's been eaten
    ld      a, ($4DAD)
    and     a
    ret     nz

    ; check if Pinky is in a tunnel
    ld      hl, ($4D33)
    ld      bc, $4D9A
    call    LABEL_205A
    ld      a, ($4D9A)
    and     a
    jp      z, LABEL_1C7D

    ; handle Pinky's tunnel movement
    ld      hl, ($4D6C)
    add     hl, hl
    ld      ($4D6C), hl

    ld      hl, ($4D6A)
    adc     hl, hl
    ld      ($4D6A), hl
    ret     nc

    ld      hl, $4D6C
    inc     (hl)
    jp      LABEL_1CAF

; handle vulnerable Pinky movement
LABEL_1C7D:
    ; skip ahead if Pinky's not vulnerable
    ld      a, ($4DA8)
    and     a
    jp      z, LABEL_1C9B

    ld      hl, ($4D68)
    add     hl, hl
    ld      ($4D68), hl

    ld      hl, ($4D66)
    adc     hl, hl
    ld      ($4D66), hl
    ret     nc

    ; skip ahead
    ld      hl, $4D68
    inc     (hl)
    jp      LABEL_1CAF

; handle normal Pinky movement
LABEL_1C9B:
    ld      hl, ($4D64)
    add     hl, hl
    ld      ($4D64), hl

    ld      hl, ($4D62)
    adc     hl, hl
    ld      ($4D62), hl
    ret     nc

    ld      hl, $4D64
    inc     (hl)
    ; FALL THROUGH
LABEL_1CAF:
    ld      hl, $4D16
    ld      a, (hl)
    and     a
    jp      z, +_

    ld      a, ($4D02)
    and     $07
    cp      $04
    jp      z, ++_
    jp      LABEL_1D0D

_:  ld      a, ($4D03)
    and     $07
    cp      $04
    jp      nz, LABEL_1D0D

_:  ld      a, $02
    call    LABEL_1ED0
    jr      c, LABEL_1CF0

    ld      a, ($4DA8)
    and     a
    jp      z, +_

    ; insert task
    rst     $28
    .db     $0D, $00
    jp      LABEL_1CF0

_:  ld      hl, ($4D0C)
    call    LABEL_2052
    ld      a, (hl)
    cp      $1A
    jr      z, LABEL_1CF0

    ; insert task
    rst     $28
    .db     $09, $00

LABEL_1CF0:
    call    LABEL_1F25
    ld      ix, $4D20
    ld      iy, $4D0C
    call    LABEL_2000
    ld      ($4D0C), hl

    ld      hl, ($4D20)
    ld      ($4D16), hl

    ld      a, ($4D2D)
    ld      ($4D29), a

LABEL_1D0D:
    ld      ix, $4D16
    ld      iy, $4D02
    call    LABEL_2000
    ld      ($4D02), hl
    call    LABEL_2018
    ld      ($4D33), hl
    ret

LABEL_1D22:
    ; bail out if Inky's in the ghost house
    ld      a, ($4DA2)
    cp      $01
    ret     nz

    ; bail out if Inky's been eaten
    ld      a, ($4DAE)
    and     a
    ret     nz

    ; check if Inky is in a tunnel
    ld      hl, ($4D35)
    ld      bc, $4D9B
    call    LABEL_205A
    ld      a, ($4D9B)
    and     a
    jp      z, LABEL_1D54

    ; handle Inky's tunnel movement
    ld      hl, ($4D78)
    add     hl, hl
    ld      ($4D78), hl

    ld      hl, ($4D76)
    adc     hl, hl
    ld      ($4D76), hl
    ret     nc

    ld      hl, $4D78
    inc     (hl)
    jp      LABEL_1D86

; handle vulnerable Inky movement
LABEL_1D54:
    ; skip ahead if Inky's not vulnerable
    ld      a, ($4DA9)
    and     a
    jp      z, LABEL_1D72

    ld      hl, ($4D74)
    add     hl, hl
    ld      ($4D74), hl

    ld      hl, ($4D72)
    adc     hl, hl
    ld      ($4D72), hl
    ret     nc

    ; skip ahead
    ld      hl, $4D74
    inc     (hl)
    jp      LABEL_1D86

; handle normal Inky movement
LABEL_1D72:
    ld      hl, ($4D70)
    add     hl, hl
    ld      ($4D70), hl

    ld      hl, ($4D6E)
    adc     hl, hl
    ld      ($4D6E), hl
    ret     nc

    ld      hl, $4D70
    inc     (hl)
    ; FALL THROUGH
LABEL_1D86:
    ld      hl, $4D18
    ld      a, (hl)
    and     a
    jp      z, +_

    ld      a, ($4D04)
    and     $07
    cp      $04
    jp      z, ++_
    jp      LABEL_1DE4

_:  ld      a, ($4D05)
    and     $07
    cp      $04
    jp      nz, LABEL_1DE4

_:  ld      a, $03
    call    LABEL_1ED0
    jr      c, LABEL_1DC7

    ld      a, ($4DA9)
    and     a
    jp      z, +_

    ; insert task
    rst     $28
    .db     $0E, $00
    jp      LABEL_1DC7

_:  ld      hl, ($4D0E)
    call    LABEL_2052
    ld      a, (hl)
    cp      $1A
    jr      z, LABEL_1DC7

    ; insert task
    rst     $28
    .db     $0A, $00

LABEL_1DC7:
    call    LABEL_1F4C
    ld      ix, $4D22
    ld      iy, $4D0E
    call    LABEL_2000
    ld      ($4D0E), hl

    ld      hl, ($4D22)
    ld      ($4D18), hl

    ld      a, ($4D2E)
    ld      ($4D2A), a

LABEL_1DE4:
    ld      ix, $4D18
    ld      iy, $4D04
    call    LABEL_2000
    ld      ($4D04), hl
    call    LABEL_2018
    ld      ($4D35), hl
    ret

LABEL_1DF9:
    ; bail out if Clyde's in the ghost house
    ld      a, ($4DA3)
    cp      $01
    ret     nz

    ; bail out if Clyde's been eaten
    ld      a, ($4DAF)
    and     a
    ret     nz

    ; check if Clyde is in a tunnel
    ld      hl, ($4D37)
    ld      bc, $4D9C
    call    LABEL_205A
    ld      a, ($4D9C)
    and     a
    jp      z, LABEL_1E2B

    ; handle Clyde's tunnel movement
    ld      hl, ($4D84)
    add     hl, hl
    ld      ($4D84), hl

    ld      hl, ($4D82)
    adc     hl, hl
    ld      ($4D82), hl
    ret     nc

    ld      hl, $4D84
    inc     (hl)
    jp      LABEL_1E5D

; handle vulnerable Clyde movement
LABEL_1E2B:
    ; skip ahead if Clyde's not vulnerable
    ld      a, ($4DAA)
    and     a
    jp      z, LABEL_1E49

    ld      hl, ($4D80)
    add     hl, hl
    ld      ($4D80), hl

    ld      hl, ($4D7E)
    adc     hl, hl
    ld      ($4D7E), hl
    ret     nc

    ; skip ahead
    ld      hl, $4D80
    inc     (hl)
    jp      LABEL_1E5D

; handle normal Clyde movement
LABEL_1E49:
    ld      hl, ($4D7C)
    add     hl, hl
    ld      ($4D7C), hl

    ld      hl, ($4D7A)
    adc     hl, hl
    ld      ($4D7A), hl
    ret     nc

    ld      hl, $4D7C
    inc     (hl)
    ; FALL THROUGH
LABEL_1E5D:
    ld      hl, $4D1A
    ld      a, (hl)
    and     a
    jp      z, +_

    ld      a, ($4D06)
    and     $07
    cp      $04
    jp      z, ++_
    jp      LABEL_1EBB

_:  ld      a, ($4D07)
    and     $07
    cp      $04
    jp      nz, LABEL_1EBB

_:  ld      a, $04
    call    LABEL_1ED0
    jr      c, LABEL_1E9E

    ld      a, ($4DAA)
    and     a
    jp      z, +_

    ; insert task
    rst     $28
    .db     $0F, $00
    jp      LABEL_1E9E

_:  ld      hl, ($4D10)
    call    LABEL_2052
    ld      a, (hl)
    cp      $1A
    jr      z, LABEL_1E9E

    ; insert task
    rst     $28
    .db     $0B, $00

LABEL_1E9E:
    call    LABEL_1F73
    ld      ix, $4D24
    ld      iy, $4D10
    call    LABEL_2000
    ld      ($4D10), hl

    ld      hl, ($4D24)
    ld      ($4D1A), hl

    ld      a, ($4D2F)
    ld      ($4D2B), a

LABEL_1EBB:
    ld      ix, $4D1A
    ld      iy, $4D06
    call    LABEL_2000
    ld      ($4D06), hl
    call    LABEL_2018
    ld      ($4D37), hl
    ret

LABEL_1ED0:
    add     a, a
    ld      c, a
    ld      b, 0
    ld      hl, $4D09
    add     hl, bc
    ld      a, (hl)
    cp      $1D
    jp      nz, +_

    ld      (hl), $3D
    jp      LABEL_1EFC

_:  cp      $3E
    jp      nz, +_

    ld      (hl), $1E
    jp      LABEL_1EFC

_:  ld      b, $21
    sub     b
    jp      c, LABEL_1EFC

    ld      a, (hl)
    ld      b, $3B
    sub     b
    jp      nc, LABEL_1EFC

    and     a
    ret

LABEL_1EFC:
    scf
    ret

LABEL_1EFE:
    ld      a, ($4DB1)
    and     a
    ret     z

    ; flip Blinky's direction
    xor     a
    ld      ($4DB1), a

    ld      hl, DATA_32FF
    ld      a, ($4D28)
    xor     %10
    ld      ($4D2C), a
    ld      b, a
    rst     $18
    ld      ($4D1E), hl

    ld      a, ($4E02)
    cp      $22
    ret     nz

    ld      ($4D14), hl
    ld      a, b
    ld      ($4D28), a
    ret

LABEL_1F25:
    ld      a, ($4DB2)
    and     a
    ret     z

    ; flip Pinky's direction
    xor     a
    ld      ($4DB2), a

LABEL_1F2E:
    ld      hl, DATA_32FF
    ld      a, ($4D29)
    xor     %10
    ld      ($4D2D), a
    ld      b, a
    rst     $18
    ld      ($4D20), hl

    ld      a, ($4E02)
    cp      $22
    ret     nz

    ld      ($4D16), hl
    ld      a, b
    ld      ($4D29), a
    ret

LABEL_1F4C:
    ld      a, ($4DB3)
    and     a
    ret     z

    ; flip Inky's direction
    xor     a
    ld      ($4DB3), a

LABEL_1F55:
    ld      hl, DATA_32FF
    ld      a, ($4D2A)
    xor     %10
    ld      ($4D2E), a
    ld      b, a
    rst     $18
    ld      ($4D22), hl

    ld      a, ($4E02)
    cp      $22
    ret     nz

    ld      ($4D18), hl
    ld      a, b
    ld      ($4D2A), a
    ret

LABEL_1F73:
    ld      a, ($4DB4)
    and     a
    ret     z

    ; flip Clyde's direction
    xor     a
    ld      ($4DB4), a

LABEL_1F7C:
    ld      hl, DATA_32FF
    ld      a, ($4D2B)
    xor     %10
    ld      ($4D2F), a
    ld      b, a
    rst     $18
    ld      ($4D24), hl

    ld      a, ($4E02)
    cp      $22
    ret     nz

    ld      ($4D1A), hl
    ld      a, b
    ld      ($4D2B), a
    ret

; ROM CHIP 3 (pacman.6h)

LABEL_2000:
    ld      a, (iy)
    add     a, (ix)
    ld      l, a
    ld      a, (iy + 1)
    add     a, (ix + 1)
    ld      h, a
    ret

LABEL_200F:
    call    LABEL_2000
    call    LABEL_65
    ld      a, (hl)
    and     a
    ret

LABEL_2018:
    ld      a, l
    srl     a
    srl     a
    srl     a
    add     a, $20
    ld      l, a
    ld      a, h
    srl     a
    srl     a
    srl     a
    add     a, $1E
    ld      h, a
    ret

LABEL_202D:
    push    af
    push    bc

    ld      a, l
    sub     $20
    ld      l, a

    ld      a, h
    sub     $20
    ld      h, a

    ld      b, 0
    sla     h
    sla     h
    sla     h
    sla     h
    rl      b
    sla     h
    rl      b
    ld      c, h
    ld      h, 0
    add     hl, bc
    ld      bc, $4040
    add     hl, bc
    pop     bc
    pop     af
    ret

LABEL_2052:
    call    LABEL_65
    ld      de, $0400
    add     hl, de
    ret

LABEL_205A:
    call    LABEL_2052
    ld      a, (hl)
    cp      $1B
Patch12:    ; Ms. Pac - Patch 18
    jr      nz, LABEL_2066

    ld      a, 1
    ld      (bc), a
    ret

LABEL_2066:
    xor     a
    ld      (bc), a
    ret

; release Pinky from the ghost house
LABEL_2069:
    ld      a, ($4DA1)
    and     a
    ret     nz

    ld      a, ($4E12)
    and     a
    jp      z, +_

    ld      a, ($4D9F)
    cp      $07
    ret     nz
    jp      LABEL_2086

_:  ld      hl, $4DB8
    ld      a, ($4E0F)
    cp      (hl)
    ret     c

LABEL_2086:
    ld      a, 2
    ld      ($4DA1), a
    ret

; release Inky from the ghost house
LABEL_208C:
    ld      a, ($4DA2)
    and     a
    ret     nz

    ld      a, ($4E12)
    and     a
    jp      z, +_

    ld      a, ($4D9F)
    cp      $11
    ret     nz
    jp      LABEL_20A9

_:  ld      hl, $4DB9
    ld      a, ($4E10)
    cp      (hl)
    ret     c

LABEL_20A9:
    ld      a, 3
    ld      ($4DA2), a
    ret

; release Clyde from the ghost house
LABEL_20AF:
    ld      a, ($4DA3)
    and     a
    ret     nz

    ld      a, ($4E12)
    and     a
    jp      z, +_

    ld      a, ($4D9F)
    cp      $20
    ret     nz

    xor     a
    ld      ($4E12), a
    ld      ($4D9F), a
    ret

_:  ld      hl, $4DBA
    ld      a, ($4E11)
    cp      (hl)
    ret     c

LABEL_20D1:
    ld      a, 3
    ld      ($4DA3), a
    ret

LABEL_20D7:
    ld      a, ($4DA3)
    and     a
    ret     z

    ld      hl, $4E0E
    ld      a, ($4DB6)
    and     a
    jp      nz, +_

    ld      a, $F4
    sub     (hl)
    ld      b, a
    ld      a, ($4DBB)
    sub     b
    ret     c

    ld      a, 1
    ld      ($4DB6), a

_:  ld      a, ($4DB7)
    and     a
    ret     nz

    ld      a, $F4
    sub     (hl)
    ld      b, a
    ld      a, ($4DBC)
    sub     b
    ret     c

    ld      a, 1
    ld      ($4DB7), a
    ret

; handle coffee break 1
LABEL_2108:
    ld      a, 1
    ld      (CoffeeBreakTrig), a
Patch13:    ; Ms. Pac - Patch 19
    ld      a, ($4E06)
    rst     $20

    ; jump table
    .dw LABEL_211A
    .dw LABEL_2140
    .dw LABEL_214B
    .dw QuickRet
    .dw LABEL_2170
    .dw LABEL_217B
    .dw LABEL_2186

LABEL_211A:
    ld      a, ($4D3A)
    sub     $21
    jr      nz, LABEL_2130

    inc     a
    ld      ($4DA0), a
    ld      ($4DB7), a
    call    LABEL_506
LABEL_212B:
    ld      hl, $4E06
    inc     (hl)
    ret
    
    ; tick the coffee break
LABEL_2130:
    call    LABEL_1806
    call    LABEL_1806
LABEL_2136:
    call    LABEL_1B36
    call    LABEL_1B36
    call    LABEL_E23
    ret

LABEL_2140:
    ld      a, ($4D3A)
    sub     $1E
    jp      nz, LABEL_2130
    jp      LABEL_212B

LABEL_214B:
    ld      a, ($4D32)
    sub     $1E
    jp      nz, LABEL_2136

    call    LABEL_1A70
    xor     a
    ld      ($4EAC), a
    ld      ($4EBC), a

    call    LABEL_5A5
    ld      ($4D1C), hl
    ld      a, ($4D3C)
    ld      ($4D30), a

    ; insert task
    rst     $30
    .db     $45, $07, $00

    jp      LABEL_212B

LABEL_2170:
    ld      a, ($4D32)
    sub     $2F
    jp      nz, LABEL_2136
    jp      LABEL_212B

LABEL_217B:
    ld      a, ($4D32)
    sub     $3D
    jp      nz, LABEL_2130
    jp      LABEL_212B

LABEL_2186:
    call    LABEL_1806
    call    LABEL_1806
    ld      a, ($4D3A)
    sub     $3D
    ret     nz

    ld      ($4E06), a

    ; insert task
LABEL_2195:
    rst     $30
    .db     $45, $00, $00

    ld      hl, $4E04
    inc     (hl)
    ret

; handle coffee break 2
LABEL_219E:
    ld      a, 1
    ld      (CoffeeBreakTrig), a

Patch14 = $+2    ; Ms. Pac - Patch 20
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ld      a, ($4E07)
    ld      iy, $41D2
    rst     $20

    ; jump table
    .dw LABEL_21C2
    .dw QuickRet
    .dw LABEL_21E1
    .dw LABEL_21F5
    .dw LABEL_220C
    .dw LABEL_221E
    .dw LABEL_2244
    .dw LABEL_225D
    .dw QuickRet
    .dw LABEL_226A
    .dw QuickRet
    .dw LABEL_2286
    .dw QuickRet
    .dw LABEL_228D

LABEL_21C2:
    ld      a, 1
    ld      ($45D2), a
    ld      ($45D3), a
    ld      ($45F2), a
    ld      ($45F3), a
    call    LABEL_506
    ld      (iy + 0), $60
    ld      (iy + 1), $61

    ; insert task
    rst     $30
    .db     $43, $08, $00

    jr      LABEL_21F0

LABEL_21E1:
    ld      a, ($4D3A)
    sub     $2C
    jp      nz, LABEL_2130

    inc     a
    ld      ($4DA0), a
    ld      ($4DB7), a
    ; FALL THROUGH
LABEL_21F0:
    ld      hl, $4E07
    inc     (hl)
    ret

LABEL_21F5:
    ld      a, ($4D01)
    cp      $77
    jr      z, +_

    cp      $78
    jp      nz, LABEL_2130

_:  ld      hl, $2084
    ld      ($4D4E), hl
    ld      ($4D50), hl
    jr      LABEL_21F0

LABEL_220C:
    ld      a, ($4D01)
    sub     $78
    jp      nz, LABEL_2237

    ld      (iy + 0), $62
    ld      (iy + 1), $63
    jr      LABEL_21F0

LABEL_221E:
    ld      a, ($4D01)
    sub     $7B
    jr      nz, LABEL_2237

    ld      (iy + $00), $64
    ld      (iy + $01), $65
    ld      (iy + $20), $66
    ld      (iy + $21), $67
    jr      LABEL_21F0

; tick the coffee break
LABEL_2237:
    call    LABEL_1806
    call    LABEL_1806
    call    LABEL_1B36
    call    LABEL_E23
    ret

LABEL_2244:
    ld      a, ($4D01)
    sub     $7E
    jr      nz, LABEL_2237

    ld      (iy + $00), $68
    ld      (iy + $01), $69
    ld      (iy + $20), $6A
    ld      (iy + $21), $6B
    jr      LABEL_21F0

LABEL_225D:
    ld      a, ($4D01)
    sub     $80
    jr      nz, LABEL_2237

    ; insert task
    rst     $30
    .db     $4F, $08, $00

    jr      LABEL_21F0

LABEL_226A:
    ld      hl, $4D01
    inc     (hl)
    inc     (hl)

    ld      (iy + $00), $6C
    ld      (iy + $01), $6D
    ld      (iy + $20), $40
    ld      (iy + $21), $40

    ; insert task
    rst     $30
    .db     $4A, $08, $00

    jp      LABEL_21F0

LABEL_2286:
    ; insert task
    rst     $30
    .db     $54, $08, $00

    jp      LABEL_21F0

LABEL_228D:
    xor     a
    ld      ($4E07), a

    ld      hl, $4E04
    inc     (hl)
    inc     (hl)
    ret

; handle coffee break 3
LABEL_2297:
    ld      a, 1
    ld      (CoffeeBreakTrig), a
Patch15 = $+1   ; Ms. Pac - Patch 21
    ld      a, ($4E08)
    rst     $20

    ; jump table
    .dw LABEL_22A7
    .dw LABEL_22BE
    .dw QuickRet
    .dw LABEL_22DD
    .dw LABEL_22F5
    .dw LABEL_22FE

LABEL_22A7:
    ld      a, ($4D3A)
    sub     $25
    jp      nz, LABEL_2130

    inc     a
    ld      ($4DA0), a
    ld      ($4DB7), a
    call    LABEL_506

LABEL_22B9:
    ld      hl, $4E08
    inc     (hl)
    ret

LABEL_22BE:
    ld      a, ($4D01)
    cp      $FF
    jr      z, +_

    cp      $FE
    jp      nz, LABEL_2130

_:  inc     a
    inc     a
    ld      ($4D01), a
    ld      a, 1
    ld      ($4DB1), a
    call    LABEL_1EFE

    ; insert task
    rst     $30
    .db     $4A, $09, $00

    jr      LABEL_22B9

LABEL_22DD:
    ld      a, ($4D32)
    sub     $2D
    jr      z, LABEL_22B9

LABEL_22E4:
    ld      a, ($4D00)
    ld      ($4DD2), a
    ld      a, ($4D01)
    sub     $08
    ld      ($4DD3), a
    jp      LABEL_2130

LABEL_22F5:
    ld      a, ($4D32)
    sub     $1E
    jr      z, LABEL_22B9
    jr      LABEL_22E4

LABEL_22FE:
    xor     a
    ld      ($4E08), a

    ; insert task
    rst     $30
    .db     $45, $00, $00

    ld      hl, $4E04
    inc     (hl)
    ret

; init hardware
LABEL_230B:
    ; clear framebuffer
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ; clear misc I/O regs
    ld      hl, $5000
    ld      b, 8

    xor     a
_:  ld      (hl), a
    inc     l
    djnz    -_

    ; clear tilemap tiles
    ld      hl, $4000
    ld      b, 4

_:  ld      ($5007), a

    ld      a, $40
_:  ld      (hl), a
    inc     l
    jr      nz, -_
    inc     h
    djnz    --_

    call    ClearTilemapCache

    ; clear tilemap palettes
    ld      b, 4

_:  xor     a
    ld      ($5007), a

    ld      a, $0F
_:  ld      (hl), a
    inc     l
    jr      nz, -_
    inc     h
    djnz    --_

    ; do an interrupt
    im      1
    ld      a, $FA
    call    SetIntVector

    xor     a
    ld      ($5007), a
    inc     a
    ld      ($5000), a
    ei 
    halt

; init game
LABEL_234B:
    ; set stack pointer
    ld      sp, $4FC0

    ; reset misc I/O regs
    xor     a
    ld      hl, $5000
    ld      bc, $0808
    rst     $08

    ; clear VRAM
    ld      hl, $4C00
    ld      b, $BE
    rst     $08
    rst     $08
    rst     $08
    rst     $08

    ; clear main I/O regs (sound, tilemap, etc.)
    ld      hl, $5040
    ld      b, $40
    rst     $08

    ; clear tilemap palettes
    call    LABEL_240D

    ; clear tilemap tiles
    ld      b, $00
    call    LABEL_23ED

    ; clear task list
    ld      hl, $4CC0
    ld      ($4C80), hl
    ld      ($4C82), hl

    ld      a, $FF
    ld      b, $40
    rst     $08

    ; enable interrupts
    ld      a, 1
    ld      ($5000), a
    ei
    ; FALL THROUGH

; process tasks forever
LABEL_238D:
    ld      hl, ($4C82)
    ld      a, (hl)
    and     a
    jp      m, LABEL_238D

    ld      (hl), $FF
    inc     l
    ld      b, (hl)
    ld      (hl), $FF
    inc     l
    jr      nz, +_

    ld      l, $C0

_:  ld      ($4C82), hl

    ; jump based on current task to process
    ld      hl, LABEL_238D
    push    hl
    rst     $20

    ; jump table
    .dw LABEL_23ED     ; A=00 - clears the whole screen if parameter == 0, just the maze if parameter == 1
    .dw LABEL_24D7     ; A=01 - colors the maze depending on parameter. if parameter == 2, then color maze white
    .dw LABEL_2419     ; A=02 - draws the maze
    .dw LABEL_2448     ; A=03 - draws the pellets
    .dw LABEL_253D     ; A=04 - resets a bunch of memories based on parameter 0 or 1
    .dw LABEL_268B     ; A=05 - resets ghost home counter and if parameter = 1, sets Blinky to chase pac man
    .dw LABEL_240D     ; A=06 - clears the color RAM
    .dw LABEL_2698     ; A=07 - set game to demo mode
    .dw LABEL_2730     ; A=08 - Blinky AI
    .dw LABEL_276C     ; A=09 - pinky AI
    .dw LABEL_27A9     ; A=0A - blue ghost (inky) AI	
    .dw LABEL_27F1     ; A=0B - Clyde AI	
    .dw LABEL_283B     ; A=0C - Blinky movement when power pill active
    .dw LABEL_2865     ; A=0D - pinky movement when power pill active
    .dw LABEL_288F     ; A=0E - blue ghost (inky) movement when power pill active
    .dw LABEL_28B9     ; A=0F - Clyde movement when power pill active
    .dw SetDifficulty  ; A=10 - sets up difficulty
    .dw LABEL_26A2     ; A=11 - clears memories from #4D00 through #4DFF
    .dw LABEL_24C9     ; A=12 - sets up coded pills and power pills memories
    .dw LABEL_2A35     ; A=13 - clears the sprites
    .dw LABEL_26D0     ; A=14 - checks all dip switches and assigns memories to the settings indicated
    .dw LABEL_2487     ; A=15 - update the current screen pill config to video ram
    .dw LABEL_23E8     ; A=16 - increase main subroutine number (#4E04)
    .dw LABEL_28E3     ; A=17 - controls pac-man AI during demo.  pacman will avoid pinky, or chase it when Blinky is edible
    .dw LABEL_2AE0     ; A=18 - draws "high score" and scores.  clears player 1 and 2 scores to zero.
    .dw LABEL_2A5A     ; A=19 - update score.  B has code for items scored, draw score on screen, check for high score and extra lives
    .dw LABEL_2B6A     ; A=1A - draws remaining lives at bottom of screen
    .dw LABEL_2BEA     ; A=1B - draws fruit at bottom right of screen
Patch16:               ; Ms. Pac - Patch 22
    .dw LABEL_2C5E     ; A=1C - used to draw text and some other functions  ; parameter lookup for text found at #36a5
    .dw LABEL_2BA1     ; A=1D - write # of credits on screen
    .dw LABEL_2675     ; A=1E - clear fruit, pacman, and all ghosts
    .dw LABEL_26B2     ; A=1F - writes points needed for extra life digits to screen

LABEL_23E8:
    ld      hl, $4E04
    inc     (hl)
    ret

; Task 0 - refresh the screen
LABEL_23ED:
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ld      a, b
    rst     $20

    ; jump table
    .dw LABEL_23F3		; clears entire screen
    .dw LABEL_2400		; clears the maze

; clear the entire tilemap
LABEL_23F3:
    ; A = blank tile
    ld      a, $40
    ld      bc, $0004
    ld      hl, $4000
_:  rst     $08
    dec     c
    jr      nz, -_

    call    ClearTilemapCache
    ret

; clear the maze
LABEL_2400:
    ld      a, $40
    ld      hl, $4040
    ld      bc, $8004
_:  rst     $08
    dec     c
    jr      nz, -_

    call    ClearTilemapCache
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

; Task 6 - clear tilemap palettes
LABEL_240D:
    xor     a
    ld      bc, $0004
    ld      hl, $4400
_:  rst     $08
    dec     c
    jr      nz, -_
Patch17:    ; Ms. Pac - Patch 23
    ret

; Task 2 - draw a maze
LABEL_2419: 
    ld      hl, $4000
    ld      bc, DATA_3435
LABEL_241F:
    ld      a, (bc)
    and     a
    jp      z, FinishMazeDraw
    jp      m, +_

    ; handle offset
    ld      e, a
    ld      d, 0
    add     hl, de
    dec     hl
    inc     bc
    ld      a, (bc)

_:  inc     hl
    ld      (hl), a

    push    af
    push    hl
    ld      de, $83E0

    ld      a, l
    and     $1F
    add     a, a

    ld      h, 0
    ld      l, a
    add     hl, de
    pop     de

    and     a
    sbc     hl, de
    pop     af

    xor     %00000001
    ld      (hl), a
    ex      de, hl
    inc     bc
    jp      LABEL_241F

FinishMazeDraw:
    xor     a
    ld      (CoffeeBreakTrig), a
    inc     a
    ld      (DrawTilemapFlag), a
    ret

; Task 3 - draw maze dots
LABEL_2448:
    ld      a, 1
    ld      (DrawTilemapFlag), a
Patch18:    ; Ms. Pac - Patch 24
    ld      hl, $4000
    ld      ix, $4E16
    ld      iy, DATA_35B5

LABEL_2453:
    ld      d, 0
    ld      b, $1E

DrawPills_Loop1:
    ld      c, $08
    ld      a, (ix)

DrawPills_Loop2:
    ld      e, (iy)
    add     hl, de
    rlca
    jr      nc, +_

    ld      (hl), $10

_:  inc     iy
    dec     c
    jr      nz, DrawPills_Loop2

    inc     ix
    dec     b
    jr      nz, DrawPills_Loop1

    ; draw power pellets
Patch19 = $+1    ; Ms. Pac - Patch 25
    ld      hl, $4E34
    ld      de, $4064
    ldi
    ld      de, $4078
    ldi
    ld      de, $4384
    ldi
    ld      de, $4398
    ldi
    ret

; Task 15 - update power pellets
LABEL_2487:
Patch1A = $+1   ; Ms. Pac - Patch 26
    ld      hl, $4000
    ld      ix, $4E16
    ld      iy, DATA_35B5

LABEL_2492:
    ld      d, 0
    ld      b, $1E

UpdatePills_Loop1:
    ld      c, $08

UpdatePills_Loop2:
    ld      e, (iy)
    add     hl, de
    
    ld      a, (hl)
    cp      $10
    scf
    jr      z, +_
    ccf
_:  rl      (ix)
    inc     iy
    dec     c
    jr      nz, UpdatePills_Loop2

    inc     ix
    dec     b
Patch1B = $+1   ; Ms. Pac - Patch 27
    jr      nz, UpdatePills_Loop1

    ld      hl, $4064
    ld      de, $4E34
    ldi
    ld      hl, $4078
    ldi
    ld      hl, $4384
    ldi
    ld      hl, $4398
    ldi
    ret

; task 12 - setup power pellets and dots
LABEL_24C9:
    ld      hl, $4E16

    ld      a, $FF
    ld      b, $1E
    rst     $08

    ld      a, $14
    ld      b, $04
    rst     $08
    ret

; task 1 - setup maze palette
LABEL_24D7:
Patch1C = $+1   ; Ms. Pac - Patch 28
    ld      e, b
    ld      a, b
    cp      $02
    ; if the screen is supposed to flash white, skip
    ; A = white maze palette
    ld      a, 31
    ld      hl, $6B7F
    jr      z, +_

    ; A = blue maze palette
    ld      a, 16
    ld      hl, $909F

    ; update LCD palette
_:  ld.lil  (mpLcdPalette + (16*4*2) + 6), hl
    ld.lil  (mpLcdPalette + (27*4*2) + 6), hl

LABEL_24E1:
    ld      hl, $4440
    ld      bc, $8004

_:  rst     $08
    dec     c
    jr      nz, -_

    ; A = HUD palette
    ld      a, 15

    ld      b, $40
    ; HL = score HUD
    ld      hl, $47C0
    rst     $08

    ld      a, e
    cp      $01
    ret     nz

Patch1D = $+1   ; Ms. Pac - Patch 29
    ld      a, 26
    ld      de, $0020

    ld      b, 6
    ld      ix, $45A0

_:  ld      (ix + $0C), a
    ld      (ix + $18), a
    add     ix, de
    djnz    -_

    ld      a, 27
    ld      b, 5
    ld      ix, $4440

_:  ld      (ix + $0E), a
    ld      (ix + $0F), a
    ld      (ix + $10), a
    add     ix, de
    djnz    -_

    ld      b, 5
    ld      ix, $4720

_:  ld      (ix + $0E), a
    ld      (ix + $0F), a
    ld      (ix + $10), a
    add     ix, de
    djnz    -_

LABEL_2534:
    ld      a, 24
    ld      ($45ED), a
    ld      ($460D), a
    ret

; task 4 - init sprites
LABEL_253D:
    ld      ix, $4C00

    ; init sprites
    ld      (ix + 2), $20
    ld      (ix + 4), $20
    ld      (ix + 6), $20
    ld      (ix + 8), $20
    ld      (ix + 10), $2C
    ld      (ix + 12), $3F

    ; init sprite palettes
    ld      (ix + 3), 1
    ld      (ix + 5), 3
    ld      (ix + 7), 5
    ld      (ix + 9), 7
    ld      (ix + 11), 9
    ld      (ix + 13), 0
    
    ld      a, b
    and     a
    jp      nz, LABEL_260F

    ld      hl, $8064
    ld      ($4D00), hl	; set Blinky position
    ld      hl, $807C
    ld      ($4D02), hl	; set pinky position
    ld      hl, $907C
    ld      ($4D04), hl	; set inky position
    ld      hl, $707C
    ld      ($4D06), hl	; set Clyde position
    ld      hl, $80C4
    ld      ($4D08), hl	; set ms pac position
    ld      hl, $2E2C
    ld      ($4D0A), hl	; set Blinky tile position
    ld      ($4D31), hl	; set Blinky tile position 2
    ld      hl, $2E2F
    ld      ($4D0C), hl	; set pinky tile position
    ld      ($4D33), hl	; set pinky tile position 2
    ld      hl, $302F
    ld      ($4D0e), hl	; set inky tile position
    ld      ($4D35), hl	; set inky tile position 2
    ld      hl, $2C2F
    ld      ($4D10), hl	; set Clyde tile position
    ld      ($4D37), hl	; set Clyde tile position 2
    ld      hl, $2E38
    ld      ($4D12), hl	; set pacman tile position
    ld      ($4D39), hl	; set pacman tile position 2
    ld      hl, $0100
    ld      ($4D14), hl	; set Blinky tile changes
    ld      ($4D1E), hl	; set Blinky tile changes 2
    ld      hl, $0001
    ld      ($4D16), hl	; set pinky tile changes
    ld      ($4D20), hl	; set pinky tile changes 2
    ld      hl, $00FF
    ld      ($4D18), hl	; set inky tile changes
    ld      ($4D22), hl	; set inky tile changes 2
    ld      hl, $00FF
    ld      ($4D1A), hl	; set Clyde tile changes
    ld      ($4D24), hl	; set Clyde tile changes 2
    ld      hl, $0100
    ld      ($4D1C), hl	; set pacman tile changes
    ld      ($4D26), hl	; set pacman tile changes 2
    ld      hl, $0102
    ld      ($4D28), hl	; set previous red and pinky orientation
    ld      ($4D2C), hl	; set red and pinky orientation
    ld      hl, $0303
    ld      ($4D2A), hl	; set previous blue and Clyde orientation
    ld      ($4D2E), hl	; set blue and Clyde orientation
    ld      a, $02
    ld      ($4D30), a	; set pacman orientation
    ld      ($4D3C), a	; set wanted pacman orientation
    ld      hl, $0000
    ld      ($4DD2), hl	; set fruit position
    ret     		    ; return

; setup intro sprites
LABEL_260F:
    ld      hl, $0094
    ld      ($4D00), hl
    ld      ($4D02), hl
    ld      ($4D04), hl
    ld      ($4D06), hl
    ld      hl, $1E32
    ld      ($4D0A), hl
    ld      ($4D0C), hl
    ld      ($4D0E), hl
    ld      ($4D10), hl
    ld      ($4D31), hl
    ld      ($4D33), hl
    ld      ($4D35), hl
    ld      ($4D37), hl
    ld      hl, $0100
    ld      ($4D14), hl
    ld      ($4D16), hl
    ld      ($4D18), hl
    ld      ($4D1A), hl
    ld      ($4D1E), hl
    ld      ($4D20), hl
    ld      ($4D22), hl
    ld      ($4D24), hl
    ld      ($4D1C), hl
    ld      ($4D26), hl
    ld      hl, $4D28
    ld      a, $02
    ld      b, $09
    rst     $08
    ld      ($4D3C), a
    ld      hl, $0894
    ld      ($4D08), hl
    ld      hl, $1F32
    ld      ($4D12), hl
    ld      ($4D39), hl
    ret

; task 1E - hide sprites
LABEL_2675:
    ld      hl, $0000
    ld      ($4DD2), hl
    ld      ($4D08), hl
LABEL_267E:
    ld      ($4D00), hl
    ld      ($4D02), hl
    ld      ($4D04), hl
    ld      ($4D06), hl
    ret

; task 5 - resets ghost house timer
LABEL_268B:
    ld      a, $55
    ld      ($4D94), a
    dec     b
    ret     z

    ld      a, 1
    ld      ($4DA0), a
    ret

; task 7 - setup demo
LABEL_2698:
    ld      a, 1
    ld      ($4E00), a
    xor     a
    ld      ($4E01), a
    ret

; task 11 - clear memory
LABEL_26A2:
    xor     a
    ld      de, $4D00

_:  ld      hl, $4E00
    ld      (de), a
    inc     de
    and     a
    sbc     hl, de
    jp      nz, -_
    ret

; task 1F - draw points needed for extra life
LABEL_26B2:
    ld      ix, $4136

    ; convert 1st digit to ASCII and draw
    ld      a, ($4E71)
    and     $0F
    add     a, $30
    ld      (ix), a

    ; convert 2nd digit to ASCII and draw
    ld      a, ($4E71)
    rrca
    rrca
    rrca
    rrca
    and     $0F
    ret     z

    add     a, $30
    ld      (ix + $20), a
    ret

; task 14 - check DIP switches
LABEL_26D0:
    ; check free play/credits settings
    ld      a, (DIPSwitch)
    ld      b, a

    ; if free play isn't set, skip ahead
    and     $03
    jp      nz, +_

    ; set free play trig
    ld      hl, $4E6E
    ld      (hl), $FF

_:  ld      c, a
    rra
    adc     a, 0
    ld      ($4E6B), a
    and     %10
    xor     c
    ld      ($4E6D), a

    ; check starting lives settings
    ld      a, b
    rrca
    rrca
    and     $03
    inc     a
    cp      $04
    jr      nz, +_
    inc     a
_:  ld      ($4E6F), a
    
    ; check extra live score settings
    ld      a, b
    rrca
    rrca
    rrca
    rrca
    and     $03
    ld      hl, DATA_2728
    rst     $10
    ld      ($4E71), a

    ; check which ghost names to show in the intro
    ld      a, b
    rlca
    cpl
    and     $01
    ld      ($4E75), a

    ; check the difficulty
    ld      a, b
    rlca
    rlca
    cpl
    and     $01
    ld      b, a
    ld      hl, DATA_272C
    rst     $18
    ld      ($4E73), hl

    ; check for cocktail trig
    ld      a, (IN1)
    rlca
    cpl
    and     $01
    ld      ($4E72), a
    ret

DATA_2728:      ; data for # of points needed for extra life
    .db $10     ; 10K points
    .db $15     ; 15K points
    .db $20     ; 20K points
    .db $FF     ; none

DATA_272C:
    .dw $0068
    .dw $007D

; Task 08 - handle Blinky AI
LABEL_2730:
    ld      a, ($4DC1)
    bit     0, a
    jp      nz, LABEL_2758

    ld      a, ($4DB6)
    and     a
    jr      nz, LABEL_2758

    ld      a, ($4E04)
    cp      $03
    jr      nz, LABEL_2758

    ; HL = ghost coords
    ld      hl, ($4D0A)
Patch1E:    ; Ms. Pac - Patch 30
    ; go to default target tile (upper-right corner)
    ; A = ghost direction
    ld      a, ($4D2C)
    ld      de, $221D
    call    LABEL_2966
    ld      ($4D1E), hl
    ld      ($4D2C), a
    ret

LABEL_2758:
    ; HL = ghost coords
    ld      hl, ($4D0A)
    ; DE = Pac-Man's coords
    ld      de, ($4D39)
    ; A = ghost direction
    ld      a, ($4D2C)
    ; move Blinky to the target tile (Pac-Man's coords)
    call    LABEL_2966
    ld      ($4D1E), hl
    ld      ($4D2C), a
    ret

; task 9 - handle Pinky AI
LABEL_276C:
    ld      a, ($4DC1)
    bit     0, a
    jp      nz, LABEL_278E

    ld      a, ($4E04)
    cp      $03
    jr      nz, LABEL_278E

    ld      hl, ($4D0C)
Patch1F = $+2    ; Ms. Pac - Patch 31
    ; go to default target tile (upper-left corner)
    ld      a, ($4D2D)
    ld      de, $391D
    call    LABEL_2966
    ld      ($4D20), hl
    ld      ($4D2D), a
    ret

LABEL_278E:
    ; DE = Pac-Man position
    ld      de, ($4D39)
    ; HL = Pac-Man direction
    ld      hl, ($4D1C)

    add     hl, hl
    add     hl, hl
    add     hl, de
    ex      de, hl
    ; DE = 4 tiles ahead of Pac-Man
    ld      hl, ($4D0C)
    ld      a, ($4D2D)
    call    LABEL_2966
    ld      ($4D20), hl
    ld      ($4D2D), a
    ret

; task 0A - handle Inky AI
LABEL_27A9:
    ld      a, ($4DC1)
    bit     0, a
    jp      nz, LABEL_27CB

    ld      a, ($4E04)
    cp      $03
    jr      nz, LABEL_27CB

Patch20:    ; Ms. Pac - Patch 32
    ; go to default target tile (lower-right corner)
    ld      hl, ($4D0E)
    ld      a, ($4D2E)
    ld      de, $2040
    call    LABEL_2966
    ld      ($4D22), hl
    ld      ($4D2E), a
    ret

LABEL_27CB:
    ; BC = Blinky's coords
    ld      bc, ($4D0A)
    ; DE = Pac-Man's coords
    ld      de, ($4D39)
    ; HL = Pac-Man's direction
    ld      hl, ($4D1C)

    add     hl, hl
    add     hl, de
    ld      a, l
    add     a, a
    sub     c
    ld      l, a
    ld      a, h
    add     a, a
    sub     b
    ld      h, a
    ex      de, hl
    ; DE = tile between Pac-Man and Blinky

    ld      hl, ($4D0E)
    ld      a, ($4D2E)
    call    LABEL_2966
    ld      ($4D22), hl
    ld      ($4D2E), a
    ret

; task 0B - handle Clyde AI
LABEL_27F1:
    ld      a, ($4DC1)
    bit     0, a
    jp      nz, LABEL_2813

    ld      a, ($4E04)
    cp      $03
    jr      nz, LABEL_2813

LABEL_2800:
Patch21:    ; Ms. Pac - Patch 33
    ; go to default tile coords (lower-left corner)
    ld      hl, ($4D10)
    ld      a, ($4D2F)
    ld      de, $3B40
    call    LABEL_2966
    ld      ($4D24), hl
    ld      ($4D2F), a
    ret

LABEL_2813:
    ld      ix, $4D39
    ld      iy, $4D10
    call    LABEL_29EA

    ; if Blinky's too close to Pac-Man, target the lower-left corner
    ld      de, $0040
    and     a
    sbc     hl, de
    jp      c, LABEL_2800

    ; otherwise, target Pac-Man like Blinky
    ld      hl, ($4D10)
    ld      de, ($4D39)
    ld      a, ($4D2F)
    call    LABEL_2966
    ld      ($4D24), hl
    ld      ($4D2F), a
    ret

; task 0C - handle vurnerable Blinky AI
LABEL_283B:
    ; skip if Blinky's been re-alived
    ld      a, ($4DAC)
    and     a
    jp      z, +_

    ; move Blinky to the ghost house
    ld      de, $2E2C
    ld      hl, ($4D0A)
    ld      a, ($4D2C)
    call    LABEL_2966
    ld      ($4D1E), hl
    ld      ($4D2C), a
    ret

    ; move Blinky randomly
_:  ld      hl, ($4D0A)
    ld      a, ($4D2C)
    call    LABEL_291E
    ld      ($4D1E), hl
    ld      ($4D2C), a
    ret

; task 0D - handle vurnerable Pinky AI
LABEL_2865:
    ; skip if Pinky's been re-alived
    ld      a, ($4DAD)
    and     a
    jp      z, +_

    ; move Pinky to the ghost house
    ld      de, $2E2C
    ld      hl, ($4D0C)
    ld      a, ($4D2D)
    call    LABEL_2966
    ld      ($4D20), hl
    ld      ($4D2D), a
    ret

    ; move Pinky randomly
_:  ld      hl, ($4D0C)
    ld      a, ($4D2D)
    call    LABEL_291E
    ld      ($4D20), hl
    ld      ($4D2D), a
    ret

; task 0E - handle vurnerable Inky AI
LABEL_288F:
    ; skip if Inky's been re-alived
    ld      a, ($4DAE)
    and     a
    jp      z, +_

    ; move Inky to the ghost house
    ld      de, $2E2C
    ld      hl, ($4D0E)
    ld      a, ($4D2E)
    call    LABEL_2966
    ld      ($4D22), hl
    ld      ($4D2E), a
    ret

    ; move Inky randomly
_:  ld      hl, ($4D0E)
    ld      a, ($4D2E)
    call    LABEL_291E
    ld      ($4D22), hl
    ld      ($4D2E), a
    ret

; task 0F - handle vurnerable Clyde AI
LABEL_28B9:
    ; skip if Clyde's been re-alived
    ld      a, ($4DAF)
    and     a
    jp      z, +_

    ; move Clyde to the ghost house
    ld      de, $2E2C
    ld      hl, ($4D10)
    ld      a, ($4D2F)
    call    LABEL_2966
    ld      ($4D24), hl
    ld      ($4D2F), a
    ret

    ; move Clyde randomly
_:  ld      hl, ($4D10)
    ld      a, ($4D2F)
    call    LABEL_291E
    ld      ($4D24), hl
    ld      ($4D2F), a
    ret

; task 17 - handle demo Pac-Man AI
LABEL_28E3:
    ld      a, ($4DA7)
    and     a
    jp      z, LABEL_28FE

    ; if Blinky's vulnerable, chase after Pinky
    ld      hl, ($4D12)
    ld      de, ($4D0C)
    ld      a, ($4D3C)
    call    LABEL_2966
    ld      ($4D26), hl
    ld      ($4D3C), a
    ret

; make Pac-Man avoid Pinky
LABEL_28FE:
    ld      hl, ($4D39)
    ld      bc, ($4D0C)

    ld      a, l
    add     a, a
    sub     c
    ld      l, a

    ld      a, h
    add     a, a
    sub     b
    ld      h, a
    ex      de, hl
    ; DE = distance between Pac-Man and Pinky

    ld      hl, ($4D12)
    ld      a, ($4D3C)
    call    LABEL_2966
    ld      ($4D26), hl
    ld      ($4D3C), a
    ret

; change edible ghost direction
LABEL_291E:
    ; IN: HL = ghost coords, A = ghost direction
    ld      ($4D3E), hl
    xor     %10
    ld      ($4D3D), a

    call    LABEL_2A23
    and     $03
    ld      hl, $4D3B
    ld      (hl), a

    add     a, a
    ld      e, a
    ld      d, 0
    ld      ix, DATA_32FF
    add     ix, de
    ld      iy, $4D3E

LABEL_293D:
    ld      a, ($4D3D)
    cp      (hl)
    jp      z, LABEL_2957

    call    LABEL_200F
    and     $C0
    sub     $C0
    jr      z, LABEL_2957

    ; OUT: HL = new target tile, A = new direction
    ld      l, (ix + 0)
    ld      h, (ix + 1)
    ld      a, ($4D3B)
    ret

LABEL_2957:
    inc     ix
    inc     ix
    ld      hl, $4D3B
    ld      a, (hl)
    inc     a
    and     %11
    ld      (hl), a
    jp      LABEL_293D

LABEL_2966:
    ; IN: HL = current tile
    ld      ($4D3E), hl
    ; IN: DE = destination tile
    ld      ($4D40), de
    ; IN: A = object direction
    ld      ($4D3B), a
    xor     %10
    ld      ($4D3D), a

    ld      hl, $FFFF
    ld      ($4D44), hl

    ld      ix, DATA_32FF
    ld      iy, $4D3E
    ld      hl, $4DC7
    ld      (hl), 0

LABEL_2988:
    ld      a, ($4D3D)
    cp      (hl)
    jp      z, LABEL_29C6

    call    LABEL_2000
    ld      ($4D42), hl
    call    LABEL_65

    ld      a, (hl)
    and     $C0
    sub     $C0
    jr      z, LABEL_29C6

    push    ix
    push    iy
    ld      ix, $4D40
    ld      iy, $4D42
    call    LABEL_29EA
    ; HL = (ix)^2 + (iy)^2
    pop     iy
    pop     ix
    ex      de, hl

    ld      hl, ($4D44)
    and     a
    sbc     hl, de
    jp      c, LABEL_29C6

    ld      ($4D44), de
    ld      a, ($4DC7)
    ld      ($4D3B), a

LABEL_29C6:
    inc     ix
    inc     ix

    ld      hl, $4DC7
    inc     (hl)
    ld      a, 4
    cp      (hl)
    jp      nz, LABEL_2988

    ld      a, ($4D3B)
    add     a, a
    ld      e, a
    ld      d, 0
    ld      ix, DATA_32FF
    add     ix, de
    ld      l, (ix + 0)
    ld      h, (ix + 1)
    srl     a
    ret

; use Pythagorean theorem to calculate the distance between Pac-Man and Blinky
LABEL_29EA:
    ld      a, (ix)
    ld      b, (iy)
    sub     b
    jp      nc, +_

    ld      a, b
    ld      b, (ix)
    sub     b

_:  call    LABEL_2A12

    push    hl
    ld      a, (ix + 1)
    ld      b, (iy + 1)
    sub     b
    jp      nc, +_

    ld      a, b
    ld      b, (ix + 1)
    sub     b

_:  call    LABEL_2A12

    pop     bc
    add     hl, bc
    ret

; HL = A^2
LABEL_2A12:
    ld      h, a
    ld      e, a
    ld      l, 0
    ld      d, l
    ld      c, 8

SquareA_Loop:
    add     hl, hl
    jp      nc, +_
    add     hl, de
_:  dec     c
    jp      nz, SquareA_Loop
    ret

LABEL_2A23:
    ld      hl, ($4DC9)
    ld      d, h
    ld      e, l
    add     hl, hl
    add     hl, hl
    add     hl, de
    inc     hl
    ld      a, h
    and     $1F
    ld      h, a
    ld      a, (hl)
    ld      ($4DC9), hl
    ret

; task 13 - clear tilemap
LABEL_2A35:
    ld      de, $4040
LABEL_2A38:
    ld      hl, $43C0
    and     a
    sbc     hl, de
    ret     z

    ld      a, (de)
    cp      $10
    jp      z, +_

    cp      $12
    jp      z, +_

    cp      $14
    jp      z, +_

    inc     de
    jp      LABEL_2A38

_:  ld      a, $40
    ld      (de), a
    inc     de
    jp      LABEL_2A38

; task 19 - update score
LABEL_2A5A:
    ld      a, ($4E00)
    cp      $01
    ret     z

    ld      hl, DATA_2B17
    rst     $18
    ex      de, hl
    call    LABEL_2B0B

    ; update first score byte
    ld      a, e
    add     a, (hl)
    daa
    ld      (hl), a
    inc     hl

    ; update second score byte
    ld      a, d
    adc     a, (hl)
    daa
    ld      (hl), a
    ld      e, a
    inc     hl

    ; update third score byte
    ld      a, 0
    adc     a, (hl)
    daa
    ld      (hl), a

    ld      d, a
    ex      de, hl
    ; HL = DE*16
    add     hl, hl
    add     hl, hl
    add     hl, hl
    add     hl, hl

    ld      a, ($4E71)
    dec     a
    cp      h
    call    c, LABEL_2B33
    call    LABEL_2AAF

    inc     de
    inc     de
    inc     de

    ; check if we need to update the high score
    ld      hl, $4E8A
    ld      b, 3

_:  ld      a, (de)
    cp      (hl)
    ret     c
    jr      nz, LABEL_2A9B

    dec     de
    dec     hl
    djnz    -_
    ret

; update high score
LABEL_2A9B:
    call    LABEL_2B0B
    ld      de, $4E88
    ld      bc, 3
    ldir

    dec     de
    ld      bc, $0304
    ld      hl, $43F2
    jr      LABEL_2ABE

; check which player's score to update
LABEL_2AAF:
    ld      a, ($4E09)
    ld      bc, $0304
    ld      hl, $43FC
    and     a
    jr      z, LABEL_2ABE
    ld      hl, $43E9
    ; FALL THROUGH

; draw a score
LABEL_2ABE:
    ; IN: DE = score ptr
    ld      a, (de)
    rrca
    rrca
    rrca
    rrca
    call    LABEL_2ACE
    ld      a, (de)
    call    LABEL_2ACE
    dec     de
    djnz    LABEL_2ABE
    ret

; draw a digit to the screen
LABEL_2ACE:
    and     %1111
    jr      z, +_

    ld      c, 0
    jr      LABEL_2ADD

_:  ld      a, c
    and     a
    jr      z, LABEL_2ADD

    ld      a, $40
    dec     c

LABEL_2ADD:
    ld      (hl), a
    dec     hl
    ret

; task 18 - draw scores
LABEL_2AE0:
    ld      b, 0
    call    LABEL_2C5E
    xor     a

    ; clear scores
    ld      hl, $4E80
    ld      b, 8
    rst     $08

    ; draw player 1 score
    ld      bc, $0304
    ld      de, $4E82
    ld      hl, $43FC
    call    LABEL_2ABE

    ; draw player 2 score
    ld      bc, $0304
    ld      de, $4E86
    ld      hl, $43E9

    ld      a, ($4E70)
    and     a
    jr      nz, LABEL_2ABE
    ld      c, $06
    jr      LABEL_2ABE

LABEL_2B0B:
    ld      a, ($4E09)
    ld      hl, $4E80
    and     a
    ret     z
    ld      hl, $4E84
    ret

; score table
DATA_2B17:
    .dw $0010   ; pac-dot
    .dw $0050   ; power pellet
    .dw $0200   ; 1st eaten ghost
    .dw $0400   ; 2nd eaten ghost
Patch22 = $+1   ; Ms. Pac - Patch 34
    .dw $0800   ; 3rd eaten ghost
    .dw $1600   ; 4th eaten ghost
    .dw $0100   ; cherry
    .dw $0300   ; strawberry
    .dw $0500   ; orange
    .dw $0700   ; apple
    .dw $1000   ; melon
    .dw $2000   ; galaxian
Patch23 = $+1   ; Ms. Pac - Patch 35
    .dw $3000   ; bell
    .dw $5000   ; key

; handle extra life
LABEL_2B33:
    inc     de
    ld      l, e
    ld      h, d
    dec     de
    bit     0, (hl)
    ret     nz

    set     0, (hl)
    ld      hl, $4E9C
    set     0, (hl)
    ld      hl, $4E14
    inc     (hl)
    ld      hl, $4E15
    inc     (hl)
    ld      b, (hl)

LABEL_2B4A:
    ld      hl, $401A
    ld      c, 5
    ld      a, b
    and     a
    jr      z, LABEL_2B61

    cp      6
    jr      nc, LABEL_2B61

_:  ld      a, $20
    ; draw extra life
    call    LABEL_2B8F
    dec     hl
    dec     hl
    dec     c
    djnz    -_

LABEL_2B61:
    dec     c
    ret     m

    call    LABEL_2B7E
    dec     hl
    dec     hl
    jr      LABEL_2B61

; draw remaining lives
LABEL_2B6A:
    ld      a, ($4E00)
    cp      $01
    ret     z

    call    LABEL_2BCD
    .dw $4412
    .db 9, 10, 2

    ld      hl, $4E15
    ld      b, (hl)
    jr      LABEL_2B4A

; update the palette of a 2x2 tile grid
LABEL_2B7E:
    ; fully transparent palette
    ld      a, $40
LABEL_2B80:
    push    hl
    push    de

    ld      (hl), a
    inc     hl
    ld      (hl), a

    ld      de, 31
    add     hl, de

    ld      (hl), a
    inc     hl
    ld      (hl), a

    pop     de
    pop     hl
    ret

; draw a 2x2 tile grid
LABEL_2B8F:
    push    hl
    push    de
    ld      de, 31

    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a

    add     hl, de

    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a

    pop     de
    pop     hl
    ret

; display # of coins
LABEL_2BA1:
    ld      a, ($4E6E)
    cp      $FF
    jr      nz, +_
    ; draw "FREE PLAY" only
    ld      b, 2
    jp      LABEL_2C5E

    ; draw "CREDIT"
_:  ld      b, 1
    call    LABEL_2C5E
    ld      a, ($4E6E)
    and     $F0
    ; skip if coin count < 10
    jr      z, +_

    ; draw 10s digit for credits
    rrca
    rrca
    rrca
    rrca
    add     a, $30
    ld      ($4034), a

_:  ld      a, ($4E6E)
    and     $0F
    add     a, $30
    ld      ($4033), a
    ret

; this works a bit like the RST routines.
; IN: (CALL + 1-2) = tilemap ptr
; IN: (CALL + 3) = byte to write
; IN: (CALL + 4) = loop 1 counter
; IN: (CALL + 5) = loop 2 counter

LABEL_2BCD:
    pop     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      a, (hl)
    inc     hl
    push    hl
    ex      de, hl
    ld      de, $0020

_:  push    hl
    push    bc

_:  ld      (hl), c
    inc     hl
    djnz    -_

    pop     bc
    pop     hl
    add     hl, de
    dec     a
    jr      nz, --_
    ret

LABEL_2BEA:
    ld      a, ($4E00)
    cp      1
    ret     z

Patch24:    ; Ms. Pac - Patch 36
    ld      a, ($4E13)
    inc     a
    cp      $08
    jp      nc, LABEL_2C2E

LABEL_2BF9:
    ld      de, DATA_3B08
    ld      b, a
LABEL_2BFD:
    ld      c, 7
    ld      hl, $4004

_:  ld      a, (de)
    call    LABEL_2B8F
    ld      a, 4
    add     a, h
    ld      h, a
    inc     de

    ld      a, (de)
    call    LABEL_2B80
    ld      a, -4
    add     a, h
    ld      h, a
    inc     de
    inc     hl
    inc     hl
    dec     c
    djnz    -_

LABEL_2C19:
    dec     c
    ret     m

    call    LABEL_2B7E
    ld      a, 4
    add     a, h
    ld      h, a
    xor     a

    call    LABEL_2B80
    ld      a, -4
    add     a, h
    ld      h, a
    inc     hl
    inc     hl
    jr      LABEL_2C19

LABEL_2C2E:
    cp      $13
    jr      c, +_

    ld      a, $13

_:  sub     $07
    ld      c, a
    ld      b, 0
    ld      hl, DATA_3B08
    add     hl, bc
    add     hl, bc
    ex      de, hl
    ld      b, 7
    jp      LABEL_2BFD

LABEL_2C44:
    ld      b, a
    and     $0F
    add     a, 0
    daa
    ld      c, a

    ld      a, b
    and     $F0
    jr      z, ++_

    rrca
    rrca
    rrca
    rrca
    ld      b, a
    xor     a
_:  add     a, $16
    daa
    djnz    -_

_:  add     a, c
    daa
    ret

; draw string onto tilemap
LABEL_2C5E:
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ld      hl, DATA_36A5
    rst     $18
    ; HL = string data

    ; DE = tilemap offset
    ld      e, (hl)
    inc     hl
    ld      a, (hl)
    and     $03
    ld      d, a

    ; IX = color table ptr
    ld      ix, $4400
    add     ix, de
    push    ix
    ; IX = tilemap ptr
    ld      de, -$400
    add     ix, de

    ; DE = VRAM offset between characters
    ld      de, -1
    bit     7, (hl)
    ; if we're drawing HUD text, use -1 offset
    jr      nz, +_

    ; otherwise (intro), use -20 offset
    ld      de, -$20

_:  inc     hl
    ld      a, b
    ld      bc, 0
    add     a, a
    jr      c, DrawBlankText

DrawTextLoop:
    ld      a, (hl)
    cp      $2F
    jr      z, CheckColoredText

    ; draw tile
    ld      (ix), a
    inc     hl
    add     ix, de
    inc     b
    jr      DrawTextLoop

CheckColoredText:
    inc     hl
LABEL_2C93:
    pop     ix

    ld      a, (hl)
    and     a
    jp      m, DrawSingleColorText

    ; A = string palette
DrawMulticolorTextLoop:
    ld      a, (hl)
    ld      (ix), a
    inc     hl
    add     ix, de
    djnz    DrawMulticolorTextLoop
    ret

DrawSingleColorText:
    ld      (ix + 0), a
    add     ix, de
    djnz    DrawSingleColorText
    ret

DrawBlankText:
    ld      a, (hl)
    cp      $2F
    jr      z, FinishBlankDraw

    ld      (ix), $40
    inc     hl
    add     ix, de
    inc     b
    jr      DrawBlankText

FinishBlankDraw:
    inc     hl
    inc     b
    cpir
Patch25 = $+1    ; Ms. Pac - Patch 37
    jr      LABEL_2C93

; sound driver start

; handle audio
LABEL_2CC1:
    ld      hl, MusicData1
LABEL_2CC4:
    ld      ix, CH1_W_NUM
    ld      iy, CH1_FREQ0
    call    LABEL_2D44
    ld      b, a

    ld      a, (CH1_W_NUM)
    and     a
    jr      z, +_

    ld      a, b
Patch26 = $+1   ; Ms. Pac - Patch 38
    ld      (CH1_VOL), a

_:  ld      hl, MusicData2
    ld      ix, CH2_W_NUM
    ld      iy, CH2_FREQ1
    call    LABEL_2D44
    ld      b, a

    ld      a, (CH2_W_NUM)
    and     a
    jr      z, +_

    ld      a, b
Patch27:    ; Ms. Pac - Patch 39
    ld      (CH2_VOL), a

_:  ld      hl, MusicData3
    ld      ix, CH3_W_NUM
    ld      iy, CH3_FREQ1
    call    LABEL_2D44
    ld      b, a

    ld      a, (CH3_W_NUM)
    and     a
    ret     z

    ld      a, b
    ld      (CH3_VOL), a
    ret

; process all SFX
LABEL_2D0C:
    ld      hl, SfxData1
    ld      ix, CH1_E_NUM
    ld      iy, CH1_FREQ0
    call    LABEL_2DEE
    ld      (CH1_VOL), a

    ld      hl, SfxData2
    ld      ix, CH2_E_NUM
    ld      iy, CH2_FREQ1
    call    LABEL_2DEE
    ld      (CH2_VOL), a

    ld      hl, SfxData3
    ld      ix, CH3_E_NUM
    ld      iy, CH3_FREQ1
    call    LABEL_2DEE
    ld      (CH3_VOL), a

    xor     a
    ld      (CH1_FREQ4), a
    ret

LABEL_2D44:
    ld      a, (ix)
    and     a
    jp      z, LABEL_2DF4

    ld      c, a
    ld      b, 8
    ld      e, $80

_:  ld      a, e
    and     c
    jr      nz, LABEL_2D59
    srl     e
    djnz    -_
    ret

LABEL_2D59:
    ld      a, (ix + 2)
    and     e
    jr      nz, +_
Patch28 = $+1    ; Ms. Pac - Patch 40
    ld      (ix + 2), e
    dec     b
    rst     $18
    jr      LABEL_2D72

_:  dec     (ix + 12)
    jp      nz, LABEL_2DD7

LABEL_2D6C:
    ld      l, (ix + 6)
    ld      h, (ix + 7)

LABEL_2D72:
    ld      a, (hl)
    inc     hl
    ld      (ix + 6), l
    ld      (ix + 7), h

    cp      $F0
    jr      c, LABEL_2DA5

    ld      hl, LABEL_2D6C
    push    hl
    and     $0F
    rst     $20

    ; jump table
    .dw LABEL_2F55  ; byte is F0
    .dw LABEL_2F65  ; byte is F1
    .dw LABEL_2F77  ; byte is F2
    .dw LABEL_2F89  ; byte is F3
    .dw LABEL_2F9B  ; byte is F4
    .dw QuickRet    ; returns immediately ; byte is F5
    .dw QuickRet    ; returns immediately ; byte is F6
    .dw QuickRet    ; returns immediately ; byte is F7
    .dw QuickRet    ; returns immediately ; byte is F8
    .dw QuickRet    ; returns immediately ; byte is F9
    .dw QuickRet    ; returns immediately ; byte is FA
    .dw QuickRet    ; returns immediately ; byte is FB
    .dw QuickRet    ; returns immediately ; byte is FC
    .dw QuickRet    ; returns immediately ; byte is FD
    .dw QuickRet    ; returns immediately ; byte is FE
    .dw LABEL_2FAD  ; byte is FF

; process regular byte
LABEL_2DA5:
    ld      b, a
    and     $1F
    jr      z, +_

    ld      (ix + 13), b

_:  ld      c, (ix + 9)
    ld      a, (ix + 11)
    and     $08
    jr      z, +_

    ld      c, 0

_:  ld      (ix + 15), c

    ld      a, b
    rlca
    rlca
    rlca
    and     %111
    ld      hl, DATA_3BB0
    rst     $10
    ld      (ix + 12), a

    ld      a, b
    and     $1F
    jr      z, LABEL_2DD7

    and     $0F
    ld      hl, DATA_3BB8
    rst     $10
    ld      (ix + 14), a

; calc waveform frequency
LABEL_2DD7:
    ld      l, (ix + 14)
    ld      h, 0

    ld      a, (ix + 13)
    and     $10
    jr      z, +_

    ld      a, 1

_:  add     a, (ix + 4)
    jp      z, LABEL_2EE8
    jp      LABEL_2EE4

; process one SFX
LABEL_2DEE:
    ld      a, (ix)
    and     a
    jr      nz, LABEL_2E1B

LABEL_2DF4:
    ld      a, (ix + 2)
    and     a
    ret     z

    ; clear sound driver flags
    ld      (ix + $02), 0
    ld      (ix + $0D), 0
    ld      (ix + $0E), 0
    ld      (ix + $0F), 0

    ; clear all channel frequencies
    ld      (iy + $00), 0
    ld      (iy + $01), 0
    ld      (iy + $02), 0
    ld      (iy + $03), 0

    xor     a
    ret

; find effect
LABEL_2E1B:
    ld      c, a
    ld      b, 8
    ld      e, $80

_:  ld      a, e
    and     c
    jr      nz, LABEL_2E29
    srl     e
    djnz    -_
    ret

LABEL_2E29:
    ld      a, (ix + 2)
    and     e
    jr      nz, LABEL_2E6E
    ld      (ix + 2), e

    dec     b
    ld      a, b
    rlca
    rlca
    rlca
    ld      c, a
    ld      b, 0
    push    hl
    add     hl, bc
    lea     de, ix + 3
    ld      bc, 8
    ldir
    pop     hl

    ld      a, (ix + 6)
    and     $7F
    ld      (ix + 12), a

    ld      a, (ix + 4)
    ld      (ix + 14), a

    ld      a, (ix + 9)
    ld      b, a
    rrca
    rrca
    rrca
    rrca
    and     %1111
    ld      (ix + 11), a

    and     $08
    jr      nz, LABEL_2E6E

    ld      (ix + 15), b
    ld      (ix + 13), 0

LABEL_2E6E:
    dec     (ix + 12)
    jr      nz, LABEL_2ECD

    ld      a, (ix + 8)
    and     a
    jr      z, LABEL_2E89

    dec     (ix + 8)
    jr      nz, LABEL_2E89

    ld      a, e
    cpl
    and     (ix)
    ld      (ix), a
    jp      LABEL_2DEE

LABEL_2E89:
    ld      a, (ix + 6)
    and     $7F
    ld      (ix + 12), a

    bit     7, (ix + 6)
    jr      z, LABEL_2EAD

    ld      a, (ix + 5)
    neg
    ld      (ix + 5), a

    bit     0, (ix + 13)
    set     0, (ix + 13)
    jr      z, LABEL_2ECD
    res     0, (ix + 13)

LABEL_2EAD:
    ld      a, (ix + 4)
    add     a, (ix + 7)
    ld      (ix + 4), a
    ld      (ix + 14), a

    ld      a, (ix + 9)
    add     a, (ix + 10)
    ld      (ix + 9), a

    ld      b, a
    ld      a, (ix + 11)
    and     $08
    jr      nz, LABEL_2ECD
    ld      (ix + 15), b

LABEL_2ECD:
    ld      a, (ix + 14)
    add     a, (ix + 5)
    ld      (ix + 14), a

    ld      l, a
    ld      h, 0

    ld      a, (ix + 3)
    and     $70
    jr      z, LABEL_2EE8

    rrca
    rrca
    rrca
    rrca

LABEL_2EE4:
    ld      b, a
_:  add     hl, hl
    djnz    -_

LABEL_2EE8:
    ld      (iy), l
    ld      a, l
    rrca
    rrca
    rrca
    rrca
    ld      (iy + 1), a
    ld      (iy + 2), h
    
    ld      a, h
    rrca
    rrca
    rrca
    rrca
    ld      (iy + 3), a

    ld      a, (ix + 11)
    rst     $20

    ; jump table
    .dw LABEL_2F22
    .dw LABEL_2F26
    .dw LABEL_2F2B
    .dw LABEL_2F3C
    .dw LABEL_2F43
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet
    .dw QuickRet

LABEL_2F22:
    ld      a, (ix + 15)
    ret

LABEL_2F26:
    ld      a, (ix + 15)
    jr      +_

LABEL_2F2B:
    ld      a, ($4C84)
    and     $01
LABEL_2F30:
    ld      a, (ix + 15)
    ret     nz

_:  and     $0F
    ret     z
    dec     a
    ld      (ix + 15), a
    ret

LABEL_2F3C:
    ld      a, ($4C84)
    and     $03
    jr      LABEL_2F30

LABEL_2F43:
    ld      a, ($4C84)
    and     $07
    jr      LABEL_2F30

LABEL_2F55:
    ld      l, (ix + 6)
    ld      h, (ix + 7)
    ld      a, (hl)
    ld      (ix + 6), a
    inc     hl
    ld      a, (hl)
    ld      (ix + 7), a
    ret

LABEL_2F65:
    ld      l, (ix + 6)
    ld      h, (ix + 7)
    ld      a, (hl)
    inc     hl
    ld      (ix + 6), l
    ld      (ix + 7), h
    ld      (ix + 3), a
    ret

LABEL_2F77:
    ld      l, (ix + 6)
    ld      h, (ix + 7)
    ld      a, (hl)
    inc     hl
    ld      (ix + 6), l
    ld      (ix + 7), h
    ld      (ix + 4), a
    ret

LABEL_2F89:
    ld      l, (ix + 6)
    ld      h, (ix + 7)
    ld      a, (hl)
    inc     hl
    ld      (ix + 6), l
    ld      (ix + 7), h
    ld      (ix + 9), a
    ret

LABEL_2F9B:
    ld      l, (ix + 6)
    ld      h, (ix + 7)
    ld      a, (hl)
    inc     hl
    ld      (ix + 6), l
    ld      (ix + 7), h
    ld      (ix + 11), a
    ret

LABEL_2FAD:
    ld      a, (ix + 2)
    cpl
    and     (ix)
    ld      (ix), a
    jp      LABEL_2DF4

; ROM CHIP 4 (pacman.6j/u7)

; init
LABEL_3000:
    ld      sp, $4FC0

    ld      hl, $4400
    ld      b, 4
LABEL_30E4:
    ld      a, $0F

_:  ld      (hl), a
    inc     l
    jr      nz, -_

    inc     h
    djnz    LABEL_30E4

    ; check for self-test error
    exx

    ld      b, $23
    call    LABEL_2C5E

LABEL_3174:
    ld      hl, $5006
    ld      a, 1

    ; clear I/O
_:  ld      (hl), a
    dec     l
    jr      nz, -_

    xor     a
    ld      ($5003), a

    ; set I/O
    sub     4
    call    SetIntVector
    
    ld      sp, $4FC0

LABEL_3290:
    ld      a, (IN1)
    and     $60
    jp      nz, LABEL_234B

    ld      b, 8
_:  call    LABEL_32ED
    djnz    -_

    ld      a, (IN1)
    and     $10
    jp      nz, LABEL_234B

    ld      e, 1

LABEL_32A9:
    ld      b, 4

LABEL_32AB:  
    call    LABEL_32ED
    ld      a, (IN0)
    and     e
    jr      nz, LABEL_32AB

_:  call    LABEL_32ED
    ld      a, (IN0)
    xor     $FF
    jr      nz, -_
    djnz    LABEL_32AB

    rlc     e
    ld      a, e
    cp      $10
    jp      c, LABEL_32A9

    ; draw easter egg (MADE BY NAMCO)
    ld      hl, $4000
    ld      b, 4

LABEL_32D3:
    ld      a, $40
_:  ld      (hl), a
    inc     l
    jr      nz, -_

    inc     h
    djnz    LABEL_32D3

    call    LABEL_3AF4

_:  ld      a, (IN1)
    and     $10
    jp      z, -_
    jp      LABEL_234B

; delay the CPU
LABEL_32ED:
    ld      hl, $2800

_:  dec     hl
    ld      a, h
    or      l
    jr      nz, -_
    ret

DATA_32F9:
    .db "01"    ; 10k points
    .db "51"    ; 15k points
    .db "02"    ; 20k points

DATA_32FF:
.db 0, -1
DATA_3301:
.db 1, 0
DATA_3303:
.db 0, 1
DATA_3305:
.db -1, 0

DATA_3307:
.db $00, $FF
DATA_3309:
.db $01, $00
DATA_330B:
.db $00, $01
DATA_330D:
.db $FF, $00

DATA_330F:
    ; speed bit patterns
    .dw $2A55, $2A55, $5555, $5555
    .dw $2A55, $2A55, $4A52, $94A5

    ; ghost movement bit patterns
    .dw $2525, $2525
    .dw $2222, $2222
    .dw $0101, $0101

    ; ghost orientation counters
    .dw $0258, $0708, $0960, $0E10
    .dw $1068, $1770, $1914

DATA_3339:
    ; speed bit patterns
    .dw $4A52, $94A5, $2AAA, $5555
    .dw $2A55, $2A55, $4A52, $94A5

    ; ghost movement bit patterns
    .dw $2492, $4925
    .dw $2448, $9122
    .dw $0101, $0101

    ; ghost orientation counters
    .dw $0000, $0000, $0000, $0000
    .dw $0000, $0000, $0000

DATA_3363:
    ; speed bit patterns
    .dw $2A55, $2A55, $5555, $5555
    .dw $2AAA, $5555, $2A55, $2A55
    
    ; ghost movement bit patterns
    .dw $4A52, $94A5
    .dw $2448, $9122
    .dw $4421, $0844

    ; ghost orientation counters
    .dw $0258, $0834, $09D8, $0FB4
    .dw $1158, $1608, $1734

; everything from here until DATA_36A5 is different on Ms. Pac
DATA_338D:
    ; speed bit patterns
    .dw $5555, $5555, $6AD5, $6AD5
    .dw $6AAA, $D555, $5555, $5555

    ; ghost movement bit patterns
    .dw $2AAA, $5555, $2492
    .dw $2492, $2222, $2222

    ; ghost orientation counters
    .dw $01A4, $0654, $07F8, $0CA8
    .dw $0DD4, $1284, $13B0

DATA_33B7:
    ; speed bit patterns
    .dw $6AD5, $6AD5, $5AD6, $B5AD
    .dw $5AD6, $B5AD, $6AD5, $6AD5

    ; ghost movement bit patterns
    .dw $6AAA, $D555, $2492
    .dw $4925, $2448, $9122

    ; ghost orientation counters
    .dw $01A4, $0654, $07F8, $0CA8
    .dw $0DD4, $FFFE, $FFFF

DATA_33E1:
    ; speed bit patterns
    .dw $6D6D, $6D6D, $6D6D, $6D6D
    .dw $6DB6, $DB6D, $6D6D, $6D6D

    ; ghost movement bit patterns
    .dw $5AD6, $B5AD, $2525
    .dw $2525, $2492, $2492

    ; ghost orientation counters
    .dw $012C, $05DC, $0708, $0BB8
    .dw $0CE4, $FFFE, $FFFF

DATA_340B:
    ; speed bit patterns
    .dw $6AD5, $6AD5, $6AD5, $6AD5
    .dw $6DB6, $DB6D, $6D6D, $6D6D

    ; ghost movement bit patterns
    .dw $5AD6, $B5AD, $2448
    .dw $9122, $2492, $2492
    
    ; ghost orientation counters
    .dw $012C, $05DC, $0708, $0BB8
    .dw $0CE4, $FFFE, $FFFF

DATA_3435:
    #import "src/Arcade/includes/mazedata.bin"

DATA_35B5:
    #import "src/Arcade/includes/pelletdata.bin"

; string lookup table
DATA_36A5:  ; Ms. Pac - patch some indices
.dw DATA_3713   ; HIGH SCORE   
.dw DATA_3723   ; CREDIT  
.dw DATA_3732   ; FREE PLAY
.dw DATA_3741   ; PLAYER ONE
.dw DATA_3751   ; PLAYER TWO
.dw DATA_376A   ; GAME OVER
.dw DATA_377A   ; READY!
.dw DATA_3786   ; PUSH START BUTTON
.dw DATA_379D   ; 1 PLAYER ONLY 
.dw DATA_37B1   ; 1 OR 2 PLAYERS
.dw DATA_3D21   ; BONUS PAC-MAN FOR  00PTS
.dw DATA_3D00   ; ADDITIONAL    AT   000
.dw DATA_37FD   ; CHARACTER / NICKNAME
.dw DATA_3D67   ; BLINKY
.dw DATA_3DE3   ; BBBBBBBB
.dw DATA_3D86   ; PINKY
.dw DATA_3E02   ; DDDDDDDD
.dw DATA_384C   ; . 10 Pts (pac-man only)
.dw DATA_385A   ; o 50 Pts (pac-man only)
.dw DATA_3D3C   ; (C) MIDWAY MFG CO
.dw DATA_3D57   ; SHADOW
.dw DATA_3DD3   ; AAAAAAAA
.dw DATA_3D76   ; SPEEDY
.dw DATA_3DF2   ; CCCCCCCC
.dw 1, 2, 3     ; unused
.dw DATA_38BC	; 100
.dw DATA_38C4	; 300
.dw DATA_38CE	; 500
.dw DATA_38D8	; 700
.dw DATA_38E2	; 1000
.dw DATA_38EC	; 2000
.dw DATA_38F6	; 3000
.dw DATA_3900	; 5000
.dw DATA_390A	; MEMORY  OK
.dw DATA_391A	; BAD    R M
.dw DATA_396F	; FREE  PLAY       
.dw DATA_392A	; 1 COIN  1 CREDIT 
.dw DATA_3958	; 1 COIN  2 CREDITS
.dw DATA_3941	; 2 COINS 1 CREDIT 
.dw DATA_3E4F	; PAC-MAN
.dw DATA_3986	; BONUS  NONE
.dw DATA_3997	; BONUS
.dw DATA_39B0	; TABLE  
.dw DATA_39BD	; UPRIGHT
.dw DATA_39CA	; 000		for test screen
.dw DATA_3DA5	; INKY    
.dw DATA_3E21	; FFFFFFFF
.dw DATA_3DC4	; CLYDE
.dw DATA_3E40	; HHHHHHHH
.dw DATA_3D95	; BASHFUL
.dw DATA_3E11	; EEEEEEEE
.dw DATA_3DB4	; POKEY
.dw DATA_3E30	; GGGGGGGG
.dw PorterText	; PORTED BY GRUBBY

#include "src/Arcade/includes/strings1.asm"

; made by namco easter egg text
DATA_3A4F:
; "NAMCO"
.db $01, $01, $03, $01, $01, $01, $03, $02, $02, $02, $01, $01, $01, $01, $02, $04
.db $04, $04, $06, $02, $02, $02, $02, $04, $02, $04, $04, $04, $06, $02, $02, $02
.db $02, $01, $01, $01, $01, $02, $04, $04, $04, $06, $02, $02, $02, $02, $06, $04
.db $05, $01, $01, $03, $01, $01, $01, $04, $01, $01, $01, $03, $01, $01, $04, $01
.db $01, $01

; "BY"
.db $6C, $05, $01, $01, $01, $18, $04, $04, $18, $05, $01, $01, $01, $17, $02, $03
.db $04, $16, $04, $03, $01, $01, $01

; "MADE"
.db $76, $01, $01, $01, $01, $03, $01, $01, $01, $02, $04, $02, $04, $0E, $02, $04
.db $02, $04, $02, $04, $0B, $01, $01, $01, $02, $04, $02, $01, $01, $01, $01, $02
.db $02, $02, $0E, $02, $04, $02, $04, $02, $01, $02, $01, $0A, $01, $01, $01, $01
.db $03, $01, $01, $01, $03, $01, $01, $03, $04, $00                    

DATA_3AE2:  ; grid test data
.dw $4002
.dw $3E01
.dw $103D
.dw $4040
.dw $3D0E
.dw $103E
.dw $43C2
.dw $3E01
.dw $103D

LABEL_3AF4:
    ld      hl, $40A2
    ld      de, DATA_3A4F

_:  ld      (hl), $14
    ld      a, (de)
    and     a
    ret     z

    inc     de
    add     a, l
    ld      l, a
    jp      nc, -_
    inc     h
    jr      -_

DATA_3B08:  ; fruit sprite data table (sprite, palette)
.db $90, $14   			; cherry
.db $94, $0F   			; strawberry
.db $98, $15   			; 1st orange
.db $98, $15   			; 2nd orange
.db $A0, $14   			; 1st apple
.db $A0, $14   			; 2nd apple
.db $A4, $17   			; 1st pineapple
.db $A4, $17   			; 2nd pineapple
.db $A8, $09   			; 1st galaxian / pretzel
.db $A8, $09   			; 2nd galaxian / pretzel
.db $9C, $16   			; 1st bell / banana
.db $9C, $16   			; 2nd bell / banana
.db $AC, $16   			; 1st key
.db $AC, $16   			; 2nd key
.db $AC, $16   			; 3rd key
.db $AC, $16   			; 4th key
.db $AC, $16   			; 5th key
.db $AC, $16   			; 6th key
.db $AC, $16   			; 7th key
.db $AC, $16   			; 8th key

SfxData1:
.db $73, $20, $00, $0C, $00, $0A, $1F, $00      ; extra life sound
.db $72, $20, $FB, $87, $00, $02, $0F, $00		; credit sound

SfxData2:
.db $36, $20, $04, $8C, $00, $00, $06, $00      ; end of power pellet
.db $36, $28, $05, $8B, $00, $00, $06, $00      ; bg sfx when 155 dots eaten
.db $36, $30, $06, $8A, $00, $00, $06, $00      ; bg sfx when 179 dots eaten
.db $36, $3C, $07, $89, $00, $00, $06, $00      ; bg sfx when 12 dots left
.db $36, $48, $08, $88, $00, $00, $06, $00      ; reset bg sfx when 12 dots left
.db $24, $00, $06, $08, $00, $00, $0A, $00      ; power pellet eaten sfx
.db $40, $70, $FA, $10, $00, $00, $0A, $00      ; eyes running sfx
.db $70, $04, $00, $00, $00, $00, $08, $00      ; unused

SfxData3:
.db $42, $18, $FD, $06, $00, $01, $0C, $00      ; dot eaten 1
.db $42, $04, $03, $06, $00, $01, $0C, $00      ; dot eaten 2
.db $56, $0C, $FF, $8C, $00, $02, $0F, $00      ; fruit eaten
.db $05, $00, $02, $20, $00, $01, $0C, $00      ; ghost eaten
.db $41, $20, $FF, $86, $FE, $1C, $0F, $FF      ; unused
.db $70, $00, $01, $0C, $00, $01, $08, $00      ; unused

DATA_3BB0:
.db $01, $02, $04, $08, $10, $20, $40, $80

DATA_3BB8:
.db $00, $57, $5C, $61, $67, $6D, $74, $7B
.db $82, $8A, $92, $9A, $A3, $AD, $B8, $C3

MusicData1:
.dw DATA_3BD4
.dw DATA_3BF3

MusicData2:
.dw DATA_3C58
.dw DATA_3C95

MusicData3:
.dw DATA_3CDE
.dw DATA_3CDE

Data_3BD4:
#import "src/Arcade/sounds/song_3BD4.bin"

DATA_3BF3:
#import "src/Arcade/sounds/song_3BF3.bin"

DATA_3C58:
#import "src/Arcade/sounds/song_3C58.bin"

DATA_3C95:
#import "src/Arcade/sounds/song_3C95.bin"

DATA_3CDE:
.db 0

#include "src/Arcade/includes/strings2.asm"

DATA_3FFA:
    .dw LABEL_3000
    .dw HandleVBlank

UpdateTilePalette:
    ld      (hl), a
    push    hl
    push    bc

    ld      bc, $4400
    or      a
    sbc     hl, bc

    ld      bc, PrevTilemap & $FFFF
    add     hl, bc
    ld      (hl), 0

    ld      hl, DrawTilemapFlag
    ld      (hl), 1

    pop     bc
    pop     hl
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

    call.lil HandleCocktailFlip + romStart

    call    HandleScroll

    call.lil DrawScreen + romStart
    
    call.lil HandleInput + romStart

IntVector = $+1
    call    HandleVBlank

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

    ; is the int vector $3FFA?
    cp      $FA
    jr      nz, +_

    ld      hl, LABEL_3000
    ld      (IntVector), hl

    ; if the vector's not $3FFC, it's invalid. bail out
_:  cp      $FC
    jr      nz, +_

    ld      hl, HandleVBlank
    ld      (IntVector), hl

_:  pop     hl
    ret

DIPSwitch:
    .db %11001001

; checks if the speedup chip is enabled
CheckForFastHack:
    ; use normal Pac-Man speed if there's a coffee break
    ld      a, (CoffeeBreakTrig)
    or      a
    ret     nz

    ; use normal Pac-Man speed if speedup isn't enabled
    ld      a, (FastHackTrig)
    or      a
    ret     z

    ld      a, $FF
    pop     bc
    ld      bc, $11CA
    jp      LABEL_1843 + 2

FastHackTrig:
    .db     0

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

    ; if the art data appvar isn't in RAM, copy it into safeRAM
    ld      hl, $0002
    add     hl, de
    call    SetAToDEU
    cp      $D0
    jr      nc, +_

HeaderSize = $+1
    ld      hl, $0012
    add     hl, de
    ld      de, pixelShadow
    ld      bc, $8000
    ldir

    ld      hl, pixelShadow
_:  push    hl

    ld      hl, ADLShift + romStart
    ld      de, cursorImage
    ld      bc, CursorCodeEnd - CursorCodeStart
    ldir

    ld      hl, TextShadowShift + romStart
    ld      de, TextShadow
    ld      bc, ShadowCodeEnd - ShadowCodeStart
    ldir

    ; set ptrs to art data
    pop     hl
    ld      (TileROM_PTR), hl
    ld      de, $4000
    add     hl, de
    ld      (SpriteROM_PTR), hl
    
    call    SelectColors + romStart
    
    ; load Pac-Man palette ROM
ConvertPaletteLIL:
    call    ConvertPalette 
    ret.sis

ArtHeader:
    .db $15, "PacArt", 0

; chooses between an arcade-perfect or TI-BASIC palette
SelectColors:
    ld      a, ($D031F6)
    or      a
    ret     z

    ld      hl, TI_Colors
    ld      de, Colors
    ld      bc, 32
    ldir
    ret

HandleInput:
    ld      ix, IN0_Maps + romStart
    call    UpdateInputLoop + romStart
    ld      (IN0 + romStart), a

    ld      ix, IN1_Maps + romStart
    call    UpdateInputLoop + romStart
    res     7, a
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
    .db 0, 0                    ; auto advance, unmapped
    .db KbdG4 & $FF, kbd5       ; player 1 coin
    .db KbdG5 & $FF, kbd6       ; player 2 coin
    .db 0, 0                    ; credit button, unmapped

IN1_Maps:
    .db KbdG7 & $FF, kbdDown
    .db KbdG7 & $FF, kbdRight
    .db KbdG7 & $FF, kbdLeft
    .db KbdG7 & $FF, kbdUp
    .db KbdG1 & $FF, kbdDel      ; board test. releasing causes reset
    .db KbdG1 & $FF, kbdMode     ; player 1 start
    .db KbdG3 & $FF, kbdGraphVar ; player 2 start
    .db 0, 0                     ; cabinet type, unmapped

IN0:
    .db $FF

IN1:
    .db $FF

.ASSUME ADL=0

#define cursorImage $E30800

ADLShift:
.ORG cursorImage

CursorCodeStart:
#include "src/Arcade/PacRenderer.asm"

; color data

Colors:
.dw $0000, $7C00, $6A4A, $FEDF, $0000, $83FF, $A2DF, $FECA, $0000, $FFE0, $0000, $909F, $83E0, $A2D4, $FED4, $6B7F

TI_Colors:
.dw $0000, $7C00, $5880, $7C1F, $0000, $025F, $025F, $FE24, $0000, $FFE0, $0000, $001F, $8260, $8260, $FE24, $739C

Palette:
#import "src/Arcade/includes/palette.bin"

CursorCodeEnd:
#include "src/includes/ti_equates.asm"

.ORG ADLShift + (CursorCodeEnd - CursorCodeStart)
TextShadowShift:
.ORG TextShadow
ShadowCodeStart:
#include "src/includes/spi.asm"
ShadowCodeEnd: