.ASSUME ADL=0

#define TileROM pixelShadow
#define SpriteROM TileROM + $4000
#define TempSpriteBuffer SpriteROM + $4000

#define DrawTilemapFlag $E000

#define ScreenPTR romStart + $10000

#define Tilemap    romStart + $4000
#define ColorTable romStart + $4400
#define PrevTilemap romStart + $5100

#define CoordsTable romStart + $5060
#define SpriteTable romStart + $4FF0

; #define IN0       $5000
; #define IN1       $5040
; #define DIPSwitch $5080

#macro string(offset, str, color, end)
.dw offset ; 84+ CE - & $3FFF
.db str, $2F, color, $2F, end
#endmacro

CH1_FREQ0       = $4e8c    ; 20 bits
CH1_FREQ1       = $4e8d
CH1_FREQ2       = $4e8e
CH1_FREQ3       = $4e8f
CH1_FREQ4       = $4e90
CH1_VOL         = $4e91
CH2_FREQ1       = $4e92    ; 16 bits
CH2_FREQ2       = $4e93
CH2_FREQ3       = $4e94
CH2_FREQ4       = $4e95
CH2_VOL         = $4e96
CH3_FREQ1       = $4e97    ; 16 bits
CH3_FREQ2       = $4e98
CH3_FREQ3       = $4e99
CH3_FREQ4       = $4e9a
CH3_VOL         = $4e9b

SOUND_COUNTER   = $4c84    ; counter, incremented each VBLANK
                                ; (used to adjust sound volume)

EFFECT_TABLE_1  = $3b30    ; channel 1 effects. 8 bytes per effect
EFFECT_TABLE_2  = $3b40    ; channel 2 effects. 8 bytes per effect
EFFECT_TABLE_3  = $3b80    ; channel 3 effects. 8 bytes per effect

#if MSPACMAN
SONG_TABLE_1    = $9685    ; channel 1 song table
SONG_TABLE_2    = $967d    ; channel 2 song table
SONG_TABLE_3    = $968d    ; channel 3 song table
#else
SONG_TABLE_1    = $3bc8
SONG_TABLE_2    = $3bcc
SONG_TABLE_3    = $3bd0
#endif

CH1_E_NUM       = $4e9c    ; effects to play sequentially (bitmask)
CH1_E_1         = $4e9d    ; unused
CH1_E_CUR_BIT   = $4e9e    ; current effect
CH1_E_TABLE0    = $4e9f    ; table of parameters, initially copied from ROM
CH1_E_TABLE1    = $4ea0
CH1_E_TABLE2    = $4ea1
CH1_E_TABLE3    = $4ea2
CH1_E_TABLE4    = $4ea3
CH1_E_TABLE5    = $4ea4
CH1_E_TABLE6    = $4ea5
CH1_E_TABLE7    = $4ea6
CH1_E_TYPE      = $4ea7
CH1_E_DURATION  = $4ea8
CH1_E_DIR       = $4ea9
CH1_E_BASE_FREQ = $4eaa
CH1_E_VOL       = $4eab


CH2_E_NUM       = $4eac    ; effects to play sequentially (bitmask)

CH3_E_NUM       = $4ebc    ; effects to play sequentially (bitmask)

CH2_E_TABLE0    = $4eaf    ; table of parameters, initially copied from ROM

CH3_E_TABLE0    = $4eBF    ; table of parameters, initially copied from ROM


; 4EAC repeats the above for channel 2
; 4EBC repeats the above for channel 3

CH1_W_NUM       = $4ecc    ; wave to play (bitmask)
CH1_W_1         = $4ecd    ; unused
CH1_W_CUR_BIT   = $4ece    ; current wave
CH1_W_SEL       = $4ecf
CH1_W_4         = $4ed0
CH1_W_5         = $4ed1
CH1_W_OFFSET1   = $4ed2    ; address in ROM to find the next byte
CH1_W_OFFSET2   = $4ed3    ; (16 bits)
CH1_W_8         = $4ed4
CH1_W_9         = $4ed5
CH1_W_A         = $4ed6
CH1_W_TYPE      = $4ed7
CH1_W_DURATION  = $4ed8
CH1_W_DIR       = $4ed9
CH1_W_BASE_FREQ = $4eda
CH1_W_VOL       = $4edb

CH2_W_NUM       = $4EDc    ; wave to play (bitmask)
CH2_W_1         = $4EDd    ; unused
CH2_W_CUR_BIT   = $4EDe    ; current wave
CH2_W_SEL       = $4EDf
CH2_W_4         = $4EE0
CH2_W_5         = $4EE1
CH2_W_OFFSET1   = $4EE2    ; address in ROM to find the next byte
CH2_W_OFFSET2   = $4EE3    ; (16 bits)
CH2_W_8         = $4EE4
CH2_W_9         = $4EE5
CH2_W_A         = $4EE6
CH2_W_TYPE      = $4EE7
CH2_W_DURATION  = $4EE8
CH2_W_DIR       = $4EE9
CH2_W_BASE_FREQ = $4EEa
CH2_W_VOL       = $4EEb

CH3_W_NUM       = $4EEc    ; wave to play (bitmask)
CH3_W_1         = $4EEd    ; unused
CH3_W_CUR_BIT   = $4EEe    ; current wave
CH3_W_SEL       = $4EEf
CH3_W_4         = $4EF0
CH3_W_5         = $4EF1
CH3_W_OFFSET1   = $4EF2    ; address in ROM to find the next byte
CH3_W_OFFSET2   = $4EF3    ; (16 bits)
CH3_W_8         = $4EF4
CH3_W_9         = $4EF5
CH3_W_A         = $4EF6
CH3_W_TYPE      = $4EF7
CH3_W_DURATION  = $4EF8
CH3_W_DIR       = $4EF9
CH3_W_BASE_FREQ = $4EFa
CH3_W_VOL       = $4EFb