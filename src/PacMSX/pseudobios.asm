;fill-in routines for the MSX BIOS, since it's not worth reimplementing the whole thing.

.ASSUME ADL=0
SNSMAT:	;basically GetKey for MSX
	cp	7
	jr	z, SNSMAT_7
	xor	a

	;check for arrow keys
	push	hl
	ld.lil	hl, KbdG7
	ld.lil	c, (hl)
	bit	kbitLeft, c
	jr	z, +_
	set	4, a
_:	bit	kbitUp, c
	jr	z, +_
	set	5, a
_:	bit	kbitDown, c
	jr	z, +_
	set	6, a
_:	bit	kbitRight, c
	jr	z, +_
	set	7, a
_:	ld.lil	hl, KbdG1
	bit.lil	kbitMode, (hl)
	jr	nz, +_
	ld.lil  hl, kbdG3
	bit.lil	kbit0, (hl)
	jr	nz, +_
	jr	z, ++_
_:	set	0, a
_:	pop	hl
	cpl
	ret

SNSMAT_7:
	ld.lil	a, (KbdG6)
	bit	kbitClear, a
	jp	nz, ExitGame
	ld	a, $FF
	ret

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
