SetGameSPI:
	ld	de, SPI_TMS9918
	jp	SpiLoop

SetArcadeSPI:
	ld	de, SPI_Arcade
	jp	SpiLoop

SetDefaultSPI:
	ld	de, SPI_Default
	jp	SpiLoop

SPI_TMS9918:
	.db 3	; # of SPI cmds
	; set horizontal resolution to 256 (centered)
	.db 5, $2A, 0, 32, (287 >> 8), (287 & $FF)
	; set vertical resolution to 192 (centered)
	.db 5, $2B, 0, 24, 0, 215
	; set undrawn areas to black
	.db 2, $B5, $80	

SPI_Arcade:
	.db 2	; # of SPI cmds
	; set horizontal resolution to 256 (centered)
	.db 5, $2A, 0, 32, (287 >> 8), (287 & $FF)
	; set undrawn areas to black
	.db 2, $B5, $80	


SPI_Default:
	.db 2	; # of SPI cmds
	; set horizontal resolution to 320
	.db 5, $2A, 0, 0, (319 >> 8), (319 & $FF)
	; set vertical resolution to 240
	.db 5, $2B, 0, 0, 0, 239

SpiLoop:	; IN: DE = SPI cmd list
	; C = number of cmds
	ld	a, (de)
	ld	c, a
	inc	de

	; B = cmd length
_:	ld	a, (de)
	ld	b, a
	inc	de

	ld	a, (de)
	call	spiCmd

_:	inc	de
	ld	a, (de)
	call	spiParam
	djnz	-_

	dec	c
	jr	nz, --_
	ret


; Input: A = parameter
spiParam:
	scf 		; First bit is set for data
	.db	$30	; jr nc, ? - skips over one byte
; Input: A = command
spiCmd:
	or	a, a ; First bit is clear for commands
	ld	hl, $F80818
	call	spiWrite
	ld	l, h
	ld	(hl), $01
spiWait:
	ld	l, $0D
spiWait1:
	ld	a, (hl)
	and	a, $F0
	jr	nz, spiWait1
	dec	l
spiWait2:
	bit	2, (hl)
	jr	nz, spiWait2
	ld	l, h
	ld	(hl), a
	ret

spiWrite:
	push	bc
	ld	b, 3
spiWriteLoop:
	rla
	rla
	rla
	ld	(hl), a ; send 3 bits
	djnz	spiWriteLoop
	pop	bc
	ret