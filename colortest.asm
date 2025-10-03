; SH6578 color tester
;==============================================================================;
.include "nes.inc"
.include "sh6578.inc"
.include "ram.inc" ; ram defs

;==============================================================================;
.ifndef _NO_HEADER
.include "nes2_header.asm"
.endif

;==============================================================================;
.org $8000
chr4bpp_Tiles:
	.incbin "testchr.4bpp"

chr2bpp_Sprites:
	.incbin "sprites.chr"
chr2bpp_Sprites_end:

;==============================================================================;
; begin program code
.org $C000
	.db "SH6578 Color Test by freem"
	.align 16

;==============================================================================;
; SH6578 Nametables
;==============================================================================;
; This note probably belongs elsewhere.

; SH6578 Nametable data is different from standard NES.
; Each tile takes 2 bytes.

; high/2  | low/1
; 76543210|76543210
;---------|---------
; FEDCBA98 76543210
; |__||___________|
;   |       |
;   |       +-------- Tile index (in 16 color mode, bit 0 is ignored)
;   |                 "The 12 bits directly point to VRAM addresses VA15-VA4"
;   +---------------- Palette bank select (16 color mode: only top two bits (F,E) used)

; write low first, then high.
; this caused me countless grief for the better part of 20 minutes while I tried
; to figure out what the hell my nametable writes were doing wrong.

; Mapping NES nametable addresses to SH6578 nametable addresses,
; assuming the SH6578 nametable is at $2000:
;-------+--------+-----+-----+
; NES   | SH6578 | Row | Col |
;-------+--------+-----+-----+
; $2000 | $2000  |   0 |   0 |
; $2001 | $2002  |   0 |   1 |
; $2002 | $2004  |   0 |   2 |
; $2003 | $2006  |   0 |   3 |
; $2020 | $2040  |   1 |   0 |
;-------+--------+-----+-----+
; the formula is essentially (lower 3 nibbles of NES NT addr)*2

;==============================================================================;
waitVBlank:
	inc vblanked
@waitLoop:
	lda vblanked
	bne @waitLoop
	rts

;==============================================================================;
.include "menucode.asm"

;==============================================================================;
; library code
.include "io.asm"
.include "nametable.asm"

;==============================================================================;
.org $E000

Reset:
	sei
	cld

	; enable SH6578 expanded features
	lda #$65
	ldx #$76
	sta SH6578_SETUP
	stx SH6578_SETUP

	ldx #$40
	stx APU_FRAMECOUNT
	ldx #$FF
	txs

	; disable SH6578 interrupts
	stx int_sh6578_irqMask
	stx SH6578_IRQMASK

	inx
	txa
	sta PPU_CTRL
	sta PPU_MASK
	sta APU_DMC_FREQ

	; set linear PRG banking (x should still be 0 from above)
	stx SH6578_PRGBANK0
	inx
	stx SH6578_PRGBANK1
	inx
	stx SH6578_PRGBANK2
	inx
	stx SH6578_PRGBANK3
	inx
	stx SH6578_PRGBANK4
	inx
	stx SH6578_PRGBANK5
	inx
	stx SH6578_PRGBANK6
	inx
	stx SH6578_PRGBANK7

	; enable extended DMA features
	lda #$80
	sta SH6578_TIMING_CONTROL

	bit PPU_STATUS
@wait1:
	bit PPU_STATUS
	bpl @wait1

	; clear RAM
	ldx #0
	txa
@ClearRam:
	sta $00,x
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	sta $700,x
	; I probably don't need to use the ram at $0800-$1FFF
	inx
	bne @ClearRam

	; clear Sprites
	ldx #0
	lda #$FF
@ClearOAM:
	sta OAM_BUF,x
	inx
	inx
	inx
	inx
	bne @ClearOAM

	; send sprite data to PPU
	lda #2
	sta OAM_DMA

	; [some other setup]
	; set joystick on port 2
	lda #0
	sta SH6578_JOYMOUSE
	; set mouse reset
	lda #2
	sta SH6578_EXTIO
	; tell DAC to be quiet
	lda #0
	sta SH6578_DAC

@wait2:
	bit PPU_STATUS
	bpl @wait2

	; just to be sure!
	lda #0
	sta PPU_MASK
	lda #$80
	sta PPU_CTRL
	sta int_ppuCtrl

	;-------------------------------;
	; set up VRAM charsets using DMA

	; VRAM $8000: 4bpp BG tiles
	lda #0
	sta SH6578_DMABANK

	lda #<chr4bpp_Tiles
	sta SH6578_DMASRC_LO
	lda #>chr4bpp_Tiles
	sta SH6578_DMASRC_HI

	lda #<$8000
	sta SH6578_DMADEST_LO
	lda #>$8000
	sta SH6578_DMADEST_HI

	; size is chr2bpp_Sprites-chr4bpp_Tiles
	lda #<(chr2bpp_Sprites-chr4bpp_Tiles)
	sta SH6578_DMALEN_LO
	lda #>(chr2bpp_Sprites-chr4bpp_Tiles)
	sta SH6578_DMALEN_HI

	lda #SH6578_DMA_FLAG_ENABLE|SH6578_DMA_FLAG_RATE_FAST|SH6578_DMA_FLAG_DEST_VRAM
	sta SH6578_DMACTRL

	jsr waitVBlank

	; VRAM $1000: 2bpp sprite tiles
	lda #0
	sta SH6578_DMABANK

	lda #<chr2bpp_Sprites
	sta SH6578_DMASRC_LO
	lda #>chr2bpp_Sprites
	sta SH6578_DMASRC_HI

	lda #$00
	sta SH6578_DMADEST_LO
	lda #$10
	sta SH6578_DMADEST_HI

	lda #<(chr2bpp_Sprites_end-chr2bpp_Sprites)
	sta SH6578_DMALEN_LO
	lda #>(chr2bpp_Sprites_end-chr2bpp_Sprites)
	sta SH6578_DMALEN_HI

	lda #SH6578_DMA_FLAG_ENABLE|SH6578_DMA_FLAG_RATE_FAST|SH6578_DMA_FLAG_DEST_VRAM
	sta SH6578_DMACTRL

	jsr waitVBlank

	;-------------------------------;
	; SH6578 video control
	lda #$85 ; 16 color bg; sprite tiles at $1000; bg nametable at $2000
	sta int_sh6578_vidCtrl
	sta SH6578_VIDEOCTRL

	jmp Menu_Setup

;==============================================================================;
NMI:
	pha
	txa
	pha
	tya
	pha

	; increment framecount
	inc <frameCount
	bne @afterFrameCount
	inc <frameCount+1
@afterFrameCount:
	; update the sprites
	lda #0
	sta OAM_ADDR
	lda #>OAM_BUF
	sta OAM_DMA
	; update nametable stuff (if necessary)
	lda vramUpdateWaiting
	beq @afterVramUpdate

	; do nametable updates
	jsr ppu_WriteBuffer

	; reset necessary vars
	lda #0
	sta vramUpdateWaiting
	sta vramDataCurPos

@afterVramUpdate:
	; palette update (if necessary)
	lda palUpdateWaiting
	beq @afterPalUpdate

	;-- update palette via DMA --;
	; dma source bank select
	lda #0
	sta SH6578_DMABANK

	; dma source address
	lda #<palBufData
	sta SH6578_DMASRC_LO
	lda #>palBufData
	sta SH6578_DMASRC_HI

	; dma dest address
	lda #<SH6578_PALSTART
	sta SH6578_DMADEST_LO
	lda #>SH6578_PALSTART
	sta SH6578_DMADEST_HI

	; dma length
	lda #$3F
	sta SH6578_DMALEN_LO
	lda #0
	sta SH6578_DMALEN_HI

	; dma control
	lda #$E0 ; fast transfer to work RAM
	sta SH6578_DMACTRL

@afterPalUpdate:
	; do non-PPU-bound things
	lda #0
	sta curSpriteIndex
	sta palUpdateWaiting

	lda int_scrollX
	sta PPU_SCROLL
	lda int_scrollY
	sta PPU_SCROLL

	lda int_sh6578_vidCtrl
	sta SH6578_VIDEOCTRL

	lda int_ppuCtrl
	sta PPU_CTRL
	lda int_ppuMask
	sta PPU_MASK

NMI_end:
	lda #0
	sta vblanked

	pla
	tay
	pla
	tax
	pla

IRQ:
	rti

;==============================================================================;
; vectors
.org $FFFA
	.dw NMI
	.dw Reset
	.dw IRQ
