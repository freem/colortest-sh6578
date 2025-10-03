; zero page
.enum $0000
	; 16 bytes temp space
	tmp00 .dsb 1, $00
	tmp01 .dsb 1, $00
	tmp02 .dsb 1, $00
	tmp03 .dsb 1, $00
	tmp04 .dsb 1, $00
	tmp05 .dsb 1, $00
	tmp06 .dsb 1, $00
	tmp07 .dsb 1, $00
	tmp08 .dsb 1, $00
	tmp09 .dsb 1, $00
	tmp0A .dsb 1, $00
	tmp0B .dsb 1, $00
	tmp0C .dsb 1, $00
	tmp0D .dsb 1, $00
	tmp0E .dsb 1, $00
	tmp0F .dsb 1, $00

	vblanked   .dsb 1 ; are we in vblank?
	frameCount .dsw 1 ; frame counter

	; shadow regs
	int_ppuCtrl   .dsb 1 ; internal PPU_CTRL (last2000)
	int_ppuMask   .dsb 1 ; internal PPU_MASK (last2001)
	int_ppuStatus .dsb 1 ; internal PPU_STATUS read (last2002)
	int_scrollX   .dsb 1 ; internal PPU_SCROLL (first write)
	int_scrollY   .dsb 1 ; internal PPU_SCROLL (second write)
	int_last4016  .dsb 1 ; last write to $4016

	; sh6578 shadow regs
	int_sh6578_vidCtrl .dsb 1 ; internal SH6578_VIDEOCTRL ($2008)
	int_sh6578_irqMask .dsb 1 ; internal SH6578_IRQMASK ($4032)
	;int_sh6578_timerCtrl .dsb 1 ; internal SH6578_TIMERCTRL ($4034)

	; input vars
	pad1Trigger .dsb 1 ; "UpDown" in some sources.
	pad2Trigger .dsb 1 ;
	pad1State .dsb 1 ; "Data" in some sources.
	pad2State .dsb 1 ;

	; vram buffer vars
	vramUpdateWaiting .dsb 1,$00 ; is a vram update waiting?
	vramDataCurPos    .dsb 1,$00 ; location in overall vram buffer
	palUpdateWaiting  .dsb 1,$00 ; is a palette update waiting?

	; sprite data shite
	curSpriteIndex .dsb 1,$00

	; color tester variables
	cursorPos     .dsb 1
	curPalSet     .dsb 1 ; 0-3  in 16 color mode
	curColorIndex .dsb 1 ; 0-15 in 16 color mode

	curHue .dsb 1
	curLum .dsb 1

	valueUpdateType .dsb 1 ; see constants section of menucode.asm
	valueUpdateDir  .dsb 1 ; -1 = left, 0 = none, 1 = right

.ende

; $200 for sprites

; $300 for vram buffer
.enum $0300
	vramBufData .dsb $E0 ; $0300-$03DF: vram buffer data
vramBufData_end:
.ende

; $400 for palette buffer
.enum $0400
	palBufData .dsb $40 ; palette buf data
.ende

; $500
; $600
; $700

; ...$800
; $900
; $A00...
; all the way to $1FFF
