.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
pad1: .res 1
previousPad1: .res 1

Temp: .res 1
cardVal: .res 1
;Win message sprites
W1: .res 1
W2: .res 1
W3: .res 1
W4: .res 1

DeckVariables:
    deck: .res 52

    ; Both dealer and player states
    DealerState: .res 1
    PlayerState: .res 1
    ; Counter for first row cards
    row1_Player: .res 1
    row1_Dealer: .res 1
    ; Counter for second row cards
    row2_Player: .res 1
    row2_Dealer: .res 1

    seed: .res 2  ; initialize 16-bit seed to any value except 0

    generatedNum: .res 1
    generatedSuit: .res 1

    ;;arregle el espacio de memoria de 10 a 5
    dealer_Tcards: .res 5  ;  Space for 10 cards (5 per row)
    dealer_Bcards: .res 5

    player_Tcards: .res 5  ; Space for 10 cards (5 per row)
    player_Bcards: .res 5

BetVariables:
    bet_amount: .res 1
    ; Betting sprites
    ZB1: .res 1 ;Zero bet Sprite
    ZB2: .res 1
    ZB3: .res 1
    ZB4: .res 1

CashVariables:
    cash_amount_high:.res 1
    cash_amount_low: .res 1
    ; Cash sprites
    ZC1: .res 1 ;Zero cash Sprite
    ZC2: .res 1
    ZC3: .res 1
    ZC4: .res 1

DealerVariables:
    dealer_amount: .res 1
    ZD1: .res 1
    ZD2: .res 1

PlayerVariables:
    player_amount: .res 1
    ZP1: .res 1
    ZP2: .res 1
frame_counter: .res 1

dealer_number_array: .res 10    ; Store card numbers (0-9)
dealer_suit_array: .res 10      ; Store card suits (0-9)
player_number_array: .res 10    ; Store card numbers (0-9)
player_suit_array: .res 10      ; Store card suits (0-9)

dealer_cards_count: .res 1      ; Track number of dealer cards
player_cards_count: .res 1

statusState: .res 1
.exportzp pad1, previousPad1, seed

.segment "CODE"
.proc irq_handler
    RTI
.endproc

.import read_controller1

.proc nmi_handler
    ; save registers
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA

    inc frame_counter   ; Will automatically wrap from 255 to 0
	JSR read_controller1
	JSR checkButtons

	LDA #$00
	STA $2005
	STA $2005

    ; restore registers
    PLA
    TAY
    PLA
    TAX
    PLA

    RTI
.endproc

.import reset_handler

.export main
.proc main
LDA #$00
STA frame_counter
STA statusState
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
    CPX #$FF              ; Compare X to hex $FF, decimal 255 - copying 256 bytes
    BNE LoadBackgroundLoop  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
						; if compare was equal to 255, keep going down

LoadBackgroundLoop2:
    LDA background+256, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $FF, decimal 255 - copying 256 bytes
    BNE LoadBackgroundLoop2  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
						; if compare was equal to 255, keep going down

LoadBackgroundLoop3:
    LDA background+512, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $FF, decimal 255 - copying 256 bytes
    BNE LoadBackgroundLoop3  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
						; if compare was equal to 255, keep going down

LoadBackgroundLoop4:
    LDA background+768, x     ; load data from address (background + the value in x)
    STA PPUDATA             ; write to PPU
    INX                   ; X = X + 1
    CPX #$FF              ; Compare X to hex $FF, decimal 255 - copying 256 bytes
    BNE LoadBackgroundLoop4  ; Branch to LoadBackgroundLoop if compare was Not Equal to zero
						; if compare was equal to 255, keep going down

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
LDA #%00000001
STA CONTROLLER1
LDA #%00000000
STA CONTROLLER1
LDA #$00
STA cardVal
STA bet_amount
STA player_amount
STA dealer_amount
STA cash_amount_high
LDA #$14
STA cash_amount_low

DrawBetSprites:
    LDA #$20
    STA ZB1
    JSR DrawBetODigit
    LDA #$20
    STA ZB2
    JSR DrawBetTDigit
    LDA #$20
    STA ZB3
    JSR DrawBetHDigit
    LDA #$20
    STA ZB4
    JSR DrawBetThDigit

DrawCashSprites:
    LDA #$20
    STA ZC1
    JSR DrawCashODigit
    LDA #$22
    STA ZC2
    JSR DrawCashTDigit
    LDA #$20
    STA ZC3
    JSR DrawCashHDigit
    LDA #$20
    STA ZC4
    JSR DrawCashThDigit

DrawDealerPointsSprites:
    LDA #$20
    STA ZD1
    JSR DrawDealerODigit
    LDA #$20
    STA ZD2
    JSR DrawDealerTDigit

DrawPlayerPointsSprites:
    LDA #$20
    STA ZP1
    JSR DrawPlayerODigit
    LDA #$20
    STA ZP2
    JSR DrawPlayerTDigit

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

.proc checkButtons
    check_left:
        LDA previousPad1
        AND #BTN_LEFT
        BEQ check_right
        LDA pad1
        AND #BTN_LEFT
        BNE check_right
    check_right:
        LDA previousPad1
        AND #BTN_RIGHT
        BEQ check_up
        LDA pad1
        AND #BTN_RIGHT
        BNE check_up
    check_up:
        LDA previousPad1
        AND #BTN_UP
        BEQ check_down
        LDA pad1
        AND #BTN_UP
        BNE check_down
        JSR raiseBet
    check_down:
        LDA previousPad1
        AND #BTN_DOWN
        BEQ check_select
        LDA pad1
        AND #BTN_DOWN
        BNE check_select
        JSR lowerBet
    check_select:
        LDA previousPad1
        AND #BTN_SELECT
        BEQ check_a
        LDA pad1
        AND #BTN_SELECT
        BNE check_a
        JSR COMPLETERESET
    check_a:
        LDA previousPad1
        AND #BTN_A
        BEQ check_b
        LDA pad1
        AND #BTN_A
        BNE check_b
        CheckPlayerTotal:
            LDA player_amount
            CMP #$16 ; Compare player total with 21
            BCS DontDealCard
            JSR drawPlayerCards

        DontDealCard:
            JSR checkButtonsDone
    check_b:
        LDA previousPad1
        AND #BTN_B
        BEQ checkButtonsDone
        LDA pad1
        AND #BTN_B
        BNE checkButtonsDone
        JSR drawDealerCards

        LDA dealer_amount
        CMP #$11
        BCC checkButtonsDone
        JSR winCondition
        RTS
    checkButtonsDone:
        LDA pad1
        STA previousPad1
        RTS
.endproc

.proc COMPLETERESET
    ;Reset bet amount Sprite
    LDA #$20
    STA ZB1
    STA ZB2
    STA ZB3
    STA ZB4
    ;Reset cash amount Sprite
    STA ZC1
    STA ZC3
    STA ZC4
    LDA #$22
    STA ZC2

    ; Reset all game state
    LDA #$00
    STA bet_amount
    STA dealer_amount
    STA player_amount
    STA DealerState
    STA PlayerState
    STA row1_Dealer
    STA row1_Player
    STA row2_Dealer
    STA row2_Player
    STA cash_amount_high

    STA dealer_cards_count
    STA player_cards_count
    STA player_suit_array
    STA dealer_number_array
    STA player_number_array
    STA dealer_suit_array
    STA statusState
    STA $02C1          ; Clear 'I' tile
    STA $02C5          ; Clear 'W' tile
    STA $02CD          ; Clear 'S' or 'N' tile
    STA $02C9          ; Clear 'E' or '!' tile

    LDA #$14
    STA cash_amount_low

    ;Draw all resetted Sprites
    JSR UpdatePlayerTotalODigit
    JSR UpdatePlayerTotalTDigit
    JSR UpdateDealerTotalODigit
    JSR UpdateDealerTotalTDigit
    JSR UpdateBetHDigit
    JSR UpdateBetTIncDigit
    JSR UpdateBetTDecDigit
    JSR UpdateBetODigit
    JSR UpdateCashHDigit
    JSR UpdateCashTDigit
    JSR UpdateCashODigit

    LDX #$00            ; Initialize X to 0
    clear_sprites:
        LDA #$00
        STA $0200, X       ; Y position
        INX                 ; Increment counter
        CPX #$A0            ; 40 sprites * 4 bytes = $A0 bytes total
        BNE clear_sprites
    RTS
.endproc

.proc winCondition
    ; won the game
    LDA cash_amount_low
    CMP #$FF  ; Compare with 255
    BCS winGame
    ;Check if player > 21 
    LDA player_amount
    CMP #$15  ; Compare with 21
    BEQ winRound
    CMP #$16  ; Compare with 22
    BCS loseRound
    ;If player >= dealer
    CMP dealer_amount  ; Compare with dealer
    BCS winRound  ; If player >= dealer

    ; Check if dealer busts (>21)
    LDA dealer_amount
    CMP #$16            ; Compare with 21
    BCS winRound

    ; Compare scores if neither busted
    CMP player_amount
    BCS loseRound ; If dealer >= player

    RTS 
    winRound:
        JSR raiseCash
        ;Reset bet amount Sprite
        JSR ResetRound
        RTS
    loseRound:
        JSR lowerCash
        LDA cash_amount_high
        BNE continue
        CMP cash_amount_low
        BEQ loseGame
    continue:
        JSR ResetRound
        RTS
    loseGame:
        PHA

        LDA #$01
        STA statusState

        LDA #$1b
        STA W1
        LDA #$2a
        STA W2
        LDA #$04
        STA W3
        LDA #$1d
        STA W4
        JSR DrawWin1Message
        JSR DrawWin2Message
        JSR DrawWin3Message
        JSR DrawWin4Message
        PLA
        JSR COMPLETERESET
        RTS
    winGame:
        PHA

        LDA #$01
        STA statusState

        LDA #$06
        STA W1
        LDA #$07
        STA W2
        LDA #$08
        STA W3
        LDA #$09
        STA W4
        JSR DrawWin1Message
        JSR DrawWin2Message
        JSR DrawWin3Message
        JSR DrawWin4Message
        PLA
        RTS
.endproc

.proc drawLose1
    ; First sprite (L)
    LDA #$08            ; Y position
    STA $02DC          
    LDA W1           ; Tile number for "L"
    STA $02DD          
    LDA #$00           ; Attributes
    STA $02DE          
    LDA #$28           ; X position
    STA $02DF
    RTS
.endproc

.proc drawLose2
    ; Second sprite (O)
    LDA #$08           ; Y position  
    STA $02D8
    LDA W2           ; Tile number for "O" 
    STA $02D9
    LDA #$00           ; Attributes
    STA $02DA
    LDA #$30           ; X position
    STA $02DB
    RTS
.endproc

.proc drawLose3
    ; Third sprite (S)
    LDA #$08
    STA $02CC ; Y-coord of first sprite
    LDA W3
    STA $02CD ; tile number of ones sprite
    LDA #$00
    STA $02CE ; attributes of first sprite
    LDA #$38
    STA $02CF ; X-coord of first sprite
    RTS
.endproc

.proc drawLose4
    ; Fourth sprite (E)
    LDA #$08
    STA $02C8 ; Y-coord of first sprite
    LDA W4
    STA $02C9 ; tile number of ones sprite
    LDA #$00
    STA $02CA ; attributes of first sprite
    LDA #$40
    STA $02CB ; X-coord of first sprite
    RTS
.endproc

.proc ResetRound
        ;Reset bet amount Sprite
        LDA #$20
        STA ZB1
        STA ZB2
        STA ZB3
        STA ZB4

        LDA #$00
        STA bet_amount
        STA player_amount
        STA dealer_amount
        STA DealerState
        STA PlayerState
        STA row1_Dealer
        STA row1_Player
        STA row2_Dealer
        STA row2_Player

        ;Draw all resetted Sprites
        JSR UpdatePlayerTotalODigit
        JSR UpdatePlayerTotalTDigit
        JSR UpdateDealerTotalODigit
        JSR UpdateDealerTotalTDigit
        JSR UpdateBetHDigit
        JSR UpdateBetTIncDigit
        JSR UpdateBetTDecDigit
        JSR UpdateBetODigit

        LDX #$00            ; Initialize X to 0
        clear_oam_loop:
            LDA #$00
            STA $0200, X       ; Y position
            INX                 ; Increment counter
            CPX #$A0            ; 40 sprites * 4 bytes = $A0 bytes total
            BNE clear_oam_loop
.endproc

.proc cardValue
    LDA generatedNum     ; Load generated card number
    CMP #$0A            ; Check if number is 10 or higher (J,Q,K)
    BCS ten             ; If 10 or higher, return 10 (BCS is branch if carry set)
    CMP #$00            ; Check if Ace
    BEQ ace
    CLC
    ADC #$01            ; Add 1 since cards are 0-based
    STA cardVal
    RTS

    ten:
        LDA #$0A            ; J,Q,K all worth 10
        STA cardVal
        RTS

    ace:
        LDA #$01            ; Ace worth 1 for now (can implement 1/11 logic later)
        STA cardVal
        RTS
.endproc

.proc dealerTotal
    LDA dealer_amount  ; Load current total
    CLC                 ; Clear carry for addition
    ADC cardVal        ; Add new card value
    STA dealer_amount   ; Store new total
    JSR UpdateDealerTotalODigit
    JSR UpdateDealerTotalTDigit
    RTS
.endproc

.proc playerTotal
    LDA player_amount   ; Load current total
    CLC                 ; Clear carry for addition
    ADC cardVal        ; Add new card value
    STA player_amount   ; Store new total
    JSR UpdatePlayerTotalODigit
    JSR UpdatePlayerTotalTDigit
    RTS
.endproc

.proc raiseBet
    ;Checks if player started game by drawing card
    ;If game started bet CANNOT BE MODIFIED
    LDA cash_amount_high
    BNE continue     ; If high byte > 0, we can raise
    LDA cash_amount_low
    CMP bet_amount      ; Compare low byte with current bet
    BEQ end            ; If equal, can't raise
    BCC end            ; If less, can't raise
    
    LDA $0251  ; load first card number tile
    CMP #$00   ; check if it's 0
    BNE end
    continue:   

    LDA bet_amount
    CLC                 ; Clear carry for addition
    CMP #maxValue      ; Check if it exceeds Max value
    ADC #Val           ; Add 5
    BCC no_overflow     ; Skip clamping if below Max value
    LDA #maxValue      ; Clamp to Max value
    no_overflow:
        STA bet_amount   ; Store updated value
        JSR UpdateBetHDigit
        JSR UpdateBetTIncDigit
        JSR UpdateBetODigit
    end:
        RTS
.endproc

.proc lowerBet
    ;Checks if player started game by drawing card
    ;If game started bet CANNOT BE MODIFIED
    LDA $0251
    CMP #$00
    BNE end

    LDA bet_amount
    SEC                 ; Set carry for subtraction
    CMP #minValue       ; Check if it goes below Min value
    SBC #Val           ; Subtract 5
    BCS no_negative    ; Skip clamping if above Min value
    LDA #minValue      ; Clamp to Min value
    no_negative:
        STA bet_amount   ; Store updated value
        JSR UpdateBetHDigit
        JSR UpdateBetTDecDigit
        JSR UpdateBetODigit
    end:
        RTS
.endproc

.proc raiseCash
    LDA cash_amount_low
    CLC                 ; Clear carry for addition
    ADC bet_amount     ; Add bet amount
    ; Check if exceeded 95
    checkv:
    CMP #$60           ; Compare with 95 ($5F)
    BCC end   ; If < 95, just store it
    
    ; Went over 95, need to wrap
    INC cash_amount_high
    SEC
    SBC #$64           ; Subtract 100
    JMP checkv

    end:
        STA cash_amount_low
        LDA cash_amount_low
        CMP #$FF
        BCS win
        ;Update cash display sprites
        JSR UpdateCashHDigit
        JSR UpdateCashTDigit
        JSR UpdateCashODigit
        RTS
    win:
        JSR winCondition
.endproc

.proc lowerCash
    LDA cash_amount_high
    BNE continue
    LDA cash_amount_low
    CMP bet_amount
    BCC end
    continue:
        LDA cash_amount_low    ; Load current cash
        SEC                    ; Set carry for subtraction
        SBC bet_amount        ; Subtract bet amount
    
    check_wrap:
        BPL store_result      ; If result positive, store it
        
        ; Went negative, need to wrap to 95
        DEC cash_amount_high
        CLC                    ; Clear carry for addition
        ADC #$64              ; Add 96 to wrap around to 95
        JMP check_wrap        ; Check if we need to wrap again
        
    store_result:
        STA cash_amount_low
        ;Update cash display sprites
        JSR UpdateCashHDigit
        JSR UpdateCashTDigit
        JSR UpdateCashODigit
    end:
    RTS
.endproc

.proc UpdateDealerTotalODigit
    LDA dealer_amount   ; Load total
    ; Mod by 10 to get ones digit
    SEC                 ; Set carry for division
    divby10:
        SBC #$0A           ; Subtract 10
        BCS divby10        ; If result >= 0, continue subtracting
        ADC #$0A           ; Add 10 back to get remainder (0-9)
        CLC
        ADC #$20           ; Convert to tile number ($20-$29)
        STA ZD1            ; Store in ones digit sprite value
        JSR DrawDealerODigit
        RTS
.endproc

.proc UpdateDealerTotalTDigit
    LDA dealer_amount   ; Load total
    
    ; Divide by 10 to get tens digit
    LDX #$00            ; Initialize tens counter
    divby10:
        CMP #$0A           ; Compare with 10
        BCC done           ; If less than 10, we're done
        SBC #$0A           ; Subtract 10
        INX                ; Increment tens counter
        JMP divby10        ; Continue dividing
        
    done:
        TXA                ; Transfer tens count to A
        CLC
        ADC #$20           ; Convert to tile number ($20-$29)
        STA ZD2            ; Store in tens digit sprite value
        JSR DrawDealerTDigit
        RTS
.endproc

.proc UpdatePlayerTotalODigit
    LDA player_amount   ; Load total
    ; Mod by 10 to get ones digit
    SEC                 ; Set carry for division
    divby10:
        SBC #$0A           ; Subtract 10
        BCS divby10        ; If result >= 0, continue subtracting
        ADC #$0A           ; Add 10 back to get remainder (0-9)
        CLC
        ADC #$20           ; Convert to tile number ($20-$29)
        STA ZP1            ; Store in ones digit sprite value
        JSR DrawPlayerODigit
        RTS
.endproc

.proc UpdatePlayerTotalTDigit
    LDA player_amount   ; Load total
    
    ; Divide by 10 to get tens digit
    LDX #$00            ; Initialize tens counter
    divby10:
        CMP #$0A           ; Compare with 10
        BCC done           ; If less than 10, we're done
        SBC #$0A           ; Subtract 10
        INX                ; Increment tens counter
        JMP divby10        ; Continue dividing
        
    done:
        TXA                ; Transfer tens count to A
        CLC
        ADC #$20           ; Convert to tile number ($20-$29)
        STA ZP2            ; Store in tens digit sprite value
        JSR DrawPlayerTDigit
        RTS
.endproc

.proc UpdateBetODigit
    LDA bet_amount
    CMP #$00
    BEQ Zero
    CMP #$FA
    BEQ Zero
    Five:
        LDA ZB1
        CMP #$25 ;sprite num 5
        BEQ Zero
        LDA #$25
        STA ZB1
        JSR DrawBetODigit
        JMP End
    Zero: 
        LDA #$20
        STA ZB1
        JSR DrawBetODigit
    End:
        RTS
.endproc

.proc UpdateBetTIncDigit
    LDA bet_amount
    CMP #$FA
    BEQ Five
    Increase1:
        LDA ZB1
        CMP #$25
        BNE End
        LDA ZB2
        CMP #$29 ;sprite num 5
        BEQ Zero 
        LDA ZB2
        CLC 
        ADC #$01;increase by 1
        STA ZB2
        JSR DrawBetTDigit
        JMP End
    Five:
        LDA ZB2
        CMP #$25 ;sprite num 5
        BEQ Zero
        LDA #$25 ;sprite num 5
        STA ZB2
        JSR DrawBetTDigit
        JMP End
    Zero: 
        LDA bet_amount
        CMP #$FA
        BEQ End
        LDA #$20 ;sprite num 0
        STA ZB2
        JSR DrawBetTDigit
    End:
        RTS
.endproc

.proc UpdateBetTDecDigit
    LDA bet_amount
    CMP #$00
    BEQ Zero
    Decrease1:
        LDA ZB1
        CMP #$20
        BNE End
        LDA ZB2
        CMP #$20 ;sprite num 5
        BEQ Nine 
        LDA ZB2
        SEC 
        SBC #$01;increase by 1
        STA ZB2
        JSR DrawBetTDigit
        JMP End
    Five:
        LDA ZB2
        CMP #$25 ;sprite num 5
        BEQ Zero
        LDA #$25 ;sprite num 5
        STA ZB2
        JSR DrawBetTDigit
        JMP End
    Nine:
        LDA ZB2
        CMP #$29 ;sprite num 5
        BEQ Zero
        LDA #$29 ;sprite num 5
        STA ZB2
        JSR DrawBetTDigit
        JMP End
    Zero: 
        LDA bet_amount
        CMP #$FA
        BEQ End
        LDA #$20 ;sprite num 0
        STA ZB2
        JSR DrawBetTDigit
    End:
        RTS
.endproc

.proc UpdateBetHDigit
    LDA bet_amount
    CMP #$00 ;000
    BEQ Zero
    CMP #$5F ;095
    BEQ Zero
    CMP #$64 ;100
    BEQ One
    CMP #$C3 ;195
    BEQ One
    CMP #$C8 ;200
    BEQ Two
    CMP #$FA ;250
    BEQ Two
    JMP End
    One:
        LDA #$21 ; sprite num 1
        STA ZB3
        JSR DrawBetHDigit
        JMP End
    Two:
        LDA #$22 ;sprite num 2
        STA ZB3
        JSR DrawBetHDigit
        JMP End
    Zero: 
        LDA #$20 ;sprite num 0
        STA ZB3
        JSR DrawBetHDigit
    End:
        RTS
.endproc

.proc UpdateCashODigit
    LDA cash_amount_low    ; Load low byte
    
    ; Mod by 10 to get ones digit
    SEC                    
    divby10:
        CMP #$0A              
        BCC done              
        SBC #$0A              
        JMP divby10           
        
    done:
        CLC
        ADC #$20              ; Convert to sprite number
        STA ZC1               
        JSR DrawCashODigit
        RTS
.endproc

.proc UpdateCashTDigit
    LDA cash_amount_low    ; Load low byte
    
    ; Divide by 10 to get tens digit
    LDX #$00              
    divby10:
        CMP #$0A              
        BCC done              
        SBC #$0A              
        INX                    
        JMP divby10           
        
    done:
        TXA                   
        CLC
        ADC #$20              ; Convert to sprite number
        STA ZC2               
        JSR DrawCashTDigit
        RTS
.endproc

.proc UpdateCashHDigit
    LDA cash_amount_high   ; Load high byte (hundreds)
    CLC
    ADC #$20              ; Convert to sprite number
    STA ZC3               
    JSR DrawCashHDigit
    RTS
.endproc

.proc DrawWin1Message
    ; Convert dealer_amount to sprite tile
    LDA #$08
    STA $02C4 ; Y-coord of first sprite
    LDA W1
    STA $02C5 ; tile number of ones sprite
    LDA #$00
    STA $02C6 ; attributes of first sprite
    LDA #$38
    STA $02C7 ; X-coord of first sprite
    RTS
.endproc

.proc DrawWin2Message
    ; Convert dealer_amount to sprite tile
    LDA #$08
    STA $02C0 ; Y-coord of first sprite
    LDA W2
    STA $02C1 ; tile number of ones sprite
    LDA #$00
    STA $02C2 ; attributes of first sprite
    LDA #$40
    STA $02C3 ; X-coord of first sprite
    RTS
.endproc

.proc DrawWin3Message
    ; Convert dealer_amount to sprite tile
    LDA #$08
    STA $02CC ; Y-coord of first sprite
    LDA W3
    STA $02CD ; tile number of ones sprite
    LDA #$00
    STA $02CE ; attributes of first sprite
    LDA #$48
    STA $02CF ; X-coord of first sprite
    RTS
.endproc

.proc DrawWin4Message
    ; Convert dealer_amount to sprite tile
    LDA #$08
    STA $02C8 ; Y-coord of first sprite
    LDA W4
    STA $02C9 ; tile number of ones sprite
    LDA #$00
    STA $02CA ; attributes of first sprite
    LDA #$50
    STA $02CB ; X-coord of first sprite
    RTS
.endproc

.proc DrawBetODigit
    ; Convert bet_amount to sprite tile
    LDA #$D8
    STA $02FC ; Y-coord of first sprite
    LDA ZB1
    STA $02FD ; tile number of ones sprite
    LDA #$00
    STA $02FE ; attributes of first sprite
    LDA #$D0
    STA $02FF ; X-coord of first sprite
    RTS
.endproc

.proc DrawCashODigit
    ; Convert cash_amount to sprite tile
    LDA #$D8
    STA $02EC ; Y-coord of first sprite
    LDA ZC1
    STA $02ED ; tile number of ones sprite
    LDA #$00
    STA $02EE ; attributes of first sprite
    LDA #$68
    STA $02EF ; X-coord of first sprite
    RTS
.endproc

.proc DrawBetTDigit
    ; Convert bet_amount to sprite tile
    LDA #$D8
    STA $02F8 ; Y-coord of first sprite
    LDA ZB2
    STA $02F9 ; tile number of ones sprite
    LDA #$00
    STA $02FA ; attributes of first sprite
    LDA #$C8
    STA $02FB ; X-coord of first sprite
    RTS
.endproc

.proc DrawCashTDigit
    ; Convert cash_amount to sprite tile
    LDA #$D8
    STA $02E8 ; Y-coord of first sprite
    LDA ZC2
    STA $02E9 ; tile number of ones sprite
    LDA #$00
    STA $02EA ; attributes of first sprite
    LDA #$60
    STA $02EB ; X-coord of first sprite
    RTS
.endproc

.proc DrawBetHDigit
    ; Convert bet_amount to sprite tile
    LDA #$D8
    STA $02F4 ; Y-coord of first sprite
    LDA ZB3
    STA $02F5 ; tile number of ones sprite
    LDA #$00
    STA $02F6 ; attributes of first sprite
    LDA #$C0
    STA $02F7 ; X-coord of first sprite
    RTS
.endproc

.proc DrawCashHDigit
    ; Convert cash_amount to sprite tile
    LDA #$D8
    STA $02E4 ; Y-coord of first sprite
    LDA ZC3
    STA $02E5 ; tile number of ones sprite
    LDA #$00
    STA $02E6 ; attributes of first sprite
    LDA #$58
    STA $02E7 ; X-coord of first sprite
    RTS
.endproc

.proc DrawBetThDigit
    ; Convert bet_amount to sprite tile
    LDA #$D8
    STA $02F0 ; Y-coord of first sprite
    LDA ZB4
    STA $02F1 ; tile number of ones sprite
    LDA #$00
    STA $02F2 ; attributes of first sprite
    LDA #$B8
    STA $02F3 ; X-coord of first sprite
    RTS
.endproc

.proc DrawCashThDigit
    ; Convert cash_amount to sprite tile
    LDA #$D8
    STA $02E0 ; Y-coord of first sprite
    LDA ZC4
    STA $02E1 ; tile number of ones sprite
    LDA #$00
    STA $02E2 ; attributes of first sprite
    LDA #$50
    STA $02E3 ; X-coord of first sprite
    RTS
.endproc

.proc DrawDealerODigit
    ; Convert dealer_amount to sprite tile
    LDA #$08
    STA $02DC ; Y-coord of first sprite
    LDA ZD1
    STA $02DD ; tile number of ones sprite
    LDA #$00
    STA $02DE ; attributes of first sprite
    LDA #$30
    STA $02DF ; X-coord of first sprite
    RTS
.endproc

.proc DrawDealerTDigit
    ; Convert dealer_amount to sprite tile
    LDA #$08
    STA $02D8 ; Y-coord of first sprite
    LDA ZD2
    STA $02D9 ; tile number of ones sprite
    LDA #$00
    STA $02DA ; attributes of first sprite
    LDA #$28
    STA $02DB ; X-coord of first sprite
    RTS
.endproc

.proc DrawPlayerODigit
    ; Convert player_amount to sprite tile
    LDA #$68
    STA $02D4 ; Y-coord of first sprite
    LDA ZP1
    STA $02D5 ; tile number of ones sprite
    LDA #$00
    STA $02D6 ; attributes of first sprite
    LDA #$50
    STA $02D7 ; X-coord of first sprite
    RTS
.endproc

.proc DrawPlayerTDigit
    ; Convert player_amount to sprite tile
    LDA #$68
    STA $02D0 ; Y-coord of first sprite
    LDA ZP2
    STA $02D1 ; tile number of ones sprite
    LDA #$00
    STA $02D2 ; attributes of first sprite
    LDA #$48
    STA $02D3 ; X-coord of first sprite
    RTS
.endproc

.proc drawDealerCards
    ;Check is player has drawn a card
    ;If player has drawn no card the dealer can draw no cards
    LDA $0251
    CMP #$00
    BEQ done_second_shortcut
    ;Check if last card has been drawn
    LDA $0249
    CMP #$00
    BNE done_second_shortcut
    ; Check if game is over (Win or Loss)
    LDA statusState
    CMP #$01
    BEQ done_second_shortcut
    ; Check current dealer state to determine which row to draw
    LDA DealerState           
    CMP #$01                ; First row state (1)
    BEQ first_row_shortcut           ; If in first row state, branch to first_row
    CMP #$02                ; Second row state (2)
    BEQ second_row          ; If in second row state, branch to second_row

    ; If state is 0 (initial state), initialize first row
    LDA #$01
    STA DealerState         ; Set state to first row
    LDA #$00          
    STA row1_Dealer         ; Reset first row card counter
    JMP first_row           ; Jump to first row logic

    first_row_shortcut:
        JMP first_row
    done_second_shortcut:
        JMP done_second

    second_row:
        ; Handle second row of cards (positions 5-10)
        LDA row2_Dealer         ; Load current second row card count
        CMP #$05                ; Check if we've placed 5 cards
        BNE continue_second     ; If not 5 cards yet, continue placing cards

        ; Reset everything when second row is full
        LDA #$00
        STA DealerState         ; Reset to initial state
        STA row1_Dealer         ; Clear first row counter
        STA row2_Dealer         ; Clear second row counter
        RTS

    continue_second:
        ; Generate and store new card for second row
        JSR generateNum
        JSR cardValue
        JSR dealerTotal
        JSR generateSuit
        LDX row2_Dealer
        LDA generatedNum
        STA dealer_Tcards, X    ; Store card number
        LDA generatedSuit  
        STA dealer_Bcards, X    ; Store card suit
        INC row2_Dealer         ; Increment second row counter
        INC dealer_cards_count

        ; Draw all cards in second row
        LDX #$00                ; Initialize loop counter
        LDY #$00                ; Y = sprite data offset

    second_row_loop:
        CPX row2_Dealer         ; Compare current card with total cards
        BEQ done_second         ; If done drawing all cards, exit

        ; Load card data for current position
        LDA dealer_Tcards, X    ; Get stored card number
        STA generatedNum
        LDA dealer_Bcards, X    ; Get stored card suit
        STA generatedSuit

        ; Place upper tile of card (number part)
        LDA #$40                ; Y-position for upper tile
        STA $0228, Y
        LDA generatedNum        ; Load card number
        CLC
        ADC #$A0                ; Add offset for card tile
        STA $0229, Y

        STA dealer_number_array, X

        LDA #$02                ; Palette attribute
        STA $022A, Y
        LDA #$48                ; Base X-position = 72 ($48)
        CLC
        TXA
        ASL                     ; Multiply X by 16 to space cards
        ASL
        ASL
        ASL
        ADC #$48
        STA $022B, Y

        ; Place lower tile of card (suit part)
        LDA #$48                ; Y-position for lower tile
        STA $022C, Y
        LDA generatedSuit       ; Load card suit
        STA $022D, Y

        STA dealer_suit_array, X

        LDA #$02                ; Palette attribute
        STA $022E, Y
        LDA $022B, Y           ; Use same X-position as upper tile
        STA $022F, Y

        TYA                     ; Move to next sprite data block
        CLC
        ADC #$08
        TAY

        INX                     ; Next card
        JMP second_row_loop

    done_second:
        RTS

    first_row:
        ; Handle first row of cards (positions 0-4)
        LDA row1_Dealer         ; Load current first row card count
        CMP #$05                ; Check if we've placed 5 cards
        BNE continue_first      ; If not 5 cards yet, continue

        ; First row is full, prepare for second row
        LDA #$02          
        STA DealerState         ; Set state to second row
        LDA #$00
        STA row2_Dealer         ; Reset second row counter
        RTS

    continue_first:
        ; Generate and store new card
        JSR generateNum         ; Generate random card number
        JSR cardValue
        JSR dealerTotal
        JSR generateSuit        ; Generate random suit
        LDX row1_Dealer         ; Get current card position
        LDA generatedNum
        STA dealer_Tcards, X    ; Store card number

        STA dealer_number_array, X

        LDA generatedSuit
        STA dealer_Bcards, X    ; Store card suit
        INC row1_Dealer         ; Increment first row counter
        INC dealer_cards_count

        ; Draw all cards in first row
        LDX #$00                ; Initialize loop counter
        LDY #$00                ; Y = sprite data offset

    first_row_loop:
        CPX row1_Dealer         ; Compare current card with total cards
        BEQ done_first          ; If done drawing all cards, exit

        ; Load card data for current position
        LDA dealer_Tcards, X    ; Get stored card number
        STA generatedNum
        LDA dealer_Bcards, X    ; Get stored card suit
        STA generatedSuit

        ; Place upper tile of card (number part)
        LDA #$20                ; Y-position = 32 ($20)
        STA $0200, Y
        LDA generatedNum        ; Load card number
        CLC
        ADC #$A0                ; Add offset for card tile
        STA $0201, Y
        LDA #$02                ; Palette attribute
        STA $0202, Y
        LDA #$48                ; Base X-position = 72 ($48)
        CLC
        TXA
        ASL                     ; Multiply X by 16 to space cards
        ASL
        ASL
        ASL
        ADC #$48
        STA $0203, Y

        ; Place lower tile of card (suit part)
        LDA #$28                ; Y-position = 40 ($28)
        STA $0204, Y
        LDA generatedSuit       ; Load card suit
        STA $0205, Y
        LDA #$02                ; Palette attribute
        STA $0206, Y
        LDA $0203, Y           ; Use same X-position as upper tile
        STA $0207, Y

        TYA                     ; Move to next sprite data block
        CLC
        ADC #$08
        TAY

        INX                     ; Next card
        JMP first_row_loop

    done_first:
        RTS
.endproc

; Helper procedure to generate a valid card value
.proc generateNum
    JSR randomizer
    AND #$0F         ; Only keep bottom 4 bits (0-15)     
    CMP #$0C              
    BCS generateNum    ; Try again if too high
    STA generatedNum             ; Store the generated card value
    RTS
.endproc

.proc generateSuit
    JSR randomizer
    AND #$03             ; Only keep bottom 2 bits (0-3)
    CLC                  ; Clear carry for addition
    ADC #$B0             ; Add B0 to get range B0-B3
    STA generatedSuit    ; Store the generated suit value
    RTS
.endproc

.proc drawPlayerCards
    ;Check if player wants to stop drawnig cards
    LDA $0201
    CMP #$00
    BNE done_second_shortcut
    ;Check if a bet has been made
    ;If bet has not been made (bid = 0) button will do nothing
    LDA bet_amount
    CMP #$00
    BEQ done_second_shortcut
    ;Check if last card has been drawn
    LDA $0299
    CMP #$00
    BNE done_second_shortcut
    ; Check current player state to determine which row to draw
    LDA PlayerState           
    CMP #$01           ; First row state (1)
    BEQ first_row_shortcut      ; If in first row state, branch to first_row
    CMP #$02           ; Second row state (2)
    BEQ second_row     ; If in second row state, branch to second_row

    ; If state is 0 (initial state), initialize first row
    LDA #$01
    STA PlayerState    ; Set state to first row
    LDA #$00          
    STA row1_Player    ; Reset first row card counter
    JMP first_row      ; Jump to first row logic

    first_row_shortcut:
        JMP first_row
    done_second_shortcut:
        JMP done_second
    second_row:
        ; Handle second row of cards (positions 5-10)
        LDA row2_Player    ; Load current second row card count
        CMP #$05           ; Check if we've placed 5 cards in second row
        BNE continue_second ; If not 5 cards yet, continue placing cards

        ; Reset everything when second row is full
        LDA #$00
        STA PlayerState    ; Reset to initial state
        STA row1_Player    ; Clear first row counter
        STA row2_Player    ; Clear second row counter
        RTS
        
    continue_second:
        ; Add a new card to second row
        JSR generateNum
        JSR cardValue
        JSR playerTotal
        JSR generateSuit
        LDX row2_Player
        LDA generatedNum
        STA player_Tcards, X    ; Store card number
        LDA generatedSuit
        STA player_Bcards, X    ; Store card number
        INC row2_Player    ; Increment second row counter
        INC player_cards_count  ; Draw all cards in second row
        
        LDX #$00           ; Initialize loop counter
        LDY #$08           ; Y = sprite data offset (8 bytes per sprite)

    second_row_loop:
        ; Draw all cards in second row
        CPX row2_Player    ; Compare current card with total cards
        BEQ done_second    ; If done drawing all cards, exit

        ; Load card data for current position
        LDA player_Tcards, X    ; Get stored card number
        STA generatedNum
        LDA player_Bcards, X    ; Get stored card number
        STA generatedSuit

        ; Place upper tile of card (number part)
        LDA #$B0           ; Y-position = 176 ($B0)
        STA $0270, Y       ; Store in sprite memory ($0270 = second row start)
        LDA generatedNum           ; Card face tile
        CLC
        ADC #$A0
        STA $0271, Y

        STA player_number_array, X   ; Store in tracking array

        LDA #$02           ; Palette attribute
        STA $0272, Y
        LDA #$48           ; Base X-position = 72 ($48)
        CLC
        TXA
        ASL                ; Multiply X by 16 to space cards
        ASL                ; (shift left 4 times = *16)
        ASL 
        ASL
        ADC #$48
        STA $0273, Y       ; Store calculated X-position

        ; Place lower tile of card (suit part)
        LDA #$B8           ; Y-position = 184 ($B8)
        STA $0274, Y
        LDA generatedSuit           ; Card suit tile
        STA $0275, Y

        STA player_suit_array, X   ; Store in tracking array

        LDA #$02           ; Palette attribute
        STA $0276, Y
        LDA $0273, Y       ; Use same X-position as upper tile
        STA $0277, Y

        TYA                ; Move to next sprite data block
        CLC
        ADC #$08
        TAY

        INX                ; Next card
        JMP second_row_loop

    done_second:
        RTS

    first_row:
        ; Handle first row of cards (positions 0-4)
        LDA row1_Player    ; Load current first row card count
        CMP #$05           ; Check if we've placed 5 cards
        BNE continue_first ; If not 5 cards yet, continue

        ; First row is full, prepare for second row
        LDA #$02          
        STA PlayerState    ; Set state to second row
        LDA #$00
        STA row2_Player    ; Reset second row counter
        RTS                ; Return, next A press will start second row

    continue_first:
        ; Generate and store new card
        JSR generateNum    ; Generate random card number
        JSR cardValue
        JSR playerTotal
        JSR generateSuit   ; Generate random suit
        LDX row1_Player    ; Get current card position
        LDA generatedNum
        STA player_Tcards, X ; Store card number
        LDA generatedSuit
        STA player_Bcards, X ; Store card suit
        INC row1_Player    ; Increment first row counter
        INC player_cards_count        ; Draw all cards in first row
        ; Draw all cards in first row
        LDX #$00           ; Initialize loop counter
        LDY #$00           ; Y = sprite data offset

    first_row_loop:
        CPX row1_Player    ; Compare current card with total cards
        BEQ done_first     ; If done drawing all cards, exit

        ; Load card data for current position
        LDA player_Tcards, X ; Get stored card number
        STA generatedNum
        LDA player_Bcards, X ; Get stored card suit
        STA generatedSuit

        ; Place upper tile of card (number part)
        LDA #$90           ; Y-position = 144 ($90)
        STA $0250, Y       ; Store in sprite memory ($0250 = first row start)
        LDA generatedNum   ; Load card number
        CLC                ; Clear carry for addition
        ADC #$A0           ; Add offset for card tile
        STA $0251, Y

        STA player_number_array, X   ; Store in tracking array

        LDA #$02           ; Palette attribute
        STA $0252, Y
        LDA #$48           ; Base X-position = 72 ($48)
        CLC                ; Clear carry for addition
        TXA                ; Calculate X position based on card index
        ASL                ; Multiply by 16 to space cards
        ASL                ; (shift left 4 times = *16)
        ASL                
        ASL                
        ADC #$48           ; Add base X position   
        STA $0253, Y

        ; Place lower tile of card (suit part)
        LDA #$98           ; Y-position = 152 ($98)
        STA $0254, Y
        LDA generatedSuit  ; Load card suit
        STA $0255, Y
    
        STA player_suit_array, X
    
        LDA #$02           ; Palette attribute
        STA $0256, Y
        LDA $0253, Y       ; Use same X-position as upper tile
        STA $0257, Y

        TYA                ; Move to next sprite data block
        CLC
        ADC #$08           ; Move to next sprite data block
        TAY                ; Use as offset for sprite memory

        JSR cardValue

        INX                ; Next card
        JMP first_row_loop

    done_first:
        RTS
.endproc

; Random number generator. Generates a random number between 0 and 51
; Returns the random number in A (lower byte) and the seed in seed (16-bit)
; Uses the X and Y registers as temporary variables (not preserved) and the carry flag (preserved) for subtraction with borrow (SBC) instruction
; The seed is updated with a new random value after each call to this function (16-bit)
; The seed should be initialized to a non-zero value before the first call to this function (e.g. seed = 0x1234)
.proc randomizer
    ; Mix frame counter into seed
    lda frame_counter  ; You'll need to maintain this elsewhere
    eor seed
    sta seed
    
    lda seed+1
    ldy #8
    @loop:
        lsr
        ror seed
        bcc @skip_eor
        eor #$B4
    @skip_eor:
        sta seed+1
        dey
        bne @loop

        lda seed
        
    @mod52:
        sec
        sbc #52
        bcs @mod52
        adc #52
        rts
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes: 
    ;paletes for Tileset A (Sprites)
    .byte $0f, $2d, $1a, $30 ;Palette 0(Base Background)
    .byte $0f, $0f, $1a, $30 ;Palette 1(Black Cards)
    .byte $0f, $05, $1a, $30 ;Palette 2(Red Cards)
    .byte $0f, $0b, $1a, $30 ;Palette 3

    ;paletes for Tileset B (Background)
    .byte $0f, $2d, $1a, $30 ;Palette 0(Base Background)
    .byte $0f, $0f, $1a, $30 ;Palette 1(Black Cards)
    .byte $0f, $05, $1a, $30 ;Palette 2(Red Cards)
    .byte $0f, $0b, $1a, $30 ;Palette 3

background:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$01,$02,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$12,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	.byte $18,$18,$18,$18,$14,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$2f,$30,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$33,$34,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$35,$36,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$16,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19
	.byte $19,$19,$19,$19,$17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$01,$1b,$03,$1c,$1d,$1e,$11,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$12,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	.byte $18,$18,$18,$18,$14,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$16,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19
	.byte $19,$19,$19,$19,$17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$02,$03,$04,$05,$11,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$0a,$0b,$0c,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $03,$1b,$1d,$39,$03,$08,$0c,$1e,$2a,$01,$1d,$1e,$1d,$2b,$02,$05
	.byte $1e,$07,$04,$2c,$07,$03,$08,$1e,$2a,$0c,$1e,$07,$2d,$2e,$1d,$2b
	.byte $04,$55,$a5,$a5,$65,$55,$59,$8a,$00,$88,$aa,$aa,$aa,$99,$66,$8a
	.byte $00,$58,$5a,$5a,$5a,$59,$55,$aa,$88,$aa,$6a,$9a,$5a,$aa,$6a,$99
	.byte $00,$99,$aa,$aa,$a5,$95,$65,$59,$44,$99,$aa,$aa,$96,$55,$55,$66
	.byte $04,$55,$55,$55,$55,$59,$56,$56,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$00

attribute:
	.byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000

.segment "CHR"
.incbin "blackJack.chr"