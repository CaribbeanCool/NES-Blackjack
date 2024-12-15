; Controller ($2000) > write
;
; 7654 3210
; |||| ||||
; |||| ||++- Base nametable address
; |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
; |||| |+--- VRAM address increment per CPU read/write of PPUDATA
; |||| |     (0: add 1, going across; 1: add 32, going down)
; |||| +---- Sprite pattern table address for 8x8 sprites
; ||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
; |||+------ Background pattern table address (0: $0000; 1: $1000)
; ||+------- Sprite size (0: 8x8; 1: 8x16)
; |+-------- PPU master/slave select
; |          (0: read backdrop from EXT pins; 1: output color on EXT pins)
; +--------- Generate an NMI at the start of the
;            vertical blanking interval (0: off; 1: on)
;
; Equivalently, bits 0 and 1 are the most significant bit of the scrolling
; coordinates (see Nametables and PPU scroll):
;
; 7654 3210
;        ||
;        |+- 1: Add 256 to the X scroll position
;        +-- 1: Add 240 to the Y scroll position
PPUCTRL   = $2000

; Mask ($2001) > write
;
; 76543210
; ||||||||
; |||||||+- Grayscale (0: normal color; 1: produce a monochrome display)
; ||||||+-- 1: Show background in leftmost 8 pixels of screen; 0: Hide
; |||||+--- 1: Show sprites in leftmost 8 pixels of screen; 0: Hide
; ||||+---- 1: Show background
; |||+----- 1: Show sprites
; ||+------ Intensify reds (and darken other colors)
; |+------- Intensify greens (and darken other colors)
; +-------- Intensify blues (and darken other colors)
PPUMASK   = $2001

; Status ($2002) < read
;
; 7654 3210
; |||| ||||
; |||+-++++- Least significant bits previously written into a PPU register
; |||        (due to register not being updated for this address)
; ||+------- Sprite overflow. The intent was for this flag to be set
; ||         whenever more than eight sprites appear on a scanline, but a
; ||         hardware bug causes the actual behavior to be more complicated
; ||         and generate false positives as well as false negatives; see
; ||         PPU sprite evaluation. This flag is set during sprite
; ||         evaluation and cleared at dot 1 (the second dot) of the
; ||         pre-render line.
; |+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
; |          a nonzero background pixel; cleared at dot 1 of the pre-render
; |          line.  Used for raster timing.
; +--------- Vertical blank has started (0: not in VBLANK; 1: in VBLANK).
;            Set at dot 1 of line 241 (the line *after* the post-render
;            line); cleared after reading $2002 and at dot 1 of the
;            pre-render line.
PPUSTATUS = $2002

; Scroll ($2005) >> write x2
PPUSCROLL = $2005

; Address ($2006) >> write x2
PPUADDR   = $2006
PPUDATA   = $2007

; OAM address ($2003) > write / OAM data ($2004) > write
; Set the "sprite" address using OAMADDR ($2003)
; Then write the following bytes via OAMDATA ($2004)

; - Byte 0 (Y Position)

; - Byte 1 (Tile Index)
;
; 76543210
; ||||||||
; |||||||+- Bank ($0000 or $1000) of tiles
; +++++++-- Tile number of top of sprite (0 to 254; bottom half gets the next tile)

; - Byte 2 (Attributes)
;
; 76543210
; ||||||||
; ||||||++- Palette (4 to 7) of sprite
; |||+++--- Unimplemented
; ||+------ Priority (0: in front of background; 1: behind background)
; |+------- Flip sprite horizontally
; +-------- Flip sprite vertically

; - Byte 3 (X Position)
OAMADDR   = $2003
OAMDMA    = $4014

CONTROLLER1 = $4016
CONTROLLER2 = $4017

BTN_RIGHT   = %00000001
BTN_LEFT    = %00000010
BTN_DOWN    = %00000100
BTN_UP      = %00001000
BTN_START   = %00010000
BTN_SELECT  = %00100000
BTN_B       = %01000000
BTN_A       = %10000000

minValue = $00
maxValue = $FA
Val = 5