; SH6578 color tester | menucode.asm
;==============================================================================;
; menu code lives here now, instead of in the main file.
; this is unlike the VT03 color tester, which was a quick hack.
; (I mean, this is still a quick hack, but it's slightly better organized now)

;==============================================================================;
; Screen Constants
;==============================================================================;
NUM_MENU_ITEMS = 4 ; palset, pal entry, hue, lum

NUM_PALSETS = 4 ; in 16 color mode
NUM_COLORS_IN_SET = 16
MAX_HUE = $10 ; $0-$F
MAX_LUM = 4   ; 0-3

VALUE_UPDATE_TYPE_IDLE   = 0
VALUE_UPDATE_TYPE_PALSET = 1 ; updates all displayed values (except pal index?)
VALUE_UPDATE_TYPE_PALIDX = 2 ; updates hue, lum, hex
VALUE_UPDATE_TYPE_HUE    = 3 ; updates hue, hex
VALUE_UPDATE_TYPE_LUM    = 4 ; updates lum, hex

;==============================================================================;
; Screen Setup
;==============================================================================;
Menu_Setup:
	; display should still be off

	; clear vars (though they should already be cleared by init code)
	lda #VALUE_UPDATE_TYPE_IDLE
	sta valueUpdateType

	lda #0
	sta cursorPos
	sta curPalSet
	sta curColorIndex
	sta valueUpdateDir

	;--------------------------------------------;
	; load palette buffer
	lda #0
	sta SH6578_DMABANK

	lda #<tblPalette_BG1
	sta SH6578_DMASRC_LO
	lda #>tblPalette_BG1
	sta SH6578_DMASRC_HI

	lda #<palBufData
	sta SH6578_DMADEST_LO
	lda #>palBufData
	sta SH6578_DMADEST_HI

	lda #63
	sta SH6578_DMALEN_LO
	lda #0
	sta SH6578_DMALEN_HI

	lda #SH6578_DMA_FLAG_ENABLE|SH6578_DMA_FLAG_DEST_WRAM|SH6578_DMA_FLAG_RATE_FAST
	sta SH6578_DMACTRL

	jsr waitVBlank

	lda #1
	sta palUpdateWaiting
	jsr waitVBlank

	lda palBufData
	tax
	and #$0F
	sta curHue
	txa
	and #$F0
	lsr
	lsr
	lsr
	lsr
	sta curLum

	;--------------------------------------------;
	; clear nametable and write initial interface
	jsr ppu_clearNT2_6578

	lda #<strHeader
	sta tmp00
	lda #>strHeader
	sta tmp01
	ldx #$20
	ldy #$D0
	lda #(strHeader_end-strHeader)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	ldx #$21
	ldy #$10
	lda #17
	sta tmp01
	lda #$08
	sta tmp00
	lda #$20
	jsr ppu_writeCharRepeat_6578

	lda #<strHeader2
	sta tmp00
	lda #>strHeader2
	sta tmp01
	ldx #$21
	ldy #$4E
	lda #(strHeader2_end-strHeader2)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strPalSet
	sta tmp00
	lda #>strPalSet
	sta tmp01
	ldx #$22
	ldy #$0A
	lda #(strPalSet_end-strPalSet)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strPalIndex
	sta tmp00
	lda #>strPalIndex
	sta tmp01
	ldx #$22
	ldy #$8A
	lda #(strPalIndex_end-strPalIndex)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strHue
	sta tmp00
	lda #>strHue
	sta tmp01
	ldx #$23
	ldy #$0A
	lda #(strHue_end-strHue)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strLum
	sta tmp00
	lda #>strLum
	sta tmp01
	ldx #$23
	ldy #$4A
	lda #(strLum_end-strLum)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strHex
	sta tmp00
	lda #>strHex
	sta tmp01
	ldx #$23
	ldy #$1A
	lda #(strHex_end-strHex)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	ldx #$23
	ldy #$5A
	stx PPU_ADDR
	sty PPU_ADDR
	lda #'$'<<1
	ldx #$08
	sta PPU_DATA
	stx PPU_DATA

	ldx #$24
	ldy #$44
	stx PPU_ADDR
	sty PPU_ADDR
	ldx #$08
	lda #'B'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'G'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'1'<<1
	sta PPU_DATA
	stx PPU_DATA

	ldx #$24
	ldy #$C4
	stx PPU_ADDR
	sty PPU_ADDR
	ldx #$08
	lda #'B'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'G'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'2'<<1
	sta PPU_DATA
	stx PPU_DATA

	ldx #$25
	ldy #$44
	stx PPU_ADDR
	sty PPU_ADDR
	ldx #$08
	lda #'B'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'G'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'3'<<1
	sta PPU_DATA
	stx PPU_DATA

	ldx #$25
	ldy #$C4
	stx PPU_ADDR
	sty PPU_ADDR
	ldx #$08
	lda #'B'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'G'<<1
	sta PPU_DATA
	stx PPU_DATA
	lda #'4'<<1
	sta PPU_DATA
	stx PPU_DATA

	; sprite number labels
	ldx #$25
	ldy #$AE
	stx PPU_ADDR
	sty PPU_ADDR
	lda #'1'<<1
	ldx #$08
	sta PPU_DATA
	stx PPU_DATA

	ldx #$25
	ldy #$B2
	stx PPU_ADDR
	sty PPU_ADDR
	lda #'2'<<1
	ldx #$08
	sta PPU_DATA
	stx PPU_DATA

	ldx #$25
	ldy #$B6
	stx PPU_ADDR
	sty PPU_ADDR
	lda #'3'<<1
	ldx #$08
	sta PPU_DATA
	stx PPU_DATA

	ldx #$25
	ldy #$BA
	stx PPU_ADDR
	sty PPU_ADDR
	lda #'4'<<1
	ldx #$08
	sta PPU_DATA
	stx PPU_DATA

	; "SPR" text
	lda #<strSPR
	sta tmp00
	lda #>strSPR
	sta tmp01
	ldx #$25
	ldy #$F2
	lda #(strSPR_end-strSPR)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	; background palette set tiles
	lda #<strTilesBG1
	sta tmp00
	lda #>strTilesBG1
	sta tmp01
	ldx #$24
	ldy #$4C
	lda #(strTilesBG1_end-strTilesBG1)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strTilesBG2
	sta tmp00
	lda #>strTilesBG2
	sta tmp01
	ldx #$24
	ldy #$CC
	lda #(strTilesBG2_end-strTilesBG2)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strTilesBG3
	sta tmp00
	lda #>strTilesBG3
	sta tmp01
	ldx #$25
	ldy #$4C
	lda #(strTilesBG3_end-strTilesBG3)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strTilesBG4
	sta tmp00
	lda #>strTilesBG4
	sta tmp01
	ldx #$25
	ldy #$CC
	lda #(strTilesBG4_end-strTilesBG4)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strHelp_Cursor
	sta tmp00
	lda #>strHelp_Cursor
	sta tmp01
	ldx #$26
	ldy #$52
	lda #(strHelp_Cursor_end-strHelp_Cursor)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	lda #<strHelp_Value
	sta tmp00
	lda #>strHelp_Value
	sta tmp01
	ldx #$26
	ldy #$92
	lda #(strHelp_Value_end-strHelp_Value)-1
	jsr ppu_writeString16_6578
	;jsr waitVBlank

	; default cursor at $2206
	ldx #$22
	ldy #$06
	stx PPU_ADDR
	sty PPU_ADDR
	lda #$3E
	ldx #$08
	sta PPU_DATA
	stx PPU_DATA

	; default value for pal set
	ldx #$22
	ldy #$20
	stx PPU_ADDR
	sty PPU_ADDR
	; pal set display is 1-4, but underlying variable uses 0-3
	lda curPalSet
	ora #$91
	asl
	ldx #$09
	sta PPU_DATA
	stx PPU_DATA

	; default value for pal index
	ldx #$22
	ldy #$A0
	stx PPU_ADDR
	sty PPU_ADDR
	lda curColorIndex
	ora #$90
	asl
	ldx #$09
	sta PPU_DATA
	stx PPU_DATA

	; default value for hue
	ldx #$23
	ldy #$12
	stx PPU_ADDR
	sty PPU_ADDR
	lda curHue
	ora #$90
	asl
	ldx #$09
	sta PPU_DATA
	stx PPU_DATA

	; default value for lum
	ldx #$23
	ldy #$52
	stx PPU_ADDR
	sty PPU_ADDR
	lda curLum
	ora #$90
	asl
	ldx #$09
	sta PPU_DATA
	stx PPU_DATA

	; default value for hex
	; nt 235C
	ldx #$23
	ldy #$5C
	stx PPU_ADDR
	sty PPU_ADDR
	lda palBufData
	and #$F0
	lsr
	lsr
	lsr
	lsr
	ora #$90
	asl
	ldx #$09
	sta PPU_DATA
	stx PPU_DATA
	lda palBufData
	and #$0F
	ora #$90
	asl
	ldx #$09
	sta PPU_DATA
	stx PPU_DATA

	; do sprites (UMCvis and Novatek-head do spritemerica)
	lda #0
	sta tmp08 ; cur pal
	tax
	tay

@spriteLoop:
	lda tblSpritePreviewY
	sta OAM_BUF,x
	inx
	lda #$01
	sta OAM_BUF,x
	inx
	lda tmp08
	sta OAM_BUF,x
	inx
	lda tblSpritePreviewX,y
	sta OAM_BUF,x
	inx

	lda tblSpritePreviewY+1
	sta OAM_BUF,x
	inx
	lda #$02
	sta OAM_BUF,x
	inx
	lda tmp08
	sta OAM_BUF,x
	inx
	lda tblSpritePreviewX,y
	sta OAM_BUF,x
	inx

	lda tblSpritePreviewY+2
	sta OAM_BUF,x
	inx
	lda #$03
	sta OAM_BUF,x
	inx
	lda tmp08
	sta OAM_BUF,x
	inx
	lda tblSpritePreviewX,y
	sta OAM_BUF,x
	inx

	lda tblSpritePreviewY+3
	sta OAM_BUF,x
	inx
	lda #$04
	sta OAM_BUF,x
	inx
	lda tmp08
	sta OAM_BUF,x
	inx
	lda tblSpritePreviewX,y
	sta OAM_BUF,x
	inx

	inc tmp08
	iny
	cpy #4
	bne @spriteLoop

	; turn on display and stuff
	lda #%10001000
	sta int_ppuCtrl

	lda #%00011110
	sta int_ppuMask
	jsr waitVBlank

;==============================================================================;
; Screen Main Loop
;==============================================================================;
MainLoop:
	jsr io_readJoySafe
	jsr HandleInput

	lda valueUpdateType
	beq @afterValueUpdate

	jsr HandleValueUpdate

@afterValueUpdate:
	jsr waitVBlank
	jsr ppu_ClearBuffer
	jmp MainLoop

;==============================================================================;
; Input Handler
;==============================================================================;
HandleInput:
	; select+start: soft reset
	lda pad1Trigger
	and #PAD_SELECT|PAD_START
	cmp #PAD_SELECT|PAD_START
	bne @HandleInputNormal

	jsr waitVBlank
	lda #0
	sta int_ppuCtrl
	sta int_ppuMask
	jmp Reset

@HandleInputNormal:
	lda pad1Trigger
	and #PAD_UP|PAD_DOWN|PAD_LEFT|PAD_RIGHT
	beq @exit

	; check up
	lda pad1Trigger
	and #PAD_UP
	beq @checkDown

	; cursor up
	lda cursorPos
	sta tmp00 ; previous cursor position
	bne @cursorUpNormal

	lda #NUM_MENU_ITEMS-1
	sta cursorPos
	bne @updateCursorUp

@cursorUpNormal:
	dec cursorPos

@updateCursorUp:
	jsr UpdateCursorDisplay

@checkDown:
	; check down
	lda pad1Trigger
	and #PAD_DOWN
	beq @checkLeft

	; cursor down
	lda cursorPos
	sta tmp00 ; previous cursor position
	cmp #NUM_MENU_ITEMS-1
	bne @cursorDownNormal

	lda #0
	sta cursorPos
	beq @updateCursorDown

@cursorDownNormal:
	inc cursorPos

@updateCursorDown:
	jsr UpdateCursorDisplay

@checkLeft:
	; check left
	lda pad1Trigger
	and #PAD_LEFT
	beq @checkRight

	; value left
	jsr ModifyValue_Left

@checkRight:
	; check right
	lda pad1Trigger
	and #PAD_RIGHT
	beq @exit

	; value right
	jsr ModifyValue_Right

@exit:
	rts

;==============================================================================;
UpdateCursorDisplay:
	ldx vramDataCurPos

	; clear old display (index in tmp00)
	ldy tmp00
	lda tblCursorPos_Hi,y
	sta vramBufData,x
	inx
	lda tblCursorPos_Lo,y
	sta vramBufData,x
	inx
	lda #2 ; 1 tile x 2 bytes per tile
	sta vramBufData,x
	inx
	lda #0
	sta vramBufData,x
	inx
	sta vramBufData,x
	inx

	; draw new display
	ldy cursorPos
	lda tblCursorPos_Hi,y
	sta vramBufData,x
	inx
	lda tblCursorPos_Lo,y
	sta vramBufData,x
	inx
	lda #2 ; 1 tile x 2 bytes per tile
	sta vramBufData,x
	inx
	lda #$3E
	sta vramBufData,x
	inx
	lda #$08
	sta vramBufData,x
	inx

	stx vramDataCurPos
	lda #1
	sta vramUpdateWaiting
	rts

;==============================================================================;
ModifyValue_Left:
	ldy cursorPos
	beq @palSet
	dey
	beq @palIndex
	dey
	beq @hue
	dey
	bne @end

@lum:
	; cursorPos == 3: lum
	dec curLum
	lda curLum
	bpl @newLumOk

	lda #MAX_LUM-1
	sta curLum

@newLumOk:
	lda #VALUE_UPDATE_TYPE_LUM
	sta valueUpdateType
	lda #-1
	sta valueUpdateDir
	rts

;--------------------------------------;
@palSet:
	; cursorPos == 0: palset
	dec curPalSet
	lda curPalSet
	bpl @newPalSetOk

	lda #NUM_PALSETS-1
	sta curPalSet

@newPalSetOk:
	lda #VALUE_UPDATE_TYPE_PALSET
	sta valueUpdateType
	lda #-1
	sta valueUpdateDir
	rts

;--------------------------------------;
@palIndex:
	; cursorPos == 1: pal index
	dec curColorIndex
	lda curColorIndex
	bpl @newPalIndexOk

	lda #NUM_COLORS_IN_SET-1
	sta curColorIndex

@newPalIndexOk:
	lda #VALUE_UPDATE_TYPE_PALIDX
	sta valueUpdateType
	lda #-1
	sta valueUpdateDir
	rts

;--------------------------------------;
@hue:
	; cursorPos == 2: hue
	dec curHue
	lda curHue
	bpl @newHueOk

	lda #MAX_HUE-1
	sta curHue

@newHueOk:
	lda #VALUE_UPDATE_TYPE_HUE
	sta valueUpdateType
	lda #-1
	sta valueUpdateDir

@end:
	rts

;------------------------------------------------------------------------------;
ModifyValue_Right:
	ldy cursorPos
	beq @palSet
	dey
	beq @palIndex
	dey
	beq @hue
	dey
	bne @end

@lum:
	; cursorPos == 3: lum
	inc curLum
	lda curLum
	cmp #MAX_LUM
	bne @newLumOk

	lda #0
	sta curLum

@newLumOk:
	lda #VALUE_UPDATE_TYPE_LUM
	sta valueUpdateType
	lda #1
	sta valueUpdateDir
	rts

;--------------------------------------;
@palSet:
	; cursorPos == 0: palset
	inc curPalSet
	lda curPalSet
	cmp #NUM_PALSETS
	bne @newPalSetOk

	lda #0
	sta curPalSet

@newPalSetOk:
	lda #VALUE_UPDATE_TYPE_PALSET
	sta valueUpdateType
	lda #1
	sta valueUpdateDir
	rts

;--------------------------------------;
@palIndex:
	; cursorPos == 1: pal index
	inc curColorIndex
	lda curColorIndex
	cmp #NUM_COLORS_IN_SET
	bne @newPalIndexOk

	lda #0
	sta curColorIndex

@newPalIndexOk:
	lda #VALUE_UPDATE_TYPE_PALIDX
	sta valueUpdateType
	lda #1
	sta valueUpdateDir
	rts

;--------------------------------------;
@hue:
	; cursorPos == 2: hue
	inc curHue
	lda curHue
	cmp #MAX_HUE
	bne @newHueOk

	lda #0
	sta curHue

@newHueOk:
	lda #VALUE_UPDATE_TYPE_HUE
	sta valueUpdateType
	lda #1
	sta valueUpdateDir

@end:
	rts

;==============================================================================;
UpdatePalSetDisplay:
	ldx vramDataCurPos

	lda #$22
	sta vramBufData,x
	inx
	lda #$20
	sta vramBufData,x
	inx
	lda #2
	sta vramBufData,x
	inx

	lda curPalSet
	clc
	adc #1
	ora #$90
	asl
	sta vramBufData,x
	inx
	lda #$09
	sta vramBufData,x
	inx

	stx vramDataCurPos
	rts

;------------------------------------------------------------------------------;
UpdatePalIndexDisplay:
	ldx vramDataCurPos

	lda #$22
	sta vramBufData,x
	inx
	lda #$A0
	sta vramBufData,x
	inx
	lda #2
	sta vramBufData,x
	inx

	lda curColorIndex
	and #$0F
	ora #$90
	asl
	sta vramBufData,x
	inx
	lda #$09
	sta vramBufData,x
	inx

	stx vramDataCurPos
	rts

;------------------------------------------------------------------------------;
UpdateHueDisplay:
	ldx vramDataCurPos

	lda #$23
	sta vramBufData,x
	inx
	lda #$12
	sta vramBufData,x
	inx
	lda #2
	sta vramBufData,x
	inx

	lda curHue
	and #$0F
	ora #$90
	asl
	sta vramBufData,x
	inx
	lda #$09
	sta vramBufData,x
	inx

	stx vramDataCurPos
	rts

;------------------------------------------------------------------------------;
UpdateLumDisplay:
	ldx vramDataCurPos

	lda #$23
	sta vramBufData,x
	inx
	lda #$52
	sta vramBufData,x
	inx
	lda #2
	sta vramBufData,x
	inx

	lda curLum
	and #$0F
	ora #$90
	asl
	sta vramBufData,x
	inx
	lda #$09
	sta vramBufData,x
	inx

	stx vramDataCurPos
	rts

;------------------------------------------------------------------------------;
UpdateHexDisplay:
	ldx vramDataCurPos

	lda #$23
	sta vramBufData,x
	inx
	lda #$5C
	sta vramBufData,x
	inx
	lda #4
	sta vramBufData,x
	inx

	lda tmp08
	and #$F0
	lsr
	lsr
	lsr
	lsr
	ora #$90
	asl
	sta vramBufData,x
	inx
	lda #$09
	sta vramBufData,x
	inx

	lda tmp08
	and #$0F
	ora #$90
	asl
	sta vramBufData,x
	inx
	lda #$09
	sta vramBufData,x
	inx

	stx vramDataCurPos
	rts

;==============================================================================;
HandleValueUpdate:
	lda valueUpdateDir
	beq HandleValueUpdate_Idle

	; determine what display(s) we need to update
	ldy valueUpdateType
	lda tblChangeValueRoutines_Lo,y
	sta tmp00
	lda tblChangeValueRoutines_Hi,y
	sta tmp01
	jmp (tmp00)

HandleValueUpdate_Epilogue:
	lda #0
	sta valueUpdateDir
	lda #1
	sta vramUpdateWaiting
	sta palUpdateWaiting
	jsr waitVBlank

HandleValueUpdate_Idle:
	rts

;==============================================================================;
ChangePalSet:
	; change palette set
	; this also changes hue, lum, hex

	ldy curPalSet
	lda tblPalBuf_Index,y
	clc
	adc curColorIndex
	tax
	lda palBufData,x
	sta tmp08
	and #$0F
	sta curHue
	lda tmp08
	and #$F0
	lsr
	lsr
	lsr
	lsr
	sta curLum

	; update vram buf
	jsr UpdatePalSetDisplay
	jsr UpdateHueDisplay
	jsr UpdateLumDisplay
	jsr UpdateHexDisplay
	jmp HandleValueUpdate_Epilogue

;------------------------------------------------------------------------------;
ChangePalIndex:
	; change palette index
	; this also changes hue, lum, hex

	ldy curPalSet
	lda tblPalBuf_Index,y
	clc
	adc curColorIndex
	tax
	lda palBufData,x
	sta tmp08
	and #$0F
	sta curHue
	lda tmp08
	and #$F0
	lsr
	lsr
	lsr
	lsr
	sta curLum

	; update vram buf
	jsr UpdatePalIndexDisplay
	jsr UpdateHueDisplay
	jsr UpdateLumDisplay
	jsr UpdateHexDisplay
	jmp HandleValueUpdate_Epilogue

;------------------------------------------------------------------------------;
ChangeHue:
	; change hue
	ldy curPalSet
	lda tblPalBuf_Index,y
	clc
	adc curColorIndex
	tax

	; update palbuf
	lda curLum
	asl
	asl
	asl
	asl
	ora curHue
	sta tmp08 ; save for write to hex display
	sta palBufData,x

	; update vram buf
	jsr UpdateHueDisplay
	jsr UpdateHexDisplay
	jmp HandleValueUpdate_Epilogue

;------------------------------------------------------------------------------;
ChangeLum:
	; change luminance
	ldy curPalSet
	lda tblPalBuf_Index,y
	clc
	adc curColorIndex
	tax

	; update palbuf
	lda curLum
	asl
	asl
	asl
	asl
	ora curHue
	sta tmp08 ; save for write to hex display
	sta palBufData,x

	jsr UpdateLumDisplay
	jsr UpdateHexDisplay
	jmp HandleValueUpdate_Epilogue

;==============================================================================;
tblChangeValueRoutines_Lo:
	.dl HandleValueUpdate_Idle
	.dl ChangePalSet
	.dl ChangePalIndex
	.dl ChangeHue
	.dl ChangeLum

tblChangeValueRoutines_Hi:
	.dh HandleValueUpdate_Idle
	.dh ChangePalSet
	.dh ChangePalIndex
	.dh ChangeHue
	.dh ChangeLum

;==============================================================================;
; Screen Data
;==============================================================================;
; [Palettes]
; SH6578 color set values are $00-$3F, but there are a few differences compared
; to the "regular" NES palette:
; - colors are accessed via $2040-$207F in the CPU space (instead of $3F00-$3F1F in the PPU space)
; - sprite colors start at $2050 and end at $205F (inclusive)
; - backgrounds can use either 4 or 16 colors per palette set (sprites are always 4 colors)

; The SH6578 datasheet groups each bank of palettes into 4 entries.
; In 16 color mode, 4 of these banks make up a single palette set, which is
; how they're broken up in the following list.

; $2040: bg pal banks 0-3
; $2050: bg pal banks 4-7 (also sprite pal banks 0-3)
; $2060: bg pal banks 8-B
; $2070: bg pal banks C-F

; 16 color set 1
tblPalette_BG1:
	;--- 00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F
	;.db $0E,$30,$20,$10,$00,$3D,$2D,$1D,$0D,$11,$12,$13,$14,$15,$16,$17

	; alt color test
	.db $0E,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3F

; sprite color sets 4x
; The 0, 4, 8, and 12 indices are transparent for sprites, but usable
; for backgrounds in 16 color mode.
tblPalette_Sprites:
	;.db $00,$10,$20,$30
	;.db $01,$11,$21,$31
	;.db $02,$12,$22,$32
	;.db $03,$13,$23,$33

	; alt color test
	.db $0E,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2F

; 16 color sets 3 and 4
tblPalette_BG3:
	;.db $0E,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$00,$10,$20

	; alt color test
	.db $0E,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1F

tblPalette_BG4:
	;.db $0E,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$00,$10,$20

	; alt color test
	.db $0E,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0F

;==============================================================================;
tblSpritePreviewY:
	.db 159,151,143,134

tblSpritePreviewX:
	.db 184,200,216,232

; cursor nametable positions
tblCursorPos_Hi:
	.dh $2206
	.dh $2286
	.dh $2306
	.dh $2346

tblCursorPos_Lo:
	.dl $2206
	.dl $2286
	.dl $2306
	.dl $2346

;==============================================================================;
; map of palette type and set to target addresses

; 16 color mode (with the caveat that sprites are always 4 colors)
;-----+---+-------------+
;Type |Set| Colors      |
;-----+---+-------------+
; BG  | 1 | $2040-$204F |
; BG  | 2 | $2050-$205F | (also sprites, see below)
; BG  | 3 | $2060-$206F |
; BG  | 4 | $2070-$207F |
;-----+---+-------------+
; SPR | 1 | $2050-$2053 |
; SPR | 2 | $2054-$2057 |
; SPR | 3 | $2058-$205B |
; SPR | 4 | $205C-$205F |
;-----+---+-------------+

; use curPalSet as index into this table
tblPalBuf_Index:
	.db 0,$10,$20,$30

; to calculate a $2040-$207F address...
; 1) High byte always $20
; 2) Use curPalSet as index into tblPalSet_StartAddr_Lo
; 3) ora curColorIndex (which will be between $0-$F)

;==============================================================================;
strHeader:
	.db ('S'<<1),$08
	.db ('H'<<1),$08
	.db ('6'<<1),$08
	.db ('5'<<1),$08
	.db ('7'<<1),$08
	.db ('8'<<1),$08

	.db $00,$00
	.db ('C'<<1),$08
	.db ('o'<<1),$08
	.db ('l'<<1),$08
	.db ('o'<<1),$08
	.db ('r'<<1),$08
	.db $00,$00
	.db ('T'<<1),$08
	.db ('e'<<1),$08
	.db ('s'<<1),$08
	.db ('t'<<1),$08
strHeader_end:

strHeader2:
	.db ('1'<<1),$08
	.db ('6'<<1),$08
	.db $00,$00
	.db ('C'<<1),$08
	.db ('o'<<1),$08
	.db ('l'<<1),$08
	.db ('o'<<1),$08
	.db ('r'<<1),$08
	.db $00,$00
	.db ('B'<<1),$08
	.db ('a'<<1),$08
	.db ('c'<<1),$08
	.db ('k'<<1),$08
	.db ('g'<<1),$08
	.db ('r'<<1),$08
	.db ('o'<<1),$08
	.db ('u'<<1),$08
	.db ('n'<<1),$08
	.db ('d'<<1),$08
strHeader2_end:

strPalSet:
	.db ('P'<<1),$08
	.db ('a'<<1),$08
	.db ('l'<<1),$08
	.db $00,$00
	.db ('S'<<1),$08
	.db ('e'<<1),$08
	.db ('t'<<1),$08
strPalSet_end:

strPalIndex:
	.db ('P'<<1),$08
	.db ('a'<<1),$08
	.db ('l'<<1),$08
	.db $00,$00
	.db ('I'<<1),$08
	.db ('n'<<1),$08
	.db ('d'<<1),$08
	.db ('e'<<1),$08
	.db ('x'<<1),$08
strPalIndex_end:

strHue:
	.db ('H'<<1),$08
	.db ('u'<<1),$08
	.db ('e'<<1),$08
strHue_end:

strLum:
	.db ('L'<<1),$08
	.db ('u'<<1),$08
	.db ('m'<<1),$08
strLum_end:

strHex:
	.db ('H'<<1),$08
	.db ('e'<<1),$08
	.db ('x'<<1),$08
strHex_end:

strSPR:
	.db ('S'<<1),$08
	.db ('P'<<1),$08
	.db ('R'<<1),$08
strSPR_end:

strHelp_Cursor:
	.db $00,$09
	.db $02,$09
	.db $00,$00
	.db ('C'<<1),$08
	.db ('u'<<1),$08
	.db ('r'<<1),$08
	.db ('s'<<1),$08
	.db ('o'<<1),$08
	.db ('r'<<1),$08
strHelp_Cursor_end:

strHelp_Value:
	.db $04,$09
	.db $06,$09
	.db $00,$00
	.db ('V'<<1),$08
	.db ('a'<<1),$08
	.db ('l'<<1),$08
	.db ('u'<<1),$08
	.db ('e'<<1),$08
strHelp_Value_end:

strTilesBG1:
	.db $02,$08
	.db $04,$08
	.db $06,$08
	.db $08,$08
	.db $0A,$08
	.db $0C,$08
	.db $0E,$08
	.db $10,$08
	.db $12,$08
	.db $14,$08
	.db $16,$08
	.db $18,$08
	.db $1A,$08
	.db $1C,$08
	.db $1E,$08
	.db $C0,$08
strTilesBG1_end:

strTilesBG2:
	.db $02,$48
	.db $04,$48
	.db $06,$48
	.db $08,$48
	.db $0A,$48
	.db $0C,$48
	.db $0E,$48
	.db $10,$48
	.db $12,$48
	.db $14,$48
	.db $16,$48
	.db $18,$48
	.db $1A,$48
	.db $1C,$48
	.db $1E,$48
	.db $C0,$48
strTilesBG2_end:

strTilesBG3:
	.db $02,$88
	.db $04,$88
	.db $06,$88
	.db $08,$88
	.db $0A,$88
	.db $0C,$88
	.db $0E,$88
	.db $10,$88
	.db $12,$88
	.db $14,$88
	.db $16,$88
	.db $18,$88
	.db $1A,$88
	.db $1C,$88
	.db $1E,$88
	.db $C0,$88
strTilesBG3_end:

strTilesBG4:
	.db $02,$C8
	.db $04,$C8
	.db $06,$C8
	.db $08,$C8
	.db $0A,$C8
	.db $0C,$C8
	.db $0E,$C8
	.db $10,$C8
	.db $12,$C8
	.db $14,$C8
	.db $16,$C8
	.db $18,$C8
	.db $1A,$C8
	.db $1C,$C8
	.db $1E,$C8
	.db $C0,$C8
strTilesBG4_end:

;==============================================================================;
; for now, I'm just copying the old code here
;==============================================================================;
.if 0

;==============================================================================;
; xxx: the rest of this still assumes VT03
;==============================================================================;
ChangePalSet:
	; set up vram write
	ldy vramDataCurPos
	lda #$21
	sta vramBufData,y
	iny
	lda #$10
	sta vramBufData,y
	iny
	lda #5
	sta vramBufData,y
	iny

	; determine what to write
	lda curPalSet
	cmp #4
	bcs @spritePal

	; 0-3 BG
	ldx #0
@loopLabelBG:
	lda Label_BG,x
	sta vramBufData,y
	iny
	inx
	cpx #3
	bne @loopLabelBG

	lda #0
	sta vramBufData,y
	iny

	lda curPalSet
	clc
	adc #$31
	sta vramBufData,y
	iny
	sty vramDataCurPos

	jmp @palSetDone

@spritePal:
	; 4-7 SPR
	ldx #0
@loopLabelSPR:
	lda Label_SPR,x
	sta vramBufData,y
	iny
	inx
	cpx #3
	bne @loopLabelSPR

	lda #0
	sta vramBufData,y
	iny

	lda curPalSet
	clc
	adc #$2D
	sta vramBufData,y
	iny
	sty vramDataCurPos

@palSetDone:
	lda #1
	sta vramUpdateWaiting
	rts

;==============================================================================;
ChangePalIndex:
	; update display
	ldy vramDataCurPos
	lda #$21
	sta vramBufData,y
	iny
	lda #$50
	sta vramBufData,y
	iny
	lda #1
	sta vramBufData,y
	iny
	lda curColorIndex
	clc
	adc #$90
	sta vramBufData,y
	iny

	sty vramDataCurPos
	lda #1
	sta vramUpdateWaiting

	rts

;==============================================================================;
; ONLY RUN ON CHANGING PAL SET OR PAL INDEX!

UpdateValueDisplay:
	; 1) low portion from PalSetOffsets,(curPalSet&3) | $3F_[X] coarse
	lda curPalSet
	and #3
	tay
	lda PalSetOffsets,y
	sta tmp00

	; 2) add (curColorIndex & 3) for proper indexing  | $3F_[X] fine
	lda curColorIndex
	and #3
	clc
	adc tmp00
	sta tmp00

	; 3) high portion from PalColorOffsets,curPalSet  | $3F[X]_
	lda curColorIndex
	lsr
	lsr
	and #7
	tay
	lda PalColorOffsets,y
	ora tmp00
	sta tmp00

	; 4) if this is a Sprite palette, OR value with $10
	lda curPalSet
	cmp #4
	bcc @checkMode

	lda tmp00
	ora #$10
	sta tmp00

@checkMode:
	; [new color mode]
	; get values from address and address+$80

	; LSB
	ldy tmp00
	lda palBufData,y
	sta tmp01
	and #$0F
	sta curHue

	lda tmp01
	and #$30
	lsr
	lsr
	lsr
	lsr
	sta tmp02 ; lum low 2 bits

	; MSB
	lda tmp00
	ora #$80
	tay
	lda palBufData,y
	sta tmp03
	and #$03
	asl
	asl
	ora tmp02
	sta curLum

	lda tmp03
	lsr
	lsr
	and #$0F
	sta curSat

@afterPart1:
	; hue value display $2189
	ldy vramDataCurPos
	lda #$21
	sta vramBufData,y
	iny
	lda #$89
	sta vramBufData,y
	iny
	lda #1
	sta vramBufData,y
	iny
	lda curHue
	clc
	adc #$90
	sta vramBufData,y
	iny

	; sat value display $21A9
	lda #$21
	sta vramBufData,y
	iny
	lda #$A9
	sta vramBufData,y
	iny
	lda #1
	sta vramBufData,y
	iny
	lda curSat
	clc
	adc #$90
	sta vramBufData,y
	iny

	; lum value display $21C9
	lda #$21
	sta vramBufData,y
	iny
	lda #$C9
	sta vramBufData,y
	iny
	lda #1
	sta vramBufData,y
	iny
	lda curLum
	clc
	adc #$90
	sta vramBufData,y
	iny

	; hex value display $21AE
	lda #$21
	sta vramBufData,y
	iny
	lda #$AE
	sta vramBufData,y
	iny
	lda #4
	sta vramBufData,y
	iny

	lda tmp03
	lsr
	lsr
	lsr
	lsr
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	lda tmp03
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	lda tmp01
	lsr
	lsr
	lsr
	lsr
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	lda tmp01
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	sty vramDataCurPos
	lda #1
	sta vramUpdateWaiting

	rts

;==============================================================================;
; this is for the "Hex" value near the middle of the screen.
UpdateHexValueDisplay:
	; 1) low portion from PalSetOffsets,(curPalSet&3) | $3F_[X] coarse
	lda curPalSet
	and #3
	tay
	lda PalSetOffsets,y
	sta tmp00

	; 2) add (curColorIndex & 3) for proper indexing  | $3F_[X] fine
	lda curColorIndex
	and #3
	clc
	adc tmp00
	sta tmp00

	; 3) high portion from PalColorOffsets,curPalSet  | $3F[X]_
	lda curColorIndex
	lsr
	lsr
	and #7
	tay
	lda PalColorOffsets,y
	ora tmp00
	sta tmp00

	; 4) if this is a Sprite palette, OR value with $10
	lda curPalSet
	cmp #4
	bcc @writeValue

	lda tmp00
	ora #$10
	sta tmp00

@writeValue:
	; hex value display $21AE
	ldy vramDataCurPos
	lda #$21
	sta vramBufData,y
	iny
	lda #$AE
	sta vramBufData,y
	iny
	lda #4
	sta vramBufData,y
	iny

	lda tmp00
	ora #$80
	tax
	lda palBufData,x
	lsr
	lsr
	lsr
	lsr
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	lda tmp00
	ora #$80
	tax
	lda palBufData,x
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	ldx tmp00
	lda palBufData,x
	lsr
	lsr
	lsr
	lsr
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	ldx tmp00
	lda palBufData,x
	and #$0F
	ora #$90
	sta vramBufData,y
	iny

	sty vramDataCurPos
	lda #1
	sta vramUpdateWaiting

	rts

;==============================================================================;
ModifyValue_Left:
	; yes I could be doing this more effectively, but this is a quickly hacked
	; together demo and I don't care about being effective when I have a
	; decent amount of space at my disposal
	lda cursorPos
	beq @palSet
	cmp #1
	beq @palIndex
	cmp #2
	beq @hue
	cmp #3
	beq @lum
	rts

;------------------------------------------------;
@palSet:
	lda curPalSet
	beq @wrapPalSet

	dec curPalSet
	jsr ChangePalSet
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

@wrapPalSet:
	lda #7
	sta curPalSet
	jsr ChangePalSet
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@palIndex:
	; depends on 2bpp vs. 4bpp (this demo only cares about 4bpp)
	lda curColorIndex
	beq @wrapPalIndex

	dec curColorIndex
	jsr ChangePalIndex
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

@wrapPalIndex:
	lda #15
	sta curColorIndex
	jsr ChangePalIndex
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@hue:
	lda curHue
	beq @wrapHue

	dec curHue
	jsr ChangeHue
	jmp UpdateHexValueDisplay

@wrapHue:
	lda #$F
	sta curHue
	jsr ChangeHue
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@lum:
	lda curLum
	beq @wrapLum

	dec curLum
	jsr ChangeLum
	jmp UpdateHexValueDisplay

@wrapLum:
	lda #$F
	sta curLum
	jsr ChangeLum
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@exit:
	rts

;==============================================================================;

ModifyValue_Right:
	; see comment in ModifyValue_Left
	lda cursorPos
	beq @palSet
	cmp #1
	beq @palIndex
	cmp #2
	beq @hue
	cmp #3
	beq @lum
	rts

;------------------------------------------------;
@palSet:
	lda curPalSet
	cmp #7
	beq @wrapPalSet

	inc curPalSet
	jsr ChangePalSet
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

@wrapPalSet:
	lda #0
	sta curPalSet
	jsr ChangePalSet
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@palIndex:
	; depends on 2bpp vs. 4bpp (this demo only cares about 4bpp)
	lda curColorIndex
	cmp #15
	beq @wrapPalIndex

	inc curColorIndex
	jsr ChangePalIndex
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

@wrapPalIndex:
	lda #0
	sta curColorIndex
	jsr ChangePalIndex
	jsr UpdateValueDisplay
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@hue:
	lda curHue
	cmp #$F
	beq @wrapHue

	inc curHue
	jsr ChangeHue
	jmp UpdateHexValueDisplay

@wrapHue:
	lda #0
	sta curHue
	jsr ChangeHue
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@lum:
	lda curLum
	cmp #$F
	beq @wrapLum

	inc curLum
	jsr ChangeLum
	jmp UpdateHexValueDisplay

@wrapLum:
	lda #0
	sta curLum
	jsr ChangeLum
	jmp UpdateHexValueDisplay

;------------------------------------------------;
@exit:
	rts

.endif
