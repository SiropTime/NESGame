.include "constants.inc"

.segment "ZEROPAGE"
.importzp addr_lo, addr_hi

.segment "CODE"

.export load_level
.proc load_level

    RTS
.endproc

.export drawing_bg
.proc drawing_bg

    ;   ; Загружаем большую звезду
    ;   ; nametable
    ;   LDA PPUSTATUS
    ;   LDA #$21
    ;   STA PPUADDR
    ;   LDA #$62
    ;   STA PPUADDR
    ;   LDX #$2f
    ;   STX PPUDATA
    ;   ; attribute
    ;   LDA PPUSTATUS
    ;   LDA #$23
    ;   STA PPUADDR
    ;   LDA #$d0
    ;   STA PPUADDR
    ;   LDA #%01000000
    ;   STA PPUDATA
    ;   ; Загружаем ещё
    ;   LDA PPUSTATUS
    ;   LDA #$22
    ;   STA PPUADDR
    ;   LDA #$3b
    ;   STA PPUADDR
    ;   LDX #$2f
    ;   STX PPUDATA

    ;   LDA PPUSTATUS
    ;   LDA #$23
    ;   STA PPUADDR
    ;   LDA #$06
    ;   STA PPUADDR
    ;   LDA #%00001000

.endproc