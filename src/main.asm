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
    ; загружаем цвет в ППУ через 2007 адрес
    LDA #$1c ; загружаем в аккумулятор индекс цвета
    STA PPUDATA ; сохраняем цвет в PPU
    LDA #$19
    STA PPUDATA
    LDA #$09
    STA PPUDATA
    LDA #$0f
    STA PPUDATA
    ; загрузка данных о спрайте
    LDA #$70
    STA $0200 ; Y-координата первого спрайта
    LDA #$05
    STA $0201 ; номер тайла первого спрайта
    LDA #$00
    STA $0202 ; атрибуты первого спрайта
    LDA #$80
    STA $0203 ; X-координата первого спрайта
    
  forever:
    JMP forever
.endproc

.segment "VECTORS" ; передача процессору обработчиков прерываний
.addr nmi_handler, reset_handler, irq_handler ; даёт адрес памяти, соответствующий метке
; то есть мы даём записываем в нужные адреса памяти обработчики прерываний

.segment "CHR"
.incbin "graphics.chr"