.include "constants.inc"

.segment "ZEROPAGE"
  .importzp player_x, player_y, gravity, jump

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler ; прерывание для резета или первого включения
    SEI ; задание бита игнорирования прерывания.
    ; нужен чтобы процессор не прерывался пока инициализируется
    CLD ; отключение режима двоично-десятичного кода
    LDX #$00 ; устанавливаем отключение отрисовки лишнего мусора при инициализации
    STX PPUCTRL ; загружаем обновлённую маску в PPUCTRL
    STX PPUMASK ; загружаем обновлённую маску в PPUMASK

    ; Инициализируем игрока
    LDA #$68
    STA player_x
    LDA #$cd
    STA player_y
    LDA #$10
    LDA #$10
    STA $0201
    LDA #$11
    STA $0205
    LDA #$20
    STA $0209
    LDA #$21
    STA $020d

    LDA #$00
    STA gravity
    LDA #DEFAULT_JUMP
    STA jump

    ; Сохраняем атрибуты спрайта игрока
    LDA #%00000001 ; меняем палитру на 1 для верхних спрайтов
    STA $0202
    STA $0206
    LDA #%00000000 ; меняем палитру на 0 для нижних спрайтов
    STA $020a
    STA $020e

    ; Обнуляем геймпад
    LDA #$01
    STA JOYPAD1
    LDA #$00
    STA JOYPAD1


  vblankwait:
    BIT PPUSTATUS ; получем состояние ППУ
    BPL vblankwait ; пока он не инициализируется окончательно
    
    ; 7 6 5 4 3 2 1 0
    ; 0 0 0 1 1 1 1 0
    ; 0 Режим оттенков серого, 1 отображение левых 8 пикселей,  2 отображение правых 8 пикселей,  3 включён фон
    ; 4 передний план, 5 выделение красного, 6 выделение зелёного, 7 выделение синего
    LDA #%10010010
    STA PPUCTRL ; сохраняем данные значения в PPUMASK
    LDA #%00011110
    STA PPUMASK
  LDX #$00
  LDA #$FF
  ; Очищаем экран, чтобы избавиться от графических багов при инициализации
  clear_oam:
    STA $0200,X ; Задаём Y-координату всем спрайтам за пределами экрана
    INX
    INX
    INX
    INX
    BNE clear_oam

  vblankwait2:
      BIT PPUSTATUS
      BPL vblankwait2

  JMP main ; переходим к главной программе
.endproc