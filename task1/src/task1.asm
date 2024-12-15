.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
	RTI
.endproc

.proc nmi_handler
	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA
		LDA #$00
		STA $2005
		STA $2005
	RTI
.endproc

.import reset_handler

.export main
.proc main

loadPalette:
    LDX PPUSTATUS
    LDX #$3f
    STX PPUADDR
    LDX #$00
    STX PPUADDR

loadPaletteLoop:
    LDA palettes,X
    STA PPUDATA
    INX
    CPX #$20
    BNE loadPaletteLoop

    ; write sprite data
    LDX #$00
loadSpriteLoop:
    LDA sprites,X
    STA $0200,X
    INX
    CPX #$10
    BNE loadSpriteLoop

LoadBackground:
    LDA PPUSTATUS             ; read PPU status to reset the high/low latch
    LDA #$20
    STA PPUADDR             ; write the high byte of $2000 address
    LDA #$00
    STA PPUADDR             ; write the low byte of $2000 address
    LDX #$00                ; start out at 0

LoadBackgroundLoop:
    LDA background, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $80, decimal 128 - copying 128 bytes
    BNE LoadBackgroundLoop  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

LoadBackgroundLoop2:
    LDA background+256, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $80, decimal 128 - copying 128 bytes
    BNE LoadBackgroundLoop2  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

LoadBackgroundLoop3:
    LDA background+512, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $80, decimal 128 - copying 128 bytes
    BNE LoadBackgroundLoop3  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

LoadBackgroundLoop4:
    LDA background+768, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $80, decimal 128 - copying 128 bytes
    BNE LoadBackgroundLoop4  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

LoadAttribute:
    LDA PPUSTATUS             ; read PPU status to reset the high/low latch
    LDA #$23
    STA PPUADDR             ; write the high byte of $23C0 address
    LDA #$C0
    STA PPUADDR             ; write the low byte of $23C0 address
    LDX #$00              ; start out at 0

LoadAttributeLoop:
    LDA attribute, x      ; load data from address (attribute + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$08              ; Compare X to hex $08, decimal 8 - copying 8 bytes
    BNE LoadAttributeLoop  ; Branch to LoadAttributeLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

vblankwait:       ; wait for another vblank before continuing
	BIT PPUSTATUS
	BPL vblankwait

	LDA #%10010000  ; turn on NMIs, sprites use first pattern table
	STA PPUCTRL
	LDA #%00011110  ; turn on screen
	STA PPUMASK

forever:
	JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes: ;paletes for Tileset A (Sprites)
.byte $0f, $2d, $1a, $30 ;Palette 0(Base Background)
.byte $0f, $0f, $1a, $30 ;Palette 1(Black Cards)
.byte $0f, $05, $1a, $30 ;Palette 2(Red Cards)
.byte $0f, $0b, $1a, $30 ;Palette 3

;paletes for Tileset B (Background)
.byte $0f, $2d, $1a, $30 ;Palette 0(Base Background)
.byte $0f, $0f, $1a, $30 ;Palette 1(Black Cards)
.byte $0f, $05, $1a, $30 ;Palette 2(Red Cards)
.byte $0f, $0b, $1a, $30 ;Palette 3

sprites:
; .byte $70, $05, $00, $80
; .byte $70, $06, $00, $88
; .byte $78, $07, $00, $80
; .byte $78, $08, $00, $88

background:
	.byte $00,$00,$01,$02,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$07,$08,$09,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$12,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	.byte $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$14,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$29,$2a,$00,$31,$32,$00,$35,$36,$00,$39
	.byte $3a,$00,$3d,$3e,$00,$41,$42,$00,$45,$46,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$2b,$2c,$00,$33,$34,$00,$37,$38,$00,$3b
	.byte $3c,$00,$3f,$40,$00,$43,$44,$00,$47,$48,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$2d,$2e,$00,$65,$66,$00,$69,$6a,$00,$6d
	.byte $6e,$00,$71,$72,$00,$65,$66,$00,$6d,$6e,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$2f,$30,$00,$67,$68,$00,$6b,$6c,$00,$6f
	.byte $70,$00,$73,$74,$00,$67,$68,$00,$6f,$70,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$49,$4a,$00,$4d,$4e,$00,$51,$52,$00,$55
	.byte $56,$00,$59,$5a,$00,$5d,$5e,$00,$61,$62,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$4b,$4c,$00,$4f,$50,$00,$53,$54,$00,$57
	.byte $58,$00,$5b,$5c,$00,$5f,$60,$00,$63,$64,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$69,$6a,$00,$6d,$6e,$00,$65,$66,$00,$71
	.byte $72,$00,$71,$72,$00,$65,$66,$00,$6d,$6e,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$6b,$6c,$00,$6f,$70,$00,$67,$68,$00,$73
	.byte $74,$00,$73,$74,$00,$67,$68,$00,$6f,$70,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$16,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19
	.byte $19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$17,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$01,$1b,$03,$1c,$1d,$1e,$11,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$12,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	.byte $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$14,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$31,$32,$00,$51,$52,$00,$39,$3a,$00,$51
	.byte $52,$00,$35,$36,$00,$39,$3a,$00,$45,$46,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$33,$34,$00,$53,$54,$00,$3b,$3c,$00,$53
	.byte $54,$00,$37,$38,$00,$3b,$3c,$00,$47,$48,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$6d,$6e,$00,$71,$72,$00,$65,$66,$00,$69
	.byte $6a,$00,$71,$72,$00,$69,$6a,$00,$65,$66,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$6f,$70,$00,$73,$74,$00,$67,$68,$00,$6b
	.byte $6c,$00,$73,$74,$00,$6b,$6c,$00,$67,$68,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$5d,$5e,$00,$55,$56,$00,$41,$42,$00,$31
	.byte $32,$00,$49,$4a,$00,$3d,$3e,$00,$49,$4a,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$5f,$60,$00,$57,$58,$00,$43,$44,$00,$33
	.byte $34,$00,$4b,$4c,$00,$3f,$40,$00,$4b,$4c,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$71,$72,$00,$65,$66,$00,$6d,$6e,$00,$69
	.byte $6a,$00,$65,$66,$00,$69,$6a,$00,$6d,$6e,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$73,$74,$00,$67,$68,$00,$6f,$70,$00,$6b
	.byte $6c,$00,$67,$68,$00,$6b,$6c,$00,$6f,$70,$15,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$16,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19
	.byte $19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$17,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$02,$03,$04,$05,$11,$28,$28,$28,$28,$00,$00
	.byte $00,$00,$00,$0a,$0b,$0c,$11,$28,$28,$28,$28,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $03,$1b,$1d,$75,$03,$08,$0c,$1e,$76,$01,$1d,$1e,$1d,$77,$02,$05
	.byte $1e,$07,$04,$78,$07,$03,$08,$1e,$76,$0c,$1e,$07,$79,$7a,$1d,$77
	.byte $04,$55,$a5,$a5,$65,$a5,$55,$8a,$00,$88,$aa,$66,$55,$aa,$19,$8a
	.byte $00,$88,$55,$66,$55,$aa,$11,$aa,$40,$59,$55,$56,$91,$6a,$54,$99
	.byte $00,$44,$55,$aa,$66,$aa,$2a,$59,$00,$44,$a5,$9a,$a6,$aa,$12,$66
	.byte $00,$54,$5a,$59,$1a,$0a,$01,$56,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$00

attribute:
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000

.segment "CHR"
.incbin "blackJackBG.chr"