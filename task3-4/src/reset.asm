.include "constants.inc"

.segment "ZEROPAGE"
.importzp seed

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
    SEI
    CLD
    LDX #$40
    STX $4017
    LDX #$FF
    TXS
    INX
    STX PPUCTRL
    STX PPUMASK
    STX $4010
    BIT $2002
vblankwait:
    BIT $2002
    BPL vblankwait

	LDX #$00
	LDA #$00
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

vblankwait2:
    BIT PPUSTATUS
    BPL vblankwait2

    LDA #1
    STA seed

    JMP main
.endproc