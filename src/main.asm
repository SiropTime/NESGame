.include "constants.inc"
.include "header.inc"


.segment "CODE"
.proc irq_handler ; запрос прерывания
    RTI ; возврат из прерывания
.endproc

.import update_player
.proc nmi_handler ; немаскируемое прерывание
  ; подготавливаем PPU к передаче в OAM
  LDA #$00 ; передаём с нулевого байта
  STA OAMADDR
  ; передаём 256 байтов в промежутке 0200-02ff в OAM
  LDA #$02
  STA OAMDMA

  JSR update_player

  LDA #%10010010
  STA PPUCTRL ; сохраняем данные значения в PPUMASK
  LDA #%00111110
  STA PPUMASK

  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

  RTI
.endproc

.import reset_handler



.import load_level
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
      LDX #$00
  
  ; Выключаем рендеринг и вызов NMI перед отрисовкой фона,
  ; так как PPU может банально не успеть
  ; Также отключаем скроллинг, чтобы таблица имён не укатилась
  LDA #%00000000
  STA PPUMASK
  STA PPUCTRL
  STA PPUSCROLL
  STA PPUSCROLL

      load_background: ; Инициализируем всё перед отрисовкой фона
      LDA PPUSTATUS ; Загружаем адрес первой таблицы имён
      LDX #$20
      STX PPUADDR
      LDX #$00
      STX PPUADDR
      LDA #<nametable ; Берём нижний байт адреса таблицы имён
      STA addr_lo
      LDA #>nametable ; Берём верхний байт адреса таблицы имён
      STA addr_lo+1 ; Получаем в итоге указатель из двух байт
      LDA #$00 ; Очищаем аккумулятор

      LDX #$04 ; 4 "страницы" (блоков по 256 байт) надо прочитать
      LDY #$00 ; Итерируемое значение
      loop:
        LDA (addr_lo), Y ; Подгружаем значение из таблицы имён нашей
        STA PPUDATA ; Грузим её в PPU
        INY ; Y++
        BNE loop ; Если не произошло переноса (т.е. > 256) повторяем
        DEX ; Иначе прочитали страницу, X--
        BEQ end ; Если X равен 0, то заканчиваем
        INC addr_lo+1 ; Иначе увеличиваем старший байт на 1
        JMP loop ; И возвращаемся к циклу
      end:
  
  ; Восстанавливаем рендеринг и всё сопуствующее
  LDA #%10010010
  STA PPUCTRL 
  LDA #%00111110
  STA PPUMASK

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

.segment "ZEROPAGE"
  player_x: .res 1
  player_y: .res 1
  addr_lo: .res 2

.exportzp player_x, player_y

; Данные
.segment "RODATA"
palettes:
  ; палитры фонов
  .byte $0c, $00, $10, $30
  .byte $0c, $08, $1c, $05
  .byte $0c, $07, $27, $35
  .byte $0c, $07, $19, $39
  ; палитры спрайтов
  .byte $0c, $05, $12, $27
  .byte $0c, $05, $23, $33
  .byte $0c, $19, $09, $29
  .byte $0c, $19, $09, $29
sprites:
  ; Y, Номер тайла, Аттрибуты, X
  .byte $a0, $10, $00, $80 
  .byte $a0, $11, $00, $88
  .byte $a8, $20, $00, $80
  .byte $a8, $21, $00, $88 

nametable:
	; Карта, ака таблица имён
  .incbin "nametable.nam"


.segment "CHR"
.incbin "ninjastrike1.chr"

