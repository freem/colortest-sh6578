; File: nametable.asm
; Nametable-focused PPU routines, SH6578 version
;==============================================================================;
; modified for sh6578 color test
; these will NOT work on a stock NES or anything resembling it!

;==============================================================================;
; Routine: ppu_clearNT_6578
; Clears the specified nametable using tile $000, palette 0.
;
; Parameters:
; - *Y* - Nametable to clear (0-3), but only when nametables are at $0000

; high byte for nametable addresses when NT is at $0000
ppu_ntIndex: .db $00, $08, $10, $18

; Use when you aren't sure if nametables are at $0000 or $2000.
; Depends on the last write to int_sh6578_vidCtrl, which may or may not match
; the value of SH6578_VIDEOCTRL.
ppu_clearNT_6578:
	lda int_sh6578_vidCtrl
	and #1
	bne ppu_clearNT2_6578

; Use when you already know nametables are at $0000.
ppu_clearNT0_6578:
	; use y as index into start address
	lda ppu_ntIndex,y
	sta PPU_ADDR
	lda #0
	sta PPU_ADDR
	beq _ppu_clearNT_6578_startClearLoop

; Use when you already know nametables are at $2000.
ppu_clearNT2_6578:
	lda #$20
	sta PPU_ADDR
	lda #0
	sta PPU_ADDR

; (internal subroutine)
; don't jump to this directly unless you don't mind setting up the ppu address yourself
_ppu_clearNT_6578_startClearLoop:
	tax
	ldy #8
@clearLoop:
	sta PPU_DATA
	sta PPU_DATA
	dex
	bne @clearLoop
	dey
	bne @clearLoop

	rts

;------------------------------------------------------------------------------;
; Routine: ppu_clearAllNT_6578
; Clears all four nametables. Only useful when nametables are at $0000.

ppu_clearAllNT_6578:
	ldy #0
	jsr ppu_clearNT0_6578
	ldy #1
	jsr ppu_clearNT0_6578
	ldy #2
	jsr ppu_clearNT0_6578
	ldy #3
	jmp ppu_clearNT0_6578

;==============================================================================;
; Routine: ppu_writeString16_6578
; Writes a string of SH6578 nametable data to the PPU at the specified location
; using DMA.
; xxx: always assumes bank 0, currently has a maximum of 256 chars
;
; Parameters:
; - *A* - String length (copied to *tmp02*), must be subtracted by 1 thanks to DMA quirk
; - *X* - Nametable addr high
; - *Y* - Nametable addr low
; - *tmp00* - String Pointer Low
; - *tmp01* - String Pointer High

ppu_writeString16_6578:
	sta tmp02 ; save string length for later

	lda #0
	sta SH6578_DMABANK

	lda tmp00
	sta SH6578_DMASRC_LO
	lda tmp01
	sta SH6578_DMASRC_HI

	stx SH6578_DMADEST_HI
	sty SH6578_DMADEST_LO

	lda tmp02
	sta SH6578_DMALEN_LO
	lda #0
	sta SH6578_DMALEN_HI

	lda #SH6578_DMA_FLAG_ENABLE|SH6578_DMA_FLAG_DEST_VRAM|SH6578_DMA_FLAG_RATE_FAST
	sta SH6578_DMACTRL

	rts

;==============================================================================;
; Routine: ppu_writeCharRepeat_6578
; Writes a single character to the PPU repeatedly.
;
; Parameters:
; - *A* - Tile Number LSB
; - *X* - Nametable addr high
; - *Y* - Nametable addr low
; - *tmp00* - Tile Number MSB and Palette
; - *tmp01* - write length

ppu_writeCharRepeat_6578:
	stx PPU_ADDR
	sty PPU_ADDR

	ldy tmp01
	ldx tmp00
@writeLoop:
	sta PPU_DATA
	stx PPU_DATA
	dey
	bne @writeLoop

	rts

;==============================================================================;
; Routine: ppu_writeList
; Write the contents of a list to the PPU.
; This routine is only meant to be run when rendering is off.
;
; Parameters:
; - *tmp00* - List pointer low
; - *tmp01* - List pointer high
;
; List Format:
; 0x00 - PPU address high byte
; 0x01 - PPU address low byte
; 0x02 - length of data to write
; 0x03 - pointer to data to write
;
; List is terminated with $FF in the PPU address high byte.

ppu_writeList:
	ldy #0
@doPage:
	; nt addr hi
	lda (tmp00),y
	bmi @writeDone
	sta PPU_ADDR
	iny

	; nt addr lo
	lda (tmp00),y
	sta PPU_ADDR
	iny

	; length
	lda (tmp00),y
	sta tmp0F ; store length for comparison
	iny

	; string pointer
	lda (tmp00),y
	sta tmp02
	iny
	lda (tmp00),y
	sta tmp03
	iny
	sty tmp0E
	ldy #0
@writeString:
	lda (tmp02),y
	sta PPU_DATA
	iny
	cpy tmp0F
	bne @writeString

	ldy tmp0E
	jmp @doPage

@writeDone:
	rts

;==============================================================================;
; Routine: ppu_writeListBuf
; Writes the contents of a list to the PPU buffer.
; Meant to be called multiple times until the Carry flag is set.
;
; Parameters:
; - *Y*     - Current index into message list
; - *tmp00* - List pointer low
; - *tmp01* - List pointer high
;
; Returns:
; - *Carry* - Set if writes are finished, clear if more writes remain
; - *Y*     - Updated index into message list
;
; List format is the same as ppu_writeList.

ppu_writeListBuf:
	sty tmp08
	ldx vramDataCurPos
@writeLoop:
	; nt addr hi
	; check if this is the end
	lda (tmp00),y
	bpl @ntAddrHi_Normal

	; writes are finished
	sec
	bcs @end

@ntAddrHi_Normal:
	sta vramBufData,x
	inx
	iny

	; nt addr lo
	lda (tmp00),y
	sta vramBufData,x
	iny
	inx

	; length
	lda (tmp00),y
	sta vramBufData,x
	sta tmp0F ; store length for comparison
	inx
	iny

	; string pointer
	lda (tmp00),y
	sta tmp02
	iny
	lda (tmp00),y
	sta tmp03
	iny
	sty tmp08
	ldy #0
@writeString:
	lda (tmp02),y
	sta vramBufData,x
	iny
	inx
	cpy tmp0F
	bne @writeString

	clc ; more writes needed
	stx vramDataCurPos
	lda #1
	sta vramUpdateWaiting

@end:
	; return updated message list index
	ldy tmp08
	rts


;==[Nametable Buffer Routines]=================================================;
; Routine: ppu_WriteBuffer
; Transfer the contents of the VRAM buffer to the PPU.

ppu_WriteBuffer:
	ldy #0 ; start at the beginning

@ppu_WriteBuffer_BufferEntry:
	; get PPU address from buffer
	lda vramBufData,y
	sta tmp00
	iny
	lda vramBufData,y
	sta tmp01
	iny

	; get length/flags
	lda vramBufData,y
	beq @ppu_WriteBuffer_end ; length of 0 = buffer done

	sta tmp02 ; combined length and flags
	and #$7F
	sta tmp03 ; length only

	; change PPU increment value
	lda tmp02
	bmi @ppu_WriteBuffer_Inc32

	; increment 1
	lda int_ppuCtrl
	and #%11111011
	sta PPU_CTRL
	bne @ppu_WriteBuffer_SetAddr

@ppu_WriteBuffer_Inc32:
	; increment 32
	lda int_ppuCtrl
	and #%11111011
	ora #%00000100
	sta PPU_CTRL

@ppu_WriteBuffer_SetAddr:
	; set PPU address
	lda tmp00
	sta PPU_ADDR
	lda tmp01
	sta PPU_ADDR

	; write data
	ldx tmp03
	iny
@ppu_WriteBuffer_WriteLoop:
	lda vramBufData,y
	sta PPU_DATA
	iny
	dex
	bne @ppu_WriteBuffer_WriteLoop

	beq @ppu_WriteBuffer_BufferEntry ; loop until reaching a length of 0

@ppu_WriteBuffer_end:
	; reset to +1 increment
	lda int_ppuCtrl
	and #%11111011
	sta int_ppuCtrl
	rts

;------------------------------------------------------------------------------;
; currently not working
; maybe it's not possible to fire multiple DMAs in a single frame?

.if 0
ppu_WriteBuffer_6578:
	ldy #0 ; start at the beginning

@handleBufferEntry:
	; get PPU address from buffer
	lda vramBufData,y
	sta tmp00
	iny
	lda vramBufData,y
	sta tmp01
	iny

	; get length/flags
	lda vramBufData,y
	beq @end ; length of 0 = buffer done

	sta tmp02 ; combined length and flags
	and #$7F
	sta tmp03 ; length only

	; change PPU increment value
	lda tmp02
	bmi @inc32

	; increment 1
	lda int_ppuCtrl
	and #%11111011
	sta PPU_CTRL
	bne @setAddr

@inc32:
	; increment 32
	lda int_ppuCtrl
	and #%11111011
	ora #%00000100
	sta PPU_CTRL

@setAddr:
	lda #0
	sta SH6578_DMABANK

	sty SH6578_DMASRC_LO
	iny
	lda #>vramBufData
	sta SH6578_DMASRC_HI

	lda tmp00
	sta SH6578_DMADEST_HI
	lda tmp01
	sta SH6578_DMADEST_LO

	dec tmp03
	lda tmp03
	sta SH6578_DMALEN_LO
	lda #0
	sta SH6578_DMALEN_HI

	lda #SH6578_DMA_FLAG_ENABLE|SH6578_DMA_FLAG_DEST_VRAM|SH6578_DMA_FLAG_RATE_FAST
	sta SH6578_DMACTRL

	jmp @handleBufferEntry ; keep handling entries

@end:
	; reset to +1 increment
	lda int_ppuCtrl
	and #%11111011
	sta int_ppuCtrl
	rts
.endif

;==============================================================================;
; Routine: ppu_ClearBuffer
; Clears the VRAM buffer.

ppu_ClearBuffer:
	ldy #0
	lda #0
@ppu_ClearBuffer_loop:
	sta vramBufData,y
	iny
	cpy #(vramBufData_end-vramBufData)
	bne @ppu_ClearBuffer_loop
	rts
