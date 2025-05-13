.assume ADL=0

DATA_3D00:
    .dw $0396
    .db "BONUS@PAC;MAN@FOR@@@000@]^_", $2F
    .db $8E, $2F, $80

#define NAMCO $28, $29, $2A, $2B, $2C, $2D, $2E

DATA_3D21:
    .dw $02BA
    .db $5C, "@", NAMCO, "1980", $2F
    .db $03, $03, $01, $01, $01, $01, $01, $01, $01, $03, $03, $03, $03, $2F, $80

DATA_3D3C:
    .dw $025D
    .db NAMCO, $2F
    .db $81, $2F, $80

PorterText:
    .dw $02FC
    .db "PORTED@BY@GRUBBY", $2F
    .db $9E, $2F, $80

DATA_3D57:
    .dw $02C5
    .db ";SHADOW@@@", $2F
    .db $81, $2F, $80

DATA_3D67:
    .dw $0165
    .db "&BLINKY&@", $2F
    .db $81, $2F, $80

DATA_3D76:
    .dw $02C8
    .db ";SPEEDY@@@", $2F
    .db $83, $2F, $80

DATA_3D86:
    .dw $0168
    .db "&PINKY&@@", $2F
    .db $83, $2F, $80

DATA_3D95:
    .dw $02CB
    .db ";BASHFUL@@", $2F
    .db $85, $2F, $80

DATA_3DA5:
    .dw $016B
    .db "&INKY&@@@", $2F
    .db $85, $2F, $80

DATA_3DB4:
    .dw $02CE
    .db ";POKEY@@@@", $2F
    .db $87, $2F, $80

DATA_3DC4:
    .dw $016E
    .db "&CLYDE&@@", $2F
    .db $87, $2F, $80

DATA_3DD3:
    .dw $02C5
    .db ";AAAAAAAA;", $2F
    .db $81, $2F, $80

DATA_3DE3:
    .dw $0165
    .db "&BBBBBBB&", $2F
    .db $81, $2F, $80

DATA_3DF2:
    .dw $02C8
    .db ";CCCCCCCC;", $2F
    .db $83, $2F, $80

DATA_3E02:
    .dw $0168
    .db "&DDDDDDD&", $2F
    .db $83, $2F, $80

DATA_3E11:
    .dw $02CB
    .db ";EEEEEEEE;", $2F
    .db $85, $2F, $80

DATA_3E21:
    .dw $016B
    .db "&FFFFFFF&", $2F
    .db $85, $2F, $80

DATA_3E30:
    .dw $02CE
    .db ";GGGGGGGG;", $2F
    .db $87, $2F, $80

DATA_3E40:
    .dw $016E
    .db "&HHHHHHH&", $2F
    .db $87, $2F, $80

DATA_3E4F:
    .dw $030C
    .db "PAC;MAN", $2F
    .db $8F, $2F, $80