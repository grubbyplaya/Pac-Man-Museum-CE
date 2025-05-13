.ASSUME ADL=0

ApplyPatches:
    call    ApplyStringPatches
    call    ApplyMiniPatches

    ld      hl, NewFruitTable
    ld      de, DATA_3B08
    ld      bc, 14
    ldir
    
    jp      EntryPoint

ApplyStringPatches: ; patches the strings
    ld      hl, PatchStringTable
    ld      de, DATA_36A5
    ld      bc, PATCH_3786 - PatchStringTable
    ldir
    ret

ApplyMiniPatches:   ; applies U5's patches onto the Pac-Man CE port
    ld      hl, Patches
    ld      ix, Patch_Addresses
    ld      b, (Patches_End - Patch_Addresses)/2

_:  push    bc
    ld      de, (ix)
    ld      bc, 8
    ldir
    pop     bc
    lea     ix, ix + 2
    djnz    -_

    ; load Ms. Pac art data
    ld.lil  hl, MsArtHeader + romStart
    ld.lil  (LoadArt + romStart), hl

    ; update the size of the art appvar header
    ld      hl, $0014
    ld      (HeaderSize), hl

    ; update int vector
    ld      hl, HandleInterrupt_MsPac
    ld      (RST_38 + 1), hl

    ; update the demo's autoplay state
    ld      a, $10
    ld      (DemoScrollState), a
    ret

MsArtHeader:
    .db $15, "MsPacArt", 0

Patch_Addresses:
.dw Patch01
.dw Patch02
.dw Patch03
.dw Patch04
.dw Patch05
.dw Patch06
.dw Patch07
.dw Patch08
.dw Patch09
.dw Patch0A
.dw Patch0B
.dw Patch0C
.dw Patch0D
.dw Patch0E
.dw Patch0F
.dw Patch10
.dw Patch11
.dw Patch12
.dw Patch13
.dw Patch14
.dw Patch15
.dw Patch16
.dw Patch17
.dw Patch18
.dw Patch19
.dw Patch1A
.dw Patch1B
.dw Patch1C
.dw Patch1D
.dw Patch1E
.dw Patch1F
.dw Patch20
.dw Patch21
.dw Patch22
.dw Patch23
.dw Patch24
.dw Patch25
.dw Patch26
.dw Patch27
.dw Patch28
Patches_End:

Patches:
    ; overlay - $0410
    .db     $4E
    inc     (hl)
    ret

    jp      LABEL_3E5C
    rst     $20
    ld      e, a

    ; overlay - $08E0
    .db     $4E
    jp      LABEL_94A1
    nop
    ld      hl, $4E04

    ; overlay - $0A30
    .ORG    Patch03
    ld      ($4EBC), a
    jr      LABEL_A3B
    ld      ($4ECC), a

    ; overlay - $0BD0
    .db     $09, $07
    dec     (iy)
    ret
    ld      b, $19

    ; overlay - $0C20
    .db     $44
    jp      LABEL_9524
    jr      nz, $+4
    ld      a, 0

    ; overlay - $0E58
    and     a
    sbc     hl, de
    ret     nz
    xor     a
    nop
    inc     a
    .db     $32

    ; overlay - $0EA8
    and     (hl)
    set     0, a
    ld      (hl), a
    ret
    jp      LABEL_86EE

    ; overlay - $1000
    xor     a
    ld      ($4DD4), a
    ret
    .db     $00, $00
    ; overlay - $1008
    ld      ($4DD2), hl
    ret
    jp      LABEL_3678
    .db     $3A, $00

    ; overlay - $1288
    ld      ($4DD1), a
    ld      hl, $4EAC
    set     6, (hl)

    ; overlay - $1348
    .db     $4E
    ld      (hl), 0
    ld      a, $3E
    ld      de, $0159

    ; overlay - $1688
    .db     $36, $0D, $1E
    ret
    jp      LABEL_869C
    ret

    ; overlay - $16B0
    ret
    jp      LABEL_86B1
    ret
    rlca
    cp      $06

    ; overlay - $16D8
    .db     $4D
    jp      LABEL_86C5
    ret
    jr      c, $+10
    .db     $1E

    ; overlay - $16F8
    .dw     $4D08
    jp      LABEL_86D9
    ret
    jr      c, $+7

    ; overlay - $19A8
    .dw     $4D08
    ld      de, $8094
    jp      LABEL_8818

    ; overlay - $19B8
    .ORG    Patch11

    call    LABEL_1000
    jr      LABEL_19C4
    .db     $1C, $CD, LABEL_42 & $FF

    ; overlay - $2060
    jp      LABEL_366F
    nop
    ld      (bc), a
    ret

    xor     a
    ld      (bc), a

    ; overlay - $2108
    jp      LABEL_3435
    rst     $20
    ; partial jump table
    .dw     LABEL_211A
    .dw     LABEL_2140

    ; overlay - $21A0
    .fill   5, 0
    jp      LABEL_344F

    ; overlay - $2298
    .dw     $4E08
    jp      LABEL_3469

    cp      (hl)
    .db     $22, $0C

    ; overlay - $23E0
    .dw     LABEL_95E3
    .dw     LABEL_2BA1
    .dw     LABEL_2675
    .dw     LABEL_26B2    

    ; overlay - $2418
    ret
    ld      hl, $4000
    call    LABEL_946A
    ld      a, (bc)

    ; overlay - $2448
    ld      hl, $4000
    jp      LABEL_947C
    ld      c, (hl)
    .db     $FD

    ; overlay - $2470
    .dw     $4E34
    jp      LABEL_94EC
    ldi
    .db     $11

    ; overlay - $2488
    .dw     $4000
    jp      LABEL_9481
    ld      c, (hl)
    .db     $FD, $21

    ; overlay - $24B0
    .db     $E5
    ld      hl, $4064
    jp      LABEL_9504
    .db     $ED

    ; overlay - $24D8
    ld      a, b
    cp      $02
    ld      a, $1F
    jp      LABEL_9580

    ; overlay - $24F8
    .db     $1A
    jp      LABEL_95C3
    ld      b, 6
    .db     $DD, $21

    ; overlay - $2748
    ld      a, ($4D2C)
    call    LABEL_9561
    .db     $CD, LABEL_2966 & $FF

    ; overlay - $2780
    .db     $4D
    call    LABEL_9561
    call    LABEL_2966
    .db     $22

    ; overlay - $27B8
    ld      hl, ($4D0E)
    call    LABEL_9559
    .db     $11, $40

    ; overlay - $2800
    ld      hl, ($4D10)
    call    LABEL_955E
    .db     $11, $40

    ; overlay - $2B20 (point table)
    .db $08     ; 800
    .dw $1600   ; 1600
    .dw $1000   ; 1000
    .dw $2000   ; 2000
    .db $00

    ; overlay - $2B30 (point table)
    .db $50     ; 5000
    .dw $5000   ; 5000

    inc     de
    ld      l, e
    ld      h, d
    dec     de

    .db     $CB

    ; overlay - $2BF0
    ld      a, ($4E13)
    inc     a
    jp      LABEL_8793
    .db     $2E

    ; overlay - $2CC0
    .db     $D2
    jp      LABEL_9797
    ld      ix, $4ECC

    ; overlay - $2CD8
    .dw     $4E91
    ld      hl, DATA_967D
    .db     $DD, $21, $DC

    ; overlay - $2CF0
    ld      ($4E96), a
    ld      hl, DATA_968D
    .db     $DD, $21

    ; overlay - $2D60
    .db     $73, $02
    jp      LABEL_364E
    inc     c
    .db     $DD, $35

.ORG Patches + (8*40)

PatchStringTable:
.dw DATA_3713
.dw DATA_3723
.dw DATA_3732
.dw DATA_3741
.dw DATA_3751
.dw DATA_376A
.dw DATA_377A
.dw PATCH_3786
.dw PATCH_379D
.dw PATCH_37B1
.dw PATCH_3D21
.dw PATCH_3D00
.dw PATCH_37FD
.dw PATCH_3D67
.dw PATCH_3DE3
.dw PATCH_3D86
.dw PATCH_3E02
.dw DATA_384C
.dw DATA_385A
.dw PATCH_3D3C
.dw DATA_3D57
.dw PATCH_3DD3
.dw PATCH_3D76
.dw PATCH_3DF2
.dw 1, 2, 3
.dw DATA_38BC
.dw PATCH_38C4
.dw DATA_38CE
.dw DATA_38D8
.dw DATA_38E2
.dw DATA_38EC
.dw DATA_38F6
.dw DATA_3900
.dw DATA_390A
.dw DATA_391A
.dw DATA_396F
.dw DATA_392A
.dw DATA_3958
.dw DATA_3941
.dw PATCH_3E11
.dw DATA_3986
.dw DATA_3997
.dw DATA_39B0
.dw DATA_39BD
.dw DATA_39CA
.dw PATCH_3DA5
.dw PATCH_3E21
.dw PATCH_3DC6
.dw PATCH_3E40
.dw PATCH_3D95
.dw PATCH_3E11
.dw PATCH_3DB4
.dw PATCH_3E30
.dw NullCredit

PATCH_3786:
    .dw $02ED
    .db "PUSH@START@BUTTON", $2F
    .db $87, $2F, $80

PATCH_379D:
    .dw $02AF
    .db "1@PLAYER@ONLY@", $2F
    .db $87, $2F, $80

PATCH_37B1:
    .dw $02AF
    .db "1@OR@2@PLAYERS", $2F
    .db $87, $0, $2F

PATCH_37FD:
    .dw $0365
    .db "@@@@@@@@&MS@PAC;MAN'@", $2F
    .db $87, $2F, $80

PATCH_38C4:
    .dw $026E
    .db "SUPER@PAC;MAN", $2F
    .db $89, $2F, $80

PATCH_38D5:
    .dw $802F
    .db "MAN", $2F
    .db $89, $2F, $80

PATCH_3D00:
    .dw $0396
    .db "@ADDITIONAL@@@@AT@@@000@]^_", $2F
    .db $95, $2F, $80

PATCH_3D21:
    .dw $025A
    .db "@@@@@@@", $2F
    .db $7, $7, $7

PATCH_3D3C:
    .dw $025B
    .db $5C, "@MIDWAY@MFG@CO@@@@", $2F
    .db $81, $2F, $80

PATCH_3D67:
    .dw $026E
    .db "@@@BLINKY", $2F
    .db $81, $2F, $80

PATCH_3D76:
    .dw $02C8
    .db ";KILLER@@@", $2F
    .db $83, $2F, $80

PATCH_3D86:
    .dw $026E
    .db "@@@PINKY@", $2F
    .db $83, $2F, $80

PATCH_3D95:
    .dw $026E
    .db "MS@PAC;MAN", $2F
    .db $89, $2F, $80

PATCH_3DA5:
    .dw $026E
    .db "@@@INKY@@", $2F
    .db $85, $2F, $80

PATCH_3DB4:
    .dw $023D
    .db "@@1980:1981@", $2F
    .db $81, $2F, $80

PATCH_3DC6:
    .dw $026E
    .db "@@@@SUE", $2F
    .db $87, $2F, $80

PATCH_3DD3:
    .dw $026B
    .db "JUNIOR@@@@", $2F
    .db $8F, $2F, $80

PATCH_3DE3:
    .dw $026B
    .db "WITH@@@@@", $2F
    .db $8F, $2F, $80

PATCH_3DF2:
    .dw $026B
    .db "THE@CHASE@", $2F
    .db $8F, $2F, $80

PATCH_3E02:
    .dw $026B
    .db "STARRING@", $2F
    .db $8F, $2F, $80

PATCH_3E11:
    .dw $030C
    .db "MS@PAC;MEN", $2F
    .db $8F, $2F, $80

PATCH_3E21:
    .dw $026B
    .db "@@@@@@@@@", $2F
    .db $85, $2F, $80

PATCH_3E30:
    .dw $026B
    .db "ACT@III&@@", $2F
    .db $87, $2F, $80

PATCH_3E40:
    .dw $026B
    .db "THEY@MEET", $2F
    .db $8F, $2F, $80

; replaces Grubby credit in Pac-Man
NullCredit:
    .dw 0
    .db "@", $2F
    .db $80, $2F, $80

NewFruitTable:
.db $90, $14				; cherry
.db $94, $0F				; strawberry
.db $98, $15				; peach
.db $9C, $07				; pretzel
.db $A0, $14				; apple
.db $A4, $17				; pear
.db $A8, $16				; banana