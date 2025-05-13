#include "bin/PacArc.lab"

.db $FF
.ORG 0
.ASSUME ADL=0

.dl MusHeader
.dl MusIcon
.dl HeaderLength

MusHeader:
    .db $81, "Ms.Pac-Man (Arcade Ver.)",0
MusIcon:
#import "src/includes/gfx/logos/mspacarc.bin"
HeaderLength:

.ORG $8000

; entry point; patches Pac-Man code
#include "src/Arcade/mspac_patcher.asm"

; handle coffee break 1
LABEL_3435:
    ld      a, ($4F00)
    cp      $01
    jp      z, LABEL_349C

    ; draw "THEY MEET" by inserting a task
    rst     $28
    .db     $1C, $32

    ; draw "1"
    ld      a, 1
    ld      ($42AC), a

    ; set 1's palette to white
    ld      a, $16
    ld      ($46AC), a
    ld      c, $00
    jp      LABEL_349C

; handle coffee break 2
LABEL_344F:
    ld      a, ($4F00)
    cp      $01
    jp      z, LABEL_349C

    ; draw "THE CHASE" by inserting a task
    rst     $28
    .db     $1C, $17

    ; draw "2"
    ld      a, 2
    ld      ($42AC), a

    ; set 2's palette to white
    ld      a, $16
    ld      ($46AC), a
    ld      c, $0C
    jp      LABEL_349C

; handle coffee break 3
LABEL_3469:
    ld      a, ($4F00)
    cp      $01
    jp      z, LABEL_349C

    ; draw "JUNIOR" by inserting a task
    rst     $28
    .db     $1C, $15

    ; draw "3"
    ld      a, 3
    ld      ($42AC), a

    ; set 3's palette to white
    ld      a, $16
    ld      ($46AC), a
    ld      c, $18
    jp      LABEL_349C

; move Blinky in the attract mode intro
LABEL_3483:
    ld      c, $24
    jp      LABEL_349C

; move Pinky in the attract mode intro
LABEL_3488:
    ld      c, $30
    jp      LABEL_349C

; move Inky in the attract mode intro
LABEL_348D:
    ld      c, $3C
    jp      LABEL_349C

; move Sue in the attract mode intro
LABEL_3492:
    ld      c, $48
    jp      LABEL_349C

; move Ms. Pac-Man in the attract mode intro
LABEL_3497:
    ld      c, $54
    jp      LABEL_349C

; handle cutscenes
LABEL_349C:
    ld      a, ($4F00)
    and     a
    call    z, LABEL_3611
    
    ld      b, 6
    ld      ix, $4F0C

LABEL_34A9:
    ; jump based on cutscene bytecode
    ld      l, (ix)
    ld      h, (ix + 1)
    ld      a, (hl)

    ; code F0 - LOOP
    cp      $F0
    jp      z, LABEL_34DE

    ; code F1 - SETPOS
    cp      $F1
    jp      z, LABEL_356B

    ; code F2 - SETN
    cp      $F2
    jp      z, LABEL_3597

    ; code F3 - SETCHAR
    cp      $F3
    jp      z, LABEL_3577

    ; code F5 - PLAYSOUND
    cp      $F5    
    jp      z, LABEL_3607

    ; code F6 - PAUSE
    cp      $F6
    jp      z, LABEL_35A4

    ; code F7 - SHOWACT
    cp      $F7
    jp      z, LABEL_35F3

    ; code F8 - CLEARACT
    cp      $F8
    jp      z, LABEL_35FD

    ; code FF - END
    cp      $FF
    jp      z, LABEL_35CB

    halt

; code F0 - LOOP
LABEL_34DE:
    push    hl
    ld      a, 1
    rst     $10
    ld      c, a

    ld      hl, $4F2E
    rst     $18
    ld      a, c
    add     a, h
    call    LABEL_3556
    ld      (de), a

    call    LABEL_3641
    rst     $18
    ld      a, h
    add     a, c
    ld      (de), a
    pop     hl

    push    hl
    ld      a, 2
    rst     $10
    ld      c, a

    ld      hl, $4F2E
    rst     $18
    ld      a, c
    add     a, l
    call    LABEL_3556
    dec     de
    ld      (de), a

    call    LABEL_3641
    rst     $18
    ld      a, l
    add     a, c
    dec     de
    ld      (de), a

    ld      hl, $4F0F
    ld      a, b
    rst     $10

    push    hl
    inc     a
    ld      c, a
    
LABEL_3515:
    ld      hl, $4F3E
    rst     $18
    ld      a, c
    sra     a
    rst     $10
    cp      $FF
    jp      nz, +_

    ld      c, 0
    jr      LABEL_3515

_:  pop     hl
    ld      (hl), c
    ld      e, a
    pop     hl

    ld      a, 3
    rst     $10
    ld      d, a

    push    de
    ld      hl, $4F4E
    rst     $18
    pop     hl

    ex      de, hl
    ld      (hl), d
    dec     hl
    ld      (hl), e
    ld      hl, $4F17
    ld      a, b
    rst     $10
    dec     a
    ld      (hl), a
    ld      de, 0
    jr      nz, LABEL_35B4

    ld      e, 4
    jr      LABEL_35B4

LABEL_3556:
    ld      c, a
    sra     c
    sra     c
    sra     c
    sra     c
    and     a
    jp      p, +_

    or      $F0
    inc     c
    ret

_:  and     $0F
    ret

; code F1 - SETPOS
LABEL_356B:
    ex      de, hl
    call    LABEL_3641
    ex      de, hl

    push    de
    inc     hl

    ld      d, (hl)
    inc     hl
    ld      e, (hl)
    jr      LABEL_358A

; code F3 - SETCHAR
LABEL_3577:
    ex      de, hl
    ld      hl, $4F0F
    ld      a, b
    rst     $10
    ld      (hl), 0
    ex      de, hl

    ld      de, $4F3E
    push    de
    inc     hl

    ld      e, (hl)
    inc     hl
    ld      d, (hl)
LABEL_358A:
    pop     hl
    push    de
    rst     $18
    ex      de, hl
    pop     de

    ld      (hl), d
    dec     hl
    ld      (hl), e
    ld      de, 3
    jr      LABEL_35B4

; code F2 - SETN
LABEL_3597:
    inc     hl
    ld      c, (hl)
    ld      hl, $4F17
    ld      a, b
    rst     $10
    ld      (hl), c
    ld      de, 2
    jr      LABEL_35B4

; code F6 - PAUSE
LABEL_35A4:
    ld      hl, $4F17
    ld      a, b
    rst     $10

    dec     a
    ld      (hl), a
    ld      de, 0
    jr      nz, LABEL_35B4

    ld      e, 1
LABEL_35B4:
    ld      l, (ix)
    ld      h, (ix + 1)
    add     hl, de
    ld      (ix), l
    ld      (ix + 1), h
    dec     ix
    dec     ix
    djnz    +_
    ret

_:  jp      LABEL_34A9

; code FF - END
LABEL_35CB:
    ld      hl, $4F1F
    ld      a, b
    rst     $10
    ld      (hl), 1

    ld      hl, $4F20
    ld      a, (hl)

    inc     hl
    and     (hl)
    inc     hl
    and     (hl)
    inc     hl
    and     (hl)
    inc     hl
    and     (hl)
    inc     hl
    and     (hl)

    ld      de, 0
    jr      z, LABEL_35B4

    ld      a, ($4E02)
    and     a
    jp      z, LABEL_2195

    xor     a
    ld      ($4F00), a
    jp      LABEL_58E

; code F7 - SHOWACT
LABEL_35F3:
    ; redraw the tilemap
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ld      a, b

    ; insert task
    rst     $28
    .db     $1C, $30

    ld      b, a
    ld      de, 1
    jr      LABEL_35B4

; code F8 - CLEARACT
LABEL_35FD:
    ; redraw the tilemap
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ; clear act # tile
    ld      a, $40
    ld      ($42AC), a
    ld      de, 1
    jr      LABEL_35B4

; code F5 - PLAYSOUND
LABEL_3607:
    inc     hl
    ld      a, (hl)
    ld      ($4EBC), a
    ld      de, 2
    jr      LABEL_35B4

LABEL_3611:
    ld      a, ($4E02)
    and     a
    jr      nz, +_

    ; clear sound waves
    ld      a, 2
    ld      ($4ECC), a
    ld      ($4EDC), a

    ; load animation data into RAM
_:  ld      hl, DATA_81F0
    ld      b, 0
    add     hl, bc
    ld      de, $4F02
    ld      bc, 12
    ldir

    ld      a, 1
    ld      ($4F00), a
    ld      ($4DA4), a

    ld      hl, $4F1F
    ld      a, 0
    ld      ($4DA5), a

    ld      b, $14
    rst     $08
    ret

LABEL_3641:
    ld      a, b
    cp      6
    jr      nz, +_

    ld      hl, $4DC6
    ret

_:  ld      hl, $4CFE
    ret

LABEL_364E:
    dec     b

    push    bc
    ld      a, b
    cp      1
    jr      z, +_

    ld      b, 0
    jr      LABEL_366A

_:  ld      a, ($4E13)
    ld      b, 1
    cp      1
    jr      z, LABEL_366A

    ld      b, 2
    cp      4
    jr      z, LABEL_366A

    ld      b, 3

LABEL_366A:
    rst     $18
    pop     bc
    jp      LABEL_2D72

; handle slowdown
LABEL_366F:
    ; does A's tile slow down the ghosts?
    bit     6, a
    jp      z, LABEL_2066
    ; set ghost slowdown flag
    ld      a, 1
    ld      (bc), a
    ret

LABEL_3678:
    ld      hl, 0
    ld      ($4DD2), hl
    ret

LABEL_3E5C:
    ld      a, ($4E02)
    cp      $10
    call    nz, LABEL_3ED0
    ld      a, ($4E02)
    rst     $20

    ; jump table
    .dw LABEL_45F         ; display "ms. Pac Man"
    .dw LABEL_3E96        ; draw the midway logo and copyright
    .dw LABEL_3E8B        ; display "Ms. Pac Man"
    .dw QuickRet          ; returns immediately
    .dw LABEL_3EBD        ; display "with"
    .dw LABEL_3E9C        ; display "Blinky"
    .dw LABEL_3483        ; move blinky across the marquee and up left side
    .dw LABEL_3EA2        ; clear "with" and display "Pinky"
    .dw LABEL_3488        ; move pinky across the marquee and up left side
    .dw LABEL_3EAB        ; display "Inky"
    .dw LABEL_348D        ; move Inky across the marquee and up left side
    .dw LABEL_3EB1        ; display "Sue"
    .dw LABEL_3492        ; move Sue across the marquee and up left side
    .dw LABEL_3EC3        ; display "Starring"
    .dw LABEL_3EB7        ; display "MS. Pac-Man"
    .dw LABEL_3497        ; move ms pacman across the marquee
    .dw LABEL_3EC9        ; start demo mode where ms. pac plays herself

LABEL_3E8B:
    ; insert task
    rst     $28
    .db     $1C, $0C

    ld      a, $60
    ld      ($4F01), a
    jp      LABEL_58E

LABEL_3E96:
    call    LABEL_9642
    jp      LABEL_58E

LABEL_3E9C:
    ; insert task
    rst     $28
    .db     $1C, $0D
    jp      LABEL_58E

LABEL_3EA2:
    ; insert tasks
    rst     $28
    .db     $1C, $30
    rst     $28
    .db     $1C, $0F
    jp      LABEL_58E

LABEL_3EAB:
    ; insert task
    rst     $28
    .db     $1C, $2F
    jp      LABEL_58E

LABEL_3EB1:
    ; insert task
    rst     $28
    .db     $1C, $31
    jp      LABEL_58E

LABEL_3EB7:
    ; insert task
    rst     $28
    .db     $1C, $33
    jp      LABEL_58E

LABEL_3EBD:
    ; insert task
    rst     $28
    .db     $1C, $0E
    jp      LABEL_58E

LABEL_3EC3:
    ; insert task
    rst     $28
    .db     $1C, $10
    jp      LABEL_58E

; handle Ms. Pac-Man in demo
LABEL_3EC9:
    xor     a
    ld      ($4E14), a
    jp      LABEL_57C

; handle the flashing bulbs in attract mode
LABEL_3ED0:
    ld      a, 1
    ld      (DrawTilemapFlag), a

    ld      a, ($4F01)
    inc     a
    and     $0F
    ld      ($4F01), a

    ld      c, a
    res     0, c
    ld      b, 0
    ld      ix, DATA_3F81
    bit     0, a
    jr      z, LABEL_3F19

    add     ix, bc
    ; move white bulbs on marquee
    ld      l, (ix + $00)
    ld      h, (ix + $01)
    ld      (hl), $87

    ld      l, (ix + $10)
    ld      h, (ix + $11)
    ld      (hl), $87

    ld      l, (ix + $20)
    ld      h, (ix + $21)
    ld      (hl), $8A

    ld      l, (ix + $30)
    ld      h, (ix + $31)
    ld      (hl), $81

    ld      l, (ix + $40)
    ld      h, (ix + $41)
    ld      (hl), $81

    ld      l, (ix + $50)
    ld      h, (ix + $51)
    ld      (hl), $84
    ret

; recolor marquee bulbs
LABEL_3F19:
    dec     c
    xor     a
    cp      c
    jp      m, +_

    ld      b, $FF

_:  dec     c
    add     ix, bc

    ; color marquee dot red
    ld      l, (ix + $00)
    ld      h, (ix + $01)
    dec     (hl)
    ; color next dot white
    ld      l, (ix + $02)
    ld      h, (ix + $03)
    ld      (hl), $88

    ; color marquee dot red
    ld      l, (ix + $10)
    ld      h, (ix + $11)
    dec     (hl)
    ; color next dot white
    ld      l, (ix + $12)
    ld      h, (ix + $13)
    ld      (hl), $88

    ; color marquee dot red
    ld      l, (ix + $20)
    ld      h, (ix + $21)
    dec     (hl)
    ; color next dot white
    ld      l, (ix + $22)
    ld      h, (ix + $23)
    ld      (hl), $8B

    ; color marquee dot red
    ld      l, (ix + $30)
    ld      h, (ix + $31)
    dec     (hl)
    ; color next dot white
    ld      l, (ix + $32)
    ld      h, (ix + $33)
    ld      (hl), $82

    ; color marquee dot red
    ld      l, (ix + $40)
    ld      h, (ix + $41)
    dec     (hl)
    ; color next dot white
    ld      l, (ix + $42)
    ld      h, (ix + $43)
    ld      (hl), $82

    ; color marquee dot red
    ld      l, (ix + $50)
    ld      h, (ix + $51)
    dec     (hl)
    ; color next dot white
    ld      l, (ix + $52)
    ld      h, (ix + $53)
    ld      (hl), $85
    ret

DATA_3F7F:
    .dw $42D0
DATA_3F81:
    .dw $42B0, $4290, $4270, $4250, $4230, $4210, $41F0, $41D0
    .dw $41B0, $4190, $4170, $4150, $4130, $4110, $40F0, $40D0
    .dw $40B0, $40AF, $40AE, $40AD, $40AC, $40AB, $40AA, $40A9
    .dw $40C9, $40E9, $4109, $4129, $4149, $4169, $4189, $41A9
    .dw $41C9, $41E9, $4209, $4229, $4249, $4269, $4289, $42A9
    .dw $42C9, $42CA, $42CB, $42CC, $42CD, $42CE, $42CF, $42D0

; cutscene and intro animations
#include "src/Arcade/mspac_anims.asm"

LABEL_869C: ; handle Ms. Pac right sprite
    ld      a, ($4D09)
    and     $07
    srl     a
    cpl

    ld      e, $30
    add     a, e
    bit     0, a
    jr      nz, +_

    ld      a, $37

_:  ld      ($4C0A), a
    ret

LABEL_86B1: ; handle Ms. Pac down sprite
    ld      a, ($4D08)
    and     $07
    srl     a

    ld      e, $30
    add     a, e
    bit     0, a
    jr      nz, +_

    ld      a, $34

_:  ld      ($4C0A), a
    ret

LABEL_86C5: ; handle Ms. Pac left sprite
    ld      a, ($4D09)
    and     $07
    srl     a

    ld      e, $AC
    add     a, e
    bit     0, a
    jr      nz, +_

    ld      a, $35

_:  ld      ($4C0A), a
    ret

LABEL_86D9: ; handle Ms. Pac up sprite
    ld      a, ($4D08)
    and     $07
    srl     a
    cpl

    ld      e, $F4
    add     a, e
    bit     0, a
    jr      nz, +_

    ld      a, $36

_:  ld      ($4C0A), a
    ret

LABEL_86EE: ; handle moving fruit
    ld      a, ($4DA4)
    and     a
    ret     nz

    ; check for release if the fruit's already been spawned in
    ld      a, ($4DD4)
    and     a
    jp      z, LABEL_8747

    ld      a, ($4DD2)
    and     a
    jp      z, LABEL_8747

    ; update the fruit's coords
    ld      a, ($4C41)
    ld      b, a
    ld      hl, DATA_8841
    rst     $18
    ; HL = coords offset
    ld      de, ($4DD2)
    add     hl, de
    ld      ($4DD2), hl

    ld      hl, $4C41
    inc     (hl)
    ld      a, (hl)
    and     $0F
    ret     nz

    ld      hl, $4C40
    dec     (hl)
    jp      m, LABEL_87B5

    ld      a, (hl)
    ld      d, a
    srl     a
    srl     a

    ; set fruit bouncing SFX
    ld      hl, $4EBC
    set     5, (hl)

    ld      hl, ($4C42)
    rst     $10
    ld      c, a
    ld      a, 3
    and     d
    jr      z, ++_

_:  srl     c
    srl     c
    dec     a
    jr      nz, -_

_:  ld      a, 3
    and     c
    rlca
    rlca
    rlca
    rlca
    ld      ($4C41), a
    ret

LABEL_8747:
    ; bail out if neither 64 nor 176 pac-dots have been eaten
    ld      a, ($4E0E)
    cp      $40
    jp      z, +_
    cp      $B0
    ret     nz

    ld      hl, $4E0D
    jp      LABEL_875B

_:  ld      hl, $4E0C
LABEL_875B:
    ld      a, (hl)
    and     a
    ret     nz

    inc     (hl)

    ; if we're not at level 7 yet, use a hardcoded fruit
    ld      a, ($4E13)
    cp      $07
    jr      c, ++_

    ; fruit = (R mod 32) mod 7
    ld      b, 7
    ld      a, r
    and     $1F

_:  sub     b
    jr      nc, -_
    add     a, b

    ; load fruit data from lookup table
_:  ld      hl, DATA_879D
    ld      b, a
    add     a, a
    add     a, b
    rst     $10

    ; write sprite #
    ld      ($4C0C), a
    inc     hl

    ; write color
    ld      a, (hl)
    ld      ($4C0D), a
    inc     hl

    ; write score value offset
    ld      a, (hl)
    ld      ($4DD4), a

    ld      hl, DATA_87F8
    call    LABEL_87CD
    inc     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      ($4DD2), de
    ret

LABEL_8793: ; draws fruits on HUD
    ; if we're at level 7 or lower, use the level #
    cp      8
    jp      c, LABEL_2BF9

    ; set to draw every fruit
    ld      a, 7
    jp      LABEL_2BF9

DATA_879D:  ; fruit lookup table
.db $00, $14, $06
.db $01, $0F, $07
.db $02, $15, $08
.db $03, $07, $09
.db $04, $14, $0A
.db $05, $15, $0B
.db $06, $16, $0C
.db $07, $00, $0D

LABEL_87B5:
    ld      a, ($4DD3)
    add     a, $20
    cp      $40
    jr      c, LABEL_8810

    ld      hl, ($4C42)
    ld      de, DATA_8808
    or      a
    sbc     hl, de
    jr      nz, LABEL_87ED

    ld      hl, DATA_8800

LABEL_87CD:
    call    LABEL_94BD

    ld      l, c
    ld      h, b

    ld      a, r
    and     $03
    ld      b, a
    add     a, a
    add     a, a
    add     a, b
    rst     $10

    ld      e, a
    inc     hl
    ld      d, (hl)
    ld      ($4C42), de
    inc     hl

    ld      a, (hl)
LABEL_87E4:
    ld      ($4C40), a
    ld      a, $1F
    ld      ($4C41), a
    ret

LABEL_87ED:
    ld      hl, DATA_8808
    ld      ($4C42), hl
    ld      a, $1D
    jp      LABEL_87E4

DATA_87F8:
    .dw DATA_8B4F ; fruit paths for maze 1
    .dw DATA_8E40 ; fruit paths for maze 2
    .dw DATA_911A ; fruit paths for maze 3
    .dw DATA_940A ; fruit paths for maze 4

DATA_8800:
    .dw DATA_8B82   ; fruit paths for maze 1
    .dw DATA_8E73    ; fruit paths for maze 2
    .dw DATA_9142    ; fruit paths for maze 3
    .dw DATA_943C    ; fruit paths for maze 4

DATA_8808:
    .db $FA, $FF, $55, $55, $01, $80, $AA, $02

LABEL_8810: ; handle fruit exiting the screen
    ld      a, 0
    ld      ($4C0D), a
    jp      LABEL_1000

LABEL_8818: ; handle moving fruit being eaten
    push    af
    ld      de, ($4DD2)

    ; skip if Pac-Man hasn't touched the fruit's hitbox
    ld      a, h
    sub     d
    add     a, 3
    cp      6
    jr      nc, LABEL_883D

    ld      a, l
    sub     e
    add     a, 3
    cp      6
    jr      nc, LABEL_883D

    ; handle eating a fruit
    ld      a, 1
    ld      ($4C0D), a
    pop     af
    add     a, 2
    ld      ($4C0C), a
    sub     a, 2
    jp      LABEL_19B2

LABEL_883D: ; handle not eating a fruit
    pop     af
    jp      LABEL_19CD

DATA_8841:  ; maze 1 fruit movement table
.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.db $FF, $FF, $00, $00, $FF, $FF, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00
.db $00, $00, $FF, $FE, $00, $00, $00, $FF, $00, $00, $FF, $FE, $00, $00, $00, $FF
.db $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $00, $01, $FF, $01, $FF, $00, $00
.db $00, $00, $00, $00, $FF, $00, $00, $00, $00, $01, $00, $00, $FF, $00, $00, $00
.db $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $01, $01, $01, $01
.db $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
.db $01, $00, $01, $00, $01, $00, $01, $00, $FF, $FF, $FF, $FF, $00, $00, $FF, $FF

DATA_88C1:  ; maze 1 tilemap
.db $40, $FC, $D0, $D2, $D2, $D2, $D2, $D4, $FC, $DA, $02, $DC, $FC, $FC, $FC, $FC
.db $FC, $FC, $DA, $02, $DC, $FC, $FC, $FC, $D0, $D2, $D2, $D2, $D2, $D2, $D2, $D2
.db $D4, $FC, $DA, $05, $DC, $FC, $DA, $02, $DC, $FC, $FC, $FC, $FC, $FC, $FC, $DA
.db $02, $DC, $FC, $FC, $FC, $DA, $08, $DC, $FC, $DA, $02, $E6, $EA, $02, $E7, $D2
.db $EB, $02, $E7, $D2, $D2, $D2, $D2, $D2, $D2, $EB, $02, $E7, $D2, $D2, $D2, $EB
.db $02, $E6, $E8, $E8, $E8, $EA, $02, $DC, $FC, $DA, $02, $DE, $E4, $15, $DE, $C0
.db $C0, $C0, $E4, $02, $DC, $FC, $DA, $02, $DE, $E4, $02, $E6, $E8, $E8, $E8, $E8
.db $EA, $02, $E6, $E8, $E8, $E8, $EA, $02, $E6, $EA, $02, $E6, $EA, $02, $DE, $C0
.db $C0, $C0, $E4, $02, $DC, $FC, $DA, $02, $E7, $EB, $02, $E7, $E9, $E9, $E9, $F5
.db $E4, $02, $DE, $F3, $E9, $E9, $EB, $02, $DE, $E4, $02, $DE, $E4, $02, $E7, $E9
.db $E9, $E9, $EB, $02, $DC, $FC, $DA, $09, $DE, $E4, $02, $DE, $E4, $05, $DE, $E4
.db $02, $DE, $E4, $08, $DC, $FC, $FA, $E8, $E8, $EA, $02, $E6, $E8, $EA, $02, $DE
.db $E4, $02, $DE, $E4, $02, $E6, $E8, $E8, $F4, $E4, $02, $DE, $E4, $02, $E6, $E8
.db $E8, $E8, $EA, $02, $DC, $FC, $FB, $E9, $E9, $EB, $02, $DE, $C0, $E4, $02, $E7
.db $EB, $02, $E7, $EB, $02, $E7, $E9, $E9, $F5, $E4, $02, $E7, $EB, $02, $DE, $F3
.db $E9, $E9, $EB, $02, $DC, $FC, $DA, $05, $DE, $C0, $E4, $0B, $DE, $E4, $05, $DE
.db $E4, $05, $DC, $FC, $DA, $02, $E6, $EA, $02, $DE, $C0, $E4, $02, $E6, $EA, $02
.db $EC, $D3, $D3, $D3, $EE, $02, $DE, $E4, $02, $E6, $EA, $02, $DE, $E4, $02, $E6
.db $EA, $02, $DC, $FC, $DA, $02, $DE, $E4, $02, $E7, $E9, $EB, $02, $DE, $E4, $02
.db $DC, $FC, $FC, $FC, $DA, $02, $E7, $EB, $02, $DE, $E4, $02, $E7, $EB, $02, $DE
.db $E4, $02, $DC, $FC, $DA, $02, $DE, $E4, $06, $DE, $E4, $02, $F0, $FC, $FC, $FC
.db $DA, $05, $DE, $E4, $05, $DE, $E4, $02, $DC, $FC, $DA, $02, $DE, $E4, $02, $E6
.db $E8, $E8, $E8, $F4, $E4, $02, $CE, $FC, $FC, $FC, $DA, $02, $E6, $E8, $E8, $F4
.db $E4, $02, $E6, $E8, $E8, $F4, $E4, $02, $DC, $00

DATA_8A3B:  ; maze 1 pac-dot data
.db $62, $02, $01, $13, $01, $01, $01, $02, $01, $04, $03, $13, $06, $04, $03, $01
.db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.db $01, $01, $06, $04, $03, $10, $03, $06, $04, $03, $10, $03, $06, $04, $01, $01
.db $01, $01, $01, $01, $01, $0C, $03, $01, $01, $01, $01, $01, $01, $07, $04, $0C
.db $03, $06, $07, $04, $0C, $03, $06, $04, $01, $01, $01, $04, $0C, $01, $01, $01
.db $03, $01, $01, $01, $04, $03, $04, $0F, $03, $03, $04, $03, $04, $0F, $03, $03
.db $04, $03, $01, $01, $01, $01, $0F, $01, $01, $01, $03, $04, $03, $19, $04, $03
.db $19, $04, $03, $01, $01, $01, $01, $0F, $01, $01, $01, $03, $04, $03, $04, $0F
.db $03, $03, $04, $03, $04, $0F, $03, $03, $04, $01, $01, $01, $04, $0C, $01, $01
.db $01, $03, $01, $01, $01, $07, $04, $0C, $03, $06, $07, $04, $0C, $03, $06, $04
.db $01, $01, $01, $01, $01, $01, $01, $0C, $03, $01, $01, $01, $01, $01, $01, $04
.db $03, $10, $03, $06, $04, $03, $10, $03, $06, $04, $03, $01, $01, $01, $01, $01
.db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $06, $04
.db $03, $13, $06, $04, $02, $01, $13, $01, $01, $01, $02, $01, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00

DATA_8B2C:  ; # of pac-dots in maze 1
.db 224

DATA_8B2D:  ; ghost target tiles for maze 1
.db $1D, $22
.db $1D, $39
.db $40, $20
.db $40, $3B

DATA_8B35:
.dw $4063   ; power pellet upper right
.dw $407C   ; power pellet lower right
.dw $4383   ; power pellet upper left
.dw $439C   ; power pellet lower left

DATA_8B3D:  ; tunnel table for mazes 1 and 2
.db $49, $09, $17, $09, $17, $09, $0E, $E0, $E0, $E0, $29, $09, $17, $09, $17, $09, $00, $00

DATA_8B4F:  ; entrance fruit paths for maze 1
.dw DATA_8B63
.db $13, $94, $0C
.dw DATA_8B68
.db $22, $94, $F4
.dw DATA_8B71
.db $27, $4C, $F4
.dw DATA_8B7B
.db $1C, $4C, $0C

DATA_8B63:
.db $80, $AA, $AA, $BF, $AA
DATA_8B68:
.db $80, $0A, $54, $55, $55, $55, $FF, $5F, $55
DATA_8B71:
.db $EA, $FF, $57, $55, $F5, $57, $FF, $15, $40, $55
DATA_8B7B:
.db $EA, $AF, $02, $EA, $FF, $FF, $AA

DATA_8B82:  ; exit fruit paths for maze 1
.dw DATA_8B94
.db $14, $00, $00
.dw DATA_8B99
.db $17, $00, $00
.dw DATA_8B9F
.db $1A, $00, $00
.dw DATA_8BA6
.db $1D

DATA_8B94:
.db $55, $40, $55, $55, $BF
DATA_8B99:
.db $AA, $80, $AA, $AA, $BF, $AA
DATA_8B9F:
.db $AA, $80, $AA, $02, $80, $AA, $AA
DATA_8BA6:
.db $55, $00, $00, $00, $55, $55, $FD, $AA

DATA_8BAE:  ; maze 2 tilemap
.db $40, $FC, $DA, $02, $DE, $D8, $D2, $D2, $D2, $D2, $D2, $D2, $D2, $D6, $D8, $D2
.db $D2, $D2, $D2, $D4, $FC, $FC, $FC, $FC, $DA, $02, $DE, $D8, $D2, $D2, $D2, $D2
.db $D4, $FC, $DA, $02, $DE, $E4, $08, $DE, $E4, $05, $DC, $FC, $FC, $FC, $FC, $DA
.db $02, $DE, $E4, $05, $DC, $FC, $DA, $02, $DE, $E4, $02, $E6, $E8, $E8, $E8, $EA
.db $02, $DE, $E4, $02, $E6, $EA, $02, $E7, $D2, $D2, $D2, $D2, $EB, $02, $E7, $EB
.db $02, $E6, $EA, $02, $DC, $FC, $DA, $02, $DE, $E4, $02, $DE, $F3, $E9, $E9, $EB
.db $02, $DE, $E4, $02, $DE, $E4, $0C, $DE, $E4, $02, $DC, $FC, $DA, $02, $DE, $E4
.db $02, $DE, $E4, $05, $DE, $E4, $02, $DE, $F2, $E8, $E8, $E8, $EA, $02, $E6, $EA
.db $02, $E6, $E8, $E8, $F4, $E4, $02, $DC, $FC, $DA, $02, $E7, $EB, $02, $DE, $E4
.db $02, $E6, $EA, $02, $E7, $EB, $02, $E7, $E9, $E9, $E9, $E9, $EB, $02, $DE, $E4
.db $02, $E7, $E9, $E9, $E9, $EB, $02, $DC, $FC, $DA, $05, $DE, $E4, $02, $DE, $E4
.db $0C, $DE, $E4, $08, $DC, $FC, $FA, $E8, $E8, $EA, $02, $DE, $E4, $02, $DE, $F2
.db $E8, $E8, $E8, $E8, $EA, $02, $E6, $E8, $E8, $EA, $02, $DE, $F2, $E8, $E8, $EA
.db $02, $E6, $EA, $02, $DC, $FC, $FB, $E9, $E9, $EB, $02, $E7, $EB, $02, $E7, $E9
.db $E9, $E9, $E9, $E9, $EB, $02, $E7, $E9, $F5, $E4, $02, $DE, $F3, $E9, $E9, $EB
.db $02, $DE, $E4, $02, $DC, $FC, $DA, $12, $DE, $E4, $02, $DE, $E4, $05, $DE, $E4
.db $02, $DC, $FC, $DA, $02, $E6, $EA, $02, $E6, $E8, $E8, $E8, $E8, $EA, $02, $EC
.db $D3, $D3, $D3, $EE, $02, $E7, $EB, $02, $E7, $EB, $02, $E6, $EA, $02, $DE, $E4
.db $02, $DC, $FC, $DA, $02, $DE, $E4, $02, $E7, $E9, $E9, $E9, $F5, $E4, $02, $DC
.db $FC, $FC, $FC, $DA, $08, $DE, $E4, $02, $E7, $EB, $02, $DC, $FC, $DA, $02, $DE
.db $E4, $06, $DE, $E4, $02, $F0, $FC, $FC, $FC, $DA, $02, $E6, $E8, $E8, $E8, $EA
.db $02, $DE, $E4, $05, $DC, $FC, $DA, $02, $DE, $F2, $E8, $E8, $E8, $EA, $02, $DE
.db $E4, $02, $CE, $FC, $FC, $FC, $DA, $02, $DE, $C0, $C0, $C0, $E4, $02, $DE, $F2
.db $E8, $E8, $EA, $02, $DC, $00, $00, $00, $00

DATA_8D27:  ; maze 2 pac-dot data
.db $66, $01, $01, $01, $01, $01, $03, $01, $01, $01, $0B, $01, $01, $07, $06, $03 
.db $03, $0A, $03, $07, $06, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01 
.db $01, $03, $07, $03, $01, $01, $01, $03, $07, $03, $06, $07, $03, $03, $03, $07 
.db $03, $06, $07, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $03 
.db $01, $01, $01, $01, $01, $01, $07, $03, $0D, $06, $03, $07, $03, $0D, $06, $03 
.db $04, $01, $01, $01, $01, $01, $01, $0D, $03, $01, $01, $01, $03, $04, $03, $10 
.db $03, $03, $03, $04, $03, $10, $01, $01, $01, $03, $03, $04, $03, $01, $01, $01 
.db $01, $12, $01, $01, $01, $04, $07, $15, $04, $07, $15, $04, $03, $01, $01, $01 
.db $01, $12, $01, $01, $01, $04, $03, $10, $01, $01, $01, $03, $03, $04, $03, $10 
.db $03, $03, $03, $04, $01, $01, $01, $01, $01, $01, $0D, $03, $01, $01, $01, $03 
.db $07, $03, $0D, $06, $03, $07, $03, $0D, $06, $03, $07, $03, $03, $01, $01, $01 
.db $01, $01, $01, $01, $01, $01, $01, $03, $01, $01, $01, $01, $01, $01, $07, $03 
.db $03, $03, $07, $03, $06, $07, $03, $01, $01, $01, $03, $07, $03, $06, $07, $06 
.db $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $03, $07, $06, $03 
.db $03, $0A, $03, $08, $01, $01, $01, $01, $01, $03, $01, $01, $01, $0B, $01, $01

DATA_8E17:  ; # of pac-dots in maze 2
.db 244

DATA_8E18:  ; ghost target tiles for maze 2
.db $1D, $22
.db $1D, $39
.db $40, $20
.db $40, $3B

DATA_8E20:
.dw $4065   ; power pellet upper right
.dw $407B   ; power pellet lower right
.dw $4385   ; power pellet upper left
.dw $439B   ; power pellet lower left

DATA_8E28:  ; tunnel table for maze 3
.db $42, $16, $0A, $16, $0A, $16, $0A, $20, $20, $20, $DE, $E0, $22, $20, $20, $20, $20, $16, $0A, $16, $0A, $16, $00, $00
DATA_8E40:  ; entrance fruit paths for maze 2
.dw DATA_8E54
.db $13, $C4, $0C
.dw DATA_8E59
.db $1E, $C4, $F4
.dw DATA_8E61
.db $26, $14, $F4
.dw DATA_8E6B
.db $1D, $14, $0C

DATA_8E54:
.db $02, $AA, $AA, $80, $2A
DATA_8E59:
.db $02, $40, $55, $7F, $55, $15, $50, $05
DATA_8E61:
.db $EA, $FF, $57, $55, $F5, $FF, $57, $7F, $55, $05
DATA_8E6B:
.db $EA, $FF, $FF, $FF, $EA, $AF, $AA, $02

DATA_8E73:  ; exit fruit paths for maze 2
.dw DATA_8E87
.db $12, $00, $00
.dw DATA_8E8C
.db $1D, $00, $00
.dw DATA_8E94
.db $21, $00, $00
.dw DATA_8E9D
.db $2C, $00, $00

DATA_8E87:
.db $55, $7F, $55, $D5, $FF
DATA_8E8C:
.db $AA, $BF, $AA, $2A, $A0, $EA, $FF, $FF
DATA_8E94:
.db $AA, $2A, $A0, $02, $00, $00, $A0, $AA, $02
DATA_8E9D:
.db $55, $15, $A0, $2A, $00, $54, $05, $00, $00, $55, $FD

DATA_8EA8:  ; maze 3 tilemap
.db $40, $FC, $D0, $D2, $D2, $D2, $D2, $D2, $D2, $D6, $E4, $02, $E7, $D2, $D2, $D2 
.db $D2, $D2, $D2, $D2, $D2, $D2, $D2, $D6, $D8, $D2, $D2, $D2, $D2, $D2, $D2, $D2 
.db $D4, $FC, $DA, $07, $DE, $E4, $0D, $DE, $E4, $08, $DC, $FC, $DA, $02, $E6, $E8 
.db $E8, $EA, $02, $DE, $E4, $02, $E6, $E8, $E8, $EA, $02, $E6, $E8, $E8, $E8, $EA 
.db $02, $E7, $EB, $02, $E6, $EA, $02, $E6, $EA, $02, $DC, $FC, $DA, $02, $DE, $F3 
.db $E9, $EB, $02, $E7, $EB, $02, $E7, $E9, $F5, $E4, $02, $E7, $E9, $E9, $F5, $E4 
.db $05, $DE, $E4, $02, $DE, $E4, $02, $DC, $FC, $DA, $02, $DE, $E4, $09, $DE, $E4 
.db $05, $DE, $E4, $02, $E6, $E8, $E8, $F4, $E4, $02, $DE, $E4, $02, $DC, $FC, $DA 
.db $02, $DE, $E4, $02, $E6, $E8, $E8, $E8, $E8, $EA, $02, $E7, $EB, $02, $E6, $EA 
.db $02, $E7, $EB, $02, $E7, $E9, $E9, $E9, $EB, $02, $E7, $EB, $02, $DC, $FC, $DA 
.db $02, $DE, $E4, $02, $E7, $E9, $E9, $E9, $F5, $E4, $05, $DE, $E4, $0E, $DC, $FC 
.db $DA, $02, $DE, $E4, $06, $DE, $E4, $02, $E6, $E8, $E8, $F4, $E4, $02, $E6, $E8 
.db $E8, $E8, $EA, $02, $E6, $E8, $E8, $E8, $E8, $E8, $F4, $FC, $DA, $02, $E7, $EB 
.db $02, $E6, $E8, $EA, $02, $E7, $EB, $02, $E7, $E9, $E9, $E9, $EB, $02, $DE, $F3 
.db $E9, $E9, $EB, $02, $DE, $F3, $E9, $E9, $E9, $E9, $F5, $FC, $DA, $05, $DE, $C0 
.db $E4, $0B, $DE, $E4, $05, $DE, $E4, $05, $DC, $FC, $FA, $E8, $E8, $EA, $02, $DE 
.db $C0, $E4, $02, $E6, $EA, $02, $EC, $D3, $D3, $D3, $EE, $02, $DE, $E4, $02, $E6 
.db $EA, $02, $DE, $E4, $02, $E6, $EA, $02, $DC, $FC, $FB, $E9, $E9, $EB, $02, $E7 
.db $E9, $EB, $02, $DE, $E4, $02, $DC, $FC, $FC, $FC, $DA, $02, $E7, $EB, $02, $DE 
.db $E4, $02, $E7, $EB, $02, $DE, $E4, $02, $DC, $FC, $DA, $09, $DE, $E4, $02, $F0 
.db $FC, $FC, $FC, $DA, $05, $DE, $E4, $05, $DE, $E4, $02, $DC, $FC, $DA, $02, $E6 
.db $E8, $E8, $E8, $E8, $EA, $02, $DE, $E4, $02, $CE, $FC, $FC, $FC, $DA, $02, $E6 
.db $E8, $E8, $F4, $E4, $02, $E6, $E8, $E8, $F4, $E4, $02, $DC, $00, $00, $00, $00

DATA_9018:  ; maze 3 pac-dot data
.db $62, $01, $02, $01, $01, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.db $01, $04, $01, $01, $01, $01, $01, $04, $05, $03, $0B, $03, $03, $03, $04, $05
.db $03, $0B, $01, $01, $01, $03, $03, $04, $03, $01, $01, $01, $01, $01, $0B, $06
.db $03, $04, $03, $10, $06, $03, $04, $03, $10, $01, $01, $01, $01, $01, $01, $01
.db $01, $01, $04, $03, $01, $01, $01, $01, $0F, $0A, $03, $04, $0F, $0A, $01, $01
.db $01, $04, $0C, $01, $01, $01, $03, $01, $01, $01, $07, $04, $0C, $03, $03, $03
.db $07, $04, $0C, $03, $03, $03, $04, $01, $01, $01, $01, $01, $01, $01, $0C, $03
.db $01, $01, $01, $03, $04, $07, $15, $04, $07, $15, $04, $01, $01, $01, $01, $01
.db $01, $01, $0C, $03, $01, $01, $01, $03, $07, $04, $0C, $03, $03, $03, $07, $04
.db $0C, $03, $03, $03, $04, $01, $01, $01, $04, $0C, $01, $01, $01, $03, $01, $01
.db $01, $04, $03, $04, $0F, $0A, $03, $01, $01, $01, $01, $0F, $0A, $03, $10, $01
.db $01, $01, $01, $01, $01, $01, $01, $01, $04, $03, $10, $06, $03, $04, $03, $01
.db $01, $01, $01, $01, $0B, $06, $03, $04, $05, $03, $0B, $01, $01, $01, $03, $03
.db $04, $05, $03, $0B, $03, $03, $03, $04, $01, $02, $01, $01, $03, $01, $01, $01
.db $01, $01, $01, $01, $01, $01, $01, $01, $04, $01, $01, $01, $01, $01, $00, $00
.db $00

DATA_9109:  ; # of pac-dots in maze 3
.db 242

DATA_910A:  ; ghost target tiles for maze 3
.db $40, $2D
.db $1D, $22
.db $1D, $39
.db $40, $20

DATA_9112:
.dw $4064   ; power pellet upper right
.dw $4078   ; power pellet lower right
.dw $4384   ; power pellet upper left
.dw $4398   ; power pellet lower left

DATA_911A:  ; entrance fruit paths for maze 3
.dw DATA_912E
.db $15, $54, $0C
.dw DATA_9134
.db $1E, $54, $F4
.dw DATA_9134
.db $1E, $54, $F4
.dw DATA_913C
.db $15, $54, $0C

DATA_912E:
.db $EA, $FF, $AB, $FA, $AA, $AA
DATA_9134:
.db $EA, $FF, $57, $55, $55, $D5, $57, $55
DATA_913C:
.db $AA, $AA, $BF, $FA, $BF, $AA

DATA_9142:  ; exit fruit paths for maze 3
.dw DATA_9156
.db $22, $00, $00
.dw DATA_915F
.db $25, $00, $00
.dw DATA_915F
.db $25, $00, $00
.dw DATA_916F
.db $28, $00, $00

DATA_9156:
.db $05, $00, $00, $54, $05, $54, $7F, $F5, $0B
DATA_915F:
.db $0A, $00, $00, $A8, $0A, $A8, $BF, $FA, $AB, $AA, $AA, $82, $AA, $00, $A0, $AA
DATA_916F:
.db $55, $41, $55, $00, $A0, $02, $40, $F5, $57, $BF

DATA_9179:  ; maze 4 tilemap
.db $40, $FC, $D0, $D2, $D2, $D2, $D2, $D2, $D2, $D2, $D2, $D4, $FC, $FC, $DA, $02
.db $DE, $E4, $02, $DC, $FC, $FC, $FC, $FC, $D0, $D2, $D2, $D2, $D2, $D2, $D2, $D2
.db $D4, $FC, $DA, $09, $DC, $FC, $FC, $DA, $02, $DE, $E4, $02, $DC, $FC, $FC, $FC
.db $FC, $DA, $08, $DC, $FC, $DA, $02, $E6, $E8, $E8, $E8, $E8, $EA, $02, $E7, $D2
.db $D2, $EB, $02, $DE, $E4, $02, $E7, $D2, $D2, $D2, $D2, $EB, $02, $E6, $E8, $E8
.db $E8, $EA, $02, $DC, $FC, $DA, $02, $E7, $E9, $E9, $E9, $F5, $E4, $07, $DE, $E4
.db $09, $DE, $F3, $E9, $E9, $EB, $02, $DC, $FC, $DA, $06, $DE, $E4, $02, $E6, $EA
.db $02, $E6, $E8, $F4, $F2, $E8, $EA, $02, $E6, $E8, $E8, $EA, $02, $DE, $E4, $05
.db $DC, $FC, $DA, $02, $E6, $E8, $EA, $02, $E7, $EB, $02, $DE, $E4, $02, $E7, $E9
.db $E9, $E9, $E9, $EB, $02, $E7, $E9, $F5, $E4, $02, $E7, $EB, $02, $E6, $EA, $02
.db $DC, $FC, $DA, $02, $DE, $C0, $E4, $05, $DE, $E4, $0B, $DE, $E4, $05, $DE, $E4
.db $02, $DC, $FC, $DA, $02, $DE, $C0, $E4, $02, $E6, $E8, $E8, $F4, $F2, $E8, $E8
.db $EA, $02, $E6, $E8, $E8, $E8, $EA, $02, $DE, $E4, $02, $E6, $E8, $E8, $F4, $E4
.db $02, $DC, $FC, $DA, $02, $E7, $E9, $EB, $02, $E7, $E9, $E9, $F5, $F3, $E9, $E9
.db $EB, $02, $E7, $E9, $E9, $F5, $E4, $02, $E7, $EB, $02, $E7, $E9, $E9, $F5, $E4
.db $02, $DC, $FC, $DA, $09, $DE, $E4, $08, $DE, $E4, $08, $DE, $E4, $02, $DC, $FC
.db $DA, $02, $E6, $E8, $E8, $E8, $E8, $EA, $02, $DE, $E4, $02, $EC, $D3, $D3, $D3
.db $EE, $02, $DE, $E4, $02, $E6, $E8, $E8, $E8, $EA, $02, $DE, $E4, $02, $DC, $FC
.db $DA, $02, $DE, $F3, $E9, $E9, $E9, $EB, $02, $E7, $EB, $02, $DC, $FC, $FC, $FC
.db $DA, $02, $E7, $EB, $02, $E7, $E9, $E9, $F5, $E4, $02, $E7, $EB, $02, $DC, $FC
.db $DA, $02, $DE, $E4, $09, $F0, $FC, $FC, $FC, $DA, $08, $DE, $E4, $05, $DC, $FC
.db $DA, $02, $DE, $E4, $02, $E6, $E8, $E8, $E8, $E8, $EA, $02, $CE, $FC, $FC, $FC
.db $DA, $02, $E6, $E8, $E8, $E8, $EA, $02, $DE, $E4, $02, $E6, $E8, $E8, $F4, $00
.db $00, $00, $00

DATA_92EC:  ; maze 4 pac-dot data
.db $62, $01, $02, $01, $01, $01, $01, $0F, $01, $01, $01, $02, $01, $04, $07, $0F
.db $06, $04, $07, $01, $01, $01, $07, $01, $01, $01, $01, $01, $06, $04, $01, $01
.db $01, $01, $03, $03, $07, $05, $03, $01, $01, $01, $04, $04, $03, $03, $07, $05
.db $03, $03, $04, $04, $01, $01, $01, $03, $01, $01, $01, $01, $01, $01, $01, $01
.db $01, $03, $01, $01, $01, $03, $04, $04, $0F, $03, $06, $04, $04, $0F, $03, $06
.db $04, $01, $01, $01, $01, $01, $01, $01, $0C, $01, $01, $01, $01, $01, $01, $03
.db $04, $07, $12, $03, $04, $07, $12, $03, $04, $03, $01, $01, $01, $01, $12, $01
.db $01, $01, $04, $03, $16, $07, $03, $16, $07, $03, $01, $01, $01, $01, $12, $01
.db $01, $01, $04, $07, $12, $03, $04, $07, $12, $03, $04, $01, $01, $01, $01, $01
.db $01, $01, $0C, $01, $01, $01, $01, $01, $01, $03, $04, $04, $0F, $03, $06, $04
.db $04, $0F, $03, $06, $04, $04, $01, $01, $01, $03, $01, $01, $01, $01, $01, $01
.db $01, $01, $01, $03, $01, $01, $01, $03, $04, $04, $03, $03, $07, $05, $03, $03
.db $04, $01, $01, $01, $01, $03, $03, $07, $05, $03, $01, $01, $01, $04, $07, $01
.db $01, $01, $07, $01, $01, $01, $01, $01, $06, $04, $07, $0F, $06, $04, $01, $02
.db $01, $01, $01, $01, $0F, $01, $01, $01, $02, $01, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

DATA_93F9:  ; # of pac-dots in maze 4
.db 238

DATA_93FA:
.dw $4064   ; power pellet upper right
.dw $407C   ; power pellet lower right
.dw $4384   ; power pellet upper left
.dw $439C   ; power pellet lower left

DATA_9402:  ; ghost target tiles for maze 4
.db $1D, $22
.db $40, $20
.db $1D, $39
.db $40, $3B

DATA_940A:  ; entrance fruit paths for maze 4
.dw DATA_941E
.db $14, $8C, $0C
.dw DATA_9423
.db $1D, $8C, $F4
.dw DATA_942B
.db $2A, $74, $F4
.dw DATA_9436
.db $15, $74, $0C

DATA_941E:
.db $80, $AA, $BE, $FA, $AA
DATA_9423:
.db $00, $50, $FD, $55, $F5, $D5, $57, $55
DATA_942B:
.db $EA, $FF, $57, $D5, $5F, $FD, $15, $50, $01, $50, $55
DATA_9436:
.db $EA, $AF, $FE, $2A, $A8, $AA

DATA_943C:  ; exit fruit paths for maze 4
.dw DATA_9450
.db $15, $00, $00
.dw DATA_9456
.db $18, $00, $00
.dw DATA_945C
.db $19, $00, $00    
.dw DATA_9463
.db $1C, $00, $00

DATA_9450:
.db $55, $50, $41, $55, $FD, $AA
DATA_9456:
.db $AA, $A0, $82, $AA, $FE, $AA
DATA_945C:
.db $AA, $AF, $02, $2A, $A0, $AA, $AA
DATA_9463:
.db $55, $5F, $01, $00, $50, $55, $BF

LABEL_946A: ; select a maze
    ld      hl, DATA_9474
    call    LABEL_94BD
    ld      hl, $4000
    ret

DATA_9474:  ; maze tilemap lookup table
.dw DATA_88C1   ; maze 1
.dw DATA_8BAE   ; maze 2
.dw DATA_8EA8   ; maze 3
.dw DATA_9179   ; maze 4

LABEL_947C: ; load pellet data
    ld      hl, LABEL_2453
    jr      +_

LABEL_9481:
    ld      hl, LABEL_2492
_:  push    hl
    ld      hl, DATA_9499
    call    LABEL_94BD
    ld      iy, 0
    add     iy, bc
    ld      hl, $4000
    ld      ix, $4E16
    ret

DATA_9499:  ; pac-dot data lookup table
.dw DATA_8A3B    ; pac-dots for maze 1
.dw DATA_8D27    ; pac-dots for maze 2
.dw DATA_9018    ; pac-dots for maze 3
.dw DATA_92EC    ; pac-dots for maze 4

LABEL_94A1: ; check if every pac-dot has been eaten
    push    bc
    ld      hl, DATA_94B5
    call    LABEL_94BD
    ld      a, (bc)
    ld      b, a
    ld      a, ($4E0E)
    cp      b
    pop     bc
    jp      nz, LABEL_8EB
    jp      LABEL_8E5

DATA_94B5:  ; pac-dot number lookup table
.dw DATA_8B2C   ; # of pellets in maze 1
.dw DATA_8E17   ; # of pellets in maze 2
.dw DATA_9109   ; # of pellets in maze 3
.dw DATA_93F9   ; # of pellets in maze 4

LABEL_94BD: ; calc maze data based on level number
    ld      a, ($4E13)
    push    hl
    cp      $0D
    jp      p, LABEL_94D4

LABEL_94C6:
    ld      hl, DATA_94DF
    rst     $10
    pop     hl

    add     a, a
    ld      c, a
    ld      b, 0
    add     hl, bc
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    ret

LABEL_94D4:
    sub     13
_:  sub     8
    jp      p, -_

    add     a, 13
    jr      LABEL_94C6

DATA_94DF:  ; maze order
.db 0, 0                  ; 1st & 2nd boards use maze 1
.db 1, 1, 1               ; 3rd, 4th, 5th boards use maze 2
.db 2, 2, 2, 2            ; boards 6 through 9 use maze 3
.db 3, 3, 3, 3            ; boards 10 through 13 use maze 4

LABEL_94EC: ; draw power pellets in Ms. Pac
    ld      hl, DATA_951C
    call    LABEL_94BD
    ld      de, $4E34
    ld      l, c
    ld      h, b

    ; draw 1 pellet each loop
_:  ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      a, (de)
    ld      (bc), a
    inc     de
    ld      a, 3
    and     e
    jr      nz, -_
    ret

LABEL_9504: ; save power pellets in Ms. Pac
    ld      hl, DATA_951C
    call    LABEL_94BD
    ld      de, $4E34
    ld      l, c
    ld      h, b

    ; draw 1 pellet each loop
_:  ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      a, (bc)
    ld      (de), a
    inc     de
    ld      a, 3
    and     e
    jr      nz, -_
    ret

DATA_951C:
.dw DATA_8B35    ; maze 1 power pellets table
.dw DATA_8E20    ; maze 2 power pellets table
.dw DATA_9112    ; maze 3 power pellets table
.dw DATA_93FA    ; maze 4 power pellets table

LABEL_9524: ; flash power pellets
    push    bc
    push    de
    ld      hl, DATA_951C
    call    LABEL_94BD
    ld      h, b
    ld      l, c

    ; write 1st pellet palette byte
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    set     2, h

    ld      a, ($447E)
    cp      (hl)
    jr      nz, +_

    ld      a, 0

_:  call    UpdateTilePalette
    ex      de, hl
    inc     hl

    ; write 2nd pellet palette byte
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    set     2, d

    ex      de, hl
    call    UpdateTilePalette
    ex      de, hl

    inc     hl

    ; write 3rd pellet palette byte
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    set     2, d
    
    ex      de, hl
    call    UpdateTilePalette
    ex      de, hl

    inc     hl

    ; write 4th pellet palette byte
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    set     2, d

    ex      de, hl
    call    UpdateTilePalette
    ex      de, hl

    pop     de
    pop     bc
    ld      a, $10
    cp      (hl)
    ret

LABEL_9559:     ; handle getting a random target tile for Inky
    ld      a, ($4D2E)
    jr      LABEL_9561

LABEL_955E:     ; handle getting a random target tile for Clyde
    ld      a, ($4D2F)
LABEL_9561:
    push    af
    push    bc
    push    hl

    ld      hl, DATA_9578
    call    LABEL_94BD

    ld      l, c
    ld      h, b
    ld      a, r
    and     $06
    rst     $10

    ld      e, a
    inc     hl
    ld      d, (hl)
    pop     hl
    pop     bc
    pop     af
    ret

DATA_9578:  ; ghost target tile lookup table
.dw DATA_8B2D    ; 1st maze
.dw DATA_8E18    ; 2nd maze
.dw DATA_910A    ; 3rd maze
.dw DATA_9402    ; 4th maze

LABEL_9580: ; handle maze palette
    jp      z, UpdateMazePalette

    ; skip if we're not in the demo
    ld      a, ($4E02)
    and     a
    jr      z, LABEL_9590

    cp      $10
    ld      a, 1
    jp      nz, LABEL_24E1

LABEL_9590:
    ld      a, ($4E13)
    cp      $15
    jp      p, LABEL_95A3

LABEL_9598:
    ld      c, a
    ld      b, 0
    ld      hl, DATA_95AE
    add     hl, bc

    ld      a, (hl)
    ld      (CurrentPalette), a

    push    ix
    exx
    call.lil ConvertPaletteLIL + romStart
    exx
    pop     ix

    ld      a, (CurrentPalette)
    jp      LABEL_24E1

LABEL_95A3:
    sub     $15
_:  sub     $10
    jp      p, -_
    add     a, $15
    jr      LABEL_9598

UpdateMazePalette:
    ld      a, (CurrentPalette)
    ld      e, a
    ld      d, 8
    mlt     de
    ld.lil  hl, mpLcdPalette
    add.lil hl, de
    ex.lil  de, hl
    ld.lil  hl, mpLcdPalette + (31*2*4)
    ld      bc, 4*2
    ldir.lil
    ld      a, $1F
    jp      LABEL_24E1

CurrentPalette:
    .db 0


DATA_95AE:  ; maze palette lookup table
.db $1D, $1D                 ; color code for levels 1 and 2
.db $16, $16, $16            ; color code for levels 3 - 5
.db $14, $14, $14, $14       ; color code for levels 6 - 9
.db $07, $07, $07, $07       ; color code for levels 10 - 13
.db $18, $18, $18, $18       ; color code for levels 14 - 17
.db $1D, $1D, $1D, $1D       ; color code for levels 18 - 21

LABEL_95C3: ; set tunnel palette
    ld      a, ($4E13)
    cp      3
    jp      p, LABEL_2534

    ld      hl, DATA_95DF
    call    LABEL_94BD

    ld      hl, $4400
LABEL_95D4:
    ld      a, (bc)
    inc     bc
    and     a
    jp      z, LABEL_2534

    rst     $10
    set     6, (hl)
    jr      LABEL_95D4

DATA_95DF:
.dw DATA_8B3D   ; tunnel data table for mazes 1 and 2
.dw DATA_8E28   ; tunnel data table for maze 3

LABEL_95E3:     ; supplants task 1C - draw text/graphics
    ld      a, b

    ; if B = 0A, draw Ms. Pac-Man graphic
    cp      $0A
    call    z, LABEL_960B

    ; if B = 0B, draw Midway graphic
    cp      $0B
    call    z, LABEL_95F6

    ; if B = 06, clear intermission indicator
    cp      $06
    call    z, LABEL_963C

    ; otherwise, draw text
    jp      LABEL_2C5E

LABEL_95F6: ; draw Midway graphic
    push    bc
    push    hl
    call    LABEL_9642
    pop     hl
    pop     bc
    ; FALL THROUGH
LABEL_95FD: ; check dip switches if extra lives are enabled
    ld      a, (DIPSwitch)
    and     $30
    cp      $30
    ld      a, b
    ret     nz

    ld      a, $20
    ld      b, $20
    ret

LABEL_960B: ; draw Ms. Pac-Man graphic
    push    bc
    push    hl
    ld      hl, DATA_9616
    call    LABEL_9627
    pop     hl
    pop     bc
    ret

DATA_9616:  ; data for Ms. Pac-Man graphic
.db $09, $20 
.dw $41F5

.db $09, $21 
.dw $4215

.db $09, $22 
.dw $41F6

.db $09, $23 
.dw $4216
.db $FF

LABEL_9627: ; draw Ms. Pac-Man graphic loop
    ld      a, (hl)
    cp      $FF
    ret     z

    ld      b, a
    inc     hl
    ld      a, (hl)
    inc     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (de), a
    ld      a, b
    set     2, d
    ld      (de), a
    inc     hl
    jr      LABEL_9627

    ret

LABEL_963C: ; clear intermission indicator
    ld      a, 0
    ld      ($4F00), a
    ret

LABEL_9642:
    ; insert tasks
    rst     $28
    .db     $1C, $13
    rst     $28
    .db     $1C, $35

    ; draw the intro screen
    ld      hl, $429A
    ld      a, $BF
    and     a
    ld      de, $001D
    ld      bc, $0400

    ; TODO: this can 100% be optimized
_:  ld      (hl), a
    add     hl, bc
    ld      (hl), 1
    sbc     hl, bc
    inc     hl
    sub     4

    ld      (hl), a
    add     hl, bc
    ld      (hl), 1
    sbc     hl, bc
    inc     hl
    sub     4

    ld      (hl), a
    add     hl, bc
    ld      (hl), 1
    sbc     hl, bc
    inc     hl
    sub     4

    ld      (hl), a
    add     hl, bc
    ld      (hl), 1
    sbc     hl, bc
    add     hl, de
    add     a, $0B
    cp      $BB
    jr      nz, -_
    ret

DATA_967D:  ; channel 2 song data
.dw DATA_9695    ; startup song
.dw DATA_96D6    ; act 1 song
.dw DATA_3C58    ; act 2 song
.dw DATA_974F    ; act 3 song

DATA_9685:  ; channel 1 song data
.dw DATA_96BD    ; startup song
.dw DATA_9719    ; act 1 song
.dw DATA_3BD4    ; act 2 song
.dw DATA_9772    ; act 3 song

DATA_968D:  ; channel 3 song data
.dw DATA_9796
.dw DATA_9796
.dw DATA_9796
.dw DATA_9796

DATA_9695:  ; startup song (channel 2)
.db $F1, $00, $F2, $02, $F3, $0A, $F4, $00
.db $41, $43, $45
.db $86, $8A, $88, $8B
.db $6A, $6B, $71, $6A, $88, $8B
.db $6A, $6B, $71, $6A, $6B, $71, $73, $75
.db $96, $95, $96, $FF

DATA_96BD:  ; startup song (channel 1)
.db $F1, $02, $F2, $03, $F3, $0A, $F4, $02, $50, $70, $86, $90, $81, $90, $86, $90
.db $68, $6A, $6B, $68, $6A, $68, $66, $6A, $68, $66, $65, $68, $86, $81, $86, $FF

DATA_96D6:  ; song for "THEY MEET" (channel 2)
.db $F1, $00, $F2, $02, $F3, $0A, $F4, $00, $69, $6B, $69, $86, $61, $64, $65, $86
.db $86, $64, $66, $64, $61, $69, $6B, $69, $86, $61, $64, $64, $A1, $70, $71, $74
.db $75, $35, $76, $30, $50, $35, $76, $30, $50, $54, $56, $54, $51, $6B, $69, $6B
.db $69, $6B, $91, $6B, $69, $66, $F2, $01, $74, $76, $74, $71, $74, $71, $6B, $69
.db $A6, $A6, $FF

DATA_9719:  ; song for "THEY MEET" (channel 1)
.db $F1, $03, $F2, $03, $F3, $0A, $F4, $02, $70, $66, $70, $46, $50, $86, $90, $70
.db $66, $70, $46, $50, $86, $90, $70, $66, $70, $46, $50, $86, $90, $70, $61, $70
.db $41, $50, $81, $90, $F4, $00, $A6, $A4, $A2, $A1, $F4, $01, $86, $89, $8B, $81
.db $74, $71, $6B, $69, $A6, $FF

DATA_974F:  ; song for "JUNIOR" (channel 2)
.db $F1, $00, $F2, $02, $F3, $0A, $F4, $00, $65, $64, $65, $88, $67, $88, $61, $63
.db $64, $85, $64, $85, $6A, $69, $6A, $8C, $75, $93, $90, $91, $90, $91, $70, $8A
.db $68, $71, $FF

DATA_9772:  ; song for "JUNIOR" (channel 1)
.db $F1, $02, $F2, $03, $F3, $0A, $F4, $02, $65, $90, $68, $70, $68, $67, $66, $65
.db $90, $61, $70, $61, $65, $68, $66, $90, $63, $90, $86, $90, $85, $90, $85, $70
.db $86, $68, $65, $FF

DATA_9796:  ; null (channel 3)
.db $FF

LABEL_9797:
    ld      a, ($4F00)
    cp      0
    jr      z, +_

    ld      de, $4C02
    ld      hl, $4F50
    ld      bc, 12
    ldir

_:  ld      a, ($4E09)
    ld      hl, $4E72
    and     (hl)
    jr      z, +_

    ld      a, ($4C0A)
    cp      $3F
    jr      nz, +_

    ld      a, $FF
    ld      ($4C0A), a

_:  ld      hl, DATA_9685
    jp      LABEL_2CC4

HandleInterrupt_MsPac:
    push    af
    call    CheckForBusywait
    pop     af
    jp      HandleInterrupt

CheckForBusywait:
    ; do a normal interrupt if we're not in the intro
    push    hl
    ld      hl, ($4E00)
    dec     l
    pop     hl
    ret     nz

    ; do a normal interrupt if the demo's playing
    push    hl
    ld      hl, $4E02
    bit     4, (hl)
    pop     hl
    ret     nz

    ; busywait for 171 scanlines so the intro doesn't flicker
    push    af 
_:  ld.lil  a, (mpLcdUPCURR + 1)
    cp      171
    jr      nz, -_
    pop     af
    ret

.db "GENERAL COMPUTER"
.db "  CORPORATION   "
.db "Hello, Nakamura!"