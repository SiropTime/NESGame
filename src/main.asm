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

  JSR update_player
  JSR draw_player

  LDA #$00
  STA $2005
  STA $2005
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
      CPX #$20
      BNE load_palettes
    ; загрузка данных о спрайте
    LDX #$00
    load_sprites:
      LDA sprites, X
      STA $0200, X
      INX
      CPX #$10
      BNE load_sprites
      
      ; Загружаем большую звезду
      ; nametable
      LDA PPUSTATUS
      LDA #$21
      STA PPUADDR
      LDA #$62
      STA PPUADDR
      LDX #$2f
      STX PPUDATA
      ; attribute
      LDA PPUSTATUS
      LDA #$23
      STA PPUADDR
      LDA #$d0
      STA PPUADDR
      LDA #%01000000
      STA PPUDATA
      ; Загружаем ещё
      LDA PPUSTATUS
      LDA #$22
      STA PPUADDR
      LDA #$3b
      STA PPUADDR
      LDX #$2f
      STX PPUDATA

      LDA PPUSTATUS
      LDA #$23
      STA PPUADDR
      LDA #$06
      STA PPUADDR
      LDA #%00001000


  forever:
    JMP forever
.endproc

.proc draw_player
  ; Сохранение регистров в стеке, чтобы не привести к конфликтам
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Записываем номера тайлов корабля
  LDA #$05
  STA $0201
  LDA #$06
  STA $0205
  LDA #$07
  STA $0209
  LDA #$08
  STA $020d

  ; Записываем аттрибуты тайлов игрока
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; Сохраняем координаты
  ; Верхний левый тайл
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; Правый верхний
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; Нижний левый
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; Нижний правый
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; Восстанавливаем регистры и возвращаемся из функции
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP

  RTS
.endproc

.proc update_player
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA player_x
    CMP #$e0
    ; BCC not_at_right_edge ; < Правой границы
    ; LDA #$00
    ; STA player_dir
    INC player_x
    JMP exit_subroutine
    ; JMP direction_set

  not_at_right_edge:
    LDA player_x
    CMP #$10
    BCS direction_set ; > Больше левой границы
    LDA #$01
    STA player_dir

  direction_set:
    LDA player_dir
    CMP #$01
    BEQ move_right ; если не равно 1, меняем направление

    DEC player_x
    JMP exit_subroutine

  move_right:
    INC player_x

  exit_subroutine:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.segment "VECTORS" ; передача процессору обработчиков прерываний
.addr nmi_handler, reset_handler, irq_handler ; даёт адрес памяти, соответствующий метке

.segment "ZEROPAGE"
  player_x: .res 1
  player_y: .res 1
  player_dir: .res 1
.exportzp player_x, player_y


; Данные
.segment "RODATA"
palettes:
  ; палитры фонов
  .byte $0f, $12, $23, $27
  .byte $0f, $2b, $3c, $39
  .byte $0f, $0c, $07, $13
  .byte $0f, $19, $09, $29
  ; палитры спрайтов
  .byte $0f, $2d, $10, $15
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
sprites:
  ; Y, Номер тайла, Аттрибуты, X
  .byte $70, $05, $00, $80 
  .byte $70, $06, $00, $88
  .byte $78, $07, $00, $80
  .byte $78, $08, $00, $88

.segment "CHR"
.incbin "starfield.chr"