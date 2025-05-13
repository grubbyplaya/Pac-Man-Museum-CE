; fill-in routines for the MSX BIOS, since it's not worth reimplementing the whole thing.

.ASSUME ADL=0
SNSMAT:	; basically GetKey for MSX
	cp	7
	jr	z, SNSMAT_7
	xor	a

	exx
	push	ix
	ld	ix, MSX_KeyMappings
	ld.lil	de, kbdG1
	ld	bc, $08FF
	ld	hl, 1

	; set DE to the key column to be read
_:	ld	e, (ix)
	ld.lil	a, (de)
	; skip if the button isn't pressed
	and	(ix + 1)
	jr	z, +_

	; clear the corresponding bit
	ld	a, c
	xor	l
	ld	c, a

	; go to next column
_:	add	hl, hl
	lea	ix, ix + 2
	djnz	--_
	ld	a, c

	pop	ix
	exx
	ret

SNSMAT_7:
	call.lil CheckForExit
	ld	a, $FF
	ret

#macro keyMap(column, key)
	.db column & $FF, key
#endmacro

MSX_KeyMappings:
	keyMap(kbdG1, kbdMode)	; space key
	keyMap(0, 0)		; unmapped
	keyMap(0, 0)		; unmapped
	keyMap(0, 0)		; unmapped
	keyMap(kbdG7, kbdLeft)	; left arrow
	keyMap(kbdG7, kbdUp)	; up arrow
	keyMap(kbdG7, kbdDown)	; down arrow
	keyMap(kbdG7, kbdRight)	; right arrow

READVDP:
	ld.lil	a, (mpLcdRis)
	bit	3, a
	ret	z
	ld	a, 8
	ld.lil	(mpLcdIcr), a
	ld	a, $80
	ei
	ret

FILLVRAM:
	push	hl
	push	de
	ld.lil	de, SegaVRAM
	add.lil	hl, de
	push.lil hl
	pop.lil	de
	inc.lil	de
	ld.lil	(hl), a
	dec	bc
	ldir.lil
	pop	de
	pop	hl
	ret

LDIRVRAM:
	push	de
	push	bc
	push	bc
	ex	de, hl
	ld.lil	bc, SegaVRAM
	add.lil	hl, bc
	ex.lil	de, hl
	
	ld.lil bc, romStart
	add.lil	hl, bc
	pop	bc
	ldir.lil
	pop	bc
	pop	de
	ret

WRITEVRAM:
	push	hl
	push	de
	ld.lil	de, SegaVRAM
	add.lil	hl, de
	ld.lil	(hl), a
	pop	de
	pop	hl
	ret

READVRAM:
	push	hl
	push	de
	ld.lil	de, SegaVRAM
	add.lil	hl, de
	ld.lil	a, (hl)
	pop	de
	pop	hl
	ret
