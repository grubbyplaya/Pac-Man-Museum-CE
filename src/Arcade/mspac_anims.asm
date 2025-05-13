.ASSUME ADL=0

; cutscene jump tables
DATA_81F0:      ; jump table for 1st coffee break
.dw DATA_8251
.dw DATA_82A3
.dw DATA_8312
.dw DATA_834C
.dw DATA_8569
.dw DATA_857C

DATA_81FC:      ; jump table for 2nd coffee break
.dw DATA_8395
.dw DATA_83F0
.dw DATA_852B
.dw DATA_854A
.dw DATA_8569
.dw DATA_857C

DATA_8208:      ; jump table for 3rd coffee break
.dw DATA_8451
.dw DATA_846D
.dw DATA_84CF
.dw DATA_84FD
.dw DATA_8489
.dw DATA_857C

DATA_8214:      ; jump table for Blinky in attract mode
.dw DATA_8594
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250

DATA_8220:      ; jump table for Pinky in attract mode
.dw DATA_8250
.dw DATA_85B0
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250

DATA_822C:      ; jump table for Inky in attract mode
.dw DATA_8250
.dw DATA_8250
.dw DATA_85CC
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250

DATA_8238:      ; jump table for Sue in attract mode
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250
.dw DATA_85E8
.dw DATA_8250
.dw DATA_8250

DATA_8244:      ; jump table for Ms. Pac-Man in attract mode
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250
.dw DATA_8250
.dw DATA_8604
.dw DATA_8250

DATA_8250:      ; instantly ends animation
    .db $FF

; move OffX subpixels up and OffY subpixels right over SETN ticks while updating the sprite palette
#macro LOOP(OffX, OffY, Pal)
    .db $F0, OffX, OffY, Pal
#endmacro

; move to (X, Y)
#macro SETPOS(X, Y)
    .db $F1, X, Y
#endmacro

; save this value for other commands
#macro SETN(VALUE)
    .db $F2, VALUE
#endmacro

; set the sprite to the value pointed to by SPRITEPTR
#macro SETCHAR(SPRITEPTR)
    .db $F3
    .dw SPRITEPTR
#endmacro

; play SFX
#macro PLAYSOUND(SFX)
    .db $F5, SFX
#endmacro

; wait for SETN ticks
#macro PAUSE
    .db $F6
#endmacro

; show the ACT text
#macro SHOWACT
    .db $F7
#endmacro

; hide the ACT text
#macro CLEARACT
    .db $F8
#endmacro

; end the animation
#macro END
    .db $FF
#endmacro

DATA_8251:      ; animation for Ms. Pac-Man in coffee break 1
    SETPOS(0, 0)
    SETCHAR(ActSignSprites_1)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(189, 82)
    SETN($28)
    PAUSE

    SETN($16)
    LOOP(0, 0, $16)

    SETN($16)
    PAUSE

    SETPOS(255, 84)
    SETCHAR(MsPacSprites_Right)

    SETN($7F)
    LOOP(-16, 0, 9)

    SETN($7F)
    LOOP(-16, 0, 9)

    SETPOS(0, 127)
    SETCHAR(MsPacSprites_Left)

    SETN($75)
    LOOP(16, 0, 9)

    SETN($04)
    LOOP(16, -16, 9)

    SETCHAR(MsPacSprites_Up)

    SETN($30)
    LOOP(0, -16, 9)

    SETCHAR(MsPacSprites_Left)

    SETN($10)
    LOOP(0, 0, 9)
    END

DATA_82A3:  ; animation for Inky and the ACT sign in coffee break 1
    SETPOS(0, 0)
    SETCHAR(ActSignSprites_2)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(173, 82)
    SETN($28)
    PAUSE

    SETN($16)
    LOOP(0, 0, $16)
    SETN($16)
    PAUSE

    SETPOS(-1, 84)
    SETCHAR(GhostSprites_Right)
    SETN($2F)
    PAUSE

    SETN($70)
    LOOP(-17, 0, 5)

    SETN($74)
    LOOP(-20, 0, 5)

    SETPOS(0, 127)
    SETCHAR(GhostSprites_Left)

    SETN($1C)
    PAUSE

    SETN($58)
    LOOP(22, 0, 5)

    PLAYSOUND($10)

    SETN($06)
    LOOP(-8, -8, 5)

    SETN($06)
    LOOP(-8, 8, 5)

    SETN($06)
    LOOP(-8, -8, 5)

    SETN($06)
    LOOP(-8, 8, 5)

    SETPOS(0, 0)
    SETCHAR(HeartSprite)

    SETN($01)
    LOOP(0, 0, 3)

    SETPOS(127, 58)

    SETN($40)
    LOOP(0, 0, 3)
    END

DATA_8312: ; animation for Pac-Man in coffee break 1
    SETN($5A)
    PAUSE

    SETPOS(0, 164)
    SETCHAR(PacSprites_Left)

    SETN($7F)
    LOOP(16, 0, 9)
    
    SETN($7F)
    LOOP(16, 0, 9)

    SETPOS(255, 127)
    SETCHAR(PacSprites_Right)

    SETN($76)
    LOOP(-16, 0, 9)

    SETN($04)
    LOOP(-16, -16, 9)

    SETCHAR(DATA_864A)

    SETN($30)
    LOOP(0, -16, 9)

    SETCHAR(PacSprites_Right)

    SETN($10)
    LOOP(0, 0, 9)
    END

DATA_834C:  ; animation for Blinky in coffee break 1
    SETN($5F)
    PAUSE

    SETPOS(1, 164)
    SETCHAR(GhostSprites_Left)

    SETN($2F)
    PAUSE

    SETN($70)
    LOOP(17, 0, 3)

    SETN($74)
    LOOP(20, 0, 3)

    SETPOS(255, 127)
    SETCHAR(GhostSprites_Right)

    SETN($1C)
    PAUSE

    SETN($58)
    LOOP(-22, 0, 3)

    SEtN($06)
    LOOP(8, -8, 3)

    SETN($06)
    LOOP(8, 8, 3)

    SEtN($06)
    LOOP(8, -8, 3)

    SETN($06)
    LOOP(8, 8, 3)

    SETCHAR(BlankSprite)

    SETN($10)
    LOOP(0, 0, $16)
    END

DATA_8395:  ; animation for Ms. Pac-Man in coffee break 2
    SETN($5A)
    PAUSE

    SETPOS(255, 52)
    SETCHAR(MsPacSprites_Right)

    SETN($7F)
    PAUSE

    SETN($24)
    PAUSE

    SETN($68)
    LOOP(-40, 0, 9)

    SETN($7F)
    PAUSE

    SETN($18)
    PAUSE

    SETPOS(0, 148)
    SETCHAR(PacSprites_Left)

    SETN($68)
    LOOP(40, 0, 9)

    SETN($7F)
    PAUSE

    SETPOS(252, 127)
    SETCHAR(MsPacSprites_Right)

    SETN($18)
    PAUSE

    SETN($68)
    LOOP(-40, 0, 9)

    SETN($7F)
    PAUSE

    SETN($18)
    PAUSE

    SETPOS(0, 84)
    SETCHAR(PacSprites_Left)

    SETN($20)
    LOOP(112, 0, 9)

    SETPOS(255, 180)
    SETCHAR(MsPacSprites_Right)

    SETN($10)
    PAUSE

    SETN($24)
    LOOP(-112, 0, 9)
    END

DATA_83F0:  ; animation for Pac-Man in coffee break 2
    SETN($63)
    PAUSE

    SETPOS(255, 52)
    SETCHAR(PacSprites_Right)

    SETN($24)
    PAUSE

    SETN($7F)
    PAUSE

    SETN($18)
    PAUSE

    SETN($57)
    LOOP(-48, 0, 9)

    SETN($7F)
    PAUSE

    SETN($28)
    PAUSE

    SETPOS(0, 148)
    SETCHAR(MsPacSprites_Left)

    SETN($58)
    LOOP(48, 0, 9)

    SETN($7F)
    PAUSE

    SETN($24)
    PAUSE

    SETPOS(255, 127)
    SETCHAR(PacSprites_Right)

    SETN($58)
    LOOP(-48, 0, 9)

    SETN($7F)
    PAUSE

    SETN($20)
    PAUSE

    SETPOS(0, 84)
    SETCHAR(MsPacSprites_Left)

    SETN($20)
    LOOP(112, 0, 9)

    SETPOS(255, 180)
    SETCHAR(PacSprites_Right)

    SETN($10)
    PAUSE

    SETN($24)
    LOOP(-112, 0, 9)

    SETN($7F)
    PAUSE
    END

DATA_8451:  ; animation for the stork's front in coffee break 3
    SETN($5A)
    PAUSE

    SETPOS(0, 96)
    SETCHAR(StorkFrontSprite)

    SETN($7F)
    LOOP(10, 0, $16)

    SETN($7F)
    LOOP(16, 0, $16)

    SETN($30)
    LOOP(16, 0, $16)
    END

DATA_846D:  ; animation for the stork's back in coffee break 3
    SETN($6F)
    PAUSE

    SETPOS(0, 96)
    SETCHAR(StorkMainSprites)

    SETN($6A)
    LOOP(10, 0, $16)

    SETN($7F)
    LOOP(16, 0, $16)

    SETN($3A)
    LOOP(16, 0, $16)
    END

DATA_8489:  ; animation for the falling sack in coffee break 3
    SETCHAR(StaticSignSprites_1)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(189, 98)

    SETN($5A)
    PAUSE

    SETPOS(5, 96)
    SETCHAR(StorkSackSprite)

    SETN($7F)
    LOOP(10, 0, $16)

    SETN($7F)
    LOOP(6, 12, $16)

    SETN($06)
    LOOP(6, -16, $16)

    SETN($0C)
    LOOP(3, 9, $16)

    SETN($05)
    LOOP(5, -10, $16)

    SETN($0A)
    LOOP(4, 3, $16)

    SETCHAR(StorkBackSprite)

    SETN($01)
    LOOP(0, 0, $16)

    SETN($20)
    PAUSE
    END

DATA_84CF:  ; animation for Pac-Man in coffee break 3
    SETPOS(0, 0)
    SETCHAR(ActSignSprites_1)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(189, 82)

    SETN($28)
    PAUSE

    SETN($16)
    LOOP(0, 0, $16)

    SETN($16)
    PAUSE

    SETPOS(0, 0)
    SETCHAR(PacSprites_Right)

    SETN($01)
    LOOP(0, 0, $09)

    SETPOS(192, 192)

    SETN($30)
    PAUSE
    END

DATA_84FD:  ; animation for Ms. Pac-Man in coffee break 3
    SETPOS(0, 0)
    SETCHAR(ActSignSprites_2)
    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(173, 82)

    SETN($28)
    PAUSE

    SETN($16)
    LOOP(0, 0, $16)

    SETN($16)
    PAUSE

    SETPOS(0, 0)
    SETCHAR(MsPacSprites_Right)

    SETN($01)
    LOOP(0, 0, $09)

    SETPOS(208, 192)

    SETN($30)
    PAUSE
    END

DATA_852B:
    SETPOS(0, 0)
    SETCHAR(ActSignSprites_1)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(189, 82)

    SETN($28)
    PAUSE

    SETN($16)
    LOOP(0, 0, $16)

    SETN($16)
    PAUSE

    SETPOS(0, 0)
    END

DATA_854A:

    SETPOS(0, 0)
    SETCHAR(ActSignSprites_2)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(173, 82)

    SETN($28)
    PAUSE

    SETN($16)
    LOOP(0, 0, $16)

    SETN($16)
    PAUSE

    SETPOS(0, 0)
    END

DATA_8569:
    SETCHAR(StaticSignSprites_1)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(189, 98)

    SETN($5A)
    PAUSE

    SETPOS(0, 0)
    END

DATA_857C:  ; animation for Act clapboard
    SETCHAR(StaticSignSprites_2)

    SETN($01)
    LOOP(0, 0, $16)

    SETPOS(173, 98)

    SETN($39)
    PAUSE

    SHOWACT

    SETN($1E)
    PAUSE

    CLEARACT

    SETPOS(0, 0)
    END

DATA_8594:  ; animation for Blinky in attract mode
    SETPOS(0, 148)
    SETCHAR(GhostSprites_Left)

    SETN($70)
    LOOP(16, 0, 1)

    SETN($50)
    LOOP(16, 0, 1)

    SETCHAR(GhostSprites_Up)

    SETN($48)
    LOOP(0, -16, 1)
    END

DATA_85B0:  ; animation for Pinky in attract mode
    SETPOS(0, 148)
    SETCHAR(GhostSprites_Left)

    SETN($70)
    LOOP(16, 0, 3)

    SETN($50)
    LOOP(16, 0, 3)

    SETCHAR(GhostSprites_Up)

    SETN($38)
    LOOP(0, -16, 3)
    END

DATA_85CC:  ; animation for Inky in attract mode
    SETPOS(0, 148)
    SETCHAR(GhostSprites_Left)

    SETN($70)
    LOOP(16, 0, 5)

    SETN($50)
    LOOP(16, 0, 5)

    SETCHAR(GhostSprites_Up)

    SETN($28)
    LOOP(0, -16, 5)
    END

DATA_85E8:  ; animation for Blinky in attract mode
    SETPOS(0, 148)
    SETCHAR(GhostSprites_Left)

    SETN($70)
    LOOP(16, 0, 7)

    SETN($50)
    LOOP(16, 0, 7)

    SETCHAR(GhostSprites_Up)

    SETN($18)
    LOOP(0, -16, 7)
    END

DATA_8604:
    SETPOS(0, 148)
    SETCHAR(PacSprites_Left)

    SETN($72)
    LOOP(16, 0, 9)

    SETN($7F)
    PAUSE
    END

MsPacSprites_Right:
.db $1B, $1B, $19, $19, $1B, $1B, $32, $32, $FF
MsPacSprites_Left:
.db $9B, $9B, $99, $99, $9B, $9B, $B2, $B2, $FF
MsPacSprites_Up:
.db $6E, $6E, $5A, $5A, $6E, $6E, $72, $72, $FF

UnusedPacLeftTable:
.db $EE, $EE, $DA, $DA, $EE, $EE, $F2, $F2, $FF

PacSprites_Right:
.db $37, $37, $2D, $2D, $37, $37, $2F, $2F, $FF
PacSprites_Left:
.db $B7, $B7, $AD, $AD, $B7, $B7, $AF, $AF, $FF

DATA_864A:
.db $36, $36, $F1, $F1, $36, $36, $F3, $F3, $FF

DATA_8653:
.db $34, $34, $31, $31, $34, $34, $33, $33, $FF

GhostSprites_Right:
.db $A4, $A4, $A4, $A5, $A5, $A5, $FF
GhostSprites_Left:
.db $24, $24, $24, $25, $25, $25, $FF
GhostSprites_Up:
.db $26, $26, $26, $27, $27, $27, $FF

BlankSprite:
.db $1F, $FF

HeartSprite:
.db $1E, $FF

ActSignSprites_1:
.db $10, $10, $10, $14, $14, $14, $16, $16, $16, $FF
ActSignSprites_2:
.db $11, $11, $11, $15, $15, $15, $17, $17, $17, $FF

StaticSignSprites_1:
.db $12, $FF
StaticSignSprites_2:
.db $13, $FF

StorkFrontSprite:
    .db $30, $FF
StorkMainSprites:
    .db $18, $18, $18, $18, $2C, $2C, $2C, $2C, $FF
StorkSackSprite:
    .db $07, $FF
StorkBackSprite:
    .db $0F, $FF