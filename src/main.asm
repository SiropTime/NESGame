.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler ; запрос прерывания
RTI ; возврат из прерывания
.endproc

.proc nmi_handler ; немаскируемое прерывание
  ; подготавливаем PPU к передаче в OAM
  LDA #$00 ; передаём с нулевого байта
  STA OAMADDR
  ; передаём 256 байтов в промежутке 0200-02ff в OAM
  LDA #$02
  STA OAMDMA
  RTI
.endproc

.import reset_handler

.export main
.proc main
    ; загрузка палитры
    ; данный процесс постоянен при отрисовке любого изображения
    LDX PPUSTATUS ; чтение статуса ППУ
    ; загружаем адрес палитры через адрес $2006, позволяющий ЦП обратиться к ППУ
    LDX #$3f ; первая часть загрузки адреса палитр PPU в память
    STX PPUADDR ; сохраняем старший байт адреса в PPUADDR
    LDX #$00 ; вторая часть загрузки адреса палитр PPU в память ($3f00)
    STX PPUADDR ; сохраняем младший адреса байт в PPUADDR
    load_palettes:
      LDA palettes, X
      STA PPUDATA
      INX
      CPX #$10
      BNE load_palettes
    ; загрузка данных о спрайте
    LDX #$00
    load_sprites:
      LDA sprites, X
      STA $0200, X
      INX
      CPX #$10
      BNE load_sprites
  forever:
    JMP forever
.endproc

.segment "VECTORS" ; передача процессору обработчиков прерываний
.addr nmi_handler, reset_handler, irq_handler ; даёт адрес памяти, соответствующий метке

; Данные
.segment "RODATA"
palettes:
  .byte $29, $19, $09, $0f
  .byte $2c, $1c, $0c, $0f
  .byte $24, $14, $04, $0f
  .byte $22, $12, $02, $0f
sprites:
  ; Y, Номер тайла, Аттрибуты, X
  .byte $70, $05, $00, $80 
  .byte $70, $06, $00, $88
  .byte $78, $07, $00, $80
  .byte $78, $08, $00, $88

.segment "CHR"
.incbin "graphics.chr"