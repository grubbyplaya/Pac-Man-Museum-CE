.ASSUME ADL=1
SwitchBank:
.ORG SwitchBank+$D40000
	ld	($D2FFFF), a
	sub	3
	ret.sis c

	di
	push	hl
	push	de
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	de, Bank3_Address
	add	hl, de
	ld	hl, (hl)
	ld	de, -$8000
	add	hl, de
	ld	(CurrentBankAddress), hl
	pop	de
	pop	hl
	ret.sis

UpdateBankAddress:
	di
	push	bc
	bit	7, h
	jr	z, +_
	ld	bc, (CurrentBankAddress)
	add	hl, bc
	pop	bc
	ret.sis

_:	ld	bc, romStart
	add	hl, bc
	pop	bc
	ret.sis

CurrentBankAddress:
	.dl 0

GetBankAddresses:
	xor	a
_:	push	af
	ld	l, a
	ld	e, a
	ld	h, 9
	ld	d, 3
	mlt	hl
	mlt	de

	ld	bc, Bank03
	add	hl, bc	; HL = ROM bank header
	ex	de, hl
	ld	bc, Bank3_Address
	add	hl, bc	
	ex	de, hl	; DE = bank address holder

	push	de
	call	Mov9ToOP1
 	call	ChkFindSym
	pop	hl
	jp	c, ErrorQuit

	call	SetAToDEU
	ld	(StoreBankAddress + 1), hl

	; offset HL into actual data
	ld	hl, $0002
	add	hl, de
	; if the appvar is in RAM, skip
	cp	$D0
	jr	nc, StoreBankAddress

	; use archived header offset
	ld	hl, $0013
	add	hl, de

StoreBankAddress:
	ld	(0), hl
	pop	af
	inc	a
	cp	5
	jr	nz, -_
	ret.sis
	
Bank03:
	.db	AppVarObj, "MsPac03", 0

Bank04:
	.db	AppvarObj, "MsPac04", 0

Bank05:
	.db	AppVarObj, "MsPac05", 0

Bank06:
	.db	AppVarObj, "MsPac06", 0

Bank07:
	.db	AppVarObj, "MsPac07", 0

Bank3_Address:
	.dl 0
Bank4_Address:
	.dl 0
Bank5_Address:
	.dl 0
Bank6_Address:
	.dl 0
Bank7_Address:
	.dl 0