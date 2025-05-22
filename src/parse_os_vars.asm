EasterEgg_CheckAns:
	call	GetAnsInt
	
	ld	de, 765		; goroawase for Namco
	call	CpHLDE
	jr	nz, +_

	; if HL is 765 (Namco), play a special animation on the title screen
	ld	a, 5
	ld	(CurrentAnim), a
	ret

_:	ld	de, -765
	call	CpHLDE
	; if HL is -765, invert the screen
	ld	a, $21
	ret	nz
InvertScreen:	; IN: A = Command
	ld	hl, $F80818
	ld	(hl), h
	ld	(hl), $44
	ld	(hl), a
	ld	l,h
	ld	(hl), $01
	ret

GetAnsInt:	; sets HL to Ans
	ld	ix, 0
	add	ix, sp
	lea	hl, ix
	dec	hl
	pea	ix - 1
	call	GetAnsData
	pop	de

	; if Ans isn't a whole number, exit
	ld	a, (ix-1)
	or	a
	ret	nz

	; convert Ans into an integer
	push	hl
	call	RealToInt
	pop	af
	ret

; TI-OS date and time routines

CheckDate:	; outputs HL as the month and date
	ld	hl, CurrentYear
	push	hl
	ld	hl, CurrentMonth
	push	hl
	ld	hl, CurrentDate
	push	hl
	call	GetDate
	pop	hl
	pop	hl
	pop	hl
	or	a
	sbc	hl, hl
	ld	a, (CurrentDate)
	ld	l, a
	ld	a, (CurrentMonth)
	ld	h, a
	ret

CurrentDate:
	.db $00
CurrentMonth:
	.db $00
CurrentYear:
	.dl 0

CheckDate_SwitchAnim:	; check for special easter egg days
	ld	ix, SpecialDays
	call	CheckDate
	xor	a
_:	inc	a
	cp	5
	ret	nc		; looped too many times? just exit.
	push	hl
	ld	bc, (ix)
	or	a
	sbc	hl, bc		; compare HL and BC
	pop	hl
	lea	ix, ix+3
	jr	nz, -_		; if they aren't the same, loop back
	ld	(CurrentAnim), a
	ret

SpecialDays:
	.dl $0516	; Pac-Man release date (5/22)
	.dl $0203	; Ms. Pac-Man release date (2/3)
	.dl $091A	; Super Pac-Man release date (9/26)
	.dl $0617	; Sonic the Hedgehog release date (6/23)

CheckDate_ToggleAnniversary:	; check for January 27, 2015
	xor	a
	ld	(UnveilTrig), a

	; bail out if the date isn't January 27
	call	CheckDate
	ld	bc, $011B
	or	a
	sbc	hl, bc
	ret	nz

	; bail out if the year isn't 2015
	ld	hl, (CurrentYear)
	ld	bc, 2015
	or	a
	sbc	hl, bc
	ret	nz

	ld	a, 1
	ld	(UnveilTrig), a
	ret